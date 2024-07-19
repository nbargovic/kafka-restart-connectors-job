FROM registry1.dso.mil/ironbank/big-bang/base:2.1.0

USER root

COPY restart-connectors.sh /opt/restart-connectors.sh
RUN chmod 755 /opt/restart-connectors.sh

USER 1000
