ifndef _MODULE_RUBY_GEM
_MODULE_RUBY_GEM = 1

mod_deps_ruby_gem=

## module load function
define f_gem_init =

endef

RAKE=rake
BUNDLE=bundle

## command dispatch function
f_do_invoke_rake = $(shell $(RAKE) $1 $2)

endif
