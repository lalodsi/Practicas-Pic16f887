		PROCESSOR   P16F887
		INCLUDE	    <P16F887.INC>
	
		__CONFIG _CONFIG1, (_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF & _DEBUG_OFF)
		__CONFIG _CONFIG2, (_WRT_OFF & _BOR40V)

T_AL		EQU		0x20
			
		ORG		0x00		;VECTOR DE RESTAURACION
	
		BANKSEL	ANSEL
	;Entradas Analógicas	
		MOVLW	0x60		;CH5 Y CH6 '01100000'
		MOVWF	ANSEL
		CLRF	ANSELH
	
		BANKSEL	TRISA
	;Reloj de 1MHz
		MOVF	0x40			;0100 0000
		MOVWF	OSCCON
	;Definición de entradas y salidas
		MOVLW	0x03		;CH5 Y CH6
		MOVWF	TRISE
		CLRF	TRISB
		CLRF	TRISC		;SALIDA RC1 CCP1; RC2 CCP1/P1A
		CLRF	TRISD
		CLRF	TRISA
	;Características de la conversión AD
		CLRF	ADCON1		;JUSTIFICACIÓN IZQ REF ALIMENTACIÓN
	;Control del TIMER2	
		MOVLW	0xFF		;255
		MOVWF	PR2		;Registro del timer 2 para hacer una comparacion
	
		BANKSEL	PORTA
	
		
;-------------------------------------------------------------------------------
;-------------------REGISTROS PARA EL CONTROL DEL PWM---------------------------
;-------------------------------------------------------------------------------
		MOVLW	0x80		;1000000000
		;Módulo CCP1
		MOVWF	CCPR1L		;DC 50% 512 => CCPR1L:CCP1CON<5:4> 0b10000000 00
		;Módulo CCP2
		MOVWF	CCPR2L		
	
		
		MOVLW	0x0C		;Mueve b'00001100' al registro W
		;P1M<10>:00 P1A MODULATED; DC1B<1:0>:00; CCP1M<3:0>:PWM
		
		MOVWF	CCP1CON ;0000 1100
		    ;PWM como salida simple
		    ;Elije el modo PWM con P1A, P1B, P1C y P1D activos en alto
		
		MOVWF	CCP2CON
		    ;Elije el modo PWM
;-------------------------------------------------------------------------------
		    
		    
		BSF		T2CON,0		;TMR2 PreE T2CKPS<1:0> 16 11; TOUTPS<3:1> 1:1 0000
		BSF		T2CON,1		
		BSF		T2CON, TMR2ON	;ENCENDER TMR2
E_IP		BTFSS	PIR1, TMR2IF	;ESPERAR INICIO PERIODO
		GOTO	E_IP
	
C_P		MOVLW	b'11010101'		;SELECCIONAR C0 '11000001'
		MOVWF	ADCON0

		BSF		ADCON0, GO_DONE		
E_C0		BTFSC	ADCON0, GO_DONE
		GOTO	E_C0
		MOVF	ADRESH, W
		MOVWF	CCPR1L
		CALL	R_AL
		MOVWF	CCP1CON
		BCF		ADCON0, ADON
	
		MOVLW	b'11011001'		;SELECCIONAR C1
		MOVWF	ADCON0
	
		BSF		ADCON0, GO_DONE		
E_C1	BTFSC	ADCON0, GO_DONE
		GOTO	E_C1
		MOVF	ADRESH, W
		MOVWF	CCPR2L
		CALL	R_AL
		MOVWF	CCP2CON
		BCF		ADCON0, ADON

		GOTO	C_P		
			
R_AL	
		BANKSEL	TRISA
		MOVF	ADRESL,W
		BANKSEL	PORTA
		MOVWF	T_AL		;DA00 0000
		BCF		STATUS, C
		RRF		T_AL,F
		RRF		T_AL,F  ;00DA 0000
		MOVLW	0x0C		;0000 1100
		IORWF	T_AL,W
		RETURN
	
		END