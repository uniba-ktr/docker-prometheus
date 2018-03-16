ARG IMAGE_TARGET=alpine

# first image to download qemu and make it executable
FROM alpine AS qemu
ARG QEMU=x86_64
ARG QEMU_VERSION=v2.11.0
ADD https://github.com/multiarch/qemu-user-static/releases/download/${QEMU_VERSION}/qemu-${QEMU}-static /qemu-${QEMU}-static
RUN chmod +x /qemu-${QEMU}-static

# second image to be deployed on dockerhub
FROM ${IMAGE_TARGET}
ARG QEMU=x86_64
COPY --from=qemu /qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
ARG ARCH=amd64
ARG PROMETHEUS_ARCH=amd64
ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

RUN mkdir -p /etc/prometheus /usr/share/prometheus /prometheus && \
    chown -R nobody:nogroup etc/prometheus /prometheus && \
    apk update && \
    apk add curl && \
    curl -s -L https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-${PROMETHEUS_ARCH}.tar.gz \
    | tar -xzf - && \
    cd /prometheus-* && \
    cp prometheus /bin/prometheus && \
    cp promtool /bin/promtool && \
    cp prometheus.yml /etc/prometheus/prometheus.yml && \
    cp -r console_libraries/ /usr/share/prometheus/console_libraries/ && \
    cp -r consoles/ /usr/share/prometheus/consoles/ && \
    rm -r /prometheus-*

USER       nobody
EXPOSE     9090
VOLUME     [ "/prometheus" ]
WORKDIR    /prometheus
ENTRYPOINT [ "/bin/prometheus" ]
CMD        [ "--config.file=/etc/prometheus/prometheus.yml", \
             "--storage.tsdb.path=/prometheus", \
             "--web.console.libraries=/usr/share/prometheus/console_libraries", \
             "--web.console.templates=/usr/share/prometheus/consoles" ]

LABEL de.uniba.ktr.prometheus.version=$VERSION \
      de.uniba.ktr.prometheus.name="Prometheus" \
      de.uniba.ktr.prometheus.docker.cmd="docker run --publish=9090:9090 --detach=true --name=prometheus unibaktr/prometheus" \
      de.uniba.ktr.prometheus.vendor="Marcel Grossmann" \
      de.uniba.ktr.prometheus.architecture=$ARCH \
      de.uniba.ktr.prometheus.vcs-ref=$VCS_REF \
      de.uniba.ktr.prometheus.vcs-url=$VCS_URL \
      de.uniba.ktr.prometheus.build-date=$BUILD_DATE
