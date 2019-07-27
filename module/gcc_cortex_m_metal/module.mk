ifndef _MODULE_GCC_CORTEX_M_METAL
_MODULE_GCC_CORTEX_M_METAL = 1

mod_deps_gcc_cortex_m_metal=gcc_cortex_m

## module lifecycle functions
define f_gcc_cortex_m_metal_init =
    $(call f_gcc_cortex_m_toolchain_define,none)
endef

endif
