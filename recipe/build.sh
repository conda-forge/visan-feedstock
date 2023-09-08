#!/bin/bash

mkdir build
cd build

if test "${CONDA_BUILD_CROSS_COMPILATION}" == "1"; then
  # This wrapper script is needed for the VTK build tools when cross compiling.
  # When e.g. vtkWrapPython is invoked from the target conda environment in
  # $PREFIX, CMake will pass the command invocation to this wrapper script.
  # We then redirect the call to the executable in the build conda environment
  # in $BUILD_PREFIX (which will be of the proper host architecture).
  cat << _EOF > crosswrapper.sh
#!/bin/bash
executable=\$1
shift
  if [[ \$executable == "\$PREFIX"* ]] ; then
    executable=\$BUILD_PREFIX\${executable#\$PREFIX}
  fi
fi
\$executable \$@
_EOF
  chmod 755 crosswrapper.sh
  CMAKE_ARGS="${CMAKE_ARGS} -DCMAKE_CROSSCOMPILING_EMULATOR=${PWD}/crosswrapper.sh"
fi

export CMAKE_LIBRARY_PATH=$PREFIX/lib

cmake $CMAKE_ARGS \
  -DCMAKE_BUILD_TYPE="Release" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DPython3_EXECUTABLE=$PREFIX/bin/python \
  ..

make -j$CPU_COUNT
make install
