
rebuild_project_descriptor_name = project.rebuild
rebuild_project_descriptor_fields = \
    project_name \
    rebuild_conf_default \
    rebuild_modules

rbproj_dfile = $(rebuild_project_descriptor_name)
rbproj_main = $(rebuild_project_name_main)

f_core_project_context_set = $(call f_core_context_set,project,$1)

define f_core_load_main_project_from_dir =
    $(call f_util_log_trace,f_init_rebuild_load_main_project_from_dir: [$1])
    $(if $(call f_core_dir_is_project,$1),\
        $(call f_core_load_project_file_for_dir_with_prefix,main,$1),\
        $(call f_util_fatal_error,boot,no project descriptor found in main dir [$(rebuild_dir_main)]))
endef

f_core_dir_is_project = $(wildcard $(call f_core_get_project_file_for_dir,$1))
f_core_get_project_file_for_dir = $1/$(rbproj_dfile)

f_core_project_var = $(call f_core_project_var_with_prefix,main,$1)
f_core_project_var_with_prefix = $(rebuild_project_var__$1__$2)

# loads contents of file, then copies field values to prefixed field-names,
# allowing all project descriptors to use the same local field-names
define f_core_load_project_file_for_dir_with_prefix
    $(call f_util_log_trace,f_core_load_project_file_with_prefix(prefix=[$1], dir=[$2]))
    $(foreach sym,$(rebuild_project_descriptor_fields),\
        $(call f_util_unset_symbol,$(sym)))
    $(call f_core_project_context_set,$1)
    $(call f_util_load_file,$(call f_core_get_project_file_for_dir,$2))
    $(call f_core_context_reset)
    $(foreach sym,$(rebuild_project_descriptor_fields),$(if $($(sym)),\
        $(call f_util_set_symbol,rebuild_project_var__$1__$(sym),$($(sym))),))
endef

define f_core_load_project_file_for_dir_with_prefix
    $(call f_util_log_trace,f_core_load_project_file_with_prefix(prefix=[$1], dir=[$2]))
    $(foreach sym,$(rebuild_project_descriptor_fields),\
        $(call f_util_unset_symbol,$(sym)))
    $(call f_core_project_context_set,$1)
    $(call f_util_load_file,$(call f_core_get_project_file_for_dir,$2))
    $(call f_core_context_reset)
    $(foreach sym,$(rebuild_project_descriptor_fields),$(if $($(sym)),\
        $(call f_util_set_symbol,rebuild_project_var__$1__$(sym),$($(sym))),))
endef
