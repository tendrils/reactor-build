# standard build goals and pre/post hooks to be overridden

ifndef REACTOR_BASE_TASKS
REACTOR_BASE_TASKS = 1

# build step implementations

.build-impl: $(rebuild_output_dirs) $(rebuild_build_items)

.clean-impl: ;\
    $(call f_action_clean, $(rebuild_dir_build))

.clobber-impl: clean

.all-impl: clean build test

.build-tests-impl: $(rebuild_build_items)

.test-impl: build-tests

.help-impl:

$(rebuild_output_dirs): ; $(call f_mkdir,$^)

# build
build: .build-post

.build-pre:

.build-impl: .build-pre

.build-post: .build-impl

# clean
clean: .clean-post

.clean-pre:

.clean-impl: .clean-pre

.clean-post: .clean-impl

# clobber
clobber: .clobber-post

.clobber-pre:

.clobber-impl: .clobber-pre

.clobber-post: .clobber-impl

# all
all: .all-post

.all-pre:

.all-impl: .all-pre

.all-post: .all-impl

# build tests
build-tests: $(rebuild_products) .build-tests-post

.build-tests-pre:

.build-tests-impl: .build-tests-pre

.build-tests-post: .build-tests-impl

# run tests
test: .test-post

.test-pre: build-tests

.test-impl: .test-pre

.test-post: .test-impl

# help
help: .help-post

.help-pre:

.help-impl: .help-pre

.help-post: .help-impl

.PHONY: all build test clean clobber help

endif
