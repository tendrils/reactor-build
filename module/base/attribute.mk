# module/base/attribute.mk
#
# basic framework on which all project metadata attributes are built

# ($1): field-id
define f_project_attr_scalar_value_get =
    $(call f_project_attr_scalar_value_get_for_project,main,$1)
endef

# ($1): field-id
define f_project_attr_scalar_type_get =
    $(call f_project_attr_scalar_type_get_for_project,main,$1)
endef

# ($1): field-id, ($2): value, [($3): type-id]
define f_project_attr_scalar_value_set =
    $(call f_project_attr_scalar_value_set_for_project,main,$1,$2,$3)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_scalar_value_get_for_project =
    $(call f_util_log_trace,\
        f_project_attr_scalar_value_get_for_project: project-id=[$1], field-id=[$2])
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_log_warn,\
			f_project_attr_scalar_value_get_for_project: invalid attribute field name [$1]))
    $(if $(call f_project_attr_field_is_vector,$2),\
        $(call f_util_log_warn,\
            f_project_attr_scalar_value_get_for_project: vector field [$2] passed to scalar function),)
    $(rebuild_project_attr_value__$1__$2)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_scalar_type_get_for_project =
    $(call f_util_log_trace,\
        f_project_attr_scalar_type_get_for_project: project-id=[$1], field-id=[$2])
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_log_warn,\
			f_project_attr_scalar_type_get_for_project: invalid attribute field name [$1]))
    $(if $(call f_project_attr_field_is_vector,$2),\
        $(call f_util_log_warn,\
            f_project_attr_scalar_type_get_for_project: vector field [$2] passed to scalar function),)
    $(rebuild_project_attr_type__$1__$2)
endef

# ($1): project-id, ($2): field-id, ($3): value, [($4): type-id]
define f_project_attr_scalar_value_set_for_project =
    $(call f_util_log_debug,\
        f_project_attr_scalar_value_set_for_project: project-id=[$1], field-id=[$2], value=[$3], type-id=[$4])
	$(if $(call f_project_attr_field_is_vector,$2),\
		$(call f_util_fatal_error,f_project_attr_scalar_value_set_for_project: vector field [$2] passed to scalar function),)
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_fatal_error,f_project_attr_scalar_value_set_for_project: invalid attribute field name [$1]))
    
    $(call f_util_set_symbol,rebuild_project_attr_value__$1__$2,$3)

    $(if $(call f_project_attr_field_is_typed,$2),\
		$(if $(call f_typemap_type_is_member_of_map,\
			$(call f_project_attr_field_typemap_id_get,$2),$4),\
        $(call f_util_set_symbol,rebuild_project_attr_type__$1__$2,$4)\
        $(call f_project_attr_type_handler_call,$1,$2,$3,$4),\
		$(call f_util_fatal_error,f_project_attr_scalar_value_set_for_project: type [$4] is not a registered type for attribute field [$2])),)
endef

# ($1): field-id
define f_project_attr_vector_values_get =
    $(call f_project_attr_vector_values_get_for_project,main,$1)
endef

# ($1): field-id, ($2): value-id
define f_project_attr_vector_value_get =
    $(call f_project_attr_vector_value_get_for_project,main,$1,$2)
endef

# ($1): field-id, ($2): value-id
define f_project_attr_vector_type_get =
    $(call f_project_attr_vector_type_get_for_project,main,$1,$2)
endef

# ($1): field-id, ($2): value-id, ($3): value, [($4): type-id]
define f_project_attr_vector_value_set =
    $(call f_project_attr_vector_value_set_for_project,main,$1,$2,$3,$4)
endef

# ($1): project-id, ($2): field-id
define f_project_attr_vector_values_get_for_project =
    $(call f_util_log_trace,\
        f_project_attr_vector_value_get_for_project: project-id=[$1], field-id=[$2], value-id=[$3])
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_log_warn,\
			f_project_attr_vector_value_get_for_project: invalid attribute field name [$1]))
    $(if $(call f_project_attr_field_is_vector,$2),\
        $(call f_util_log_warn,\
            f_project_attr_vector_value_get_for_project: vector field [$2] passed to scalar function),)
    $(rebuild_project_attr_values__$1__$2)
endef

# ($1): project-id, ($2): field-id, ($3): value-id
define f_project_attr_vector_value_get_for_project =
    $(call f_util_log_trace,\
        f_project_attr_vector_value_get_for_project: project-id=[$1], field-id=[$2], value-id=[$3])
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_log_warn,\
			f_project_attr_vector_value_get_for_project: invalid attribute field name [$1]))
    $(if $(call f_project_attr_field_is_vector,$2),\
        $(call f_util_log_warn,\
            f_project_attr_vector_value_get_for_project: vector field [$2] passed to scalar function),)
    $(rebuild_project_attr_value__$1__$2__$3)
