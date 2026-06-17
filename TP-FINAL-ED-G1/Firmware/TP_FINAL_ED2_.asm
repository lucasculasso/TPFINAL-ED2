#include <p16f887.inc>
    list p=16f887

    __CONFIG _CONFIG1, _XT_OSC & _WDT_OFF & _PWRTE_ON & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
    __CONFIG _CONFIG2, _BOR40V & _WRT_OFF

    cblock 0x20
        LDRSupIzq     
        LDRSupDer     
        LDRInfIzq     
        LDRInfDer     
        DemoraADC_Var       
        LuzIzq
        LuzDer
        LuzSup
        LuzInf
        
        Display_Estado  
        EjeXDisplay         
        EjeYDisplay         
        
        PWM_Estado      
        ServoXH       
        ServoXL       
        ServoYH       
        ServoYL  
        PosX
        PosY
        Division
        Resto
        
        Bandera_TX
        RegDelay1
        RegDelay2           
    endc

W_Temp      EQU 0X70          
STATUS_Temp EQU 0X71

    ORG 0x00          
    goto INICIO

    ORG 0x04          
    movwf   W_Temp      
    swapf   STATUS, w
    movwf   STATUS_Temp 

    banksel INTCON
    btfsc   INTCON, T0IF
    call    INTERRUPCION_TMR0      

    banksel PIR1
    btfsc   PIR1, TMR1IF
    call    INTERRUPCION_TMR1      

    banksel INTCON
    btfsc   INTCON, RBIF
    call    INTERRUPCION_PORTB

SALIR:
    banksel PORTA
    swapf   STATUS_Temp, w
    movwf   STATUS      
    swapf   W_Temp, f
    swapf   W_Temp, w   
    retfie              

    ORG 0x20
TablaDisplay:
    banksel PCLATH
    clrf    PCLATH
    addwf   PCL, f
    retlw   b'00111111'
    retlw   b'00000110'
    retlw   b'01011011'
    retlw   b'01001111'
    retlw   b'01100110'
    retlw   b'01101101'
    retlw   b'01111101'
    retlw   b'00000111'
    retlw   b'01111111'
    retlw   b'01101111'

INICIO:
    banksel ANSEL      
    movlw   b'00001111'
    movwf   ANSEL
    clrf    ANSELH      

    movlw   .50
    movwf   PosX
    movwf   PosY
    
    banksel TRISA       
    movlw   b'00001111'
    movwf   TRISA
    movlw   b'00000001'
    movwf   TRISB
    movlw   b'10000000'
    movwf   TRISC
    clrf    TRISD
    clrf    TRISE

    clrf    ADCON1      

    ;Timer0
    banksel OPTION_REG
    movlw   b'00000011'
    movwf   OPTION_REG

    banksel WPUB
    movlw   b'00000001'
    movwf   WPUB
    
    banksel IOCB
    movlw   b'00000001'
    movwf   IOCB

    ;Configuración de Timer1
    banksel T1CON       
    movlw   b'00000001'
    movwf   T1CON

    ;Configuración UART 9600 baudios
    banksel TXSTA
    movlw   b'00100100'
    movwf   TXSTA
    banksel SPBRG
    movlw   .25
    movwf   SPBRG
    banksel RCSTA
    movlw   b'10010000'
    movwf   RCSTA

    ;Habilitación de interrupciones
    banksel PIE1       
    bsf     PIE1, TMR1IE
    
    banksel INTCON      
    movlw   b'11101000'
    movwf   INTCON

    banksel PORTA
    clrf    PORTA       
    clrf    PORTC
    clrf    PORTD
    clrf    PORTE
    
    clrf    PWM_Estado  
    clrf    Display_Estado
    clrf    Bandera_TX

    movlw   0xFA
    movwf   ServoXH
    movwf   ServoYH
    movlw   0x64
    movwf   ServoXL
    movwf   ServoYL

    movlw   d'5'
    movwf   EjeXDisplay
    movlw   d'5'
    movwf   EjeYDisplay

    banksel PORTA
    goto    BUCLEPPAL   

    ;Bucle principal
BUCLEPPAL:
    call    Leer_Sensores   

    ;Recepción UART
    banksel PIR1
    btfsc   PIR1, RCIF
    call    REVISAR_RECEPCION

    ;Análisis del eje X
    banksel PORTA
    movf    LDRSupIzq, w
    addwf   LDRInfIzq, w
    movwf   LuzIzq          
    
    movf    LDRSupDer, w
    addwf   LDRInfDer, w
    movwf   LuzDer          
    
    movf    LuzIzq, w
    subwf   LuzDer, w       
    
    btfsc   STATUS, Z
    goto    CENTRO_X
    btfsc   STATUS, C
    goto    MOVERDER
    goto    MOVERIZQ

