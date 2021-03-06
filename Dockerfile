FROM centos:6.10

COPY assets_11g /assets_11g
RUN /assets_11g/setup_docker.sh

EXPOSE 22
EXPOSE 1521
EXPOSE 8080

CMD /usr/sbin/startup.sh && tail -f /dev/null