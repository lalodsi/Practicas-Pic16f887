;	    ESCLAVO SPI
;	    
;AUTOR: RODR�GUEZ RAM�REZ LUIS EDUARDO
;    
;EL OBJETIVO DE ESTE PROYECTO ES ESTABLECER UNA COMUNICACI�N SPI
;COMO ESCLAVO INTERCAMBIANDO INFORMACI�N CON UN DISPOSITIVO MAESTRO
	    
	    LIST P=16F887
	    INCLUDE <P16F887.INC>

	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V
	    
;INICIALIZACI�N DEL MICROCONTROLADOR
;
;SE ESTABLECER� EL ESTADO DE LAS ENTRADAS, SALIDAS Y LOS COMPONENTES
;A UTILIZAR
	    
	    
	    ORG		0x00
	    
AN1	    EQU		0x21		;DATOS A ENVIAR
AN2	    EQU		0x22		;DATOS A ENVIAR
RET	    EQU		0x23		;RETARDO PROGRAMADO
SPI_AN1	    EQU		0x24		;DATOS A RECIBIR
SPI_AN2	    EQU		0x25		;DATOS A RECIBIR
SPI_PA	    EQU		0x26		;DATOS A RECIBIR
NUM_DATA    EQU		0x27		;CONTADOR DE RECEPCI�N
	    
;-----------ENTRADAS Y SALIDAS--------------------------------------------------
	    BSF		STATUS, RP0	;BANCO 1
	    BCF		STATUS, RP1
	    
	    MOVLW	0x2F		;ESTABLECE EL NIBLE BAJO COMO 0000 0000
	    MOVWF	TRISA		;ENTRADA DIGITAL
	    CLRF	TRISB		;PUERTO B COMO SALIDA DIGITAL
	    MOVLW	B'00010000'	;ESTABLECE LAS L�NEAS DE COMUNICACI�N
	    MOVWF	TRISC		;Y DEL RELOJ CORRESPONDIENTES A I/O
	    CLRF	TRISD
	    CLRF	TRISE
	    BSF		TRISE,0		;ENTRADA ANAL�GICA 5
	    
;	    MOVLW	B'11010101'	;PREESCALADOR 1:64
;	    MOVWF	OPTION_REG	;TIMER 0 COMO TEMPORIZADOR
	    
;------------------------ENTRADAS ANAL�GICAS------------------------------------
	    BCF		STATUS, RP0	;BANCO 0
	    MOVLW	B'11010100'	;ENTRADA ANAL�GICA 5
	    MOVWF	ADCON0		;
	    BSF		STATUS, RP0	;BANCO 1
	    CLRF	ADCON1		;JUSTIFICACION A LA IZQUIERDA
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1
	    MOVLW	B'00100000'	;ENTRADA ANAL�GICA 5
	    MOVWF	ANSEL
	    CLRF	ANSELH	
;----------------------------SALIDA PWM-----------------------------------------
	    BCF		STATUS, RP1
	    BCF		STATUS, RP0	;BANCO 0
	    MOVLW	B'00001100'	;CONFIGURACI�N PWM
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
;--------------------------CONFIGURACI�N SPI------------------------------------
	    MOVLW	B'00110100'	;MODO ESCLAVO SPI CON SS HABILITADO
	    MOVWF	SSPCON		;
	    BSF		STATUS, RP0	;BANCO 1
	    MOVLW	B'00000000'	;
	    MOVWF	SSPSTAT		;BORRA EL STATUS
	    
	    CLRF	PORTA
	    CLRF	NUM_DATA	;REINICIA EL CONTADOR
;   CICLO PRINCIPAL
;
;   OBTENCI�N DE INFORMACI�N DEL MEDIO Y DEL PUERTO SPI Y ENV�O POR
;   MEDIO DEL MISMO PUERTO
	    
CICLO	    BSF		ADCON0,ADON	;PRENDER EL ADC
	    BSF		ADCON0,GO	;COMIENZA LA RECEPCI�N
	    BTFSC	ADCON0,GO	;PREGUNTA SI YA TERMIN� LA RECEPCI�N
	    GOTO	$-1		
	    BCF		ADCON0,ADON	;APARA EL ADC PARA QUE NO OCUPE ENERG�A
	    MOVF	ADRESH,W	;GUARDA LOS BITS MAS SIGNIFICATIVOS
	    MOVWF	AN1		;EN AN1
	    BSF		STATUS,RP0	;BANCO 1
	    MOVF	ADRESL,W	;GUARDA LOS BITS MENOS SIGNIFICATIVOS
	    BCF		STATUS,RP0	;BANCO 0
	    MOVWF	AN2		;GUARDA LOS BMS EN AN2
	    ;----------------------------SPI------------------------------------
	    BTFSS	SSPSTAT, BF	;
	    GOTO	$-1		;ESPERA EL PRIMER BYTE
	    BCF		SSPSTAT, BF	;PREPARA PARA EL SIGUIENTE BIT
	    MOVF	SSPBUF		;GUARDA EL PRIMER DATO RECIBIDO
	    MOVWF	SPI_AN1		;Y LO GUARDA
	    ;-----------SEGUNDO BYTE
	    BTFSS	SSPSTAT, BF	;
	    GOTO	$-1		;ESPERA EL SEGUNDO BYTE
	    BCF		SSPSTAT, BF	;PREPARA PARA EL SIGUIENTE BIT
	    MOVF	SSPBUF		;GUARDA EL PRIMER DATO RECIBIDO
	    MOVWF	SPI_AN2		;Y LO GUARDA
	    ;-----------TERCER BYTE
	    BTFSS	SSPSTAT, BF	;
	    GOTO	$-1		;ESPERA EL TERCER BYTE
	    BCF		SSPSTAT, BF	;PREPARA PARA EL SIGUIENTE BIT
	    MOVF	SSPBUF		;GUARDA EL PRIMER DATO RECIBIDO
	    MOVWF	SPI_PA		;Y LO GUARDA
	    
	    ;-----------MUESTRA DE DATOS----------------------------------------
	    
	    MOVF	SPI_AN1,W	;MUEVE AN1 AL REGISTRO W
	    MOVWF	CCPR1L		;LO CARGA EN EL PWM
	    MOVF	SPI_AN2,W	;MUEVE AN2 AL REGISTRO W
	    ;ACOMODAR DATOS
	    BCF		STATUS, C	;BORRA C
	    RRF		SPI_AN2,F
	    RRF		SPI_AN2,F	;ROTA 2 VECES AN2 PARA ACOMODARLO
	    MOVLW	0x0C		;AGREGA C PARA NO CAMBIAR LA CONFIGURACI�N PWM
	    IORWF	SPI_AN2,W	;JUNTA LOS BITS Y GUARDA EN W
	    ;DATOS ACOMODADOS
	    MOVWF	CCP1CON		;CARGA LOS BITS AL PWM
	    MOVF	SPI_PA,W	;MUEVE PA A W
	    MOVWF	PORTB		;LO MUESTRA EN EL PUERTO B
	    GOTO	CICLO
	    
	    END