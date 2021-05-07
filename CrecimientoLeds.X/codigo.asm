	    LIST P=16F887
	    INCLUDE <P16F887.INC>
	    
	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V

	    ORG		0x00
COM	    EQU		0x20; Declara la variable
VA	    EQU		0x21
VB	    EQU		0x22
VC	    EQU		0x23	    
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1 ; BANCO 3
	    CLRF	ANSEL
	    CLRF	ANSELH		;DESACTIVAR ENTRADAS ANALOGICAS
	    BSF		STATUS, RP0
	    BCF		STATUS, RP1	;BANCO 1
	    MOVLW	0xFF		;GUARDAR FF EN W
	    MOVWF	TRISA		;CONFIGURAR A COMO ENTRADA
	    CLRF	TRISB		;B COMO SALIDA
	    CLRF	TRISC
	    CLRF	TRISD
	    CLRF	TRISE
	    BCF		STATUS, RP0
	    BCF		STATUS, RP1	; BANCO 0
	    CLRF	COM		;Limpia la variable
CONTADOR    MOVF	COM, 0x00	;Mueve el contenido de la variable COM a W si W es cero
	    MOVWF	PORTB		;Mueve el contenido de W al puerto B
	    CALL	RET		;LLAMADA A RETARDO, COMENTAR SI SE VA A SIMULAR--------------------
	    INCF	COM, F		;Incrementa la variable COM si F=1
	    MOVLW	0x65		;Mueve el valor 100 decimal al registro W
	    SUBWF	COM, W		;Resta COM - W si W=1, Si el numero es 
	    BTFSS	STATUS, 2	;Si el valor del bit 2 de STATUS es cero, salta la siguiente instruccion
	    GOTO	CONTADOR
TERMINO	    GOTO	TERMINO
	    
	    
;	    
;                                   FUNCION DE RETARDO
;
	    
	    
RET	    MOVLW	0x04
	    MOVWF	VC
C_VC	    MOVLW	0xFA
	    MOVWF	VB
C_VB	    MOVLW	0xF9;0xF9
	    MOVWF	VA
C_VA	    NOP
	    DECFSZ	VA,F
	    GOTO	C_VA
	    DECFSZ	VB,F
	    GOTO	C_VB
	    DECFSZ	VC,F
	    GOTO	C_VC
	    RETURN
	    
	    END