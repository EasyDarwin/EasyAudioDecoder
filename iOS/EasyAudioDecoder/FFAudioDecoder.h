#ifndef FFAudioDecoder_h
#define FFAudioDecoder_h

void *ff_decoder_create(int code, int sample_rate, int channels, int bit_rate);
int ff_decode_frame(void *pParam, unsigned char *pData, int nLen, unsigned char *pPCM, unsigned int *outLen);
void ff_decode_close(void *pParam);

#endif /* FFAudioDecoder_h */
