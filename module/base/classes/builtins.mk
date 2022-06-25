# ReBuild Object System: builtin class definitions

define c_core_value_types =
    string
    int
    list

endef
define c_core_builtin_classes =
    Any
    array
    map
endef

define f_core_ref_is_builtin =
    $(call f_util_list_contains_string,
        $(c_core_builtin_classes),
        $(call f_core_ref_type,$1))
endef
