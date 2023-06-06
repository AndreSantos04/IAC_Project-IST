;   GRUPO 55
;   107041- André Antunes Santos
;   107052 - Tomás Maria Agostinho Bernardino
;   88571 - Artur Miguel e Gaio Lopes dos Santos Pinto


; COMANDOS:
; 2 - Movimenta o asteroide
; A - Movimenta a sonda
; B - Aumenta o valor do display
; C - Começa o jogo
; D - Pausa o jogo
; E - Terminar o jogo

; F - Diminui o valor do display

;*********************************************************************************
; TO-DO
; 1 - CRIAR PROCESSO DO TECLADO - ANDRÉ
; 2 - CRIAR PROCESSO DO PAINEL DE CONTROLO - TOMÁS
; 3 - CRIRA PROCESSO DO DESENHO DE ASTEROIDE E SONDAS - TOMÁS
; 4 - CRIAR PROCESSO COLISAO + DISPLAY - ANDRÉ, falta colisao 
; 5 - PROCESSO DE INICIO/PAUSA/FIM - ANDRÉ
; 6 - VARIOS ASTEROIDES E SONDAS



; *********************************************************************************
; * Constantes
; *********************************************************************************
DISPLAYS		    EQU 0A000H	; endereço do periférico que liga aos displays
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN ao qual vão ser acedidos os bits de 0 a 3)
PIN                 EQU 0E000H  ; endereço do periférico PIN ao qual vão ser acedidos os bits de 4 a 7
LINHA_TECLADO	    EQU 0010H	; linha a testar 1 bit a esquerda da linha maxima (8b)
MASCARA				EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
MASCARA_2_BITS      EQU 03E7H   ; para isolar os 2 bits de menor peso
FATOR               EQU 1000    ; fator da divisao para a conversão de hexadecimal para decimal



COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    			EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   			EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    			EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     			EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 				EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  	EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
SELECIONA_CENARIO_FRONTAL   EQU COMANDOS + 46H		; endereço do comando para selecionar uma imagem frontal
TOCA_SOM					EQU COMANDOS + 5AH		; endereço do comando para tocar um som
APAGA_CENARIO_FRONTAL       EQU COMANDOS + 44H      ; endereço do comando para apagar o cenário frontal

; * Constantes - posição
LINHA_ASTEROIDE         EQU  0      ; 1ª linha do asteroide 
COLUNA_ASTEROIDE_ESQ	EQU  0      ; 1ª coluna do asteroide
COLUNA_ASTEROIDE_MEIO   EQU  30     ; coluna onde começar a desenhar para o asteroide ficar centralizado
LINHA_NAVE              EQU  27     ; 1ª linha da nave 
COLUNA_NAVE             EQU  25     ; 1ª coluna da nave 
LINHA_SONDA             EQU  26      ; linha da sonda 
COLUNA_SONDA            EQU  32      ; coluna da sonda 
LINHA_PAINEL			EQU  29
COLUNA_PAINEL			EQU  29

MIN_COLUNA		        EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		        EQU  63     ; número da coluna mais à direita que o objeto pode ocupar


; * Dimensões dos bonecos

LARGURA_ASTEROIDE		EQU	5
ALTURA			        EQU	5		; altura do asteroide e da nave
LARGURA_NAVE            EQU 15
LARGURA_PAINEL_NAVE		EQU 7
ALTURA_PAINEL_NAVE		EQU 2	

;*Constantes - movimento
ATRASO			EQU	0005H		; (inicialmente a 400) atraso para limitar a velocidade de movimento do asteroide/nave
ALCANCE_SONDA   EQU 000CH 		; alcance maximo da sonda


;*Constantes - movimento
DECREMENTO              EQU  -1     ; indica o decremento da coluna/linha do asteroide/sonda
INCREMENTO              EQU  1      ; indica o incremento da coluna/linha do asteroide/sonda
BAIXO                   EQU  0      ; indica o incremento da coluna do asteroide ao andar para baixo
CIMA                    EQU  0      ; indica o incremento da coluna da sonda ao andar para cima
; * Constantes - cores
VERMELHO	  EQU 0FF00H ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
LARANJA       EQU 0FFA0H ; cor do pixel: laranja em ARGB (opaco e vermelho no máximo, verde a 10 e azul a 0)
VERDE         EQU 0F5F2H ; cor do pixel: verde em ARGB (opaco e verde no máximo, vermelho e azul a 0)
AZUL_CIANO    EQU 0F0FFH ; cor do pixel: verde em ARGB (opaco, verde e azul no máximo, vermelho a 0)
CINZENTO      EQU 0F999H ; cor do pixel: verde em ARGB (opaco no máximo, vermelho, verde e azul a 9)
PRETO         EQU 0F000H ; cor do pixel: preto em ARGB (opaco no máximo, vermelho, verde e azul a 0)
ROSA          EQU 0FF3FH ; cor do pixel: rosa em ARGB (opaco e vermelho no máximo, verde e azul a 7)
AMARELO		  EQU 0FFF0H ; cor do pixel: amarelo em ARGB (opaco, vermelho e verde no máximo, azul a 0)


; * Constantes - teclado/display

INCREMENTO_DISPLAY      EQU 000BH    ; tecla que incrementa o valor do display
DECREMENTO_DISPLAY      EQU 000FH    ; tecla que decremento o valor do display
SONDA_CIMA              EQU 000AH    ; tecla que move a sonda para cima
ASTEROIDE_BAIXO         EQU 0002H    ; tecla que move o asteroide para baixo

TECLA_JOGO_COMECA       EQU 000CH    ; tecla que começa o jogo
TECLA_JOGO_PAUSA        EQU 000DH    ; tecla que pausa o jogo
TECLA_JOGO_TERMINA      EQU 000EH    ; tecla que termina o jogo

JOGO                    EQU 0    ; estado do jogo: jogo
SEM_ENERGIA             EQU 1    ; estado do jogo: perdeu sem energia
COLISAO                 EQU 2    ; estado do jogo: perdeu por colisão
PAUSA                   EQU 3    ; estado do jogo: pausa
TERMINADO               EQU 4    ; estado do jogo: terminado

VALOR_INICIAL_DISPLAY_HEX EQU 0064H   ; valor inicial do display (64 EM HEXADECIMAL)
VALOR_INICIAL_DISPLAY     EQU 0100H   ; valor inicial do display (100 EM DECIMAL)
MIN_VALOR_DISPLAY         EQU 0000H   ; valor minimo do display
MAX_VALOR_DISPLAY         EQU 03E7H   ; valor maximo do display

