FROM alpine:3.11

COPY cpanfile /src/
#ENV EV_EXTRA_DEFS -DEV_NO_ATFORK

RUN apk update && \
  apk add --no-cache perl perl-io-socket-ssl perl-dev g++ make wget curl mariadb-connector-c mariadb-connector-c-dev shadow dcron tzdata unixodbc unixodbc-dev freetds freetds-dev
# && \

RUN \
# install perl dependences
  curl -L https://cpanmin.us | perl - App::cpanminus && \
  cd /src && \
# first install Number::Format without tests - it has problems without locale
  cpanm --notest Number::Format && \
# install other deps...
  cpanm --installdeps . -M https://cpan.metacpan.org
# && \

RUN \
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
#  sed -ri 's/(\$remote_user\s=\s['\''|"])/###\1/' lib/Esv.pm && \
  perl Makefile.PL && \
  make && \
  make install && \
# disable logs
  rm -rf /opt/esv/log && \
# make cron files
  echo > /var/spool/cron/crontabs/root && \
#  cat /src/support/docker-smbload.cron > /var/spool/cron/crontabs/esv && \
  echo "* * * * * date" >> /var/spool/cron/crontabs/esv && \
  cd / && rm -rf /src

WORKDIR /opt/esv

ENV ESV_CONFIG /opt/esv/esv.conf

USER esv:esv
#VOLUME ["/opt/esv/public"]
EXPOSE 3000

#CMD ["sh", "-c", "script/check_db_hosts && hypnotoad -f /opt/esv/script/esv"]
CMD ["sh"]
