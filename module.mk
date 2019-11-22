# rebuild/module.mk

# loader context variable $(_module) is set dynamically by the module loader
_module_dir = $(rebuild_dir_module)/$(_module)
_module_file = $(_module_dir)/module.mk

f_core_module_context_set = $(call f_core_context_set,module,$1)

# set module context, load module file, and transcribe its attributes
define f_core_load_rebuild_module_file =
    $(call f_util_log_trace,f_core_load_rebuild_module_file file=[$1])
    $(call f_core_module_context_set,$1)
    $(call f_util_load_file,$(rebuild_dir_module)/$1/module.mk)
    $(call f_core_context_reset)
endef

define f_core_load_rebuild_module_cache =
    $(call f_util_log_debug,f_core_load_rebuild_module_cache)
    $(call f_util_set_symbol,rebuild_modules_available,\
        $(foreach path,$(wildcard $(rebuild_dir_module)/*),$(notdir $(path))))
    $(call f_util_log_trace,rebuild_modules_available = $(rebuild_modules_available))
    $(foreach mod,$(rebuild_modules_available),\
        $(call f_core_load_rebuild_module_file,$(mod)))
endef

define f_core_rebuild_module_visit_dependencies =
    $(call f_util_log_debug,f_core_rebuild_module_visit_dependencies)
    $(call f_util_set_symbol,rebuild_modules_selected,$(call f_core_project_var,rebuild_modules))
    $(foreach mod,$(rebuild_modules_selected),\
        $(call f_core_rebuild_module_visit_dependencies_for_module,$(mod)))
endef

define f_core_rebuild_module_visit_dependencies_for_module =
    $(call f_util_log_trace,f_core_rebuild_module_visit_dependencies_for_module($1))
    $(if $(call f_util_string_equals,$1,base),,\
        $(call f_util_override_append_if_absent,mod_deps_$1,base))
    $(call f_util_override_append_if_absent,rebuild_modules_enabled,$1)

    $(foreach mod,$(mod_deps_$1),\
        $(if $(call f_util_list_contains_string,$(mod),$(rebuild_modules_available)),,\
            $(call f_util_fatal_error,module $(mod) not found [required by $1]))\
        $(if $(strip $(call f_util_list_contains_string,$(mod),$(rebuild_modules_enabled))),,\
            $(call f_core_rebuild_module_visit_dependencies_for_module,$(mod))))
endef

define f_core_rebuild_activate_modules =
    $(call f_util_log_debug,f_core_rebuild_activate_modules)
    $(call f_util_log_trace,rebuild_modules_selected = $(rebuild_modules_selected))
    $(call f_util_log_trace,rebuild_modules_enabled = $(rebuild_modules_enabled))
    $(foreach mod,$(rebuild_modules_selected),\
        $(call f_core_rebuild_activate_module,$(mod)))
endef

# first ensure all dependencies are activated, set module context,
# and then run module activation routine
define f_core_rebuild_activate_module =
    $(call f_util_log_trace,f_core_rebuild_activate_module: [$1])
    $(foreach mod,$(mod_deps_$1),\
        $(if $(call f_util_list_contains_string,$(mod),$(rebuild_modules_active)),,\
            $(call f_init_rebuild_activate_module,$(mod))))
    $(call f_core_module_context_set,$1)
    $(call f_$1_init)
    $(call f_core_context_reset)
    $(call f_util_override_append_if_absent,rebuild_modules_loaded,$(mod))
    $(call f_util_log_debug,loaded module: $1)
endef
