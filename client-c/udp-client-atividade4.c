/*
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the Institute nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE INSTITUTE AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE INSTITUTE OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 * This file is part of the Contiki operating system.
 *
 */

#include "contiki.h"
#include "contiki-lib.h"
#include "contiki-net.h"
#include "net/ip/resolv.h"
#include "dev/leds.h"

#include "dev/watchdog.h"

#include "board-peripherals.h"
#include "cc2650/board.h"
#include "gpio.h"

#include "dev/adc-sensor.h"
#include "lib/sensors.h"

#include "button-sensor.h"
#include "lpm.h"

#include "ti-lib.h"

#include <string.h>
#include <stdbool.h>

#define DEBUG DEBUG_PRINT
#include "net/ip/uip-debug.h"

/*-----------------------------------------------------*/
#define IDENTIFY (0x79)
#define LIGHT_UP (0x7A)
#define LIGHT_DOWN (0x7B)
#define LED_STATE (0x7C)
#define SUCCESS (0x7E)
#define LED_GET_STATE (0x7F)

#define OP_REQUEST (0x6E)
#define OP_RESULT (0x6F)
/*-----------------------------------------------------*/

#define SEND_INTERVAL       15 * CLOCK_SECOND
#define MAX_PAYLOAD_LEN     40
#define CONN_PORT     8802
#define MDNS 0

static char buf[MAX_PAYLOAD_LEN];

static struct sensors_sensor *sensor;
static struct uip_udp_conn *client_conn;

#define UIP_UDP_BUF  ((struct uip_udp_hdr *)&uip_buf[UIP_LLH_LEN + UIP_IPH_LEN])
#define UIP_IP_BUF   ((struct uip_ip_hdr *)&uip_buf[UIP_LLH_LEN])

