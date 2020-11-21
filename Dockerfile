FROM ubuntu:latest

# Added to avoid problematic debconf prompts during builds
# See https://github.com/moby/moby/issues/27988#issuecomment-462809153
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt -y update
RUN apt -y install apache2
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod headers
RUN a2enmod proxy_wstunnel
RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf
RUN a2enconf fqdn
# Make directories for custom bind mounts

RUN mkdir /etc/apache2/local 

# This is where all your configuration that's not part of the container build goes.
# You should bind mount it; to update with changes, restart the container.
RUN mkdir /etc/apache2/local/conf 

# Put SSL certs for your hosts here
RUN mkdir /etc/apache2/local/certs

COPY 999-local-sites.conf /etc/apache2/sites-available
RUN a2ensite 999-local-sites

# The usual running as a service won't work.
# Ref: http://www.inanzzz.com/index.php/post/rhsb/running-apache-server-as-foreground-on-ubuntu-with-dockerfile
CMD [ "/usr/sbin/apache2ctl","-DFOREGROUND"]

EXPOSE 80
EXPOSE 443
