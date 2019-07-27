ifndef _MODULE_C_BINARY
_MODULE_C_BINARY = 1

mod_deps_c_binary=

C_BINARY_PROJECT_TYPE =
C_TOOLCHAIN_PROVIDER =

## module load function
define f_c_binary_init =
	$(call f_define_build_action,compile)
endef

define f_c_binary_toolchain_define =
	$(call f_util_set_symbol,C_TOOLCHAIN_TYPE,$1)
	$(call f_util_set_symbol,C_TOOLCHAIN_ARCH,$2)
	$(call f_util_set_symbol,C_TOOLCHAIN_OS,$3)
	$(call f_util_set_symbol,C_TOOLCHAIN_ABI,$4)
	$(call f_util_set_symbol,C_TOOLCHAIN_ID,$1-$2-$3-$4)
	$(call f_util_log_debug,c-binary,c/c++ toolchain provider registered: $(C_TOOLCHAIN_PROVIDER))
endef

define f_c_binary_command_compile_set =
	$(call f_util_override_set_symbol,f_c_binary_command_compile,$1)
endef

define f_c_binary_do_compile =
	$(call f_c_binary_command_compile,$1)
endef

endif
