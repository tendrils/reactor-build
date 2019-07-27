ifndef _MODULE_GCC_CORTEX_M
_MODULE_GCC_CORTEX_M = 1

mod_deps_gcc_cortex_m=gcc cortex_m

## module lifecycle functions
define f_gcc_cortex_m_init =
    
endef

define f_gcc_cortex_m_toolchain_define =

	$(call f_gcc_toolchain_define,arm-$1-eabi)
	$(call f_gcc_cross_target_set,arm-$1-eabi)
endef

# GCC specs- semihosting is enabled by default
SPEC_NANO=--specs=nano.specs
SPEC_SEMIHOST=--specs=rdimon.specs
SPEC_NOHOST=--specs=nosys.specs

SPEC_HOST=$(SPEC_SEMIHOST)
GCC_SPECS+=$(SPEC_NANO) $(SPEC_HOST)

# C Compiler configuration
CFLAGS+= -Os -flto -ffunction-sections -fdata-sections -ffreestanding $(CORTEXM_GCC_SPEC_NANO) $(CORTEXM_GCC_SPEC_SEMIHOST)

# Linker configuration
LDCONF=sram
GC=--gc-sections
MAP=-Map=$(DISTDIR)/$(PRODUCT_STRING).map
LD_SCRIPT=$(BOARD_DIR)/link_$(LDCONF).ld
LDFLAGS+=-T $(LD_SCRIPT) $(USE_NANO) $(USE_SEMIHOST) 

endif
