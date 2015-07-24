#!/bin/bash

set -e


warn() {
  echo "[WARN] $*"
}
crit() {
  echo "[CRIT] $*"
  exit 1
}

PIA_PROFILE=${PIA_PROFILE:-us-west}

[ ! -d /torrents ] && crit "Torrent directory not mounted (-v /your/torrents:/torrents"

mkdir -p /app/rutorrent /watch

# restore settings
rsync -a /app/rutorrent/* /usr/share/webapps/rutorrent/share/settings/

# create the tun device
[ -d /dev/net ] || mkdir -p /dev/net
[ -c /dev/net/tun ] || mknod /dev/net/tun c 10 200

if [ ! -f /app/runonce ]; then
  echo "Performing first time setup"

  # setup PIA credentials
  auth=/pia.auth
  if [ ! -f ${auth} ]; then
    [ -z "${PIA_USER}" ] && crit "PIA_USER not specified"
    [ -z "${PIA_PASS}" ] && crit "PIA_PASS not specified"

    echo "${PIA_USER}" > ${auth}
    echo "${PIA_PASS}" >> ${auth}
  fi

  # check UID/GID
  if [ ${RT_UID} -ne 0 -o ${RT_UID} -eq 0 2>/dev/null ]; then
    if [ ${RT_UID} -lt 100 -o ${RT_UID} -gt 65535 ]; then
      warn "RT_UID out of (100..65535) range, using default of 500"
      RT_UID=500
    fi
  else
    warn "RT_UID non-integer detected, using default of 500"
    RT_UID=500
  fi

  if [ ${RT_GID} -ne 0 -o ${RT_GID} -eq 0 2>/dev/null ]; then
    if [ ${RT_GID} -lt 100 -o ${RT_GID} -gt 65535 ]; then
       warn "RT_GID out of (100..65535) range, using default of 500"
       RT_GID=500
    fi
  else
    warn "RT_GID non-integer detected, using default of 500"
    RT_GID=500
  fi

  # add UID/GID or use existing
  groupadd --gid ${RT_GID} torrents || echo "Using existing group ${RT_GID}"
  useradd --gid ${RT_GID} --no-create-home --uid ${RT_UID} torrents

  cat > /etc/supervisor.d/openvpn.conf <<EOT
[program:openvpn]
command=/usr/bin/openvpn --cd /etc/openvpn --config /etc/openvpn/${PIA_PROFILE}.conf
EOT

  # set runonce so it... runs once
  touch /app/runonce
fi

chown -R ${RT_UID}:${RT_GID} /torrents

/usr/bin/supervisord --configuration /etc/supervisord.conf --nodaemon

# vim:ts=2 sw=2 ai:
