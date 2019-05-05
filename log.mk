# build logging API

## API constants
ll_error = 0
ll_warn = 1
ll_info = 2
ll_debug = 3
ll_trace = 4


## logger dispatch function
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
    define macro_ll_define =
        ll_active_$1 := $(shell project/shell/lte $(ll_$1) $(ll_$(LOG_LEVEL)))
        $(call f_boot_trace_log,inner: ($(ll_$1) $(ll_$(LOG_LEVEL))) $(shell project/shell/lte $(ll_$1) $(ll_$(LOG_LEVEL))))
    endef
    
    $(call f_boot_trace_log,f_log_level_define: $1)
    $(eval $(call macro_ll_define,$1))
    $(call f_boot_trace_log,$$ll_active_$1: $(ll_active_$1))
endef
