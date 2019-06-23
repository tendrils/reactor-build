ifndef REACTOR_PROJECT_COMMON
REACTOR_PROJECT_COMMON = 1

include $(SCRIPT_DIR)/tasks.mk

include $(MODULE_DIR)/modules.mk

#
# build step implementations
#
.build-impl: .build-pre $(BUILDDIR) $(DISTDIR) $(BUILD_ITEMS)

.clean-impl: .clean-pre ;\
    $(call f_action_clean, $(BUILD_DIR))

.clobber-impl: .clobber-pre clean

.all-impl: clean build test

.build-tests-impl: $(PRODUCT) .build-tests-pre

.test-impl: build-tests .test-pre

.help-impl: .help-pre

f_do_clean = \
    $(call f_rm,$1)

$(BUILD_DIR): ;\
    $(call f_mkdir,$^)

$(DIST_DIR): ;\
    $(call f_mkdir,$(DIST_DIR))

$(OBJ_DIR): ;\
    $(call f_mkdir,$(OBJ_DIR))

endif
