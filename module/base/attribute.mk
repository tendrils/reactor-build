# module/base/attribute.mk
#
# basic framework on which all project metadata attributes are built

# ($1): field-id, ($2): field-storage, ($3): field-is-typed
define f_project_attr_field_define =
    $(call f_util_log_debug,$0: field-id=[$1], field-storage=[$2], field-is-typed=[$3])
    $(call f_util_append_if_absent,rebuild_defined_project_attr_fields,$1)
    $(if $2,\
        $(if $(call f_util_list_contains_string,$2,array map scalar),,\
            $(call f_util_fatal_error,$0: [$2] is not a valid field storage class))\
        $(call f_util_set_symbol,rebuild_project_attr_field_storage__$1,$2),)
    $(if $3,\
        $(call f_util_set_symbol,rebuild_project_attr_field_typed__$1,$(rb_true))\
		$(call f_typemap_map_define,\
			$(call f_project_attr_field_typemap_id_get,$1)),)
endef

# ($1): field-id, ($2): type-id, [($3): parent-id], [($4): handler]
define f_project_attr_type_define =
    $(call f_util_log_debug,$0: field-id=[$1], type-id=[$2], parent-id=[$3], handler=[$4])
    $(if $(call f_project_attr_field_is_defined,$1),,\
        $(call f_util_fatal_error,$0: field [$1] is not defined))
    $(call f_typemap_type_define,\
        $(call f_project_attr_field_typemap_id_get,$1),$2,$3)
    $(if $4,\
        $(call f_util_set_symbol,rebuild_attr_type_handler__$1__$2,$4),)
endef

## storage class: scalar

# ($1): field-id
define f_project_attr_scalar_value_get =
    $(call f_project_attr_scalar_value_get_for_project,main,$1)
endef

# ($1): field-id
define f_project_attr_scalar_type_get =
    $(call f_project_attr_scalar_type_get_for_project,main,$1)
endef

# ($1): field-id, ($2): value, [($3): type-id]
define f_project_attr_scalar_set =
    $(call f_project_attr_scalar_set_for_project,main,$1,$2,$3)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_scalar_value_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2])
    $(call f_project_attr_field_access_validate,$0,$2,scalar)
    $(rebuild_project_attr_value__$1__$2)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_scalar_type_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2])
    $(call f_project_attr_field_access_validate,$0,$2,scalar)
    $(rebuild_project_attr_type__$1__$2)
endef

# ($1): project-id, ($2): field-id, ($3): value, [($4): type-id]
define f_project_attr_scalar_set_for_project =
    $(call f_util_log_debug,$0: project-id=[$1], field-id=[$2], value=[$3], type-id=[$4])
    $(call f_project_attr_field_access_validate_critical,$0,$2,scalar)

    $(call f_util_set_symbol,rebuild_project_attr_value__$1__$2,$3)

    $(if $(call f_project_attr_field_is_typed,$2),\
        $(call f_project_attr_typed_field_access_validate_critical,$0,$2,$4)\
        $(call f_util_set_symbol,rebuild_project_attr_type__$1__$2,$4)\
        $(call f_project_attr_type_handler_call,$1,$2,$3,$4),,)
endef

## storage class: map

# ($1): field-id
define f_project_attr_map_keys_get =
    $(call f_project_attr_map_keys_get_for_project,$(rbproj_main),$1)
endef

# ($1): field-id, ($2): key
define f_project_attr_map_value_get =
    $(call f_project_attr_map_value_get_for_project,$(rbproj_main),$1,$2)
endef

# ($1): field-id, ($2): key
define f_project_attr_map_type_get =
    $(call f_project_attr_map_type_get_for_project,$(rbproj_main),$1,$2)
endef

# ($1): field-id, ($2): key, ($3): value, [($4): type]
define f_project_attr_map_set =
    $(call f_project_attr_map_set_for_project,$(rbproj_main),$1,$2,$3,$4)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_map_keys_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2])
    $(call f_project_attr_field_access_validate,$0,$2,map)
    $(rebuild_project_attr_keys__$1__$2)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_map_types_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2])
    $(call f_project_attr_field_access_validate,$0,$2,map)
    $(rebuild_project_attr_types__$1__$2)
endef

