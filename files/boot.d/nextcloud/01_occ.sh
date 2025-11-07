#!/usr/bin/env bash

check_file="/entrypoint_ran_scripts"

if [ ! -f "${check_file}" ]; then

    check=$( sudo -u ${NC_D_USER:-${NC_USER:-www-data}} php -d memory_limit=-1 ${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ -V 2>&1 )
    check=$( echo ${check} | sed 's/./\L&/g' )

    if [[ ! ${check} =~ "not installed" ]]; then

        sudo -u ${NC_D_USER:-${NC_USER:-www-data}} php -d memory_limit=-1 ${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ upgrade
        sudo -u ${NC_D_USER:-${NC_USER:-www-data}} php -d memory_limit=-1 ${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ db:add-missing-indices
        sudo -u ${NC_D_USER:-${NC_USER:-www-data}} php -d memory_limit=-1 ${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ maintenance:update:htaccess

        echo "${NC_D_APPS:-${NC_APPS}}" | sudo -u ${NC_D_USER:-${NC_USER:-www-data}} xargs -d ' ' -n1 php -d memory_limit=-1 ${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ app:install
        echo "${NC_D_APPS:-${NC_APPS}}" | sudo -u ${NC_D_USER:-${NC_USER:-www-data}} xargs -d ' ' -n1 php -d memory_limit=-1 ${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ app:enable

        touch "${check_file}"
    fi
fi
