
define f_define_project_reftype =
    $(call f_util_log_debug,f_define_project_reftype: type-id=[$1], parent=[$2], handler=[$3])
    $(call f_project_attr_type_define,rebuild_reference,$1,$2,$3)
endef

define f_define_project_reference
    $(call f_util_log_debug,base,f_define_project_reference: ref-id=[$1], ref-type=[$2], path=[$3])
    $(call f_define_project_reference_for_project,$(rbproj_main),$1,$2,$3)
endef

define f_project_reference_define_for_project =
    $(call f_util_log_trace,f_project_reference_define_for_project: project=[$1] ref-id=[$2], ref-type=[$3], path=[$4])
    $(call f_project_attr_value_set_for_project__rebuild_reference,$1,$2,$3,$4)
endef

define f_project_reference_reftype_get =
    $(call f_project_reference_get_for_project,main,$1)
endef

define f_project_reference_get =
    $(call f_project_reference_reftype_get_for_project,main,$1)
endef

define f_project_reference_reftype_get_for_project =
    $(call f_project_attr_type_get__rebuild_reference,$1,$2)
endef

define f_project_reference_get_for_project =
    $(call f_project_attr_value_get__rebuild_reference,$1,$2)
endef
