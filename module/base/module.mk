ifndef _MODULE_BASE
_MODULE_BASE = 1

MOD_DIR_BASE=$(SCRIPT_MODULE_DIR)/base

rebuild_project_descriptor_fields += \
    project_traits \
    subproject_dirs

## module load function
define f_base_init =
    # define abstract project model
    $(call f_base_init_model)

    # define project reference types
    $(call f_define_project_reftype,rebuild:dependency,\
        f_base_handle_reftype_rebuild_dependency)
    $(call f_define_project_reftype,rebuild:subproject,\
        f_base_handle_reftype_rebuild_subproject)

    # define project traits
    $(call f_define_project_trait,rebuild:base,\
        f_base_activate_trait_rebuild_base)
    $(call f_define_project_trait,rebuild:parent,\
        f_base_activate_trait_rebuild_parent)
    
    # set load hook
    $(call f_rebuild_register_system_load_hook,f_base_system_load_hook)
endef

define f_base_system_load_hook =
    $(call f_activate_project_traits)
endef

define f_base_init_model =
    $(call f_define_build_action,compile)
    $(call f_define_build_action,build)
    $(call f_define_build_action,clean)
endef

define f_base_activate_trait_rebuild_base =
    $(foreach dir,$(rebuild_project_var_main_project_dependencies),\
        $(call f_define_project_ref,rebuild:dependency,$(dir)))
endef

define f_base_activate_trait_rebuild_parent =
    $(foreach dir,$(rebuild_project_var_main_subproject_dirs),\
        $(call f_define_project_ref,rebuild:subproject,$(dir)))
endef

define f_base_handle_reftype_rebuild_dependency =
    	$(call f_util_set_symbol,)
endef

define f_base_handle_reftype_rebuild_subproject =
    
endef

# search for project descriptors in the given directory, select one, and load it
define f_rebuild_load_subproject_descriptor =
    $(if $(call f_rebuild_dir_is_project,$1),\
        $(call f_rebuild_load_project_descriptor_from_file_with_prefix,subproject,$1/$(rbproj_name)),\
            $(call f_util_fatal_error,base,\
                        could not locate project descriptor for subproject [$1]))
endef

f_do_clean = $(call f_rm,$1)

# Set buildhost platform-specific options
ifeq ($(OS),Windows_NT)
    f2b = $(subst /,\,$1)
    f_mkdir = md $(call f2b,$1)
    f_cp=copy $(call f2b,$1)
    f_rm=rmdir /s /q $(call f2b,$1)
else
    f_mkdir=mkdir -p $1
    f_cp=cp $1
    f_rm=rm -rf $1
    SHELL=/bin/bash
endif

BUILD_DIR       = $(PROJECT_BASE)/build
OBJ_DIR         = $(BUILD_DIR)/obj
DIST_DIR        = $(BUILD_DIR)/dist

# function: f_define_build_action(name)
# ->  register an action to be invoked during the build process,
#     along with automatic logging and optional pre/post hooks
# ->  [name] ($1): the name of the action to register
# ->  [handler] ($2): the name of the registered action handler;
#       defaults to 'f_do_[name]' if not specified
define f_define_build_action =
    $(call f_util_log_debug,boot,f_define_build_action: $1 $2)
    $(eval $(call m_define_build_action,$1,$2))
endef
define m_define_build_action =
    define f_action_$1 =
        $$(call f_log_action_$1,$$1)
        $$(if f_pre_$1, $$(call f_pre_$1,$$1,$$2,$$3))
        $$(if $2, $$(call $2,$$1,$$2,$$3), $$(call f_do_$1,$$1,$$2,$$3))
        $$(if f_post_$1, $$(call f_post_$1,$$1,$$2,$$3))
    endef

    define f_log_action_$1 =
        $$(call f_util_log,info,$1: $$1)
    endef
endef

define f_define_project_attr_field =
    $(call f_util_log_debug,core,f_define_project_attr_field: field-id=[$1], field_type=[$2])
    $(call f_util_append_if_absent,rebuild_defined_project_attr_fields,$1)
    $(call f_util_append_if_absent,rebuild_defined_project_attr_field_type__$1,$2)
    $(if $(call f_util_string_equals,scalar,$2),\
            $(eval $(call m_define_project_attr_field_scalar,$1)),\
        $(if $(call f_util_string_equals,vector,$2),\
                $(eval $(call m_define_project_attr_field_vector,$1)),\
            $(call f_util_fatal_error,core,\
                attribute field [$1] has invalid type designation [$2])))
