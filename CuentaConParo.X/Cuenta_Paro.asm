	    LIST P=16F887
	    INCLUDE <P16F887.INC>
	    
	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	    
	    ORG		0x00
					    ;DEFINICIÓN DE CONSTANTES NUMÉRICAS
NUM_1	    EQU		B'01100000';0x20	    
NUM_2	    EQU		B'11011010';0x21	 
NUM_3	    EQU		B'11110010';0x22	 
NUM_4	    EQU		B'01100110';0x23	 
NUM_5	    EQU		B'10110110';0x24	 
NUM_6	    EQU		B'10111110';0x25	 
NUM_7	    EQU		B'11100000';0x26	 
NUM_8	    EQU		B'11111110';0x27	 	   
NUM_9	    EQU		B'11100110';0x28
NUM_0	    EQU		B'11111100';0x29
					    ;VARIABLES NECESARIAS
VA	    EQU		0x30
VB	    EQU		0x31
VC	    EQU		0x32	    
RET_D	    EQU		0x33
UNIDAD	    EQU		0x34
DECENA	    EQU		0x35
CENTENA	    EQU		0x36
MILLAR	    EQU		0x09	    
TEMP	    EQU		0x38		    ;VARIABLE TEMPORAL PARA LA ASIGNACIÓN DE SEGMENTOS	    
					    ;DESACTIVAR ENTRADAS ANALÓGICAS
	    BSF		STATUS,RP0
	    BSF		STATUS,RP1
	    CLRF	ANSEL
	    CLRF	ANSELH
					    ;DEFINICIÓN DE PUERTOS DIGITALES
	    BSF		STATUS,RP0
	    BCF		STATUS,RP1
	    CLRF	TRISA
	    CLRF	TRISB
	    CLRF	TRISC
	    CLRF	TRISD
	    CLRF	TRISE
	    BCF		STATUS,RP0
	    BCF		STATUS,RP1
					    ;CONDICIONES INICIALES
	    CLRF	UNIDAD
	    CLRF	DECENA
	    CLRF	CENTENA
	    CLRF	MILLAR
	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;----------------- CODIGO PRINCIPAL 
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
	    
CICLO	    MOVLW	0x08		    ;COMIENZA CON UN RETARDO
	    MOVWF	VA
PARTE_A	    MOVLW	0x02;FA
	    MOVWF	VB
PARTE_B	    MOVLW	0x01;F9
	    MOVWF	VC
PARTE_C	    NOP				    ;CODIGO DE BARRIDO DE DISPLAYS
	    
	    CALL	BARRIDO		    ;BARRIDO DE DISPLAYS
	    
	    
	    DECFSZ	VC, F
	    GOTO	PARTE_C
	    DECFSZ	VB, F
	    GOTO	PARTE_B
	    DECFSZ	VA, F
	    GOTO	PARTE_A
	    
	    CALL	ASIGNA		    ;ASIGNACIÓN DE NÚMEROS
	    
	    
	    GOTO	CICLO
	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;-----------------------------ASIGNA---------------------	    
;------------- ASIGNACIÓN DE UNIDADES, DECENAS Y CENTENAS
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------

ASIGNA	    
	    ;PROCESO DE CONTEO
	    INCF	UNIDAD		    ;AUMENTA UNA UNIDAD CADA QUE TERMINA EL CICLO
	    MOVF	UNIDAD, W	    ;GUARDA EN W
	    SUBLW	0x0A		    ;HACE LA OPERACION K - W Y LA GUARDA EN W
	    BTFSS	STATUS, Z	    ;REVISA QUE LA OPERACIÓN ANTERIOR SEA CERO
	    GOTO	C_DECENA	    ;SALTA EL PROCESO DE ACARREO
	    ;ACARREO---------------------------
	    INCF	DECENA		    ;SI ES 1, SE INCREMENTA UNA UNIDAD
	    CLRF	UNIDAD		    ;SE REINICIAN LAS UNIDADES
	    ;-----------------------------------REVISIÓN DE ESTADO
C_DECENA    MOVF	DECENA, W	    ;GUARDA LAS DECENAS EN W
	    SUBLW	0x0A		    ;HACE LA OPERACIÓN K - W Y LA GUARDA EN W
	    BTFSS	STATUS, Z	    ;SI ES 1 SE SALTA UNA INSTRUCCIÓN
	    GOTO	C_CENTENA	    ;SE SALTA AL CONTEO DE CENTENAS
	    ;ACARREO---------------------------
	    INCF	CENTENA		    ;INCREMENTA LAS DECENAS
	    CLRF	DECENA		    ;Y REINICIA EL CONTADOR DE DECENAS
	    ;-----------------------------------REVISIÓN DE ESTADO
C_CENTENA   MOVF	CENTENA, W		    ;GUARDA CENTENA EN W
	    SUBLW	0x0A		    ;HACE LA OPERACIÓN K - W Y LA GUARDA EN W
	    BTFSS	STATUS, Z	    ;REVISA SI HAY UN ACARREO Y SALTA SI NO ES EL CASO
	    GOTO	C_MILLAR	    ;SALTA AL CONTEO DE MILLARES
	    ;ACARREO---------------------------
	    INCF	MILLAR		    ;INCREMENTA 1 A LOS MILLARES
	    CLRF	CENTENA		    ;Y REINICIA EL CONTADOR DE DECENAS
	    ;----------------------------------REVISIÓN DE ESTADO
