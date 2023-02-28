#!/bin/bash

if [[ ! -z ${DSPACE_ADMIN_EMAIL_FILE} && -f ${DSPACE_ADMIN_EMAIL_FILE} ]]
then
  DSPACE_ADMIN_EMAIL=`cat ${DSPACE_ADMIN_EMAIL_FILE}`
fi

if [[ ! -z ${DSPACE_ADMIN_PASSWORD_FILE} && -f ${DSPACE_ADMIN_PASSWORD_FILE} ]]
then
  DSPACE_ADMIN_PASSWORD=`cat ${DSPACE_ADMIN_PASSWORD_FILE}`
fi

if [[ ! -z ${DSPACE_ADMIN_FIRSTNAME_FILE} && -f ${DSPACE_ADMIN_FIRSTNAME_FILE} ]]
then
  DSPACE_ADMIN_FIRSTNAME=`cat ${DSPACE_ADMIN_FIRSTNAME_FILE}`
fi

if [[ ! -z ${DSPACE_ADMIN_LASTNAME_FILE} && -f ${DSPACE_ADMIN_LASTNAME_FILE} ]]
then
  DSPACE_ADMIN_LASTNAME=`cat ${DSPACE_ADMIN_LASTNAME_FILE}`
fi

CONFIG_PATH=/dspace/config
CFG_NAMES=($(compgen -A variable | grep '^DSPACE_CFG_'))

if [ -d ${CONFIG_PATH} ]
then
  CFG_FILE_PATH=${CONFIG_PATH}/local.cfg

  if [[ ${#CFG_NAMES[@]} > 0 ]]
  then
    echo "Creating local config for backend..."

    touch ${CFG_FILE_PATH}
    cat /dev/null > ${CFG_FILE_PATH}

    for VAR in "${CFG_NAMES[@]}"
    do
      if [[ ${VAR} == *_FILE ]]
      then
        CFG_NAME=`echo ${VAR:11:-5} | sed s/__/-/g | sed s/_/./g`
        CFG_VALUE_FILE=`echo ${!VAR} | sed s/^[\'\"]//g | sed s/[\'\"]$//g`
        CFG_VALUE=`cat ${CFG_VALUE_FILE}`
      else
        CFG_NAME=`echo ${VAR:11} | sed s/__/-/g | sed s/_/./g`
        CFG_VALUE=`echo ${!VAR} | sed s/^[\'\"]//g | sed s/[\'\"]$//g`
      fi
      
      echo ${CFG_NAME} = ${CFG_VALUE} >> ${CFG_FILE_PATH}
    done
  fi
fi

until [ `/dspace/bin/dspace database test 2>/dev/null | grep "Connected successfully" | wc -l` -gt 0 ]
do
  echo "Database not yet ready. Waiting for 3 seconds..."
  sleep 3
done

INIT_DATA=N
if [ `/dspace/bin/dspace database status | grep -e Versioned.*Pending | wc -l` -gt 0 ]
then
  INIT_DATA=Y
fi

if [[ ${INIT_DATA} == "Y" ]]
then
  echo "Database is empty. Migrating database..."
  /dspace/bin/dspace database migrate
fi

if [[ ! -z ${DSPACE_ENTITY_MODELS_FILE} && -f ${DSPACE_ENTITY_MODELS_FILE} ]]
then
  echo "Initializing entities..."
  /dspace/bin/dspace initialize-entities -f ${DSPACE_ENTITY_MODELS_FILE}
fi

if [[ ! -z ${DSPACE_ADMIN_EMAIL} && ! -z ${DSPACE_ADMIN_PASSWORD} ]]
then
  if [ `/dspace/bin/dspace user -L | cut -f2 | grep -e '${DSPACE_ADMIN_EMAIL}/.*' | wc -l` -gt 0 ]
  then
    echo "Administrator ${DSPACE_ADMIN_EMAIL} already exists. Skipped create initial administrator account."
  else
    echo "Creating initial administrator ${DSPACE_ADMIN_EMAIL}..."
    /dspace/bin/dspace create-administrator -e ${DSPACE_ADMIN_EMAIL} -f ${DSPACE_ADMIN_FIRSTNAME:-N/A} -l ${DSPACE_ADMIN_LASTNAME:-N/A} -p "${DSPACE_ADMIN_PASSWORD}"
  fi
fi

if [[ ${INIT_DATA} == "Y" ]]
then
  if [[ ! -z ${DSPACE_ADMIN_EMAIL} && ! -z ${DSPACE_INIT_STUCTURE_FILE} && -f ${DSPACE_INIT_STUCTURE_FILE} ]]
  then
    echo "Initializing collection structure..."

    IMPORT_OUTPUT=${DSPACE_INIT_STUCTURE_FILE}_output
    /dspace/bin/dspace structure-builder -f ${DSPACE_INIT_STUCTURE_FILE} -o ${IMPORT_OUTPUT} -e ${DSPACE_ADMIN_EMAIL}
    cat ${IMPORT_OUTPUT}
    rm ${IMPORT_OUTPUT}
  fi
fi

echo "Starting DSpace backend..."
catalina.sh run
