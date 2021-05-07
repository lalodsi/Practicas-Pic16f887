		PROCESSOR P16F887
		INCLUDE <P16F887.INC>
		__CONFIG _CONFIG1,(_INTRC_OSC_NOCLKOUT & _WDT_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _CPD_OFF & _BOR_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF & _DEBUG_OFF)
		__CONFIG _CONFIG2,(_WRT_OFF & _BOR40V)
		
		ORG 	0x00 
;-------------------------------------------------------
;-------------------------------------------------------
;------------DEFINIR ESPACIOS DE MEMORIA----------------
;-------------------------------------------------------
;-------------------------------------------------------
MILLARES	EQU		0X21		;GUARDA EL VALOR DE LOS MILLARES
CENTENAS	EQU		0X22		;GUARDA EL VALOR DE LAS CENTENAS
DECENAS		EQU		0X23		;GUARDA EL VALOR DE LAS DECENAS
UNIDADES	EQU		0X24		;GUARDA EL VALOR DE LAS UNIDADES
VAD		EQU		0X25		;GUARDA EL VALOR ANALOGICO OBTENIDO
X40		EQU		0X26
CONTADOR	EQU		0X27		;CONTADOR PARA RETARDOS USANDO EL TIMER 0
TCE		EQU		0X28
C51		EQU		0X29
TTC		EQU		0X30
TDE		EQU		0X31
C05		EQU		0X32
TTD		EQU		0X33
XV		EQU		0X34

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;----------DEFINICION DE ENTRADAS Y SALIDAS---------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------	
;	    DEFINIR PUERTOS COMO ENTRADAS O SALIDAS		
		BCF	    STATUS, RP0
		BSF	    STATUS, RP1		    ;PUERTO 1
		MOVLW	    0x01
		MOVWF	    TRISA		    ;ENTRADA Y VARIAS SALIDAS
		CLRF	    TRISB		    ;SALIDA
		CLRF	    TRISC		    ;SALIDA
		CLRF	    TRISD		    ;SALIDA
		CLRF	    TRISE		    ;SALIDA
;---------------PUERTOS ANALOGICOS------------------
;	    FORMATO DE NUMERO Y VOLTAJES DE REFERENCIA
		CLRF		ADCON1		    ;JUSTIFICADO A LA IZQUIERDA
;	    DEFINIR EL TIMER 0
		MOVLW	    0XD4		    ;B'11010100'
		MOVWF	    OPTION_REG		    ;PREESCALADOR 1:32
		
		BSF	    STATUS, RP0
		BSF	    STATUS, RP1		    ;BANCO 3
;	    PONER PINES EN MODO ANALOGICO
		BSF	    ANSEL, 0		    ;AD0 COMO PUERTO ANALOGICO
		
		BCF	    STATUS, RP0
		BCF	    STATUS, RP1		    ;BANCO 0
		
;	    LIMPIAR SALIDAS
		CLRF		PORTB
		CLRF		PORTC

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-----------------CICLO PRINCIPAL-------------------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
CICLO_P		CLRF		MILLARES
		CLRF		CENTENAS
		CLRF		DECENAS
		CLRF		UNIDADES
;	    RECIBIR DATOS ANALOGICOS
		MOVLW		B'11000001'
		MOVWF		ADCON0
		BSF 		ADCON0,GO_DONE	    ;COMERZAR CONVERSION
		BTFSC		ADCON0,GO_DONE	    ;ESPERAR A QUE SE TERMINE LA CONVERSIÓN
		GOTO		$-1		    ;REINICIAR ULTIMA ACCION HASTA QUE TERMINE
		BCF 		ADCON0,ADON	    ;APAGAR EL ADC
		
		MOVF 		ADRESH,W	    ;GUARDAR RESULTADO DE ADRESH EN W
		MOVWF		VAD		    ;Y GUARDARLO EN VAD
