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




; *********************************************************************************
; * Constantes
; *********************************************************************************
DISPLAYS		    EQU  0A000H	; endereço do periférico que liga aos displays
TEC_LIN				EQU 0C000H	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL				EQU 0E000H	; endereço das colunas do teclado (periférico PIN)
LINHA_TECLADO	    EQU  0010H	; linha a testar 1 bit a esquerda da linha maxima (8b)
MASCARA				EQU 0FH		; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TECLA_ESQUERDA			EQU 1		; tecla na primeira coluna do teclado (tecla C)
TECLA_DIREITA			EQU 2		; tecla na segunda coluna do teclado (tecla D)

COMANDOS				EQU	6000H			; endereço de base dos comandos do MediaCenter

DEFINE_LINHA    		EQU COMANDOS + 0AH		; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU COMANDOS + 0CH		; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU COMANDOS + 12H		; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU COMANDOS + 40H		; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU COMANDOS + 02H		; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU COMANDOS + 42H		; endereço do comando para selecionar uma imagem de fundo
TOCA_SOM				EQU COMANDOS + 5AH		; endereço do comando para tocar um som

; * Constantes - posição
LINHA_ASTEROIDE         EQU  0      ; 1ª linha do asteroide 
COLUNA_ASTEROIDE	    EQU  0      ; 1ª coluna do asteroide 
LINHA_NAVE              EQU  27     ; 1ª linha da nave 
COLUNA_NAVE             EQU  25     ; 1ª coluna da nave 
LINHA_SONDA             EQU 26      ; linha da sonda 
COLUNA_SONDA            EQU 32      ; coluna da sonda 
MIN_COLUNA		        EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		        EQU  63        ; número da coluna mais à direita que o objeto pode ocupar

ATRASO			EQU	5H		; (inicialmente a 400) atraso para limitar a velocidade de movimento do asteroide/nave

; * Dimensões dos bonecos
LARGURA_ASTEROIDE		EQU	5
ALTURA			        EQU	5		; altura do asteroide e da nave
LARGURA_NAVE            EQU 15


; * Constantes - cores
VERMELHO	  EQU 0FF00H ; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
LARANJA       EQU 0FFA0H ; cor do pixel: laranja em ARGB (opaco e vermelho no máximo, verde a 10 e azul a 0)
VERDE         EQU 0F5F2H ; cor do pixel: verde em ARGB (opaco e verde no máximo, vermelho e azul a 0)
AZUL_CIANO    EQU 0F0FFH ; cor do pixel: verde em ARGB (opaco, verde e azul no máximo, vermelho a 0)
CINZENTO      EQU 0F999H ; cor do pixel: verde em ARGB (opaco no máximo, vermelho, verde e azul a 9)
PRETO         EQU 0F000H ; cor do pixel: preto em ARGB (opaco no máximo, vermelho, verde e azul a 0)
ROSA          EQU 0FF3FH ; cor do pixel: rosa em ARGB (opaco e vermelho no máximo, verde e azul a 7)



; * Constantes - teclado/display
VALOR_INICIAL_DISPLAY EQU 0064H   ; valor inicial do display (100 EM DECIMAL)

INCREMENTO_DISPLAY EQU 000BH    ; tecla que incrementa o valor do display
DECREMENTO_DISPLAY EQU 000FH    ; tecla que decremento o valor do display
SONDA_CIMA         EQU 000AH    ; tecla que move a sonda para cima
ASTEROIDE_BAIXO    EQU 0002H    ; tecla que move o asteroide para baixo

JOGO_COMECA        EQU 000CH    ; tecla que começa o jogo
JOGO_PAUSA         EQU 000DH    ; tecla que pausa o jogo
JOGO_TERMINA       EQU 000EH    ; tecla que termina o jogo

MIN_VALOR_DISPLAY  EQU 0000H    ; valor minimo do display
MAX_VALOR_DISPLAY  EQU 03E7H    ; valor maximo do display

; * Constantes - MEDIA CENTER
SOM_DISPARO        EQU 2
SOM_ASTEROIDE      EQU 1

IMAGEM_INICIO      EQU 0
IMAGEM_JOGO        EQU 1
IMAGEM_PAUSE       EQU 2




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
pilha:
	STACK 100H			; espaço reservado para a pilha 
						; (200H bytes, pois são 100H words)
SP_inicial:				; este é o endereço (1200H) com que o SP deve ser 
						; inicializado. O 1.º end. de retorno será 
						; armazenado em 11FEH (1200H-2)
							
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

