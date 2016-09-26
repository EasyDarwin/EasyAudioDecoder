# Copyright (C) 2009 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
LOCAL_PATH:= $(call my-dir)
SRC_ROOT_PATH := $(call my-dir)
LOCAL_INCLUDE := $(LOCAL_PATH)/aacdec/include

include $(CLEAR_VARS)
LOCAL_MODULE := libavcodec
LOCAL_SRC_FILES := $(LOCAL_PATH)/aacdec/lib/libavcodec.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libavdevice
LOCAL_SRC_FILES := $(LOCAL_PATH)/aacdec/lib/libavdevice.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libavfilter
LOCAL_SRC_FILES := $(LOCAL_PATH)/aacdec/lib/libavfilter.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libavformat
LOCAL_SRC_FILES := $(LOCAL_PATH)/aacdec/lib/libavformat.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libavutil
LOCAL_SRC_FILES := $(LOCAL_PATH)/aacdec/lib/libavutil.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libswresample
LOCAL_SRC_FILES := $(LOCAL_PATH)/aacdec/lib/libswresample.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := libswscale
LOCAL_SRC_FILES := $(LOCAL_PATH)/aacdec/lib/libswscale.a
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_C_INCLUDES += $(LOCAL_PATH)
LOCAL_C_INCLUDES += $(LOCAL_INCLUDE)

PROJECT_FILES := $(wildcard $(SRC_ROOT_PATH)/*.cpp)
PROJECT_FILES += $(wildcard $(SRC_ROOT_PATH)/*.c)
PROJECT_FILES += $(wildcard $(SRC_ROOT_PATH)/aacdec/*.cpp)

$(warning $(PROJECT_FILES))
PROJECT_FILES := $(PROJECT_FILES:$(LOCAL_PATH)/%=%)
$(warning $(PROJECT_FILES))
LOCAL_SRC_FILES := $(PROJECT_FILES)

LOCAL_CFLAGS := -D__unix__ -DANDROID_OS	-D__arm__ -D__STDC_CONSTANT_MACROS

LOCAL_MODULE    := AudioCodecer

LOCAL_LDLIBS += -L$(LOCAL_PATH)/aacdec/lib -lavcodec -lswscale -lswresample -lavutil -lavformat -lavfilter -lavdevice -llog -lz

CFLAGS += -mfpu=neon

LOCAL_STATIC_LIBRARIES := libavcodec libswscale libswresample libavutil libavformat libavfilter libavdevice

include $(BUILD_SHARED_LIBRARY)
