#!/usr/bin/env bash

check_file="/entrypoint_ran_scripts"

if [ ! -f "${check_file}" ]; then

    check=$( sudo -u ${NC_D_USER:-${NC_USER:-www-data}} php -d memory_limit=-1 ${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ -V 2>&1 )
    check=$( echo ${check} | sed 's/./\L&/g' )

    if [[ ! ${check} =~ "not installed" ]]; then

        OCC_BIN="${NC_D_BASE_PATH:-${NC_BASE_PATH:-/var/www/html}}/occ"
        NC_USER_RUN="${NC_D_USER:-${NC_USER:-www-data}}"

        sudo -u "${NC_USER_RUN}" php -d memory_limit=-1 "${OCC_BIN}" upgrade
        sudo -u "${NC_USER_RUN}" php -d memory_limit=-1 "${OCC_BIN}" db:add-missing-indices
        sudo -u "${NC_USER_RUN}" php -d memory_limit=-1 "${OCC_BIN}" maintenance:update:htaccess

        # Read NC_D_APPS into an array (one item per line/word), trimming empties
        mapfile -t APPS < <(printf '%s' "${NC_D_APPS:-${NC_APPS}}" | tr -d '\r' | tr -s '[:space:]' '\n' | sed '/^$/d')

        for app in "${APPS[@]}"; do
            sudo -u "${NC_USER_RUN}" php -d memory_limit=-1 "${OCC_BIN}" app:remove  "$app" || true
            sudo -u "${NC_USER_RUN}" php -d memory_limit=-1 "${OCC_BIN}" app:install "$app" || true
            sudo -u "${NC_USER_RUN}" php -d memory_limit=-1 "${OCC_BIN}" app:enable  "$app"
        done

        rm -rf /var/www/html/data/appdata_*/css/* /var/www/html/data/appdata_*/js/* 
        sudo -u "${NC_USER_RUN}" php -d memory_limit=-1 "${OCC_BIN}" maintenance:repair

        touch "${check_file}"
    fi
fi
