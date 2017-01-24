FROM centos

LABEL description="A Yum repo in a docker container." \
maintainer="Matt Bacchi <mbacchi@gmail.com>" \
version="0.1.0"

WORKDIR workdir

RUN ["yum", "install", "-y", "httpd"]

COPY workdir/* /var/www/html/docker-yumrepo/
COPY docker-yumrepo.conf /etc/httpd/conf.d/

CMD ["-D", "FOREGROUND"]
ENTRYPOINT ["/usr/sbin/httpd"]