CENTRO_X:
    movlw   .50
    movwf   PosX
    movlw   0xFA
    movwf   ServoXH
    movlw   0x64
    movwf   ServoXL
    goto    TEST_EJEY

MOVERDER:
    call    INCREMENTO_SERVOX
    goto    TEST_EJEY

MOVERIZQ:
    call    DECREMENTO_SERVOX
    goto    TEST_EJEY 

    ;Análisis del eje Y
TEST_EJEY:
    movf    LDRSupIzq, W
    addwf   LDRSupDer, W
    movwf   LuzSup          
    
    movf    LDRInfIzq, W
    addwf   LDRInfDer, W
    movwf   LuzInf          
    
    movf    LuzSup, W
    subwf   LuzInf, W       
    
    btfsc   STATUS, Z
    goto    CENTRO_Y
    btfsc   STATUS, C
    goto    MoverAbajo
    goto    MoverArriba
    
CENTRO_Y:
    movlw   .50
    movwf   PosY
    movlw   0xFA
    movwf   ServoYH
    movlw   0x64
    movwf   ServoYL
    goto    FinComparacion

MoverAbajo:
    call    DECREMENTO_SERVOY
    goto    FinComparacion

MoverArriba:
    call    INCREMENTO_SERVOY
    goto    FinComparacion

    ;Actualización de displays
FinComparacion:
    movf    PosX, w
    call    EscalaDisplay
    movwf   EjeXDisplay
    
    movf    PosY, w
    call    EscalaDisplay
    movwf   EjeYDisplay

    ;Transmisión UART
    banksel Bandera_TX
    movf    Bandera_TX, w
    xorlw   .1
    btfss   STATUS, Z
    goto    CONTINUAR_BUCLE

    clrf    Bandera_TX

    movlw   'X'
    call    ENVIAR_SERIAL
    movlw   ':'
    call    ENVIAR_SERIAL
    movf    EjeXDisplay, w
    addlw   .48
    call    ENVIAR_SERIAL

    movlw   ' '
    call    ENVIAR_SERIAL

    movlw   'Y'
    call    ENVIAR_SERIAL
    movlw   ':'
    call    ENVIAR_SERIAL
    movf    EjeYDisplay, w
    addlw   .48              
    call    ENVIAR_SERIAL

    movlw   0x0D
    call    ENVIAR_SERIAL
    movlw   0x0A
    call    ENVIAR_SERIAL

CONTINUAR_BUCLE:
    call    BucleDemora
    goto    BUCLEPPAL    

    ;Subrutina recepción PC
REVISAR_RECEPCION:
    banksel RCREG
    movf    RCREG, w
    banksel Resto
    movwf   Resto
    
    xorlw   'C'
    btfsc   STATUS, Z
    goto    EJECUTAR_CENTRADO
    
    return

EJECUTAR_CENTRADO:
    movlw   .50
    movwf   PosX
    movwf   PosY
    movlw   0xFA
    movwf   ServoXH
    movwf   ServoYH
    movlw   0x64
    movwf   ServoXL
    movwf   ServoYL
    
    movlw   'O'
    call    ENVIAR_SERIAL
    movlw   'K'
    call    ENVIAR_SERIAL
    movlw   0x0D
    call    ENVIAR_SERIAL
    movlw   0x0A
    call    ENVIAR_SERIAL
    return

    ;Configuración y conversión  ADC
Leer_Sensores:
    banksel ADCON0
    
    movlw   b'01000001' 
    movwf   ADCON0
    call    Demora_ADC
    bsf     ADCON0, 1
DEMORA_AN0:
    btfsc   ADCON0, 1
    goto    DEMORA_AN0
    movf    ADRESH, w
    movwf   LDRSupIzq
    
    movlw   b'01000101'
    movwf   ADCON0
    call    Demora_ADC
    bsf     ADCON0, 1
DEMORA_AN1:
    btfsc   ADCON0, 1
    goto    DEMORA_AN1
    movf    ADRESH, w
    movwf   LDRSupDer
    
    movlw   b'01001001'
    movwf   ADCON0
    call    Demora_ADC
    bsf     ADCON0, 1
DEMORA_AN2:
    btfsc   ADCON0, 1
    goto    DEMORA_AN2
    movf    ADRESH, w
    movwf   LDRInfIzq
    
    movlw   b'01001101'
    movwf   ADCON0
    call    Demora_ADC
    bsf     ADCON0, 1
DEMORA_AN3:
    btfsc   ADCON0, 1
    goto    DEMORA_AN3
    movf    ADRESH, w
    movwf   LDRInfDer
    return

Demora_ADC:
    movlw   d'20'
    movwf   DemoraADC_Var
BUCLE_DEMORA_ADC:
    decfsz  DemoraADC_Var, f
    goto    BUCLE_DEMORA_ADC
    return

    ;Interrupción Timer1, para servos
