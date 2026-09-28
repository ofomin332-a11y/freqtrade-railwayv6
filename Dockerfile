FROM freqtradeorg/freqtrade:stable

WORKDIR /freqtrade

COPY . /freqtrade/

COPY railway-start.sh /railway-start.sh
RUN chmod +x /railway-start.sh

EXPOSE 8080

ENTRYPOINT ["/railway-start.sh"]
