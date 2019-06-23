ifndef _MODULE_C
_MODULE_C = 1

## per-module variables- these are unregistered by the module loader,
## so their values should not be referred to directly
mod_deps_c=$(C_MODULE_REQUIRES)

C_MODULE_REQUIRES=

## module load function
define f_c_init =

endef

endif
