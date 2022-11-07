FROM ubuntu:20.04
WORKDIR /opt
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

ARG BUILD_DEPENDENCIES="                 \
        ninja-build                      \
        build-essential                  \
        debhelper                        \
        cdbs                             \
        clang-format                     \
        cmake                            \
        git                              \
        pkg-config                       \
        xmlto                            \
        xsltproc                         \
        ffmpeg"

ARG DEPENDENCIES="                       \
        autotools-dev                    \
        docbook-xsl                      \
        dpkg-dev                         \
        libasound2-dev                   \
        libavutil-dev                    \
        libavcodec-dev                   \
        libavresample-dev                \
        libcairo-dev                     \
        libcups2-dev                     \
        libdbus-glib-1-dev               \
        libfaac-dev                      \
        libfaad-dev                      \
        libgsm1-dev                      \
        libgstreamer1.0-dev              \
        libgstreamer1.0-dev              \
        libgstreamer-plugins-base1.0-dev \
        libjpeg-dev                      \
        libpcsclite-dev                  \
        libpulse-dev                     \
        libssl-dev                       \
        libx11-dev                       \
        libxkbfile-dev                   \
        libswscale-dev                   \
        libsystemd-dev                   \
        libwayland-dev                   \
        libxcursor-dev                   \
        libxdamage-dev                   \
        libxext-dev                      \
        libxfixes-dev                    \
        libxi-dev                        \
        libxinerama-dev                  \
        libxml2-dev                      \
        libxrandr-dev                    \
        libxrender-dev                   \
        libxtst-dev                      \
        libxv-dev                        \
        libudev-dev                      \
        libusb-1.0-0-dev                 \
        libz-dev                         \
        uuid-dev"

RUN set -ex \
    sed -i "s@http://.*.ubuntu.com@http://mirrors.ustc.edu.cn@g" /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends ${BUILD_DEPENDENCIES} \
    && apt-get install -y --no-install-recommends ${DEPENDENCIES}

RUN git clone -b 2.8.1 https://github.com/FreeRDP/FreeRDP /opt/FreeRDP
WORKDIR /opt/FreeRDP
RUN set -ex \
    && cmake -DCMAKE_BUILD_TYPE=Release -DCHANNEL_URBDRC=OFF -DWITH_PROXY=ON -DWITH_SHADOW=OFF -DWITH_SERVER=ON -DBUILD_SHARED_LIBS=OFF -DWITH_SWSCALE=ON -DWITH_CAIRO=ON -DPROXY_PLUGINDIR=/opt/freerdp \
    && cmake --build . -j $(nproc) \
    && cmake --build . --target install

FROM ubuntu:20.04
WORKDIR /opt/freerdp
ARG TARGETARCH
ENV LANG=en_US.utf8
ENV DEBIAN_FRONTEND=noninteractive

ARG DEPENDENCIES="                       \
        libasound2-dev                   \
        libavcodec-dev                   \
        libcups2-dev                     \
        libpulse-dev                     \
        libswscale-dev                   \
        libssl-dev                       \
        libxkbfile-dev"

ARG TOOLS="                              \
        ca-certificates                  \
        curl                             \
        locales                          \
        openssl                          \
        procps"

RUN set -ex \
    sed -i "s@http://.*.ubuntu.com@http://mirrors.ustc.edu.cn@g" /etc/apt/sources.list \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt update \
    && apt install -y --no-install-recommends ${DEPENDENCIES} \
    && apt-get install -y --no-install-recommends ${TOOLS} \
    && echo "LANG=$LANG" > /etc/default/locale \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local/bin /usr/local/bin
COPY config.ini .
COPY entrypoint.sh .
RUN chmod 755 ./entrypoint.sh
CMD ["./entrypoint.sh"]
