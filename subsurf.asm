STACK SEGMENT PARA STACK 
	DB 64 DUP ('MYSTACK ')
STACK ENDS
MYDATA SEGMENT PARA 'DATA'
		ESQPART		DW  20
		MEIOPART	DW  80
		DIRPART		DW  140
		POSITION	DW  1
		initpart	DW  190
		LIMPART		DW	199
		cump		DW  20
		stringVazia DW  0fffh DUP (' '),'$'
MYDATA ENDS

MYCODE SEGMENT PARA 'CODE' 
MYPROC PROC FAR 
	ASSUME CS:MYCODE,DS:MYDATA,SS:STACK 
	PUSH DS 
	SUB AX,AX 
	PUSH AX 
	MOV AX,MYDATA ; coloca em AX a posicao dos DADOS 
	MOV DS,AX ; coloca essa posicao no reg. DS 
		MOV	AH,00h			;Modo de Video
		MOV AL,0Dh			;Grafico 320x200
		INT 10h				;Interrupção 10H(Video)

		MOV AH,11			;Palete de cores
		MOV BH,00			;FOREGROUND
		MOV BL,00			;COR DE FUNDO
		INT 10h				;serviços de video e ecrã
		
		MOV AH,11			;Palete de cores
		MOV BH,01			;Palete de cores
		MOV BL,00			;Cores Primárias
		INT 10h				;serviços de video e ecrã
		
		
		CALL INITMOUSE		;INICIAR O RATO
		
		MOV AL,15			;COR DAS FRONTEIRAS DO TABULEIRO DO JOGO
		CALL TABGAME
		MOV AL,09			;https://en.wikipedia.org/wiki/Enhanced_Graphics_Adapter
		CALL MPART			;INSERSÃO DA PEÇA DO MEIO
		
		CALL MOVIM			;PROCEDIMENTO DA MOVIMENTAÇÃO DO BONECO
		
		MOV AH,00h			;SET MODE VIDEO
		MOV AL,02h			;80x25 TEXT
		INT 10h				;Interrupção 10H(Video)
	RET 
MYPROC ENDP
;--------------------------------------------------------------------------
;Procedimento para iniciar o rato
;--------------------------------------------------------------------------
INITMOUSE PROC NEAR
		MOV AX,1				;Mostra o cursor
		INT 33H	
		
		MOV AX,04
		MOV CX,180
		MOV DX,100
		INT 33h
								;
		MOV AX,7				;Limite de movimento Horizontal
		MOV CX,0				;LIMITE MINIMO
		MOV DX,359				;LIMITE MAXIMO
		INT 33H

		MOV AX,8				;Limite de movimento Verical
		MOV CX,0				;LIMITE MINIMO
		MOV DX,199				;LIMITE MAXIMO
		INT 33H
RET
INITMOUSE ENDP
;--------------------------------------------------------------------------------------
;---Boneco do meio
;--------------------------------------------------------------------------------------
MPART PROC NEAR
		MOV DX,initpart;VALOR TOPO DA PEÇA
NLINE1:
		MOV BX,CUMP;VAI BUSCAR O CUMPRIMENTO POR PARAMETRO
		INC DX;VALOR TOPO DA PEÇA PASSA um PIXEL PARA BAIXO
		MOV CX,MEIOPART;VAI BUSCAR A MEDIDA DO MEIO
		CALL rhoriz		;RISCA HORIZONTALMENTE
		PUSH AX			;GUARDA AX NA PILHA
		MOV AX,LIMPART	;VERIFICA SE O VALOR JÁ CHEGOU AO FIM
		CMP DX,AX
		POP AX
		JNE NLINE1		;SE NÃO REPETE
	RET
MPART ENDP
;--------------------------------------------------------------------------------------
;---Boneco do lado Esquerdo
;--------------------------------------------------------------------------------------
EPART PROC NEAR
		MOV DX,initpart
NLINE2:
		MOV BX,CUMP
		INC DX
		MOV CX,ESQPART
		CALL rhoriz
		PUSH AX
		MOV AX,LIMPART
		CMP DX,AX
		POP AX
		JNE NLINE2
	RET
EPART ENDP
;--------------------------------------------------------------------------------------
;---Boneco do lado Direito
;--------------------------------------------------------------------------------------
DPART PROC NEAR
		MOV DX,initpart
NLINE3:
		MOV BX,CUMP
		INC DX
		MOV CX,DIRPART
		CALL rhoriz
		PUSH AX
		MOV AX,LIMPART
		CMP DX,AX
		POP AX
		JNE NLINE3
	RET
