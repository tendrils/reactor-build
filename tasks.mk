# standard build goals and pre/post hooks to be overridden

# build
build: .build-post

.build-pre: .init

.build-impl: .build-pre

.build-post: .build-impl

# clean
clean: .clean-post

.clean-pre: .init

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
build-tests: $(PRODUCT) .build-tests-post

.build-tests-pre: .init

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

.PHONY: all build test clean clobber help .init
