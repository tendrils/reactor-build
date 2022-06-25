
c_object_class_name = Object
c_object_class_superclasses = any
define c_object_class_fields =
    class_name:string
    direct_superclasses:list
    direct_fields:list
endef
c_class_object_constructor_params =

define f_class_object_define =
    $(call f_util_log_trace,($0))
    $(call f_core_class_define,
        $(c_class_object_name),
        f_class_object_constructor,
        $(c_class_object_constructor_params),
        $(c_class_object_fields))
endef

define f_class_object_constructor =
    $(call f_util_log_trace,($0): object_ref:[$1], superclass_constructors:[$2], arg_list:[$3])

endef
