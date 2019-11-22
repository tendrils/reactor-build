ifndef _MODULE_REACTOR_LAYER
_MODULE_REACTOR_LAYER = 1

mod_deps_reactor_layer=reactor_module

rebuild_defined_project_traits+=reactor:layer

SUBPRODUCTS+=$(PRODUCT_MODULE_FILES)

## module load function
define f_reactor_layer_init =
	$(if $(call f_project_trait_is_enabled,rebuild:parent),\
		$(call f_reactor_layer_init_composite),)
endef

define f_reactor_layer_init_composite =
	$(call f_util_set_symbol,reactor_module_project_paths,\
		$(foreach dir,$(rebuild_subproject_paths),\
			$(if $(call f_subproject_is_reactor_module,$(dir)),$(dir),)))
	$(call f_util_set_symbol,reactor_module_project_names,\
		$(foreach dir,$(reactor_module_project_paths),\
			$(call f_reactor_module_project_name_get,$(dir))))
endef

endif
