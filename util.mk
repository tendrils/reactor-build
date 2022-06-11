# utility and logging functions

## constants
c_util_log_level_error = 0
c_util_log_level_warn = 1
c_util_log_level_info = 2
c_util_log_level_debug = 3
c_util_log_level_trace = 4

#rebuild_log_level = $(c_util_log_level_info)

## init function
define f_util_init =
    $(call f_util_log_channel_init)
endef

define f_util_log_channel_init =
    $(call f_util_log_level_define,trace,4)
    $(call f_util_log_level_define,debug,3)
    $(call f_util_log_level_define,info,2)
    $(call f_util_log_level_define,warn,1)
    $(call f_util_log_level_define,error,0)
    $(call f_util_log_trace,primary logging channel initialized)
endef

# define logging interface
#
# f_util_log([$1]: level, [$2]: message)
f_util_log = $(if $(call f_util_log_level_is_active,$1),$(call f_util_do_log,$1,$2))
f_util_do_log = $(info [$1]$(if $(_context), ($(_context)$(if $(_context_value),:$(_context_value)))): $2)
f_util_fatal_error = $(error [error] ($(_context):$(_context_value)) Fatal error: $2)

f_util_log_level_is_active = $(v_util_log_level_enabled_$1)
define f_util_log_level_define =
    $(eval $(call m_util_log_level_define,$1,$2))
endef

# define utility macros
define m_util_log_level_define =
    v_core_log_level_value_$1 = $2
    f_util_log_$1 = $$(call f_util_log,$1,$$1)

    v_util_log_level_enabled_$1 := $$(call lte,$2,$$(v_core_log_level_value_$$(rebuild_log_level)))

endef
m_util_load_file = include $1
m_util_set_symbol = $1=$2
m_util_unset_symbol = undefine $1
m_util_append_to_symbol = $1+=$2

f_util_load_file = $(call f_util_log_trace,f_util_load_file: $1)$(eval $(call m_util_load_file,$1))

define f_util_set_symbol =
    $(call f_util_log_trace,f_util_set_symbol: [$1 = $2])
    $(call f_util_set_symbol_internal,$1,$2)
endef
f_util_set_symbol_internal = $(eval $(call m_util_set_symbol,$1,$2))

define f_util_unset_symbol =
    $(call f_util_log_trace,f_util_unset_symbol: [$1])
    $(call f_util_unset_symbol_internal,$1)
endef
f_util_unset_symbol_internal = $(eval $(call m_util_unset_symbol,$1))

define f_util_reset_symbol =
    $(call f_util_log_trace,f_util_reset_symbol: [$1 = $2])
    $(call f_util_reset_symbol_internal,$1,$2)
endef
define f_util_reset_symbol_internal =
    $(call f_util_unset_symbol_internal,$1)
    $(call f_util_set_symbol_internal,$1,$2)
endef

f_util_append_to_symbol = $(eval $(call m_util_append_to_symbol,$1,$2))
f_util_append_if_absent = $(if $(call f_util_list_contains_string,$2,$($1)),$(call f_util_log_trace,boot,found $1 in $2),$(call f_util_append_to_symbol,$1,$2))
f_util_export_symbol = $(eval export $1)$(call f_util_log_trace,export $1)
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
f_util_list_reverse = $(if $(wordlist 2,2,$(1)),$(call f_util_list_reverse,$(wordlist 2,$(words $(1)),$(1))) $(firstword $(1)),$(1))
f_util_list_head = $(firstword $1)
f_util_list_tail = $(wordlist 2,$(words $1),$1)
