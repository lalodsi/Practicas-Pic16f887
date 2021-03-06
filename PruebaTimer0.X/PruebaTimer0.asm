;	    CONTROLADOR DE MOTOR A PASOS UNIPOLAR
; 
; AUTOR: RODR?GUEZ RAM?REZ LUIS EDUARDO
;	    
;	    EL OBJETIVO DE ESTE C?DIGO ES CONTROLAR UN MOTOR A PASOS UNIPOLAR A TRAV?S
; DEL PUERTO B Y UTILIZANDO UN SWITCH COMO CAMBIO DE DIRECCI?N, EN ESTE CASO EL SWITCH ES RA7
	    
	    LIST P=16F887
	    INCLUDE <P16F887.INC>

	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	    
	    ORG		0x00
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1
	    CLRF	ANSEL
	    CLRF	ANSELH
	    BSF		STATUS, RP0
	    BCF		STATUS, RP1; BANCO 1
	    CLRF	TRISA
	    CLRF	TRISB
	    CLRF	TRISC
	    CLRF	TRISD
	    CLRF	TRISE
	    MOVLW	0xD7
	    MOVWF	OPTION_REG
RETAR	    
	    
	    END