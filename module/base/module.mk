ifndef _MODULE_BASE
_MODULE_BASE = 1

include $(_module_dir)/reference.mk
include $(_module_dir)/resource.mk

rebuild_project_descriptor_fields += \
    project_traits \
    subproject_dirs

## module load function
define f_base_init =
    # define abstract project model
    $(call f_base_init_model)

    $(call f_define_project_attr_field,rebuild:resource,vector)
    $(call f_define_project_attr_field,rebuild:reference,vector)

    # define base project reference type families
    $(call f_define_type_map,rebuild:resource)
    $(call f_define_type_map,rebuild:reference)

    # define project reference types
    $(call f_define_project_reftype,rebuild:dependency,inherit,\
        f_base_handle_reftype_rebuild_dependency)
    $(call f_define_project_reftype,rebuild:subproject,inherit,\
        f_base_handle_reftype_rebuild_subproject)

    # define project traits
    $(call f_define_project_trait,rebuild:base,\
        f_base_activate_trait_rebuild_base)
    $(call f_define_project_trait,rebuild:parent,\
        f_base_activate_trait_rebuild_parent)
    
    # set load hook
    $(call f_core_register_system_load_hook,f_base_system_load_hook)
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
    $(if $(call f_rebuild_dir_is_project,$1),\
        $(call f_util_append_to_symbol,rebuild_defined_project_dependencies,$1)\
            $(call f_rebuild_load_dependency_project_descriptor,$1),\
        $(call f_util_fatal_error,base,\
                    could not locate project descriptor for project dependency [$1]))
endef

define f_base_handle_reftype_rebuild_subproject =
    $(if $(call f_rebuild_dir_is_project,$1),\
        $(call f_util_append_to_symbol,rebuild_defined_subprojects,$1)\
            $(call f_rebuild_load_subproject_descriptor,$1),\
        $(call f_util_fatal_error,base,\
                    could not locate project descriptor for subproject [$1]))
endef

define f_rebuild_load_subproject_descriptor =
    $(call f_rebuild_load_project_descriptor_from_file_with_prefix,\
        $(call f_base_get_prefix,subproject__$1),$1/$(rbproj_name))
endef

f_base_get_prefix = $(subst /,_,$1)

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

define f_define_system_type_map =
    $(call f_util_log_debug,core,f_define_system_type_map: map-id=[$1])
    $(call f_util_append_if_absent,rebuild_defined_system_type_maps,$1)
endef

define f_define_system_type_entry =
    $(call f_util_log_debug,core,\
        f_define_system_type_entry: map-id=[$1], type-id=[$2], parent-id=[$3])
    $(call f_util_append_if_absent,rebuild_defined_system_type_map__$1,$2)
    $(if $3,$(call f_util_append_if_absent,rebuild_defined_system_type_map_parent__$1__$2,$3),)
endef

define f_define_project_attr_field =
    $(call f_util_log_debug,core,\
        f_define_project_attr_field: field-id=[$1], field-is-vector=[$2], field-is-typed=[$3])
    $(call f_util_append_if_absent,rebuild_defined_project_attr_fields,$1)
    $(call f_util_append_if_absent,rebuild_defined_project_attr_field_type__$1,$2)
    $(if $(call f_util_string_equals,scalar,$2),\
            $(eval $(call m_define_project_attr_field_scalar,$1,$3)),\
        $(if $(call f_util_string_equals,vector,$2),\
                $(eval $(call m_define_project_attr_field_vector,$1,$3)),\
            $(call f_util_fatal_error,core,\
                attribute field [$1] has invalid type designation [$2] (expected: [scalar|vector]))))
endef

# early-binding variables:
# ($1): field-id, ($2): field-is-typed
define m_define_project_attr_field_scalar =
    f_rebuild_project_attr_value_get__$1 = $(rebuild_project_attr_value__$1__$$1)
    f_rebuild_project_attr_type_get__$1 = $(rebuild_project_attr_type__$1__$$1)

    # ($$1): project-id, ($$2): attr-type, ($$3): attr-value
    define f_define_project_attr_value__$1 =
        $$(call f_util_log_trace,base,\
            f_define_project_attr_value__$1: project-id=[$$1], attr-type=[$$2], attr-value=[$$3])
        $$(call f_util_set_symbol,rebuild_project_attr_type__$1__$$1,$$2)
        $$(call f_util_set_symbol,rebuild_project_attr_value__$1__$$1,$$3)
        $$(call f_call_project_attr_type_handler__$1,$$1,$$2,$$3)
    endef

    # ($$1): type-id, ($$2): type-handler
    define f_define_project_attr_type__$1 =
        $$(call f_util_log_trace,base,\
            f_define_project_attr_type__$1: type-id=[$$1], handler=[$$2])
        $$(call f_util_append_to_symbol,rebuild_defined_project_attr_types__$1,$$1)
        $$(if $$2,$$(call f_util_set_symbol,\
            rebuild_attr_type_handler__$1__$$(subst :,_,$$1),$$2),)
    endef

    # ($$1): project-id, ($$2): attr-type, ($$3): attr-value
    define f_call_project_attr_type_handler__$1 =
        $$(if rebuild_attr_type_handler__$1__$$(subst :,_,$$1),\
            $$(call $$(rebuild_attr_type_handler__$1__$$(subst :,_,$$1)),$$2),)
    endef
endef

# TODO: add type validation to f_define_project_attr_value__x
# ($1): field-id
define m_define_project_attr_field_vector =
    f_rebuild_project_attr_value_get__$1 = $(rebuild_project_attr_value__$1__$$1__$$2)
    f_rebuild_project_attr_type_get__$1 = $(rebuild_project_attr_type__$1__$$1__$$2)
    define f_define_project_attr_value__$1 =
        $$(call f_util_log_trace,base,\
            f_define_project_attr_value__$1: project=[$$1], attr-id=[$$2], attrtype=[$$3], path=[$$4])
        $$(if $$(call f_util_list_contains_string,$$2,rebuild_defined_project_attrs__$1__$$1),,\
            $$(call f_util_append_to_symbol,rebuild_defined_project_attrs__$1__$$1,$$2))
        $$(call f_util_set_symbol,rebuild_project_attr_type__$1__$$1__$$2,$$3)
        $$(call f_util_set_symbol,rebuild_project_attr_value__$1__$$1__$$2,$$4)
        $$(call f_call_project_attr_type_handler__$1,$$2,$$3)
    endef
    define f_define_project_attr_type__$1 =
        $$(call f_util_log_trace,base,\
            f_define_project_attr_type__$1: type-id=[$$1], handler=[$$2])
        $$(call f_util_append_to_symbol,rebuild_defined_project_attr_types__$1,$$1)
        $$(if $$2,$$(call f_util_set_symbol,\
            rebuild_attr_type_handler__$1__$$(subst :,_,$$1),$$2),)
    endef
    # ($$1): project-id
    define f_call_project_attr_type_handler__$1 =
        $$(if rebuild_attr_type_handler__$1__$$(subst :,_,$$1),\
            $$(call $$(rebuild_attr_type_handler__$1__$$(subst :,_,$$1)),$$2),)
    endef
endef

define f_rebuild_define_project_resource_root =
    $(call f_util_log_debug,base,\
        f_rebuild_define_project_resource_root: project=[$1], path=[$2])
    $(call f_util_append_if_absent,rebuild_defined_resource_roots__$1,$2)
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
