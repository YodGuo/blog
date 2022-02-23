#!/bin/bash
## set time zone
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

## configuration file path
CONF_FILE='/root/.halo/application.yaml'

## Download configuration file
echo "Using '${HALO_DATABASE}'. Downloading configuration file..."
if [[ ${HALO_DATABASE} && X${HALO_DATABASE} == XMYSQL ]]; then
    curl -L https://dl.halo.run/config/application-template-mysql.yaml --output ${CONF_FILE}
elif [[ ${HALO_DATABASE} && X${HALO_DATABASE} == XH2 ]]; then
    curl -L https://dl.halo.run/config/application-template-h2.yaml --output ${CONF_FILE}
else
    echo "Unknown database type, Exit!"
    exit 1
fi
unset HALO_DATABASE

## Initialize the configuration file
if env | grep -q '^HALO_.\+=.\+'; then
    # Ignore variables with '-'.
    for VAR_NAME in $(env | grep '^HALO_.\+=.\+' | sed -r "s/^HALO_([^=]*).*/\1/g"); do
        if echo ${VAR_NAME} | grep -q '.*\-.*'; then
            echo "\"HALO_${VAR_NAME}\" in Environment variable contains '-',this will be ignored."
            continue
        fi

        IFS_OLD=$IFS
        IFS='_'

        VAR_NAME_ARR=(${VAR_NAME})
        CONF_ITEM_LEVEL=${#VAR_NAME_ARR[@]}

        IFS=$IFS_OLD

        CONF_CONTENT=$(eval echo \${HALO_${VAR_NAME}} | sed -r 's@([\/|\&|\$|\[|\]|\*|\.|\^])@\\\1@g')

        if [[ ${CONF_ITEM_LEVEL} -eq 2  ]]; then
            CONF_ITEM_LEVEL_1=$(sed -n -r "s/(${VAR_NAME_ARR[0]//_/-}|${VAR_NAME_ARR[0]}):.*/\1/Ip" ${CONF_FILE})
            CONF_ITEM_LEVEL_2=$(sed -n -r "/${CONF_ITEM_LEVEL_1}:$/I,/^[^ ]/{s/ *(${VAR_NAME_ARR[1]//_/-}|${VAR_NAME_ARR[1]}): *.*/\1/Ip}" ${CONF_FILE})
            sed -i -r "/${CONF_ITEM_LEVEL_1}:$/I,/^[^ ]/{s@(${CONF_ITEM_LEVEL_2}: *).*@\1${CONF_CONTENT}@I}" ${CONF_FILE}
        else
            CONF_ITEM_LEVEL_3_INIT=$(echo ${VAR_NAME} | awk -F '_' '{print substr($0, index($0, $3))}')
            CONF_ITEM_LEVEL_1=$(sed -n -r "s/(${VAR_NAME_ARR[0]//_/-}|${VAR_NAME_ARR[0]}):.*/\1/Ip" ${CONF_FILE})
            CONF_ITEM_LEVEL_2=$(sed -n -r "/${CONF_ITEM_LEVEL_1}:$/I,/^[^ ]/{s/ *(${VAR_NAME_ARR[1]//_/-}|${VAR_NAME_ARR[1]}): *.*/\1/Ip}" ${CONF_FILE})
            CONF_ITEM_LEVEL_3=$(sed -n -r "/${CONF_ITEM_LEVEL_1}:$/I,/^[^ ]/{/${CONF_ITEM_LEVEL_2}:$/I,/^[  ].*\:$/{s/ *(${CONF_ITEM_LEVEL_3_INIT//_/-}|${CONF_ITEM_LEVEL_3_INIT}): *.*/\1/Ip}}" ${CONF_FILE})
            sed -i -r "/${CONF_ITEM_LEVEL_1}:$/I,/^[^ ]/{/${CONF_ITEM_LEVEL_2}:$/I,/^[  ].*\:$/{s@(${CONF_ITEM_LEVEL_3}: *).*@\1${CONF_CONTENT}@I}}" ${CONF_FILE}
        fi

        echo "Config overridden from Environment variable, ${VAR_NAME}=${CONF_CONTENT}."
    done
fi

## starting program
exec \
    java -Xms${JVM_XMS} -Xmx${JVM_XMX} ${JVM_OPTS} \
    -Djava.security.egd=file:/dev/./urandom org.springframework.boot.loader.JarLauncher