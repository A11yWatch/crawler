FROM rustlang/rust:nightly AS builder

WORKDIR /app
COPY . .

RUN cargo install --path .

FROM debian:buster-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    ca-certificates wget gcc libssl-dev libc6-dev

COPY --from=builder /usr/local/cargo/bin/website_crawler /usr/local/bin/website_crawler

ARG CRAWL_URL
ARG CRAWL_URL_BACKGROUND
ARG SCAN_URL_COMPLETE
ARG SCAN_URL_START

ENV ROCKET_ADDRESS=0.0.0.0
ENV ROCKET_PORT=8000
ENV ROCKET_ENV="prod"

ENV CRAWL_URL="${CRAWL_URL:-http://api:8080/api/website-crawl}"
ENV CRAWL_URL_BACKGROUND="${CRAWL_URL_BACKGROUND:-http://api:8080/api/website-crawl-background}"
ENV SCAN_URL_COMPLETE="${SCAN_URL_COMPLETE:-http://api:8080/api/website-crawl-background-complete}"
ENV SCAN_URL_START="${SCAN_URL_START:-http://api:8080/api/website-crawl-background-start}"

EXPOSE 8000

CMD ["website_crawler"]