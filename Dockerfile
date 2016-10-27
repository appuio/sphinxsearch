FROM openshift/base-centos7

USER root

LABEL io.k8s.description="Sphinx container with openshift centos 7 base" \
      io.k8s.display-name="Sphinx" \
      io.openshift.expose-services="9312:sphinx" \
      io.openshift.tags="sphinx"

# SLOW STUFF
# Slow operations, kept at top of the Dockerfile so they're cached for most changes.

# Install epel first
RUN yum update -y && \
    INSTALL_PKGS="epel-release" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    yum clean all -y

# Install Sphinx searchd
RUN yum update -y && \
    INSTALL_PKGS="sphinx" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    yum clean all -y

RUN mkdir -p log &&  mkdir -p tmp && mkdir -p db/sphinx/production
RUN chmod -R 777 log tmp db

ADD config/production.sphinx.conf ./config/production.sphinx.conf

USER 1001

EXPOSE 9312

CMD  indexer --config config/production.sphinx.conf --all --rotate && /usr/bin/searchd --config ./config/production.sphinx.conf
