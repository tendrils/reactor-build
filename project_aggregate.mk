# Common build rules and properties for executable firmware projects
ifndef REACTOR_PROJECT_AGGREGATE
REACTOR_PROJECT_AGGREGATE = 1

include $(BASE)/project/init.mk

BUILD_ITEMS += $(SUBPROJECTS)

include $(SCRIPT_DIR)/project_common.mk

endif
