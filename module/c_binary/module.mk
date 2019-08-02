ifndef _MODULE_C_BINARY
_MODULE_C_BINARY = 1

mod_deps_c_binary=

C_BINARY_PROJECT_TYPE =

## module load function
define f_c_binary_init =
	$(call f_define_build_action,compile_c,f_c_binary_do_compile_c)
	$(call f_define_build_action,compile_cxx,f_c_binary_do_compile_cxx)
	$(call f_define_build_action,compile_c_to_asm,f_c_binary_do_compile_c_to_asm)
	$(call f_define_build_action,compile_cxx_to_asm,f_c_binary_do_compile_cxx_to_asm)
	$(call f_define_build_action,compile_asm,f_c_binary_do_compile_asm)
endef

define f_c_binary_toolchain_define =
	$(call f_util_override_append_if_absent,C_BINARY_TOOLCHAINS,$1)
	$(call f_util_set_symbol,c_binary_tc_type_$1,$2)
	$(call f_util_set_symbol,c_binary_tc_arch_$1,$3)
	$(call f_util_set_symbol,c_binary_tc_os_$1,$4)
	$(call f_util_set_symbol,c_binary_tc_abi_$1,$5)
	$(call f_util_log_debug,c_binary,c/c++ toolchain provider registered: $1)
	$(if $(C_BINARY_TOOLCHAIN_DEFAULT),,\
		$(call f_c_binary_tc_default_set,$1))
endef

define f_c_binary_tc_default_set =
	$(call f_util_override_set_symbol,C_BINARY_TC_DEFAULT,$1)
	$(call f_util_log_debug,c_binary,default c/c++ toolchain provider set to [$1])
endef

define f_c_binary_tc_cmd_set =
	$(call f_util_override_set_symbol,fp_c_binary_tc_$1_cmd_$2,$3)
endef

define f_c_binary_tc_cmd_invoke =
	$(if $(fp_c_binary_tc_$1_cmd_$2),,\
		$(call f_util_fatal_error,c-binary,no [$2] command set for c/c++ toolchain provider [$(C_BINARY_TOOLCHAIN_DEFAULT)]))
	$(call $(fp_c_binary_tc_$1_cmd_$2),$3,$4)
endef

define f_c_binary_cmd_invoke =
	$(if $(C_BINARY_TOOLCHAIN_DEFAULT),,\
		$(call f_util_fatal_error,c-binary,no default c/c++ toolchain provider set))
    $(call f_c_binary_tc_cmd_invoke,default,$1,$2,$3)
endef

fp_c_binary_tc_default_cmd_compile_c = $(ff_c_binary_tc_$(C_BINARY_TOOLCHAIN_DEFAULT)_cmd_compile_c)
fp_c_binary_tc_default_cmd_compile_cxx = $(ff_c_binary_tc_$(C_BINARY_TOOLCHAIN_DEFAULT)_cmd_compile_cxx)
fp_c_binary_tc_default_cmd_compile_c_to_asm = $(ff_c_binary_tc_$(C_BINARY_TOOLCHAIN_DEFAULT)_cmd_compile_c_to_asm)
fp_c_binary_tc_default_cmd_compile_cxx_to_asm = $(ff_c_binary_tc_$(C_BINARY_TOOLCHAIN_DEFAULT)_cmd_compile_c)

f_c_binary_do_compile_c = $(call f_c_binary_cmd_invoke,compile_c,$1,$2)
f_c_binary_do_compile_cxx = $(call f_c_binary_cmd_invoke,compile_cxx,$1,$2)
f_c_binary_do_compile_c_to_asm = $(call f_c_binary_cmd_invoke,compile_c_to_asm,$1,$2)
f_c_binary_do_compile_cxx_to_asm = $(call f_c_binary_cmd_invoke,compile_cxx_to_asm,$1,$2)

$(C_SRC_DIR)/%.o: %.c
	$(call f_action_compile_c,$^,$@)

$(CXX_SRC_DIR)/%.o: %.c
	$(call f_action_compile_cxx,$^,$@)

endif