DPART ENDP
MOVIM PROC NEAR
VOLTA:
		MOV AL,15		;BRANCO
		CALL TABGAME	;REPINTA O TABULEIRO
		XOR BX,BX
		XOR CX,CX		
		MOV AX,3		;ESTADO DO RATO
		INT 33H			;Interrupção DO RATO
		AND BX,07		;METE OS DIGITOS MAIS SIGNIFICATIVOS A 0 (001 010 100) 7(111)
		CMP BX,2		;Verifica o BOTÃO DIREITO
		JE finish		;CASO ELE SEJA PREMIDO SAI DO PROCEDIMENTO
		;AND BX,07
		;CMP BX,1
		;JNE VOLTA
		CMP CX,120		;SE RATO ESTIVER NA ENTRE OS 0 e 60 PIXEIS
		JBE esq			;MOVE PARA A ESQUERDA
		CMP CX,240		;SE RATO ESTIVER NA ENTRE OS 61 e 120 PIXEIS
		JBE meio		;MOVE PARA O MEIO
		CMP CX,320		;SE RATO ESTIVER NA ENTRE OS 121 e 180 PIXEIS
		JBE dir			;MOVE PARA A DIREITA
		;SE AS CONDIÇÕES NÂO FOREM SATISFEITAS O TECLADO ASSUME AS FUNÇõES DOS MOVIMENTOS
		mov AH,01 			;VERIFICA O ESTADO DO TECLADO
		int 16h				;envoca interrupção da bios para o teclado
		jz volta			;SE FOR 0 É PORQUE NÃO FOI UTILIZADO E VOLTA A PERGUNTAR
		
		mov AH,00H			;LE O VALOR DO TECLADO
							;@param AL caracter	
		int 16H				;envoca interrupção da bios para o teclado
		CALL LIMPACARECRA	;retira do ecrã o caracter premido
		CMP AL,'j'			;Compara o caracter com a letra 'j'
		JE movEsq				;salta para o movimento que faz mexer o quadrado para a esquerda
		;CMP AL,'k'			;Compara o caracter com a letra 's'
		;JE baixo			;salta para o movimento que faz mexer o quadrado para a baixo
		CMP AL,'l'			;Compara o caracter com a letra 'l'
		JE movDir				;salta para o movimento que faz mexer o quadrado para a direita
		;CMP AL,'i'			;Compara o caracter com a letra 'd'
		;JE cima	
		CMP AL,1BH			;Compara o caracter com a TECLA 'ESQ'
		JE finish	
		JMP VOLTA			;Salta para o fim do programa
movEsq:
		MOV AX,POSITION
		CMP AX,0			;Verifica se já está na esquerda
		JE esq				;Se SIM salta para o procedimento de mudar para a esquerda
		CMP AX,1			;Verifica se já está na esquerda
		JE esq				;Se SIM salta para o procedimento de mudar para a esquerda
		JNE meio			;CASO CONTRARIO salta para o procedimento de mudar para o meio
movDir:
		MOV AX,POSITION
		CMP AX,2			;Verifica se já está na direita
		JE dir				;Se SIM salta para o procedimento de mudar para a direita
		CMP AX,1			;Verifica se já está no meio
		JE dir				;Se SIM salta para o procedimento de mudar para a direita
		JNE meio			;CASO CONTRARIO salta para o procedimento de mudar para o meio
meio:
		CALL MIDLE
		JMP VOLTA			;vai pedir novo movimento
esq: 
		CALL LEFT
		JMP VOLTA			;vai pedir novo movimento
dir:
		CALL RIGHT
		JMP VOLTA			;vai pedir novo movimento
cima:
		jmp VOLTA			;Caso nenhuma das condições não seja satisfeita repete
baixo:
		JMP VOLTA			;Caso nenhuma das condições não seja satisfeita repete
finish:
		ret	
MOVIM ENDP
LEFT PROC NEAR
		MOV POSITION,0
		MOV AL,00			;COR DO BACKGROUND
		CALL DPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
		MOV AL,00			;COR DO BACKGROUND
		CALL MPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
		MOV AL,09			;COR 02
		CALL EPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
LEFT ENDP
MIDLE PROC NEAR
		MOV POSITION,1
		MOV AL,00			;COR DO BACKGROUND
		CALL EPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
		MOV AL,00			;COR DO BACKGROUND
		CALL DPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
		MOV AL,09			;COR DO BACKGROUND
		CALL MPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
MIDLE ENDP
RIGHT PROC NEAR
		MOV POSITION,2
		MOV AL,00			;COR DO BACKGROUND
		CALL EPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
		MOV AL,00			;COR DO BACKGROUND
		CALL MPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
		MOV AL,09			;COR 02
		CALL DPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
