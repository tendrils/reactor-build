ifndef _REBUILD_MAIN
_REBUILD_MAIN = 1

auto: default

# Set default configuration and resolve project paths
CONF_DEFAULT_DEFAULT := reference-platform

# [rebuild_dir_main] is the directory from which the make command originated
# [rebuild_dir_root] is the root node of the project hierarchy, where the
#   active copy of ReBuild is installed. it must be set to the same value by
#   all subordinate projects in the project tree, inside the project makefile
rebuild_dir_main            = $(CURDIR)
rebuild_dir_root            = $(CURDIR)
rebuild_dir_resource        = $(realpath $(rebuild_dir_root)/../../resource)
rebuild_dir_conf_base       = $(rebuild_dir_root)/conf
rebuild_dir_conf            = $(call f_core_target_dir_get,$(rebuild_conf))
rebuild_dir_home            = $(rebuild_dir_root)/rebuild
rebuild_dir_module          = $(rebuild_dir_home)/module

rebuild_output_dirs += $(rebuild_dir_build) $(rebuild_dir_dist)

rebuild_filename_conf = rebuild.conf

rebuild_file_conf = $(rebuild_dir_conf)/$(rebuild_filename_conf)

# shorthand aliases for symbols often used in expressions
rbproj_root = $(rebuild_dir_root)

# Load host and target configuration files
-include $(rebuild_dir_conf_base)/build-host.conf
include $(rebuild_dir_conf_base)/build-host.default.conf

include $(rebuild_dir_home)/util.mk
include $(rebuild_dir_home)/tasks.mk
include $(rebuild_dir_home)/project.mk
include $(rebuild_dir_home)/module.mk
include $(rebuild_dir_home)/context.mk

define f_core_load_target_config =
    $(call f_util_log_trace,f_core_load_target_config)
    
    $(if $(rebuild_conf_default),,\
        $(call f_util_set_symbol,rebuild_conf_default,$(rebuild_conf_global_default)))
    $(if $(rebuild_conf),,\
        $(call f_util_set_symbol,rebuild_conf,$(rebuild_conf_default)))
    $(call f_util_export_symbol,rebuild_conf)
    $(call f_util_log_debug,rebuild_conf_default = $(rebuild_conf_default))
    $(call f_util_log_debug,rebuild_conf = $(rebuild_conf))

    $(call f_core_target_context_set,$(rebuild_conf))
    $(call f_core_load_config_file_for_target,$(rebuild_conf))
    $(call f_core_context_reset)
endef

define f_core_load_config_file_for_target =
    $(call f_util_log_trace,f_core_load_config_file_for_target: [target = $1])
    $(call f_util_load_file,$(call f_core_target_config_file_get,$1))
endef

f_core_target_dir_get = $(rebuild_dir_conf_base)/$1
f_core_target_config_file_get = $(call f_core_target_dir_get,$1)/$(rebuild_filename_conf)

f_core_target_context_set = $(call f_core_context_set,target,$1)

define f_core_register_system_load_hook =
    $(call f_util_log_trace,f_core_register_system_load_hook: $1)
    $(call f_util_append_to_symbol,rebuild_system_load_hooks,$1)
    $(call f_util_set_symbol,rebuild_load_hook_context_key__$1,$(_context))
    $(call f_util_set_symbol,rebuild_load_hook_context_value__$1,$(_context_value))
endef

f_core_load_hook_context_key = $(rebuild_load_hook_context_key__$1)
f_core_load_hook_context_value = $(rebuild_load_hook_context_value__$1)

define f_core_execute_system_load_hooks =
    $(call f_util_log_trace,f_core_execute_system_load_hooks)
    $(if $(rebuild_system_load_hooks),\
        $(foreach hook,$(rebuild_system_load_hooks),\
            $(call f_util_log_trace,calling system-load hook: $(hook))\
            $(call f_core_context_set,\
                $(call f_core_load_hook_context_key,$(hook))\
                $(call f_core_load_hook_context_value,$(hook)))\
            $(call $(hook))\
            $(call f_core_context_reset)))
endef

define f_do_init =
    $(call f_util_init)

    # load core runtime data structures
    $(call f_core_load_rebuild_module_cache)
    $(call f_core_load_main_project_from_dir,$(rebuild_dir_main))
    $(call f_core_load_target_config)

    # bootstrap module system
    $(call f_core_rebuild_module_visit_dependencies)
    $(call f_core_rebuild_activate_modules)
    $(call f_core_rebuild_traverse_references)

    # run startup hooks
    $(call f_core_execute_system_load_hooks)
endef

define f_action_init =
    $(call f_util_log_trace,f_action_init)
    $(if $(rebuild_status_init),,\
        $(call f_util_set_symbol,rebuild_status_init,1)\
        $(call f_do_init))
    $(call f_util_log_trace,end f_action_init)
endef

v_init ::= $(call f_action_init)

endif
