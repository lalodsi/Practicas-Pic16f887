;	    MAESTRO SPI
;	    
;AUTOR: RODRÍGUEZ RAMÍREZ LUIS EDUARDO
;    
;EL OBJETIVO DE ESTE PROYECTO ES ESTABLECER UNA COMUNICACIÓN SPI
;COMO MAESTRO ENVIANDO DATOS A OTRO DISPOSITIVO
	    
	    LIST P=16F887
	    INCLUDE <P16F887.INC>

	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	    
;INICIALIZACIÓN DEL MICROCONTROLADOR
;
;SE ESTABLECERÁ EL ESTADO DE LAS ENTRADAS, SALIDAS Y LOS COMPONENTES
;A UTILIZAR
	    
	    
	    ORG		0x00
	    
AN1	    EQU		0x21
AN2	    EQU		0x22
RET	    EQU		0x23
	    
;-----------ENTRADAS Y SALIDAS--------------------------------------------------
	    BSF		STATUS, RP0	;BANCO 1
	    BCF		STATUS, RP1
	    
	    MOVLW	0x2F		;ESTABLECE EL NIBLE BAJO COMO 0000 0000
	    MOVWF	TRISA		;ENTRADA DIGITAL
	    CLRF	TRISB		;PUERTO B COMO SALIDA DIGITAL
	    MOVLW	B'00010000'	;ESTABLECE LAS LÍNEAS DE COMUNICACIÓN
	    MOVWF	TRISC		;Y DEL RELOJ CORRESPONDIENTES A I/O
	    CLRF	TRISD
	    CLRF	TRISE
	    BSF		TRISE,0		;ENTRADA ANALÓGICA 5
	    
	    MOVLW	B'11010101'		;PREESCALADOR 1:64
	    MOVWF	OPTION_REG		;TIMER 0 COMO TEMPORIZADOR
	    
;------------------------ENTRADAS ANALÓGICAS------------------------------------
	    BCF		STATUS, RP0	;BANCO 0
	    MOVLW	B'11010100'	;ENTRADA ANALÓGICA 5
	    MOVWF	ADCON0		;
	    BSF		STATUS, RP0	;BANCO 1
	    CLRF	ADCON1		;JUSTIFICACION A LA IZQUIERDA
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1
	    MOVLW	B'00100000'	;ENTRADA ANALÓGICA 5
	    MOVWF	ANSEL
	    CLRF	ANSELH	
;----------------------------SALIDA PWM-----------------------------------------
	    BCF		STATUS, RP1
	    BCF		STATUS, RP0	;BANCO 0
	    MOVLW	B'00001100'	;CONFIGURACIÓN PWM
	    MOVWF	CCP1CON		;
	    MOVLW	B'01000000'
	    MOVWF	CCPR1L		;COMIENZA EL PWM AL 50%
;------------------------------TIMER 2------------------------------------------
	    BSF		STATUS, RP0	;BANCO 1
	    MOVLW	0xFF		;
	    MOVWF	PR2		;
	    BCF		STATUS, RP0	;BANCO 0
	    MOVLW	B'00000011'	;
	    MOVWF	T2CON		;
;--------------------------CONFIGURACIÓN SPI------------------------------------
	    MOVLW	B'00110000'	;
	    MOVWF	SSPCON		;HABILIDA EL MODO SPI A FOSC/4
	    BSF		STATUS, RP0	;BANCO 1
	    MOVLW	B'00000000'	;
	    MOVWF	SSPSTAT		;
	    
	    CLRF	PORTA
	    
	    
;   CICLO PRINCIPAL
;
;   OBTENCIÓN DE INFORMACIÓN DEL MEDIO Y ENVÍO POR
;   MEDIO DEL PUERTO SPI
	    
	    
	    ;OBTENER INFORMACIÓN POR MEDIO DEL ADC
CICLO	    BSF		ADCON0,ADON	;PRENDER EL ADC
	    BSF		ADCON0,GO	;COMIENZA LA RECEPCIÓN
	    BTFSC	ADCON0,GO	;PREGUNTA SI YA TERMINÓ LA RECEPCIÓN
	    GOTO	$-1		
	    BCF		ADCON0,ADON	;APARA EL ADC PARA QUE NO OCUPE ENERGÍA
	    MOVF	ADRESH,W	;GUARDA LOS BITS MAS SIGNIFICATIVOS
	    MOVWF	AN1		;EN AN1
	    BSF		STATUS,RP0	;BANCO 1
	    MOVF	ADRESL,W	;GUARDA LOS BITS MENOS SIGNIFICATIVOS
	    BCF		STATUS,RP0	;BANCO 0
	    MOVWF	AN2		;GUARDA LOS BMS EN AN2
	    ;---------------------SPI-------------------------------------------
	    ;ENVIANDO BYTE 1
	    MOVF	AN1, W		;MUEVE AN1 AL REGISTRO W
	    MOVWF	SSPBUF		;ENVIA POR SPI
	    ;ENVIANDO BYTE 2
	    MOVF	AN2, W		;MUEVE AN2 AL REGISTRO W
	    BSF		STATUS,RP0	;BANCO1
	    BTFSS	SSPSTAT, BF	;ESPERA A QUE SE RECIBA EL BIT
	    GOTO	$-1		;
	    BCF		SSPSTAT, BF	;REINICIA EL ESTATUS DEL BUFFER
	    BCF		STATUS,RP0	;BANCO 0
	    MOVWF	SSPBUF		;ENVIA POR SPI
	    ;ENVIANDO BYTE 3
	    BSF		STATUS,RP0	;BANCO1
	    BTFSS	SSPSTAT, BF	;ESPERA A QUE SE RECIBA EL BIT
	    GOTO	$-1		;
	    BCF		SSPSTAT, BF	;REINICIA EL ESTATUS DEL BUFFER
	    BCF		STATUS,RP0	;BANCO 0
	    MOVF	PORTA,W		;CARGA LA INFO DEL PUERTO A
	    MOVWF	SSPBUF		;ENVIA POR SPI
	   ; GOTO	CICLO
	    
	    
	    
	    
	    
	    
	    
	    MOVLW	0x0D;3D			;VALOR PARA EL RETARDO DEFINIDO EXPERIMENTALMENTE
	    MOVWF	RET			;GUARDAR EL VALOR EN EL RETARDO
	    
	    BTFSS	INTCON, 2		;REVISA SI HAY DESBORDAMIENTO
	    GOTO	$-1			;REGRESA 2 INSTRUCCIONES
	    
	    BCF		INTCON, 2		;REINICIA EL DESBORDAMIENTO
	    DECFSZ	RET			;DECREMENTA EL RETARDO
	    GOTO	$-4			;REGRESA HASTA EL LLAMADO DEL BARRIDO (5 INSTRUCCIONES)
	    
	    GOTO CICLO
	    
	    END