ifndef _MODULE_AGGREGATE
_MODULE_AGGREGATE = 1

mod_deps_aggregate=

SUBPROJECTS=$(SUBPROJECT_DIRS:modules/=)

BUILD_ITEMS += $(SUBPRODUCTS)

## module load function
define f_aggregate_init =

endef

endif
