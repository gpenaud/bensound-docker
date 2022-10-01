# image: php:7.2-apache
FROM php@sha256:25417b6c9c2e1a52b551ba89087f4d07c216f58784773c9e7a1710a1f6e2b4a1

RUN apt-get --yes update && DEBIAN_FRONTEND=noninteractive apt-get --yes --no-install-recommends install \
  # for docker healthcheck
  curl \
  # Avoid error during gd extension installation
  libpng-dev \
  # Avoid error during ldap extension installation
  libldb-dev \
  libldap2-dev \
  # Avoid error during soap extension installation
  # "" configure: error: libxml2 not found. Please check your libxml2 installation. ""
  libxml2-dev \
  # Avoid error during intl extension installation
  # "" Unable to detect ICU prefix or no failed. Please verify ICU install prefix and make sure icu-config works. ""
  g++ \
  libicu-dev \
  zlib1g-dev

RUN docker-php-ext-install \
  bcmath \
  # cli \ Unfound as php extension
  # common \ Unfound as php extension
  gd \
  intl \
  ldap \
  mbstring \
  # mcrypt \ Unfound as php extension
  # mysqlnd \ Unfound as php extension
  # pear \ Unfound as php extension
  soap \
  # xml \ Unfound as php extension
  xmlrpc \
  zip

RUN a2enmod \
  ssl \
  proxy \
  proxy_http
