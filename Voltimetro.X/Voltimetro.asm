	    LIST P=16F887
	    INCLUDE <P16F887.INC>
	    
	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	
	    ORG		0x00	
;			
;   Constantes
;			
DET	    EQU		0x21
VA	    EQU		0x22
CH1	    EQU		0x23
CONT	    EQU		0x24
CONTU	    EQU		0x25
CONTD	    EQU		0x26
BA	    EQU		0x27
BB	    EQU		0x28
BD	    EQU		0x29
CONTC	    EQU		0x30
RESTA	    EQU		0x31
CON	    EQU		0x32

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;----------DEFINICION DE ENTRADAS Y SALIDAS---------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------	    

	    BANKSEL	TRISA
	    MOVLW	0x01
	    MOVWF	TRISA		    ;A COMO ENTRADA
	    CLRF	TRISB		    ;B COMO SALIDA
	    CLRF	TRISC		    ;C COMO SALIDA
	    CLRF	TRISD		    ;D COMO SALIDA
	    CLRF	TRISE		    ;E COMO SALIDA
;----------ENTRADAS ANALÓGICAS----------------------	
	    MOVLW	B'00000000'	    ;JUSTIFICACION A LA
	    MOVWF	ADCON1		    ;IZQUIERDA
	    BCF		STATUS, RP0
	    BCF		STATUS, RP1	    ;BANCO 0
	    MOVLW	B'11000001'	    ;ACTIVA AN0
	    MOVWF	ADCON0
	    BANKSEL	ANSEL		    ;BANCO 3
	    MOVLW	B'00000001'	    ;ENTRADA ANALOGICA 0
	    MOVWF	ANSEL
	    CLRF	ANSELH

;-------DEFINICION TIMER 0 COMO TEMPORIZADOR--------

	    BANKSEL	OPTION_REG
	    MOVLW	0XD4		    ;'1101 0100'
	    MOVWF	OPTION_REG	    ;
	    
;---------INICIALIZAR VALORES-----------------------
	    BANKSEL 	ADCON0
	    CLRF	CONTU
	    CLRF	CONTD
	    CLRF	CONTC
	    CLRF	RESTA
				
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-----------------CICLO PRINCIPAL-------------------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
C_P	    CALL	RET		;Llama al retardo
	    BSF 	ADCON0,GO_DONE	;Iniciamos la conversión
EC0	    BTFSC	ADCON0,GO_DONE	;Realizamos un ciclo y esperamos hasta que termine la conversion.
	    GOTO	EC0
	    MOVF 	ADRESH,W	;Pasamos el resultado de la conversion que se guardo en ADRESH a W
	    MOVWF	RESTA		;Guardamos el resultado en el registro RESTA
;--------------RECEPCION DE DATOS-------------------
	    GOTO	REST1
	    GOTO	C_P

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-----------NO SE QUE ES ESTO-----------
;---------------------------------------------------
;---------------------------------------------------
;----------------------------------------------------
	    
REST1	    MOVF	RESTA,W
	    MOVWF	VA
	    MOVLW	.51
	    SUBWF	RESTA,F
	    BTFSS	STATUS,C
	    GOTO	SIG1
	    INCF	CONTU,F
	    GOTO	REST1

SIG1	    MOVF	VA,W
	    MOVWF	RESTA
REST2	    MOVLW	.5
	    SUBWF	RESTA,F
	    BTFSS	STATUS,C
	    GOTO	SIG2
	    INCF	CONTD,F
	    GOTO	REST2

SIG2	    MOVF	VA,W
	    MOVWF	RESTA
REST3	    MOVLW	.1
	    SUBWF	RESTA,F
	    BTFSS	STATUS,C
	    CALL	SEG7
	    GOTO	C_P
	    INCF	CONTC,F
	    GOTO	C_P
	    
