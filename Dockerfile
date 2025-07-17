FROM alpine:3.22.1

ARG CRON_TIME="30 0 * * *"
ARG CRON_DIR="/etc/periodic/AutomatedBackup"
ARG SCRIPT_NAME="doBackup"

RUN apk add --no-cache mariadb-client

RUN mkdir "${CRON_DIR}"
RUN crontab -l | { cat; echo "$CRON_TIME run-parts ${CRON_DIR}"; } | crontab -
COPY "./${SCRIPT_NAME}.sh" "${CRON_DIR}/${SCRIPT_NAME}"
RUN chmod +x "${CRON_DIR}/${SCRIPT_NAME}"

CMD ["crond", "-f"]
