FROM golang:alpine3.13 as builder

ARG version=1.9.0

RUN apk update && apk add --no-cache \
  `# install tools` \
  git gcc musl-dev make \
  `# install dependencies` \
  linux-headers unbound-dev expat-dev ca-certificates

RUN update-ca-certificates

WORKDIR /coredns

RUN git clone --recursive --depth 1 --branch v${version} https://github.com/AvapnoHelpingHand/coredns.git ./

RUN go get github.com/AvapnoHelpingHand/coredns-unbound && \
    echo "unbound:github.com/AvapnoHelpingHand/coredns-unbound" >> ./plugin.cfg

RUN go generate && make CGO_ENABLED=1

FROM golang:alpine3.13 as app

WORKDIR /coredns

COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /coredns/coredns /coredns

RUN apk update && apk add --no-cache tini unbound-libs

ENTRYPOINT ["tini", "--", "/coredns/coredns"]