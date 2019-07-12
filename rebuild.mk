ifndef _REBUILD_MAIN
_REBUILD_MAIN = 1

auto: default

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

# Set default configuration and resolve project paths
CONF_DEFAULT_DEFAULT := reference-platform

PROJECT_BASE       := $(realpath .)
RESOURCE_BASE      := $(realpath $(BASE)/../../resource)
CONF_ROOT           = $(BASE)/conf
CONF_DIR            = $(CONF_ROOT)/$(CONF)
PLATFORM_DIR        = $(BASE)/platform
MODULE_DIR          = $(BASE)/module
SCRIPT_DIR          = $(BASE)/rebuild
SCRIPT_MODULE_DIR   = $(SCRIPT_DIR)/module

BUILD_DIR       = $(PROJECT_BASE)/build
OBJ_DIR         = $(BUILD_DIR)/obj
DIST_DIR        = $(BUILD_DIR)/dist

# Load host and target configuration files
-include $(CONF_ROOT)/build-host.conf
include $(CONF_ROOT)/build-host.default.conf

include $(SCRIPT_DIR)/util.mk

# function: f_define_build_action(name)
# ->  register an action to be invoked during the build process,
#     along with automatic logging and optional pre/post hooks
# ->  [name] ($1): the name of the action to register
# ->  [handler] ($2): the name of the registered action handler;
#       defaults to 'f_do_[name]' if not specified
define f_define_build_action =
    $(call f_util_log_trace,boot,f_define_build_action: $1 $2)
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

define f_init_model =
    $(call f_define_build_action,build)
    $(call f_define_build_action,clean)
endef

available_rebuild_modules := $(wildcard $(SCRIPT_MODULE_DIR)/*)

define f_init_rebuild_compute_dependencies =
    $(call f_util_set_symbol,REBUILD_EXPLICIT_MODULES,$(REBUILD_MODULES))
    $(foreach mod,$(REBUILD_MODULES),\
        $(call f_init_rebuild_compute_module_dependencies,$(mod)))
endef

define f_init_rebuild_compute_module_dependencies =
    $(call f_util_log_trace,boot,f_init_rebuild_compute_module_dependencies($1))
    $(call f_util_log_trace,boot,mod_deps_$1: $(mod_deps_$1))
    $(call f_util_append_if_absent,REBUILD_MODULES,$1)
    $(call f_util_load_build_module_file,$1)
    $(foreach mod,$(mod_deps_$1),\
        $(if $(findstring $1,$(REBUILD_MODULES)),,\
            $(call f_override_append_to_symbol,REBUILD_MODULES)\
            $(call f_init_rebuild_compute_module_dependencies,$(mod))))
endef

define f_init_rebuild_load_modules =
    $(call f_util_log_trace,boot,REBUILD_EXPLICIT_MODULES = $(REBUILD_EXPLICIT_MODULES))
    $(call f_util_log_trace,boot,REBUILD_MODULES = $(REBUILD_MODULES))
    $(foreach mod,$(REBUILD_EXPLICIT_MODULES),\
        $(call f_init_load_build_module,$(mod)))
endef

define f_init_load_build_module =
    $(call f_util_log_trace,boot,f_init_load_build_module: $1)
    $(call f_util_override_append_if_absent,MODULES_LOADED,$1)
    $(call f_util_override_append_if_absent,mod_deps_$1,base)
    $(foreach mod,$(mod_deps_$1),\
        $(if $(findstring $(mod),$(MODULES_LOADED)),,\
            $(call f_init_load_build_module,$(mod))))
    $(call f_load_build_module_file,$1)
    $(call f_$1_init)
    $(call f_util_log_debug,boot,loaded module: $1)
endef

define f_init_load_target_config
    $(call f_util_log_debug,boot,CONF_DEFAULT = $(CONF_DEFAULT))
    $(if $(CONF_DEFAULT),,$(call f_util_set_symbol,CONF_DEFAULT,$(CONF_DEFAULT_DEFAULT)))
    $(call f_util_log_debug,boot,CONF = $(CONF))
    $(call f_util_export_set_symbol,CONF,$(CONF_DEFAULT))
endef

define f_do_init =
    $(call f_util_init)
    $(call f_util_log_debug,boot,logging interface loaded)
    $(call f_init_load_target_config)
    $(call f_init_model)
    $(call f_util_log_debug,boot,loading ReBuild modules)
    $(call f_init_rebuild_compute_dependencies)
    $(call f_util_override_append_if_absent,REBUILD_MODULES,base)
    $(call f_init_rebuild_load_modules)
    $(call f_util_set_symbol,STATUS_INIT,1)
endef

define f_init =
    $(call f_util_log_trace,boot,f_init)
    $(if $(STATUS_INIT),,$(call f_do_init))
    $(call f_util_log_trace,boot,end f_init)
endef

include $(SCRIPT_DIR)/tasks.mk

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

f_do_clean = $(call f_rm,$1)

OUTPUT_DIRS = $(BUILD_DIR) $(DIST_DIR) $(OBJ_DIR)

$(OUTPUT_DIRS): ;\
    $(call f_mkdir,$^)

.init: ; $(call f_do_init)

endif
