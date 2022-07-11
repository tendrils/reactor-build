# ReBuild object reference interface

#   initialize the object reference interface globally
define f_core_ref_global_init =
    $(call f_util_log_trace,($0))
    $(call f_util_set_symbol,rebuild_ref_id_next,0)
endef

#   allocate new object reference and return its ref-id
define f_core_ref_allocate =
    $(call f_util_log_trace,($0): rebuild_ref_id_next:[$(rebuild_ref_id_next)])
    $(call _let,__id,$(call f_util_int_get_increment,rebuild_ref_id_next))
    $(if $(call f_util_list_contains_string,rebuild_defined_ref_ids,$(__id)),
        $(call __warn,ref-id [$(__id)] is already allocated),
        $(call _append,rebuild_defined_ref_ids,$(__id))
        $(__id))
endef
