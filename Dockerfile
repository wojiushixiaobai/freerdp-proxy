FROM ubuntu:jammy
WORKDIR /opt
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

RUN set -ex \
    && apt update \
    && apt install -y ninja-build build-essential debhelper cdbs dpkg-dev autotools-dev cmake pkg-config xmlto libssl-dev docbook-xsl xsltproc git libsystemd-dev libz-dev

RUN git clone -b 2.7.0 https://github.com/FreeRDP/FreeRDP /opt/FreeRDP
WORKDIR /opt/FreeRDP
RUN set -ex \
    && rm -rf /opt/FreeRDP/server/proxy/modules/demo \
    && cmake -DCMAKE_BUILD_TYPE=Release -DWITH_PROXY_MODULES=ON -DCHANNEL_URBDRC=OFF -DWITH_PROXY=ON -DWITH_SHADOW=OFF -DWITH_SERVER=ON -DBUILD_SHARED_LIBS=ON -DPROXY_PLUGINDIR=/usr/local/lib/freerdp/proxy/plugins \
    && cmake --build . -j $(nproc) \
    && cmake --build . --target install

FROM ubuntu:jammy
WORKDIR /opt/freerdp
ARG TARGETARCH
ENV LANG=en_US.utf8

RUN set -ex \
    && apt update \
    && apt install -y libssl-dev openssl iproute2 iputils-ping vim \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local /usr/local
COPY --from=0 /opt/FreeRDP/server/proxy/server.crt .
COPY --from=0 /opt/FreeRDP/server/proxy/server.key .
COPY config.ini .
COPY entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
