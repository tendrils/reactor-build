# rebuild/context.mk
#
# routines for the saving and loading of context info used by the logger

rebuild_context_initial_1 := core
rebuild_context_initial_2 := main
_context_1 = $(rebuild_context_initial_1)
_context_2 = $(rebuild_context_initial_2)

_context = $(_context_1):$(_context_2)

define f_core_context_set =
    $(call f_util_reset_symbol_internal,_context_1,$1)
    $(call f_util_reset_symbol_internal,_context_2,$2)
endef

define f_core_context_reset =
    $(call f_core_context_set,$(rebuild_context_initial_1),$(rebuild_context_initial_2))
endef

define f_core_context_save =
    $(call f_util_log_trace,$0: saving context [$1])
    $(call f_util_set_symbol_internal,rebuild_context_1__$1,$(_context_1))
    $(call f_util_set_symbol_internal,rebuild_context_2__$1,$(_context_2))
endef

define f_core_context_restore =
    $(call f_util_log_trace,$0: restoring context [$1])
    $(call f_core_context_set,\
        $(rebuild_context_1__$1),$(rebuild_context_1__$2))
endef
