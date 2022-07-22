FROM ubuntu:20.04
WORKDIR /opt
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && apt update \
    && apt install -y --no-install-recommends  ninja-build build-essential debhelper cdbs dpkg-dev autotools-dev cmake pkg-config xmlto libssl-dev docbook-xsl xsltproc git libsystemd-dev libz-dev ffmpeg libavutil-dev libavcodec-dev libavresample-dev libcairo-dev libpulse-dev libxkbfile-dev libx11-dev libwayland-dev libxrandr-dev libxi-dev libxrender-dev libxext-dev libxinerama-dev libxfixes-dev libxcursor-dev libxv-dev libxdamage-dev libxtst-dev libcups2-dev libpcsclite-dev libasound2-dev libjpeg-dev libgsm1-dev libusb-1.0-0-dev libudev-dev libdbus-glib-1-dev uuid-dev libxml2-dev libgstreamer1.0-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-base1.0-dev libfaad-dev libfaac-dev libswscale-dev clang-format

RUN git clone https://github.com/FreeRDP/FreeRDP /opt/FreeRDP
WORKDIR /opt/FreeRDP
RUN set -ex \
    && rm -rf /opt/FreeRDP/server/proxy/modules/demo \
    && cmake -DCMAKE_BUILD_TYPE=Release -DWITH_PROXY_MODULES=ON -DCHANNEL_URBDRC=OFF -DWITH_PROXY=ON -DWITH_SHADOW=OFF -DWITH_SERVER=ON -DBUILD_SHARED_LIBS=OFF \
    && cmake --build . -j $(nproc) \
    && cmake --build . --target install \
    && rm -f /usr/local/bin/xfreerdp

FROM ubuntu:20.04
WORKDIR /opt/freerdp
ARG TARGETARCH
ENV LANG=en_US.utf8
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && sed -i "s@http://.*.ubuntu.com@http://repo.huaweicloud.com@g" /etc/apt/sources.list \
    && apt update \
    && apt install -y --no-install-recommends libssl-dev libcups2-dev libavcodec-dev libpulse-dev libswscale-dev openssl iproute2 iputils-ping vim \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local /usr/local
COPY config.ini .
COPY entrypoint.sh .
RUN chmod 755 ./entrypoint.sh
CMD ["./entrypoint.sh"]
