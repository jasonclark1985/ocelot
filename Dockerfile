# latest: docker-registry.threega.com/ocelot:<same as npm version>

FROM alpine:3.1

RUN apk add --update nodejs

ADD ./ ./

CMD npm start

EXPOSE 8080
EXPOSE 8081
