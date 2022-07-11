ifndef _MODULE_BASE
_MODULE_BASE = 1

#include $(_module_dir)/reference.mk
#include $(_module_dir)/resource.mk
#include $(_module_dir)/typemap.mk

rebuild_project_descriptor_fields += \
    project_traits \
    subproject_dirs

rebuild_subproject_paths = $(call f_base)

## module load function
define f_base_init =
    $(call f_util_load_file,$(_module_dir)/ref.mk)
    $(call f_util_load_file,$(_module_dir)/object_system.mk)
    $(call f_util_load_file,$(_module_dir)/reference.mk)
    $(call f_util_load_file,$(_module_dir)/resource.mk)
    $(call f_util_load_file,$(_module_dir)/typemap.mk)

    # define data types
    $(call f_typemap_map_define,)

    # define abstract project model
    $(call f_base_init_model)

    $(call f_project_attr_field_define,rebuild:resource,array,$(rb_true))
    $(call f_project_ref_field_define,rebuild:dependency,array,$(rb_true))
    $(call f_project_ref_field_define,rebuild:subproject,array,$(rb_true))

    # define project reference types
    $(call f_project_reference_field_define,rebuild:dependency,inherit,\
        f_base_handle_reftype_rebuild_dependency)
    $(call f_project_ref_type_define,rebuild:subproject,inherit,\
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
    $(call f_util_log_trace,f_base_system_load_hook)
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
        $(call f_util_fatal_error,\
                    could not locate project descriptor for project dependency [$1]))
endef

define f_base_handle_reftype_rebuild_subproject =
    $(if $(call f_rebuild_dir_is_project,$1),\
        $(call f_util_append_to_symbol,rebuild_defined_subprojects,$1)\
            $(call f_rebuild_load_subproject_descriptor,$1),\
        $(call f_util_fatal_error,\
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

# function: f_define_build_action(name)
# ->  register an action to be invoked during the build process,
#     along with automatic logging and optional pre/post hooks
# ->  [name] ($1): the name of the action to register
# ->  [handler] ($2): the name of the registered action handler;
#       defaults to 'f_do_[name]' if not specified
define f_define_build_action =
    $(call f_util_log_debug,f_define_build_action: $1 $2)
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
        $$(call f_util_log_info,$1: $$1)
    endef
endef

define f_rebuild_define_project_resource_root =
    $(call f_util_log_debug,f_rebuild_define_project_resource_root: project=[$1], path=[$2])
    $(call f_util_append_if_absent,rebuild_defined_resource_roots__$1,$2)
endef

define f_define_project_trait =
    $(call f_util_log_debug,f_define_project_trait: id=[$1], handler=[$2])
    $(call f_util_append_to_symbol,rebuild_defined_project_traits,$1)
    $(call f_util_set_symbol,rebuild_project_trait_handler__$(subst :,_,$1),$2)
endef

define f_project_trait_enable =
    $(call f_util_log_trace,f_project_trait_enable: trait=[$1])
    $(call f_project_trait_enable_for_project,$(rbproj_name),$1)
endef

define f_project_trait_enable_for_project =
    $(call f_util_log_trace,f_project_trait_enable: project=[$1] trait=[$2])
    $(call f_util_append_if_absent,rebuild_project_var__$1__project_traits,$2)
    $(call f_util_log_debug,trait [$1] enabled for project [$2])
endef

define f_project_trait_is_enabled =
    $(call f_project_trait_is_enabled_for_project,$1,$(rbproj_name))
endef

define f_project_trait_is_enabled_for_project =
    $(call f_util_list_contains_string,$1,$(rebuild_project_var__$2__project_traits))
endef

define f_activate_project_traits =
    $(call f_util_log_trace,f_activate_project_traits: traits=[$(rebuild_defined_project_traits)])
    $(foreach trait,$(rebuild_defined_project_traits),\
        $(if $(call f_project_trait_is_enabled,$(trait)),\
            $(call f_activate_project_trait,$(trait)),))
endef

define f_activate_project_trait =
    $(call $(rebuild_project_trait_handler__$1))
endef

endif
