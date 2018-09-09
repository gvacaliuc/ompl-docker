FROM ubuntu:bionic

MAINTAINER Gabriel Vacaliuc "gabe.vacaliuc@gmail.com"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
    apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    fonts-liberation \
    lsb-release \
    tzdata \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN ln -fs /usr/share/zoneinfo/America/Chicago /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

RUN wget -O - http://ompl.kavrakilab.org/install-ompl-ubuntu.sh | bash -s -- --python --app

# Configure environment
ENV CONDA_DIR=/opt/conda \
    SHELL=/bin/bash \
    ENV_USER=ompl \
    ENV_UID=1000 \
    ENV_GID=100 \
    LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ENV PATH=$CONDA_DIR/bin:$PATH \
    HOME=/home/$ENV_USER

RUN echo "${LANG} UTF-8" > /etc/locale.gen && \
    locale-gen

ADD fix-permissions /usr/local/bin/fix-permissions

# create runtime user
RUN useradd -m -s /bin/bash -N -u $ENV_UID $ENV_USER && \
    mkdir -p $CONDA_DIR && \
    chown $ENV_USER:$ENV_GID $CONDA_DIR && \
    chmod g+w /etc/passwd /etc/group && \
    fix-permissions $HOME && \
    fix-permissions $CONDA_DIR

USER $ENV_UID

# Setup work directory for backward-compatibility
RUN mkdir /home/$ENV_USER/work && \
    fix-permissions $HOME

ENV LD_LIBRARY_PATH=/usr/local/lib

WORKDIR /home/$ENV_USER/work