;C_P			CLRF		CONTU
;			CLRF		CONTD
;			CLRF		CONTC
;			CLRF		RESTA
;			MOVLW		B'11000000'
;			MOVWF		ADCON0
;			BSF 		ADCON0,ADON 	; Encendemos el ADC
;			CALL		RET
;			BSF 		ADCON0,GO_DONE	; Iniciamos la conversión
;EC0			BTFSC		ADCON0,GO_DONE	; Realizamos un ciclo y esperamos hasta que termine la conversion.
;			GOTO		EC0
;			BCF 		ADCON0,ADON		; Apagamos el ADC
;			BANKSEL		ADRESH
;			MOVF 		ADRESH,W		; Pasamos el resultado de la conversion que se guardo en ADRESH a W
;;			MOVLW		.160
;			MOVWF		RESTA
;;Recepcion de datos
;			GOTO		REST1
;VOLT		
;			CALL		SEG7
;RETUR			GOTO		C_P
;
;;oBTENCION DE TEENSION
;REST1		MOVF		RESTA,W
;			MOVWF		VA
;			MOVLW		.51
;			SUBWF		RESTA,F
;			BTFSS		STATUS,C
;			GOTO		SIG1
;			INCF		CONTU,F
;			GOTO		REST1
;
;SIG1		MOVF		VA,W
;			MOVWF		RESTA
;REST2		MOVLW		.5
;			SUBWF		RESTA,F
;			BTFSS		STATUS,C
;			GOTO		SIG2
;			INCF		CONTD,F
;			GOTO		REST2
;
;SIG2		MOVF		VA,W
;			MOVWF		RESTA
;REST3		MOVLW		.1
;			SUBWF		RESTA,F
;			BTFSS		STATUS,C
;			GOTO		VOLT
;			INCF		CONTC,F
;			GOTO		REST3	    

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-----------BARRIDO DE NÚMEROS EN DISPLAY-----------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
SEG7	    MOVF	CONTU,W
	    CALL	DISP_PUNTO
	    MOVWF	PORTB
	    MOVLW	B'00000001'
	    MOVWF	PORTC
	    CALL	R8.5ms
;Muestra decenas
	    MOVF	CONTD,W
	    CALL	DISP_NUM
	    MOVWF	PORTB
	    MOVLW	B'00000010'
	    MOVWF	PORTC
	    CALL	R8.5ms
;Muestra centenas
	    MOVF	CONTC,W
	    CALL	DISP_NUM
	    MOVWF	PORTB
	    MOVLW	B'00000100'
	    MOVWF	PORTC
	    CALL	R8.5ms
	    RETURN

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-----------MUESTRA DE NUMEROS EN DISPLAY-----------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
DISP_NUM    ADDWF	PCL,F		    ;SALTA EL CONTADOR A LA INSTRUCCIÓN CORRESPONDIENTE
	    RETLW	0xFC		    ;NUMERO 0
	    RETLW	0x60		    ;NUMERO 1
	    RETLW	0xDA		    ;NUMERO 2
	    RETLW	0xF2		    ;NUMERO 3
	    RETLW	0x66		    ;NUMERO 4
	    RETLW	0xB6		    ;NUMERO 5
	    RETLW	0xBE		    ;NUMERO 6
	    RETLW	0xE0		    ;NUMERO 7
	    RETLW	0xFE		    ;NUMERO 8
	    RETLW	0xE6		    ;NUMERO 9

DISP_PUNTO  ADDWF	PCL,F
	    RETLW	0xFD		    ;NUMERO 0.
	    RETLW	0x61		    ;NUMERO 1.
	    RETLW	0xDB		    ;NUMERO 2.
	    RETLW	0xF3		    ;NUMERO 3.
	    RETLW	0x67		    ;NUMERO 4.
	    RETLW	0xB7		    ;NUMERO 5.
	    RETLW	0xBF		    ;NUMERO 6.
	    RETLW	0xE1		    ;NUMERO 7.
	    RETLW	0xFF		    ;NUMERO 8.
	    RETLW	0xE7		    ;NUMERO 9.

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-----------RETARDO CON TIMER 0---------------------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
R8.5ms	    MOVLW	0X03 ;0x03
	    MOVWF	CONT
C_CI	    CLRF	TMR0
E64	    BTFSS	TMR0,5
	    GOTO	E64
	    DECFSZ	CONT,F
	    GOTO	C_CI
	    RETURN
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-------------------RETARDO-------------------------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
RET	    MOVLW	0X05		
	    MOVWF	BD
CVC	    MOVLW	0x0F
	    MOVWF	BB
CVB	    MOVLW	0x20
	    MOVWF	BA
CVA	    ;CLRWDT
	    NOP
	    DECFSZ	BA,F
	    GOTO	CVA
	    DECFSZ	BB,F
	    GOTO	CVB
	    DECFSZ	BD,F
	    GOTO	CVC
	    RETURN	

	    END