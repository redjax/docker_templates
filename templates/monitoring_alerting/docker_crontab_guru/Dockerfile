FROM alpine:latest

ARG DASHBOARD_USERNAME
ARG DASHBOARD_PASSWORD

RUN apk add --no-cache \
  curl \
  bash \
  ca-certificates \
  dcron \
  tar

# Download and install cronitor (PLAIN URL)
RUN curl -sL https://cronitor.io/dl/linux_amd64.tar.gz | \
    tar -xz -C /usr/local/bin/ && \
    chmod +x /usr/local/bin/cronitor

# Create spool dir for dashboard
RUN mkdir -p /var/spool/cron/crontabs && \
    chmod 755 /var/spool/cron/crontabs

# Configure dashboard auth
RUN cronitor configure \
    --dash-username "${DASHBOARD_USERNAME}" \
    --dash-password "${DASHBOARD_PASSWORD}"

EXPOSE 9000

# Start dashboard
CMD ["cronitor", "dash", "--port", "9000"]

