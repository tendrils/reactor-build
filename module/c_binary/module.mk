ifndef _MODULE_C_BINARY
_MODULE_C_BINARY = 1

mod_deps_c_binary=

C_BINARY_PROJECT_TYPE =

## module load function
define f_c_binary_init =
	$(call f_define_build_action,compile_c,f_c_binary_do_compile_c)
	$(call f_define_build_action,compile_cxx,f_c_binary_do_compile_cxx)
	$(call f_define_build_action,compile_c_to_deps,f_c_binary_do_compile_c_to_deps)
	$(call f_define_build_action,compile_cxx_to_deps,f_c_binary_do_compile_cxx_to_deps)
	$(call f_define_build_action,compile_c_to_asm,f_c_binary_do_compile_c_to_asm)
	$(call f_define_build_action,compile_cxx_to_asm,f_c_binary_do_compile_cxx_to_asm)
	$(call f_define_build_action,compile_asm,f_c_binary_do_compile_asm)
	$(call f_define_build_action,link_binary,f_c_binary_do_link_binary)

	$(call f_define_build_action,compile_c_with_tc,f_c_binary_do_compile_c_with_tc)
	$(call f_define_build_action,compile_cxx_with_tc,f_c_binary_do_compile_cxx_with_tc)
	$(call f_define_build_action,compile_c_to_deps_with_tc,f_c_binary_do_compile_c_to_deps_with_tc)
	$(call f_define_build_action,compile_cxx_to_deps_with_tc,f_c_binary_do_compile_cxx_to_deps_with_tc)
	$(call f_define_build_action,compile_c_to_asm_with_tc,f_c_binary_do_compile_c_to_asm_with_tc)
	$(call f_define_build_action,compile_cxx_to_asm_with_tc,f_c_binary_do_compile_cxx_to_asm_with_tc)
	$(call f_define_build_action,compile_asm_with_tc,f_c_binary_do_compile_asm_with_tc)
	$(call f_define_build_action,link_binary_with_tc,f_c_binary_do_link_binary_with_tc)
endef

define f_c_binary_toolchain_define =
	$(call f_util_log_debug,$0: name=[$1], type=[$2], arch=[$3], os=[$4], abi=[$5])
	$(call f_core_context_save,c_binary_tc_$1)
	$(call f_util_override_append_if_absent,v_c_binary_toolchains,$1)
	$(call f_util_set_symbol,v_c_binary_tc_type_$1,$2)
	$(call f_util_set_symbol,v_c_binary_tc_arch_$1,$3)
	$(call f_util_set_symbol,v_c_binary_tc_os_$1,$4)
	$(call f_util_set_symbol,v_c_binary_tc_abi_$1,$5)
	$(if $(v_c_binary_toolchain_default),,$(call f_c_binary_tc_default_set,$1))
endef

define f_c_binary_project_type_define =
	$(call f_util_override_append_if_absent,v_c_binary_project_types,$1)
endef

define f_c_binary_tc_default_set =
	$(call f_util_log_trace,$0: [$1])
	$(call f_util_override_set_symbol,v_c_binary_toolchain_default,$1)
endef

# f_c_binary_cmd_invoke(command, in_files, out_file)
#
# -> generic command handler function
# -> pass command to active toolchain, or default if none is selected
#
# command ($1): the name of the toolchain command to invoke
# in_files ($2): the name of the input file(s)
# out_file ($3): the name of the output file
#
define f_c_binary_cmd_invoke =
	$(if $(v_c_binary_toolchain_default),,\
		$(call f_util_fatal_error,no c/c++ toolchain providers are registered))
	$(if $(v_c_binary_toolchain_active),\
		$(call f_c_binary_tc_cmd_invoke,$(v_c_binary_toolchain_active),$1,$2,$3),\
    	$(call f_c_binary_tc_cmd_invoke,$(v_c_binary_toolchain_default),$1,$2,$3))
endef

define f_c_binary_tc_active_set =
	$(call f_util_log_debug,activated c/c++ toolchain [$(v_c_binary_toolchain_active)])\
	$(call f_util_set_symbol,v_c_binary_toolchain_active,$1)
endef

define f_c_binary_tc_active_get =
	$(if $(v_c_binary_toolchain_active),\
		$(v_c_binary_toolchain_active),\
		$(v_c_binary_toolchain_default))
endef

define f_c_binary_tc_cmd_set =
	$(call f_util_override_set_symbol,fp_c_binary_tc_$1_cmd_$2,$(call $3,$1))
endef

# f_c_binary_tc_cmd_invoke(command, in_files, out_file)
#
# -> specific command handler function
# -> pass command to specified toolchain
# -> called by generic handler function f_c_binary_cmd_invoke
#
# toolchain ($1): the id of the target toolchain
# command ($2): the name of the toolchain command to invoke
# in_files ($3): the name of the input file(s)
# out_file ($4): the name of the output file
#
define f_c_binary_tc_cmd_invoke =
	$(if $(fp_c_binary_tc_$1_cmd_$2),,\
		$(call f_util_fatal_error,no [$2] command set for c/c++ toolchain provider [$(C_BINARY_TOOLCHAIN_DEFAULT)]))
	$(call f_util_context_restore,c_binary_tc_$1)
	$(call $(fp_c_binary_tc_$1_cmd_$2),$3,$4)
	$(call f_util_context_reset)
endef

# generic command dispatch functions
f_c_binary_do_compile_c = $(call f_c_binary_cmd_invoke,compile_c,$1,$2)
f_c_binary_do_compile_cxx = $(call f_c_binary_cmd_invoke,compile_cxx,$1,$2)
f_c_binary_do_compile_c_to_asm = $(call f_c_binary_cmd_invoke,compile_c_to_asm,$1,$2)
f_c_binary_do_compile_cxx_to_asm = $(call f_c_binary_cmd_invoke,compile_cxx_to_asm,$1,$2)
f_c_binary_do_link_binary = $(call f_c_binary_cmd_invoke,link_binary,$1,$2)

# selective command dispatch functions
f_c_binary_do_compile_c_with_tc = $(call f_c_binary_tc_cmd_invoke,compile_c_with_tc,$1,$2)
f_c_binary_do_compile_cxx_with_tc = $(call f_c_binary_tc_cmd_invoke,compile_cxx_with_tc,$1,$2)
f_c_binary_do_compile_c_to_asm_with_tc = $(call f_c_binary_tc_cmd_invoke,compile_c_to_asm_with_tc,$1,$2)
f_c_binary_do_compile_cxx_to_asm_with_tc = $(call f_c_binary_tc_cmd_invoke,compile_cxx_to_asm_with_tc,$1,$2)
f_c_binary_do_link_binary_with_tc = $(call f_c_binary_tc_cmd_invoke,link_binary_with_tc,$1,$2)

%.c.o: %.c
	$(call f_action_compile_c,$^,$@)

%.c.s: %.c
	$(call f_action_compile_c_to_asm,$^,$@)

%.c.d: %.c
	$(call f_action_compile_c_to_deps,$^,$@)

%.cpp.o: %.cpp
	$(call f_action_compile_cxx,$^,$@)

%.cpp.s: %.cpp
	$(call f_action_compile_cxx_to_asm,$^,$@)

%.cpp.d: %.cpp
	$(call f_action_compile_cpp_to_deps,$^,$@)

%.s.o: %.s
	$(call f_action_compile_asm,$^,$@)

%.S.o: %.S
	$(call f_action_compile_asm,$^,$@)

endif
