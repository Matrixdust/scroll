ARG ALPINE_VERSION=3.15
FROM alpine:${ALPINE_VERSION}
ARG CARGO_CHEF_TAG=0.1.41
ARG DEFAULT_RUST_TOOLCHAIN=nightly-2022-08-23

RUN apk add --no-cache \
        ca-certificates \
        gcc \
        musl-dev

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

RUN set -eux; \
    apkArch="$(apk --print-arch)"; \
    case "$apkArch" in \
        x86_64) rustArch='x86_64-unknown-linux-musl' ;; \
        aarch64) rustArch='aarch64-unknown-linux-musl' ;; \
        *) echo >&2 "unsupported architecture: $apkArch"; exit 1 ;; \
    esac; \
    \
    url="https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init"; \
    wget "$url"; \
    chmod +x rustup-init;

RUN ./rustup-init -y --no-modify-path --default-toolchain ${DEFAULT_RUST_TOOLCHAIN}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

RUN cargo install cargo-chef --locked --version ${CARGO_CHEF_TAG} \
    && rm -rf $CARGO_HOME/registry/