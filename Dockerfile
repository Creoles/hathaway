FROM daocloud.io/ubuntu:14.04
MAINTAINER CongjieRan "rancongjie@126.com"
RUN apt-get -y update && apt-get install -y nginx && apt-get install -y nodejs
WORKDIR /
RUN npm i cooking-cli -g
RUN npm run dist
RUN cp -R /* /var/www/html
EXPOSE 80 8080
CMD ["nginx", "-g", "daemon off;"]