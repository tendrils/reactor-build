# ReBuild Object System
include classes/builtins.mk
include classes/object.mk
include classes/class.mk

define f_core_object_system_init =
    $(call f_class_any_define)
    $(call f_class_object_define)
    $(call f_class_class_define)
endef

define f_core_ref_object_p =
    
endef

f_core_class_context_set = $(call f_core_context_set,class,$1)

define f_core_class_define =
    $(call f_util_log_trace,($0): class_name:[$1], direct_superclasses:[$2], constructor:[$3], constructor_params:[$4])
    $(foreach _class,$2,
        $(call f_core_class_assert_class_is_defined,$(_class))
        $(call f_core_class_assert_class_is_finalized,$(_class)))
    $(call f_util_append_to_symbol,rebuild_defined_standard_classes,$1)
    $(call f_util_set_symbol,rebuild_class_direct_superclasses__$1,$2)
    $(call f_util_set_symbol,rebuild_class_constructor__$1,$3)
    $(call f_util_set_symbol,rebuild_class_constructor_param_types__$1,$4)
    $(call f_util_set_symbol,rebuild_class_precedence_list__$1,
        $(call f_core_class_compute_class_precedence_list,$1))
    $(call f_util_set_symbol,rebuild_class_next_instance__$1,0)
endef

define f_core_class_field_define =
    $(call f_util_log_trace,($0): class_name:[$1], field_name:[$2], field_type:[$3], readonly:[$4])
    $(call f_util_append_if_absent,rebuild_class_defined_direct_fields__$1,$2)
    $(call f_util_set_symbol,rebuild_class_field_type_for_field__$1__$2,$3)
    $(call f_core_class_method_define,$1,get_$2,$3)
    $(if $4,,$(call f_core_class_method_define,$1,set_$2,,$3))
endef

# accessors
f_core_class_get_direct_superclasses = $(rebuild_class_direct_superclasses__$1)
f_core_class_get_constructor = $(rebuild_class_constructor__$1)
#f_core_class_get_class_precedence_list = $(rebuild_class_precedence_list__$1)

# conditionals
f_core_class_is_defined = $(call f_util_list_contains_string,rebuild_defined_classes,$1)
f_core_class_is_undefined = $(if $(call f_core_class_is_defined,$1),,true)
f_core_class_is_finalized = $(rebuild_class_is_finalized__$1)
f_core_class_is_open = $(if $(call f_core_class_is_finalized,$1),,true)

# assertions
define f_core_class_assert_class_is_defined =
    $(call f_util_log_trace,($0): class_name:[$1])
    $(call f_util_assert_condition,$(call f_core_class_is_defined,$1),class [$1] is undefined)
endef

define f_core_class_assert_class_is_undefined =
    $(call f_util_log_trace,($0): class_name:[$1])
    $(call f_util_assert_condition,$(call f_core_class_is_undefined,$1),class [$1] is already defined)
endef

define f_core_class_assert_class_is_open =
    $(call f_util_log_trace,($0): class_name:[$1])
    $(call f_util_assert_condition,$(call f_core_class_is_open,$1),class [$1] is already finalized)
endef

define f_core_class_assert_class_is_finalized =
    $(call f_util_log_trace,($0): class_name:[$1])
    $(call f_util_assert_condition,$(call f_core_class_is_finalized,$1),class [$1] is not yet finalized)
endef

# params are formatted as a list of argument-types
define f_core_class_method_define =
    $(call f_util_log_trace,($0): class_name:[$1], method_name:[$2], return_type:[$3], params=[$4])
    $(call f_util_append_if_absent,rebuild_class_defined_direct_methods__$1,$2)
    $(call f_util_set_symbol,rebuild_class_return_type_for_method__$1__$2,$3)
    $(call f_util_set_symbol,rebuild_class_param_types_for_method__$1__$2,$4)
endef

define f_core_class_constructor_define =
    $(call f_util_log_trace,($0): class_name:[$1])
    $(call f_util_set_symbol,rebuild_class_constructor_method__$1,)
endef

define f_core_class_finalize =
    $(call f_util_log_trace,($0): class_name:[$1])
#   TODO perform finalization of fields and methods here

    $(call f_util_set_symbol,rebuild_class_is_finalized__$1,true)
endef

define f_core_class_compute_class_precedence_list =

endef

define f_core_class_make_instance =
    $(call f_util_log_trace,($0): class_name:[$1], args:[$2])
    $(call f_core_class_assert_class_is_finalized,$1)
    $(call f_core_class_instance_call_constructors,
        _instance__$1__$(rebuild_class_next_instance__$1),$1,$2)
    $(call f_util_set_symbol,rebuild_class_next_instance__$1,
        $(call inc,rebuild_class_next_instance__$1))
    
endef

# constructor functions always have exactly three arguments:
# $1: new instance object reference
# $2: list of superclass constructor functions
# $3: list of constructor arguments
define f_core_class_instance_call_constructors =
    $(call f_util_log_trace,($0): object_ref:[$1], class_name:[$2], args:[$3])
    $(call $(call f_core_class_get_constructor,$2),
        $(call f_util_list_map,$(call f_core_class_get_direct_superclasses,$1),
            $(call f_core_class_get_constructor,$1)),$2)
endef
