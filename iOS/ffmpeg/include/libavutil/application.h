/*
 * copyright (c) 2016 Zhang Rui
 *
 * This file is part of FFmpeg.
 *
 * FFmpeg is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * FFmpeg is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with FFmpeg; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

#ifndef AVUTIL_APPLICATION_H
#define AVUTIL_APPLICATION_H

#include "libavutil/log.h"

#define AVAPP_EVENT_WILL_HTTP_OPEN  1
#define AVAPP_EVENT_DID_HTTP_OPEN   2
#define AVAPP_EVENT_WILL_HTTP_SEEK  3
#define AVAPP_EVENT_DID_HTTP_SEEK   4

typedef struct AVAppHttpEvent
{
    int      event_type;
    void    *obj;
    char     url[4096];
    int64_t  offset;
    int      error;
    int      http_code;
} AVAppHttpEvent;

#define AVAPP_EVENT_DID_TCP_READ 1

typedef struct AVAppIOTraffic
{
    int     event_type;
    void   *obj;
    int     bytes;
} AVAppIOTraffic;

typedef struct AVApplicationContext AVApplicationContext;
struct AVApplicationContext {
    const AVClass *av_class;    /**< information for av_log(). Set by av_application_open(). */
    void *opaque;               /**< user data. */

    void (*func_did_tcp_connect_ip_port)(AVApplicationContext *h, int error, int family, const char *ip, int port);
    void (*func_on_http_event)(AVApplicationContext *h, AVAppHttpEvent *event);
    void (*func_on_io_traffic)(AVApplicationContext *h, AVAppIOTraffic *event);
};

int  av_application_alloc(AVApplicationContext **ph, void *opaque);
int  av_application_open(AVApplicationContext **ph, void *opaque);
void av_application_close(AVApplicationContext *h);
void av_application_closep(AVApplicationContext **ph);

void av_application_did_tcp_connect_fd(AVApplicationContext *h, int error, int fd);
void av_application_did_tcp_connect_ip_port(AVApplicationContext *h, int error, int family, const char *ip, int port);

void av_application_on_http_event(AVApplicationContext *h, AVAppHttpEvent *event);
void av_application_will_http_open(AVApplicationContext *h, void *obj, const char *url);
void av_application_did_http_open(AVApplicationContext *h, void *obj, const char *url, int error, int http_code);
void av_application_will_http_seek(AVApplicationContext *h, void *obj, const char *url, int64_t offset);
void av_application_did_http_seek(AVApplicationContext *h, void *obj, const char *url, int64_t offset, int error, int http_code);

void av_application_on_io_traffic(AVApplicationContext *h, AVAppIOTraffic *event);
void av_application_did_io_tcp_read(AVApplicationContext *h, void *obj, int bytes);

#endif /* AVUTIL_APPLICATION_H */
