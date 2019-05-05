ifndef REACTOR_INIT
REACTOR_INIT = 1

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

PROJECT_BASE   := $(realpath .)
RESOURCE_BASE  := $(realpath ../../resource)
CONF_ROOT       = $(BASE)/conf
CONF_DIR        = $(CONF_ROOT)/$(CONF)
PLATFORM_DIR    = $(BASE)/platform
MODULE_DIR      = $(BASE)/module
SCRIPT_DIR      = $(BASE)/project

BUILD_DIR       = $(PROJECT_BASE)/build
OBJ_DIR         = $(BUILD_DIR)/obj
DIST_DIR        = $(BUILD_DIR)/dist

include $(SCRIPT_DIR)/boot.mk

# Load optional host and target configuration files
-include $(CONF_ROOT)/build-host.conf

include $(CONF_ROOT)/build-host.default.conf
include $(CONF_DIR)/build-target.conf

include $(PLATFORM_DIR)/platform.mk

include $(SCRIPT_DIR)/log.mk

define f_define_build_action =
    define m_define =
        define f_action_$1 =
            $(call f_log_$1,$$1)
            $(if f_pre_$1, $$(call f_pre_$1,$$1,$$2,$$3))
            $(call f_do_$1,$$1,$$2,$$3)
            $(if f_post_$1, $$(call f_post_$1,$$1,$$2,$$3))
        endef
        define f_log_$1 =
            $$(call f_log,info,$1: $$1)
        endef
    endef
    
    $(call f_log_debug,f_define_build_action: $1)
    $(eval $(call m_define,$1))
endef

define f_do_compile_c =
    $$(CC) $$(CFLAGS) $$1 -o $$2
    $(call f_do_compile_deps_c,$$1,$$2)
endef

define f_do_compile_deps_c =
	$$(CC) -MM $$(CFLAGS) $$1 -o $$2
endef

define f_do_link =
    $$(LD) $$(OBJECTFILES) $$(LDFLAGS) $$(ARCHFLAGS) -o $$1
endef

define f_init_model =
    $(call f_log_level_define,trace)
    $(call f_log_level_define,debug)
    $(call f_log_level_define,info)
    $(call f_log_level_define,warn)
    $(call f_log_level_define,error)
    
    $(call f_define_build_action,compile_c)
    $(call f_define_build_action,build)
    $(call f_define_build_action,clean)
endef

define f_do_init =
    $(call f_init_model)
endef

.INIT := $(call f_do_init)

.init:

endif
