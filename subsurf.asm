STACK SEGMENT PARA STACK 
	DB 64 DUP ('MYSTACK ')
STACK ENDS
MYDATA SEGMENT PARA 'DATA'
		;------------------
		;MEDIDAS RELATIVAS AO BONECO
		;------------------
		ESQPART		DW  20
		MEIOPART	DW  80
		DIRPART		DW  140
		POSITION	DW  1
		initpart	DW  190
		LIMPART		DW	199
		initpartC	DW  180
		LIMPARTC	DW	189
		cump		DW  20
		;------------------
		;POSIÇÕES DO ARRAY DE POSIÇÕES
		;------------------
		POSARRAY1   DW 00H
		POSARRAY2   DW 01H
		POSARRAY3   DW 02H
		POSARRAY4   DW 03H
		;------------------
		;	ARRAY DE POSIÇÕES
		;------------------
		INSERTPOS 	DB 01,01,01,020
					DB 02,00,01,050
					DB 01,01,02,040
					DB 01,01,02,010
					DB 02,01,00,050
					DB 01,02,00,060
					DB 00,00,01,070
					DB 00,01,00,010
					DB 00,00,01,090
					DB 01,01,00,020
					DB 01,01,00,070
					DB 00,01,00,030
					DB 00,00,01,030
					DB 01,01,00,030
					DB 01,01,00,030
					DB 00,01,00,030
		;------------------------------------
		;	MENU DE INFORMAÇÕES
		;------------------------------------
		MSG00		DB      23 dup(' '),201,13 dup(205),187,0AH,0DH
					DB      23 dup(' '),186,' TEMPO:      ',186,0AH,0DH
					DB      23 dup(' '),186,' COINS:      ',186,0AH,0DH
					DB      23 dup(' '),204,13 dup(205),185,0AH,0DH
					DB      23 dup(' '),186,' ESQUERDA: j ',186,0AH,0DH
					DB      23 dup(' '),186,' DIREITA : l ',186,0AH,0DH
					DB      23 dup(' '),186,' CIMA    : i ',186,0AH,0DH
					DB      23 dup(' '),186,' BAIXO   : k ',186,0AH,0DH
					DB      23 dup(' '),186,' PAUSA   : p ',186,0AH,0DH
					DB      23 dup(' '),186,' P.SCREEN: x ',186,0AH,0DH
					DB      23 dup(' '),204,13 dup(205),185,0AH,0DH
					DB      23 dup(' '),186,' Sair:   Esc ',186,0AH,0DH
					DB      23 dup(' '),200,13 dup(205),188,'$'
		;-------------------------------------
		;VARIAVEL RELATIVAS AO VAGAO
		;-------------------------------------
		INITVAG 	DW	01
		FIMVAG		DW	?
		COMVAG		DW  86
		COEVAG		DW  60
		CODVAG		DW  110
		cumpVAG		DW  10
		
		temporizador	DW 	0
		ze				DB '0','$'
		
		TEMP 		DW ?
		;-----------------------------------
		;	FICHEIROS
		;-----------------------------------
		;FICHEIRO lido
		TABLE DB 80 DUP (' '),'$' 
		;BUFFER
		SCREEN DB 64000 DUP (' '),'$' 
		;FILE
		NAMEFLD DB 80 DUP (' '),'$' ; buffer para a pilha 
		FILENAM	DB '.\coord.dat',0
		scres	DB '.\screen.pgm',0
		FHAND	DW ?
		;HEADER DA IMAGEM
		SCREEN_HEAD	DB 'P5',0AH
					DB '# COMENT',0AH
					DB '320 200',0AH
					DB '255',0AH,'$'
		;FILE MSG ERRORS
		BADOPENF DB 'BAD OPENFILE','$'
MYDATA ENDS
MYCODE SEGMENT PARA 'CODE' 
MYPROC PROC FAR 
	ASSUME CS:MYCODE,DS:MYDATA,SS:STACK 
	PUSH DS 
	SUB AX,AX 
	PUSH AX 
	MOV AX,MYDATA ; coloca em AX a posicao dos DADOS 
	MOV DS,AX ; coloca essa posicao no reg. DS 
		CALL STARTVAR;
		;CALL READFILE
		;CALL CONTROLER
		;MOV AH,01
		;Int 21h
		
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
		
		call infor
		MOV AL,15			;COR DAS FRONTEIRAS DO TABULEIRO DO JOGO
		CALL TABGAME
		CALL INITMOUSE		;INICIAR O RATO
		MOV AL,09			;https://en.wikipedia.org/wiki/Enhanced_Graphics_Adapter
		CALL MPART			;INSERSÃO DA PEÇA DO MEIO
		
		CALL MOVIM			;PROCEDIMENTO DA MOVIMENTAÇÃO DO BONECO
		
		MOV AH,00h			;SET MODE VIDEO
		MOV AL,02h			;80x25 TEXT
		INT 10h				;Interrupção 10H(Video)
	RET 
