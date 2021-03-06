#!/bin/bash


if [ -n "${RELATIVE_URL}" ]; then
if [ ! -d /opt/TeamCity/webapps${RELATIVE_URL} ]; then
echo "Changing context for relative URL ${RELATIVE_URL}"
mkdir -p /opt/TeamCity/webapps/${RELATIVE_URL}
rmdir /opt/TeamCity/webapps/${RELATIVE_URL}
mv /opt/TeamCity/webapps/ROOT /opt/TeamCity/webapps/${RELATIVE_URL}
fi
export TEAMCITY_APP_DIR=/opt/TeamCity/webapps/${RELATIVE_URL}
fi

echo "Datapath directory ${TEAMCITY_DATA_PATH}"

# Copy JDBC driver
mkdir -p ${TEAMCITY_DATA_PATH}/lib/jdbc
chmod 750 -R ${TEAMCITY_DATA_PATH}
cp ${JDBC_DEST}/${JDBC_PACKAGE} ${TEAMCITY_DATA_PATH}/lib/jdbc
chmod 550 ${JDBC_DEST}/${JDBC_PACKAGE} ${TEAMCITY_DATA_PATH}/lib/jdbc
chown -R ci:ci ${TEAMCITY_DATA_PATH}

TEAMCITY_SERVER_MEM_OPTS="-Xmx1024m -XX:MaxPermSize=270m"
export TEAMCITY_SERVER_MEM_OPTS

export TEAMCITY_DATA_PATH
sleep ${TEAMCITY_SERVER_DELAYED_START}
sudo -u ci sh -c 'export "${1}"; /opt/TeamCity/bin/teamcity-server.sh run' _ "TEAMCITY_DATA_PATH=${TEAMCITY_DATA_PATH}"