endef

# ($1): project-id, ($2): field-id, ($3): value-id
define f_project_attr_vector_type_get_for_project =
    $(call f_util_log_trace,\
        f_project_attr_vector_type_get_for_project: project-id=[$1], field-id=[$2])
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_log_warn,\
			f_project_attr_vector_type_get_for_project: invalid attribute field name [$1]))
    $(if $(call f_project_attr_field_is_vector,$2),\
        $(call f_util_log_warn,\
            f_project_attr_vector_type_get_for_project: vector field [$2] passed to scalar function),)
    $(rebuild_project_attr_type__$1__$2__$3)
endef

# ($1): project-id, ($2): field-id, ($3): value-id ($4): value, [($5): type-id]
define f_project_attr_vector_value_set_for_project =
    $(call f_util_log_debug,\
        f_project_attr_vector_value_set_for_project: project-id=[$1], field-id=[$2], value-id=[$3] value=[$4], type-id=[$5])
	$(if $(call f_project_attr_field_is_vector,$2),,\
		$(call f_util_fatal_error,f_project_attr_vector_value_set_for_project: scalar field [$2] passed to vector function),)
    $(if $(call f_project_attr_field_is_defined,$2),,\
        $(call f_util_fatal_error,f_project_attr_vector_value_set_for_project: invalid attribute field name [$1]))

    $(call f_util_append_if_absent,rebuild_project_attr_values__$1__$2,$3)
    $(call f_util_set_symbol,rebuild_project_attr_value__$1__$2__$3,$4)

    $(if $(call f_project_attr_field_is_typed,$2),\
		$(if $(call f_typemap_type_is_member_of_map,\
                $(call f_project_attr_field_typemap_id_get,$2),$4),\
            $(call f_util_set_symbol,rebuild_project_attr_type__$1__$2__$3,$4)\
            $(call f_project_attr_type_handler_call,$1,$2,$4,$5),\
		    $(call f_util_fatal_error,f_project_attr_vector_value_set_for_project: type [$5] is not a registered type for attribute field [$2])),)

endef

# - f_project_attr_type_handler_call
# ($1): field-id, ($2): type-id, ($3): value
#
# - look up the attribute-type hook function associated with the given type,
# and call it with the given value as a parameter
# - the type is passed along with the value so that one handler can be
# assigned to multiple types
# TODO: call handlers for all parent types in order
define f_project_attr_type_handler_call =
    $(foreach __type,$(call f_typemap_type_ancestors_get,\
            $(call f_project_attr_field_typemap_id_get,$1),$2)\
        $(call $(rebuild_attr_type_handler__$1__$(__type)),$(__type),$3))
endef

define f_project_attr_field_define =
    $(call f_util_log_debug,\
        f_project_attr_field_define: field-id=[$1], field-is-vector=[$2], field-is-typed=[$3])
    $(call f_util_append_if_absent,rebuild_defined_project_attr_fields,$1)
    $(if $2,\
        $(call f_util_set_symbol,rebuild_project_attr_field_vector__$1,true),)
    $(if $3,\
        $(call f_util_set_symbol,rebuild_project_attr_field_typed__$1,true)\
		$(call f_typemap_map_define,\
			$(call f_project_attr_field_typemap_id_get,$1)),)
endef

# ($1): field-id, ($2): type-id, [($3): parent-id], [($4): handler]
define f_project_attr_type_define =
    $(call f_util_log_debug,\
        f_project_attr_type_define: field-id=[$1], type-id=[$2], parent-id=[$3], handler=[$4])
    $(call f_typemap_type_define,\
        $(call f_project_attr_field_typemap_id_get,$1),$2,$3)
    $(if $4,\
        $(call f_util_set_symbol,rebuild_attr_type_handler__$1__$2,$4),)
endef

define f_project_attr_fields_get =
    $(rebuild_defined_project_attr_fields)
endef

define f_project_attr_field_typemap_id_get =
	project_attr_field__$1
endef

# ($1): field-id
define f_project_attr_field_types_get =
    $(call f_typemap_map_types_get,\
        $(call f_project_attr_field_typemap_id_get,$1))
endef

# ($1): field-id
define f_project_attr_field_is_vector =
    $(rebuild_project_attr_field_vector__$1)
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
