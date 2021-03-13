FROM alpine:3.11

COPY cpanfile /src/
#ENV EV_EXTRA_DEFS -DEV_NO_ATFORK

RUN apk update && \
  apk add --no-cache perl perl-io-socket-ssl perl-dev g++ make wget curl mariadb-connector-c mariadb-connector-c-dev shadow tzdata unixodbc unixodbc-dev freetds freetds-dev patch && \
# install perl dependences
  curl -L https://cpanmin.us | perl - App::cpanminus && \
  cd /src && \
# first install Number::Format without tests - it has problems without locale
  cpanm --notest Number::Format && \
# install other deps...
  cpanm --installdeps . -M https://cpan.metacpan.org && \
# create esv user
  groupadd esv && \
  useradd -N -g esv -M -d /opt/esv/run -s /sbin/nologin -c "ESV user" esv && \
# fix ping to run under user
  chmod u+s /bin/ping && \
# cleanup
  apk del perl-dev g++ wget curl mariadb-connector-c-dev shadow freetds-dev unixodbc-dev && \
  rm -rf /root/.cpanm/* /usr/local/share/man/* /src/cpanfile

COPY . /src/

RUN cd /src && \
  sed -ri 's/(\$remote_user\s=\s['\''|"])/###\1/' lib/Esv.pm && \
  perl Makefile.PL && \
  make && \
  make install && \
# disable logs
  rm -rf /opt/esv/log && \
# setup alpine tds
  { echo ; \
    echo '[oper_sheets]'; \
    echo 'host = 10.5.51.2'; \
    echo 'port = 1433'; \
    echo 'database = sheets'; \
    echo 'tds version = 7.1'; \
    echo 'client charset = UTF-8'; \
    echo 'text size = 64512'; } >> /etc/freetds.conf && \
# setup alpine unixodbc
  { echo '[FreeTDS]'; \
    echo 'Description = FreeTDS driver'; \
    echo 'Driver = /usr/lib/libtdsodbc.so.0'; \
    echo 'UsageCount = 1'; } >> /etc/odbcinst.ini && \
  { echo '[oper_sheets]'; \
    echo 'Driver = FreeTDS'; \
    echo 'Server = 10.5.51.2'; \
    echo 'Port = 1433'; \
    echo 'Database = sheets'; \
    echo 'UsageCount = 1'; } >> /etc/odbc.ini && \
# patch AnyEvent::InfluxDB
  cp /src/support/AnyEvent/InfluxDB.pm.patch /usr/local/share/perl5/site_perl/AnyEvent/ && \
  cd /usr/local/share/perl5/site_perl/AnyEvent && \
  patch <InfluxDB.pm.patch && \
  rm InfluxDB.pm.patch && \
# cleanup
  cd / && rm -rf /src

WORKDIR /opt/esv

ENV ESV_CONFIG /opt/esv/esv.conf
# required for DateTime
ENV TZ Asia/Yekaterinburg

USER esv:esv
#VOLUME ["/opt/esv/public"]
EXPOSE 3000

#CMD ["sh", "-c", "script/check_db_hosts && hypnotoad -f /opt/esv/script/esv"]
CMD ["sh", "-c", "script/check_db_hosts && script/start_server"]