MYPROC ENDP
STARTVAR PROC NEAR
		MOV SI,POSARRAY4
		MOV AL,INSERTPOS[SI]
		CBW
		MOV FIMVAG,AX
	RET
STARTVAR ENDP
;------------------------------
;	FUNÇÃO DE LEITURA DO ARRAY PARA ENVIAR OS VAGOES
;------------------------------
CONTROLER PROC NEAR
		PUSH CX
		PUSH BX
		PUSH DX
		PUSH AX
		PUSH SI
		mov AL,00
		CALL EVAGAO
		mov AL,00
		CALL MVAGAO
		mov AL,00
		CALL DVAGAO
		CALL MOVVAGAO
		MOV SI,POSARRAY1
		CMP INSERTPOS[SI],01
		JE ESQVAG
		JA ESQCOIN
		
FESQ:
		MOV SI,POSARRAY2
		CMP INSERTPOS[SI],01
		JE MEIVAG
		JA MECOIN
FMEI:
		MOV SI,POSARRAY3
		CMP INSERTPOS[SI],01
		JE DIRVAG
		JA DIRCOIN
		JMP fnl
ESQVAG:
		mov AL,09
		CALL EVAGAO
		JMP FESQ
ESQCOIN:
		mov AL,09
		CALL ECOIN
		JMP FESQ
MECOIN:
		CALL MCOIN
		JMP FMEI
MEIVAG:
		mov AL,09
		CALL MVAGAO
		JMP FMEI
DIRVAG:	
		mov AL,09
		CALL DVAGAO
		JMP FNL
DIRCOIN:
		mov AL,09
		CALL DCOIN
FNL:
		POP SI
		POP AX
		POP DX
		POP BX
		POP CX
	RET
CONTROLER ENDP
;------------------------------------------------------
;LEITURA DO ECRÃ
;ESTAVEL
;------------------------------------------------------
READSCREEN PROC NEAR
		PUSH DI
		PUSH DX
		PUSH CX;Guarda o valor na pilha
		LEA DI,SCREEN
		MOV AX,320;resolução Horizontal
		MOV BX,200;resolução VERTICAL
		XOR DX,DX
VERTIC:			
		XOR CX,CX
HORIZ:
		PUSH AX
		PUSH BX
		MOV AH,0DH
		MOV BH,00
		INT 10H
		ADD AL,0FFH
		MOV [DI],AL
		INC DI
		POP AX
		POP BX
		INC CX
		
		CMP CX,AX
		JNE HORIZ
		INC DX

		CMP DX,BX
		JNE VERTIC
		POP CX;tira o valor na pilha
		POP DX
		POP DI
	RET
READSCREEN ENDP
;-----------------------------------------
;SCREENSHOT
;-----------------------------------------
SCREENSHOT PROC NEAR
	MOV AH,3DH
	MOV AL,01
	LEA DX,scres		
	INT 21H
	jc BadOpen1
	mov FHAND, ax ;Save file handle
	mov AH,40h			;ESCRITA
	mov BX,FHAND
	MOV CX,24			;TAMANHO DA HEADER
	LEA DX,SCREEN_HEAD	
	INT 21H				;GRAVA A HEADER NO FICHEIRO
	CALL READSCREEN
	mov AH,40h			;ESCRITA
	mov BX,FHAND
	MOV CX,64000		;TAMANHO DOS PIXEIS
	LEA DX,SCREEN
	INT 21H				;GRAVA OS PIXEIS NO FICHEIRO
	mov bx, FHAND
	mov ah, 3eh ;Close file
	int 21h
	jc CloseError1
CloseError1:
	JMP BADOPEN1
BadOpen1:
	RET
