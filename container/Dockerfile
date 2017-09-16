FROM ubuntu
RUN apt-get -y update
RUN apt-get -y install git
RUN apt-get -y install nodejs
RUN apt-get -y install npm
RUN git clone https://github.com/cubedro/eth-netstats
RUN cd eth-netstats && \
    npm install && \
    npm install -g grunt-cli && \
    ln -s /usr/bin/nodejs /usr/bin/node && \
    grunt
ENV WS_SECRET helloworld123
WORKDIR /eth-netstats/
CMD npm start
