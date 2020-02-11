FROM debian:buster

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential=12.6 \
    cmake=3.13.4-1 \
    unzip=6.0-23+deb10u1 \
    pkg-config=0.29-6 \
    wget=1.20.1-1.1 \
    libjpeg-dev=1:1.5.2-2 \
    libpng-dev=1.6.36-6 \
    libtiff-dev=4.1.0+git191117-2~deb10u1 \
    libavcodec-dev=7:4.1.4-1~deb10u1 \
    libavformat-dev=7:4.1.4-1~deb10u1 \
    libswscale-dev=7:4.1.4-1~deb10u1 \
    libv4l-dev=1.16.3-3 \
    libxvidcore-dev=2:1.3.5-1 \
    libx264-dev=2:0.155.2917+git0a84d98-2 \
    libgtk-3-dev=3.24.5-1 \
    libatlas-base-dev=3.10.3-8 \
    gfortran=4:8.3.0-1 \
    && apt-get install -y python3-dev=3.7.3-1 \
    python3-pip=18.1-5 \
    clang=1:7.0-47 \
    # && apt-get purge -y --auto-remove ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir numpy matplotlib jupyter jupyterlab pandas

RUN cd /tmp \
    && wget -O opencv.zip https://github.com/opencv/opencv/archive/4.2.0.zip \
    && wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.2.0.zip \
    && unzip opencv.zip \
    && unzip opencv_contrib.zip \
    && rm opencv.zip opencv_contrib.zip

RUN cd /tmp/opencv-4.2.0 && mkdir build && cd build \
    && CXX=clang++ CC=clang cmake -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D INSTALL_PYTHON_EXAMPLES=OFF \
        -D INSTALL_C_EXAMPLES=OFF \
        -D OPENCV_ENABLE_NONFREE=ON \
        -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib-4.2.0/modules \
        -D PYTHON_EXECUTABLE=/usr/bin/python3 \
        -D BUILD_DOCS=OFF \
        -D BUILD_PERF_TESTS=OFF \
        -D BUILD_TESTS=OFF \
        -D BUILD_EXAMPLES=OFF ..

RUN cd /tmp/opencv-4.2.0/build && make -j && make install && ldconfig \
    && rm -rf /tmp/* && mkdir /notebooks

EXPOSE 8888 8088 8080

# RUN groupadd -r notebook && useradd -r -g notebook notebook && chown -R notebook:notebook /notebooks
# USER notebook

WORKDIR /notebooks

CMD ["jupyter", "lab", "--ip=0.0.0.0", "--allow-root", "--port=8888", "--no-browser"]

