STACK SEGMENT PARA STACK 
	DB 64 DUP ('MYSTACK ')
STACK ENDS
MYDATA SEGMENT PARA 'DATA'
		COMPLIN 	DW  118
		COMPCOL 	DW  168
		COMPQUAD	DW  26 
		POSINIC		DW	160
		POSFIN		DW 	169
		LINUMIN		DW 	60
		LINDOIN		DW	70
		var			DW	1
		LEITINIC	DW	21
		LEITFIN		DW  117
		temporizador	DW 	0
		stringVazia		DB 	5 DUP (' '),'$'
		ze				DB '0','$'
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

		CALL CONTROLO
		CALL POSICIONAECRA

		MOV AH,00h			;SET MODE VIDEO
		MOV AL,02h			;80x25 TEXT
		INT 10h				;Interrupção 10H(Video)
	RET 
MYPROC ENDP
CONTROLO PROC NEAR
		call infor			;chama o painel do tempo	
VOLTA1:	
		MOV	AH,2Ch  		;OBTEM o TEMPO DO DOS
		INT 21h				;invoca a interrupção do DOS
		call MOSTRACHRONO	;chama o cronometro
		MOV BH,DH  			;guarda o valor 
OBTEM_SEGUNDO:       
		MOV AH,2Ch			;OBTEM o TEMPO DO DOS
		INT 21h 			;invoca a interrupção do DOS
		mov AH,01 			;ve o estado do teclado 
		int 16h				;envoca interrupção da bios para o teclado
		jz TEMPO
		mov AH,01H			; vai ler o valor do teclado
		int 21H				;envoca interrupção da bios para o teclado		
		cmp AL,1BH			;verifica se foi primida a tecla 'ESQ'
		je sair
	JMP TEMPO				;salta para a comparação de tempos
TEMPO: 
		CMP BH,DH 			;compara o 1º tempo com o tempo actual
		JE OBTEM_SEGUNDO	;se for igual vai recumeçar o relogio
	JMP VOLTA1				;recomeça o o procedimento
sair:
	ret
CONTROLO ENDP
INFOR PROC NEAR
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	
	MOV AH,2Ch				;le o tempo actual
	INT 21h

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
POSICIONAECRA PROC NEAR
		PUSH AX
		PUSH BX
		PUSH DX
		MOV AH,02h			;define o código de interrupção
		MOV BH,0
		INT 10h				;interrupção de video
		MOV AH,02
		MOV DL,' '
		INT 21h
		POP DX
		MOV AH,02h			;define o código de interrupção
		MOV BH,0
		INT 10h				;interrupção de video
		POP BX
		POP AX
	RET
POSICIONAECRA ENDP
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
MOSTRACHRONO PROC NEAR
		PUSH AX
		PUSH CX
		PUSH DX

		MOV AH,2Ch			;Tempo do Sistema
		INT 21h				;Activa a interrupção

		XOR AX,AX			;garante o AX a "0"
		MOV AL,60			;carega o valor 60
		MUL CL				;multiplica o 60 pelo segundo
		ADD AL,DH			;adiciona os segundos
		SUB AX,temporizador	;total de segundos
		
		MOV DH,5			;linha para o colocar
		MOV DL,31			;coluna para o colocar
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
MYCODE ENDS 
END