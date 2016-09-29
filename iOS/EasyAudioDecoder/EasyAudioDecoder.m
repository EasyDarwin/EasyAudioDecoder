#import <Foundation/Foundation.h>
#include "EasyAudioDecoder.h"
#include "EasyTypes.h"
#include "g711.h"
#include "FFAudioDecoder.h"

#include "libavutil/opt.h"
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"
#include "libswresample/swresample.h"

EasyAudioHandle* EasyAudioDecodeCreate(int code, int sample_rate, int channels, int sample_bit){
    EasyAudioHandle *pHandle = malloc(sizeof(EasyAudioHandle));
    pHandle->code = code;
    pHandle->pContext = 0;
    if (code == EASY_SDK_AUDIO_CODEC_AAC || code == EASY_SDK_AUDIO_CODEC_G726){
        av_register_all();
        pHandle->pContext = ff_decoder_create(code, sample_rate, channels, sample_bit);
        if(NULL == pHandle->pContext){
            free(pHandle);
            return NULL;
        }
    }
    return pHandle;
}

int EasyAudioDecode(EasyAudioHandle* pHandle, unsigned char* buffer, int offset, int length, unsigned char* pcm_buffer, int* pcm_length){
    int err = 0;
    if (pHandle->code == EASY_SDK_AUDIO_CODEC_AAC || pHandle->code == EASY_SDK_AUDIO_CODEC_G726){
        err = ff_decode_frame(pHandle->pContext, (unsigned char *)(buffer + offset),length, (unsigned char *)pcm_buffer, (unsigned int*)pcm_length);
    }else if (pHandle->code == EASY_SDK_AUDIO_CODEC_G711U){
        short *pOut = (short *)(pcm_buffer);
        unsigned char *pIn = (unsigned char *)(buffer + offset);
        for (int m=0; m<length; m++){
            pOut[m] = ulaw2linear(pIn[m]);
        }
        *pcm_length = length*2;
    }else if (pHandle->code == EASY_SDK_AUDIO_CODEC_G711A){
        short *pOut = (short *)(pcm_buffer);
        unsigned char *pIn = (unsigned char *)(buffer + offset);
        for (int m=0; m<length; m++){
            pOut[m] = alaw2linear(pIn[m]);
        }
        *pcm_length = length*2;
    }
    return err;
}

void EasyAudioDecodeClose(EasyAudioHandle* pHandle){
    if (pHandle->code == EASY_SDK_AUDIO_CODEC_AAC || pHandle->code == EASY_SDK_AUDIO_CODEC_G726){
        ff_decode_close(pHandle->pContext);
    }
    free(pHandle);
}
