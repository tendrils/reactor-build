ifndef _MODULE_AGGREGATE
_MODULE_AGGREGATE = 1

## per-module variables- these are unregistered by the module loader,
## so their values should not be referred to directly
mod_deps_aggregate=$(AGGREGATE_MODULE_REQUIRES)

AGGREGATE_MODULE_REQUIRES=

BUILD_ITEMS += $(SUBPROJECTS)

## module load function
define f_aggregate_init =
    $(call f_init)
endef

.INIT_MODULE_AGGREGATE := $(call f_aggregate_init) $(.INIT)

endif