SCREENSHOT ENDP
;------------------------------------------------------
;	LEITURA DO FICHEIRO
;------------------------------------------------------
READFILE PROC NEAR
		PUSH SI
		MOV AH,3DH
		MOV AL,00
		LEA DX,FILENAM
		INT 21H
		jc BadOpen
		mov FHAND, ax ;Save file handle
		LEA SI,TABLE
LP: 
		mov ah,3fh ;Read data from the file
		lea dx, NAMEFLD ;Address of data buffer
		mov cx, 1 ;Read one byte
		mov bx, FHAND ;Get file handle value
		int 21h
		jc ReadError
		cmp ax, cx ;EOF reached?
		jne EOF
		mov al, NAMEFLD ;Get character read
		MOV AH,02
		MOV DL,AL
		INT 21H			;ESCREVE NO ECRÃ
		;MOV [SI],AL	;ESCREVE NO ARRAY
		;INC SI	
		jmp LP ;Read next byte
EOF: 	
		LEA DX,TABLE
		MOV AH,09
		INT 21H
		mov bx, FHAND
		mov ah, 3eh ;Close file
		int 21h
		jc CloseError
CloseError:
		JMP BadOpen
ReadError:
		JMP BadOpen
BadOpen:
		POP SI
	RET
READFILE ENDP
;------------------------------------------------------
;	INCREMENTA OS VALORES DO VAGAO PARA A SENSASÃO DE MOVIMENTO
;------------------------------------------------------
MOVVAGAO proc near
		mov dx,INITVAG		;chama a variavel final
		CMP DX,199
		JAE RESET
VLT:		
		MOV DX,COEVAG
		DEC DX
		DEC DX
		DEC DX
		MOV COEVAG,DX 		;Decresce a posição do vagão 3 pixeis
		MOV DX,CODVAG
		INC DX
		MOV CODVAG,DX		;Cresce a posição do vagão 1 pixeis
		MOV DX,COMVAG
		DEC DX
		MOV COMVAG,DX		;Decresce a posição do vagão 1 pixeis
		MOV DX,cumpVAG
		INC DX
		INC DX
		MOV cumpVAG,DX		;Cresce o cumprimento do vagão 2 pixeis
		mov dx,FIMVAG		;chama a variavel final
		ADD dx,15			;avança 10 pixeis para cima
		mov FIMVAG,dx		;devolve à variavel
		mov dx,INITVAG		;chama a variavel da posicaooriginal
		ADD dx,15			;avança 10 pixeis para cima
		mov INITVAG,dx		;guarda na variavel
		JMP FI
RESET:
	PUSH DX
	;FAZ A NOVA LEITURA DA MATRIZ E REPOE VALORES ONDE OS VAGÕES COMEÇÃO
	MOV DX,POSARRAY1
	ADD DX,04H
	MOV POSARRAY1,DX	;ALTERAR A POSIÇÃO DO 1.º VAGÃO
	MOV DX,POSARRAY2
	ADD DX,04H
	MOV POSARRAY2,DX	;ALTERAR A POSIÇÃO DO 2.º VAGÃO
	MOV DX,POSARRAY3
	ADD DX,04H
	MOV POSARRAY3,DX	;ALTERAR A POSIÇÃO DO 3.º VAGÃO
	MOV DX,POSARRAY4
	ADD DX,04H
	MOV POSARRAY4,DX	;ALTERAR A POSIÇÃO DO CUMPRIMENTO
	MOV SI,POSARRAY4
	MOV DL,INSERTPOS[SI]
	CBW
	MOV INITVAG,01H		;REPOR O VALOR DO VAGÃO DE ORIGEM
	MOV FIMVAG,DX 		;Definir o limite do VAGÃO DE ORIGEM
	MOV COEVAG,60		;REPOR O VALOR DO Inicial esquerdo VAGÃO DE ORIGEM
	MOV CODVAG,110		;REPOR O VALOR DO Inicial MEIO VAGÃO DE ORIGEM
	MOV COMVAG,86		;REPOR O VALOR DO Inicial DIREITO VAGÃO DE ORIGEM
	MOV cumpVAG,10		;REPOR O VALOR DO Cumprimento VAGÃO DE ORIGEM
	POP DX
	JMP VLT
FI:	
	ret
MOVVAGAO endp
;-------------------------------------------------------------
;	CHAMA OS VAGÕES DO MEIO
;-------------------------------------------------------------
MVAGAO proc near
		mov dx,INITVAG		;ve o valor da posição inicial
