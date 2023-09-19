#! /bin/bash

################################################################################
# Prepare
################################################################################

# Set up shell
if [ "$(echo ${VERBOSE} | tr '[:upper:]' '[:lower:]')" = 'yes' ]; then
    set -x                      # Output commands
fi
set -e                          # Abort on errors

. $CCTK_HOME/lib/make/bash_utils.sh

# Take care of requests to build the library in any case
SGRID_DIR_INPUT=$SGRID_DIR
if [ "$(echo "${SGRID_DIR}" | tr '[a-z]' '[A-Z]')" = 'BUILD' ]; then
    SGRID_BUILD=yes
    SGRID_DIR=
else
    SGRID_BUILD=
fi

# Try to find the library if build isn't explicitly requested
# TODO: check if this actually works without an include file
if [ -z "${SGRID_BUILD}" ]; then
    find_lib SGRID sgrid 1 1.0 "sgrid" "" "$SGRID_DIR"
fi

THORN=SGRID

################################################################################
# Build
################################################################################

if [ -n "$SGRID_BUILD" -o -z "${SGRID_DIR}" ]; then
    echo "BEGIN MESSAGE"
    echo "Using bundled SGRID..."
    echo "END MESSAGE"
    
    check_tools "tar patch"

    # Set locations
    BUILD_DIR=${SCRATCH_BUILD}/build/${THORN}
    if [ -z "${SGRID_INSTALL_DIR}" ]; then
        INSTALL_DIR=${SCRATCH_BUILD}/external/${THORN}
    else
        echo "BEGIN MESSAGE"
        echo "Installing SGRID into ${SGRID_INSTALL_DIR} "
        echo "END MESSAGE"
        INSTALL_DIR=${SGRID_INSTALL_DIR}
    fi
    SGRID_BUILD=1
    SGRID_DIR=${INSTALL_DIR}
    SGRID_INC_DIRS="$SGRID_DIR/include"
    SGRID_LIB_DIRS="$SGRID_DIR/lib"
    SGRID_LIBS="sgrid"
else
    SGRID_BUILD=
    DONE_FILE=${SCRATCH_BUILD}/done/${THORN}
    if [ ! -e ${DONE_FILE} ]; then
        mkdir ${SCRATCH_BUILD}/done 2> /dev/null || true
        date > ${DONE_FILE}
    fi
fi

################################################################################
# Configure Cactus
################################################################################

# Pass configuration options to build script
echo "BEGIN MAKE_DEFINITION"
echo "SGRID_BUILD       = ${SGRID_BUILD}"
echo "SGRID_INSTALL_DIR = ${SGRID_INSTALL_DIR}"
echo "END MAKE_DEFINITION"

set_make_vars "SGRID" "$SGRID_LIBS" "$SGRID_LIB_DIRS" "$SGRID_INC_DIRS"

# Pass options to Cactus
echo "BEGIN MAKE_DEFINITION"
echo "SGRID_DIR      = ${SGRID_DIR}"
echo "SGRID_INC_DIRS = ${SGRID_INC_DIRS}"
echo "SGRID_LIB_DIRS = ${SGRID_LIB_DIRS}"
echo "SGRID_LIBS     = ${SGRID_LIBS}"
echo "END MAKE_DEFINITION"

echo 'INCLUDE_DIRECTORY $(SGRID_INC_DIRS)'
echo 'LIBRARY_DIRECTORY $(SGRID_LIB_DIRS)'
echo 'LIBRARY           $(SGRID_LIBS)'
