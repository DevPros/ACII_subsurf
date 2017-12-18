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
		initpartC	DW  180
		LIMPARTC	DW	189
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
		CALL LIMPAAREA
		MOV AL,09			;https://en.wikipedia.org/wiki/Enhanced_Graphics_Adapter
		CALL MPART			;INSERSÃO DA PEÇA DO MEIO
		
		CALL MOVIM			;PROCEDIMENTO DA MOVIMENTAÇÃO DO BONECO
		
		MOV AH,00h			;SET MODE VIDEO
		MOV AL,02h			;80x25 TEXT
		INT 10h				;Interrupção 10H(Video)
	RET 
MYPROC ENDP
LIMPAAREA PROC NEAR
		MOV AL,0
		MOV DX,180;VALOR TOPO DA PEÇA
NLINE34:
		MOV BX,140;VAI BUSCAR O CUMPRIMENTO POR PARAMETRO
		INC DX;VALOR TOPO DA PEÇA PASSA um PIXEL PARA BAIXO
		MOV CX,20;VAI BUSCAR A MEDIDA DO MEIO
		CALL rhoriz		;RISCA HORIZONTALMENTE
		CMP DX,199
		JNE NLINE34		;SE NÃO REPETE
	RET
LIMPAAREA ENDP
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
		MOV DX,639				;LIMITE MAXIMO
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
		PUSH DX
		PUSH AX
		MOV AX,3		;ESTADO DO RATO
		INT 33H			;Interrupção DO RATO	
		CMP CX,359
		JAE TRES2
		CMP DX,100
		JBE UM
TRES2:	
		CALL MEBAIXO
		JBE FINA
UM:
		CALL MECIMA
FINA:
		POP AX
		POP DX
	RET
MPART ENDP
;--------------------------------------------------------------------------------------
;---Boneco do lado Esquerdo
;--------------------------------------------------------------------------------------
EPART PROC NEAR
		PUSH DX
		PUSH AX
		MOV AX,3		;ESTADO DO RATO
		INT 33H			;Interrupção DO RATO
		CMP CX,359
		JAE TRES1
		CMP DX,100
		JBE UM1
TRES1:
		CALL ESBAIXO
		JMP FINA1
UM1:
		CALL ESCIMA
FINA1:
		POP AX
		POP DX
	RET
EPART ENDP
;--------------------------------------------------------------------------------------
;---Boneco do lado Direito
;--------------------------------------------------------------------------------------
DPART PROC NEAR
		PUSH DX
		PUSH AX
		MOV AX,3		;ESTADO DO RATO
		INT 33H			;Interrupção DO RATO
		CMP CX,359
		JAE TRES
		CMP DX,100
		JBE UM3
TRES:
		CALL DIBAIXO
		JMP FINA3
UM3:
		CALL DICIMA
FINA3:
		POP AX
		POP DX
	RET
DPART ENDP
ESBAIXO PROC NEAR
		PUSH DX
		PUSH CX
		PUSH BX
		PUSH AX
		MOV DX,initpart;VALOR TOPO DA PEÇA
NLINE2:
		MOV BX,CUMP;VAI BUSCAR O CUMPRIMENTO POR PARAMETRO
		INC DX;VALOR TOPO DA PEÇA PASSA um PIXEL PARA BAIXO
		MOV CX,ESQPART;VAI BUSCAR A MEDIDA DO MEIO
		CALL rhoriz		;RISCA HORIZONTALMENTE
		PUSH AX			;GUARDA AX NA PILHA
		MOV AX,LIMPART	;VERIFICA SE O VALOR JÁ CHEGOU AO FIM
		CMP DX,AX
		POP AX
		JNE NLINE2		;SE NÃO REPETE
		POP AX
		POP BX
		POP CX
		POP DX
	RET
ESBAIXO ENDP
MEBAIXO PROC NEAR
		PUSH DX
		PUSH CX
		PUSH BX
		PUSH AX
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
		POP AX
		POP BX
		POP CX
		POP DX
	RET
MEBAIXO ENDP
DIBAIXO PROC NEAR
		PUSH DX
		PUSH CX
		PUSH BX
		PUSH AX
		MOV DX,initpart;VALOR TOPO DA PEÇA
NLINE3:
		MOV BX,CUMP;VAI BUSCAR O CUMPRIMENTO POR PARAMETRO
		INC DX;VALOR TOPO DA PEÇA PASSA um PIXEL PARA BAIXO
		MOV CX,DIRPART;VAI BUSCAR A MEDIDA DO MEIO
		CALL rhoriz		;RISCA HORIZONTALMENTE
		PUSH AX			;GUARDA AX NA PILHA
		MOV AX,LIMPART	;VERIFICA SE O VALOR JÁ CHEGOU AO FIM
		CMP DX,AX
		POP AX
		JNE NLINE3		;SE NÃO REPETE
		POP AX
		POP BX
		POP CX
		POP DX
	RET
DIBAIXO ENDP
DICIMA PROC NEAR
		PUSH DX
		PUSH CX
		PUSH BX
		PUSH AX
		MOV DX,initpartC;VALOR TOPO DA PEÇA