repetM:
		mov cx,COMVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		call rhoriz			;chama procedimento que avança a linha vertical
		inc dx				;incrementa para a proxima linha
		cmp dx,FIMVAG		;compara com posição final
		jbe repetM			;se ele for um valor abaixo ou igual continua incremenar linhas
		mov dx,INITVAG		;move a nova posição inicial
	ret
MVAGAO endp
;-------------------------------------------------------------
;	CHAMA OS MOEDAS DO MEIO
;-------------------------------------------------------------
MCOIN proc near
		mov dx,INITVAG		;ve o valor da posição inicial
repetCM:
		mov cx,COMVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		MOV AL,02
		call rhoriz			;chama procedimento que avança a linha vertical
		inc dx				;incrementa para a proxima linha
		cmp dx,FIMVAG		;compara com posição final
		jbe repetCM			;se ele for um valor abaixo ou igual continua incremenar linhas
		mov dx,INITVAG		;move a nova posição inicial
		ADD dx,5H
		mov bx,cumpVAG		;cumprimento do quadrado
		mov cx,COMVAG		;chama a variavel
		MOV AL,00
		call rhoriz			;chama procedimento que avança a linha vertical
		mov dx,INITVAG		;chama a variavel
		ADD DX,10H
		mov cx,COMVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		MOV AL,00
		call rhoriz			;chama procedimento que avança a linha vertical
	ret
MCOIN endp
;-------------------------------------------------------------
;	CHAMA OS MOEDAS DA ESQUERDA
;-------------------------------------------------------------
ECOIN proc near
		mov dx,INITVAG		;ve o valor da posição inicial
repetCE:
		mov cx,COEVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		MOV AL,02
		call rhoriz			;chama procedimento que avança a linha vertical
		inc dx				;incrementa para a proxima linha
		cmp dx,FIMVAG		;compara com posição final
		jbe repetCE			;se ele for um valor abaixo ou igual continua incremenar linhas
		mov dx,INITVAG		;move a nova posição inicial
		ADD dx,5H
		mov bx,cumpVAG		;cumprimento do quadrado
		mov cx,COEVAG		;chama a variavel
		MOV AL,00
		call rhoriz			;chama procedimento que avança a linha vertical
		mov dx,INITVAG		;chama a variavel
		ADD DX,10H
		mov cx,COEVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		MOV AL,00
		call rhoriz			;chama procedimento que avança a linha vertical
	ret
ECOIN endp
;-------------------------------------------------------------
;	CHAMA OS VAGÕES DA ESQUERDA
;-------------------------------------------------------------
EVAGAO proc near
		mov dx,INITVAG		;ve o valor da posição inicial
repete:
		mov cx,COEVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		call rhoriz			;chama procedimento que avança a linha vertical
		inc dx				;incrementa para a proxima linha
		cmp dx,FIMVAG		;compara com posição final
		jbe repete			;se ele for um valor abaixo ou igual continua incremenar linhas
		mov dx,INITVAG		;move a nova posição inicial
	ret
EVAGAO endp
;-------------------------------------------------------------
;	CHAMA OS MOEDAS DA DIREITA
;-------------------------------------------------------------
DCOIN proc near
		mov dx,INITVAG		;ve o valor da posição inicial
repetCD:
		mov cx,CODVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		MOV AL,02
		call rhoriz			;chama procedimento que avança a linha vertical
		inc dx				;incrementa para a proxima linha
		cmp dx,FIMVAG		;compara com posição final
		jbe repetCD			;se ele for um valor abaixo ou igual continua incremenar linhas
		mov dx,INITVAG		;move a nova posição inicial
		ADD dx,5H
		mov bx,cumpVAG		;cumprimento do quadrado
		mov cx,CODVAG		;chama a variavel
		MOV AL,00
		call rhoriz			;chama procedimento que avança a linha vertical
		mov dx,INITVAG		;chama a variavel
		ADD DX,10H
		mov cx,CODVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		MOV AL,00
		call rhoriz			;chama procedimento que avança a linha vertical
	ret
DCOIN endp
;-------------------------------------------------------------
;	CHAMA OS VAGÕES DA DIREITA
;-------------------------------------------------------------
DVAGAO proc near
		mov dx,INITVAG		;ve o valor da posição inicial
