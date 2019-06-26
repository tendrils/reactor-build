ifndef _MODULE_GCC_ARM_CORTEXM
_MODULE_GCC_ARM_CORTEXM = 1

mod_deps_gcc_arm_cortexm=gcc arm_cortexm

## module lifecycle functions
define f_gcc_arm_cortexm_init =
    
endef

GCC_CROSS_TARGET=arm-none-eabi

GCC_ARM_CORTEXM_USE_NANO=--specs=nano.specs
GCC_ARM_CORTEXM_USE_SEMIHOST=--specs=rdimon.specs
GCC_ARM_CORTEXM_USE_NOHOST=--specs=nosys.specs

# C Compiler configuration
CFLAGS+= -Os -flto -ffunction-sections -fdata-sections -ffreestanding $(GCC_ARM_CORTEXM_USE_NANO) $(GCC_ARM_CORTEXM_USE_SEMIHOST)

# Linker configuration
LDCONF?=sram
GC=--gc-sections
MAP=-Map=$(DISTDIR)/$(PRODUCT_STRING).map
LD_SCRIPT=$(BOARD_DIR)/link_$(LDCONF).ld
LDFLAGS+=-T $(LD_SCRIPT) $(USE_NANO) $(USE_SEMIHOST) 

endif
