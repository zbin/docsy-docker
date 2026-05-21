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

# mise use -g: 安装并激活工具（创建 shims，使命令在 PATH 中可用）
# hugo-extended: 带 SCSS/SASS 转译支持的 Hugo 版本
RUN mise use -g go@latest node@lts hugo-extended@latest

# Pre-fetch Hugo docsy module
RUN mkdir -p /tmp/hugo-mod-test && cd /tmp/hugo-mod-test \
    && hugo mod init github.com/tmp/test \
    && printf '[module]\n  [[module.imports]]\n    path = "github.com/google/docsy"\n' >> hugo.toml \
    && hugo mod get github.com/google/docsy \
    && rm -rf /tmp/hugo-mod-test

WORKDIR /src
