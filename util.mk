# utility and logging functions

## constants
c_util_log_level_error = 0
c_util_log_level_warn = 1
c_util_log_level_info = 2
c_util_log_level_debug = 3
c_util_log_level_trace = 4

## init function
define f_util_init =
    $(call f_util_log_channel_init)
endef

define f_util_log_channel_init =
    $(call f_util_log_level_define,trace)
    $(call f_util_log_level_define,debug)
    $(call f_util_log_level_define,info)
    $(call f_util_log_level_define,warn)
    $(call f_util_log_level_define,error)
    $(call f_util_log_trace,boot,primary logging channel initialized)
endef

f_util_fatal_error = $(error [error] ($1) Fatal error: $2)
f_util_log = $(if $(call f_util_log_level_is_active,$1),$(call f_util_do_log,$1,$2,$3))
f_util_do_log = $(info [$1] ($2): $3)

f_util_log_level_is_active = $(v_util_log_level_enabled_$1)
f_util_log_level_define = $(eval $(call m_util_log_level_define,$1))

# define utility macros
define m_util_log_level_define =
    define f_util_log_$1
        $$(call f_util_log,$1,$$1,$$2)
    endef
    v_util_log_level_enabled_$1 := $$(shell $$(rebuild_home)/shell/lte $$(c_util_log_level_$1) $$(c_util_log_level_$(LOG_LEVEL)))
endef
m_util_load_file = include $1
m_util_set_symbol = $1=$2
m_util_unset_symbol = undefine $1
m_util_append_to_symbol = $1+=$2

f_util_build_module_dir = $(SCRIPT_MODULE_DIR)/$1
f_util_load_file = $(call f_util_log_trace,util,f_util_load_file: $1)$(eval $(call m_util_load_file,$1))
f_util_set_symbol = $(call f_util_log_trace,util,f_util_set_symbol: [$1 = $2])$(eval $(call m_util_set_symbol,$1,$2))
f_util_unset_symbol = $(eval $(call m_util_unset_symbol,$1))
f_util_append_to_symbol = $(eval $(call m_util_append_to_symbol,$1,$2))
f_util_append_if_absent = $(if $(call f_util_list_contains_string,$2,$($1)),$(call f_util_log_trace,boot,found $1 in $2),$(call f_util_append_to_symbol,$1,$2))
f_util_export_symbol = $(eval export $1)$(call f_util_log_trace,util,export $1)
f_util_export_set_symbol = $(eval export $(call m_util_set_symbol,$1,$2))
f_util_export_unset_symbol = $(eval export $(call m_util_unset_symbol,$1,$2))
f_util_export_append_to_symbol = $(eval export $(call m_util_append_to_symbol,$1,$2))
f_util_export_append_if_absent = $(if $(call f_util_list_contains_string,$2,$($1)),,$(call f_util_export_append_to_symbol,$1,$2))
f_util_override_set_symbol = $(eval override $(call m_util_set_symbol,$1,$2))
f_util_override_unset_symbol = $(eval override $(call m_util_unset_symbol,$1))
f_util_override_append_to_symbol = $(eval override $(call m_util_append_to_symbol,$1,$2))
f_util_override_append_if_absent = $(if $(call f_util_list_contains_string,$2,$($1)),,$(call f_util_override_append_to_symbol,$1,$2))

f_util_string_equals = $(strip $(if $(findstring $(strip $1),$2),$(findstring $(strip $2),$1),))
f_util_list_contains_string = $(strip $(if $(findstring $1,$2),$(foreach x,$2,$(call f_util_string_equals,$1,$(x))),))
