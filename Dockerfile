FROM golang:1.5.0

# Install the GeoIP C library.
RUN apt-get update \
 && apt-get install -y libgeoip-dev pkg-config

# Download the GeoIP data files from Maxmind.
# No GeoLite2 support yet, see https://github.com/abh/geodns/issues/66
RUN cd /usr/share/GeoIP \
 && rm -f * \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz \
 && wget http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz \
 && wget http://download.maxmind.com/download/geoip/database/asnum/GeoIPASNum.dat.gz \
 && gzip -d GeoIP.dat.gz \
 && gzip -d GeoLiteCity.dat.gz \
 && gzip -d GeoIPASNum.dat.gz \
 && mv GeoLiteCity.dat GeoIPCity.dat

# Download, test & build the GeoDNS server.
RUN go get github.com/abh/geodns \
 && cd $GOPATH/src/github.com/abh/geodns \
 && go get -t \
 && go test \
 && go build

 EXPOSE 53
 EXPOSE 8053

RUN mkdir /dns
WORKDIR $GOPATH/src/github.com/abh/geodns
CMD ./geodns -config="/dns"


FROM golang:1.13.15-alpine

# Install the GeoIP C library.
RUN apk update \
 && apk add geoip-dev pkgconfig

# Download the GeoIP data files from Maxmind.
# No GeoLite2 support yet, see https://github.com/abh/geodns/issues/66
RUN cd /usr/share/GeoIP \
 && rm -f * \
 && wget https://dl.miyuru.lk/geoip/maxmind/country/maxmind.dat.gz -O GeoIP.dat.gz \
 && gzip -d GeoIP.dat.gz \
 && mv maxmind.dat GeoIP.dat \
 && wget https://dl.miyuru.lk/geoip/maxmind/city/maxmind.dat.gz -O GeoLiteCity.dat.gz \
 && gzip -d GeoLiteCity.dat.gz \
 && mv maxmind.dat GeoIPCity.dat \
 && wget https://dl.miyuru.lk/geoip/maxmind/asn/maxmind.dat.gz -O GeoIPASNum.dat.gz \
 && gzip -d GeoIPASNum.dat.gz \
 && mv maxmind.dat GeoIPASNum.dat

# Download, test & build the GeoDNS server.
RUN go get github.com/abh/geodns \
 && cd $GOPATH/src/github.com/abh/geodns \
 && go get -t \
 && go test \
 && go build

 EXPOSE 53
 EXPOSE 8053

RUN mkdir /dns
WORKDIR $GOPATH/src/github.com/abh/geodns
CMD ./geodns -config="/dns"