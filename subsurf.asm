STACK SEGMENT PARA STACK 
	DB 64 DUP ('MYSTACK ')
STACK ENDS
MYDATA SEGMENT PARA 'DATA'
		ESQPART		DW  20
		MEIOPART	DW  80
		DIRPART		DW  120
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
		MOV BH,01			;Palete de cores
		MOV BL,01			;Cores Primárias
		INT 10h				;serviços de video e ecrã
		
		MOV AH,11			;Palete de cores
		MOV BH,00			;Palete de cores
		MOV BL,01			;Cores Primárias
		INT 10h				;serviços de video e ecrã
		CALL INITMOUSE
		MOV AL,04
		CALL TABGAME
		MOV AL,02
		CALL MPART
		CALL MOVIM
		
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
						;Horizontal
		MOV AX,7				;Limite de movimento
		MOV CX,0	
		MOV DX,639				;Limite de Pixeis
		INT 33H
								;vertical
		MOV AX,8				;Limite de movimento
		MOV CX,0			
		MOV DX,199				;Limite de Pixeis
		INT 33H
RET
INITMOUSE ENDP
MPART PROC NEAR
		MOV DX,initpart
NLINE1:
		MOV BX,CUMP
		INC DX
		MOV CX,MEIOPART
		CALL rhoriz
		PUSH AX
		MOV AX,LIMPART
		CMP DX,AX
		POP AX
		JNE NLINE1
	RET
MPART ENDP
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
		MOV AL,04
		CALL TABGAME
		XOR BX,BX
		XOR CX,CX
		MOV AX,3
		INT 33H
		AND BX,07
		CMP BX,2
		JE finish
		;AND BX,07
		;CMP BX,1
		;JNE VOLTA
		CMP CX,120
		JBE esq
		CMP CX,240
		JBE meio
		CMP CX,320
		JBE dir
		
		mov AH,01 			;ve o estado do teclado 
		int 16h				;envoca interrupção da bios para o teclado
		jz volta
		
		mov AH,00H			; vai ler o valor do teclado
		int 16H				;envoca interrupção da bios para o teclado
		;MOV AH,01			;Escrever no ecrã
							;@param AL caracter		
		;INT 21h				;Interrupção 21H(DOS)
		CALL LIMPACARECRA	;retira do ecrã o caracter premido
		CMP AL,'j'			;Compara o caracter com a letra 'a'
		JE esq				;salta para o movimento que faz mexer o quadrado para a esquerda
		;CMP AL,'k'			;Compara o caracter com a letra 's'
		;JE baixo			;salta para o movimento que faz mexer o quadrado para a baixo
		CMP AL,'l'			;Compara o caracter com a letra 'd'
		JE dir				;salta para o movimento que faz mexer o quadrado para a direita
		;CMP AL,'i'			;Compara o caracter com a letra 'd'
		;JE cima	
		CMP AL,'q'			;Compara o caracter com a letra 'q'
		JE finish	
		JMP VOLTA		;Salta para o fim do programa
meio:
		MOV AL,00
		CALL EPART
		MOV AL,00
		CALL DPART
		MOV AL,02
		CALL MPART
		JMP VOLTA		;vai pedir novo movimento
esq: 
		MOV AL,00
		CALL DPART
		MOV AL,00
		CALL MPART
		MOV AL,02
		CALL EPART
		JMP VOLTA		;vai pedir novo movimento
dir:
		MOV AL,00
		CALL EPART
		MOV AL,00
		CALL MPART
		MOV AL,02
		CALL DPART
		JMP VOLTA		;vai pedir novo movimento
cima:
		jmp VOLTA	
baixo:
		JMP VOLTA		
		;Caso nenhuma das condições não seja satisfeita repete
finish:
		ret	
MOVIM ENDP
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

TABGAME PROC NEAR
		
		mov dx,00		;Vertical
		mov cx,00	;Horizontal
		mov bx,180			;cumprimento
		call rhoriz
		
		mov dx,00		;Vertical
		mov cx,00	;Horizontal
		mov bx,200			;cumprimento
		call rVertic

		mov dx,200	;Vertical
		mov cx,0h	;Horizontal
		mov bx,180			;cumprimento
		call rhoriz

		mov dx,0		;Vertical
		mov cx,180	;Horizontal
		mov bx,200		;cumprimento
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