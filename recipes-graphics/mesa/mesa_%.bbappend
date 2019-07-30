FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

GLHDRS_PATCH = ""
GLHDRS_PATCH_tegra = "file://egl-gles2-nv-extensions.patch"
GLHDRS_PATCH_tegra124 = ""
SRC_URI += "${GLHDRS_PATCH}"

TEGRADEPS = ""
TEGRADEPS_tegra = "tegra-mmapi-glheaders tegra-libraries"
TEGRADEPS_tegra124 = "tegra-libraries"
DEPENDS += "${TEGRADEPS}"

PACKAGECONFIG[glvnd] = "-Dglvnd=true,-Dglvnd=false,libglvnd"

GLVNDCFG = ""
GLVNDCFG_tegra = " glvnd"
GLVNDCFG_tegra124 = ""
PACKAGECONFIG_append_class-target = "${GLVNDCFG}"
PACKAGECONFIG_remove_class-target_tegra = "glx-tls"
EXTRA_OEMESON_append_tegra = " -Ddri-drivers='' -Ddri3=false"

move_libraries() {
    install -d ${D}${libdir}/mesa
    if [ -e ${D}${libdir}/libGL.so ]; then
       mv ${D}${libdir}/libGL.* ${D}${libdir}/mesa/
    fi
    if [ -e ${D}${libdir}/libGLESv2.so ]; then
        mv ${D}${libdir}/libGLES* ${D}${libdir}/mesa/
    fi
    if [ -e ${D}${libdir}/libEGL.so ]; then
        mv ${D}${libdir}/libEGL.* ${D}${libdir}/mesa/
    fi
}

do_install_append() {
    if ${@bb.utils.contains("PACKAGECONFIG", "glvnd", "true", "false", d)}; then
        for pkgf in gl egl; do
	    if [ -e ${STAGING_LIBDIR}/pkgconfig/${pkgf}.pc ]; then
	       rm -f ${D}${libdir}/pkgconfig/${pkgf}.pc
	    fi
	done
    fi
}

do_install_append_tegra() {
    if ${@bb.utils.contains("PACKAGECONFIG", "glvnd", "false", "true", d)}; then
        move_libraries
    fi
}

PACKAGE_ARCH_tegra = "${SOC_FAMILY_PKGARCH}"
FILES_libegl-mesa += "${libdir}/libEGL_mesa.so.* ${datadir}/glvnd"
FILES_libegl-mesa-dev += "${libdir}/libEGL_mesa.so"
FILES_libgl-mesa += "${libdir}/libGLX_mesa.so.*"
FILES_libgl-mesa-dev += "${libdir}/libGLX_mesa.so"
PACKAGES =+ "${PN}-stubs-dev ${PN}-stubs"
FILES_${PN}-stubs = "${libdir}/mesa/lib*${SOLIBS}"
FILES_${PN}-stubs-dev = "${libdir}/mesa/lib*${SOLIBSDEV}"
ALLOW_EMPTY_${PN}-stubs = "1"
ALLOW_EMPTY_${PN}-stubs-dev = "1"
PRIVATE_LIBS_${PN}-stubs = "\
    libEGL.so.1 \
    libGLESv1_CM.so.1 \
    libGLESv2.so.2 \
    libGL.so.1 \
"
