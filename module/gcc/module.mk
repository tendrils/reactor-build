ifndef _MODULE_GCC
_MODULE_GCC = 1

mod_deps_gcc=c_binary

C_BINARY_PROJECT_TYPE =
C_TOOLCHAIN_PROVIDER =

## module lifecycle functions
define f_gcc_init =

endef

# shell command templates for GCC toolchain commands
fm_gcc_tc_cmd_compile_c=$$(v_gcc_tc_cross_prefix_$1)gcc $$(v_gcc_cflags_$1) $$1 -o $$2
fm_gcc_tc_cmd_compile_cxx=$$(v_gcc_tc_cross_prefix_$1)g++ $$(v_gcc_tc_cflags_$1) $$1 -o $$2
fm_gcc_tc_cmd_compile_c_to_deps=$$(v_gcc_tc_cross_prefix_$1)gcc -M $$(v_gcc_tc_cflags_$1) $$1 -o $$2
fm_gcc_tc_cmd_compile_cxx_to_deps=$$(v_gcc_tc_cross_prefix_$1)g++ -M $$(v_gcc_tc_cflags_$1) $$1 -o $$2
fm_gcc_tc_cmd_compile_c_to_asm=$$(v_gcc_tc_cross_prefix_$1)gcc -S $$(v_gcc_tc_cflags_$1) $$1 -o $$2
fm_gcc_tc_cmd_compile_cxx_to_asm=$$(v_gcc_tc_cross_prefix_$1)g++ -S $$(v_gcc_tc_cflags_$1) $$1 -o $$2
fm_gcc_tc_cmd_compile_asm=$$(v_gcc_tc_cross_prefix_$1)as $$(v_gcc_tc_cflags_$1) $$1 -o $$2
fm_gcc_tc_cmd_link_binary=$$(v_gcc_tc_cross_prefix_$1)ld -o $$1 $$2 $$(v_gcc_tc_ldflags_$1)
fm_gcc_tc_cmd_strip_binary=$$(v_gcc_tc_cross_prefix_$1)objcopy -I $$3 -O $$4 $$1 $$2
fm_gcc_tc_cmd_archive_static=$$(v_gcc_tc_cross_prefix_$1)ar qc $$(v_gcc_tc_flag_lto_$1) $$1 $$2
fm_gcc_tc_cmd_update_static=$$(v_gcc_tc_cross_prefix_$1)ranlib $$(v_gcc_tc_flag_lto_$1) $$1

# internal command for ReBuild to locate LTO plugin for the given GCC toolchain
f_gcc_tc_cmd_find_lto_plugin=$(v_gcc_tc_cross_prefix_$1)gcc --print-file-name=liblto_plugin.so

# f_gcc_toolchain_define:
#   register a new GCC-based toolchain and its associated commands
# ($1): handle for new toolchain
# ($2): [optional] cross-compilation target
define f_gcc_toolchain_define =
    $(call f_c_binary_toolchain_define,$1)
	$(call f_util_override_append_if_absent,GCC_TOOLCHAINS,$1)
    $(if $2,$(call f_gcc_cross_target_set,$1,$2),)
    $(call f_gcc_tc_flag_lto_set,$1)
    $(call f_c_binary_tc_cmd_set,$1,compile_c,fm_gcc_tc_cmd_compile_c)
    $(call f_c_binary_tc_cmd_set,$1,compile_cxx,fm_gcc_tc_cmd_compile_cxx)
    $(call f_c_binary_tc_cmd_set,$1,compile_c_to_deps,fm_gcc_tc_cmd_compile_c_to_deps)
    $(call f_c_binary_tc_cmd_set,$1,compile_cxx_to_deps,fm_gcc_tc_cmd_compile_cxx_to_deps)
    $(call f_c_binary_tc_cmd_set,$1,compile_c_to_asm,fm_gcc_tc_cmd_compile_c_to_asm)
    $(call f_c_binary_tc_cmd_set,$1,compile_cxx_to_asm,fm_gcc_tc_cmd_compile_cxx_to_asm)
    $(call f_c_binary_tc_cmd_set,$1,compile_asm,fm_gcc_tc_cmd_compile_asm)
    $(call f_c_binary_tc_cmd_set,$1,link_binary,fm_gcc_tc_cmd_link_binary)
    $(call f_c_binary_tc_cmd_set,$1,strip_binary,fm_gcc_tc_cmd_strip_binary)
    $(call f_c_binary_tc_cmd_set,$1,create_static_lib,fm_gcc_tc_cmd_create_static_lib)
    $(call f_c_binary_tc_cmd_set,$1,update_static_lib,fm_gcc_tc_cmd_update_static_lib)
endef

define f_gcc_tc_flag_lto_set =
    $(call f_util_set_symbol,v_gcc_tc_flag_lto_$1,--plugin=$(shell $(call f_gcc_tc_cmd_find_lto_plugin,$1)))
    $(call f_util_log_trace,gcc,LTO flag for toolchain $1 set to [$(v_gcc_tc_flag_lto_$1)])
endef

define f_gcc_tc_cross_target_set =
    $(call f_util_set_symbol,v_gcc_tc_cross_target_$1,$2)
    $(if $2,\
        $(call f_util_override_set_symbol,\
            v_gcc_tc_cross_prefix_$1,$(v_gcc_tc_cross_target_$1)-),\
        $(call f_util_override_unset_symbol,v_gcc_tc_cross_prefix_$1))
endef

define f_gcc_tc_cflags_set =
    $(call f_util_set_symbol,v_gcc_tc_cflags_$1,$2)
endef

define f_gcc_tc_cflags_append =
    $(call f_util_append_to_symbol,v_gcc_tc_cflags_$1,$2)
endef

# Linker configuration
LIBFLAGS=$(MODFLAGS) $(PLATFORM_LIBFLAGS)
LDFLAGS= -L $(DISTDIR) $(LIBFLAGS)

# C Compiler configuration
C_INCLUDES+=-Iinclude -I$(CONF_DIR) $(PLATFORM_INCLUDES)
v_gcc_include_flags=$(v_c_binary_include_path:%=-I%)
v_gcc_cflags_default_value=-c $(v_gcc_include_flags) 
CXXFLAGS=$(CFLAGS)

endif
