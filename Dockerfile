FROM centos:7.5.1804
MAINTAINER Pablo Escobar <pablo.escobarlopez@unibas.ch>

ENV OPENSTRUCTURE_VERSION=1.8.0
ENV OPENMM_VERSION=7.1.1
ENV EIGEN_VERSION=3.3.4
ENV SWIG_VERSION=3.0.12

ENV PYTHONPATH="/usr/local/lib64/python2.7/site-packages/:${PYTHONPATH}"
ENV LD_LIBRARY_PATH="/usr/local/lib64/:/usr/local/openmm/lib/:${LD_LIBRARY_PATH}"
ENV PATH="/usr/local/openmm/bin/:${PATH}"

ENV CPUS_FOR_MAKE=2

RUN yum makecache fast && \
    yum -y install epel-release && \
    yum -y install \
    boost-devel \
    bzip2 \
    cmake \
    doxygen \
    fftw-devel \
    fftw-static \
    file \
    freetype-devel \
    gcc \
    gcc-c++ \
    gcc-gfortran \
    glibc-common \
    glibc-devel \
    libjpeg-turbo-devel \
    libpng-devel \
    libtiff-devel \
    make \
    mesa-libGL-devel \
    mesa-libGLU-devel \
    numpy \
    openblas-devel \
    pcre-devel \
    PyQt4 \
    python-devel \
    qt-devel \
    strace \
    wget \
 && yum -y clean all

# copy eigen header files to /usr/local/include/Eigen
WORKDIR /usr/local/src
RUN wget -O eigen-${EIGEN_VERSION}.tar.bz2 -nc http://bitbucket.org/eigen/eigen/get/${EIGEN_VERSION}.tar.bz2 && \
    mkdir -p /tmp/eigen/ && \
    tar xf eigen-${EIGEN_VERSION}.tar.bz2 -C /tmp/eigen/ --strip-components=1 && \
    mv /tmp/eigen/Eigen /usr/local/include && \
    rm -fr /tmp/eigen/


# download and install latest SWIG (required by OpenMM)
WORKDIR /usr/local/src
RUN wget -O swig-${SWIG_VERSION}.tar.gz https://sourceforge.net/projects/swig/files/swig/swig-${SWIG_VERSION}/swig-${SWIG_VERSION}.tar.gz && \
   tar xvf swig-${SWIG_VERSION}.tar.gz && \
   cd swig-${SWIG_VERSION}/ && \
   ./configure && \
   make -j ${CPUS_FOR_MAKE} && \
   make install 

# install openmm https://github.com/pandegroup/openmm
WORKDIR /usr/local/src
RUN wget -O openmm-${OPENMM_VERSION}.tar.gz https://github.com/pandegroup/openmm/archive/${OPENMM_VERSION}.tar.gz && \
   tar xvf openmm-${OPENMM_VERSION}.tar.gz && \
   mkdir /usr/local/src/openmm-${OPENMM_VERSION}/build && \
   cd /usr/local/src/openmm-${OPENMM_VERSION}/build && \
   cmake .. && \
   make -j ${CPUS_FOR_MAKE} && \
   make install 

# download OpenStructure sources tarball
WORKDIR /usr/local/src
RUN wget -O openstructure-${OPENSTRUCTURE_VERSION}.tar.gz "https://git.scicore.unibas.ch/schwede/openstructure/-/archive/${OPENSTRUCTURE_VERSION}/openstructure-${OPENSTRUCTURE_VERSION}.tar.gz" && \
    mkdir /usr/local/src/openstructure-${OPENSTRUCTURE_VERSION}-source && \
    tar -xf openstructure-${OPENSTRUCTURE_VERSION}.tar.gz --strip-components=1 -C /usr/local/src/openstructure-${OPENSTRUCTURE_VERSION}-source && \
    mkdir /usr/local/src/openstructure-${OPENSTRUCTURE_VERSION}-source/build 

# compile OpenStructure
WORKDIR /usr/local/src/openstructure-${OPENSTRUCTURE_VERSION}-source/build
RUN cmake .. \
   -DENABLE_MM=1 \
   -DOPEN_MM_LIBRARY=/usr/local/openmm/lib/libOpenMM.so \
   -DOPEN_MM_PLUGIN_DIR=/usr/local/openmm/lib/plugins \
   -DOPEN_MM_INCLUDE_DIR=/usr/local/openmm/include \
   -DCOMPILE_TMTOOLS=1 \
   -DENABLE_GFX=ON \
   -DENABLE_GUI=ON \
   -DUSE_NUMPY=1 \
   -DUSE_RPATH=1 \
   -DEIGEN3_INCLUDE_DIR=/usr/local/include/Eigen/ \
   -DFFTW_LIBRARY=/usr/lib64/libfftw3f.a \
   -DQT_QMAKE_EXECUTABLE=/usr/lib64/qt4/bin/qmake \
   -DOPTIMIZE=1 && \
   make -j ${CPUS_FOR_MAKE} && \
   make check && \
   make install 

RUN rm -fr /usr/local/src/openstructure-${OPENSTRUCTURE_VERSION}-source/

ENTRYPOINT ["/usr/local/bin/ost"]
