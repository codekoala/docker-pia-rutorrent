Private Internet Access + ruTorrent
===================================

ArchLinux-based Docker container running rTorrent and ruTorrent behind Apache
and using a Private Internet Access VPN.

Example usage:

    docker run -d \
        -p 8080:80 \
        --cap-add=NET_ADMIN \
        --dns=209.22.18.222 \
        --dns=209.22.18.218 \
        -v ~/Downloads/torrents:/torrents \
        -v ~/.config/rutorrent:/app/rutorrent \
        -v ~/Downloads/watch:/watch \
        -e PIA_USER=<user> \
        -e PIA_PASS=<password> \
        -e PIA_PROFILE=<gateway> \
        -e RT_UID=1000 \
        -e RT_GID=1000 \
        --name rutorrent \
        codekoala/rutorrent

Environment Variables
---------------------

- ``PIA_USER``: your PIA username
- ``PIA_PASS``: your PIA password
- ``PIA_PROFILE``: the name of the PIA OpenVPN profile to use (see
  https://www.privateinternetaccess.com/pages/client-support/ for options)
- ``RT_UID``: Numeric user ID to assign to the rtorrent user
- ``RT_GID``: Numeric group ID to assign to the rtorrent user

Notes
-----

- If you wish to not lose ruTorrent configuration when you re-create the
  container, use the ``-v /some/path:/app/rutorrent`` option.
- The DNS options are there to protect against DNS requests leaking. You may
  use whatever DNS servers you wish.