repetd:
		mov cx,CODVAG		;chama a variavel
		mov bx,cumpVAG		;cumprimento do quadrado
		call rhoriz			;chama procedimento que avança a linha vertical
		inc dx				;incrementa para a proxima linha
		cmp dx,FIMVAG		;compara com posição final
		jbe repetd			;se ele for um valor abaixo ou igual continua incremenar linhas
		mov dx,INITVAG		;move a nova posição inicial
	ret
DVAGAO endp
;-------------------------------------------------------------
;	FUNÇÃO DO CONTROLO POR RATO/TECLAS E INCREMENTAÇÃO DE TEMPO DO VAGÃOS/MOEDAS
;-------------------------------------------------------------
MOVIM PROC NEAR	
VOLTA:	
		CALL DOSTIME
		call MOSTRACHRONO	;chama o cronometro
		XOR DL,DL
		MOV TEMP,DX  			;guarda o valor 
OBTEM_SEGUNDO:  
		;SE AS CONDIÇÕES NÂO FOREM SATISFEITAS O TECLADO ASSUME AS FUNÇõES DOS MOVIMENTOS
		CALL DOSTIME	
		mov AH,01 			;VERIFICA O ESTADO DO TECLADO
		int 16h				;envoca interrupção da bios para o teclado
		jz tempo			;SE FOR 0 É PORQUE NÃO FOI UTILIZADO E VOLTA A PERGUNTAR
		CALL READKEYBORD
		CMP AL,'j'			;Compara o caracter com a letra 'j'
		JE movEsq				;salta para o movimento que faz mexer o quadrado para a esquerda
		CMP AL,'k'			;Compara o caracter com a letra 'k'
		JE baixo			;salta para o movimento que faz mexer o quadrado para a baixo
		CMP AL,'l'			;Compara o caracter com a letra 'l'
		JE movDir				;salta para o movimento que faz mexer o quadrado para a direita
		CMP AL,'i'			;Compara o caracter com a letra 'i'
		JE cima	
		CMP AL,'p'			;Compara o caracter com a letra 'p'
		JE pausa	
		CMP AL,'x'			;Compara o caracter com a letra 'x'
		JE scrsht	
		CMP AL,1BH			;Compara o caracter com a TECLA 'ESQ'
		JE finish	
		JMP TEMPO
scrsht:
		CALL SCREENSHOT
		JMP TEMPO
pausa:
		CALL READKEYBORD
		JMP TEMPO
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
TEMPO: 
		MOV BX,TEMP
		CMP BH,DH 			;compara o 1º tempo com o tempo actual
		JE OBTEM_SEGUNDO	;se for igual vai recumeçar o relogio	
		
		
		CALL CONTROLER
		CALL MOUSE
		CMP CX,120		;SE RATO ESTIVER NA ENTRE OS 0 e 60 PIXEIS
		JBE esq			;MOVE PARA A ESQUERDA
		CMP CX,240		;SE RATO ESTIVER NA ENTRE OS 61 e 120 PIXEIS
		JBE meio		;MOVE PARA O MEIO
		CMP CX,359		;SE RATO ESTIVER NA ENTRE OS 121 e 180 PIXEIS
		JBE dir			;MOVE PARA A DIREITA
		JMP VOLTA
finish:
		ret	
MOVIM ENDP
;------------------------
;TIME
;@RETURN BX - BUTTONS
;@RETURN CX - HORIZONTAL COORD
;@RETURN DX - VERTICAL COORD
;------------------------
MOUSE PROC NEAR
	MOV AX,3		;ESTADO DO RATO
	INT 33H			;Interrupção DO RATO
	AND BX,07		;METE OS DIGITOS MAIS SIGNIFICATIVOS A 0 (001 010 100) 7(111)
RET
MOUSE ENDP
;------------------------
;TIME
;@RETURN CH - HOURS
;@RETURN CL - MINUTS
;@RETURN DH - SECONDS
;@RETURN DL - CENTSECONDS
;------------------------
DOSTIME PROC NEAR
		PUSH AX
		PUSH BX
		MOV	AH,2Ch  		;OBTEM o TEMPO DO DOS
		INT 21h				;invoca a interrupção do DOS	
		POP BX
		POP AX
	RET
DOSTIME ENDP
;------------------------
;READ KEYBORD
;@RETURN AL - key pressed
;------------------------
READKEYBORD PROC NEAR
		PUSH BX
		PUSH CX
		PUSH DX
		mov AH,00H			;LE O VALOR DO TECLADO
		int 16H		
		POP DX
		POP CX
		POP BX
	RET
