# utility and logging functions

## constants
c_util_log_level_error = 0
c_util_log_level_warn = 1
c_util_log_level_info = 2
c_util_log_level_debug = 3
c_util_log_level_trace = 4

## init function
define f_util_init =
    $(call f_util_log_level_define,trace)
    $(call f_util_log_level_define,debug)
    $(call f_util_log_level_define,info)
    $(call f_util_log_level_define,warn)
    $(call f_util_log_level_define,error)
endef

define f_util_fatal_error =
    $(error [error] Fatal error: $1)
endef

## logger dispatch functions
define f_util_log =
    $(if $(call f_util_log_level_is_active,$1),$(call f_util_do_log,$1,$2,$3))
endef

define f_util_do_log =
    $(info [$1] ($2): $3)
endef

## level-check function
f_util_log_level_is_active = $(v_util_log_level_enabled_$1)

## level-define function
f_util_log_level_define = $(eval $(call m_util_log_level_define,$1))

# define utility macros
define m_util_log_level_define =
    define f_util_log_$1
        $$(call f_util_log,$1,$$1,$$2)
    endef
    v_util_log_level_enabled_$1 := $$(shell $$(SCRIPT_DIR)/shell/lte $$(c_util_log_level_$1) $$(c_util_log_level_$(LOG_LEVEL)))
endef
m_util_load_build_module_file = include $(SCRIPT_MODULE_DIR)/$1/module.mk
m_util_load_target_config_file = include $(CONF_BASE)/$1/build-target.conf
m_util_set_symbol = $1=$2
m_util_append_to_symbol = $1+=$2

# define callable macro invocations
f_util_load_build_module_file = $(eval $(call m_util_load_build_module_file,$1))
f_util_load_target_config_file = $(eval $(call m_util_load_target_config_file,$1))
f_util_set_symbol = $(eval $(call m_util_set_symbol,$1,$2))
f_util_append_to_symbol = $(eval $(call m_util_append_to_symbol,$1,$2))
f_util_append_if_absent = $(if $(findstring $2,$($1)),,$(call f_util_append_to_symbol,$1,$2))
f_util_export_set_symbol = $(eval export $(call m_util_set_symbol,$1,$2))
f_util_export_append_to_symbol = $(eval export $(call m_util_append_to_symbol,$1,$2))
f_util_export_append_if_absent = $(if $(findstring $2,$($1)),,$(call f_util_export_append_to_symbol,$1,$2))
f_util_override_set_symbol = $(eval override $(call m_util_set_symbol,$1,$2))
f_util_override_append_to_symbol = $(eval override $(call m_util_append_to_symbol,$1,$2))
f_util_override_append_if_absent = $(if $(findstring $2,$($1)),,$(call f_util_override_append_to_symbol,$1,$2))
