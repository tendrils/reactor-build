ifndef _MODULE_MODULAR
_MODULE_MODULAR = 1

mod_deps_modular=aggregate

PRODUCT_MODULE_PREFIX=mod
PRODUCT_MODULE_SUFFIX_STATIC=a

SOURCE_MODULE_DIR=$(BASE)/module
SOURCE_MODULE_PATHS=$(wildcard $(SOURCE_MODULE_DIR)/*)
SOURCE_MODULE_NAMES=$(SOURCE_MODULE_PATHS:$(SOURCE_MODULE_DIR)/%=%)
PRODUCT_MODULE_FILES=$(SOURCE_MODULE_NAMES:%=$(PRODUCT_MODULE_PREFIX)%.$(PRODUCT_MODULE_SUFFIX))

SUBPRODUCTS+=$(PRODUCT_MODULE_FILES)

## module load function
define f_modular_init =

endef

endif