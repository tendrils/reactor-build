
define f_project_ref_static_init =

endef

# ($1): field-id, ($2): storage-class
define f_project_ref_field_define =
    $(call f_util_log_debug,$0: field-id=[$1], storage-class=[$2])
    $(call f_project_attr_field_define,$1,$2)
endef

## attribute storage class: scalar

# ($1): field-id, ($2): path
define f_project_reference_scalar_set =
    $(call f_util_log_trace,$0: field-id=[$1], path=[$2])
    $(call f_project_attr_scalar_set,$1,$2)
endef

# ($1): project-id, ($2): field-id, ($3): path
define f_project_reference_scalar_set_for_project =
    $(call f_util_log_debug,$0: project=[$1], field-id=[$2], path=[$3])
    $(call f_project_attr_scalar_set_for_project,$1,$2,$3)
endef

# ($1): field-id
define f_project_reference_scalar_get =
    $(call f_util_log_trace,$0: field-id=[$1])
    $(call f_project_attr_scalar_value_get,$1,$2)
endef

# ($1): project-id, ($2): field-id
define f_project_reference_scalar_get_for_project =
    $(call f_util_log_debug,$0: project=[$1], field-id=[$2])
    $(call f_project_attr_scalar_value_get,$1,$2,$3)
endef

## attribute storage class: array

# ($1): field-id, ($2): path
define f_project_reference_array_append =
    $(call f_util_log_trace,$0: field-id=[$1], path=[$2])
    $(call f_project_attr_array_append,$1,$2)
endef

# ($1): project-id, ($2): field-id, ($3): path
define f_project_reference_array_append_for_project =
    $(call f_util_log_debug,$0: project-id=[$1], field-id=[$2], path=[$3])
    $(call f_project_attr_array_append_for_project,$1,$2,$3)
endef

# ($1): field-id, ($2): index
define f_project_reference_array_get =
    $(call f_util_log_trace,$0: field-id=[$1], index=[$2])
    $(call f_project_attr_array_value_get,$1,$2)
endef

# ($1): project-id, ($2): field-id, ($3): index
define f_project_reference_array_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2], index=[$3])
    $(call f_project_attr_array_value_get,$1,$2,$3)
endef

## attribute storage class: map

# ($1): field-id, ($2): key, ($3): path
define f_project_reference_map_set =
    $(call f_util_log_debug,$0: field-id=[$1], key=[$2], path=[$3])
    $(call f_project_attr_map_set,$1,$2,$3)
endef

# ($1): project-id, ($2): field-id, ($3): key, ($4): path
define f_project_reference_map_set_for_project =
    $(call f_util_log_debug,$0: project-id=[$1], field-id=[$2], key=[$3], path=[$4])
    $(call f_project_attr_map_set_for_project,$1,$2,$3,$4)
endef

# ($1): field-id, ($2): key
define f_project_reference_map_get =
    $(call f_util_log_debug,$0: field-id=[$1], key=[$2])
    $(call f_project_attr_map_value_get,$1,$2)
endef

# ($1): project-id, ($2): field-id, ($3): key
define f_project_reference_map_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2], key=[$3])
    $(call f_project_attr_map_value_get_for_project,$1,$2,$3)
endef