/*---------------------------------------------------------------------------*/
PROCESS(udp_client_process, "UDP client process");
AUTOSTART_PROCESSES(&resolv_process,&udp_client_process);
/*---------------------------------------------------------------------------*/
static void
tcpip_handler(int16_t *loadvalue, int16_t *current_duty, int16_t *ticks)
{
    char *dados;
    if(uip_newdata()) {
        dados = ((char*)uip_appdata);
        switch (dados[0]) {
            case LED_GET_STATE:
                PRINTF("Entrada no LED GET STATE");
                uip_ipaddr_copy(&client_conn->ripaddr, &UIP_IP_BUF->srcipaddr);
                client_conn->rport = UIP_UDP_BUF->destport;

                sensor = sensors_find(ADC_SENSOR);

                buf[0] = SUCCESS;
                //buf[1] = ; //enviar o valor do sensor

                uip_udp_packet_send(client_conn, buf, 2);
                PRINTF("Enviando SUCCESS para [");
                PRINT6ADDR(&client_conn->ripaddr);
                PRINTF("]:%u\n", UIP_HTONS(client_conn->rport));

                break;
            case LIGHT_UP:
                PRINTF("Entrada no LIGHT UP \n");
                uip_ipaddr_copy(&client_conn->ripaddr, &UIP_IP_BUF->srcipaddr);
                client_conn->rport = UIP_UDP_BUF->destport;
                
                if((*current_duty + dados[1]) < 100){
                    *current_duty += dados[1];
                }else {
                    *current_duty = 100;
                }

                *ticks = ((*current_duty) * (*loadvalue)) / 100;
                ti_lib_timer_match_set(GPT0_BASE, TIMER_A, (*loadvalue - *ticks));

                sensor = sensors_find(ADC_SENSOR);
                sensor->configure(ADC_SENSOR_SET_CHANNEL, ADC_COMPB_IN_AUXIO7);

                buf[0] = SUCCESS;
                buf[1] = 1;

                uip_udp_packet_send(client_conn, buf, 2);
                PRINTF("Enviando SUCCESS para [");
                PRINT6ADDR(&client_conn->ripaddr);
                PRINTF("]:%u\n", UIP_HTONS(client_conn->rport));
                break;
            case LIGHT_DOWN:
                PRINTF("Entrada no LIGHT DOWN \n");
                uip_ipaddr_copy(&client_conn->ripaddr, &UIP_IP_BUF->srcipaddr);
                client_conn->rport = UIP_UDP_BUF->destport;

                if((*current_duty - dados[1]) > 0){
                    *current_duty -= dados[1];
                }else {
                    *current_duty = 0;
                }
                *ticks = ((*current_duty) * (*loadvalue)) / 100;
                ti_lib_timer_match_set(GPT0_BASE, TIMER_A, (*loadvalue - *ticks));

                sensor = sensors_find(ADC_SENSOR);
                sensor->configure(ADC_SENSOR_SET_CHANNEL, ADC_COMPB_IN_AUXIO7);

                buf[0] = SUCCESS;
                buf[1] = 1;

                uip_udp_packet_send(client_conn, buf, 2);
                PRINTF("Enviando SUCCESS para [");
                PRINT6ADDR(&client_conn->ripaddr);
                PRINTF("]:%u\n", UIP_HTONS(client_conn->rport));
                break;
        }
    }
    return;
}
/*---------------------------------------------------------------------------*/
static void
timeout_handler(void)
{
    char payload = 0;

    if(uip_ds6_get_global(ADDR_PREFERRED) == NULL) {
      PRINTF("Aguardando auto-configuracao de IP\n");
      return;
    }
    buf[0] = IDENTIFY;
    buf[1] = 1;
    uip_udp_packet_send(client_conn, buf, 2);

    PRINTF("Cliente para [");
    PRINT6ADDR(&client_conn->ripaddr);
    PRINTF("]:%u\n", UIP_HTONS(client_conn->rport));
}
/*---------------------------------------------------------------------------*/
static void
print_local_addresses(void)
{
  int i;
  uint8_t state;

  PRINTF("Client IPv6 addresses: ");
  for(i = 0; i < UIP_DS6_ADDR_NB; i++) {
    state = uip_ds6_if.addr_list[i].state;
    if(uip_ds6_if.addr_list[i].isused &&
       (state == ADDR_TENTATIVE || state == ADDR_PREFERRED)) {
      PRINT6ADDR(&uip_ds6_if.addr_list[i].ipaddr);
      PRINTF("\n");
    }
  }
}
/*---------------------------------------------------------------------------*/
#if UIP_CONF_ROUTER
static void
set_global_address(void)
{
  uip_ipaddr_t ipaddr;

  uip_ip6addr(&ipaddr, UIP_DS6_DEFAULT_PREFIX, 0xfe80, 0, 0, 0, 0, 0, 0);
  uip_ds6_set_addr_iid(&ipaddr, &uip_lladdr);
  uip_ds6_addr_add(&ipaddr, 0, ADDR_AUTOCONF);
}
#endif /* UIP_CONF_ROUTER */
/*---------------------------------------------------------------------------*/

#if MDNS

