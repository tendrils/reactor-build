ifndef REACTOR_PROJECT_COMMON
REACTOR_PROJECT_COMMON = 1

include $(SCRIPT_DIR)/tasks.mk

include $(MODULE_DIR)/modules.mk

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

#
# build step implementations
#
.build-impl: .build-pre $(BUILDDIR) $(DISTDIR) $(BUILD_ITEMS)

.clean-impl: .clean-pre ;\
    $(call f_action_clean, $(BUILD_DIR))

.clobber-impl: .clobber-pre clean

.all-impl: clean build test

.build-tests-impl: $(PRODUCT) .build-tests-pre

.test-impl: build-tests .test-pre

.help-impl: help-pre

f_do_clean = \
    $(call f_rm,$1)

$(BUILD_DIR): ;\
    $(call f_mkdir,$^)

$(DIST_DIR): ;\
    $(call f_mkdir,$(DIST_DIR))

$(OBJ_DIR): ;\
    $(call f_mkdir,$(OBJ_DIR))

endif
