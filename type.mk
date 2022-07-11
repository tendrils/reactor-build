# rebuild/type.mk

#   types are global symbols which can belong to exactly one
# typemap at any time. inheritance is a property of the
# containing typemap, and can be single, multiple, or none.
# type identity is also a property of the typemap, and
# may be either transitive or not. instances of types in a
# transitive typemap are considered members of any type from
# which they inherit.

rbconst_typemap_inherit_none = none
rbconst_typemap_inherit_single = single
rbconst_typemap_inherit_multiple = multiple

# typemap accessor functions
f_core_typemap_inheritance = $(rebuild_typemap_inheritance__$1)
f_core_typemap_inherit_none = $(call _equals,\
    $(call f_core_typemap_inheritance,$1),rbconst_typemap_inherit_none)
f_core_typemap_inherit_single = $(call _equals,\
    $(call f_core_typemap_inheritance,$1),rbconst_typemap_inherit_single)
f_core_typemap_inherit_multi = $(call _equals,\
    $(call f_core_typemap_inheritance,$1),rbconst_typemap_inherit_multiple)

f_core_typemap_transitive = $(rebuild_typemap_transitive__$1)

define f_core_typemap_supports_inheritance =
    $(call f_core_typemap_inherit_single,$1)
    $(call f_core_typemap_inherit_multi,$1)
endef

# type accessor functions
f_core_type_typemap_get = $(rebuild_type_parent_typemap__$1)

define f_core_typemap_define =
    $(call _trace,($0): [name = $1, inherit = $2, transitive-id = $3])
    $(call _append,rebuild_defined_typemaps,$1)
    $(call _set,rebuild_typemap_inheritance__$1,$2)
    $(call _set,rebuild_typemap_transitive__$1,$(if $3,$3,$(rbconst_typemap_inherit_none)))
endef

define f_core_type_define_for_typemap =
    $(call _trace,($0): typemap:[$1], type:[$2], parent_types:[$3])
    $(call _let,__inherit,$(f_core_typemap_inheritance,$1))
    $(if $(call _equals,$(__inherit),$(rbconst_typemap_inherit_none)),,\
        $(if $(call _equals,$(__inherit),$(rbconst_typemap_inherit_single)),
            $(if $(call gt,$(words $3),1),
                $(call _fatal,Multiple parent types supplied for single-inherit type $1)
            ,)
            $(call _set,rebuild_type_parent_types__$2,$3)
        )
    )
    $(call _clear,__inherit) 
endef

#   return the immediate parent types of the given type
define f_core_type_parents =
    $(rebuild_type_parent_types__$1)
endef

#   recursively list all types above this one in the hierarchy
define f_core_type_ancestors =
    $(sort $(call f_core_type_ancestors_recursive,$1))
endef
define f_core_type_ancestors_recursive =
    $(call _let,__seen,$2)
    $(foreach __parent,$(call f_core_type_parents,$1),
        $(if $(call _contains,$(__parent),$2),,
            $(call _append,__seen,$(__parent))
            $(__parent)$(call f_core_type_ancestors,$(__parent),$(__seen))
        )
    )
endef

# function: f_core_type_has_parent
#   - recursively checks whether type-B is a member of type-A's inheritance tree
# ($1): type-A
# ($2): type-B
define f_core_type_has_parent =
    $(call _contains,$2,$(call f_core_type_ancestors,$1))
endef

# function: f_core_type_is_member_of
# ($1): type-A, ($2): type-B
#   - returns whether type-B is a member of type-A, directly or transitively
#   - takes the union of a series of assertions; if all fail, evaluates to nil
# assertion-1: [type-A] is equal to [type-B]
# assertion-2: [type-A] and [type-B] are members of the same typemap,
#               AND typemap supports inheritance,
#               AND [type-B] is included in [type-A]'s ancestor types
define f_core_type_is_member_of =
    $(call f_util_string_equals,$1,$2)

    $(call _let,__typemap_a,$(call f_core_type_typemap_get,$1))
    $(call _let,__typemap_b,$(call f_core_type_typemap_get,$2))
    $(if $(call _equals,$(__typemap_a),$(__typemap_b)),\
        $(if $(call f_core_typemap_supports_inheritance,$(__typemap_a)),\
            $(call f_core_type_has_parent,$1,$2)
        ,)
    ,)

    $(call _clear,__typemap_a)
    $(call _clear,__typemap_b)
endef
