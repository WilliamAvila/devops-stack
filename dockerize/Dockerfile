FROM golang:1.18-alpine

WORKDIR /dockerize


COPY webserver.go ./
COPY src ./src
COPY webserver/articlehandler/articleHandler.go ./webserver/articlehandler/
COPY server.confi ./
COPY go.mod ./
COPY go.sum ./


RUN go build -o main webserver.go 
CMD ["./main"]

EXPOSE 8080