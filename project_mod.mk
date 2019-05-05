# Common build rules and properties for reactor modules
include $(BASE)/project/init.mk

SRC_DIR = $(PROJECT_BASE)/src

PRODUCT_STRING = mod$(NAME)--$(PLATFORM_STRING)

PRODUCT_MOD = $(DIST_DIR)/$(PRODUCT_STRING).a

PRODUCT = $(PRODUCT_MOD)

BUILD_ITEMS += $(PRODUCT)

$(PRODUCT_MOD): $(OBJECTFILES)
	$(AR) $@ $^
	$(RANLIB) $@

include $(SCRIPT_DIR)/project_common.mk