;---------------------------------------------
		CALL		RCX
		MOVWF		CENTENAS
		
		MOVF		TTC,W
		CALL		RDX
		MOVWF		DECENAS
		
		MOVF		TTC,W
		CALL		RUX
		MOVWF		UNIDADES
		
		CALL		VALDX
		NOP
;----------------------------------------------
		MOVLW		.40
		MOVWF		X40		    ;GUARDA UN 40 EN X40

;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
;-----------------CUENTA 40 CICLOS------------------
;---------------------------------------------------
;---------------------------------------------------
;---------------------------------------------------
CUENTA40	MOVF		UNIDADES,W	    ;GUARDA LAS UNIDADES EN W
		CALL		DISPLAY		    ;ASIGNA UN VALOR ESPECÍFICO
		MOVWF		PORTB		    ;MUESTRA VALOR EN PUERTO
		MOVLW		0X01
		MOVWF		PORTC
		CALL		Ret_TMR0

		MOVF		DECENAS, W	    ;GUARDA LAS DECENAS EN W
		CALL		DISPLAY		    ;ASIGNA UN VALOR ESPECÍFICO
		MOVWF		PORTB		    ;MUESTRA VALOR EN PUERTO
		MOVLW		0X02
		MOVWF		PORTC
		CALL		Ret_TMR0

		MOVF		CENTENAS, W	    ;GUARDA LAS CENTENAS EN W
		CALL		DISPLAY2	    ;ASIGNA UN VALOR ESPECÍFICO
		MOVWF		PORTB		    ;MUESTRA VALOR EN PUERTO
		MOVLW		0X04
		MOVWF		PORTC
		CALL		Ret_TMR0

		MOVF		MILLARES,W	    ;GUARDA LOS MILLARES EN W
		CALL		DISPLAY		    ;ASIGNA UN VALOR ESPECÍFICO
		MOVWF		PORTB		    ;MUESTRA VALOR EN PUERTO
		MOVLW		0X08
		MOVWF		PORTC
		CALL		Ret_TMR0

		DECFSZ		X40,F
		GOTO		CUENTA40
;----------------TERMINANDO EL CICLO 40 VECES
		GOTO		CICLO_P		    ;REGRESA AL CICLO PRINCIPAL

		
;/////////////////////////////////////
RCX		MOVWF		TCE
		CLRF		C51
		CLRF		TTC

R51		MOVLW		.51
		SUBWF		TCE,W
		BTFSS		STATUS, C
		GOTO		RF51
		MOVWF		TCE
		MOVWF		TTC
		INCF		C51,F
		GOTO		R51
		
RF51		MOVF		C51,F
		BTFSS		STATUS, Z
		GOTO		XF51
		MOVF		TCE,W
		MOVWF		TTC
XF51		MOVF		C51, W
		RETURN

;-------------------------------------
RDX		MOVWF		TDE
		CLRF		C05
		CLRF		TTD

R05		MOVLW		.5	    ;5
		SUBWF		TDE,W
		BTFSS		STATUS,C
		GOTO		RF05
		MOVWF		TDE
		MOVWF		TTD
		INCF		C05, F
		GOTO		R05

RF05		MOVF		C05,F
		BTFSC		STATUS, Z
		GOTO		C05CP
		GOTO		C05CN
		
C05CP		MOVF		TDE, W
		MOVWF		TTD
		GOTO		XRF05

C05CN		MOVF		TTD, F
		BTFSS		STATUS, Z
		GOTO		C05X
		MOVLW		0X05
		MOVWF		TTD

C05X		MOVLW		0X0A
		SUBWF		C05,W
		BTFSS		STATUS, Z
		GOTO		XRF05
		DECF		C05, F
		MOVLW		0X05
		MOVWF		TTD

XRF05		MOVF		C05, W
		RETURN