# ($1): project-id, ($2): field-id, ($3): key
define f_project_attr_map_value_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2], key=[$3])
    $(call f_project_attr_field_access_validate,$0,$2,map)
    $(rebuild_project_attr_value__$1__$2__$3)
endef

# ($1): project-id, ($2): field-id, ($3): key
define f_project_attr_map_type_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2], key=[$3])
    $(call f_project_attr_field_access_validate,$0,$2,map)
    $(rebuild_project_attr_type__$1__$2__$3)
endef

# ($1): project-id, ($2): field-id, ($3): key ($4): value, [($5): type-id]
define f_project_attr_map_set_for_project =
    $(call f_util_log_debug,$0: project-id=[$1], field-id=[$2], key=[$3] value=[$4], type-id=[$5])
    $(call f_project_attr_field_access_validate_critical,$0,$2,map)

    $(call f_util_append_if_absent,rebuild_project_attr_keys__$1__$2,$3)
    $(call f_util_set_symbol,rebuild_project_attr_value__$1__$2__$3,$4)

    $(if $(call f_project_attr_field_is_typed,$2),\
		$(call f_project_attr_typed_field_access_validate_critical,$0,$2,$5)\
        $(call f_util_set_symbol,rebuild_project_attr_type__$1__$2__$3,$4)\
        $(call f_project_attr_type_handler_call,$1,$2,$4,$5),)
endef

## storage class: array

# ($1): field-id
define f_project_attr_array_values_get =
    $(call f_project_attr_array_values_get_for_project,$(rbproj_main),$1)
endef

# ($1): field-id
define f_project_attr_array_types_get =
    $(call f_project_attr_array_types_get_for_project,$(rbproj_main),$1)
endef

# ($1): field-id, ($2): index
define f_project_attr_array_value_get =
    $(call f_project_attr_array_value_get_for_project,$(rbproj_main),$1,$2)
endef

# ($1): field-id, ($2): index
define f_project_attr_array_type_get =
    $(call f_project_attr_array_type_get_for_project,$(rbproj_main),$1,$2)
endef

# ($1): field-id, ($2): index, ($3): value, [($4): type-id]
define f_project_attr_array_append =
    $(call f_project_attr_array_append_for_project,$(rbproj_main),$1,$2,$3,$4)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_array_values_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2])
    $(call f_project_attr_field_access_validate,$0,$2,array)

    $(rebuild_project_attr_values__$1__$2)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_array_types_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2])
    $(call f_project_attr_field_access_validate,$0,$2,array)

    $(rebuild_project_attr_types__$1__$2)
endef

# ($1): project-id, ($2): field-id, ($3): index
define f_project_attr_array_value_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2], index=[$3])
    $(call f_project_attr_field_access_validate,$0,$2,array)

    $(word $3,$(rebuild_project_attr_values__$1__$2))
endef

# ($1): project-id, ($2): field-id, ($3): index
define f_project_attr_array_type_get_for_project =
    $(call f_util_log_trace,$0: project-id=[$1], field-id=[$2], index=[$3])
    $(call f_project_attr_field_access_validate,$0,$2,array)

    $(word $3,$(rebuild_project_attr_types__$1__$2))
endef

# ($1): project-id, ($2): field-id, ($3): value, [($4): type-id]
define f_project_attr_array_append_for_project =
    $(call f_util_log_debug,$0: project-id=[$1], field-id=[$2], value=[$3], type-id=[$4])
    $(call f_project_attr_field_access_validate_critical,$0,$2,array)

    $(if $(call f_project_attr_field_is_typed,$2),\
		$(call f_project_attr_typed_field_access_validate_critical,$0,$2,$4)\
        $(call f_util_append_to_symbol,rebuild_project_attr_types__$1__$2,$4)\
        $(call f_project_attr_type_handler_call,$2,$4,$3),)

    $(call f_util_append_to_symbol,rebuild_project_attr_values__$1__$2,$3)
endef