DIMINUI_ENERGIA_INT       EQU 0003H   ; valor que diminui a energia devido a interrupcao
AUMENTA_ENERGIA           EQU 0019H   ; valor que aumenta a energia devido a uma asteroide mineravel
DIMINUI_ENERGIA_SONDA     EQU 0005H   ; valor que diminui a energia devido a sonda

DISPLAY_ENERGIA_INT       EQU 0       ; indica ao processo display que a energia diminui devido a interrupcao
DISPLAY_AUMENTA_ENERGIA   EQU 1       ; indica ao processo display que a energia aumenta
DISPLAY_ENERGIA_SONDA     EQU 2       ; indica ao processo display que a energia diminui devido a sonda

; * Constantes - MEDIA CENTER
SOM_DISPARO        EQU 2
SOM_ASTEROIDE      EQU 1

IMAGEM_INICIO      EQU 0
IMAGEM_JOGO        EQU 1
IMAGEM_PAUSE       EQU 2
IMAGEM_TERMINADO   EQU 3
IMAGEM_SEMENERGIA  EQU 4
IMAGEM_COLISAO     EQU 5




; *********************************************************************************
; * Registos usados globalmente: (Vamos escrevendo para termos noção dos registos já utilizados)
; Como input: R0, R1, R2 (podem ser alterados após o seu uso nas rotinas)
; Como output:(não convém serem alterados)
; - R5,R6,R7 ->posição do asteroide(R5 e R6) e posição da sonda(R7)
; - R8: Estado do jogo (POR COMECAR, A JOGAR, PAUSA)
; - R9: Tecla clicada
; - R11: Valor hexadecimal do display 
; - R10 : Descrição do papel de registo de controlo de R10
;         Inicialmente a 0, o registo 10 vai servir para controlo do desenho do asteroide e da sonda, tal que,
;         Se R10 estiver a -1 e alguma das rotinas de desenho for chamada irá apagar o desenho (reescrever os pixels a transparente),
;         se estiver a 0 não está nenhum asteroide ou sonda desenhados, se estiver a 1 está o asteroide apenas,
;         a 2 a sonda apenas e a 3 a sonda e o asteroide.
; *********************************************************************************

; *********************************************************************************
; * Dados 
; *********************************************************************************
	PLACE       1000H


; * Reserva do espaço das pilhas dos diferentes processos

	STACK 100H			; espaço reservado para a pilha (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)

	STACK 100H			; 100H bytes reservados para a pilha do processo "painel_nave"
SP_painel_nave:			; endereço inicial da pilha

    STACK 100H			; espaço reservado para a pilha do processo teclado
SP_teclado:

    STACK 100H			; espaço reservado para a pilha do processo DISPLAY
SP_display:    

    STACK 100H          ; 100H bytes reservados para a pilha do processo "spawn_asteroide"
SP_asteroide:           ; endereço inicial da pilha

    STACK 100H
SP_pause:

    STACK 100H
SP_game_over:
; LOCKS dos diferentes processos e rotinas

tecla_carregada:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
						; uma vez por cada tecla carregada
							
tecla_continuo:
	LOCK 0				; LOCK para o teclado comunicar aos restantes processos que tecla detetou,
						; enquanto a tecla estiver carregada


jogo_pausado:           ; LOCK para comunicar aos processos que o jogo está em pausa
    LOCK 0               

energia_display:        ; LOCK para bloquear o processo DISPLAY e comunicar qual a alteração a fazer 
    LOCK 0              ; se o LOCK estiver a 0, a energia diminui (RELOGIO DE INTERRUPCAO)
                        ; se o LOCK estiver a 1, a energia aumenta (ASTEROIDE MINERAVEL)
                        ; se o LOCK estiver a 2, a energia diminui (SONDA)


espera_tecla_recomeçar:
	LOCK 0

int_asteroide:
    LOCK 0

game_over:              ; LOCK para comunicar aos processos que o jogo terminou
    LOCK 0

int_painel_nave:
	LOCK 0			    ; controla o processo da mudança de cor do painel de controlo da nave

display_HEX:
    WORD 0064H          ; WORD para o valor do display em hexadecimal


estado_jogo:
	WORD 0				; WORD para o estado do jogo (0 - em jogo, 1 - perdeu sem energia, 2 - perdeu por colisão, 3 - em pausa)

nova_nave:
    WORD 0              ; WORD para o redesenhar a nave

tecla:
    WORD 0              ; WORD para a tecla carregada


linha_asteroide:                ; variável que guarda a linha do asteroide no momento
    WORD LINHA_ASTEROIDE

coluna_asteroide:
    WORD COLUNA_ASTEROIDE_ESQ   ; variável que guarda a linha do asteroide no momento

linha_sonda:
    WORD LINHA_SONDA            ;variável que guarda a linha da sonda



; * Tabelas dos objetos

; Tabela das rotinas de interrupção (por completar)
tabela_rot_int:
	WORD 0;rot_int_0
	WORD 0
    WORD rot_int_2          ; rotina de atendimento da interrupção 2(energia)
	WORD rot_int_3			; rotina de atendimento da interrupção 3




DEF_ASTEROIDE_N_MINERAVEL:					; tabela que define o asteroide não minerável (largura, altura, pixels e sua cor)
	WORD		 LARGURA_ASTEROIDE
    WORD        ALTURA
	WORD		VERMELHO , 0 , VERMELHO , 0 , VERMELHO 		
    WORD		0 , VERMELHO , LARANJA , VERMELHO , 0
    WORD        VERMELHO , LARANJA , 0 , LARANJA , VERMELHO 
    WORD		0 , VERMELHO , LARANJA , VERMELHO , 0
	WORD		VERMELHO , 0 , VERMELHO , 0 , VERMELHO 
  

DEF_ASTEROIDE_MINERAVEL:					; tabela que define o asteroide minerável 
	WORD		LARGURA_ASTEROIDE
    WORD        ALTURA
	WORD		0 , VERDE , VERDE , VERDE , 0		
    WORD		VERDE , VERDE , VERDE , VERDE , VERDE 
    WORD        VERDE , VERDE , VERDE , VERDE , VERDE 
    WORD		VERDE , VERDE , VERDE , VERDE , VERDE 
	WORD		0 , VERDE , VERDE , VERDE , 0	

