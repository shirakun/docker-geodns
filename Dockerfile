FROM golang:1.13.15-alpine

ENV LICENSE_KEY ""

EXPOSE 53
EXPOSE 8053


RUN apk update \
 && apk add geoip-dev pkgconfig git gcc musl-dev \
 && go get github.com/abh/geodns \
 && cd $GOPATH/src/github.com/abh/geodns \
 && go get -t \
 && go test \
 && go build \
 && apk del pkgconfig git gcc musl-dev \
 && rm -rf /usr/local/go \
 && mkdir /dns 

# WORKDIR $GOPATH/src/github.com/abh/geodns
CMD mkdir -p /tmp/geoip \
&& wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=$LICENSE_KEY&suffix=tar.gz" -O /tmp/geoip/GeoLite2-Country.tar.gz \
&& wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=$LICENSE_KEY&suffix=tar.gz" -O /tmp/geoip/GeoLite2-City.tar.gz \
&& wget "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=$LICENSE_KEY&suffix=tar.gz" -O /tmp/geoip/GeoLite2-ASN.tar.gz \
&& tar -zxvf /tmp/geoip/GeoLite2-Country.tar.gz -C /tmp/geoip \
&& tar -zxvf /tmp/geoip/GeoLite2-City.tar.gz -C /tmp/geoip \
&& tar -zxvf /tmp/geoip/GeoLite2-ASN.tar.gz -C /tmp/geoip \
&& rm -rf /usr/share/GeoIP/* \
&& cp /tmp/geoip/GeoLite2-Country_*/GeoLite2-Country.mmdb /usr/share/GeoIP/GeoLite2-Country.mmdb \
&& cp /tmp/geoip/GeoLite2-City_*/GeoLite2-City.mmdb /usr/share/GeoIP/GeoLite2-City.mmdb \
&& cp /tmp/geoip/GeoLite2-ASN_*/GeoLite2-ASN.mmdb /usr/share/GeoIP/GeoLite2-ASN.mmdb \
&& rm -rf /tmp/geoip \
&& cd $GOPATH/src/github.com/abh/geodns \
&& ./geodns -config="/dns"