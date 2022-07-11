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

#   lexical scope functions
define f_core_stack_init =
    $(call _trace,($0))
    $(call _set,rebuild_scope_id_next,0)
    $(call f_core_scope_push)
endef
define f_core_scope_save =
    $(call _trace,($0): name:[$1])
    $(call _set,rebuild_scope_vars__$1,rebuild_scope_vars__$(_scope))
    $(foreach var,$(rebuild_scope_vars__$(_scope)),
        $(call _set,rebuild_var__$1__$(var),$($(var))))
endef
#   allocate a new scope frame and push it onto the stack
define f_core_scope_push =
    $(call _trace,($0))
    $(call f_core_scope_push_frame,$(call f_util_int_get_increment,rebuild_scope_id_next))
endef
#   push scope frame ($1) onto the stack
define f_core_scope_push_frame =
    $(call _trace,($0): frame:[$1])
    $(call _append,rebuild_scope_stack,$1)
    $(call _set,_scope,$(call _head,$(rebuild_scope_stack)))
endef
define f_core_scope_pop =
    $(call _trace,($0): _scope:[$(_scope)])
    $(if $(call lt,$(words $(rebuild_scope_stack)),0),
        $(call _fatal,rebuild scope stack underflow),)
    $(call _shift,rebuild_scope_stack)
    $(call _set,_scope,$(call f_util_list_head,$(rebuild_scope_stack)))
    $(call f_util_int_decrement,rebuild_scope_id_next)
endef
#   variable operations
##  init operations: 
define f_core_var_init =
    $(call _trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_init_for_scope,$(_scope),$1,$2,$3)
endef
define f_core_var_deinit =
    $(call _trace,($0): id:[$1])
    $(call f_core_var_deinit_for_scope,$(_scope),$1)
endef
define f_core_var_init_global =
    $(call _trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_init_for_scope,global,$1,$2,$3)
endef
define f_core_var_deinit_global =
    $(call _trace,($0): id:[$1])
    $(call f_core_var_deinit_for_scope,global,$1)
endef
define f_core_var_init_for_scope =
    $(call _trace,($0): scope:[$1] id:[$2], type:[$3], value:[$4])
    $(call _append,rebuild_scope_vars__$1,$2)
    $(call f_core_var_set_for_scope,$1,$2,$3,$4)
endef
define f_core_var_deinit_for_scope =
    $(call _trace,($0): scope:[$1] id:[$2])
    $(call _shift,rebuild_scope_vars__$1,$2)
    $(call f_core_var_unset_for_scope,$1,$2)
endef
##  set operations:
define f_core_var_set =
    $(call _trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_set_for_scope,$(_scope),$1,$2:$3)
endef
define f_core_var_unset =
    $(call _trace,($0): id:[$1])
    $(call f_core_var_unset_for_scope,$(_scope),$1)
endef
define f_core_var_set_global =
    $(call _trace,($0): id:[$1], type:[$2], value:[$3])
    $(call f_core_var_set_for_scope,global,$1,$2:$3)
endef
define f_core_var_unset_global =
    $(call _trace,($0): id:[$1])
    $(call f_core_var_unset_for_scope,global,$1)
endef
define f_core_var_set_for_scope =
    $(call _trace,($0): scope:[$1] id:[$2], type:[$3], value:[$4])
    $(call _set,rebuild_var__$1__$2,$3:$4)
endef
define f_core_var_unset_for_scope =
    $(call _trace,($0): scope:[$1] id:[$2])
    $(call _clear,rebuild_var__$1__$2)
endef
##  get operations:
define f_core_var_get =
    $(call f_core_val_get,$(call f_core_var_get_raw,$1))
endef
define f_core_var_type =
    $(call f_core_val_get_type,$(call f_core_var_get_raw,$1))
endef
define f_core_var_get_format =
    $(call f_core_val_get_format,$(call f_core_var_get_raw,$1))
endef
define f_core_var_get_header =
    $(call f_core_val_get_header,$(call f_core_var_get_raw,$1))
endef
define f_core_var_get_raw =
    $(call f_core_var_get_raw_for_scope,$1,$(_scope))
endef
define f_core_var_get_for_scope =
    $(call f_core_val_get,$(call f_core_var_get_raw_for_scope,$1,$2))
endef
define f_core_var_type_for_scope =
    $(call f_core_val_get_type,$(call f_core_var_get_raw_for_scope,$1,$2))
endef
define f_core_var_get_format_for_scope =
    $(call f_core_val_get_format,$(call f_core_var_get_raw_for_scope,$1,$2))
endef
define f_core_var_get_header_for_scope =
    $(call f_core_val_get_header,$(call f_core_var_get_raw_for_scope,$1,$2))
endef
define f_core_var_get_raw_for_scope =
    $($(call f_core_var_id,$1,$2))
endef
define f_core_var_id =
    rebuild_var__$2__$1
endef

#   variable predicates
define f_core_var_format_is_p =
    $(call _equals,
        $(call f_core_var_get_format,$1),$2)
endef
define f_core_var_type_is_p =
    $(call _equals,
        $(call f_core_var_get_type,$1),$2)
endef
