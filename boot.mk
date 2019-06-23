# functions and macros for use by other routines in the init stage

## logging functions
define f_boot_log =
    $(info [BOOT] $1)
endef
define f_boot_trace_log =
    $(if $(TRACE), $(info [BOOT][TRACE] $1))
endef
define f_boot_failure =
    $(error [BOOT] Fatal error: $1)
endef
