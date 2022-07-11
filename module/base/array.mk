# Array data type support

f_core_ref_array_p = $(call f_core_var_array_p,$($1))

# + f_core_array_literal_parse
# > split source string into a space-separated list
# of tokens, then recursively parse the token stream.
# parsed arrays are returned as object references,
# function returns a reference to the root array
define f_core_array_literal_parse =
    $(call _let,__source,
        $(subst $(_lparen), $(_lparen) ,
        $(subst $(_rparen), $(_rparen) , $1)))
    $(call _let,__count,0)
    $(foreach __token,__source,
        $(if $(call _equals,$(__token),$(_lparen),
            $(call f_util_int_increment,__count)))
        $(if $(call _equals,$(__token),$(_rparen),
            $(if $(call lte,$(__count),0),
                $(call _let,__error,syntax error),
                $(call f_util_int_decrement,__count)))
            ))

endef

define f_core_var_is_array =
    $(call f_util_string_equals,
        $(firstword $(subst <,$(_space),
        $(call f_core_var_get_type,$1))),array)
endef

# + f_core_array_create
# > instantiate a new array object, returning a reference
# to the newly created array
define f_core_array_create =
    $(call _trace,($0): content_type:[$1])
    $(call _let,__ref,$(call f_core_ref_allocate))
    $(if $1,$(call _let,__ctype,$1),$(call _let,__ctype,any))
    $(call _let,rebuild_ref_type__$(__ref),array<$(__ctype)>)
    $(__ref)
    $(call _clear,__ref)
endef

# + f_core_array_add
# > adds the given (raw) value to the referenced array, checking
# that the item matches the array's type specifier
define f_core_array_add =
    $(call _trace,($0): array_refid:[$1], new_value:[$2])
    $(if $(call f_core_val_get_type))
    $(call _append,rebuild_array__$1,$2)
endef
