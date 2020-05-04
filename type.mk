# rebuild/context.mk

rbconst_typemap_inherit_none = none
rbconst_typemap_inherit_single = single
rbconst_typemap_inherit_multiple = multiple

# typemap accessor functions
f_core_typemap_inherit_get = $(rebuild_typemap_inherit__$1)
f_core_typemap_inherit_is_none = $(call f_util_string_equals,\
    $(call f_core_typemap_inherit_get,$1),rbconst_typemap_inherit_none)
f_core_typemap_inherit_is_single = $(call f_util_string_equals,\
    $(call f_core_typemap_inherit_get,$1),rbconst_typemap_inherit_single)
f_core_typemap_inherit_is_multi = $(call f_util_string_equals,\
    $(call f_core_typemap_inherit_get,$1),rbconst_typemap_inherit_multiple)

f_core_typemap_transitive_id_get = $(rebuild_typemap_transitive_id__$1)

define f_core_typemap_supports_inheritance =
    $(call f_core_typemap_inherit_is_single,$1)
    $(call f_core_typemap_inherit_is_multi,$1)
endef

# type accessor functions
f_core_type_typemap_get = $(rebuild_type_parent_typemap__$1)

define f_core_typemap_define =
    $(call f_util_log_trace,f_core_typemap_define: [name = $1, inherit = $2, transitive-id = $3])
    $(call f_util_append_if_absent,rebuild_defined_typemaps,$1)
    $(call f_util_set_symbol,rebuild_typemap_inherit__$1,$2)
    $(call f_util_set_symbol,rebuild_typemap_transitive_id__$1,$(if $3,$3,$(rbconst_typemap_inherit_none)))
endef

define f_core_type_define_for_typemap =
    $(call f_util_log_trace,f_core_type_define: [typemap = $1, type = $2, ancestors = $3])
    $(call f_util_set_symbol,__inherit,$(f_core_typemap_inherit,$1))
    $(if $(call f_util_string_equals,$(__inherit),$(rbconst_typemap_inherit_none)),,\
        $(call f_util_set_symbol,rebuild_type_ancestor_types__$2,$3))
    $(call f_util_unset_symbol,__inherit)
endef

# function: f_core_type_has_parent
#   - recursively checks whether type-B is a member of type-A's inheritance tree
#   - TODO: improve cycle-detection to handle edge case where type-A === type-B,
#           and type-A is also a transitive parent of itself
# ($1): type-A
# ($2): type-B
define f_core_type_has_parent =
    $(foreach __parent,$(f_core_type_parents_get,$1),\
        $(if $(call f_util_list_contains_string,$(__parent),$(__seen)),,\
            $(call f_util_append_to_symbol,__seen,$(__parent))\
            $(call f_util_string_equals,$(__parent),$2)\
            $(if $(call f_util_string_equals,$(__parent),$2),,\
                $(call f_core_type_has_parent,$(__parent),$2))))
    $(call f_util_unset_symbol,__seen)
endef

# function: f_core_type_is_identical_to
#   - returns whether type-B is a member of type-A, directly or transitively
# ($1): type-A
# ($2): type-B
define f_core_type_is_identical_to =
    # takes the union of a series of assertions; if all fail, evaluates to nil
    
    # assertion-1: [type-A] is equal to [type-B]
    $(call f_util_string_equals,$1,$2)

    # assertion-2: [type-A] and [type-B] are members of the same typemap,
    #               AND typemap supports inheritance,
    #               AND [type-B] is included in [type-A]'s ancestor types
    $(call f_util_reset_symbol,__typemap_a,$(call f_core_type_typemap_get,$1))
    $(call f_util_reset_symbol,__typemap_b,$(call f_core_type_typemap_get,$2))
    $(if $(call f_util_string_equals,$(__typemap_a),$(__typemap_b)),\
        $(if $(call f_core_typemap_supports_inheritance,$(__typemap_a)),\
            $(call f_core_type_has_parent,$1,$2),),)

    $(call f_util_unset_symbol,__typemap_a)
    $(call f_util_unset_symbol,__typemap_b)
endef
