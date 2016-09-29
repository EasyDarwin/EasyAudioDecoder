#include "FFAudioDecoder.h"
#include "libavformat/avformat.h"
#include "libswresample/swresample.h"
#include "libavcodec/avcodec.h"

#define AVCODEC_MAX_AUDIO_FRAME_SIZE	192000

typedef struct{
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    struct SwrContext *au_convert_ctx;
    uint8_t audio_buf[(AVCODEC_MAX_AUDIO_FRAME_SIZE * 3) / 2];
} DFFmpeg;

void *ff_decoder_create(int code, int sample_rate, int channels, int bit_rate)
{
    DFFmpeg *pComponent = (DFFmpeg *)malloc(sizeof(DFFmpeg));
    AVCodec *pCodec = avcodec_find_decoder(code);
    if (pCodec == NULL){
        printf("find audio decoder error, code : %d\r\n",code);
        return 0;
    }
    printf("find audio decoder %s ok.\r\n",avcodec_get_name(code));
    // 创建显示contedxt
    pComponent->pCodecCtx = avcodec_alloc_context3(pCodec);
    pComponent->pCodecCtx->channels = channels;
    pComponent->pCodecCtx->sample_rate = sample_rate;
    pComponent->pCodecCtx->bit_rate = bit_rate;
    pComponent->pCodecCtx->bits_per_coded_sample = 2;
    if(avcodec_open2(pComponent->pCodecCtx, pCodec, NULL) < 0){
        printf("open codec error\r\n");
        return 0;
    }
    
    pComponent->pFrame = av_frame_alloc();
    pComponent->au_convert_ctx = swr_alloc_set_opts(NULL, pComponent->pCodecCtx->channel_layout, AV_SAMPLE_FMT_S16, pComponent->pCodecCtx->sample_rate,
                                                    pComponent->pCodecCtx->channel_layout, pComponent->pCodecCtx->sample_fmt, pComponent->pCodecCtx->sample_rate, 0, NULL);
    swr_init(pComponent->au_convert_ctx);
    return (void *)pComponent;
}

int ff_decode_frame(void *pParam, unsigned char *pData, int nLen, unsigned char *pPCM, unsigned int *outLen)
{
    int pkt_pos=0;
    int src_len=0;
    int dst_len=0;
    DFFmpeg *pComponent = (DFFmpeg *)pParam;
    AVPacket packet;
    av_init_packet(&packet);
    packet.size = nLen;
    packet.data = pData;
    
    while(pkt_pos < nLen){
        int got_frame = 0;
        src_len = avcodec_decode_audio4(pComponent->pCodecCtx, pComponent->pFrame, &got_frame, &packet);
        if (src_len < 0){
            printf("avcodec_decode_audio4 error\r\n");
            return -3;
        }
        
        if (got_frame){
            uint8_t *out[] = {pComponent->audio_buf};
            int needed_buf_size = av_samples_get_buffer_size(NULL, pComponent->pCodecCtx->channels, pComponent->pFrame->nb_samples, AV_SAMPLE_FMT_S16, 1);
            int len = swr_convert(pComponent->au_convert_ctx, out, needed_buf_size, (const uint8_t **)pComponent->pFrame->data, pComponent->pFrame->nb_samples);
            if (len > 0){
                len = len * pComponent->pCodecCtx->channels * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16);
                memcpy(pPCM+dst_len, pComponent->audio_buf, len);
            }
            dst_len += len;
        }
        
        pkt_pos += src_len;
        packet.data = pData + pkt_pos;
        packet.size = nLen - pkt_pos;
    }
    if (NULL != outLen){
        *outLen = dst_len;
    }
    av_free_packet(&packet);
    return (dst_len>0)?0:-1;
}

void ff_decode_close(void *pParam)
{
    DFFmpeg *pComponent = (DFFmpeg *)pParam;
    if (pComponent == NULL){
        return;
    }
    
    swr_free(&pComponent->au_convert_ctx);
    
    if (pComponent->pFrame != NULL){
        av_frame_free(&pComponent->pFrame);
        pComponent->pFrame = NULL;
    }
    
    if (pComponent->pCodecCtx != NULL){
        avcodec_close(pComponent->pCodecCtx);
        avcodec_free_context(&pComponent->pCodecCtx);
        pComponent->pCodecCtx = NULL;
    }
    
    free(pComponent);
}
