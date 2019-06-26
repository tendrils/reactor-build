# build logging interface

## constants
ll_error = 0
ll_warn = 1
ll_info = 2
ll_debug = 3
ll_trace = 4

## init function
define f_log_init =
    $(call f_boot_trace_log,active log level: $(LOG_LEVEL))
    $(call f_log_level_define,trace)
    $(call f_log_level_define,debug)
    $(call f_log_level_define,info)
    $(call f_log_level_define,warn)
    $(call f_log_level_define,error)
endef

## logger dispatch functions
define f_log =
    $(if $(call f_log_level_active,$1),$(call f_do_log,$1,$2,$3))
endef

define f_do_log =
    $(info [$1] ($2): $3)
endef

## level-check function
f_log_level_active = $(ll_active_$1)

## level-define function
define f_log_level_define =
    $(call f_boot_trace_log,f_log_level_define: $1)
    $(eval $(call macro_ll_define,$1))
endef
define macro_ll_define =
    define f_log_$1
        $$(call f_log,$1,$$1,$$2)
    endef
    ll_active_$1 := $$(shell $$(SCRIPT_DIR)/shell/lte $$(ll_$1) $$(ll_$(LOG_LEVEL)))
endef
