#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/*
 uri_encode.c - functions for URI percent encoding / decoding
*/

//const char *reserved_chars = "!*'();:@&=+$,/?#[]%";
//

const char *unreserved_chars
  = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~";

// calc a large enough buffer to store encoding
int calc_buffer_size (char *uri)
{
  int buffer_size = strlen(uri) * 3 + 1;
  return buffer_size;
}

// generic percent-encoding algorithm
char *encode (char *uri, const char *special_chars, char *buffer)
{
  int i = 0;
  while (uri[i] != '\0')
  {
    int encode_char = 1;

    int j = 0;
    while (special_chars[j] != '\0')
    {
      if (uri[i] == special_chars[j])
      {
        // do not encode char as it is in the special_chars set
        encode_char = 0;
        break;
      }
      j++;
    }
    if (encode_char == 1)
    {
      // convert bytes to hex
      char code[4];
      unsigned char octet = (unsigned char) uri[i];
      sprintf(code, "%%%02X", octet);
      strcat(buffer, code);
    }
    else
    {
      char code[2];
      code[0] = uri[i];
      code[1] = '\0';
      strcat(buffer, code);
    }
    i++;
  }
  return buffer;
}

char *decode (char *uri, char *buffer)
{
  int i = 0;

  while(uri[i] != '\0')
  {
    if(uri[i] == '%')
    {
      i++;
      char code[3];
      code[0] = uri[i++];
      code[1] = uri[i++];
      code[2] = '\0';

      int decimal = (int)strtol(code, NULL, 16);

      char decode[2];
      decode[0] = decimal;
      decode[1] = '\0';
      strcat(buffer, decode);
    }
    else
    {
      char code[2];
      code[0] = uri[i++];
      code[1] = '\0';
      strcat(buffer, code);
    }
  }
  return buffer;
}

char *uri_encode (char *uri, char *buffer)
{
  return encode(uri, unreserved_chars, buffer);
}

char *uri_decode (char *uri, char *buffer)
{
  return decode(uri, buffer);
}

MODULE = URI::Encode::XS      PACKAGE = URI::Encode::XS

PROTOTYPES: ENABLED

char *
uri_encode(char *uri)
    CODE:
        if (strlen(uri) == 0)
        {
          croak("uri_encode() requires a scalar argument to encode!");
        }
        char buffer[ calc_buffer_size(uri) ];
        buffer[0] = '\0';
        uri_encode(uri, buffer);
        RETVAL = buffer;
    OUTPUT: RETVAL

