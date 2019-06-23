ifndef _MODULE_GCC_EXECUTABLE
_MODULE_GCC_EXECUTABLE = 1

## per-module variables- these are unregistered by the module loader,
## so their values should not be referred to directly
MODULE_REQUIRES=$(GCC_EXECUTABLE_MODULE_REQUIRES)

GCC_EXECUTABLE_MODULE_REQUIRES=gcc c_binary c_executable

## module load function
define f_gcc_executable_init =
    $(call f_define_)
endef

# Use newlib-nano. To disable it, specify USE_NANO=
USE_NANO=--specs=nano.specs

# Use semihosting or not
USE_SEMIHOST=--specs=rdimon.specs
USE_NOHOST=--specs=nosys.specs

TARGET?=arm-none-eabi

ifdef TARGET
    XC_PREFIX=$(TARGET)-
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
LDCONF?=sram
GC=--gc-sections
MAP=-Map=$(DISTDIR)/$(PRODUCT_STRING).map
LD_SCRIPT=$(BOARD_DIR)/link_$(LDCONF).ld
LIBFLAGS=$(MODFLAGS) $(PLATFORM_LIBFLAGS)
LDFLAGS=$(USE_NANO) $(USE_SEMIHOST) $(PLATFORM_FLAGS) -L $(DISTDIR) -T $(LD_SCRIPT) -Wl,$(GC) -Wl,$(MAP) $(LIBFLAGS)

# C Compiler configuration
C_INCLUDES+=-Iinclude -I$(CONF_DIR) $(PLATFORM_INCLUDES)
CFLAGS+=-c -Os -flto -ffunction-sections -fdata-sections -ffreestanding $(USE_NANO) $(USE_SEMIHOST) $(PLATFORM_FLAGS) $(C_INCLUDES) 
CXXFLAGS=$(CFLAGS)

.INIT_MODULE_GCC := $(call f_gcc_init) $(.INIT)

endif
