# module/base/typemap.mk
#
# enables the definition of types and type hierarchies

define f_typemap_map_define =
    $(call f_util_log_debug,f_typemap_map_define: map-id=[$1])
    $(call f_util_append_if_absent,rebuild_defined_typemaps,rebuild_typemap__$1)
endef

# ($1): map-id, ($2): type-id, ($3): parent-id
define f_typemap_type_define =
    $(call f_util_log_debug,f_typemap_type_define: map-id=[$1], type-id=[$2], parent-id=[$3])
    $(call f_util_append_if_absent,rebuild_typemap_types__$1,$2)
    $(if $3,\
		$(if $(call f_typemap_type_is_member_of_map,$1,$3))\
		$(call f_util_append_if_absent,rebuild_typemap_type_parent__$1__$2,$3),\
		$(call f_util_fatal_error,f_typemap_type_define: provided parent type [$3] is not a member of map [$1]))
endef

# ($1): map-id
f_typemap_map_types_get = $(rebuild_typemap_types__$1)

# ($1): map-id, ($2): type-id
f_typemap_type_parent_get = $(rebuild_typemap_type_parent__$1__$2)

# iterates recursively over type's parent types, starting from the base type
# ($1): map-id, ($2): type-id
define f_typemap_type_ancestors_get =
    $(call f_util_list_reverse,\
        $(call f_typemap_type_ancestors_get_descend,$1,$2))
endef

define f_typemap_type_ancestors_get_descend =
    $(call f_typemap_type_parent_get,$1,$2)
    $(call f_typemap_type_ancestors_get_descend,\
        $(call f_typemap_type_parent_get,$1,$2))
endef

# ($1): map-id, ($2): type-id
define f_typemap_type_is_member_of_map =
    $(if $(call f_util_list_contains_string,rebuild_defined_typemaps,$1),\
        $(call f_util_list_contains_string,rebuild_typemap_entries__$1,$2),)
endef

# shorthand alias for f_typemap_type_is_member_of_type
f_typemap_match = $(call f_typemap_type_is_member_of_type,$1,$2,$3)

# ($1): map-id, ($2): type-a, ($3): type-b
# returns nonempty result if type-a matches type-b or any of its parent types
define f_typemap_type_is_member_of_type =
    $(if $(call f_typemap_type_is_member_of_map,$1,$2),\
        $(if $(call f_typemap_type_is_member_of_map,$1,$3),\
            $(call f_typemap_match_inner,$1,$2,$3),),)
endef

# recursive part of type matching routine
define f_typemap_match_inner =
    $(if $(call f_util_string_equals,$2,$3),true,\
        $(if $(call f_typemap_type_parent_get,$1,$3),\
            $(call f_typemap_match_inner,$1,$2,$(call f_typemap_type_parent_get,$1,$3)),))
endef
