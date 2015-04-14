# ---------------------------------------------------------------
# the setpath shell function in envsetup.sh uses this to figure out
# what to add to the path given the config we have chosen.
ifeq ($(CALLED_FROM_SETUP),true)

ifneq ($(filter /%,$(HOST_OUT_EXECUTABLES)),)
ABP:=$(HOST_OUT_EXECUTABLES)
else
ABP:=$(PWD)/$(HOST_OUT_EXECUTABLES)
endif

ANDROID_BUILD_PATHS := $(ABP)
ANDROID_PREBUILTS := prebuilt/$(HOST_PREBUILT_TAG)
ANDROID_GCC_PREBUILTS := prebuilts/gcc/$(HOST_PREBUILT_TAG)

# The "dumpvar" stuff lets you say something like
#
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-TARGET_OUT
# or
#     CALLED_FROM_SETUP=true \
#       make -f config/envsetup.make dumpvar-abs-HOST_OUT_EXECUTABLES
#
# The plain (non-abs) version just dumps the value of the named variable.
# The "abs" version will treat the variable as a path, and dumps an
# absolute path to it.
#
dumpvar_goals := \
	$(strip $(patsubst dumpvar-%,%,$(filter dumpvar-%,$(MAKECMDGOALS))))
ifdef dumpvar_goals

  ifneq ($(words $(dumpvar_goals)),1)
    $(error Only one "dumpvar-" goal allowed. Saw "$(MAKECMDGOALS)")
  endif

  # If the goal is of the form "dumpvar-abs-VARNAME", then
  # treat VARNAME as a path and return the absolute path to it.
  absolute_dumpvar := $(strip $(filter abs-%,$(dumpvar_goals)))
  ifdef absolute_dumpvar
    dumpvar_goals := $(patsubst abs-%,%,$(dumpvar_goals))
    ifneq ($(filter /%,$($(dumpvar_goals))),)
      DUMPVAR_VALUE := $($(dumpvar_goals))
    else
      DUMPVAR_VALUE := $(PWD)/$($(dumpvar_goals))
    endif
    dumpvar_target := dumpvar-abs-$(dumpvar_goals)
  else
    DUMPVAR_VALUE := $($(dumpvar_goals))
    dumpvar_target := dumpvar-$(dumpvar_goals)
  endif

.PHONY: $(dumpvar_target)
$(dumpvar_target):
	@echo $(DUMPVAR_VALUE)

endif # dumpvar_goals

ifneq ($(dumpvar_goals),report_config)
PRINT_BUILD_CONFIG:=
endif

endif # CALLED_FROM_SETUP


ifneq ($(PRINT_BUILD_CONFIG),)
HOST_OS_EXTRA:=$(shell python -c "import platform; print(platform.platform())")
$(info ============================================)
$(info   PLATFORM_VERSION_CODENAME=$(PLATFORM_VERSION_CODENAME))
$(info   PLATFORM_VERSION=$(PLATFORM_VERSION))
$(info   SOKP_VERSION=$(SOKP_VERSION))
$(info   TARGET_PRODUCT=$(TARGET_PRODUCT))
$(info   TARGET_BUILD_VARIANT=$(TARGET_BUILD_VARIANT))
$(info   TARGET_BUILD_TYPE=$(TARGET_BUILD_TYPE))
$(info   TARGET_BUILD_APPS=$(TARGET_BUILD_APPS))
$(info   TARGET_ARCH=$(TARGET_ARCH))
$(info   TARGET_ARCH_VARIANT=$(TARGET_ARCH_VARIANT))
$(info   TARGET_CPU_VARIANT=$(TARGET_CPU_VARIANT))
#tobitege: TARGET_GCC_VERSION instead of unused TARGET_TC_ROM:
ifdef TARGET_GCC_VERSION
$(info   TARGET_GCC_VERSION=$(TARGET_GCC_VERSION))
else
$(info   TARGET_GCC_VERSION=4.8)
endif
$(info   TARGET_NDK_GCC_VERSION=$(TARGET_NDK_GCC_VERSION))
$(info   TARGET_TOOLS_PREFIX=$(TARGET_TOOLS_PREFIX))
$(info   TARGET_TOOLCHAIN_ROOT=$(TARGET_TOOLCHAIN_ROOT))
$(info   TARGET_CC=$($(combo_2nd_arch_prefix)TARGET_CC))
ifdef TARGET_TC_KERNEL
$(info   TARGET_TC_KERNEL=$(TARGET_TC_KERNEL))
else
$(info   TARGET_TC_KERNEL DEFAULTING TO "4.8-sm"!)
endif
ifdef GCC_OPTIMIZATION_LEVELS
$(info   GCC_OPTIMIZATION_LEVELS=$(GCC_OPTIMIZATION_LEVELS))
else
$(info   GCC_OPTIMIZATION_LEVELS empty!)
endif
$(info   BUILD_ID=$(BUILD_ID))
$(info   HOST_ARCH=$(HOST_ARCH))
$(info   HOST_OS=$(HOST_OS))
$(info   HOST_OS_EXTRA=$(HOST_OS_EXTRA))
$(info   HOST_BUILD_TYPE=$(HOST_BUILD_TYPE))
$(info   HOST_CC=$(HOST_CC))
$(info   HOST_OUT_EXECUTABLES=$(HOST_OUT_EXECUTABLES))
$(info   OUT_DIR=$(OUT_DIR))

ifdef USE_HOST_4_8
$(info   USE_HOST_4_8=$(USE_HOST_4_8))
else
$(info   USE_HOST_4_8=false)
endif
ifdef SOKP_O3
$(info   SOKP_O3=$(SOKP_O3))
else
$(info   SOKP_O3=false)
endif
ifeq (true,$(SOKP_GRAPHITE))
$(info   SOKP_GRAPHITE=$(SOKP_GRAPHITE))
#$(info   GRAPHITE_FLAGS=$(GRAPHITE_FLAGS))
else
$(info   GRAPHITE_OPTIMIZATIONS=false)
endif
ifdef SOKP_STRICT
$(info   SOKP_STRICT=$(SOKP_STRICT))
else
$(info   SOKP_STRICT=false)
endif
ifdef SOKP_KRAIT
$(info   SOKP_KRAIT=$(SOKP_KRAIT))
else
$(info   SOKP_KRAIT=false)
endif
ifdef SOKP_PIPE
$(info   SOKP_PIPE=$(SOKP_PIPE))
else
$(info   SOKP_PIPE=false)
endif
$(info   HOST_ARCH=$(HOST_ARCH))
$(info   HOST_OS=$(HOST_OS))
$(info   HOST_OS_EXTRA=$(HOST_OS_EXTRA))
$(info   HOST_BUILD_TYPE=$(HOST_BUILD_TYPE))
$(info   BUILD_ID=$(BUILD_ID))
$(info   OUT_DIR=$(OUT_DIR))
ifeq ($(CYNGN_TARGET),true)
$(info   CYNGN_TARGET=$(CYNGN_TARGET))
$(info   CYNGN_FEATURES=$(CYNGN_FEATURES))
endif
ifneq (,$(GCC_OPTIMIZATION_LEVELS))
$(info   SM_AND_VERSION=$(SM_AND_VERSION))
$(info   SM_KERNEL_VERSION=$(SM_KERNEL_VERSION))
ADDITIONAL_BUILD_PROPERTIES += \
    ro.sm.android=$(SM_AND_VERSION) \
    ro.sm.kernel=$(SM_KERNEL_VERSION) \
    ro.sm.flags=$(GCC_OPTIMIZATION_LEVELS)
endif
$(info ============================================)
endif
endif