# - f_project_attr_type_handler_call
# ($1): field-id, ($2): type-id, ($3): value
#
# - look up the attribute-type hook function associated with the given type,
#   and call it with the given value as a parameter
# - the type is passed along with the value so that one handler can be
#   assigned to multiple types
define f_project_attr_type_handler_call =
    $(call f_util_log_debug,$0: field-id=[$1], type-id=[$2], value=[$3])
    $(foreach __type,$(call f_typemap_type_ancestors_get,\
            $(call f_project_attr_field_typemap_id_get,$1),$2)\
        $(call $(rebuild_attr_type_handler__$1__$(__type)),$(__type),$3))
endef

define f_project_attr_fields_get =
    $(rebuild_defined_project_attr_fields)
endef

# ($1): field-id
define f_project_attr_field_typemap_id_get =
	project_attr_field__$1
endef

# ($1): field-id
define f_project_attr_field_types_get =
    $(call f_typemap_map_types_get,\
        $(call f_project_attr_field_typemap_id_get,$1))
endef

# ($1): field-id
define f_project_attr_field_is_defined =
    $(call f_util_list_contains_string,$(rebuild_defined_project_attr_fields),$1)
endef
# ($1): field-id
define f_project_attr_field_is_scalar =
    $(call f_util_string_equals,scalar,$(rebuild_project_attr_field_storage__$1))
endef

# ($1): field-id
define f_project_attr_field_is_map =
    $(call f_util_string_equals,map,$(rebuild_project_attr_field_storage__$1))
endef

# ($1): field-id
define f_project_attr_field_is_array =
    $(call f_util_string_equals,array,$(rebuild_project_attr_field_storage__$1))
endef

# ($1): field-id
define f_project_attr_field_storage_get =
    $(rebuild_project_attr_field_storage__$1)
endef

# ($1): field-id
define f_project_attr_field_is_typed =
    $(rebuild_project_attr_field_typed__$1)
endef

# ($1): field-id
define f_project_attr_field_is_defined =
	$(call f_util_list_contains_string,\
		$(call f_project_attr_fields_get),$1)
endef

# ($1): field-id, ($2): type-id
define f_project_attr_field_type_is_defined =
	$(call f_util_list_contains_string,\
		$(call f_project_attr_field_types_get,$1),$2)
endef

# - f_project_attr_field_access_validate
# ($1): caller-id, ($2): field-id, ($3): storage-class
#
# - assert field <field-id> is defined, and is of storage class <storage-class>
# - log a warning on failure
define f_project_attr_field_access_validate =
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_log_warn,f_project_attr_field_def_msg,$1,$2))
    $(if $(call f_project_attr_field_storage_do_validate,$2,$3),\
        $(call f_util_log_warn,$(call f_project_attr_field_storage_msg,$1,$2,$3)),)
endef

# - f_project_attr_field_access_validate_critical
# ($1): caller-id, ($2): field-id, ($3): storage-class
#
# - assert field <field-id> is defined, and is of storage class <storage-class>
# - halt and catch fire on failure
define f_project_attr_field_access_validate_critical =
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_fatal_error,f_project_attr_field_def_msg,$1,$2))
    $(if $(call f_project_attr_field_storage_do_validate,$2,$3),\
        $(call f_util_fatal_error,$(call f_project_attr_field_storage_msg,$1,$2,$3)),)
endef

# - f_project_attr_typed_field_access_validate_critical
# ($1): caller, ($2): field-id, ($3): type-id
#
# - assert type <type-id> is not null, and is a valid type for field <field-id>
# - halt and catch fire on failure
define f_project_attr_typed_field_access_validate_critical =
	$(if $2,,$(call f_util_fatal_error,$1: no type specified for typed field [$2]))
	$(if $(call f_typemap_type_is_member_of_map,\
            $(call f_project_attr_field_typemap_id_get,$2),$3),,\
	    $(call f_util_fatal_error,$1: type [$2] is not a registered type for attribute field [$2]))
endef

# ($1): field-id, ($2): storage-class
define f_project_attr_field_storage_do_validate =
    $(call f_util_string_equals,$(call f_project_attr_field_storage_get,$1)$2)
endef

# ($1): caller, ($2): field-id
define f_project_attr_field_def_msg =
    $1: invalid attribute field name [$2]
endef

# ($1): caller, ($2): field-id, ($3): storage-class
define f_project_attr_field_storage_msg =
    $1: field [$2] with storage [$(call f_project_attr_field_storage_get,$2)] passed to function with storage class [$3]
endef