DEF_NAVE:                               ; tabela que define a nave
  WORD    LARGURA_NAVE
  WORD    ALTURA
  WORD    0, 0, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, VERMELHO, 0, 0
  WORD    0, VERMELHO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, VERMELHO, 0
  WORD    VERMELHO, PRETO, PRETO, PRETO, CINZENTO, LARANJA, AZUL_CIANO, VERMELHO, AZUL_CIANO, VERDE, CINZENTO, PRETO, PRETO, PRETO, VERMELHO
  WORD    VERMELHO, PRETO, PRETO, PRETO, VERDE, CINZENTO, VERMELHO, CINZENTO, LARANJA, CINZENTO, AZUL_CIANO, PRETO, PRETO, PRETO, VERMELHO
  WORD    VERMELHO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, PRETO, VERMELHO

DEF_SONDA:                              ; tabela que define a sonda (apenas um pixel)
  WORD    ROSA

; *********************************************************************************
; * Código
; *********************************************************************************
PLACE   0                     ; o código tem de começar em 0000H
inicio:


    MOV  SP, SP_inicial		; inicializa SP para a palavra a seguir
              ; à última da pilha
                              
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
    MOV	R1, IMAGEM_INICIO			; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    
    MOV R11, VALOR_INICIAL_DISPLAY            
    MOV [DISPLAYS], R11     ; inicializa o display com o valor inicial
    
    

    MOV R8, 0 ; Controla se o estado em que está o jogo (0 - jogo terminado, 1 - jogo a decorrer, 2 - jogo parado)

espera_tecla:   
    CALL rot_teclado			; leitura às teclas
    CMP R1, 0
    JZ espera_tecla


    CALL rot_converte_numero   ; retorna R9 com a tecla premida
	
    CALL rot_acoes_teclado   ;executa as acoes de acordo com a tecla premida


	JMP espera_tecla


; **********************************************************************
; TECLADO - Faz uma leitura às teclas de uma linha do teclado e retorna o valor lido
;
;
; Retorna: 	R0 - valor lido das colunas do teclado (0, 1, 2, 4, ou 8)
;			R1 - Valor das linhas	
; **********************************************************************
rot_teclado:
	PUSH	R2
	PUSH	R3
	PUSH	R5

    MOV R1, LINHA_TECLADO   ; por linha a 0001 0000 - para testar qual das linhas foi clicada

    loop_linha:
        SHR R1, 1           ; dividir por 2 para testar as varias linhas do teclado
        CMP R1, 0
        JZ fim_teclado
    
    	MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    	MOV  R3, TEC_COL   ; endereço do periférico das colunas
    	MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    	MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    	MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    	AND  R0, R5        ; elimina bits para além dos bits 0-3
    	CMP	R0, 0
    	JZ loop_linha		; se nenhuma tecla premida, testa linha seguinte

    tecla_premida:
        MOVB [R2], R1      ; escrever no periférico de saída (linhas)
        MOVB R9, [R3]
        AND R9, R5
        CMP R0, R9          ; testar se a coluna e igual
        JZ tecla_premida


    fim_teclado:
    	POP	R5
    	POP	R3
    	POP	R2
    	RET


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
        POP R2
        POP R1
        POP R0
        RET



;; ************************************************************************************
;; Rotina
;; desenha asteroide ou nave, dependendo do valor de R2
;;
;; PARÂMETROS:  R2 - tipo da tabela (nave, asteroide não minerável, asteroide 
;;              minerável ou explosão de asteroide), a sonda é tratada noutra rotina
;;              R5 - linha do primeiro píxel do asteroide
;;              R6 - coluna do primeiro píxel do asteroide

;;
;; RETORNA: R5 e R6 no caso de se desenhar um asteroide - linha e coluna respetivamente
;; ************************************************************************************

rot_desenha_asteroide_e_nave: ; Deposita os valores dos registos abaixo no stack

    PUSH R0
    PUSH R1 
    PUSH R2
    PUSH R3
    PUSH R4
    PUSH R7
    PUSH R8
    
; as seis intruções seguintes servem para verificar o valor de R10 de acordo com o explicado na descrição 
    CMP R10, 1          
    JZ atualiza_posicao
    
    CMP R10, 3
    JZ atualiza_posicao
    
    CMP R10, -1
    JZ atualiza_posicao

