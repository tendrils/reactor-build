# commands for the Rake build tool

# register commands to project model
define f_rake_cmd_init =
    $(call f_define_build_action, invoke_rake)
    $(call f_define_rake_build_action, build)
    $(call f_define_rake_build_action, clean)
    $(call f_define_rake_build_action, install)
    1
endef

## command registration meta-function
define f_define_rake_build_action =
    define macro_rake_cmd_define =
        f_do_rake_$1 = $(call f_do_invoke_rake, $1, $$1)
    endef
    $(eval $(call macro_rake_cmd_define, $1))
    $(call f_define_build_action, rake_$1)
endef

## command dispatch function
define f_do_invoke_rake =
    $(shell $(RAKE) $1 $2)
endef

.INIT_RAKE := $(call f_rake_init) $(.INIT)
