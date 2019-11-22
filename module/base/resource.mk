
define f_define_project_restype =
    $(call f_util_log_debug,base,f_define_project_restype: id=[$1], handler=[$2])
    #$(call f_util_append_to_symbol,rebuild_defined_project_restypes,$1)
    #$(if $2,$(call f_util_set_symbol,rebuild_project_restype_handler__$(subst :,_,$1),$2),)
    $(call f_define_project_attr_type__rebuild_resource,$1,$2)
endef

# ($1): project-id, 
define f_rebuild_call_project_resource_type_handler =
    #$(call $(rebuild_restype_handler__$1__$(subst :,_,$2)))
    $(call f_call_project_attr_type_handler__rebuild_resource,$1,$2)
endef

define f_define_project_resource =
    $(call f_util_log_debug,base,\
        f_define_project_resource: project=[$1], id=[$2], restype=[$3], path=[$4])
    #$(call f_util_append_to_symbol,rebuild_defined_project_references__$1,$2)
    #$(call f_util_set_symbol,rebuild_project_resource_restype__$1__$2,$3)
    #$(call f_util_set_symbol,rebuild_project_resource__$1__$2,$4)
    #$(call f_rebuild_call_project_restype_handler,$1,$3)

    $(call f_define_project_attr_value__rebuild_resource,$1,$2,$3,$4)
endef

define f_rebuild_project_resource_type =
    $(call f_rebuild_project_attr_type_get__rebuild_resource,$1,$2)
endef

# ($1): project-id
# ($2): resource-id
define f_rebuild_project_resource =
    $(call f_rebuild_project_attr_value_get__rebuild_resource,$1,$2)
endef