C_MILLAR    MOVLW	MILLAR		    ;GUARDA MILLAR EN W
	    SUBLW	0x0A		    ;HACE LA OPERACIÓN K - W Y LA GUARDA EN W
	    BTFSS	STATUS, Z	    ;REVISA SI HAY UN ACARREO Y SALTA SI NO ES EL CASO
	    RETURN
	    RETURN
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;----------------------------BARRIDO---------------------	    
;--------------------------------------------------------	    
;----------------- CODIGO PARA EL BARRIDO DE DISPLAYS 
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
	    
BARRIDO	    MOVF	UNIDAD, W	    ;PARTE 1: UNIDADES
	    MOVWF	TEMP
	    CALL	ASIGNA_NUM
	    MOVLW	B'00001000'
	    MOVWF	PORTA
	    CALL	DISPLAY
	    
	    MOVF	DECENA, W	    ;PARTE 2: DECENAS
	    MOVWF	TEMP
	    CALL	ASIGNA_NUM
	    MOVLW	B'00000100'
	    MOVWF	PORTA
	    CALL	DISPLAY
	    
	    MOVF	CENTENA, W	    ;PARTE 3: CENTENAS
	    MOVWF	TEMP
	    CALL	ASIGNA_NUM
	    MOVLW	B'00000010'
	    MOVWF	PORTA
	    CALL	DISPLAY
	    
	    MOVF	MILLAR, W	    ;PARTE 4: MILLARES
	    MOVWF	TEMP
	    CALL	ASIGNA_NUM
	    MOVLW	B'00000001'
	    MOVWF	PORTA
	    CALL	DISPLAY
	    
	    RETURN
	    
	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;-------------------------------DISPLAY------------------	    
;--------------------------------------------------------	    
;----------------- CODIGO PARA EL RETARDO DE LOS DISPLAYS
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
	    
DISPLAY	    MOVLW	0xF0
	    MOVWF	RET_D
ESP_D	    NOP
	    DECFSZ	RET_D, F
	    GOTO	ESP_D
	    RETURN
	    
	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;--------------------------------------------------------	    
;-----------------------ASIGNA NUMERO--------------------	    
;--------------------------------------------------------	    
;----------------- ASIGNACIÓN DE NUMEROS-----------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------	    
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
;--------------------------------------------------------
	    
	    
ASIGNA_NUM  MOVWF	TEMP		;Carga el valor de W en Dígito
	    MOVLW	0x00		;Compara con 0
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 0?
	    GOTO	ENVIA0		;Sí: Envia Dígito
	    
	    MOVLW	0x01		;Compara con 1
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 1?
	    GOTO	ENVIA1		;Sí: Envia Dígito
	    
	    MOVLW	0x02		;Compara con 2
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 2?
	    GOTO	ENVIA2		;Sí: Envia Dígito
	    
	    MOVLW	0x03		;Compara con 3
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 3?
	    GOTO	ENVIA3		;Sí: Envia Dígito
	    
	    MOVLW	0x04		;Compara con 4
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 4?
	    GOTO	ENVIA4		;Sí: Envia Dígito
	    
	    MOVLW	0x05		;Compara con 5
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 5?
	    GOTO	ENVIA5		;Sí: Envia Dígito
	    
	    MOVLW	0x06		;Compara con 6
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 6?
	    GOTO	ENVIA6		;Sí: Envia Dígito
	    
	    MOVLW	0x07		;Compara con 7
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 7?
	    GOTO	ENVIA7		;Sí: Envia Dígito
	    
	    MOVLW	0x08		;Compara con 8
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 8?
	    GOTO	ENVIA8		;Sí: Envia Dígito
	    
	    MOVLW	0x09		;Compara con 9
	    XORWF	TEMP,W		;OPERA W XOR F Y GUARDA EN W
	    BTFSC	STATUS,Z	;Cuenta = 9?
	    GOTO	ENVIA9		;Sí: Envia Dígito
	    CLRF	UNIDAD
	    CLRF	DECENA
	    CLRF	CENTENA
	    CLRF	MILLAR
	    RETURN
ENVIA0
	    MOVLW	NUM_0
	    MOVWF	PORTB
	    RETURN
ENVIA1
	    MOVLW	NUM_1
	    MOVWF	PORTB
	    RETURN
ENVIA2
	    MOVLW	NUM_2
	    MOVWF	PORTB
	    RETURN
ENVIA3
	    MOVLW	NUM_3
	    MOVWF	PORTB
	    RETURN
ENVIA4
	    MOVLW	NUM_4
	    MOVWF	PORTB
	    RETURN
ENVIA5
	    MOVLW	NUM_5
	    MOVWF	PORTB
	    RETURN
ENVIA6
	    MOVLW	NUM_6
	    MOVWF	PORTB
	    RETURN
ENVIA7
	    MOVLW	NUM_7
	    MOVWF	PORTB
	    RETURN
ENVIA8
	    MOVLW	NUM_8
	    MOVWF	PORTB
	    RETURN
ENVIA9
	    MOVLW	NUM_9
	    MOVWF	PORTB	
	    RETURN
	    
	    END