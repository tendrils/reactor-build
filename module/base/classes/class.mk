
c_object_class_name = object
c_object_class_fields = \
    class_name:string \
    direct_superclasses:list \
    direct_fields:list
    
define f_core_class_object_define =
    $(call f_util_log_trace,($0))
    $(call f_core_class_define,Object,)
endef
