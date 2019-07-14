ifndef _MODULE_BASE
_MODULE_BASE = 1

mod_deps_base=$(BASE_MODULE_REQUIRES)

BASE_MODULE_REQUIRES=

MOD_DIR_BASE=$(SCRIPT_MODULE_DIR)/base

## module load function
define f_base_init =
    $(call f_base_init_model)
endef

define f_base_init_model =
    $(call f_define_build_action,build)
    $(call f_define_build_action,clean)
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

endif
