# Base build image
FROM golang:1.22-alpine as builder

RUN apk update && apk add git
WORKDIR /app 

# Pass in the version number on the Docker command line:
# docker build -t foo/bar --build-arg VERSION=1.2.3
# or default to "0.0.0"
ARG VERSION=0.0.0
ARG GO_VERSION=0.0.0
ARG GIT_COMMIT=""
ARG GIT_BRANCH=""
ARG BUILD_DATE=""
ENV VERSION=${VERSION}
ENV GO_VERSION=${GO_VERSION}
ENV GIT_COMMIT=${GIT_COMMIT}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV BUILD_DATE=${BUILD_DATE}

# Module cache and dependencies
COPY go.mod go.sum ./
RUN go mod download 

# Here we copy the rest of the source code
COPY . ./

# And compile the project
ENV CGO_ENABLED=0
ENV GOOS=linux
RUN go build -a -installsuffix cgo -ldflags "-w -X main.Version=${VERSION} -X main.BuildDate=${BUILD_DATE} -X main.GoVersion=${GO_VERSION} -X main.Commit=${GIT_COMMIT} -X main.Branch=${GIT_BRANCH}" -o /app/elector cmd/elector.go

FROM scratch
WORKDIR /app
COPY --from=builder /app/elector /app/elector 

CMD ["/app/elector"]