DEF_EXPLOSAO_ASTEROIDE:					; tabela que define o asteroide quando explode 
	WORD		LARGURA_ASTEROIDE
    WORD        ALTURA
	WORD		0 , AZUL_CIANO , 0 , AZUL_CIANO , 0		
    WORD		AZUL_CIANO , 0, AZUL_CIANO , 0, AZUL_CIANO 
    WORD        0 , AZUL_CIANO , 0 , AZUL_CIANO , 0
    WORD		AZUL_CIANO , 0, AZUL_CIANO , 0, AZUL_CIANO 
	WORD		0 , AZUL_CIANO , 0 , AZUL_CIANO , 0	

DEF_NAVE:					; tabela que define a nave
  	WORD    LARGURA_NAVE
  	WORD    ALTURA
  	WORD    0, 0, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, 0, 0
  	WORD    0, VERMELHO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, VERMELHO, 0
  	WORD    VERMELHO, PRETO, PRETO, PRETO, CINZENTO, LARANJA, AZUL_CIANO, VERMELHO, AZUL_CIANO, VERDE, CINZENTO, PRETO, PRETO, PRETO, VERMELHO
  	WORD    VERMELHO, PRETO, PRETO, PRETO, VERDE, CINZENTO, VERMELHO, CINZENTO, LARANJA, CINZENTO, AZUL_CIANO, PRETO, PRETO, PRETO, VERMELHO
  	WORD    VERMELHO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, VERMELHO


DEF_SONDA:					; tabela que define a sonda (apenas um pixel)
  	WORD    ROSA


tabela_cores:				; Tabela que define as cores possíveis para o painel de controlo					
	WORD 	VERMELHO		
	WORD 	VERDE
	WORD 	AMARELO
	WORD 	AZUL_CIANO
	WORD	CINZENTO


; * Tabelas combinações (Coluna inicial e direção em relação à coluna):

inicio_esquerda_move_direita:
    WORD    MIN_COLUNA
    WORD    INCREMENTO 

inicio_meio_move_esquerda:
    WORD    COLUNA_ASTEROIDE_MEIO
    WORD    DECREMENTO

inicio_meio_move_baixo:
    WORD    COLUNA_ASTEROIDE_MEIO
    WORD    BAIXO

inicio_meio_move_direita:
    WORD    COLUNA_ASTEROIDE_MEIO
    WORD    INCREMENTO

inicio_direita_move_esquerda:
    WORD    MAX_COLUNA
    WORD    DECREMENTO

; Tabela que será acedida para determinar a posição do asteróide a desenhar
tabela_geral_posicao:
    WORD inicio_esquerda_move_direita
    WORD inicio_meio_move_esquerda
    WORD inicio_meio_move_baixo
    WORD inicio_meio_move_direita
    WORD inicio_direita_move_esquerda






; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     ; o código tem de começar em 0000H
inicio:


    MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir à última da pilha
    MOV BTE, tabela_rot_int ; inicializa BTE (registo de Base da Tabela de Exceções)                        
    
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV [APAGA_CENARIO_FRONTAL], R1 ; apaga o cenário frontal (o valor de R1 não é relevante)
    MOV	 R1, IMAGEM_INICIO			; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    


    MOV R1, TERMINADO
    MOV [estado_jogo], R1 ; iniciamos o programa no estado terminado
    
    ;EI0
    EI2
    EI3
    EI

    CALL proc_teclado    ; Cria o processo teclado

espera_inicio_jogo:
    MOV R1, [tecla_carregada] ; Verifica se alguma tecla foi carregada
    MOV R2, TECLA_JOGO_COMECA
    CMP R1, R2
    JNZ espera_inicio_jogo
    CALL rot_inicia_jogo


inicia:


;;;;;;; DAR OS CALLS AOS PROCESSOS ;;;;;;;;
    CALL proc_painel_nave
    CALL proc_display
    CALL proc_spawn_asteroide
    CALL proc_fim_jogo
    CALL proc_pause
    CALL proc_fim_jogo

; **********************************************************************
; Processo
;

; TECLADO - Processo que deteta quando se carrega numa tecla e coloca o valor no LOCK
;		  	tecla_carregada
;		
;		R2 - endereço periferico das linhas 
;		R3 - endereço periferico das colunas
;		R5 - mascara
; **********************************************************************



PROCESS SP_teclado	; indicação de que a rotina que se segue é um processo,

						    ; com indicação do valor para inicializar o SP
proc_teclado:
	MOV  R2, TEC_LIN		; endereço do periférico das linhas
	MOV  R3, TEC_COL		; endereço do periférico das colunas
	MOV  R5, MASCARA		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

    loop_linha:
        
       	MOV R1, LINHA_TECLADO ; por linha a 0001 0000 - para testar qual das linhas foi clicada

    espera_tecla:				; neste ciclo espera-se até uma tecla ser premida
        WAIT
    					    ; este ciclo é potencialmente bloqueante, pelo que tem de
    						; ter um ponto de fuga (aqui pode comutar para outro processo)
        SHR R1, 1           ; dividir por 2 para testar as varias linhas do teclado
        JZ  loop_linha      ; se for zero recomeçar o ciclo, caso contrario testar colunas 

    	MOVB [R2], R1			; escrever no periférico de saída (linhas)
    	MOVB R0, [R3]			; ler do periférico de entrada (colunas)
    	AND  R0, R5			; elimina bits para além dos bits 0-3
    	CMP  R0, 0			; há tecla premida?
    	JZ   espera_tecla		; se nenhuma tecla premida, repete

        CALL rot_converte_numero   ; retorna R9 com a tecla premida
    
        MOV R9, [tecla]
    	MOV	[tecla_carregada], R9	; informa quem estiver bloqueado neste LOCK que uma tecla foi carregada
    							    ; ( o valor escrito e a tecla carregada)
    ;acoes_teclado:
    ;    
    ;    MOV  R4, [estado_jogo]  ; guarda o estado do jogo
    ;  
    ;    MOV R6, TECLA_JOGO_PAUSA
    ;    CMP R9, R6                  ; Verifica se carregou na tecla de pausa (D)
    ;    JZ pausa_jogo
    ;    ;MOV R6, TECLA_JOGO_COMECA
    ;    ;CMP R9, R6                  ; Verifica se carregou na tecla de novo jogo (C)
    ;    ;JZ novo_jogo
