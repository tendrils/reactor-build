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

_empty:=
_space:= $(empty) $(empty)
_lparen:= (
_rparen:= )

#   utility function shorthands
_set = $(call f_util_set_symbol,$1,$2)
_let = $(call f_util_reset_symbol,$1,$2)
_append = $(call f_util_append_to_symbol,$1,$2)
_add = $(call f_util_append_if_absent,$1,$2)
_clear = $(call f_util_unset_symbol,$1)
_shift = $(call f_util_shift_symbol,$1)

_equals = $(call f_util_string_equals,$1,$2)
_contains = $(call f_util_list_contains_string,$1,$2)

_head = $(call f_util_list_head,$1)
_tail = $(call f_util_list_tail,$1)

_trace = $(call f_util_log_trace,$1)
_debug = $(call f_util_log_debug,$1)
_info = $(call f_util_log_info,$1)
_warn = $(call f_util_log_warn,$1)
_error = $(call f_util_log_error,$1)
_fatal = $(call f_util_fatal_error,$1)

#########################
#   logging interface   #
#########################

## default log level, to be overridden by command line
rebuild_log_level = info

define f_util_log_channel_init =
    $(call f_util_log_level_define,trace,$(c_util_log_level_trace))
    $(call f_util_log_level_define,debug,$(c_util_log_level_debug))
    $(call f_util_log_level_define,info,$(c_util_log_level_info))
    $(call f_util_log_level_define,warn,$(c_util_log_level_warn))
    $(call f_util_log_level_define,error,$(c_util_log_level_error))
    $(call _debug,primary logging channel initialized)
endef

# ($1): level-name, ($2): level-number
define f_util_log_level_define =
    $(eval $(call m_util_log_level_define,$1,$2))
endef

f_util_log_level_is_active = $(v_util_log_level_enabled_$1)

# ($1): level, ($2): message
f_util_log = $(if $(call f_util_log_level_is_active,$1),$(call f_util_do_log,$1,$2))
f_util_do_log = $(info [$1] $(if $(_context),($(_context)):) $2)
f_util_fatal_error = $(error [error] $(if $(_context),($(_context)):) Fatal error: $2)
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
m_util_prepend_to_symbol = $1=$2 $1
m_util_drop_first_item = $1=$(call f_util_list_tail,$1)

f_util_assert_condition = $(if $1,,$(call _fatal,ASSERTION FAILED: $2))

## symbol manipulation functions
f_util_load_file = $(call _trace,f_util_load_file: $1)$(eval $(call m_util_load_file,$1))

define f_util_set_symbol =
    $(call _trace,($0): symbol:[$1] value:[$2])
    $(call f_util_set_symbol_internal,$1,$2)
endef
f_util_set_symbol_internal = $(eval $(call m_util_set_symbol,$1,$2))

define f_util_unset_symbol =
    $(call _trace,($0): symbol:[$1])
    $(call f_util_unset_symbol_internal,$1)
endef
f_util_unset_symbol_internal = $(eval $(call m_util_unset_symbol,$1))

define f_util_reset_symbol =
    $(call _trace,($0): symbol:[$1] value:[$2])
    $(call f_util_reset_symbol_internal,$1,$2)
endef
define f_util_reset_symbol_internal =
    $(call f_util_unset_symbol_internal,$1)
    $(call f_util_set_symbol_internal,$1,$2)
endef

f_util_append_to_symbol = $(call _trace,($0): symbol:[$1] value:[$2])$(eval $(call m_util_append_to_symbol,$1,$2))
f_util_append_if_absent = $(call _trace,($0): symbol:[$1] value:[$2])$(if $(call f_util_list_contains_string,$2,$($1)),,$(call f_util_append_to_symbol,$1,$2))
f_util_prepend_to_symbol = $(call _trace,($0): symbol:[$1] value:[$2])$(eval $(call m_util_prepend_to_symbol,$1,$2))
f_util_remove_from_symbol = $(call _trace,($0): symbol:[$1] value:[$2])$(call f_util_set_symbol,$1,$(filter-out $2,$($1)))
f_util_export_symbol = $(call _trace,($0): [$1])$(eval export $1)
f_util_shift_symbol = $(call _trace,($0): [$1])$(call _head,$($1))$(call _set,$1,$(call _tail,$($1)))

## list and string manipulation functions
f_util_string_equals = $(strip $(if $(findstring $(strip $1),$2),$(findstring $(strip $2),$1),))
f_util_string_remove_whitespace = $(subst $(_space),,$(strip $1))
# ($1): string, ($2): list
f_util_list_contains_string = $(strip $(if $(findstring $1,$2),$(foreach x,$2,$(call f_util_string_equals,$1,$(x))),))
f_util_list_reverse = $(if $(wordlist 2,2,$(1)),$(call f_util_list_reverse,$(wordlist 2,$(words $(1)),$(1))) $(firstword $(1)),$(1))
f_util_list_head = $(firstword $1)
f_util_list_tail = $(wordlist 2,$(words $1),$1)
f_util_list_map = $(foreach _item,$1,$(call $2,$(_item)))
f_util_list_get = $(word $1,$2)
f_util_list_get_first = $(call _head,$1)
f_util_list_get_last = $(word $(words $1),$1)

#   integer operations
# write incremented value to symbol $1
define f_util_int_increment =
    $(call _set,$1,$(call inc,$($1)))
endef
# read symbol value and then increment
define f_util_int_get_increment =
    $($1)
    $(call f_util_int_increment,$1)
endef
# increment symbol and then read value
define f_util_int_increment_get =
    $(call f_util_int_decrement,$1)
    $($1)
endef
# write decremented value to symbol $1
define f_util_int_decrement =
    $(call f_util_set_symbol,$1,$(call dec,$($1)))
endef
# read symbol value and then decrement
define f_util_int_get_decrement =
    $($1)
    $(call f_util_int_decrement,$1)
endef
# decrement symbol and then read value
define f_util_int_decrement_get =
    $(call f_util_int_decrement,$1)
    $($1)
endef
