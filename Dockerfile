FROM golang:alpine3.13 as builder

ARG version=1.8.6

RUN apk update && apk add --no-cache \
  `# install tools` \
  git make \
  `# install dependencies` \
  linux-headers openssl-dev unbound-dev expat-dev

WORKDIR /coredns

RUN git clone --recursive --depth 1 --branch v${version} https://github.com/AvapnoHelpingHand/coredns.git ./

ENV CGO_ENABLED=1

RUN go get github.com/AvapnoHelpingHand/coredns-unbound && \
    echo "unbound:github.com/AvapnoHelpingHand/coredns-unbound" >> ./plugin.cfg

RUN go generate && make


FROM golang:alpine3.13 as app

WORKDIR /coredns

COPY --from=builder /coredns/coredns /coredns

RUN apk update && apk add --no-cache tini

ENTRYPOINT ["tini", "--"]