FROM alpine AS builder

RUN apk add --no-cache cmake g++ git make rapidjson-dev

# The valijson release that is tested, and reported as the implementation version
ARG VALIJSON_VERSION=1.1.5

WORKDIR /tmp
RUN git clone --recurse-submodules --depth=1 --branch "v${VALIJSON_VERSION}" https://github.com/tristanpenman/valijson.git
RUN mkdir valijson/build && cd valijson/build && cmake .. && cmake --install .

WORKDIR /usr/src/myapp
COPY . .

RUN g++ -static -std=c++17 -DVALIJSON_USE_EXCEPTIONS=1 -DVALIJSON_VERSION="\"${VALIJSON_VERSION}\"" -o bowtie-valijson bowtie_valijson.cpp

FROM alpine
COPY --from=builder /usr/src/myapp/bowtie-valijson /usr/local/bin

CMD ["bowtie-valijson"]
