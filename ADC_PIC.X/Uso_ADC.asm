	    LIST P=16F887
	    INCLUDE <P16F887.INC>

	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	    
	    ORG		0x00
VPA	    EQU		0x20
OP1	    EQU		0x21
OP2	    EQU		0x22
OP3	    EQU		0x23	    
	    ;ELEGIR SALIDAS ANALOGICAS
	    BANKSEL	ANSEL  
	    MOVLW	0xE0 ;1110 0000
	    MOVWF	ANSEL
	    CLRF	ANSELH
	    
	    ;ELEGIR PUERTOS
	    BANKSEL	TRISA
	    MOVLW	0xFF
	    MOVWF	TRISA
	    CLRF	TRISB
	    CLRF	TRISC
	    CLRF	TRISD
	    MOVLW	0x07 ; 0000 0111
	    MOVWF	TRISE ; TRES BITS DEL PUERTO E COMO ENTRADA
	    CLRF	ADCON1 ; CONFIGURA REFERENCIAS Y JUSTIFICACION
	    BANKSEL	PORTA
	    MOVLW	B'11010101'
	    MOVWF	ADCON0 ;ACTIVA LAS ENTRADAS ANALOGICAS
		;CALL SampleTime ;Acquisiton delay
	    
C_P	    BSF		ADCON0,GO ;Start conversion
	    BTFSC	ADCON0,GO ;Is conversion done?
	    GOTO	C_P ;No, test again
	    MOVF	ADRESH,W ;Read upper 2 bits
	    MOVWF	PORTB
	    GOTO	C_P
;	    MOVLW	0x01
;	    SUBWF	VPA,W
;	    BTFSC	STATUS, Z
;	    GOTO	OP1
;	    
;	    MOVLW	0x02
;	    SUBWF	VPA,W
;	    BTFSC	STATUS,Z
;	    GOTO	OP2
;	    
;	    MOVLW	0x03
;	    SUBWF	VPA, W
;	    BTFSC	STATUS,Z
;	    GOTO	OP3
;	    GOTO	C_P
	    
	    END
;OP1	    
;;	    MOVF	V_CS.W
;	    
;	    GOTO	M_R
;	    
;OP2	    
;;	    MOVWF	V_C6
;	    
;	    GOTO	M_R
;	    
;OP3	    
;;	    MOVWF	V_X
;	    
;	    GOTO	M_R
;	    
;M_R	    ;CALL	RAN
;	    MOVWF	PORTB
;	    GOTO	C_P
;	    
;	    