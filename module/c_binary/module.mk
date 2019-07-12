ifndef _MODULE_C_BINARY
_MODULE_C_BINARY = 1

mod_deps_c_binary=

C_BINARY_PROJECT_TYPE=

## module load function
define f_c_binary_init =
	$(if C_BINARY_PROJECT_TYPE,,)
endef

endif
