ifndef _MODULE_GCC
_MODULE_GCC = 1

mod_deps_gcc=c_binary

C_BINARY_PROJECT_TYPE =
C_TOOLCHAIN_PROVIDER =

## module lifecycle functions
define f_gcc_init =

endef

define f_gcc_toolchain_define =
	$(call f_util_set_symbol,GCC_TOOLCHAIN_PROVIDER,$1)
    $(call f_c_binary_toolchain_define,gcc,$(GCC_TOOLCHAIN_PROVIDER))
endef

define f_gcc_cross_target_set =
    $(call f_util_set_symbol,GCC_CROSS_TARGET,$1)
    $(if $(GCC_CROSS_TARGET),\
        $(call f_util_override_set_symbol,XC_PREFIX,$(GCC_CROSS_TARGET)-),)
endef

CC=$(XC_PREFIX)gcc
CXX=$(XC_PREFIX)g++
AS=$(XC_PREFIX)as
LD=$(XC_PREFIX)gcc
OBJCOPY=$(XC_PREFIX)objcopy

LTOFLAG:=--plugin=$(shell $(CC) --print-file-name=liblto_plugin.so)
AR=$(XC_PREFIX)ar qc $(LTOFLAG)
RANLIB=$(XC_PREFIX)ranlib $(LTOFLAG)

# Linker configuration
LIBFLAGS=$(MODFLAGS) $(PLATFORM_LIBFLAGS)
LDFLAGS= -L $(DISTDIR) $(LIBFLAGS)

# C Compiler configuration
C_INCLUDES+=-Iinclude -I$(CONF_DIR) $(PLATFORM_INCLUDES)
CFLAGS+=-c $(C_INCLUDES) 
CXXFLAGS=$(CFLAGS)

endif
