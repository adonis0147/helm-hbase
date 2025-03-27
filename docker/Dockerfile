FROM alpine:latest AS builder

WORKDIR /tmp

COPY hbase-*.tar.gz .
RUN tar -zxvf hbase-*.tar.gz -C /

COPY jdk-* .
RUN tar -zxvf jdk-*.tar.gz -C /

FROM ubuntu:latest

RUN mkdir -p /home/hbase

WORKDIR /home/hbase

COPY --from=builder hbase-* /home/hbase/hbase-current
COPY --from=builder /jdk-* /opt/java

ENV PATH="/opt/java/bin:/home/hbase/hbase-current/bin:${PATH}"
ENV JAVA_HOME='/opt/java'
ENV HBASE_LOG_DIR='/home/hbase/cluster-data/hbase/logs'
ENV HBASE_PID_DIR='/home/hbase/cluster-data/hbase/pids'

CMD ["/usr/bin/bash"]
