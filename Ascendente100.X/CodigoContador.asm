	    LIST P=16F887
	    INCLUDE <P16F887.INC>
	    
	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	    
	    ;Código para un conteo descendente
	    ;El microcontrolador contará comenzando desde 100 hasta llegar al
	    ;0 en donde se detendrá y no hará nada después
	    
	    ORG		0x00
	    
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1 ;BANCO 3
	    CLRF	ANSEL
	    CLRF	ANSELH;DESACTIVAR ENTRADAS ANALOGICAS
	    BSF		STATUS, RP0
	    BCF		STATUS, RP1;BANCO 1
	    CLRF	TRISA
	    CLRF	TRISB
	    CLRF	TRISC
	    CLRF	TRISD
	    CLRF	TRISE		;TODAS COMO SALIDAS
	    BCF		STATUS, RP0
	    BCF		STATUS, RP1	;BANCO 0
	    
	    
	    CLRF	COM		;Limpia la variable
CONTADOR    MOVF	COM, W		;Mueve el contenido de la variable COM a W si W es cero
	    MOVWF	PORTB		;Mueve el contenido de W al puerto B
	    INCF	COM, F		;Incrementa la variable COM
	    MOVLW	0x64
	    SUBWF	COM, W
	    BTFSS	STATUS, 2
	    GOTO	CONTADOR
TERMINO	    GOTO	TERMINO