NLINE32:
		MOV BX,CUMP;VAI BUSCAR O CUMPRIMENTO POR PARAMETRO
		INC DX;VALOR TOPO DA PEÇA PASSA um PIXEL PARA BAIXO
		MOV CX,DIRPART;VAI BUSCAR A MEDIDA DO MEIO
		CALL rhoriz		;RISCA HORIZONTALMENTE
		PUSH AX			;GUARDA AX NA PILHA
		MOV AX,LIMPARTC	;VERIFICA SE O VALOR JÁ CHEGOU AO FIM
		CMP DX,AX
		POP AX
		JNE NLINE32		;SE NÃO REPETE
		POP AX
		POP BX
		POP CX
		POP DX
	RET
DICIMA ENDP
ESCIMA PROC NEAR
		PUSH DX
		PUSH CX
		PUSH BX
		PUSH AX
		MOV DX,initpartC;VALOR TOPO DA PEÇA
NLINE22:
		MOV BX,CUMP;VAI BUSCAR O CUMPRIMENTO POR PARAMETRO
		INC DX;VALOR TOPO DA PEÇA PASSA um PIXEL PARA BAIXO
		MOV CX,ESQPART;VAI BUSCAR A MEDIDA DO MEIO
		CALL rhoriz		;RISCA HORIZONTALMENTE
		PUSH AX			;GUARDA AX NA PILHA
		MOV AX,LIMPARTC	;VERIFICA SE O VALOR JÁ CHEGOU AO FIM
		CMP DX,AX
		POP AX
		JNE NLINE22		;SE NÃO REPETE
		POP AX
		POP BX
		POP CX
		POP DX
	RET
ESCIMA ENDP
MECIMA PROC NEAR
		PUSH DX
		PUSH CX
		PUSH BX
		PUSH AX
		MOV DX,initpartC;VALOR TOPO DA PEÇA
NLINE12:
		MOV BX,CUMP;VAI BUSCAR O CUMPRIMENTO POR PARAMETRO
		INC DX;VALOR TOPO DA PEÇA PASSA um PIXEL PARA BAIXO
		MOV CX,MEIOPART;VAI BUSCAR A MEDIDA DO MEIO
		CALL rhoriz		;RISCA HORIZONTALMENTE
		PUSH AX			;GUARDA AX NA PILHA
		MOV AX,LIMPARTC	;VERIFICA SE O VALOR JÁ CHEGOU AO FIM
		CMP DX,AX
		POP AX
		JNE NLINE12		;SE NÃO REPETE
		POP AX
		POP BX
		POP CX
		POP DX
	RET
MECIMA ENDP
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
		CMP CX,120		;SE RATO ESTIVER NA ENTRE OS 0 e 60 PIXEIS
		JBE esq			;MOVE PARA A ESQUERDA
		CMP CX,240		;SE RATO ESTIVER NA ENTRE OS 61 e 120 PIXEIS
		JBE meio		;MOVE PARA O MEIO
		CMP CX,359		;SE RATO ESTIVER NA ENTRE OS 121 e 180 PIXEIS
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
		CMP AL,'k'			;Compara o caracter com a letra 's'
		JE baixo			;salta para o movimento que faz mexer o quadrado para a baixo
		CMP AL,'l'			;Compara o caracter com a letra 'l'
		JE movDir				;salta para o movimento que faz mexer o quadrado para a direita
		CMP AL,'i'			;Compara o caracter com a letra 'd'
		JE cima	
		CMP AL,1BH			;Compara o caracter com a TECLA 'ESQ'
		JE finish	
		JMP VOLTA			;Salta para o fim do programa
movEsq:
		MOV AX,POSITION
		CMP AX,1			;Verifica se já está na esquerda
		JBE esq				;Se SIM salta para o procedimento de mudar para a esquerda
		JNE meio			;CASO CONTRARIO salta para o procedimento de mudar para o meio
movDir:
		MOV AX,POSITION
		CMP AX,1			;Verifica se já está no meio
		JAE dir				;Se SIM salta para o procedimento de mudar para a direita
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
		call CIMAP
		JMP VOLTA
baixo:
		call BAIXOP
		JMP VOLTA
finish:
		ret	
MOVIM ENDP
CIMAP PROC NEAR
		PUSH AX
		MOV AX,POSITION
		CMP AX,1
		POP AX
		JB ecima
		JE mcima
		JA dcima
		jmp fin			;Caso nenhuma das condições não seja satisfeita repete
ecima:
		MOV AL,09	
		CALL ESCIMA
		JMP fin
mcima:
		MOV AL,09	
		CALL MECIMA
		JMP fin
dcima:
		MOV AL,09	
		CALL DICIMA
fin:
	RET
CIMAP ENDP
BAIXOP PROC NEAR
		PUSH AX
		MOV AX,POSITION
		CMP AX,1
		POP AX
		JB ebaixo
		JE mbaixo
		JA dbaixo
		jmp fin2		;Caso nenhuma das condições não seja satisfeita repete
ebaixo:
		MOV AL,09	
		CALL ESBAIXO
		JMP fin2
mbaixo:
		MOV AL,09	
		CALL MEBAIXO
		JMP fin2
dbaixo:
		MOV AL,09	
		CALL DIBAIXO
fin2:
	RET
BAIXOP ENDP
LEFT PROC NEAR
		MOV POSITION,0
		CALL LIMPAAREA
		MOV AL,09			;COR 02
		CALL EPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
LEFT ENDP
MIDLE PROC NEAR
		MOV POSITION,1
		CALL LIMPAAREA
		MOV AL,09			;COR DO BACKGROUND
		CALL MPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
MIDLE ENDP
RIGHT PROC NEAR
		MOV POSITION,2
		CALL LIMPAAREA
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