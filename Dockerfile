
FROM alpine
ARG TARGETPLATFORM=amd64
ARG VERSION=2.2.1
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL

RUN mkdir -p /etc/prometheus /usr/share/prometheus /prometheus && \
    chown -R nobody:nogroup etc/prometheus /prometheus && \
    apk update && \
    apk add curl && \
    curl -s -L https://github.com/prometheus/prometheus/releases/download/v${VERSION}/prometheus-${VERSION}.linux-$(echo ${TARGETPLATFORM} | sed -e "s|arm32v5|armv5|g" -e "s|arm32v6|armv6|g" -e "s|arm32v7|armv7|g" -e "s|arm64.*|arm64|g" -e "s|i386|386|g").tar.gz \
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
      de.uniba.ktr.prometheus.architecture=$TARGETPLATFORM \
      de.uniba.ktr.prometheus.vcs-ref=$VCS_REF \
      de.uniba.ktr.prometheus.vcs-url=$VCS_URL \
      de.uniba.ktr.prometheus.build-date=$BUILD_DATE
