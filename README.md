# rssf-projeto

Projeto de RSSF LAB I que implementa uma comunicação entre servidor e cliente de interface gráfica (interação de usuário) com um cliente microcontrolador. 

## Protocolo
 
 The following table describes the protocol used for both clients

|PROTOCOLO     |  VALOR  |  DESCRIÇÃO  |
|--------------|:-------:|:-----------:|
|IDENTIFY      |    1    |Microcontroller Client
|	           |    2    |UI Client
|HANDSHAKE     |    1    |Send Handshake
|LED GET STATE |   0/1   |Get the state value of microcontroller client. The value is not relevant
|LED STATE     |    1    |Led red is on
|              |    2    |Led green is on
|              |    3    |Both led are on
|              |    0    |Both led are off
|LED SET STATE |    1    |Set red led on
|              |    2    |Set green led on
|              |    3    |Set both leds ON
|              |    0    |Set both leds OFF


The following protocol is used only by UI Client

|PROTOCOLO     |  VALOR  |  RETORNO                     |  DESCRIÇÃO  |
|--------------|:-------:|:----------------------------:|:-----------:|
|DEVICES LIST  |    1    | List of Microcontrollers     |Get the list of microcontrollers connected to the server
