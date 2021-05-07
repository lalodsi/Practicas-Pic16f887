	    LIST P=16F887
	    INCLUDE <P16F887.INC>
	    
	    __CONFIG    _CONFIG1, _LVP_OFF & _FCMEN_ON & _IESO_OFF & _BOR_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT
	    __CONFIG    _CONFIG2, _WRT_OFF & _BOR21V


	    ORG		0x00
	    ;
	    ; Configuración de puertos de entrada/salida
	    ;	Puerto E como entradas analógicas (5,6,7)
	    ;	Puerto B como salidas digitales
	    ;	Puerto A como entradas digitales
	    ;	Los demás puestos no importan
	    BSF		STATUS, RP0
	    BCF		STATUS, RP1 ;BANCO1
	    MOVLW	0xFF
	    MOVWF	TRISA	;PUERTO A COMO ENTRADA
	    CLRF	TRISB
	    CLRF	TRISC
	    CLRF	TRISD
	    MOVWF	TRISE	;PUERTO E COMO ENTRADA
	    ;
	    ;CONFIGURACIÓN DE PUERTOS ANALOGICOS
	    ;
	    BSF		STATUS, RP0
	    BSF		STATUS, RP1;BANCO 3
	    MOVLW	B'11100000'
	    MOVWF	ANSEL
	    CLRF	ANSELH
	    ;
	    ;CONFIGURACIÓN DE FUNCIONAMIENTO DEL CONVERSOR A/D
	    ;
	    BCF		STATUS, RP0
	    BCF		STATUS, RP1
	    MOVLW	B'11010101'
	    MOVWF	ADCON0
	    BSF		STATUS, RP0
	    BCF		STATUS, RP1
	    CLRF	ADCON1
	    BCF		STATUS, RP0
	    BCF		STATUS, RP1
	    ;
	    ;CICLO PRINCIPAL
	    ;
	    ;CALL	DELAY
CICLO	    BSF		ADCON0,GO;COMIENZA A CONVERTIR
	    BTFSC	ADCON0,GO;REVISA SI TERMINÓ DE CONVERTIR
	    GOTO	$-1
	    MOVF	ADRESH, W
	    MOVWF	PORTB
	    GOTO	CICLO
	    
	    END