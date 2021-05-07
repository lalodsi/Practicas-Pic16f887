	    LIST P=16F887
	    INCLUDE <P16F887.INC>
	    
	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	    
	    ORG	    0x00
	    BSF	    STATUS, RP0
	    BSF	    STATUS, RP1
	    CLRF    ANSEL
	    CLRF    ANSELH
	    BSF	    STATUS, RP0
	    BCF	    STATUS, RP1
	    MOVLW   0xFF
	    MOVWF   TRISA
	    CLRF    TRISB
	    CLRF    TRISC
	    CLRF    TRISD
	    CLRF    TRISE
	    BCF	    STATUS, RP0
	    BCF	    STATUS, RP1
CICLO	    MOVF    PORTA, W
;	    ADDLW   0x0A
	    MOVWF   PORTB
	    GOTO    CICLO
	    
	    END