RIGHT ENDP
;--------------------------------------------------------------------------
;posiciona as uma string vazia para ocultar os caracteres escritos no ecrã ao movimentar as teclas
;--------------------------------------------------------------------------
LIMPACARECRA PROC NEAR
		PUSH AX
		PUSH BX
		PUSH DX
		MOV AH,02h			;Define a posição do ecrã
		MOV BH,0			;Página 0
		INT 10h				;Interrupção 10H(Video)
		MOV AH,09			;Define que irá escrever uma string
		LEA DX,stringVazia	;insere uma string vazia no lugar do tempo anterior para limpar
		INT 21h				;Interrupção 10H(DOS)
		MOV AH,02h			;define o código de interrupção
		MOV BH,0			;Página 0
		INT 10h				;Interrupção 10H(Video)
		POP DX
		POP BX
		POP AX
	RET
LIMPACARECRA ENDP
;--------------------------------------------------------------------------
;Desenha Reta Vertical
; @PARAM AL
; @PARAM BX
; @PARAM CX
; @PARAM DX
;--------------------------------------------------------------------------
rVertic proc near
inicio:
	cmp bx,00h				;compara se o bx chegou ao valor mínimo
	je sai					;se sim sai
	MOV AH,12				;Escreve o pixel no ecrã
	INT 10h					;Interrupção 10h(Video)
	Inc dx					;passa para o proximo pixel Verical
	dec bx					;decrementa o valor da representação o tamanho do comprimento da reta
	jmp inicio				;Volta a verificar
sai:
	ret						;Termina o procedimento
rVertic endp 
;--------------------------------------------------------------------------
;Desenha Reta Horizontal
; @PARAM AL
; @PARAM BX
; @PARAM CX
; @PARAM DX
;--------------------------------------------------------------------------
rhoriz proc near
inicio2:
	cmp bx,00h				;compara se o bx chegou ao valor mínimo
	je sai2					;se sim sai
	MOV AH,12				;Escreve o pixel no ecrã
	INT 10h					;Interrupção 10h(Video)
	Inc cx					;passa para o proximo pixel Horizontal
	dec bx					;decrementa o valor da representação o tamanho do comprimento da reta
	jmp inicio2				;Volta a verificar
sai2:	
	ret						;Termina o procedimento
rhoriz endp 
;--------------------------------------------------------------------------------------------------
;------TABULEIRO DO JOGO---------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------
TABGAME PROC NEAR
		
		mov dx,00			;Vertical
		mov cx,00			;Horizontal
		mov bx,180			;cumprimento
		call rhoriz
		
		mov dx,00			;Vertical
		mov cx,00			;Horizontal
		mov bx,200			;cumprimento
		call rVertic

		mov dx,200			;Vertical
		mov cx,0h			;Horizontal
		mov bx,180			;cumprimento
		call rhoriz

		mov dx,0			;Vertical
		mov cx,180			;Horizontal
		mov bx,200			;cumprimento
		call rVertic
		
	RET
TABGAME ENDP
MYCODE ENDS 
END
;--------------------------------------------------------------------------
; INT 10H 00H(0)
; AH 	-> Determina a Interrupção Define o modo de video
; AL 	-> Modo de Video
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; INT 10H 02H(2)
; AH 	-> Determina a Interrupção Definir a posição do ecrã
; BH 	-> Mostra o número da página 
; DH 	-> Posição Linha da Página
; DL 	-> Posição Coluna da Página
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; INT 10H 0BH(11)
; AH 	-> Determina a Interrupção Define Painel de Cores
; BH 	-> (0 = Background 320x200,BorderColor text,Foreground 640x200 / 1 = Palette)
; BL 	-> Define a palete de cores (BH a 0 = Background 640x200 / BH a 1 = RGB 0 -> 0 Actual, 1 RED, 2 GREEN, 3 BROW, Cores Primárias 1 -> 0 Actual, 1 CYAN ,2 MAGENTA,3 WHITE )
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; INT 10H 0CH(12)
; AH 	-> Determina a Interrupção Escrever um Pixel
; AL 	-> Define a Cor do Pixel
; BH 	-> Mostra o número da página (Caso o modo Grafico o permita)
; CX 	-> Posição Horizontal do Pixel
; DX 	-> Posição Vertical do Pixel
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; INT 21H 02H(2)
; AH	-> Determina a Interrupção Mostra caracter
; DL	-> Variavel que contém o caracter a mostrar
;--------------------------------------------------------------------------
;--------------------------------------------------------------------------
; INT 21H 09H(9)
; AH	-> Determina a Interrupção Mostra String
; DS:DX	-> Variavel que contém a String
;--------------------------------------------------------------------------