; Os blocos acima tratam os casos em que já existe um asteroide
    MOV R8, DEF_NAVE                    ; guarda o valor da memória na primeira posição da tabela que define a nave 
    CMP R2, R8                          ; verifica se foi pedido para desenhar uma nave
    JNZ posicao_inicial_asteroide       ; se não foi pedida a nave então foi um asteroide

    
    posicao_inicial_nave:
        MOV  R7, LINHA_NAVE			    ; linha da nave
        MOV  R4, COLUNA_NAVE	        ; coluna da nave
        

        JMP desenha_asteroide_e_nave    
    
    posicao_inicial_asteroide:
        
        MOV R5, LINHA_ASTEROIDE		; linha do asteroide
        MOV R6, COLUNA_ASTEROIDE       ; coluna do asteroide
        ADD R10, 1                      ; Diz ao registo de controlo que já existe 1 asteroide
        
    atualiza_posicao:
        MOV R7, R5                      ; guarda o valor global da linha do asteroide noutro registo para poder ser manipulado 
        MOV R4, R6                      ; guarda o valor global da coluna do asteroide noutro registo para poder ser manipulado 
    
    desenha_asteroide_e_nave:   ; desenha o asteroide/nave/sonda(bonecos) a partir da tabela

        MOV	R0, [R2]			; obtém a largura do boneco
        ADD R2, 2               ; endereço da altura do boneco
        MOV R1, [R2]            ; obtém a altura
        ADD	R2, 2			    ; endereço da cor do 1º pixel (2 porque a largura é uma word)

        MOV R8, R4              ; guarda o primeiro valor da coluna para depois


    desenha_todos_pixels:
        CMP R1, 0                               ;verifica se a altura é 0, se sim termina
        JZ teste_apagar

        MOV R4, R8                              ;reinicia a coluna para o seu valor inicial
        CALL rot_desenha_pixels_linha        ; se a altura não for 0 vai desenhar os pixels da primeira linha livre
        
        ADD R7, 1           ; próxima linha
        SUB R1, 1           ; menos uma linha para tratar

        JMP desenha_todos_pixels        ; continua até percorrer toda a tabela 

    teste_apagar:                       
        CMP R10, -1                         ; se esta rotina foi usada para apagar (R10 = -1) 
        JNZ fim_desenha_asteroide_e_nave
        MOV R10, 3                          ; Põe R10 a 3 de modo a poder desenhar o próximo asteroide

    fim_desenha_asteroide_e_nave: ; volta a atribuir os valores acumulados no stack aos devidos registos
        
        POP R8
        POP R7
        POP R4
        POP R3
        POP R2
        POP R1
        POP R0
        RET


;; ************************************************************************************
;; Rotina
;; preenche os pixeis de uma linha, ou com a cor presente em cada pixel da tabela
;; do objeto, se R10 for diferente de -1 ou com cor 0, ou seja, apaga os pixels
;;
;; PARÂMETROS:  R2 - tipo da tabela (nave, asteroide não minerável, asteroide 
;;              minerável ou explosão de asteroide), a sonda é tratada noutra rotina
;;              R7 - linha do objeto
;;              R4 - coluna do objeto
;;
;; ************************************************************************************

rot_desenha_pixels_linha:       		; desenha os pixels do asteroide/nave a partir da tabela
    
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R10

    MOV R3, 0               ; inicializa o R3 (futura cor dos pixels) a 0

    MOV R1, DEF_SONDA       ; guarda o valor incial da tabela da sonda para se poder comparar com o do input(R2)
    
    preenche_pixel:

        CMP R10, -1             ; verifica se é suposto apagar o desenho ; verifica se é suposto apagar o desenho
                                ; (pôr o valor dos pixels a 0 ao não mudar o R3, que está a 0)
        JZ pinta_pixels

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
        POP R4
        POP R3
        POP R1
        POP R0
        RET

