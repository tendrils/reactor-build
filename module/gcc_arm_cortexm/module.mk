ifndef _MODULE_GCC_ARM_CORTEXM
_MODULE_GCC_ARM_CORTEXM = 1

mod_deps_gcc=$(GCC_ARM_CORTEXM_MODULE_REQUIRES)

GCC_ARM_CORTEXM_MODULE_REQUIRES=c_binary

## module lifecycle functions
define f_gcc_arm_cortexm_init =
    $(call f_define_c_toolchain,$(GCC_TOOLCHAIN_NAME))
endef

GCC_TARGET_ARCH=arm-none-eabi

GCC_ARM_CORTEXM_USE_NANO=--specs=nano.specs
GCC_ARM_CORTEXM_USE_SEMIHOST=--specs=rdimon.specs
GCC_ARM_CORTEXM_USE_NOHOST=--specs=nosys.specs

endif
