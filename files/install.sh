#!/usr/bin/env bash

chmod a+x /boot.sh \
          /_usr_local_bin/*
mv /_usr_local_bin/* /usr/local/bin/
rm -rf /_usr_local_bin

# upgrade and install applets and services
apt-get update -q --fix-missing
apt-get -yq install --no-install-recommends \
        procps apt-utils \
        sudo
apt-get -yq upgrade

# perform installation cleanup
apt-get -y clean
apt-get -y autoclean
apt-get -y autoremove
rm -r /var/lib/apt/lists/*

# prepare entrypoint
entrypoint_path="/usr/local/bin/entrypoint"

which supervisord
if [ $? -eq 0 ]; then
    # supervisord is installed, so write out
    # entrypoint for full image, which starts
    # the nextcloud by using supervisord
    sed -i 's|{{ STARTUP_COMMAND }}|/usr/bin/supervisord -c /supervisord.conf|g' ${entrypoint_path}
else
    # no supervisord is installed, so write out
    # entrypoint for simply starting Apache2
    sed -i 's/{{ STARTUP_COMMAND }}/apache2-foreground/g' ${entrypoint_path}
fi

chmod a+x /usr/local/bin/entrypoint