;
;
;
;
    ;    ;MOV R6, TECLA_JOGO_TERMINA
    ;    ;CMP R9, R6                  ; Verifica se carregou na tecla de sair (E)
    ;    ;JZ sair_jogo
;
    ha_tecla:					; neste ciclo espera-se até NENHUMA tecla estar premida
        
    	YIELD				    ; este ciclo é potencialmente bloqueante, pelo que tem de
    						    ; ter um ponto de fuga (aqui pode comutar para outro processo)
        MOV R9, [tecla]
    	MOV	[tecla_continuo], R9	; informa quem estiver bloqueado neste LOCK que uma tecla está a ser carregada
    							; (o valor escrito é a tecla premida)
        MOVB [R2], R1			; escrever no periférico de saída (linhas)
    							; mantenho mesmo R1 porque esse R1 tem a linha que foi premida em cima
    							; nao preciso de ir a procura outra vez qual linha foi premida
        MOVB R0, [R3]			; ler do periférico de entrada (colunas)
    	AND  R0, R5				; elimina bits para além dos bits 0-3
        CMP  R0, 0				; há tecla premida?
        JNZ  ha_tecla			; se ainda houver uma tecla premida, espera até não haver

    	JMP	espera_tecla		; esta "rotina" nunca retorna porque nunca termina

    						    ; Se se quisesse terminar o processo, era deixar o processo chegar a um RET

PROCESS SP_pause

proc_pause:
    MOV R4, [estado_jogo]  ; guarda o estado do jogo
    MOV R0, [tecla_carregada]
    MOV R1, TECLA_JOGO_PAUSA

    CMP R0, R1
    JZ pausa_jogo
    JMP proc_pause
    pausa_jogo:
        
        CMP R4, PAUSA                           ; se o jogo estiver pausado
        JZ  unpause                             ; volta o jogo

        CMP R4, JOGO                            ; se o jogo não estiver a decorrer nem em pausa
        JNZ proc_pause                            ; nao faz nada

        MOV R4, PAUSA                           ; se o jogo estiver a decorrer 
        MOV [estado_jogo], R4                   ; coloca o jogo em pausa

        ;;;;;;;;;;;;;;;;;;;;;; COLOCAR COMO OVERLAY ;;;;;;;;;;;;;;;;;;;;;;;;

        MOV R7, IMAGEM_PAUSE                       
        MOV [SELECIONA_CENARIO_FRONTAL], R7       ; coloca o ecrã de pausa

        JMP proc_pause

    unpause:
       
       MOV R4, JOGO                            ; retoma o jogo   
       MOV [estado_jogo], R4
               
       MOV [APAGA_CENARIO_FRONTAL], R4         ; volta ao ecrã de jogo 
       MOV [jogo_pausado], R4
       
       JMP proc_pause

    ;novo_jogo:                                  ; começa um novo jogo
    ;                                            ; caso o anterior tenha terminado
    ;    CMP R4, SEM_ENERGIA
    ;    JZ comeca_novo_jogo
    ;    CMP R4, COLISAO
    ;    JZ comeca_novo_jogo
    ;    CMP R4, TERMINADO
    ;    JZ comeca_novo_jogo
    ;    JMP ha_tecla
;
    ;comeca_novo_jogo:
;
    ;    MOV R4, JOGO                        ; coloca o estado do jogo em JOGO
    ;    MOV [estado_jogo], R4
;
    ;    MOV R4, IMAGEM_JOGO                        
    ;    MOV [SELECIONA_CENARIO_FUNDO], R4   ; volta ao ecrã de jogo 
    ;    MOV [APAGA_CENARIO_FRONTAL], R4     
    ;    
    ;    MOV R4, VALOR_INICIAL_DISPLAY_HEX
    ;    MOV [display_HEX], R4              ; guarda o valor inicial do display em hexadecimal
;
    ;    MOV R4, VALOR_INICIAL_DISPLAY            
    ;    MOV [DISPLAYS], R4                  ; inicializa o display com o valor inicial eM decimal
;
;
    ;    MOV R2, DEF_SONDA                   ; guarda a próxima tabela a ser desenhada         
    ;    CALL rot_desenha_sonda              ; desenha a sonda
    ;    MOV R2, DEF_NAVE                    ; Inicializa o registo 2 que vai indicar que boneco desenhar
    ;    CALL rot_desenha_asteroide_e_nave   ; desenha a nave
    ;    MOV R2, DEF_ASTEROIDE_N_MINERAVEL   ; guarda qual a próxima tabela a ser desenhada 
    ;    CALL rot_desenha_asteroide_e_nave   ; desenha o asteroide se ainda não estiver desenhado
;
    ;    MOV [jogo_pausado], R4
    ;    MOV [game_over], R4
;
;
    ;    JMP proc_teclado
    
;    sair_jogo:
;
;       CMP R4, JOGO
;        JZ sai_jogo
;        CMP R4, PAUSA
;        JZ sai_jogo
;        JMP ha_tecla
;    
;    sai_jogo:
;
;       MOV R4, TERMINADO
;        MOV [estado_jogo], R4
;
;       MOV R4, IMAGEM_TERMINADO
;        MOV [SELECIONA_CENARIO_FRONTAL], R4
;
;       JMP ha_tecla



; **********************************************************************
; Rotina
;
; Converte_numero - converte o numero da linha e da coluna da tecla premida
;		            no numero/letra premida
;
;PARAMETROS: R1 - numero da linha premida
;            R0 - numero da coluna
;
;RETORNA: R9 - tecla clicada
; **********************************************************************

rot_converte_numero:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R9
    PUSH R10

    MOV R9, 0   ; inicializar contador da linha a zero
    MOV R10, 0  ; inicializar contador da coluna a zero
    MOV R2, 4   ; Sera no final usado para multiplicar por 4

    ciclo_converte_linha:
        SHR R1, 1       ;vou dividindo por 2 para ver quantos ciclos se completa até chegar a zero
        CMP R1, 0       ; quando chega a zero, converti de numero binario da linha ( 1 a 8)
                        ; para numero entre 0 a 3
        JZ  ciclo_converte_coluna   ; que vou usar na expressao no final para me dar tecla clicada
        ADD R9, 1          ; vou adicionando 1 ao contador
        JMP ciclo_converte_linha    ; volto ao inicio

    ciclo_converte_coluna:
        SHR R0, 1       ; depois de ter numero das linhas faço o mesmo para as colunas
        CMP R0, 0       ; converto de 1 a 8 binario para 0 a 3 decimal
        JZ fim_converte_numero
        ADD R10, 1
        JMP ciclo_converte_coluna

    fim_converte_numero:

        MUL R9, R2      ; Usando a expressao: 
                        ;Tecla = 4 x Num_decimal_linha + num_decimal_col
        ADD R9, R10     ; retorno o R9 

        MOV [tecla], R9


        POP R10
        POP R9
        POP R2
        POP R1
        POP R0
        RET




