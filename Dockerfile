FROM openjdk:jre-alpine as builder

COPY qemu-*-static /usr/bin/

FROM builder

LABEL maintainer="Jay MOULIN <jaymoulin@gmail.com> <https://twitter.com/MoulinJay>"

# archive extraction uses sevenzipjbinding library
# which is compiled against libstdc++
RUN mkdir -p /opt/JDownloader/
RUN apk add --update libstdc++ ffmpeg && apk add wget  --virtual .build-deps && \
    wget -O /opt/JDownloader/JDownloader.jar "http://installer.jdownloader.org/JDownloader.jar?$RANDOM" && chmod +x /opt/JDownloader/JDownloader.jar && \
    wget -O /sbin/tini "https://github.com/krallin/tini/releases/download/v0.16.1/tini-static-armhf" --no-check-certificate && chmod +x /sbin/tini && \
    apk del wget --purge .build-deps
ENV LD_LIBRARY_PATH=/lib;/lib32;/usr/lib

ADD daemon.sh /opt/JDownloader/
ADD default-config.json.dist /opt/JDownloader/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json.dist
ADD configure.sh /usr/bin/configure

VOLUME /root/Downloads
VOLUME /opt/JDownloader/cfg
WORKDIR /opt/JDownloader

CMD ["/sbin/tini", "--", "/opt/JDownloader/daemon.sh"]
