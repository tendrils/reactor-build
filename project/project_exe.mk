# Common build rules and properties for executable firmware projects
ifndef REACTOR_PROJECT_EXE
REACTOR_PROJECT_EXE = 1

include $(BASE)/project/init.mk

LD_LIBS = $(MODULES) $(PLATFORM_LIB)

PRODUCT_STRING=$(NAME)_$(PLATFORM_STRING)

PRODUCT_ELF=$(DIST_DIR)/$(PRODUCT_STRING).elf

PRODUCT_BIN=$(DIST_DIR)/$(PRODUCT_STRING).bin

PRODUCT=$(PRODUCT_BIN)

include $(SCRIPT_DIR)/project_common.mk

-include $(OBJECTFILES:.o=.d)

$(PRODUCT_ELF): $(OBJECTFILES) $(MODULES) $(PLATFORM_LIB)
#	$(LD) $(OBJECTFILES) $(LDFLAGS) $(ARCHFLAGS) -o $@
	$(call f_action_link, $(OBJECTFILES), $(LD_LIBS), $@)

$(PRODUCT_BIN): $(PRODUCT_ELF)
	$(OBJCOPY) -I elf32-little -O binary $^ $@

endif