READKEYBORD ENDP
;------------------------
;Pinta as BONECO do lado de Cima
;
;------------------------
CIMAP PROC NEAR
		PUSH AX
		MOV AX,POSITION
		CMP AX,1
		POP AX
		JB ecima
		JE mcima
		JA dcima
		jmp fin			;Caso nenhuma das condições não seja satisfeita SAI
ecima:
		MOV AL,00	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,09	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
		JMP fin
mcima:
		MOV AL,09	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
		JMP fin
dcima:
		MOV AL,00	
		CALL MECIMA
		MOV AL,09	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
fin:
	RET
CIMAP ENDP
;------------------------
;Pinta as BONECO do lado de Baixo
;
;------------------------
BAIXOP PROC NEAR
		PUSH AX
		MOV AX,POSITION
		CMP AX,1		;COMPARA COM 1 
		POP AX
		JB ebaixo		;1> é na esquerda
		JE mbaixo		;1= é no meio
		JA dbaixo		;1< é na direita
		jmp fin2		;Caso nenhuma das condições não seja satisfeita repete
ebaixo:					;MOSTRA O BONECO NA ESQUERDA EM BAIXO
		MOV AL,00	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,09	
		CALL ESBAIXO
		JMP fin2
mbaixo:					;MOSTRA O BONECO NA MEIO EM BAIXO
		MOV AL,00	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,09	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
		JMP fin2
dbaixo:					;MOSTRA O BONECO NA DIREITA EM BAIXO
		MOV AL,00	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,09	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
fin2:
	RET
BAIXOP ENDP
;--------------------------------------------------------------------------
;Mostra a informação do lado direito do ecrã
;--------------------------------------------------------------------------
INFOR PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV DH,4			;linha para o colocar
	MOV DL,0			;coluna para o colocar
	CALL POSICIONAECRA
	
	MOV AH,09h				;Função para escrever caracter no ecrã
	LEA	DX,MSG00			;Mensagem a ser escrita
	INT 21H					;Activa a função
	
	
	CALL DOSTIME

	XOR AX,AX				;Garante o ax a "0"
	MOV AL,60				;Move o número de segundos que dá 1 minuto para AL
	MUL CL					;Multiplica pelos segundos
	ADD AL,DH				;Adiciona os segundos
	MOV temporizador,AX		;salva o tempo no temporizador
	
	POP DX
	POP CX
	POP BX
	POP AX
 RET
INFOR ENDP
;---------------------------------------------------------------
;	FUNÇÃO QUE MOSTRA O CRONOMETRO DO ECRÃ
;---------------------------------------------------------------
MOSTRACHRONO PROC NEAR
		PUSH AX
		PUSH CX
		PUSH DX

		CALL DOSTIME

		XOR AX,AX			;garante o AX a "0"
		MOV AL,60			;carega o valor 60
		MUL CL				;multiplica o 60 pelo segundo
		ADD AL,DH			;adiciona os segundos
		SUB AX,temporizador	;total de segundos
		
		MOV DH,5			;linha para o colocar
		MOV DL,32			;coluna para o colocar
		CALL POSICIONAECRA

		MOV CX,60			;carrega o numero 60
		DIV CL 				;divide total corrido seconds by 60
		PUSH AX 			;salva os minutos e segundos
		AND AX,00FFh		;limpa os segundos
		CALL DISPX			;mostra no ecrã os Minutos

		MOV AL,02h			;ativa a função de inserir o caracter
		MOV DL,':'			;imprime o separador separator
		INT 21h				;activa interrupção

		POP AX				;restaura os minutos e segundos
		MOV AL,AH			;prepara os segundos para imprimir no ecrã
		cmp AL,09h			;compara o valor AL com 09h
		jbe zer				;se for abaixo salta
ondeEstavas:		
		AND AX,00FFh		;limpa os minutos
		CALL DISPX			;mostra no ecrã os Segundos
	JMP sairdaqui
zer:
		MOV AH,09h			;ativa a função de inserir o caracter
		LEA DX,ze			;mete um 0 a esquerda nos segundos
		INT 21h				;activa interrupção
	JMP ondeEstavas
sairdaqui:
		POP DX
		POP CX
		POP AX
		RET
