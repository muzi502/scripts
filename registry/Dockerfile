FROM quay.io/skopeo/stable:v1.3.0 as images-builder
WORKDIR /build
COPY . .
RUN bash build.sh build docker.io
FROM scratch
COPY --from=images-builder /build/docker /docker
