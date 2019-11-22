
define f_define_project_reftype =
    $(call f_util_log_debug,base,f_define_project_reftype: id=[$1], handler=[$2])
    #$(call f_util_append_to_symbol,rebuild_defined_reftypes,$1)
    #$(if $2,$(call f_util_set_symbol,rebuild_reftype_handler__$(subst :,_,$1),$2),)
    $(call f_define_project_attr_type__rebuild_reference,$1,$2)
endef

# ($1): project-id
# ($2): reference-id
define f_rebuild_call_reftype_handler =
    #$(call $(rebuild_reftype_handler__$3),$1,$2)
    $(call f_call_project_attr_type_handler__rebuild_reference,$1,$2)
endef

define f_define_project_reference
    $(call f_util_log_debug,base,f_define_project_reference: ref-id=[$1], ref-type=[$2], path=[$3])
    $(call f_define_project_reference_for_project,$(rbproj_main),$1,$2,$3)
endef

define f_define_project_reference_for_project =
    $(call f_util_log_trace,base,f_define_project_reference_for_project: project=[$1] ref-id=[$2], ref-type=[$3], path=[$4])
    #$(call f_util_append_to_symbol,rebuild_project_defined_refs__$1,$2)
    #$(call f_util_set_symbol,rebuild_project_reference_reftype__$1__$2,$3)
    #$(call f_util_set_symbol,rebuild_project_reference__$1__$2,$4)
    #$(call f_rebuild_call_reftype_handler,$1,$2,$3)
    $(call f_define_project_attr_value__rebuild_reference,$1,$2,$3,$4)
endef

define f_rebuild_project_reference_reftype =
    $(call f_rebuild_project_attr_type_get__rebuild_reference,$1,$2)
endef

define f_rebuild_project_reference =
    $(call f_rebuild_project_attr_value_get__rebuild_reference,$1,$2)
endef
