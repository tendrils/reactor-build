ifndef _MODULE_GCC
_MODULE_GCC = 1

mod_deps_gcc=$(GCC_MODULE_REQUIRES)

GCC_MODULE_REQUIRES=c_binary

## module lifecycle functions
define f_gcc_init =
    $(call f_define_c_toolchain,$(GCC_TOOLCHAIN_NAME))
endef

ifdef GCC_CROSS_TARGET
    XC_PREFIX=$(GCC_CROSS_TARGET)-
endif

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