PROCESS SP_game_over

proc_fim_jogo:
    YIELD

    MOV R4, [estado_jogo]     ; verifica o estado do jogo
    CMP R4, JOGO
    JZ verifica_tecla         ; se o jogo estiver a decorrer ou em pausa
    CMP R4, PAUSA             ; verifica se o utilizador carregou na tecla de sair (E)
    JZ verifica_tecla

    CMP R4, SEM_ENERGIA
    JZ perdeu_sem_energia

    CMP R4, COLISAO
    JZ perdeu_colisao

    CMP R4, TERMINADO
    JZ verifica_recomeca_jogo
    JMP proc_fim_jogo         ; se o jogo não estiver TERMINADO não faz nada

perdeu_sem_energia:

    MOV R4, IMAGEM_SEMENERGIA           ; Caso tehna perdido por falta de energia
    MOV [SELECIONA_CENARIO_FUNDO], R4
    ;;;;;SOM
    JMP verifica_recomeca_jogo

perdeu_colisao:

    MOV R4, IMAGEM_COLISAO              ; Caso tenha perdido por uma colisao com a nave
    MOV [SELECIONA_CENARIO_FUNDO], R4
    ;;;;;SOM
    JMP verifica_recomeca_jogo
    
verifica_tecla:

    MOV R0, TECLA_JOGO_TERMINA
    MOV R4, [tecla]
    CMP R4, R0                  ; Verifica se carregou na tecla de sair (E)
    JZ termina_jogo
    JMP proc_fim_jogo

termina_jogo:                   ;Caso tenha saido do jogo
    
    MOV R4, TERMINADO
    MOV [estado_jogo], R4

    MOV R4, IMAGEM_TERMINADO
    MOV [SELECIONA_CENARIO_FRONTAL], R4
    JMP verifica_recomeca_jogo

verifica_recomeca_jogo:
    YIELD

    MOV R0, TECLA_JOGO_COMECA
    MOV R4, [tecla]
    CMP R4, R0                  ; Verifica se carregou na tecla de comecar (C)
    JZ recomeca_jogo
    JMP verifica_recomeca_jogo

recomeca_jogo:

    CALL rot_inicia_jogo

    JMP proc_fim_jogo



rot_inicia_jogo:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R4

    MOV R4, JOGO
    MOV [estado_jogo], R4
    
    MOV R4, IMAGEM_JOGO
    MOV [SELECIONA_CENARIO_FUNDO], R4
    MOV [APAGA_CENARIO_FRONTAL], R4

    MOV R4, VALOR_INICIAL_DISPLAY_HEX
    MOV [display_HEX], R4              ; guarda o valor inicial do display em hexadecimal

    MOV R4, VALOR_INICIAL_DISPLAY            
    MOV [DISPLAYS], R4                  ; inicializa o display com o valor inicial eM decimal


    MOV R2, DEF_SONDA                   ; guarda a próxima tabela a ser desenhada         
    CALL rot_desenha_sonda              ; desenha a sonda
    MOV R2, DEF_NAVE                    ; Inicializa o registo 2 que vai indicar que boneco desenhar
    CALL rot_desenha_asteroide_e_nave   ; desenha a nave
    MOV R2, DEF_ASTEROIDE_N_MINERAVEL   ; guarda qual a próxima tabela a ser desenhada 
    CALL rot_desenha_asteroide_e_nave   ; desenha o asteroide se ainda não estiver desenhado

    MOV [jogo_pausado], R4
    MOV [game_over], R4

    POP R4
    POP R3
    POP R2
    POP R1
    POP R0
    RET

; ************************************************************************************
; Rotina
; desenha asteroide ou nave, dependendo do valor de R2
;
; PARÂMETROS:  R2 - tipo da tabela (nave, asteroide não minerável, asteroide 
;              minerável ou explosão de asteroide), a sonda é tratada noutra rotina
;              R5 - linha do primeiro píxel do asteroide
;              R6 - coluna do primeiro píxel do asteroide
;
; RETORNA: R5 e R6 no caso de se desenhar um asteroide - linha e coluna respetivamente
; ************************************************************************************

rot_desenha_asteroide_e_nave: ; Deposita os valores dos registos abaixo no stack

    PUSH R0
    PUSH R1 
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R7
    PUSH R8
    PUSH R9
    PUSH R10
    PUSH R11
    
; as seis intruções seguintes servem para verificar o valor de R10 de acordo com o explicado na descrição 
    CMP R10, 1          
    JZ desenha_asteroide_e_nave
    
    CMP R10, 3
    JZ desenha_asteroide_e_nave
    
    CMP R10, -1
    JZ desenha_asteroide_e_nave