static resolv_status_t
set_connection_address(uip_ipaddr_t *ipaddr)
{
#ifndef UDP_CONNECTION_ADDR
#if RESOLV_CONF_SUPPORTS_MDNS
#define UDP_CONNECTION_ADDR       contiki-udp-server.local
#elif UIP_CONF_ROUTER
#define UDP_CONNECTION_ADDR       fd00:0:0:0:0212:7404:0004:0404
#else
#define UDP_CONNECTION_ADDR       fe80:0:0:0:6466:6666:6666:6666
#endif
#endif /* !UDP_CONNECTION_ADDR */

#define _QUOTEME(x) #x
#define QUOTEME(x) _QUOTEME(x)

    resolv_status_t status = RESOLV_STATUS_ERROR;

    if(uiplib_ipaddrconv(QUOTEME(UDP_CONNECTION_ADDR), ipaddr) == 0) {
        uip_ipaddr_t *resolved_addr = NULL;
        status = resolv_lookup(QUOTEME(UDP_CONNECTION_ADDR),&resolved_addr);
        if(status == RESOLV_STATUS_UNCACHED || status == RESOLV_STATUS_EXPIRED) {
            PRINTF("Attempting to look up %s\n",QUOTEME(UDP_CONNECTION_ADDR));
            resolv_query(QUOTEME(UDP_CONNECTION_ADDR));
            status = RESOLV_STATUS_RESOLVING;
        } else if(status == RESOLV_STATUS_CACHED && resolved_addr != NULL) {
            PRINTF("Lookup of \"%s\" succeded!\n",QUOTEME(UDP_CONNECTION_ADDR));
        } else if(status == RESOLV_STATUS_RESOLVING) {
            PRINTF("Still looking up \"%s\"...\n",QUOTEME(UDP_CONNECTION_ADDR));
        } else {
            PRINTF("Lookup of \"%s\" failed. status = %d\n",QUOTEME(UDP_CONNECTION_ADDR),status);
        }
        if(resolved_addr)
            uip_ipaddr_copy(ipaddr, resolved_addr);
    } else {
        status = RESOLV_STATUS_CACHED;
    }

    return status;
}
#endif

/*---------------------------------------------------------------------------*/
PROCESS_THREAD(udp_client_process, ev, data)
{
  static struct etimer et;
  uip_ipaddr_t ipaddr;
  static int16_t current_duty = 0;
  static int16_t loadvalue;
  static int16_t ticks = 0;

  PROCESS_BEGIN();
  PRINTF("UDP client process started\n");

#if UIP_CONF_ROUTER
  //set_global_address();
#endif

  etimer_set(&et, 2*CLOCK_SECOND);
  while(uip_ds6_get_global(ADDR_PREFERRED) == NULL)
  {
      PROCESS_WAIT_EVENT();
      if(etimer_expired(&et))
      {
          PRINTF("Aguardando auto-configuracao de IP\n");
          etimer_set(&et, 2*CLOCK_SECOND);
      }
  }


  print_local_addresses();

#if MDNS
  static resolv_status_t status = RESOLV_STATUS_UNCACHED;
  while(status != RESOLV_STATUS_CACHED) {
    status = set_connection_address(&ipaddr);

    if(status == RESOLV_STATUS_RESOLVING) {
      //PROCESS_WAIT_EVENT_UNTIL(ev == resolv_event_found);
      PROCESS_WAIT_EVENT();
    } else if(status != RESOLV_STATUS_CACHED) {
      PRINTF("Can't get connection address.\n");
      PROCESS_YIELD();
    }
  }
#else
  //c_onfigures the destination IPv6 address
  //fe80::c6e3:f15f:76b7:31ca
  //2804:14c:8786:8166:d853:f44f:43ae:918c
  //2804:14c:8786:8166:e1d9:8827:9cc2:ff1a
  //2804:14c:8786:8166:212:4b00:f24:e101
  uip_ip6addr(&ipaddr, 0x2804, 0x014c, 0x8786, 0x8166, 0x0212, 0x4b00, 0x0f24, 0xe101);
#endif
  /* new connection with remote host */
  client_conn = udp_new(&ipaddr, UIP_HTONS(CONN_PORT), NULL);
  udp_bind(client_conn, UIP_HTONS(CONN_PORT));

  PRINT6ADDR(&client_conn->ripaddr);
  PRINTF(" local/remote port %u/%u\n",
    UIP_HTONS(client_conn->lport), UIP_HTONS(client_conn->rport));

  etimer_set(&et, SEND_INTERVAL);

  loadvalue = pwminit(5000);

  while(1) {
    PROCESS_YIELD();
    if(etimer_expired(&et)) {
      timeout_handler();
      etimer_restart(&et);
    } else if(ev == tcpip_event) {
      tcpip_handler(&loadvalue, &current_duty, &ticks);
    }
  }

  PROCESS_END();
}
/*---------------------------------------------------------------------------*/
