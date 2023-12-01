FROM uqlibrary/centos:191030

ENV COMPOSER_VERSION=2.6.5

RUN \
  rpm -Uvh http://yum.newrelic.com/pub/newrelic/el5/x86_64/newrelic-repo-5-3.noarch.rpm && \
  #Enable the ius testing and disable mirrors to ensure getting latest, not an out of date mirror
  sed -i "s/mirrorlist/#mirrorlist/" /etc/yum.repos.d/ius-testing.repo && \
  sed -i "s/#baseurl/baseurl/" /etc/yum.repos.d/ius-testing.repo

RUN yum update -y && \
  yum install -y http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
  yum install -y yum-utils \
  epel-release

RUN yum-config-manager --disable remi-php54 && \
    yum-config-manager --enable remi-php73

RUN yum update -y && \
    yum install -y \
    php-common \
    php-cli \
    php-fpm \
    php-gd \
    php-imap \
    php-ldap \
    php-mcrypt \
    php-mysqlnd \
    php-pdo \
    php-pecl-geoip \
    php-pecl-memcached \
    php-pecl-xdebug \
    php-pecl-zip \
    php-intl \
    php-pgsql \
    php-soap \
    php-xmlrpc \
    php-mbstring \
    php-tidy \
    php-opcache \
    git \
    newrelic-php5 \
    newrelic-sysmond \
    mysql \
    telnet \
    which && \
  yum clean all


RUN \
  mkdir -p /run/php-fpm && \
  sed -i "s/;date.timezone =.*/date.timezone = Australia\/Brisbane/" /etc/php.ini && \
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini && \
  sed -i "s/display_errors =.*/display_errors = Off/" /etc/php.ini && \
  sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 30M/" /etc/php.ini && \
  sed -i -e "s/daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf && \
  sed -i "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php-fpm.conf && \
  sed -i "s/;log_level = notice/log_level = warning/" /etc/php-fpm.conf && \
  usermod -u 1000 nobody && \
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer --version=${COMPOSER_VERSION}

ADD fs /

EXPOSE 9000

ENV NSS_SDB_USE_CACHE YES
ENTRYPOINT ["/usr/sbin/php-fpm", "-R", "--nodaemonize"]​
