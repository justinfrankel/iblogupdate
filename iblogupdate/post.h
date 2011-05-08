#ifndef _JNL_HTTPPOST_H_
#define _JNL_HTTPPOST_H_

#define JNL_HTTPPOST_DIV_STRING "_____akjka1111zzzASFIJAHFASJFHASLKFHZI8VZJKZ__________AZZ8530597329562798067FZJXXXX___"

#include "../WDL/queue.h"


static void JNL_HTTP_POST_AddText(WDL_Queue *b, const char *name, const char *value)
{
  char buf[4096];
  snprintf(buf,sizeof(buf),"--" JNL_HTTPPOST_DIV_STRING "\r\n"
              "Content-Disposition: form-data; name=\"%.500s\"\r\n"
                          "\r\n",name);
  b->Add(buf,(int)strlen(buf));
  b->Add(value,(int)strlen(value));
  b->Add("\r\n",2);
}

static void JNL_HTTP_POST_File(WDL_Queue *b, const char *name, const char *fn, const void *data, int data_size)
{
  char buf[4096];
  snprintf(buf,sizeof(buf),"--" JNL_HTTPPOST_DIV_STRING "\r\n"
              "Content-Disposition: form-data; name=\"%.500s\"; filename=\"%.500s\"\r\n"
              "Content-Type: application/octet-stream\r\n"
              "Content-transfer-encoding: binary\r\n"
              "\r\n",name,fn);
  b->Add(buf,(int)strlen(buf));

  b->Add(data,data_size);

  const char *p="\r\n--" JNL_HTTPPOST_DIV_STRING "--\r\n";
  b->Add(p,(int)strlen(p));

}

#endif
