ifndef _MODULE_BASE
_MODULE_BASE = 1

MOD_DIR_BASE=$(SCRIPT_MODULE_DIR)/base

rebuild_project_descriptor_fields += \
    project_traits \
    subproject_dirs

## module load function
define f_base_init =
    $(call f_base_init_model)
    $(call f_define_project_reftype,dependency)
    $(call f_define_project_reftype,subproject)
    $(call f_define_project_trait,rebuild:base,\
        f_base_activate_trait_rebuild_base)
    $(call f_define_project_trait,rebuild:parent,\
        f_base_activate_trait_rebuild_parent)
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

endef

define f_base_activate_trait_rebuild_parent =
    $(foreach dir,$(subproject_dirs),\
        $(call f_define_project_ref,subproject,$(dir)))
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

define f_define_project_reftype =
    $(call f_util_log_debug,base,f_define_project_reftype: name[$1], reftype[$2])
    $(call f_util_append_to_symbol,rebuild_defined_project_reftypes,$1)
    $(call f_util_set_symbol,rebuild_project_reftype_$(subst :,_,$1),$2)
endef

define f_define_project_ref =
    $(call f_util_log_debug,base,f_define_project_ref: name=[$1], reftype=[$2], ref=[$3])
    $(call f_util_append_to_symbol,rebuild_defined_project_refs,$1)
    $(call f_util_set_symbol,rebuild_project_ref_reftype_$1,$2)
    $(call f_util_set_symbol,rebuild_project_ref_$1,$3)
endef

define f_rebuild_project_reftype =
    $(rebuild_project_reftype_$1)
endef

define f_rebuild_project_ref =
    $(rebuild_project_ref_$1)
endef

define f_define_project_trait =
    $(call f_util_log_debug,base,f_define_project_trait: name[$1], handler[$2])
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
