//
extern "C" {
#include "AACDecoder.h"
}
#include <android/log.h>
#undef	LOG_TAG
#define LOG_TAG "AACDecoder"
#define LOGI(...) __android_log_print (ANDROID_LOG_INFO,LOG_TAG,__VA_ARGS__)
#define LOGD(...) __android_log_print (ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

#define AVCODEC_MAX_AUDIO_FRAME_SIZE	192000

typedef struct AACDFFmpeg {
    AVCodecContext *pCodecCtx;
    AVFrame *pFrame;
    struct SwrContext *au_convert_ctx;
    int out_buffer_size;
	uint8_t audio_buf[(AVCODEC_MAX_AUDIO_FRAME_SIZE * 3) / 2];
} AACDFFmpeg;

void *aac_decoder_create(AVCodecID codecid, int sample_rate, int channels, int bit_rate)
{
    AACDFFmpeg *pComponent = (AACDFFmpeg *)malloc(sizeof(AACDFFmpeg));
    AVCodec *pCodec = avcodec_find_decoder(codecid);//AV_CODEC_ID_AAC
    if (pCodec == NULL)
    {
		LOGD("find %d decoder error", codecid);
        return 0;
    }
	LOGD("aac_decoder_create codecid=%d", codecid);
    // 创建显示contedxt
    pComponent->pCodecCtx = avcodec_alloc_context3(pCodec);
    pComponent->pCodecCtx->channels = channels;
    pComponent->pCodecCtx->sample_rate = sample_rate;
    pComponent->pCodecCtx->bit_rate = bit_rate;
    pComponent->pCodecCtx->bits_per_coded_sample = 2;
    LOGI("bits_per_coded_sample:%d",pComponent->pCodecCtx->bits_per_coded_sample);
    if(avcodec_open2(pComponent->pCodecCtx, pCodec, NULL) < 0)
    {
        LOGD("open codec error\r\n");
        return 0;
    }
    
    pComponent->pFrame = av_frame_alloc();
    

    pComponent->au_convert_ctx = swr_alloc_set_opts(NULL, 
			pComponent->pCodecCtx->channel_layout, AV_SAMPLE_FMT_S16, pComponent->pCodecCtx->sample_rate,
			pComponent->pCodecCtx->channel_layout, pComponent->pCodecCtx->sample_fmt, pComponent->pCodecCtx->sample_rate,
			0, NULL);

	swr_init(pComponent->au_convert_ctx);
LOGD("aac_decoder_create end");
    return (void *)pComponent;
}

int aac_decode_frame(void *pParam, unsigned char *pData, int nLen, unsigned char *pPCM, unsigned int *outLen)
{
	int pkt_pos=0;
	int src_len=0;
	int dst_len=0;
	int data_size=0;
    AACDFFmpeg *pAACD = (AACDFFmpeg *)pParam;
    AVPacket packet;
    av_init_packet(&packet);
// LOGD("aac_decode_frame nLen=%d", nLen);
    packet.size = nLen;
    packet.data = pData;
    
    int got_frame = 0;

	while (pkt_pos < nLen)
	{
	//	pkt_pos = 0;
		int got_frame = 0;
		src_len = avcodec_decode_audio4(pAACD->pCodecCtx, pAACD->pFrame, &got_frame, &packet);
		if (src_len < 0)
		{
			return -3;
		}

		if (got_frame)
		{
			uint8_t *out[] = {pAACD->audio_buf};

			int needed_buf_size = av_samples_get_buffer_size(NULL, pAACD->pCodecCtx->channels, pAACD->pFrame->nb_samples, AV_SAMPLE_FMT_S16, 1);

			int len = swr_convert(pAACD->au_convert_ctx, out, needed_buf_size, (const uint8_t **)pAACD->pFrame->data, pAACD->pFrame->nb_samples);
			if (len > 0)
			{
				len = len * pAACD->pCodecCtx->channels * av_get_bytes_per_sample(AV_SAMPLE_FMT_S16);
				//soundFile.Write((unsigned char *)audio_buf,  len);
				memcpy(pPCM+dst_len, pAACD->audio_buf, len);
			}

			dst_len += len;
		}

		pkt_pos += src_len;
		packet.data = pData + pkt_pos;
		packet.size = nLen - pkt_pos;
	}

	if (NULL != outLen)	
		*outLen = dst_len;
	//LOGD("aac_decode_frame outLen=%d", *outLen);
	
    av_free_packet(&packet);
	
    return (dst_len>0)?0:-1;
}

void aac_decode_close(void *pParam)
{
    AACDFFmpeg *pComponent = (AACDFFmpeg *)pParam;
    if (pComponent == NULL)
    {
        return;
    }
    
    swr_free(&pComponent->au_convert_ctx);
    
    if (pComponent->pFrame != NULL)
    {
        av_frame_free(&pComponent->pFrame);
        pComponent->pFrame = NULL;
    }
    
    if (pComponent->pCodecCtx != NULL)
    {
        avcodec_close(pComponent->pCodecCtx);
        avcodec_free_context(&pComponent->pCodecCtx);
        pComponent->pCodecCtx = NULL;
    }
    
    free(pComponent);
}
