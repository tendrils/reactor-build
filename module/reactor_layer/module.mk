ifndef _MODULE_REACTOR_LAYER
_MODULE_REACTOR_LAYER = 1

mod_deps_reactor_layer=aggregate

rebuild_defined_project_traits+=reactor:layer

reactor_module_product_lib_prefix=mod
reactor_module_product_lib_suffix_static=.a
reactor_module_product_lib_suffix_dynamic=.so

rebuild_source_module_dir=$(BASE)/module
reactor_module_project_paths=\
	$(foreach dir,$(rebuild_subproject_dirs),\
		$(if $(call f_subproject_is_reactor_module,$(dir)),$(dir),))
reactor_module_project_names=$(reactor_module_project_paths:$(SOURCE_MODULE_DIR)/%=%)
reactor_module_product_names=$(reactor_module_source_names:%=$(PRODUCT_MODULE_PREFIX)%.$(PRODUCT_MODULE_SUFFIX))

SUBPRODUCTS+=$(PRODUCT_MODULE_FILES)

## module load function
define f_reactor_module_init =
	$(call f_util_set_symbol,reactor_module_project_paths,\
		$(foreach dir,$(rebuild_subproject_paths),\
			$(if $(call f_subproject_is_reactor_module,$(dir)),$(dir),)))
	$(call f_util_set_symbol,reactor_module_project_names,\
		$(foreach dir,$(reactor_module_project_paths),\
			$(call f_reactor_module_project_name_get,$(dir))))
endef

define f_reactor_module_project_name_get =
	
endef

endif