MOSTRACHRONO ENDP
;Define o ponto no ecrã e apara o caracter potencialmente ecrito
DEFINEPOINT PROC NEAR
		MOV AH,02h			;define o código de interrupção
		MOV BH,0
		INT 10h				;interrupção de video
	RET
DEFINEPOINT ENDP
;Define o ponto no ecrã e apara o caracter potencialmente ecrito
POSICIONAECRA PROC NEAR
		PUSH AX
		PUSH BX
		PUSH DX
		CALL DEFINEPOINT
		MOV AH,02
		MOV DL,' '
		INT 21h
		POP DX
		CALL DEFINEPOINT
		POP BX
		POP AX
	RET
POSICIONAECRA ENDP
;--------------------------------------------------------------------------
;Procedimento para iniciar o rato
;ESTAVEL
;--------------------------------------------------------------------------
INITMOUSE PROC NEAR
		MOV AX,1				;Mostra o cursor
		INT 33H	
		
		MOV AX,04				;Define a posição inicial do raro
		MOV CX,180				; Coordenada HORIZONTAL
		MOV DX,100				; Coordenada VERTICAL
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
;--------------------------------------------------------------------------------------------------
;Pede Para desenhar a BONECO no lado esquerdo
;-----------------------------------------------------------------------------------
LEFT PROC NEAR
		MOV POSITION,0
		MOV AL,00	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
		MOV AL,09			;COR 02
		CALL EPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
LEFT ENDP
;---------------------------------------------------------------------------
;Pede Para desenhar o BONECO no meio
;---------------------------------------------------------------------------
MIDLE PROC NEAR
		MOV POSITION,1
		MOV AL,00	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
		MOV AL,09			;COR DO BACKGROUND
		CALL MPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
MIDLE ENDP
;------------------------------------------------------------------------
;Pede Para desenhae a BONECO no lado direito
;------------------------------------------------------------------------
RIGHT PROC NEAR
		MOV POSITION,2
		MOV AL,00	
		CALL MECIMA
		MOV AL,00	
		CALL DICIMA
		MOV AL,00	
		CALL ESCIMA
		MOV AL,00	
		CALL MEBAIXO
		MOV AL,00	
		CALL DIBAIXO
		MOV AL,00	
		CALL ESBAIXO
		MOV AL,09			;COR 02
		CALL DPART			;PINTA A PEÇA COM A COR DEFINIDA EM @AL
	RET
RIGHT ENDP
;--------------------------------------------------------------------------------------
;---Boneco do meio
;--------------------------------------------------------------------------------------
MPART PROC NEAR
		PUSH DX
		PUSH AX
		CALL MOUSE
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
		CALL MOUSE
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
		CALL MOUSE
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
;----------------------------------------------------------------------------
;Desenha a BONECO na ESQUERDA em BAIXO
;----------------------------------------------------------------------------
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
;-----------------------------------------------------------------------------
;Desenha a BONECO no MEIO em BAIXO
;-----------------------------------------------------------------------------
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
;---------------------------------------------------------------------
;Desenha a boneco na DIREITA em BAIXO
;---------------------------------------------------------------------
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
;----------------------------------------------------------------------------
;Desenha a BONECO na DIREITA em cima
;----------------------------------------------------------------------------
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
;-------------------------------------------------------------------
;Desenha a BONECO na ESQUERDA em cima
;-------------------------------------------------------------------
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
;-----------------------------------------------------------------------
;Desenha a BONECO no meio em cima
;-----------------------------------------------------------------------
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
;------TABULEIRO DO JOGO---------------------------------------------------------------------------
;FUNÇÃO PARA DESENHAR O TABULEIRO DO JOGO
;ESTAVEL
;--------------------------------------------------------------------------------------------------
TABGAME PROC NEAR
		mov dx,00			;Vertical
		mov cx,60			;Horizontal
		mov bx,199			;cumprimento
		call reta1
		
		mov dx,00			;Vertical
		mov cx,120			;Horizontal
		mov bx,199			;cumprimento
		call reta2
		
		mov dx,00			;Vertical
		mov cx,80			;Horizontal
		mov bx,199			;cumprimento
		call reta3
		
		mov dx,00			;Vertical
		mov cx,100			;Horizontal
		mov bx,199			;cumprimento
		call reta4
		
		mov dx,0			;Vertical
		mov cx,180			;Horizontal
		mov bx,199			;cumprimento
		call rVertic
		
	RET
