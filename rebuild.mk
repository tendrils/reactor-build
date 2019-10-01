ifndef _REBUILD_MAIN
_REBUILD_MAIN = 1

auto: default

# Set default configuration and resolve project paths
CONF_DEFAULT_DEFAULT := reference-platform

rebuild_dir_main = $(CURDIR)

rebuild_root_project    := $(realpath .)
rebuild_ext_resource_root           := $(realpath $(rebuild_base)/../../resource)
rebuild_conf_base       = $(rebuild_base)/conf
rebuild_conf_dir        = $(rebuild_conf_base)/$(rebuild_conf)
PLATFORM_DIR            = $(BASE)/platform
MODULE_DIR              = $(BASE)/module
rebuild_home        = $(rebuild_dir_main)/rebuild
rebuild_module_dir  = $(rebuild_home)/module

# shorthand aliases for symbols often used in expressions
rbproj_root = $(rebuild_root_project)

# Load host and target configuration files
-include $(CONF_BASE)/build-host.conf
include $(CONF_BASE)/build-host.default.conf

include $(rebuild_home)/util.mk
include $(rebuild_home)/tasks.mk

define f_util_load_build_module_file =
    $(call f_util_load_file,$(rebuild_module_dir)/$1/module.mk)
endef

define f_util_load_target_config_file =
    $(call f_util_load_file,$(CONF_BASE)/$1/build-target.conf)
endef

