FROM alpine:3.13 as builder

ARG version=1.15.0

RUN apk update && apk add --no-cache \
  `# install tools` \
  git golang make \
  `# install dependencies` \
  linux-headers openssl-dev libunbound-dev libexpat

WORKDIR /coredns

RUN git clone --recursive --depth 1 --branch release-${version} https://github.com/AvapnoHelpingHand/coredns.git ./

ENV CGO_ENABLED=1

RUN echo "unbound:github.com/AvapnoHelpingHand/coredns-unbound" >> ./plugin.cfg

RUN go generate && make


FROM alpine:3.13 as app

WORKDIR /coredns

COPY --from=builder /coredns/coredns /coredns

RUN apk update && apk add --no-cache tini

ENTRYPOINT ["tini", "--"]