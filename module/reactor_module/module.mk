ifndef _MODULE_REACTOR_MODULE
_MODULE_REACTOR_MODULE = 1

mod_deps_reactor_module=c_binary

#rebuild_project_descriptor_fields+=
rebuild_defined_project_traits+=reactor:module

reactor_module_product_lib_prefix=mod
reactor_module_product_lib_suffix_static=.a
reactor_module_product_lib_suffix_dynamic=.so

SUBPRODUCTS+=$(PRODUCT_MODULE_FILES)

## module load function
define f_reactor_module_init =
	$(call f_util_set_symbol,reactor_module_project_paths,\
		$(foreach dir,$(rebuild_subproject_paths),\
			$(if $(call f_subproject_is_reactor_module,$(dir)),$(dir),)))
	$(call f_util_set_symbol,reactor_module_project_names,\
		$(foreach dir,$(reactor_module_project_paths),\
			$(call f_reactor_module_project_name_get,$(dir))))
	$(call f_util_set_symbol,reactor_module_product_names,\
		$(foreach dir,$(reactor_module_project_paths),\
			$(call f_reactor_module_product_name_get,$(dir))))
endef

define f_reactor_module_project_name_get =

endef

endif
