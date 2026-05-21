FROM debian:13-slim

RUN apt-get update  \
    && apt-get -y --no-install-recommends install  \
        sudo curl git ca-certificates build-essential \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV MISE_DATA_DIR="/mise"
ENV MISE_CONFIG_DIR="/mise"
ENV MISE_CACHE_DIR="/mise/cache"
ENV MISE_INSTALL_PATH="/usr/local/bin/mise"
ENV PATH="/mise/shims:$PATH"

RUN curl https://mise.run | sh

COPY .mise.toml /mise/config.toml

RUN mise install

# Pre-fetch Hugo docsy module
RUN mkdir -p /tmp/hugo-mod-test && cd /tmp/hugo-mod-test \
    && hugo mod init github.com/tmp/test \
    && printf '[module]\n  [[module.imports]]\n    path = "github.com/google/docsy"\n' >> hugo.toml \
    && hugo mod get github.com/google/docsy \
    && rm -rf /tmp/hugo-mod-test

WORKDIR /src
