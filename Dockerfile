FROM codekoala/arch
MAINTAINER "Josh VanderLinden <codekoala@gmail.com>"

VOLUME ["/torrents", "/watch"]
EXPOSE 80
CMD ["/app/start.sh"]

RUN pacman -Syu --noconfirm \
    apache \
    ffmpeg \
    mediainfo \
    mod_scgi \
    openvpn \
    php-apache \
    rsync \
    rtorrent \
    rutorrent \
    supervisor \
    unrar \
    unzip

# download the OpenVPN profiles for Private Internet Access and rename them to
# be suitable as systemd units
RUN curl -o /openvpn.zip https://www.privateinternetaccess.com/openvpn/openvpn.zip && \
    unzip -d /etc/openvpn/ /openvpn.zip && \
    cd /etc/openvpn && \
    ls -1 *.ovpn | while read f; do echo "mv -f '${f}'" $(echo "${f}" | sed -e 's/.*/\L&/g;s/ovpn/conf/;s/ /-/g'); done | sh

# reference the auth file for Private Internet Access
RUN sed -i 's/^auth-user-pass$/\0 \/pia.auth/' /etc/openvpn/*.conf

ADD app /app
ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/supervisor.d/* /etc/supervisor.d/
ADD conf/httpd.conf /etc/httpd/conf/httpd.conf
ADD conf/php.ini /etc/php/
