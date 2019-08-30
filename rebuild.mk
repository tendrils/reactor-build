ifndef _REBUILD_MAIN
_REBUILD_MAIN = 1

auto: default

# Set default configuration and resolve project paths
CONF_DEFAULT_DEFAULT := reference-platform

PROJECT_BASE       := $(realpath .)
RESOURCE_BASE      := $(realpath $(BASE)/../../resource)
CONF_BASE           = $(BASE)/conf
CONF_DIR            = $(CONF_BASE)/$(CONF)
PLATFORM_DIR        = $(BASE)/platform
MODULE_DIR          = $(BASE)/module
SCRIPT_DIR          = $(BASE)/rebuild
SCRIPT_MODULE_DIR   = $(SCRIPT_DIR)/module

# Load host and target configuration files
-include $(CONF_BASE)/build-host.conf
include $(CONF_BASE)/build-host.default.conf

include $(SCRIPT_DIR)/util.mk
include $(SCRIPT_DIR)/tasks.mk

define f_init_rebuild_compute_dependencies =
    $(call f_util_set_symbol,available_rebuild_modules,\
        $(foreach path,$(wildcard $(SCRIPT_MODULE_DIR)/*),$(notdir $(path))))
    $(call f_util_log_trace,boot,available_rebuild_modules = $(available_rebuild_modules))
    $(call f_util_set_symbol,REBUILD_EXPLICIT_MODULES,$(REBUILD_MODULES))
    $(foreach mod,$(REBUILD_EXPLICIT_MODULES),\
        $(call f_init_rebuild_compute_module_dependencies,$(mod)))
endef

define f_init_rebuild_compute_module_dependencies =
    $(call f_util_log_trace,boot,f_init_rebuild_compute_module_dependencies($1))
    $(call f_util_load_build_module_file,$1)
    $(if $(call f_util_string_equals,$1,base),,\
        $(call f_util_override_append_if_absent,mod_deps_$1,base))
    $(call f_util_override_append_if_absent,REBUILD_MODULES,$1)

    $(foreach mod,$(mod_deps_$1),\
        $(if $(call f_util_list_contains_string,$(mod),$(available_rebuild_modules)),,\
            $(call f_util_fatal_error,module $(mod) not found [required by $1]))\
        $(if $(strip $(call f_util_list_contains_string,$(mod),$(REBUILD_MODULES))),,\
            $(call f_init_rebuild_compute_module_dependencies,$(mod))))
endef

define f_init_rebuild_load_modules =
    $(call f_util_log_trace,boot,REBUILD_EXPLICIT_MODULES = $(REBUILD_EXPLICIT_MODULES))
    $(call f_util_log_trace,boot,REBUILD_MODULES = $(REBUILD_MODULES))
    $(foreach mod,$(REBUILD_EXPLICIT_MODULES),\
        $(call f_init_rebuild_load_module,$(mod)))
endef

define f_init_rebuild_load_module =
    $(call f_util_log_trace,boot,f_init_rebuild_load_module: $1)
    $(foreach mod,$(mod_deps_$1),\
        $(if $(call f_util_list_contains_string,$(mod),$(MODULES_LOADED)),,\
            $(call f_init_rebuild_load_module,$(mod))))
    $(call f_$1_init)
    $(call f_util_override_append_if_absent,MODULES_LOADED,$(mod))
    $(call f_util_log_debug,boot,loaded module: $1)
endef
c_rebuild_default_project_descriptor = project$(c_rebuild_default_project_descriptor_suffix)
c_rebuild_default_project_descriptor_suffix = .rebuild
c_rebuild_project_descriptor_fields = \
    project_name \
    conf_default \
    rebuild_modules \
    subproject_dirs

define f_init_load_project_descriptors =
    $(call f_init_load_main_project_descriptor)
    $(foreach )
endef

define f_init_load_main_project_descriptor =
    $(if $(rebuild_project),\
        $(call f_init_load_project_descriptor_from_file,./$(rebuild_project).rebuild),\
        $(call f_init_load_project_descriptor_from_file,./$(c_rebuild_default_project_descriptor)))
    $(call f_util_set_symbol,v_main_project_name,$(project_name))
endef

# search for project descriptors in the given directory, select one, and load it
define f_init_load_subproject_descriptor =
    $(if $(wildcard $1/$1$(c_rebuild_default_project_descriptor_suffix),\
        $(call f_init_load_project_descriptor_from_file,$1/$1$(c_rebuild_default_project_descriptor_suffix)),\
        $(if $(wildcard $1/*$(c_rebuild_default_project_descriptor_suffix)),\
            $(call f_init_load_project_descriptor_from_file,$(firstword $(wildcard $1/*$(c_rebuild_default_project_descriptor_suffix)))),\
            $(call f_util_fatal_error,init,could not locate project descriptor for project [$1]))))
endef

# loads contents of file, then copies field values to prefixed field-names,
# allowing all project descriptors to use the same local field-names
define f_init_load_project_descriptor_from_file =
    $(foreach sym,$(c_rebuild_project_descriptor_fields),\
        $(call f_util_unset_symbol,$(sym)))
    $(call f_util_load_file,$1)
    $(foreach sym,$(c_rebuild_project_descriptor_fields),$(if $($(sym)),\
        $(call f_util_set_symbol,$(v_proj_$(project_name)_$(sym)),$($(sym))),))
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

define f_do_init =
    $(call f_util_init)
    $(call f_util_log_debug,boot,logging interface loaded)
    $(call f_init_load_main_project_descriptor)
    $(call f_init_load_target_config)
    $(call f_util_log_debug,boot,loading ReBuild modules)
    $(call f_init_rebuild_compute_dependencies)
    $(call f_init_rebuild_load_modules)
    $(call f_util_set_symbol,STATUS_INIT,1)
endef

define f_action_init =
    $(call f_util_log_trace,boot,f_action_init)
    $(if $(STATUS_INIT),,$(call f_do_init))
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
