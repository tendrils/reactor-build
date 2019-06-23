# commands for the GCC compiler toolchain

## register commands to project model
define f_gcc_cmd_init =

    $(call f_define_build_action, invoke_gcc)
    $(call f_define_build_action, gcc_compile.c)
    $(call f_define_build_action, gcc_compile.cpp)
    $(call f_define_build_action, gcc_assemble.s)
    $(call f_define_build_action, gcc_assemble.S)
    1
endef

## command dispatch functions
cf_do_invoke_gcc = $(GCC) $(CFLAGS) $1 -o $2
cf_do_invoke_gcc_ld = $(GCC_LD) $1 $(LDFLAGS) $(ARCHFLAGS) $2 -o $3

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

.INIT_GCC := $(call f_gcc_init) $(.INIT)
