# Proyecto: Seguidor de Luz
> **Asignatura:** Electrónica Digital II - Universidad Nacional de Córdoba
## **Integrantes del grupo:**
1) CASTELLANI, Luciano
2) CULASSO, Lucas José
3) RODRIGUEZ MUÑOZ, María Azul
>**Profesor: Marcos Blasco**

## 1. Descripción y propósito del proytecto:
El mismo es un seguidor de luz, compuesto por 4 sensores LDR, 2 servomotores SG90 de 180°, dos displays de 7 segmentos cátodo común y un pulsador.
El objetivo es adquirir las señales de luz captadas por los sensores y dirigir los servomotores hacia la fuente emisora de luz, buscando un balance, al mismo tiempo que se envía la posición de los mismos a los displays. Por otra parte, si es presionado el pulsador, se transmite hacia una PC esa misma posición. Finalmente, si desde la PC es presionada la tecla "C", el sistema retoma la posicion central.
Este proyecto puede ser extrapolable a la instalación de un panel solar que rastree el movimiento del sol.
### Alcances del proyecto:
* **El sistema puede:**
  1) Rastrear una fuente de luz.
  2) Transmitir la posicion de los servomotores a displays.
  3) Transmitir la posicion de los servomotores a PC.
* **El sistema no puede:**
  1) Rastrear luz 360°, en ambos ejes.
  2) Funcionar solamente con la alimentacion vía USB y fuente externa de DC.
### Posibles Etapas Siguientes:
* Armar el circuito en una PCB.
* En caso de llevarse a paneles solares, usar modo de reposo durante la noche.
* Previo al modo reposo del caso previo, cargar baterías.
* Implementar una App Web para seguir el consumo, posición, avisos del sistema.
* Transmitir datos mediante Bluetooth o Wi-Fi.
## 2. Arquitectura del sistema:
### Hardware:
* Esquematico:
  [TPFinalG1.pdf](https://github.com/user-attachments/files/28976402/TPFinalG1.pdf)
  <img width="1023" height="581" alt="Esquematico" src="https://github.com/user-attachments/assets/486fd3d7-e395-427d-854f-300522d7acc9" />


### Software:
* Diagrama de flujo:
  [Diagrama de Flujo TP.pdf](https://github.com/user-attachments/files/29009096/Diagrama.de.Flujo.TP.pdf)
<img width="1280" height="904" alt="WhatsApp Image 2026-06-17 at 17 01 58" src="https://github.com/user-attachments/assets/e35ac8e1-6185-47fa-bc31-ed918050cee0" />
  <img width="904" height="1280" alt="WhatsApp Image 2026-06-17 at 17 01 59 (1)" src="https://github.com/user-attachments/assets/bf7dba3f-75ae-4d71-a7c1-ad832aed215c" />
<img width="904" height="1280" alt="WhatsApp Image 2026-06-17 at 17 01 58 (1)" src="https://github.com/user-attachments/assets/5b5c33bf-b997-48a9-9f44-4ff8cbec28ff" />

<img width="1280" height="904" alt="WhatsApp Image 2026-06-17 at 17 01 59 (2)" src="https://github.com/user-attachments/assets/4f2be8a3-5147-4d2d-8190-0bf9bdec40ea" />

<img width="904" height="1280" alt="WhatsApp Image 2026-06-17 at 17 01 59 (3)" src="https://github.com/user-attachments/assets/ce84ef93-d7e0-4816-962e-1e979886a3e5" />
<img width="904" height="1280" alt="WhatsApp Image 2026-06-17 at 17 01 59" src="https://github.com/user-attachments/assets/0b9a9cb8-b848-4189-8125-5f2d726791eb" />

## 3. Especificaciones:
* **Tensión de alimentación:**
  1) 3.3V para el PIC 16F887.
  2) 5V para los servomotores.
* **Método de alimentación:**
  1) Vía USB para el PIC.
  2) Fuente externa de alimentacion de DC.
### Entorno:
* **Entorno de desarrollo:** MPLAB X IDE v.5.35, compilador XC8.
*  **Hardware de programación:** Conexion directa de TX y RX al PIC, no se utilizó ningún PICKit.
*  **Configuración de Bits:**
    1) *Oscilador:* XT (Cristal Externo de 4MHz)
    2) *Watchdog Timer (WDT):* OFF
    3) *Master Clear (MCLRE):* ON
* Perifericos Internos usasdos:
  1) Timer0
  2) RB0
  3) Timer1
  4) UART
* Prioridad de interrupción: Timer0. Debido a la frecuencia con la que interrumpe.
## 4. Proceso de Integración y Desarrollo:
* Etapa 1: Investigación sobre programacion de servomotores.
* Etapa 2: Implementación del ADC junto con los LDRs.
* Etapa 3: Configuración de puertos.
* Etapa 4: Multiplexacion de displays y mostrar datos.
* Etapa 5: Comunicacion serie con PC.
## 5. Ensayos, Pruebas y Resultados:
* Circuito montado en Protoboard, no 100% completo. Se probó iluminar los LDRs para controlar su correcto funcionamiento:
  
  <img width="500" height="600" alt="IMG_2593" src="https://github.com/user-attachments/assets/f787b5ee-097b-41f4-b4d6-e980924d8201" />
* Proceso de impresión de base de sosten de los servos:
  
  <img width="500" height="600" alt="IMG_2594" src="https://github.com/user-attachments/assets/3d0d443b-e136-4f08-aa2a-ecd16d15b293" />
* Diseño en UltraMaker de base y techo de la estructura:
  
  <img width="600" height="400" alt="image" src="https://github.com/user-attachments/assets/e9c2462d-e325-4437-8fa2-8b359fa8845c" />
* Estructura impresa:
<img width="500" height="600" alt="image" src="https://github.com/user-attachments/assets/a2da1ba4-f32c-4d83-8cd5-238a786fafb0" />


* Montaje final:
<img width="500" height="600" alt="IMG_2599" src="https://github.com/user-attachments/assets/d7e78ff1-32ae-4f6d-b2a1-45e681f8467d" />

* GIF de montaje andando:


https://github.com/user-attachments/assets/c96c9eac-158e-465c-9a23-a8bcdf7dba23



  


