ifndef _MODULE_BASE
_MODULE_BASE = 1

mod_deps_base=$(BASE_MODULE_REQUIRES)

BASE_MODULE_REQUIRES=

## module load function
define f_base_init =

endef

.INIT_MODULE_BASE := $(call f_base_init) $(.INIT)

endif
