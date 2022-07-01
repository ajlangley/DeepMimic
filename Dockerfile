FROM python:3.6
MAINTAINER alangley@blizzard.com

# Install Ubuntu packages
RUN apt update
RUN apt install -y git wget zlib1g libgl1-mesa-dev libx11-dev libxrandr-dev \
  libxi-dev libopenmpi-dev mesa-utils clang cmake

# Python dependencies
RUN pip install PyOpenGL PyOpenGL_accelerate tensorflow==1.13.1 mpi4py

# Bullet
RUN wget https://github.com/bulletphysics/bullet3/archive/refs/tags/2.88.tar.gz \
  -O /bullet_2.88.tar.gz \
  && tar -xzf /bullet_2.88.tar.gz \
  && cd /bullet3-2.88 \
  && ./build_cmake_pybullet_double.sh USE_DOUBLE_PRECISION=OFF \
  && cd build_cmake \
  && make install \
  && cd / \
  && rm bullet3-2.88.tar.gz

# Eigen
RUN wget --no-check-certificate https://gitlab.com/libeigen/eigen/-/archive/3.3.7/eigen-3.3.7.tar.gz \
  && tar -xzf eigen-3.3.7.tar.gz \
  && cd eigen-3.3.7 \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make install \
  && cd / \
  && rm eigen-3.3.7.tar.gz

# # freeglut
# RUN wget --no-check-certificate https://github.com/FreeGLUTProject/freeglut/releases/download/v3.0.0/freeglut-3.0.0.tar.gz \
#   && tar -xzf freeglut-3.0.0.tar.gz \
#   && cd freeglut-3.0.0
#   && mkdir build \
#   && cd build \
#   && cmake -DCMAKE_INSTALL_PREFIX=\usr .. \
#   && make \
#   && make install \
#   && cd / \
#   && rm freeglut-3.0.0.tar.gz \
#   && rm -r freeglut-3.0.0 \


# glew
RUN wget --no-check-certificate https://cfhcable.dl.sourceforge.net/project/glew/glew/2.1.0/glew-2.1.0.tgz \
  && tar -xzf glew-2.1.0.tgz \
  && cd glew-2.1.0 \
  && make \
  && make install \
  && make clean \
  && cd / \
  && rn glew-2.1.0.tgz

# SWIG
RUN wget --no-check-certificate https://cfhcable.dl.sourceforge.net/project/swig/swig/swig-4.0.0/swig-4.0.0.tar.gz \
  && tar -xzf swig-4.0.0.tar.gz \
  && cd swig-4.0.0 \
  && ./configure --without-pcre \
  && make \
  && make install \
  && cd / \
  && rm swig-4.0.0.tar.gz
