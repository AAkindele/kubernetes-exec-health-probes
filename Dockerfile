FROM alpine

COPY . /app

WORKDIR /app

RUN addgroup -S demo && \
    adduser -S demo -G demo && \
    chown -R demo:demo /app

USER demo

ENTRYPOINT [ "./app.sh" ]
