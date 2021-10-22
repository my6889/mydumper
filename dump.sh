#!/bin/bash
set -e

DB_USER=${DB_USER:-${MYSQL_ENV_DB_USER}}
DB_PASS=${DB_PASS:-${MYSQL_ENV_DB_PASS}}
DB_NAME=${DB_NAME:-${MYSQL_ENV_DB_NAME}}
DB_HOST=${DB_HOST:-${MYSQL_ENV_DB_HOST}}
DB_PORT=${DB_PORT:-${MYSQL_ENV_DB_PORT}}
ALL_DATABASES=${ALL_DATABASES}
DESTINATION=${DESTINATION}

if [ "${DESTINATION}" = "S3" ]; then
  echo "DESTINATION SET TO S3!"
            #对象存储设置
            if [ "${ACCESS_KEY_ID}" = "" ]; then
              echo "[ERROR]: You need to set the ACCESS_KEY_ID environment variable."
              exit 1
            fi
            
            if [ "${SECRET_ACCESS_KEY}" = "" ]; then
              echo "[ERROR]: You need to set the SECRET_ACCESS_KEY environment variable."
              exit 1
            fi
            
            if [ "${BUCKET}" = "" ]; then
              echo "[ERROR]: You need to set the BUCKET environment variable."
              exit 1
            fi
            
            if [ "${PREFIX}" = "" ]; then
              echo "[ERROR]: You need to set the PREFIX environment variable."
              exit 1
            fi
elif [ "${DESTINATION}" = "OSS" ]; then
  echo "DESTINATION SET TO OSS!"
              #对象存储设置
            if [ "${ACCESS_KEY_ID}" = "" ]; then
              echo "[ERROR]: You need to set the ACCESS_KEY_ID environment variable."
              exit 1
            fi
            
            if [ "${SECRET_ACCESS_KEY}" = "" ]; then
              echo "[ERROR]: You need to set the SECRET_ACCESS_KEY environment variable."
              exit 1
            fi
            
            if [ "${BUCKET}" = "" ]; then
              echo "[ERROR]: You need to set the BUCKET environment variable."
              exit 1
            fi
            
            if [ "${PREFIX}" = "" ]; then
              echo "[ERROR]: You need to set the PREFIX environment variable."
              exit 1
            fi
elif [ "${DESTINATION}" = "COS" ]; then
  echo "DESTINATION SET TO COS!"
              #对象存储设置
            if [ "${ACCESS_KEY_ID}" = "" ]; then
              echo "[ERROR]: You need to set the ACCESS_KEY_ID environment variable."
              exit 1
            fi
            
            if [ "${SECRET_ACCESS_KEY}" = "" ]; then
              echo "[ERROR]: You need to set the SECRET_ACCESS_KEY environment variable."
              exit 1
            fi
            
            if [ "${BUCKET}" = "" ]; then
              echo "[ERROR]: You need to set the BUCKET environment variable."
              exit 1
            fi
            
            if [ "${PREFIX}" = "" ]; then
              echo "[ERROR]: You need to set the PREFIX environment variable."
              exit 1
            fi
else 
  echo "[WARNING]: DESTINATION environment variable Not set or set to other value,Dump File will save at /mysqldump in container!"
fi

#DB设置
if [[ ${DB_USER} == "" ]]; then
        echo "[ERROR]: You need to set the DB_USER environment variable."
        exit 1
fi
if [[ ${DB_PASS} == "" ]]; then
        echo "[ERROR]: You need to set the DB_PASS environment variable."
        exit 1
fi
if [[ ${DB_HOST} == "" ]]; then
        echo "[ERROR]: You need to set the DB_HOST environment variable."
        exit 1
fi
if [[ ${DB_PORT} == "" ]]; then
        echo "[ERROR]: You need to set the DB_PORT environment variable."
        exit 1
fi

ds=`date +%Y%m%d_%H%M%S`


if [[ ${ALL_DATABASES} == "" ]]; then
        if [[ ${DB_NAME} == "" ]]; then
                echo "[ERROR]: You need to set the DB_NAME environment variable."
                exit 1
        elif  [[ ${TABLES_NAME} == "" ]]; then
                echo "Dumping database:${DB_NAME} ..."
                mydumper --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --port="${DB_PORT}" --database "${DB_NAME}" -c -o  /mysqldump/"${DB_NAME}".$ds
                echo "Dumping database:${DB_NAME} Completed!"
        else
                echo "Dumping table:${DB_NAME}- ${TABLES_NAME}..."
                mydumper --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --port="${DB_PORT}" --database "${DB_NAME}" -T ${TABLES_NAME} -c -o  /mysqldump/"${DB_NAME}-${TABLES_NAME}".$ds
                echo "Dumping table:${DB_NAME}- ${TABLES_NAME} Completed!"
        fi

elif [[ ${ALL_DATABASES} == "TRUE" ]]; then
       echo "Dumping ALL_DATABASES ..."
       mydumper --user="${DB_USER}" --password="${DB_PASS}" --host="${DB_HOST}" --port="${DB_PORT}"  -c -o /mysqldump/ALL_DATABASES.$ds/
       echo "Dumping ALL_DATABASES Completed!"
else
       echo "[ERROR]: 无效的ALL_DATABASES值！请设置为TRUE或置空！"
       exit 1
fi


if [ "${DESTINATION}" = "S3" ]; then
  if [ "${AWS_REGION}" = "" ]; then
    echo "[ERROR]: You need to set the AWS_REGION environment variable."
    exit 1
  else
      echo "rsync to AWS-S3..........."
      aws configure set aws_access_key_id ${ACCESS_KEY_ID}
      aws configure set aws_secret_access_key ${SECRET_ACCESS_KEY}
      aws configure set default.region ${AWS_REGION}
      aws s3 sync /mysqldump/ s3://$BUCKET/$PREFIX
      echo "rsync to AWS-S3 Completed!"
  fi
elif [ "${DESTINATION}" = "OSS" ]; then
   if [ "${OSS_ENDPOINT}" = "" ]; then
   echo "[ERROR]: You need to set the OSS_ENDPOINT environment variable."
    exit 1
   else
    ossutil64 config -e ${OSS_ENDPOINT} -i ${ACCESS_KEY_ID} -k ${SECRET_ACCESS_KEY} -L CH -c /root/.ossutilconfig
	echo "rsync to OSS..........."
	ossutil64 sync /mysqldump/  oss://${BUCKET}/${PREFIX}
	echo "rsync to OSS Completed!"
   fi
elif [ "${DESTINATION}" = "COS" ]; then
  if [ "${COS_REGION}" = "" ]; then 
    echo "[ERROR]: You need to set the COS_REGION environment variable."
    exit 1
  else
    coscmd config -a ${ACCESS_KEY_ID} -s ${SECRET_ACCESS_KEY} -b ${BUCKET} -r $COS_REGION
	echo "rsync to COS..........."
	coscmd upload -r /mysqldump/ ${PREFIX}
	echo "rsync to COS Completed!"
  fi
else
  echo "Dump Mission Completed!"
  echo "[WARNING]: If you don't mount volumes this time,Please mount an outside directory or volume to /mysqldump and run once again!"
  echo "[INFO]: Dump Files are saved at /mysqldump in container!"
fi
