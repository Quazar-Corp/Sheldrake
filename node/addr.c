#define CAML_NAME_SPACE
/* this part implement the OCaml binding */
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <netdb.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

  

CAMLprim value stub_get_global_addr(value unit)
{
    // CAMLlocalN always expected a CAMLparamN before
    CAMLparam1(unit);
    CAMLlocal1(global_addr);   // OCaml local var in C declaration 
    
    char hostbuffer[256];
    char *IPbuffer;
    struct hostent *host_entry;
    int hostname, final_ip_size;
  
    // To retrieve hostname
    hostname = gethostname(hostbuffer, sizeof(hostbuffer));
  
    // To retrieve host information
    host_entry = gethostbyname(hostbuffer);
  
    // To convert an Internet network
    // address into ASCII string
    IPbuffer = inet_ntoa(*((struct in_addr*)
                           host_entry->h_addr_list[0]));

    final_ip_size = strlen(IPbuffer);

    // Check other allocs to successful return the type you need
    global_addr = caml_alloc_string(sizeof(char[final_ip_size]));
    memcpy(String_val(global_addr), IPbuffer, sizeof(char[final_ip_size]));

    CAMLreturn(global_addr);
}
