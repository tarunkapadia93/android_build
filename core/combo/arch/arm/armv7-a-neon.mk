# Configuration for Linux on ARM.
# Generating binaries for the ARMv7-a architecture and higher with NEON
#
ARCH_ARM_HAVE_ARMV7A            := true
ARCH_ARM_HAVE_VFP               := true
ARCH_ARM_HAVE_VFP_D32           := true
ARCH_ARM_HAVE_NEON              := true

CORTEX_A15_TYPE := \
	cortex-a15 \
	krait \
	denver

# arm64 doesn't like cortex-a15
ifeq (denver,$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT))
# Export cflags and cpu variant to the kernel.
	export kernel_arch_variant_cflags := -march=armv8-a
endif
ifneq (,$(filter $(CORTEX_A15_TYPE),$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)))
	arch_variant_cflags := -mcpu=cortex-a15
else
ifeq ($(strip $(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)),cortex-a8)
	arch_variant_cflags := -mcpu=cortex-a8
else
ifeq ($(strip $(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)),cortex-a7)
	arch_variant_cflags := -mcpu=cortex-a7
else
	arch_variant_cflags := -march=armv7-a
endif
endif
endif

arch_variant_cflags += \
    -mfloat-abi=softfp \
    -mfpu=neon

# For neon vfpv4 type, override -mfpu=neon with -mfpu=neon-vfpv4
# Have the clang compiler ignore unknow flag option -mfpu=neon-vfpv4
# Once ignored by clang, clang will default back to -mfpu=neon
neon_vfpv4_type := \
	cortex-a15 \
	krait

ifneq ($(filter $(neon_vfpv4_type),$(TARGET_$(combo_2nd_arch_prefix)CPU_VARIANT)),)
arch_variant_cflags += \
    -mfpu=neon-vfpv4
# Export cflags and cpu variant to the kernel.
export kernel_arch_variant_cflags := $(arch_variant_cflags)
endif
