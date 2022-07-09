FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y git wget libgl1-mesa-dev libglu1-mesa-dev libxi-dev libx11-dev \
  libxrandr-dev libxi-dev libopenmpi-dev mesa-utils clang cmake software-properties-common \
  build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev \
  libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev

# Python 3.7
RUN cd /usr/src \
  && wget https://www.python.org/ftp/python/3.7.10/Python-3.7.10.tgz \
  && tar -xzf Python-3.7.10.tgz \
  && cd Python-3.7.10 \
  && ./configure  --enable-optimizations --enable-shared \
  && make install altinstall \
  && cd .. \
  && rm Python-3.7.10.tgz
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
RUN pip3.7 install PyOpenGL PyOpenGL_accelerate tensorflow==1.13.1 mpi4py

RUN mkdir -p /deepmimic-deps

# Bullet3
RUN cd /deepmimic-deps \
  && wget https://github.com/bulletphysics/bullet3/archive/refs/tags/2.88.tar.gz \
  && tar -xzf 2.88.tar.gz \
  && cd bullet3-2.88 \
  && mkdir build_cmake \
  && cd build_cmake \
  && cmake -DCMAKE_INSTALL_PREFIX=install -DBUILD_PYBULLET=OFF -DBUILD_PYBULLET_NUMPY=OFF \
  -DUSE_DOUBLE_PRECISION=OFF -DBT_USE_EGL=ON -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON .. \
  && make install

# Eigen
RUN cd /deepmimic-deps \
  && wget --no-check-certificate https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz \
  && tar -xzf eigen-3.3.7.tar.gz \
  && cd eigen-3.3.7 \
  && mkdir build \
  && cd build \
  && cmake .. -DCMAKE_INSTALL_PREFIX=install \
  && make install

# freeglut
RUN cd /deepmimic-deps \
  && wget --no-check-certificate https://github.com/FreeGLUTProject/freeglut/releases/download/v3.0.0/freeglut-3.0.0.tar.gz \
  && tar -xzf freeglut-3.0.0.tar.gz \
  && cd freeglut-3.0.0 \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_INSTALL_PREFIX=install .. \
  && make \
  && make install

# Glew
RUN cd deepmimic-deps \
  && wget --no-check-certificate https://cfhcable.dl.sourceforge.net/project/glew/glew/2.1.0/glew-2.1.0.tgz \
  && tar -xzf glew-2.1.0.tgz \
  && cd glew-2.1.0 \
  && make DESTDIR=install \
  && make install \
  && make clean

# SWIG
RUN cd /deepmimic-deps \
  && wget --no-check-certificate https://cfhcable.dl.sourceforge.net/project/swig/swig/swig-4.0.0/swig-4.0.0.tar.gz \
  && tar -xzf swig-4.0.0.tar.gz \
  && cd swig-4.0.0 \
  && ./configure --without-pcre \
  && make \
  && make install

# Set enviornment variables for DeepMimic build
ENV EIGEN_DIR=/deepmimic-deps/eigen-3.3.7
ENV BULLET_INC_DIR=/deepmimic-deps/bullet3-2.88/build_cmake/install/include/bullet
ENV BULLET_LIB_DIR=/deepmimic-deps/bullet3-2.88/build_cmake/install/lib
ENV GLEW_INC_DIR=/deepmimic-deps/glew-2.1.0/include/GL
ENV GLEW_LIB_DIR=/usr/lib64
ENV FREEGLUT_INC_DIR=/deepmimic-deps/freeglut-3.0.0/build/install/include
ENV FREEGLUT_LIB_DIR=/deepmimic-deps/freeglut-3.0.0/build/install/lib
ENV LD_LIBRARY_PATH=$GLEW_LIB_DIR:$FREEGLUT_LIB_DIR:$LD_LIBRARY_PATH
ENV PROTOCOL_BUFFERS_PYTHON_IMPLEMENTATION=python
ENV MESA_GL_VERSION_OVERRIDE=3.2

# Set environment variable for the container to access the host display
ENV DISPLAY=host.docker.internal:0.0

# RUN cd /workspaces/DeepMimic/DeepMimicCore \
#   && make python