INTERRUPCION_TMR1:
    banksel PIR1
    bcf     PIR1, TMR1IF    
    movf    PWM_Estado, w
    xorlw   d'0'
    btfsc   STATUS, Z
    goto    Estado0          
    movf    PWM_Estado, w
    xorlw   d'1'
    btfsc   STATUS, Z
    goto    Estado1          
    goto    Estado2          

    ;Estado 0: pulso Servo X
Estado0:
    banksel PORTC
    bsf     PORTC, 2
    movf    ServoXH, w
    movwf   TMR1H           
    movf    ServoXL, w
    movwf   TMR1L           
    movlw   d'1'
    movwf   PWM_Estado      
    return

    ;Estado 1: pulso Servo Y
Estado1:
    banksel PORTC
    bcf     PORTC, 2
    bsf     PORTC, 1
    movf    ServoYH, w
    movwf   TMR1H
    movf    ServoYL, w
    movwf   TMR1L
    movlw   d'2'
    movwf   PWM_Estado      
    return

    ;Estado 2: Espera
Estado2:
    banksel PORTC
    bcf     PORTC, 1
    movlw   0xBD
    movwf   TMR1H
    movlw   0x98
    movwf   TMR1L
    clrf    PWM_Estado      
    return

    ;Interrupción Timer0, para displays
INTERRUPCION_TMR0:
    banksel INTCON
    bcf     INTCON, T0IF
    
    banksel PORTE
    bcf     PORTE, 0
    bcf     PORTE, 1
    
    banksel Display_Estado
    movf    Display_Estado, W
    xorlw   .1              
    btfsc   STATUS, Z
    goto    DispEjeY
    
DispEjeX:
    movf    EjeXDisplay, W  
    call    TablaDisplay
    banksel PORTD
    movwf   PORTD           
    banksel PORTE
    bsf     PORTE, 0
    
    banksel Display_Estado
    movlw   .1
    movwf   Display_Estado
    return

DispEjeY:
    movf    EjeYDisplay, w  
    call    TablaDisplay
    banksel PORTD
    movwf   PORTD           
    banksel PORTE
    bsf     PORTE, 1
    
    banksel Display_Estado
    clrf    Display_Estado
    return
 
    ;Interrupción por cambio en RB0
INTERRUPCION_PORTB:
    banksel PORTB
    movf    PORTB, w
    banksel INTCON
    bcf     INTCON, RBIF    
    
    banksel PORTB
    btfss   PORTB, 0
    goto    SeteoBandera
    return

SeteoBandera:
    movlw   .1
    movwf   Bandera_TX
    return

    ;Posición Servo X
INCREMENTO_SERVOX:
    movf    PosX, w
    xorlw   .99     
    btfsc   STATUS,  Z
    return 
    movlw   .10
    subwf   ServoXL, f
    btfss   STATUS,  C
    decf    ServoXH, f
    incf    PosX,  f
    return

DECREMENTO_SERVOX:
    movf    PosX, w
    xorlw   .0              
    btfsc   STATUS,  Z
    return 
    movlw   .10
    addwf   ServoXL, f
    btfsc   STATUS,  C
    incf    ServoXH, f
    decf    PosX,   f
    return

    ;Posición Servo Y
INCREMENTO_SERVOY:
    movf    PosY, w
    xorlw   .99
    btfsc   STATUS,  Z
    return 
    movlw   .10
    subwf   ServoYL, f
    btfss   STATUS,  C
    decf    ServoYH, f
    incf    PosY,  f
    return

DECREMENTO_SERVOY:
    movf    PosY, w         
    xorlw   .0
    btfsc   STATUS,  Z
    return 
    movlw   .10
    addwf   ServoYL,  f
    btfsc   STATUS,   C
    incf    ServoYH,  f
    decf    PosY,     f
    return

    ;Escalado para display
EscalaDisplay:
    clrf    Division
    movwf   Resto

BucleDivision:
    movlw   .10
    subwf   Resto,   w
    btfss   STATUS,  C
    goto    FinDiv
    movwf   Resto
    incf    Division, f
    goto    BucleDivision

FinDiv:
    movf    Division, w
    return

    ;Demora bucle principal
BucleDemora:
    movlw   .25              
    movwf   RegDelay1

L_D1:
    movlw   .255
    movwf   RegDelay2

L_D2:
    decfsz  RegDelay2, f
    goto    L_D2
    decfsz  RegDelay1, f
    goto    L_D1
    return

    ;Datos por UART
ENVIAR_SERIAL:
    banksel PIR1
EsperaUART:
    btfss   PIR1, TXIF
    goto    EsperaUART
    banksel TXREG
    movwf   TXREG
    return
    
    END