TABGAME ENDP
;--------------------------------------------------------------------------
;Desenha Reta Vertical
; @PARAM AL - COR
; @PARAM BX - CUMPRIMENTO
; @PARAM CX - PONTO INICIAL HORIZONTAL
; @PARAM DX - PONTO INICIAL VERTICAL
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
; @PARAM AL - COR
; @PARAM BX - CUMPRIMENTO
; @PARAM CX - PONTO INICIAL HORIZONTAL
; @PARAM DX - PONTO INICIAL VERTICAL
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
;--------------------------------------------------------------------------
;Desenha Reta ANGULAR 1
; @PARAM AL - COR
; @PARAM BX - CUMPRIMENTO
; @PARAM CX - PONTO INICIAL HORIZONTAL
; @PARAM DX - PONTO INICIAL VERTICAL
;--------------------------------------------------------------------------
reta1 proc near
inicio3:
	cmp bx,00h				;compara se o bx chegou ao valor mínimo
	je sai3					;se sim sai	
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	DEC bx
	DEC CX
	jmp inicio3				;Volta a verificar
sai3:
	ret						;Termina o procedimento
reta1 endp 
;--------------------------------------------------------------------------
;Desenha Reta ANGULAR 2
; @PARAM AL - COR
; @PARAM BX - CUMPRIMENTO
; @PARAM CX - PONTO INICIAL HORIZONTAL
; @PARAM DX - PONTO INICIAL VERTICAL
;--------------------------------------------------------------------------
reta2 proc near
inicio4:
	cmp bx,00h				;compara se o bx chegou ao valor mínimo
	je sai4					;se sim sai
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	DEC bx
	INC CX	
	jmp inicio4				;Volta a verificar
sai4:
	ret						;Termina o procedimento
reta2 endp 
;--------------------------------------------------------------------------
;Desenha Reta ANGULAR 3
; @PARAM AL - COR
; @PARAM BX - CUMPRIMENTO
; @PARAM CX - PONTO INICIAL HORIZONTAL
; @PARAM DX - PONTO INICIAL VERTICAL
;--------------------------------------------------------------------------
reta3 proc near
inicio5:
	cmp bx,00h				;compara se o bx chegou ao valor mínimo
	je sai5					;se sim sai
	CALL ANGULAR ;ABRE o ANGULO
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	DEC bx
	DEC CX
	jmp inicio5				;Volta a verificar
sai5:
	ret						;Termina o procedimento
reta3 endp 
;--------------------------------------------------------------------------
;Desenha Reta ANGULAR 4
; @PARAM AL - COR
; @PARAM BX - CUMPRIMENTO
; @PARAM CX - PONTO INICIAL HORIZONTAL
; @PARAM DX - PONTO INICIAL VERTICAL
;--------------------------------------------------------------------------
reta4 proc near
inicio6:
	cmp bx,00h				;compara se o bx chegou ao valor mínimo
	je sai6					;se sim sai
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	CALL ANGULAR
	DEC bx
	INC CX					;decrementa o valor da representação o tamanho do comprimento da reta
	jmp inicio6				;Volta a verificar
sai6:
	ret						;Termina o procedimento
reta4 endp 
ANGULAR PROC NEAR
		MOV AH,12				;Escreve o pixel no ecrã
		INT 10h					;Interrupção 10h(Video)
		Inc dx
	RET
ANGULAR ENDP
;---------------------------
;-Converte o código em ASCCI
;ESTAVEL
;---------------------------
DISPX PROC NEAR
		PUSH DX
		PUSH CX
		PUSH BX
		XOR CX,CX			;Garante o cx a "0"
		MOV BX,10			;o número a ser dividido 10
DISPX1:
		XOR DX,DX			;Garante o dx a "0"
		DIV BX 				;Divide o bx
		PUSH DX 			;Guarda o resto para uma variavel
		INC CX 				;conta restante
		OR AX,AX 			;testa o quociente
		JNZ DISPX1
DISPX2:
		POP DX 				;tira o numero da pilha
		MOV AH,06h 			;Função para mostrar o caracter
		ADD DL,30H 			;converte o para ascii
		INT 21H 			;activa a interrupção
		LOOP DISPX2
		POP BX
		POP CX 
		POP DX
	RET
DISPX ENDP
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