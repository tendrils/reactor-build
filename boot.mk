# functions and macros for use by other routines in the init stage

## logging functions
define f_boot_log =
    $(info [BOOT]: $1)
endef
define f_boot_trace_log =
    $(if $(TRACE), $(info [TRACE]: $1))
endef