endef
# TODO: add type validation to f_define_project_attr_value__x
# ($1): field-id
define m_define_project_attr_field_vector =
    define f_define_project_attr_value__$1 =
        $$(call f_util_log_trace,base,\
            f_set_project_attr__$1: project=[$$1], field-id=[$$2], attrtype=[$$3], path=[$$4])
        $$(call f_util_append_to_symbol,rebuild_defined_project_attrs__$1__$$1,$$2)
        $$(call f_util_set_symbol,rebuild_project_attr_attrtype__$1__$$1__$$2,$$3)
        $$(call f_util_set_symbol,rebuild_project_attr__$1__$$1__$$2,$$4)
        $$(call f_call_attrtype_handler__$1,$$2,$$3)
    endef
    define f_define_project_attr_type__$1 =
        $$(call f_util_log_trace,base,\
            f_define_project_attrtype__$1: type-id=[$$1], handler=[$$2])
        $$(call f_util_append_to_symbol,rebuild_defined_project_attr_types__$1,$$1)
        $$(if $$2,$$(call f_util_set_symbol,\
            rebuild_attrtype_handler__$1__$$(subst :,_,$$1),$$2),)
    endef
    # ($$1): project-id
    define f_call_project_attrtype_handler__$1 =
        $$(if rebuild_attrtype_handler__$1__$$(subst :,_,$$1),\
            $$(call $$(rebuild_attrtype_handler__$1__$$(subst :,_,$$1)),$$2),)
    endef
endef

define f_define_project_restype =
    $(call f_util_log_debug,base,f_define_project_restype: id=[$1], handler=[$2])
    #$(call f_util_append_to_symbol,rebuild_defined_project_restypes,$1)
    #$(if $2,$(call f_util_set_symbol,rebuild_project_restype_handler__$(subst :,_,$1),$2),)
    $(call f_define_project_attr_type__rebuild_resource,$1,$2)
endef

define f_rebuild_call_project_restype_handler =
    #$(call $(rebuild_restype_handler__$1__$(subst :,_,$2)))
    $(call $(rebuild_attrtype_handler__rebuild_resource__$(subst :,_,$1)))
endef

rebuild_defined_project_resources__$1=$()

define f_define_project_resource =
    $(call f_util_log_debug,base,\
        f_define_project_resource: project=[$1], id=[$2], restype=[$3], path=[$4])
    $(call f_util_append_to_symbol,rebuild_defined_project_references__$1,$2)
    $(call f_util_set_symbol,rebuild_project_resource_restype__$1__$2,$3)
    $(call f_util_set_symbol,rebuild_project_resource__$1__$2,$4)
    $(call f_rebuild_call_project_restype_handler,$1,$3)
endef

define f_rebuild_project_resource_restype =
    $(rebuild_project_resource_restype__$1__$2)
endef

# ($1): project-id
# ($2): resource-id
define f_rebuild_project_resource =
    $(rebuild_project_resource__$1__$2)
endef

define f_rebuild_define_project_resource_root =
    $(call f_util_log_debug,base,\
        f_rebuild_define_project_resource_root: project=[$1], path=[$2])
    $(call f_util_append_if_absent,rebuild_defined_resource_roots__$1,$2)
endef

define f_define_project_reftype =
    $(call f_util_log_debug,base,f_define_project_reftype: id=[$1], handler=[$2])
    $(call f_util_append_to_symbol,rebuild_defined_reftypes,$1)
    $(if $2,$(call f_util_set_symbol,rebuild_reftype_handler__$(subst :,_,$1),$2),)
endef

# ($1): project-id
# ($2): reference-id
# ($1): reference-type
define f_rebuild_call_reftype_handler =
    $(call $(rebuild_reftype_handler__$3),$1,$2)
endef

define f_define_project_reference =
    $(call f_util_log_debug,base,f_define_project_reference: project=[$1] id=[$2], reftype=[$3], path=[$4])
    $(call f_util_append_to_symbol,rebuild_project_defined_refs__$1,$2)
    $(call f_util_set_symbol,rebuild_project_reference_reftype__$1__$2,$3)
    $(call f_util_set_symbol,rebuild_project_reference__$1__$2,$4)
    $(call f_rebuild_call_reftype_handler,$1,$2,$3)
endef

define f_rebuild_project_reference_reftype =
    $(rebuild_project_reference_reftype__$1__$2)
endef

define f_rebuild_project_reference =
    $(rebuild_project_reference__$1__$2)
endef

define f_define_project_trait =
    $(call f_util_log_debug,base,f_define_project_trait: id=[$1], handler=[$2])
    $(call f_util_append_to_symbol,rebuild_defined_project_traits,$1)
    $(call f_util_set_symbol,rebuild_project_trait_handler_$(subst :,_,$1),$2)
endef

define f_project_trait_is_enabled =
    $(call f_project_trait_is_enabled_for_project,$1,$(rebuild_main_project_name))
endef

define f_project_trait_is_enabled_for_project =
    $(call f_util_list_contains_string,$1,$(rebuild_project_var_$2_project_traits))
endef

define f_activate_project_traits =
    $(foreach trait,$(rebuild_defined_project_traits),\
        $(if $(call f_project_trait_is_enabled,$(trait)),\
            $(call f_activate_project_trait,$(trait)),))
endef

define f_activate_project_trait =
    $(call $(rebuild_project_trait_handler_$1))
endef

endif
