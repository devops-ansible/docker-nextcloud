#!/usr/bin/env bash

check_file="/entrypoint_ran_scripts"

if [ ! -f "${check_file}" ]; then

    check=$( sudo -u ${NC_USER} php -d memory_limit=-1 ${NC_BASE_PATH}/occ -V 2>&1 )
    check=$( echo ${check} | sed 's/./\L&/g' )

    if [[ ! ${check} =~ "not installed" ]]; then

        sudo -u ${NC_USER} php -d memory_limit=-1 ${NC_BASE_PATH}/occ upgrade
        sudo -u ${NC_USER} php -d memory_limit=-1 ${NC_BASE_PATH}/occ db:add-missing-indices
        sudo -u ${NC_USER} php -d memory_limit=-1 ${NC_BASE_PATH}/occ maintenance:update:htaccess

        echo "${NC_APPS}" | sudo -u ${NC_USER} xargs -d ' ' -n1 php -d memory_limit=-1 ${NC_BASE_PATH}/occ app:install
        echo "${NC_APPS}" | sudo -u ${NC_USER} xargs -d ' ' -n1 php -d memory_limit=-1 ${NC_BASE_PATH}/occ app:enable

        touch "${check_file}"
    fi
fi