;---------------------------------------
RUX		MOVWF		XV		    ;GUARDA W EN XV  
		MOVF		XV, F		    ;REVISA EL VALOR DE XV
		BTFSC		STATUS, Z	    ;SI ES 1, SALTA
		GOTO		XR0

		MOVLW		.11		    ;ASIGNA 11 BINARIO A W
		SUBWF		XV,W		    ;OPERACION F - W Y GUARDA EN W (XV - 11)
		BTFSS		STATUS, C
		GOTO		XR1

		MOVLW		.16
		SUBWF		XV, W
		BTFSS		STATUS, C
		GOTO		XR2

		MOVLW		.34
		SUBWF		XV, W
		BTFSS		STATUS, C
		GOTO 		XR3

		MOVLW		.41
		SUBWF		XV, W
		BTFSS		STATUS, C
		GOTO		XR4
		GOTO		XR5
;----------------------
;--------------------------------------	LLAMAR A XR 0,1,2,3,4 Y 5	
;----------------------
XR0		RETLW		0X00

XR1		MOVF		TTD, W
		ADDWF		PCL, F
		NOP
		RETLW		0X02
		RETLW		0X04
		RETLW		0X06
		RETLW		0X08
		RETLW		0X00

XR2		MOVF		TTD, W
		ADDWF		PCL, F
		NOP
		RETLW		0X02
		RETLW		0X04
		RETLW		0X05
		RETLW		0X07
		RETLW		0X09

XR3		MOVF		TTD, W
		ADDWF		PCL, F
		NOP
		RETLW		0X01
		RETLW		0X03
		RETLW		0X05
		RETLW		0X07
		RETLW		0x09

XR4		MOVF		TTD, W
		ADDWF		PCL, F
		NOP
		RETLW		0X01
		RETLW		0X03
		RETLW		0X05
		RETLW		0X06
		RETLW		0X08

XR5		MOVF		TTD, W
		ADDWF		PCL, F
		NOP
		RETLW		0X00
		RETLW		0X02
		RETLW		0X04
		RETLW		0X06
		RETLW		0X08
;--------------------------------------
VALDX		MOVLW		.15		;15 BINARIO
		SUBWF		TTC,W
		BTFSC		STATUS,Z
		GOTO		ERR
		MOVLW		.25		;25 BINARIO
		SUBWF		TTC,W
		BTFSC		STATUS,Z
		GOTO		ERR
		MOVLW		.30		;30 BINARIO
		SUBWF		TTC,W
		BTFSC		STATUS,Z
		GOTO		ERR
		MOVLW		.35		;35 BINARIO
		SUBWF		TTC,W
		BTFSC		STATUS,Z
		GOTO		ERR
		MOVLW		.40		;40 BINARIO
		SUBWF		TTC,W
		BTFSC		STATUS,Z
		GOTO		ERR
		MOVLW		.45		;45 BINARIO
		SUBWF		TTC,W
		BTFSC		STATUS,Z
		GOTO		ERR
		RETURN		

ERR		DECF		DECENAS,F
		RETURN

;-------------------------------------------------------
;-------------------------------------------------------
;------------RETARDO CON TIMER 0------------------------
;-------------------------------------------------------
;-------------------------------------------------------
Ret_TMR0		MOVLW	0X03
			MOVWF	CONTADOR
			CLRF	TMR0
			BTFSS	TMR0,4
			GOTO	$-1
			DECFSZ	CONTADOR,F
			GOTO	$-4
			RETURN
;-------------------------------------------------------
;-------------------------------------------------------
;------------MOSTRAR NUMEROS EN DISPLAYS----------------
;-------------------------------------------------------
;-------------------------------------------------------	
DISPLAY		ADDWF	    PCL,F
		RETLW	    0X3F
		RETLW	    0X06
		RETLW	    0X5B
		RETLW	    0X4F
		RETLW	    0X66
		RETLW	    0X6D
		RETLW	    0X7D
		RETLW	    0X07
		RETLW	    0X7F
		RETLW	    0X67
;----Numeros con punto decimal
DISPLAY2	ADDWF	    PCL,F
		RETLW	    0XBF
		RETLW	    0X86
		RETLW	    0XDB
		RETLW	    0XCF
		RETLW	    0XE6
		RETLW	    0XED

END