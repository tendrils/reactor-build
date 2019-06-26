ifndef _REBUILD
_REBUILD = 1

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
CONF_DEFAULT_DEFAULT := reference-hardware
CONF_DEFAULT ?= $(CONF_DEFAULT_DEFAULT)
CONF ?= $(CONF_DEFAULT)

PROJECT_BASE       := $(realpath .)
RESOURCE_BASE      := $(realpath $(BASE)/../../resource)
CONF_ROOT           = $(BASE)/conf
CONF_DIR            = $(CONF_ROOT)/$(CONF)
PLATFORM_DIR        = $(BASE)/platform
MODULE_DIR          = $(BASE)/module
SCRIPT_DIR          = $(BASE)/script
SCRIPT_MODULE_DIR   = $(SCRIPT_DIR)/module

BUILD_DIR       = $(PROJECT_BASE)/build
OBJ_DIR         = $(BUILD_DIR)/obj
DIST_DIR        = $(BUILD_DIR)/dist

include $(SCRIPT_DIR)/boot.mk

# Load optional host and target configuration files
-include $(CONF_ROOT)/build-host.conf
include $(CONF_ROOT)/build-host.default.conf

include $(CONF_DIR)/build-target.conf

include $(SCRIPT_DIR)/log.mk

# function: f_define_build_action(name)
# ->  register an action to be invoked during the build process,
#     along with automatic logging and optional pre/post hooks
# ->  [name] ($1): the name of the action to register
# ->  [handler] ($2): the name of the registered action handler;
#       defaults to 'f_do_[name]' if not specified
define f_define_build_action =
    $(call f_log_trace,core,f_define_build_action: $1 $2)
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
        $$(call f_log,info,$1: $$1)
    endef
endef

define f_init_model =
    $(call f_define_build_action,build)
    $(call f_define_build_action,clean)
endef

available_rebuild_modules := $(wildcard $(SCRIPT_MODULE_DIR)/*)

define f_init_load_build_modules =
    $(foreach mod,$(REBUILD_MODULES),\
        $(if $(findstring $(mod),$(available_rebuild_modules)),,\
            $(call f_boot_failure,ReBuild module $(mod) not installed))\
        $(call f_init_load_build_module,$(mod)))
endef

define f_init_load_build_module =
    $(call f_log_trace,core,f_init_load_build_module: $1)
    $(call f_override_append_if_absent,MODULES_LOADED,$1)
    $(call f_load_build_module_file,$1)
    $(foreach mod,$(mod_deps_$1),\
        $(if $(findstring $(mod),$(available_rebuild_modules)),,\
            $(call f_boot_failure,ReBuild module $(mod) not installed [required by module $1]))\
        $(if $(findstring $(mod),$(MODULES_LOADED)),,\
            $(call f_init_load_build_module,$(mod))))
    $(call f_$1_init)
    $(call f_log_debug,core,loaded module: $1)
endef
m_load_build_module_file = include $(SCRIPT_DIR)/module/$1/module.mk
m_override_set_symbol = override $1=$2
m_override_append_to_symbol = override $1+=$2
f_load_build_module_file = $(eval $(call m_load_build_module_file,$1))
f_override_set_symbol = $(eval $(call m_override_set_symbol,$1,$2))
f_override_append_to_symbol = $(eval $(call m_override_append_to_symbol,$1,$2))
f_override_append_if_absent = $(if $(findstring $2,$($1)),,$(call f_override_append_to_symbol,$1,$2))

define f_do_init =
    $(call f_log_init)
    $(call f_log_debug,core,logging interface loaded)
    $(call f_init_model)
    $(call f_log_debug,core,loading ReBuild modules)
    $(call f_init_load_build_modules)
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

f_do_clean = \
    $(call f_rm,$1)

$(BUILD_DIR): ;\
    $(call f_mkdir,$^)

$(DIST_DIR): ;\
    $(call f_mkdir,$(DIST_DIR))

$(OBJ_DIR): ;\
    $(call f_mkdir,$(OBJ_DIR))

.INIT := $(call f_do_init)

.init: ; $(.INIT)

endif