;; **********************************************************************
;; Rotina
;; Serve para desenhar ou apagar a sonda dependendo do valor de R10
;;
;; PARÂMETROS: R2 - enderço inicial da tabela da sonda 
;;             R7 - sua linha no momento
;; 
;; RETORNA: R10 - Registo para controlar o próximo desenho, se R10 veio a -1 (para apagar)
;;               irá devolver R10 com 3, o que indica ao processador que a próxima chamada
;;               desta rotina será para desenhar
;; **********************************************************************
rot_desenha_sonda:
    PUSH R1
    PUSH R2
    PUSH R4

    ; as seis intruções seguintes servem para verificar se existe alguma sonda ou se
    ; é para apagar,de acordo com o explicado na descrição de R10

    CMP R10, 3
    JZ coluna_constante

    CMP R10, 2
    JZ coluna_constante

    CMP R10, -1
    JZ coluna_constante

    

    posicao_sonda:

        MOV  R7, LINHA_SONDA	    ; linha da nave
        ADD R10, 2                  ; Diz à variável de controlo que após esta já rotina haverá uma sonda desenhada
    
    coluna_constante:
        MOV  R4, COLUNA_SONDA	    ; coluna da nave
         
    desenha_pixels_sonda:
        CALL rot_desenha_pixels_linha ; pinta a sonda de rosa, como definido na sua tabela
    
    teste_apaga:
        CMP R10, -1                         ; verifica se esta rotina foi usada para apagar, se sim, põe o valor de R1 a 3 para poder desenhar de novo
        JNZ fim_desenho_sonda
        MOV R10, 3                          ; Põe R10 a 3 de modo a poder desenhar a próxima sonda

    fim_desenho_sonda:                     
    POP R4
    POP R2
    POP R1
    RET





; **********************************************************************
; Rotina
;
; Executa a acao correspondente a tecla clicada
;
; PARAMETROS: R8 - estado do jogo
;             R9 - tecla clicada
;             R11 - valor apresentado no display (hexadecimal)
; **********************************************************************

rot_acoes_teclado:

    PUSH R0
    PUSH R2
    

    MOV R0, JOGO_COMECA   ; tecla para começar o jogo
    CMP R9, R0
    JZ jogo_comeca       ; procede ao inicio do jogo
    CMP R8, 0
    JZ fim_acoes_teclado ; se o jogo não começou, não faz nada

    MOV R0, JOGO_TERMINA  ; tecla para terminar o jogo
    CMP R9, R0
    JZ jogo_termina       ; procede ao termino do jogo

    MOV R0, JOGO_PAUSA   ; tecla para pausar o jogo
    CMP R9, R0
    JZ jogo_pausa       ; procede à pausa do jogo
    CMP R8, 2
    JZ fim_acoes_teclado ; se o jogo está em pausa, não faz nada

    MOV R0, INCREMENTO_DISPLAY  ; tecla referente ao incremento do display
    CMP R9, R0
    JZ incrementa_display       ; procede ao incremento do valor do display
    

    MOV R0, DECREMENTO_DISPLAY  ; tecla referente ao decremento do display
    CMP R9, R0
    JZ decrementa_display       ; procede ao decremento do valor do display

    MOV R0, SONDA_CIMA          ; tecla referente ao movimento da sonda para cima
    CMP R9, R0

    JZ movimento_sonda_cima     ; procede ao movimento da sonda para cima

    MOV R0, ASTEROIDE_BAIXO     ; tecla referente ao movimento do asteroide para baixo
    CMP R9, R0
    JZ movimento_asteroide_baixo ; procede ao movimento do asteroide para baixo na diagonal

    JMP fim_acoes_teclado ; caso a tecla clicada não tenha nenhum comando atribuido

    incrementa_display:

        MOV R0, MAX_VALOR_DISPLAY   ; valor maximo do display
        CMP R11,  R0           
        JGE fim_acoes_teclado ; se o valor do display for o maximo, não incrementa
        ADD R11, 1                  ; incrementa o valor do display


        MOV [DISPLAYS], R11             ; atualiza o valor do display
        JMP fim_acoes_teclado

    decrementa_display:

        MOV R0, MIN_VALOR_DISPLAY       ; valor minimo do display
        CMP R11, R0             
        JLE fim_acoes_teclado           ; se o valor do display for o minimo, não decrementa
        SUB R11, 1                      ; decrementa o valor do display

        MOV [DISPLAYS], R11             ; atualiza o valor do display
        JMP fim_acoes_teclado

    movimento_sonda_cima:

        MOV R0, SOM_DISPARO
        MOV [TOCA_SOM], R0              ; toca o som do disparo da sonda

        MOV R2, DEF_SONDA               ; guarda a tabela da sonda que vai ser desenhada no ecrã
        MOV R10, -1                     ; Diz á rotina seguinte que vai apagar a sonda existente
        CALL rot_desenha_sonda
        CALL rot_atualiza_posicao    ; incrementa a posição verticalmente para cima (-1 linha pois a maior(31) é em baixo)

        CALL rot_desenha_sonda

        JMP fim_acoes_teclado

    movimento_asteroide_baixo:

        MOV R0, SOM_ASTEROIDE
        MOV [TOCA_SOM], R0          ; toca o som do movimento do asteroide

        MOV R2, DEF_ASTEROIDE_N_MINERAVEL       ; guarda a tabela do asteroide que vai ser desenhado no ecrã
        MOV R10, -1                             ; Diz á rotina seguinte que vai apagar o asteroide existente
        CALL rot_desenha_asteroide_e_nave
        CALL rot_atualiza_posicao            ; incrementa a posição diagonalmente (+1 coluna +1 linha)

        CALL rot_desenha_asteroide_e_nave    ; desenha o asteroide na nova posição


        JMP fim_acoes_teclado   

    jogo_comeca:

        CALL rot_jogo_comeca     ; inicia o jogo
        JMP fim_acoes_teclado

    jogo_pausa:

        CALL rot_jogo_pausado    ;coloca/retira o jogo da pausa

        JMP fim_acoes_teclado

    jogo_termina:

        CALL rot_jogo_termina    ;termina o jogo, limpando o ecrã

        JMP fim_acoes_teclado

    fim_acoes_teclado:

        POP R2
        POP R0
        RET


