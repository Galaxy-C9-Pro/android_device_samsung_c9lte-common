#
# Copyright (C) 2017 The Lineage OS Project
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

# This contains the module build definitions for the hardware-specific
# components for this device.
#
# As much as possible, those components should be built unconditionally,
# with device-specific names to avoid collisions, to avoid device-specific
# bitrot and build breakages. Building a component unconditionally does
# *not* include it on all devices, so it is safe even with hardware-specific
# components.

LOCAL_PATH := $(call my-dir)

ifneq ($(filter c9lte c9ltechn,$(TARGET_DEVICE)),)

include $(call all-makefiles-under,$(LOCAL_PATH))

include $(CLEAR_VARS)

ADSP_IMAGES := \
    adsp.b00 adsp.b01 adsp.b02 adsp.b03 adsp.b04 adsp.b05 adsp.b06 adsp.b07 \
    adsp.b08 adsp.b09 adsp.b10 adsp.b11 adsp.b12 adsp.b13 adsp.b14 adsp.mbn \
    adsp.mdt

ADSP_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/firmware/,$(notdir $(ADSP_IMAGES)))
$(ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "ADSP firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware-modem/image/$(notdir $@) $@

CMN_IMAGES := \
    cmnlib.b00 cmnlib.b01 cmnlib.b02 cmnlib.b03 cmnlib.b04 cmnlib.b05 cmnlib.mdt

CMN_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(CMN_IMAGES)))
$(CMN_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CMN firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@


CMN64_IMAGES := \
    cmnlib64.b00 cmnlib64.b01 cmnlib64.b02 cmnlib64.b03 cmnlib64.b04 cmnlib64.b05 cmnlib64.mdt

CMN64_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(CMN64_IMAGES)))
$(CMN64_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CMN64 firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@
	
CPE_IMAGES := \
    cpe.b02 cpe.b04 cpe.b05 cpe.b06 cpe.b08 cpe.b10 cpe.b11 \
    cpe.b12 cpe.b14 cpe.b16 cpe.b18 cpe.b20 cpe.b21 cpe_9335.b08 \
    cpe_9335.b09 cpe_9335.b11 cpe_9335.b14 cpe_9335.b16 cpe_9335.b18 \
    cpe_9335.b19 cpe_9335.b20 cpe_9335.b22 cpe_9335.b24 cpe_9335.b26 cpe_9335.b28 cpe_9335.b29 \
    cpe.mbn cpe.mdt cpe_9335.mbn cpe_9335.mdt

CPE_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(CPE_IMAGES)))
$(CPE_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CPE firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

IMS_LIBS := libimscamera_jni.so libimsmedia_jni.so

IMS_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR_APPS)/ims/lib/arm64/,$(notdir $(IMS_LIBS)))
$(IMS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "IMS lib link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /system/vendor/lib64/$(notdir $@) $@

ISDB_IMAGES := \
    isdbtmm.b00 isdbtmm.b01 isdbtmm.b02 isdbtmm.b03 isdbtmm.b04 isdbtmm.b05 isdbtmm.b06 isdbtmm.mdt

ISDB_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(ISDB_IMAGES)))
$(ISDB_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "ISDB firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

CARDAPP_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/firmware/,$(notdir $(CARDAPP_IMAGES)))
$(CARDAPP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "CARDAPP firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

MBA_IMAGES := \
    mba.mbn

MBA_SYMLINKS := $(addprefix $(TARGET_OUT_VENDOR)/firmware/,$(notdir $(MBA_IMAGES)))
$(MBA_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "MBA firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware-modem/image/$(notdir $@) $@

MDTP_IMAGES := \
    mdtp.b00 mdtp.b01 mdtp.b02 mdtp.b03 mdtp.b04 mdtp.b05 mdtp.b06 mdtp.mdt

MDTP_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(MDTP_IMAGES)))
$(MDTP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "MDTP firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

MISC_IMAGES := \
    qdsp6m.qdb

MISC_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(MISC_IMAGES)))
$(MISC_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Misc firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware-modem/image/$(notdir $@) $@

MODEM_IMAGES := \
    modem.b00 modem.b01 modem.b02 modem.b04 modem.b05 modem.b06 \
    modem.b07 modem.b08 modem.b09 modem.b10 modem.b11 modem.b12 \
    modem.b13 modem.b16 modem.b17 modem.b18 modem.b19 modem.b20 \
    modem.b21 modem.mdt

MODEM_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(MODEM_IMAGES)))
$(MODEM_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Modem firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware-modem/image/$(notdir $@) $@

WV_IMAGES := \
    widevine.b00 widevine.b01 widevine.b02 widevine.b03 widevine.b04 widevine.b05 \
    widevine.b06 widevine.mdt

WV_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(WV_IMAGES)))
$(WV_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Widevine firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

WCNSS_IMAGES := \
    wcnss.b00 wcnss.b01 wcnss.b02 wcnss.b04 wcnss.b06 \
    wcnss.b09 wcnss.b10 wcnss.b11 wcnss.b12 \
    wcnss.mdt

WCNSS_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(WCNSS_IMAGES)))
$(WCNSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Modem firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@

VENUS_IMAGES := \
    venus-v1.b00 venus-v1.b01 venus-v1.b02 venus-v1.b03 venus-v1.b04 \
    venus-v1.mdt

VENUS_SYMLINKS := $(addprefix $(TARGET_OUT_ETC)/firmware/,$(notdir $(VENUS_IMAGES)))
$(VENUS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Venus firmware link: $@"
	@mkdir -p $(dir $@)
	@rm -rf $@
	$(hide) ln -sf /firmware/image/$(notdir $@) $@
	
RFS_APQ_GNSS_SYMLINKS := $(TARGET_OUT)/rfs/apq/gnss/
$(RFS_APQ_GNSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS APQ GSS folder structure: $@"
	@rm -rf $@
	@mkdir -p $(dir $@)/readonly
	$(hide) ln -sf /data/tombstones/modem $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware $@/readonly/firmware

RFS_MDM_ADSP_SYMLINKS := $(TARGET_OUT)/rfs/mdm/adsp/
$(RFS_MSM_ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MDM ADSP folder structure: $@"
	@rm -rf $@
	@mkdir -p $(dir $@)/readonly
	$(hide) ln -sf /data/tombstones/lpass $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/adsp $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware $@/readonly/firmware

RFS_MDM_MPSS_SYMLINKS := $(TARGET_OUT)/rfs/mdm/mpss/
$(RFS_MSM_MPSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MDM MPSS folder structure: $@"
	@rm -rf $@
	@mkdir -p $(dir $@)/readonly
	$(hide) ln -sf /data/tombstones/modem $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware $@/readonly/firmware

RFS_MDM_SPARROW_SYMLINKS := $(TARGET_OUT)/rfs/mdm/sparrow/
$(RFS_MDM_SPARROW_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MDM SPARROW folder structure: $@"
	@rm -rf $@
	@mkdir -p $(dir $@)/readonly
	$(hide) ln -sf /data/tombstones/modem $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware $@/readonly/firmware

RFS_MSM_ADSP_SYMLINKS := $(TARGET_OUT)/rfs/msm/adsp/
$(RFS_MSM_ADSP_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM ADSP folder structure: $@"
	@rm -rf $@
	@mkdir -p $(dir $@)/readonly
	$(hide) ln -sf /data/tombstones/lpass $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/adsp $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware-modem $@/readonly/firmware

RFS_MSM_MPSS_SYMLINKS := $(TARGET_OUT)/rfs/msm/mpss/
$(RFS_MSM_MPSS_SYMLINKS): $(LOCAL_INSTALLED_MODULE)
	@echo "Creating RFS MSM MPSS folder structure: $@"
	@rm -rf $@
	@mkdir -p $(dir $@)/readonly
	$(hide) ln -sf /data/tombstones/modem $@/ramdumps
	$(hide) ln -sf /persist/rfs/msm/mpss $@/readwrite
	$(hide) ln -sf /persist/rfs/shared $@/shared
	$(hide) ln -sf /persist/hlos_rfs/shared $@/hlos
	$(hide) ln -sf /firmware-modem $@/readonly/firmware

ALL_DEFAULT_INSTALLED_MODULES += $(ADSP_SYMLINKS) $(CMN_SYMLINKS) $(CMN64_SYMLINKS) $(CPE_SYMLINKS) $(ISDB_SYMLINKS) $(IMS_SYMLINKS) $(CARDAPP_SYMLINKS) $(MBA_SYMLINKS) $(MDTP_SYMLINKS) $(MODEM_SYMLINKS) $(MISC_SYMLINKS) $(VENUS_SYMLINKS) $(WCNSS_SYMLINKS) $(WV_SYMLINKS) $(RFS_APQ_GNSS_SYMLINKS) $(RFS_MSM_ADSP_SYMLINKS) $(RFS_MSM_MPSS_SYMLINKS) $(RFS_MSM_MPSS_SYMLINKS) $(RFS_MSM_ADSP_SYMLINKS) $(RFS_MSM_MPSS_SYMLINKS)

endif
