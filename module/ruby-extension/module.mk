ifndef _MODULE_RUBY_EXT
_MODULE_RUBY_EXT = 1

## per-module variables- these are unregistered by the module loader,
## so their values should not be referred to directly
MODULE_REQUIRES=$(RUBY_EXT_MODULE_REQUIRES)

RUBY_EXT_MODULE_REQUIRES=ruby-gem

## module load function
define f_ruby_ext_init =
    
endef

.INIT_MODULE_RUBY_EXT := $(call f_ruby_ext_init) $(.INIT)

endif
