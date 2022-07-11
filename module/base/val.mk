#	base/val.mk
#	functions related to raw data values

c_format_sep := ::
c_header_sep := <:>

# value encoding functions
define f_core_val_get_format =
    $(call f_util_list_head,
        $(subst $(c_format_sep),$(_space),
            $(call f_core_val_header,$1)))
endef
define f_core_val_get_type =
    $(call f_util_list_tail,
        $(subst $(c_format_sep),$(_space),
            $(call f_core_val_header,$1)))
endef
define f_core_val_get_type_root =
    $(call f_util_list_head,$(subst <,$(_space),
        $(call f_core_val_get_type,$1)))
endef
define f_core_val_get_header =
    $(call f_util_list_head,
        $(subst $(c_header_sep),$(_space),$1))
endef
define f_core_val_get =
    $(call f_util_list_tail,
        $(subst $(c_header_sep),$(_space),$1))
endef

#   value predicates
define f_core_val_format_is_p =
    $(call f_util_string_equals,
        $(call f_core_val_get_format,$1),$2)
endef
define f_core_val_type_is_p =
    $(call f_util_string_equals,
        $(call f_core_val_get_type,$1),$2)
endef
