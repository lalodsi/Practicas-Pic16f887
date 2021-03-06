	    LIST P=16F887
	    INCLUDE <P16F887.INC>
	    
	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V

	    ORG		0x00
	    
VA	    EQU		0x20 ;Guardado temporal
NB	    EQU		0x21 ;Guarda los datos en B para operarlos
NA	    EQU		0x22 ;Guarda los datos en A para operarlos
RX	    EQU		0x23
OPX	    EQU		0x24
XB	    EQU		0x25
XA	    EQU		0x26
	    
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1 ;BANCO 3
	    CLRF	ANSEL
	    CLRF	ANSELH	    ;DESACTIVA SALIDAS ANALOGICAS
	    BSF		STATUS, RP0
	    BCF		STATUS, RP1 ;BANCO 1
	    MOVLW	0xFF	    ;MOVER 255 A W
	    MOVWF	TRISA
	    CLRF	TRISB
	    CLRF	TRISC
	    CLRF	TRISD
	    CLRF	TRISE
	    BCF		STATUS, RP0
	    BCF		STATUS, RP1 ;BANCO 0
;
; COMIENZA EL CODIGO DE FUNCIONAMIENTO
;	    
C_P	    ;Parte 1: Recibir del puerto A y ordenarlo
	    MOVF	PORTA, W    ;MUEVE EL CONTENIDO DEL PUERTO A A W DEBIDO A QUE W=0 COMO BIT
	    MOVWF	VA	    ;MUEVE LO CONTENIDO EN W AL REGISTRO VA
	    ANDLW	0x0F	    ;SE HACE LA OPERACION W AND 0x0F Y SE GUARDA EN EL REGISTRO W
	    MOVWF	NB	    ;MUEVE LO CONTENIDO EN W AL REGISTRO NB
	    MOVF	VA, W	    ;MUEVE EL CONTENIDO DEL REGISTRO VA A W DEBIDO A QUE W=0 COMO BIT
	    ANDLW	0xF0	    ;EJECITA LA OPERACION W AND 0xF0 Y SE GUARDA EN EL REGISTRO W
	    MOVWF	NA	    ;MUEVE EL CONTENIDO DE W AL REGISTRO NA
	    SWAPF	NA, F	    ;INTERCAMBIA LOS NIBLES CONTENIDOS EN EL REGISTRO NA
	    ;Parte 2: Revisar la entrada del puerto C para determinar si es suma o alguna otra operacion
	    CLRF	RX	    ;LIMPIA EL CONTENIDO EN EL REGISTRO RX
	    MOVF	PORTC,W	    ;MUEVE EL CONTENIDO DEL PUERTO C AL REGISTRO W DEBIDO A QUE W=0 COMO BIT
	    MOVWF	OPX	    ;EL CONTENIDO DE W LO MUEVE AL REGISTRO OPX
	    BTFSC	STATUS,Z    ;REVISA EL BIT Z DEL REGISTRO STATUS, SI ES 0 SALTA UNA INSTRUCCIÓN
	    GOTO	X_SUM
	    DECFSZ	OPX,W	    ; RESTA 1 AL REGISTRO OPX, SI EL RESULTADO ES CERO SE SALTA UNA INSTRUCCIÓN
	    GOTO	E_MD
	    
X_RES	    MOVF	NB,W	    ;MUEVE EL CONTENIDO DE NB AL REGISTRO W
	    SUBWF	NA,W	    ;HACE LA OPERACION NA - W Y SE GUARDA EN W
	    MOVWF	RX	    ;MUEVE EL CONTENIDO DE W AL REGISTRO RX
	    GOTO	M_R	    
	    
X_SUM	    MOVF	NB,W	    ;MUEVE EL CONTENIDO DE NB AL REGISTRO W
	    ADDWF	NA,W	    ;HACE LA OPERACIÓN NA + W Y SE GUARDA EN W
	    MOVWF	RX	    ;MUEVE EL CONTENIDO DE W AL REGISTRO RX
	    GOTO	M_R
	    
	    ;Parte 3	Ya que no es suma ni resta, entonces hay que saber si es división o multiplicacion
	    ;		pero primero revisar si ambas entradas son cero, si es así, muestra directamente
	    ;		un cero binario en la salida
