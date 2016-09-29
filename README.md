## EasyAudioDecoder ##

**EasyAudioDecoder** 是EasyDarwin开源流媒体服务团队整理、开发的一款音频转码到Linear PCM的工具库，目前支持G.711A/PCMA、G.711U/PCMU、G726、AAC音频格式的转码，跨平台，支持Android & iOS；

### Android AudioCodec库说明

 1. 该工程（Android目录下的工程）为Android的NDK工程。安装android ndk，cd到jni目录，执行ndk-build；
 2. ffmpeg静态库已经编译ok，其中.h、.a文件位于ffmpeg/armeabi-v7a目录下；
 3. 该工程实际上是对于ffmpeg库的封装，具体实现见AACDecode.cpp文件；
 4. 库工程仅编译了armeabi-v7a版本，如需其他abi版本，可自己编译ffmpeg,参考[EasyPlayer Android音频解码库（第一部分，ffmpeg-android的编译](http://blog.csdn.net/jyt0551/article/details/52519096#0-qzone-1-94593-d020d2d2a4e8d1a374a433f596ad1440)，把对应abi的版本拷贝至ffmpeg目录下面，在Application.mk里增加改abi，再编译;
 5.  对应的java文件为AudioCodec.java
 
 ### iOS EasyAudioDecoder库说明
 
 1.该工程(iOS目录下的工程)为 xcode 的 framework 工程.双击 `EasyAudioDecoder.xcodeproj` 即可用 xcode 打开工程;
 2.ffmpeg 静态库已经编译 ok,在 iOS 目录下,同时支持真机和模似器;
 3.该工程实际上是对于 ffmpeg 库的封装,具体实现见 FFAudioDecoder.m 文件;
 4.使用该库的时候,引入头文件`EasyAudioDecoder.h`, API非常简单:`EasyAudioDecodeCreate`,`EasyAudioDecode`,`EasyAudioDecodeClose`分别表示创建解码器,解码,销毁解码器

## 调用示例 ##

- **testEasyAudioDecoderr**：通过EasyAudioDecoderAPI对G711A/G711U/G726/AAC进行转码；

- **ARM版本的EasyAudioDecoder库可自行编译**；

## 调用过程 ##
![](http://www.easydarwin.org/skin/easydarwin/images/easyaudiodecoder20160910.png)

## 获取更多信息 ##

邮件：[support@easydarwin.org](mailto:support@easydarwin.org) 

WEB：[www.EasyDarwin.org](http://www.easydarwin.org)

Copyright &copy; EasyDarwin.org 2012-2016

![EasyDarwin](http://www.easydarwin.org/skin/easydarwin/images/wx_qrcode.jpg)
