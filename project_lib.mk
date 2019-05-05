# Common build rules and properties for reactor modules
include $(BASE)/project/init.mk

PRODUCT_STRING=lib$(NAME)_$(PLATFORM_STRING)

PRODUCT_LIB=$(DIST_DIR)/$(PRODUCT_STRING).a

PRODUCT=$(PRODUCT_LIB)

$(PRODUCT_LIB): $(OBJECTFILES)
	$(AR) $@ $^
	$(RANLIB) $@

include $(SCRIPT_DIR)/project_common.mk
