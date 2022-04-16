FROM --platform=$BUILDPLATFORM rustlang/rust:nightly AS builder

WORKDIR /app
COPY . .

ENV GRPC_HOST=0.0.0.0:50055
ENV GRPC_HOST_API=api:50051

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    gcc cmake libc6 libssl-dev

RUN cargo install --no-default-features --path .

FROM debian:buster-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates libssl-dev

COPY --from=builder /usr/local/cargo/bin/website_crawler /usr/local/bin/website_crawler
COPY --from=builder /usr/local/cargo/bin/health_client /usr/local/bin/health_client

ENV GRPC_HOST=0.0.0.0:50055
ENV GRPC_HOST_API=api:50051

CMD ["website_crawler"]