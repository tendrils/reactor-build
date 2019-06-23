# Common build rules and properties for executable firmware projects
ifndef REACTOR_PROJECT_GEM
REACTOR_PROJECT_GEM = 1

include $(BASE)/script/project/init.mk

PRODUCT_STRING=$(NAME)_$(PLATFORM_STRING)

PRODUCT_GEM=$(DIST_DIR)/$(PRODUCT_STRING).gem

PRODUCT=$(PRODUCT_GEM)

include $(SCRIPT_DIR)/project_common.mk

$(PRODUCT_GEM): $(PLATFORM_LIB)
#	$(LD) $(OBJECTFILES) $(LDFLAGS) $(ARCHFLAGS) -o $@
	$(call f_action_invoke_rake)

endif
