#!/bin/bash
NGINX_VERSION="1.7.0"
NGINX_TARBALL="nginx-${NGINX_VERSION}.tar.gz"
PCRE_VERSION="8.35"
PCRE_TARBALL="pcre-${PCRE_VERSION}.tar.gz"
OPENSSL_VERSION="1.0.1g"
OPENSSL_TARBALL="openssl-${OPENSSL_VERSION}.tar.gz"
OPENSSL_PATCH_URL="https://bugs.archlinux.org/task/35868?getfile=10648"
 
if [[ "${1}" == "clean" ]]; then
  rm -rf nginx*
  rm -rf pcre-*
  rm -rf openssl-*
  exit 0
fi
 
if [[ ! -d "${NGINX_TARBALL%.tar.gz}" ]]; then
  wget "http://nginx.org/download/${NGINX_TARBALL}"
  tar xvzf "${NGINX_TARBALL}" && rm -f "${NGINX_TARBALL}"
fi
 
if [[ ! -d "${PCRE_TARBALL%.tar.gz}" ]]; then
  wget "http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/${PCRE_TARBALL}"
  tar xvzf "${PCRE_TARBALL}" && rm -f "${PCRE_TARBALL}"
fi
 
if [[ ! -d "${OPENSSL_TARBALL%.tar.gz}" ]]; then
  wget "http://www.openssl.org/source/${OPENSSL_TARBALL}"
  tar xvzf "${OPENSSL_TARBALL}" && rm -f "${OPENSSL_TARBALL}"
  cd "${OPENSSL_TARBALL%.tar.gz}"
fi
 
cd "nginx-${NGINX_VERSION}"
mkdir ../nginx
./configure --with-pcre=../pcre-${PCRE_VERSION} \
  --http-client-body-temp-path=/var/tmp/nginx/client_body_temp  \
  --http-fastcgi-temp-path=/var/tmp/nginx/fastcgi_temp \
  --http-proxy-temp-path=/var/tmp/nginx/proxy_temp \
  --http-scgi-temp-path=/var/tmp/nginx/scgi_temp \
  --http-log-path=/var/log/nginx-access.log \
  --with-openssl-opt=no-krb5 \
  --with-ld-opt="-static" \
  --with-cpu-opt=native \
  --with-cc=clang-devel
  --with-zlib-asm=native
  --with-sha1-asm
  --with-md5-asm
  --with-pcre-jit
  --with-cpp=clang++-devel
  --with-openssl=../openssl-${OPENSSL_VERSION} \
  --with-http_ssl_module \
  --with-http_spdy_module \
  --with-http_stub_status_module \
  --with-http_gzip_static_module \
  --with-file-aio \
  --with-pcre \
  --with-cc-opt="-O3 -static -static-libgcc" \
  --without-http_charset_module \
  --without-http_ssi_module \
  --without-http_userid_module \
  --without-http_access_module \
  --without-http_auth_basic_module \
  --without-http_autoindex_module \
  --without-http_geo_module \
  --without-http_map_module \
  --without-http_split_clients_module \
  --without-http_referer_module \
  --without-http_proxy_module \
  --without-http_uwsgi_module \
  --without-http_memcached_module \
  --without-http_empty_gif_module \
  --without-http_browser_module \
  --without-http_upstream_ip_hash_module \
  --without-http_upstream_least_conn_module \
  --without-http_upstream_keepalive_module \
  --without-mail_pop3_module \
  --without-mail_imap_module \
  --without-mail_smtp_module
 
sed -i '/CFLAGS/s/ \-O //g' objs/Makefile
make && make install