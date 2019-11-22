# rebuild/context.mk

define f_core_context_set =
    $(call f_util_log_trace,f_core_context_set [$1:$2])
    $(call f_util_unset_symbol,_$(_context))
    $(call f_util_reset_symbol,_context,$1)
    $(call f_util_reset_symbol,_$1,$2)
endef

define f_core_context_reset =
    $(call f_util_log_trace,f_core_context_reset)
    $(call f_core_context_set,$(context_initial_key),$(context_initial_value))
endef

_context = core
_core = main
context_initial_key := $(_context)
context_initial_value := $(_core)

_context_value = $(_$(_context))
