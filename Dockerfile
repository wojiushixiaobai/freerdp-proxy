FROM ubuntu:focal
WORKDIR /opt
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

ARG BUILD_DEPENDENCIES="              \
    build-essential                   \
    autotools-dev                     \
    git                               \
    cmake                             \
    pkg-config                        \
    clang-format                      \
    libssl-dev                        \
    libsystemd-dev                    \
    libz-dev                          \
    libcairo2-dev"

RUN set -ex \
    && apt update \
    && apt install -y $BUILD_DEPENDENCIES

RUN git clone https://github.com/FreeRDP/FreeRDP /opt/FreeRDP
WORKDIR /opt/FreeRDP
RUN git fetch
RUN cmake -DCHANNEL_URBDRC=OFF -DWITH_PROXY=ON -DWITH_SHADOW=OFF -DWITH_SERVER=ON -DBUILD_SHARED_LIBS=ON
RUN cmake --build . -j $(nproc)
RUN cmake --build . --target install

FROM ubuntu:focal
LABEL org.opencontainers.image.source = "https://github.com/wojiushixiaobai/freerdp-proxy"
WORKDIR /opt/freerdp
ARG TARGETARCH
ENV LANG=en_US.utf8

RUN set -ex \
    && apt update \
    && apt install -y libssl-dev openssl \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "LANG=$LANG" > /etc/default/locale \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local /usr/local
COPY config.ini .
COPY entrypoint.sh .
RUN chmod 755 ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