define f_init_rebuild_load_module_cache =
    $(call f_util_log_debug,boot,f_init_rebuild_load_module_cache)
    $(call f_util_set_symbol,rebuild_modules_available,\
        $(foreach path,$(wildcard $(rebuild_module_dir)/*),$(notdir $(path))))
    $(call f_util_log_trace,boot,rebuild_modules_available = $(rebuild_modules_available))
    $(call f_util_load_build_module_file,$1)
endef

define f_init_rebuild_compute_dependencies =
    $(call f_util_log_trace,boot,f_init_rebuild_compute_dependencies)
    $(call f_util_set_symbol,rebuild_modules_explicit,$(rebuild_modules))
    $(foreach mod,$(rebuild_modules_explicit),\
        $(call f_init_rebuild_compute_dependencies_for_module,$(mod)))
endef

define f_init_rebuild_compute_dependencies_for_module =
    $(call f_util_log_trace,boot,f_init_rebuild_compute_dependencies_for_module($1))
    $(if $(call f_util_string_equals,$1,base),,\
        $(call f_util_override_append_if_absent,mod_deps_$1,base))
    $(call f_util_override_append_if_absent,REBUILD_MODULES,$1)

    $(foreach mod,$(mod_deps_$1),\
        $(if $(call f_util_list_contains_string,$(mod),$(rebuild_modules_available)),,\
            $(call f_util_fatal_error,module $(mod) not found [required by $1]))\
        $(if $(strip $(call f_util_list_contains_string,$(mod),$(rebuild_modules_enabled))),,\
            $(call f_init_rebuild_compute_dependencies_for_module,$(mod))))
endef

define f_init_rebuild_activate_modules =
    $(call f_util_log_debug,boot,f_init_rebuild_activate_modules)
    $(call f_util_log_trace,boot,rebuild_modules_selected = $(rebuild_modules_selected))
    $(call f_util_log_trace,boot,rebuild_modules_enabled = $(rebuild_modules_enabled))
    $(foreach mod,$(rebuild_modules_selected),\
        $(call f_init_rebuild_activate_module,$(mod)))
endef

define f_init_rebuild_activate_module =
    $(call f_util_log_trace,boot,f_init_rebuild_activate_module: $1)
    $(foreach mod,$(mod_deps_$1),\
        $(if $(call f_util_list_contains_string,$(mod),$(rebuild_modules_active)),,\
            $(call f_init_rebuild_load_module,$(mod))))
    $(call f_$1_init)
    $(call f_util_override_append_if_absent,rebuild_modules_loaded,$(mod))
    $(call f_util_log_debug,boot,loaded module: $1)
endef

rebuild_project_descriptor_name = project.rebuild
rebuild_project_descriptor_fields = \
    project_name \
    conf_default \
    rebuild_modules

rbproj_name = $(rebuild_project_descriptor_name)

define f_init_load_main_project_descriptor =
    $(if $(call f_rebuild_dir_is_project,$(rebuild_dir_main)),\
        $(call f_rebuild_load_project_file_with_prefix,main,$(rebuild_dir_main),\
        $(call f_util_fatal_error,boot,no project found in main dir [$(rebuild_dir_main)])))
    $(call f_util_set_symbol,rebuild_main_project_name,$(project_name))
endef

f_rebuild_dir_is_project = $(wildcard $(call f_rebuild_project_file_for_dir,$1))
f_rebuild_project_file_for_dir = $1/$(rbproj_name)

# loads contents of file, then copies field values to prefixed field-names,
# allowing all project descriptors to use the same local field-names
define f_rebuild_load_project_file_with_prefix =
    $(call f_util_log_trace,boot,loading project descriptor file=[$1], prefix=[$2])
    $(foreach sym,$(rebuild_project_descriptor_fields),\
        $(call f_util_unset_symbol,$(sym)))
    $(call f_util_load_file,$1)
    $(foreach sym,$(rebuild_project_descriptor_fields),$(if $($(sym)),\
        $(call f_util_set_symbol,rebuild_project_var_$2_$(project_name)_$(sym),$($(sym))),))
endef

define f_init_load_target_config =
    $(if $(CONF_DEFAULT),,\
        $(call f_util_set_symbol,CONF_DEFAULT,$(CONF_DEFAULT_DEFAULT)))
    $(if $(CONF),,\
        $(call f_util_set_symbol,CONF,$(CONF_DEFAULT)))
    $(call f_util_export_symbol,CONF)
    $(call f_util_log_debug,boot,CONF = $(CONF))
    $(call f_util_log_debug,boot,CONF_DEFAULT = $(CONF_DEFAULT))
    $(call f_util_load_target_config_file,$(CONF))
endef

define f_rebuild_register_system_load_hook =
    $(call f_util_log_trace,f_rebuild_register_system_load_hook: $1)
    $(call f_util_append_to_symbol,rebuild_system_load_hooks,$1)
endef

define f_rebuild_execute_system_load_hooks =
    $(call f_util_log_trace,f_rebuild_execute_system_load_hooks)
    $(if $(rebuild_system_load_hooks),\
        $(foreach hook,$(rebuild_system_load_hooks),\
            $(call f_util_log_trace,calling system-load hook: $(hook))\
            $(call $(hook))))
endef

define f_do_init =
    $(call f_util_set_symbol,rebuild_status_init,1)
    $(call f_util_init)

    # load core runtime data structures
    $(call f_init_rebuild_load_module_cache)
    $(call f_init_load_main_project_descriptor)
    $(call f_init_load_target_config)

    # bootstrap module system
    $(call f_init_rebuild_compute_dependencies)
    $(call f_init_rebuild_activate_modules)

    # run startup hooks
    $(call f_rebuild_execute_system_load_hooks)
endef

define f_action_init =
    $(call f_util_log_trace,boot,f_action_init)
    $(if $(rebuild_status_init),,$(call f_do_init))
    $(call f_util_log_trace,boot,end f_action_init)
endef

#
# build step implementations
#
.build-impl: .build-pre $(BUILDDIR) $(DISTDIR) $(BUILD_ITEMS)

.clean-impl: .clean-pre ;\
    $(call f_action_clean, $(BUILD_DIR))

.clobber-impl: .clobber-pre clean

.all-impl: clean build test

.build-tests-impl: $(PRODUCT) .build-tests-pre

.test-impl: build-tests .test-pre

.help-impl: .help-pre

OUTPUT_DIRS = $(BUILD_DIR) $(DIST_DIR) $(OBJ_DIR)

$(OUTPUT_DIRS): ; $(call f_mkdir,$^)

.init:
	
v_init ::= $(call f_action_init)

endif