; Os blocos acima tratam os casos em que já existe um asteroide
    MOV R8, DEF_NAVE                    ; guarda o valor da memória na primeira posição da tabela que define a nave 
    CMP R2, R8                          ; verifica se foi pedido para desenhar uma nave
    JNZ posicao_inicial_asteroide       ; se não foi pedida a nave então foi um asteroide

    
    posicao_inicial_nave:
        MOV  R7, LINHA_NAVE			    ; linha da nave
        MOV  R4, COLUNA_NAVE	        ; coluna da nave
        

        JMP desenha_asteroide_e_nave    
    
    posicao_inicial_asteroide:
        
        MOV R7, [linha_asteroide]		; linha do asteroide
        MOV R4, [coluna_asteroide]       ; coluna do asteroide
        ADD R10, 1                      ; Diz ao registo de controlo que já existe 1 asteroide
        

    
    desenha_asteroide_e_nave:   ; desenha o asteroide/nave/sonda(bonecos) a partir da tabela

        MOV	R0, [R2]			; obtém a largura do boneco
        ADD R2, 2               ; endereço da altura do boneco
        MOV R1, [R2]            ; obtém a altura
        ADD	R2, 2			    ; endereço da cor do 1º pixel (2 porque a largura é uma word)

        MOV R8, R4              ; guarda o primeiro valor da coluna para depois


    desenha_todos_pixels:
        CMP R1, 0                               ; verifica se a altura é 0, se sim termina
        JZ teste_apagar

        MOV R4, R8                              ; reinicia a coluna para o seu valor inicial
        
    	MOV R3, 0               ; inicializa o R3 (futura cor dos pixels) a 0
		
		CALL rot_desenha_pixels_linha        ; se a altura não for 0 vai desenhar os pixels da primeira linha livre
        
        ADD R7, 1           ; próxima linha
        SUB R1, 1           ; menos uma linha para tratar

        JMP desenha_todos_pixels        ; continua até percorrer toda a tabela 

    teste_apagar:                       
        CMP R10, -1                         ; se esta rotina foi usada para apagar (R10 = -1) 
        JNZ fim_desenha_asteroide_e_nave
        MOV R10, 3                          ; Põe R10 a 3 de modo a poder desenhar o próximo asteroide

    fim_desenha_asteroide_e_nave: ; volta a atribuir os valores acumulados no stack aos devidos registos
        POP R11
        POP R10
        POP R9
        POP R8
        POP R7
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET


; ************************************************************************************
; Rotina
; preenche os pixeis de uma linha, ou com a cor presente em cada pixel da tabela
; do objeto, se R10 for diferente de -1 ou com cor 0, ou seja, apaga os pixels
;
; PARÂMETROS:  R2 - tipo da tabela (nave, asteroide não minerável, asteroide 
;              minerável ou explosão de asteroide), a sonda é tratada noutra rotina
;              R7 - linha do objeto
;              R4 - coluna do objeto
;
; ************************************************************************************

rot_desenha_pixels_linha:       		; desenha os pixels do asteroide/nave a partir da tabela
    
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R10


    MOV R1, DEF_SONDA       ; guarda o valor incial da tabela da sonda para se poder comparar com o do input(R2)
    MOV R5, tabela_cores    ; guarda o enderço da tabela de cores

    CMP R10, 4              ; verifica se o input foi a tabela de cores 
    JNZ preenche_pixel      ; se não, salta
    MOV R6, 8               ; guarda o número 8 por ser demasiado grande para adicionar diretamente
    ;MOV R10, 0              ; se for tabela de cores é para desenhar por isso R10 não pode ser -1
    ADD R5, R6              ; Guarda em R5 o endereço da última cor da tabela 

    preenche_pixel:

        CMP R10, -1             ; verifica se é suposto apagar o desenho
        JZ pinta_pixels         ; se for para apagar não lê a cor do pixel, pois esta será 0
        
        CMP R2, R5              ; verifica se já chegou á última cor
        JLE continua_preenche
        SUB R2, R6              ; se chegou à última cor reeinicia para o primeiro endereço da tabela (-10)
        SUB R2, 2

    continua_preenche:
        MOV	R3, [R2]			; obtém a cor do próximo pixel do asteroide/nave
        
    pinta_pixels:
        MOV  [DEFINE_LINHA], R7	; seleciona a linha
        MOV  [DEFINE_COLUNA], R4	; seleciona a coluna
        MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
        
        CMP R2, R1      ; Se for para desenhar uma sonda, apenas preenche o único pixel que tem e sai do loop
        JZ fim_desenha_pixels

        ADD	R2, 2			    ; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
        ADD R4, 1               ; próxima coluna
        SUB R0, 1			    ; menos uma coluna para tratar (diminui a Largura restante)
        JNZ preenche_pixel      ; continua até percorrer toda a largura do objeto

    fim_desenha_pixels:
        
        POP R10
        POP R6
        POP R5
        POP R4
        POP R3
        POP R1
        POP R0
        RET

; **********************************************************************
; Rotina
; Serve para desenhar ou apagar a sonda dependendo do valor de R10
;
; PARÂMETROS: R2 - enderço inicial da tabela da sonda 
;             R7 - sua linha no momento
; 
; RETORNA: R10 - Registo para controlar o próximo desenho, se R10 veio a -1 (para apagar)
;               irá devolver R10 com 3, o que indica ao processador que a próxima chamada
;               desta rotina será para desenhar
; **********************************************************************
rot_desenha_sonda:
    PUSH R1
    PUSH R2
    PUSH R4
    PUSH R7

    ; as seis intruções seguintes servem para verificar se existe alguma sonda ou se
    ; é para apagar,de acordo com o explicado na descrição de R10

    CMP R10, 3
    JZ coluna_constante

    CMP R10, 2
    JZ coluna_constante

    CMP R10, -1
    JZ coluna_constante

    posicao_sonda:

        MOV  R7, [linha_sonda]			; linha da nave

        ADD R10, 2						; Diz à variável de controlo que após esta já rotina haverá uma sonda desenhada
    
    coluna_constante:
        MOV  R4, COLUNA_SONDA			; coluna da nave
         
    desenha_pixels_sonda:
    	MOV R3, 0						; inicializa o R3 (futura cor dos pixels) a 0
        CALL rot_desenha_pixels_linha	; pinta a sonda de rosa, como definido na sua tabela
    
    teste_apaga:
        CMP R10, -1						; verifica se esta rotina foi usada para apagar, se sim, põe o valor de R1 a 3 para poder desenhar de novo
        JNZ fim_desenho_sonda
        MOV R10, 3						; Põe R10 a 3 de modo a poder desenhar a próxima sonda

    fim_desenho_sonda:  
    POP R7                   
    POP R4
    POP R2
    POP R1
    RET

; **********************************************************************
; Processo
;
; display - Processo que aumenta ou diminui a energia da nave e a transmite para o display
;           em numeracao decimal
;           A energia comeca a 100% e diminui 3% a cada 3 segundos, 5% por cada sonda disparada
;           e aumenta 25% por cada asteroide mineravel destruido
;           Se chegar a 0% o jogo termina
;		
;           R1 - Valor atual do display em hexadecimal     
; **********************************************************************

PROCESS SP_display

