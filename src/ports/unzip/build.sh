#!/bin/bash
# Copyright (c) 2014 The Native Client Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

BuildStep() {
  ChangeDir ${SRC_DIR}

  make -f unix/Makefile clean
  # "generic" target, which runs unix/configure, is
  # suggested. However, this target does not work well with NaCl. For
  # example, it does not allow us to overwrite LFLAGS1, it sets the
  # results of uname command, etc.
  #
  # We use NACLCXX as the linker because we link some C++ libraries
  # (e.g., libppapi).
  make -j${OS_JOBS} -f unix/Makefile unzips \
      CC=${NACLCC} LD=${NACLCXX} \
      CFLAGS="${NACL_CFLAGS} -DHAVE_TERMIOS_H -DNO_LCHMOD -Dmain=nacl_main" \
      LFLAGS1="${NACL_LDFLAGS} ${NACL_CLI_MAIN_LIB} \
               -lppapi_simple -lnacl_io -lppapi -lppapi_cpp"
}

InstallStep() {
  MakeDir ${PUBLISH_DIR}
  for name in funzip unzip unzipsfx; do
    cp ${name} ${PUBLISH_DIR}/${name}_${NACL_ARCH}${NACL_EXEEXT}

    pushd ${PUBLISH_DIR}
    LogExecute python ${NACL_SDK_ROOT}/tools/create_nmf.py \
        ${PUBLISH_DIR}/${name}_*${NACL_EXEEXT} \
        -s . \
        -o ${name}.nmf
    popd
  done
}
