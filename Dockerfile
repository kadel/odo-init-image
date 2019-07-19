#
# This is an "initContainer" image using the base "source-to-image" OpenShift template
# in order to appropriately inject the supervisord binary into the application container.
#

FROM openshift/origin-release:golang-1.12 AS gobuilder

RUN mkdir -p /go/src/github.com/openshift/odo-supervisord-image/
ADD . /go/src/github.com/openshift/odo-supervisord-image/
WORKDIR /go/src/github.com/openshift/odo-supervisord-image/
RUN go build getlanguage.go


FROM registry.access.redhat.com/ubi7/ubi

ENV SUPERVISORD_DIR /opt/supervisord

ADD https://github.com/Yelp/dumb-init/releases/download/v1.2.2/dumb-init_1.2.2_amd64 ${SUPERVISORD_DIR}/bin/dumb-init 
RUN chmod +x ${SUPERVISORD_DIR}/bin/dumb-init

RUN mkdir -p ${SUPERVISORD_DIR}/conf ${SUPERVISORD_DIR}/bin

ADD supervisor.conf ${SUPERVISORD_DIR}/conf/
ADD https://raw.githubusercontent.com/sclorg/s2i-base-container/master/core/root/usr/bin/fix-permissions  /usr/bin/fix-permissions
RUN chmod +x /usr/bin/fix-permissions

ADD https://github.com/ochinchina/supervisord/releases/download/v0.5/supervisord_0.5_linux_amd64 ${SUPERVISORD_DIR}/bin/supervisord

ADD assemble-and-restart ${SUPERVISORD_DIR}/bin
ADD run ${SUPERVISORD_DIR}/bin
ADD s2i-setup ${SUPERVISORD_DIR}/bin
ADD setup-and-run ${SUPERVISORD_DIR}/bin

COPY --from=gobuilder /go/src/github.com/openshift/odo-supervisord-image/getlanguage ${SUPERVISORD_DIR}/bin


ADD language-scripts ${SUPERVISORD_DIR}/language-scripts/

RUN chgrp -R 0 ${SUPERVISORD_DIR}  && \
    chmod -R g+rwX ${SUPERVISORD_DIR} && \
    chmod -R 666 ${SUPERVISORD_DIR}/conf/* && \
    chmod 775 ${SUPERVISORD_DIR}/bin/supervisord
