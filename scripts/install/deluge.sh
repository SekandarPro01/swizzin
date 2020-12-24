#!/bin/bash
#
# [Swizzin :: Install Deluge package]
# Author: liara
#
# Copyright (C) 2017 Swizzin
# Licensed under GNU General Public License v3.0 GPL-3 (in short)
#
#   You may copy, distribute and modify the software as long as you track
#   changes/dates in source files. Any modifications to our software
#   including (via compiler) GPL-licensed code must also be made available
#   under the GPL along with build & install instructions.
#
#################################################################################

. /etc/swizzin/sources/functions/deluge
. /etc/swizzin/sources/functions/libtorrent
. /etc/swizzin/sources/functions/utils
local_packages=/usr/local/bin/swizzin
users=($(_get_user_list))
master=$(_get_master_username)
pass=$(cut -d: -f2 < /root/.master.info)
codename=$(lsb_release -cs)
ip=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')

if [[ -n $1 ]]; then
    users=($1)
    _dconf
    if [[ -f /install/.nginx.lock ]]; then
        bash /etc/swizzin/scripts/nginx/deluge.sh $users
        systemctl reload nginx
    fi
    exit 0
fi

whiptail_deluge
#check_client_compatibility
install_fpm

if ! skip_libtorrent_rasterbar; then
    echo_progress_start "Building libtorrent-rasterbar"
    build_libtorrent_deluge
    echo_progress_done "Libtorrent-rasterbar installed"
fi

build_deluge

_dconf
_dservice

touch /install/.deluge.lock
touch /install/.delugeweb.lock
