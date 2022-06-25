# ReBuild typed variable support
define c_types =
    $(c_any_type)
    $(c_prefix_types)
endef
define c_prefix_types =
    $(c_anyref_type)
    $(c_anyval_type)
    $(c_reference_types)
    $(c_value_types)
endef
define c_value_types =
    $(c_label_type)
    $(c_string_type)
    $(c_int_type)
    $(c_type_type)
endef
define c_reference_types =
    $(c_object_type)
    $(c_array_type)
endef
# category types
c_any_type = any
c_anyref_type = anyref
c_anyval_type = anyval
# value types
c_label_type = label
c_string_type = string
c_int_type = int
c_type_type = type
# reference types
c_object_type = object
c_array_type = array

define f_core_scope_init =
    $(call f_util_log_trace,($0))
    $(call f_util_set_symbol,rebuild_scope_id_next,0)
    $(call f_core_scope_push)
endef
define f_core_scope_save =
    $(call f_util_set_symbol,rebuild_scope_vars__$1,rebuild_scope_vars__$(_scope))
    $(foreach var,$(rebuild_scope_vars__$(_scope)),
        $(call f_util_set_symbol,rebuild_var__$1__$(var),$($(var))))
endef
#   allocate a new scope frame and push it onto the stack
define f_core_scope_push =
    $(call f_util_log_trace,($0))
    $(call f_core_scope_push_frame,$(call f_util_int_get_increment,rebuild_scope_id_next))
endef
#   push scope frame ($1) onto the stack
define f_core_scope_push_frame =
    $(call f_util_set_symbol,_scope,$1)
    $(call f_util_append_to_symbol,rebuild_scopes,$(_scope))
endef
#   variable operations
define f_core_var_init =
    $(call f_util_log_trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_init_for_scope,$(_scope),$1,$2,$3)
endef
define f_core_var_deinit =
    $(call f_util_log_trace,($0): id:[$1])
    $(call f_core_var_deinit_for_scope,$(_scope),$1)
endef
define f_core_var_set =
    $(call f_util_log_trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_set_for_scope,$(_scope),$1,$2:$3)
endef
define f_core_var_unset =
    $(call f_util_log_trace,($0): id:[$1])
    $(call f_core_var_unset_for_scope,$(_scope),$1)
endef
define f_core_var_init_global =
    $(call f_util_log_trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_init_for_scope,global,$1,$2,$3)
endef
define f_core_var_deinit_global =
    $(call f_util_log_trace,($0): id:[$1])
    $(call f_core_var_deinit_for_scope,global,$1)
endef
define f_core_var_set_global =
    $(call f_util_log_trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_set_for_scope,global,$1,$2:$3)
endef
define f_core_var_unset_global =
    $(call f_util_log_trace,($0): id:[$1])
    $(call f_core_var_unset_for_scope,global,$1)
endef
define f_core_var_init_for_scope =
    $(call f_util_log_trace,($0): scope:[$1] id:[$2], type:[$3], value:[$4])
    $(call f_util_append_to_symbol,rebuild_scope_vars__$1,$2)
    $(call f_core_var_set_for_scope,$1,$2,$3,$4)
endef
define f_core_var_deinit_for_scope =
    $(call f_util_log_trace,($0): scope:[$1] id:[$2])
    $(call f_util_remove_from_symbol,rebuild_scope_vars__$1,$2)
    $(call f_core_var_unset_for_scope,$1,$2)
endef
define f_core_var_set_for_scope =
    $(call f_util_log_trace,($0): scope:[$1] id:[$2], type:[$3], value:[$4])
    $(call f_util_set_symbol,rebuild_var__$1__$2,$3:$4)
endef
define f_core_var_unset_for_scope =
    $(call f_util_log_trace,($0): scope:[$1] id:[$2])
    $(call f_util_unset_symbol,rebuild_var__$1__$2)
endef

define f_core_var_type =
    $(patsubst :%,,$(rebuild_var__$(_scope)__$1))
endef

define f_core_var_value =
    $(patsubst %:,,$(rebuild_var__$(_scope)__$1))
endef

define f_core_var_is_ref =
    $(call f_core_type_is_ref,$(call f_core_var_type,$1))
endef

define f_core_type_is_ref =

endef