;**********************************************************************
; Rotina
;
; Inicia o jogo
;
; PARAMETROS: R8 - estado do jogo
;             R11 - valor apresentado no display (hexadecimal)
;**********************************************************************

rot_jogo_comeca:

    CMP R8, 0               
    JGT fim_jogo_comeca                   ; se o jogo foi iniciado nao faz nada  

    MOV R8, IMAGEM_JOGO                  
    MOV [SELECIONA_CENARIO_FUNDO], R8     ; coloca o ecrã de jogo

    MOV R11, VALOR_INICIAL_DISPLAY            
    MOV [DISPLAYS], R11     ; inicializa o display com o valor inicial 

    MOV R8, 1                             ; muda o estado do jogo 

    MOV R10, 0

    MOV R2, DEF_NAVE                     ; Inicializa o registo 2 que vai indicar que boneco desenhar
    CALL rot_desenha_asteroide_e_nave ; desenha a nave

    MOV R2, DEF_ASTEROIDE_N_MINERAVEL    ; guarda qual a próxima tabela a ser desenhada 
    CALL rot_desenha_asteroide_e_nave ; desenha o asteroide se ainda não estiver desenhado

    MOV R2, DEF_SONDA         ; guarda a próxima tabela a ser desenhada         
    CALL rot_desenha_sonda ; desenha a sonda

    fim_jogo_comeca:

        RET



;**********************************************************************
; Rotina
;
; Termina o jogo
;
; PARAMETROS: R8 - estado do jogo
;**********************************************************************

rot_jogo_termina:

    MOV R8, IMAGEM_INICIO                 
    MOV [SELECIONA_CENARIO_FUNDO], R8     ;coloca o ecrã de inicio

    MOV R8, 0                            ;muda o estado do jogo para jogo terminado

    MOV [APAGA_ECRÃ], R8                 ;apaga todos os pixeis desenhados no ecrã
                                ;painel de instrumentos, sondas, asteroides

    RET



;**********************************************************************
; Rotina
;
; Pausa o jogo ou retira o jogo da pausa
;
; PARAMETROS: R8 - estado do jogo
;**********************************************************************

rot_jogo_pausado:

    CMP R8, 1
    JZ pause
    CMP R8, 2
    JZ unpause

    pause:
        MOV R8, IMAGEM_PAUSE                       
        MOV [SELECIONA_CENARIO_FUNDO], R8          ;coloca o ecrã de pausa

        MOV R8, 2                                  ;muda o estado do jogo para em pausa
        JMP fim_jogo_pausado

    unpause:
        MOV R8, IMAGEM_JOGO                        
        MOV [SELECIONA_CENARIO_FUNDO], R8          ;volta ao ecrã de jogo 

        MOV R8, 1                                  ;muda o estado do jogo

    fim_jogo_pausado:
        
        RET


;; **********************************************************************
;; Rotina 
;; - indica qual a próxima posição de um determinado objeto
;;  
;; - PARÂMETROS:    R5, R6 (linha e coluna do asteroide)
;;                  R7 (linha da sonda)
;; 
;; - RETORNA: Os registos de posição atualizados (R5 e R6 ou R7 dependendo do tipo do objeto)
;; **********************************************************************

rot_atualiza_posicao:
    PUSH R0

    
    MOV R0, DEF_SONDA           
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
        POP R0
        RET