E_MD	    MOVF	NB,F	    ;MUEVE EL CONTENIDO DE NB A SÍ MISMO (MODIFICA A Z)
	    BTFSC	STATUS,Z    ;REVISA EL BIT Z DEL REGISTRO STATUS, SI ES 0 SALTA UNA INSTRUCCIÓN
	    GOTO	M_R
	    MOVF	NA,F	    ;MUEVE EL CONTENIDO DE NA A SÍ MISMO (MODIFICA A Z)
	    BTFSC	STATUS,Z    ;REVISA EL BIT Z DEL REGISTRO STATUS, SI ES 0 SALTA UNA INSTRUCCIÓN
	    GOTO	M_R
	    
	    ;Parte 4	Ahora compara el puerto C con 2 y 3 para determinar si es división o multiplicación
	    
	    MOVLW	0x02	    ;GUARDA UN 2 EN EL REGISTRO W
	    SUBWF	OPX,W	    ;HACE LA OPERACION OPX - W Y SE GUARDA EN EL REGISTRO W
	    BTFSC	STATUS,Z    ;REVISA EL BIT Z DEL REGISTRO STATUS, SI ES 0, SALTA UNA INSTRUCCIÓN
	    GOTO	X_MUL
	    MOVLW	0x03	    ;GUARDA UN 3 EN EL REGISTRO W
	    SUBWF	OPX,W	    ;HACE LA OPERACION OPX - W Y SE GUARDA EN EL REGISTRO W
	    BTFSC	STATUS,Z    ;REVISA EL BIT Z DEL REGISTRO STATUS, SI ES 0 SE SALTA UNA INSTRUCCIÓN
	    GOTO	X_DIV
	    ;Cualquier otro caso no previsto, muestra cero en la entrada
	    GOTO	M_R
	    
X_MUL	    MOVF	NA,W	    ;MUEVE EL CONTENIDO DEL REGISTRO NA AL REGISTRO W
	    SUBWF	NB,W	    ;HACE LA OPERACION NB - W Y SE GUARDA EN EL REGISTRO W
	    BTFSC	STATUS,C    ;REVISA EL BIT Z DEL REGISTRO STATUS, SI ES 0 SE SALTA UNA INSTRUCCIÓN
	    GOTO	NB_M
	    MOVF	NA,W	    ;MUEVE EL CONTENIDO DE NA AL REGISTRO W
	    MOVWF	XB	    ;MUEVE EL CONTENIDO DEL REGISTRO W AL REGISTRO XB
	    MOVF	NB,W	    ;MUEVE EL CONTENIDO DEL REGISTRO NB AL REGISTRO W
	    MOVWF	XA	    ;MUEVE EL CONTENIDO DEL REGISTRO W AL REGISTRO NA
	    GOTO	C_MUL
	    
NB_M	    MOVF	NB,W	    ;MUEVE EL CONTENIDO DE NB AL REGISTRO W
	    MOVWF	XB	    ;MUEVE EL CONTENIDO DEL REGISTRO W AL REGISTRO XB
	    MOVF	NA,W	    ;MUEVE EL CONTENIDO DE NA AL REGISTRO W
	    MOVWF	XA	    ;MUEVE EL CONTENIDO DEL REGISTRO W AL REGISTRO XA
	    
C_MUL	    MOVF	XB,W	    ;MUEVE EL CONTENIDO DEL REGISTRO XB AL REGISTRO W
	    ADDWF	RX,F	    ;HACE LA OPERACION W + RX Y EL RESULTADO LO GUARDA EN RX
	    DECFSZ	XA,F	    ;SE RESTA 1 A XA Y SE GUARDA EL RESULTADO EN XA, SI ES CERO, SALTA
	    GOTO	C_MUL
	    GOTO	M_R
	    
X_DIV	    MOVF	NA,W	    ;MUEVE EL CONTENIDO DEL REGISTRO NA AL REGISTRO W
	    SUBWF	NB,F	    ;HACE LA OPERACION NB - W Y EL RESULTADO LO GUARDA EN NB
	    BTFSS	STATUS,C    ;REVISA EL BIT C DEL REGISTRO STATUS, Y SALTA SI ES 1
	    GOTO	M_R
	    INCF	RX,F	    ;INCREMENTA LO CONTENIDO EN RX Y LO GUARDA EN RX
	    GOTO	X_DIV
	    
	    ;Mostrar Resultado
M_R	    MOVF	RX,W	    ;MUEVE EL CONTENIDO DE RX AL REGISTRO W
	    MOVWF	PORTB	    ;EL CONTENIDO EN EL REGISTRO W LO MUESTRA EN EL PUERTO B
	    GOTO	C_P
	    
	    END