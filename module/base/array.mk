# Array data type support

f_core_ref_array_p = $(call f_core_var_array_p,$($1))

# + f_core_array_literal_parse
# > split source string into a space-separated list
# of tokens, then recursively parse the token stream.
# parsed arrays are returned as object references,
# function returns
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
                $(call _let,__error,syntax error)))))

endef

define f_core_var_is_array =
    $(call f_util_string_equals,
        $(firstword $(subst <,$(_space),
        $(call f_core_var_get_type,$1))),array)
endef

define f_core_array_define =

endef
