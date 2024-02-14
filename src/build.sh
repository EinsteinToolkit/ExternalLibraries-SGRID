#! /bin/bash

################################################################################
# Build
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors



# Set locations
THORN=SGRID
NAME=sgrid
NAME_SUFFIX=_a4fe199d
SRCDIR="$(dirname $0)"
BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
if [ -z "${SGRID_INSTALL_DIR}" ]; then
    INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
else
    echo "BEGIN MESSAGE"
    echo "Installing SGRID into ${SGRID_INSTALL_DIR} "
    echo "END MESSAGE"
    INSTALL_DIR=${SGRID_INSTALL_DIR}
fi
DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
SGRID_DIR=${INSTALL_DIR}

# Set up environment
#unset LIBS
#unset TOP
# Roland said that unset does not work, because Cactus circumvents it.
# So now we remove all flags that make has, which will also affect e.g. -j8
MAKEFLAGS=${MAKEFLAGS%% -- *}

if echo '' ${ARFLAGS} | grep 64 > /dev/null 2>&1; then
    export OBJECT_MODE=64
fi

echo "SGRID: Preparing directory structure..."
cd ${SCRATCH_BUILD}
mkdir build external done 2> /dev/null || true
rm -rf ${BUILD_DIR} ${INSTALL_DIR}
mkdir ${BUILD_DIR} ${INSTALL_DIR}

echo "SGRID: Unpacking archive..."
pushd ${BUILD_DIR}
${TAR?} xf ${SRCDIR}/../dist/${NAME}${NAME_SUFFIX}.tar
pushd ${NAME}
#${PATCH?} -p1 < ${SRCDIR}/../dist/stdarg.patch
# Some (ancient but still used) versions of patch don't support the
# patch format used here but also don't report an error using the exit
# code. So we use this patch to test for this
${PATCH?} -p1 < ${SRCDIR}/../dist/patchtest.patch
if [ ! -e .patch_tmp ]; then
    echo 'BEGIN ERROR'
    echo 'The version of patch is too old to understand this patch format.'
    echo 'Please set the PATCH environment variable to a more recent '
    echo 'version of the patch command.'
    echo 'END ERROR'
    exit 1
fi
rm -f .patch_tmp
popd

echo "SGRID: Building..."
cd ${NAME}
${MAKE} CC=${CC} OFLAGS="${CFlAGS}"

echo "SGRID: Installing..."
mkdir -p ${INSTALL_DIR}/lib
cp lib/libsgrid.a ${INSTALL_DIR}/lib
popd

echo "SGRID: Cleaning up..."
rm -rf ${BUILD_DIR}

date > ${DONE_FILE}
echo "SGRID: Done."