proc_display:
    MOV R1, VALOR_INICIAL_DISPLAY_HEX      ; Valor inicial do display em hexadecimal (64H)
    MOV R3, VALOR_INICIAL_DISPLAY
    atualiza_energia:
        MOV R0, [energia_display]              ; Verifica o valor do LOCK energia_display para saber como atualizar a energia
        
        
        MOV R2, [estado_jogo]                  ; Verifica o estado do jogo
        CMP R2, PAUSA                          ; Se estiver em pausa não atualiza a energia
        JZ pausa_energia

        MOV R1, [display_HEX]
        MOV R3, VALOR_INICIAL_DISPLAY_HEX
        CMP R4, R3                             ; Verifica se o valor do display é O inicial
        JNZ acoes_display

    reinicia_display:
        MOV R1, VALOR_INICIAL_DISPLAY_HEX             ; Se for, atualiza o valor do display para o valor inicial

    acoes_display:
        CMP R2, SEM_ENERGIA                    ; Se estiver sem energia não atualiza a energia
        JZ sem_energia
        CMP R2, TERMINADO                      ; Se o jogo tiver terminado não atualiza a energia
        JZ fim_jogo
        CMP R2, COLISAO
        JZ fim_jogo

        CMP R0, DISPLAY_AUMENTA_ENERGIA        ; 1 - asteroide mineravel destruido, aumenta energia
        JZ aumenta_energia
        CMP R0, DISPLAY_ENERGIA_SONDA          ; 2 - sonda disparada, diminui energia (5%)
        JZ diminui_energia_sonda

    diminui_energia_int:                       ; 3 - rotina de interrupcao, diminui energia (3%)
        
        SUB R1, DIMINUI_ENERGIA_INT
        CMP R1, MIN_VALOR_DISPLAY              ; Verifica se a energia chegou a 0 apos a diminuicao
        JLE sem_energia
        JMP atualiza_display                   ; Se nao chegou, atualiza o valor no display

    diminui_energia_sonda:
        SUB R1, DIMINUI_ENERGIA_SONDA
        CMP R1, MIN_VALOR_DISPLAY              ; Verifica se a energia chegou a 0 apos a diminuicao
        JLE sem_energia
        JMP atualiza_display                   ; Se nao chegou, atualiza o valor no display

    aumenta_energia:
        MOV R2, AUMENTA_ENERGIA
        ADD R1, R2
        JMP atualiza_display                 

    sem_energia:

        MOV R0, SEM_ENERGIA                    ; Altera o estado do jogo para SEM_ENERGIA, terminando-o
        MOV [estado_jogo], R0
        MOV R0, 0
        MOV [DISPLAYS], R0                     ; Display fica a 0 (sem energia)
        MOV R0, [game_over]
        JMP proc_display

    atualiza_display:
        MOV [display_HEX], R1
        CALL rot_converte_Hex_Decimal          ; Converte o valor no R1 (hexadecimal) para decimal (R5)
        MOV [DISPLAYS], R5                     ; Atualiza o valor no display com o valor decimal (R5)
        JMP atualiza_energia

    pausa_energia:
        MOV R9, [jogo_pausado]                 ; Bloqueia o processo enquanto o jogo estiver em pausa
        JMP atualiza_energia

    fim_jogo:
        MOV R9, [game_over]                    ; Bloqueia o processo enquanto o jogo estiver terminado
        JMP proc_display

; **********************************************************************
; ROTINA
;
; converte_Hex_Decimal - Converte um numero hexadecimal para decimal,
;						de forma a que cada nibble do display mostre um digito
;
; Parametros: R1 - numero em hexadecimal
;
; Variaveis:
;      		  R2 - temporario
;			  R3 - fator 
;			  R4 - digito
;		      R5 - resultado 
;
; Retorna R5 - valor decimal (cada nibble com um digito)
; **********************************************************************

rot_converte_Hex_Decimal:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
    PUSH R6

	MOV R4, 0
	MOV R5, 0H
	MOV R3, FATOR		; o fator começa em 1000
    ciclo_converte_hex:
        MOD R1, R3 			; numero = numero MOD Fator
        MOV R6, 10				
        DIV R3, R6			; fator = fator DIV 10

        MOV R2, R1			  
        DIV R2, R3			; digito = numero DIV fator
        MOV R4, R2

        SHL R5, 4			; resultado = resultado SHL 4 (proximo nibble)
                            ; desloca para cada nibble ter um digito
        OR R5,R4			; resultado = resultado OR digito
                            ; adiciona novo digito ao nible com menos peso

        MOV R2,R3			
        SUB R2, 1			; Ver se fator é igual a 1
        JNZ ciclo_converte_hex

        POP R6
        POP R4 
        POP R3
        POP R2 
        POP R1
        RET 

; **********************************************************************
; Rotina 
; - indica qual a próxima posição de um determinado objeto
;  
; - PARÂMETROS:    R5, R6 (linha e coluna do asteroide)
;                  R7 (linha da sonda)
; 
; - RETORNA: Os registos de posição atualizados (R5 e R6 ou R7 dependendo do tipo do objeto)
; **********************************************************************


rot_atualiza_posicao:
    PUSH R0
    PUSH R5
    PUSH R6
    PUSH R7

    
    MOV R0, DEF_SONDA           
    MOV R5, [linha_asteroide]
    MOV R6, [coluna_asteroide]
    MOV R7, [linha_sonda]
    CMP R2, R0                          ; verifica se o objeto é uma sonda
    JNZ proxima_posicao_asteroide       ; salta se não for sonda (será asteroide)

    proxima_posicao_sonda:
        SUB R7, 1                       ; decrementa a linha, ou seja sobe no ecrã verticalmente
        JMP fim_atualiza_posicao

    proxima_posicao_asteroide:          ; incrementa a linha e coluna do asteroide (desde a inicial) de modo a andar na diagonal
        ADD R5, 1
        ADD R6, 1
        JMP fim_atualiza_posicao

    
    fim_atualiza_posicao:
        POP R7
        POP R6
        POP R5
        POP R0
        RET

; **********************************************************************
; Processo
;
; painel_nave - Processo que lê o relógio da nave e muda o lock int_painel_nave
;               para que seja possível mudar as cores do painel da nave
;		
;       R0, R1 - largura do painel e altura do painel, respetivamente
;		R2 - endereço da tabela das cores definida no início 
;       R4, R7 - linha e coluna do painel, respetivamente
; **********************************************************************



