ifndef _MODULE_RUBY_GEM
_MODULE_RUBY_GEM = 1

## module load function
define f_gem_init =
    RAKE=rake
    BUNDLE=bundle
endef

## command dispatch function
f_do_invoke_rake =  $(shell $(RAKE) $1 $2)

.INIT_MODULE_RUBY_GEM := $(call f_gem_init) $(.INIT)

endif