PROCESS SP_painel_nave		; indicação de que a rotina que se segue é um processo,
							; com indicação do valor para inicializar o SP
proc_painel_nave:

	MOV R2, tabela_cores		; guarda o endereço da tabela das cores para se poder aceder às cores
;	MOV R3, 8				; guarda o número máximo de bits a adicionar ao endereço da tabela das cores
	
	MOV R0, LARGURA_PAINEL_NAVE		;guarda a largura do painel
	MOV R1, ALTURA_PAINEL_NAVE		;guarda a altura do painel
	
    posicao_painel_nave:
        
        MOV R7, LINHA_PAINEL		; linha do painel
        MOV R4, COLUNA_PAINEL       ; coluna do painel
        MOV R10, 4                  ; irá servir para dizer à rot_desenha_pixels_linha que o input é a tabela de cores

    loop_painel:
        YIELD

        CALL rot_desenha_pixels_linha   ; muda a primeira linha do painel
            ADD R7, 1
        CALL rot_desenha_pixels_linha   ; muda a segunda linha do painel
            SUB R7, 1
    verifica_pausa:                     ; verifica se o jogo está pausado
        MOV R5, [estado_jogo]           ; se estiver, bloqueia o processo
        CMP R5, PAUSA            
        JNE verifica_fim_jogo
        MOV R5, [jogo_pausado]

        JMP loop_painel
    
    verifica_fim_jogo:
        CMP R5, JOGO            ; verifica se o jogo terminou
        JZ loop_painel
        CMP R5, PAUSA
        JZ loop_painel
        MOV R5, [game_over]
    
        JMP loop_painel



; **********************************************************************
; Processo
;
; painel_nave - Processo que lê o relógio da nave e muda o lock int_painel_nave
;               para que seja possível mudar as cores do painel da nave
;		
;       R0, R1 - largura do painel e altura do painel, respetivamente
;		R2 - endereço da tabela das cores definida no início 
;       R4, R7 - linha e coluna do painel, respetivamente
; **********************************************************************
PROCESS SP_asteroide        ; indicação de que a rotina que se segue é um processo,
							; com indicação do valor para inicializar o SP
    
proc_spawn_asteroide:
    MOV R3, tabela_geral_posicao        ; guarda o enderço da tabela das combinações de posições possíveis
    CALL rot_gera_aleatorio             ; recebe dois números pseudoaleatórios: R0 e R1
    CMP R0, 0                           ; se R0 não for 0 é para fazer um não minerável senão o oposto
    JNZ  asteroide_nao_mineravel
    MOV R2, DEF_ASTEROIDE_MINERAVEL     ; no caso de ser minerável, guarda o endereço da sua tabela
    JMP escolhe_tabela_particular

    asteroide_nao_mineravel:
        MOV R2, DEF_ASTEROIDE_N_MINERAVEL   ; no caso de ser não minerável, guarda o endereço da sua tabela

    escolhe_tabela_particular:
        SHL R1, 1               ; multiplica por dois (anda um bit para a direita pois queremos incrementar de 2 em 2 bytes)
        ADD R3, R1              ; vai adicionar um certo valor par de 0 a 8 a R3 de modo a obter o endereço de uma tabela de direção
        MOV R5, [R3]

    loop_movimento:
        YIELD

        MOV R7, [linha_asteroide]
        MOV R4, [R5]
        ADD R5, 2
        MOV R6, [R5]

                                        ; verifica se o jogo está pausado
        MOV R5, [estado_jogo]           ; se estiver, bloqueia o processo
        CMP R5, PAUSA            
        JNE verifica_fim_jogo
        MOV R5, [jogo_pausado]

        JMP loop_movimento
    

        CMP R5, JOGO            ; verifica se o jogo terminou
        JZ loop_painel
        CMP R5, PAUSA
        JZ loop_painel
        MOV R5, [game_over]
    
        JMP loop_movimento
    ; Falta separar a parte do movimento e a parte do desenho dos 4 asteroides



;; **********************************************************************
;; Rotina 
;; - gera dois números aleatórios, um entre 0 e 3, outro entre 0 e 4
;;  
;; - PARÂMETROS:    
;;              R2 - Máscara de 2 bits
;;              R4 - endereço do periférico PIN

;; 
;; - RETORNA: R0 (número entre 0 e 3) e R1 (número entre 0 e 4)
;; **********************************************************************

rot_gera_aleatorio:
    
    PUSH R2
    PUSH R3
    PUSH R4

    MOV R2, MASCARA_2_BITS   ; será utilizado para isolar os 2 bits de menor peso de um valor
    MOV R3, 5
    MOV R4, PIN
    MOVB R0, [R4]           ; lê os bits 4 a 7 do periférico PIN
    SHR R0, 4                ; coloca os bits lidos antes (4 a 7) nos bits 0 a 3, de modo a ficar com um valor entre 0 e 15
    MOV R1, R0

    AND R0, R2               ; isola os 2 bits de menor peso, o que dá 4 hipóteses
    MOD R1, R3                ; R1 = resto da divisão de R1 por 5 de modo a ficarmos com 5 hipóteses (0 a 4)

fim_gera_aleatório:
    POP R4
    POP R3
    POP R2
    RET






;escolhe_cor_pixel:
;	MOV R4, tabela_cores	; guarda o enderço da tabela das cores para se poderem aceder às cores
;	CMP R5, R3				; se R5 for menor que 8, poderá ser adicionado ao endereço da tabela das cores para obter uma cor
;	JLE muda_cor
;	MOV R5, 0
;
;muda_cor:   
;	ADD R4, R5
;	ADD R5, 2
;
;


;rot_int_0:
;	PUSH R2
;	MOV R2, int_asteroide
;	MOV [R2], R1
;	POP R2
;	RFE



;rot_int_1:
;	PUSH R2
;	MOV R2, evento_int_missil
;	MOV [R2], R1
;	POP R2
;	RFE
;
 rot_int_2:                 ; Rotina que trata a interrupção 2
 	PUSH R0                 ; Desbloqueia o processo display para diminuir a energia da nave
 	MOV R0, DISPLAY_ENERGIA_INT
 	MOV [energia_display], R0
 	POP R0
 	RFE
 

rot_int_3:                  ; Rotina que trata a interrupção 3
	PUSH R0                 ; Desbloqueia o processo do painel da nave 
	MOV R0, int_painel_nave
	MOV [R0], R1
	POP R0
	RFE

