#!/usr/bin/env bash

# The Initial Owner of the Original Code is European Environment Agency (EEA).
# All Rights Reserved. See
# https://github.com/eea/eea.docker.jenkins.slave#copyright-and-license
# Original file:
# https://github.com/eea/eea.docker.jenkins.slave/blob/master/docker-entrypoint.sh

PARAMS=""

# The Jenkins username for authentication
if [ ! -z "$JENKINS_USER" ]; then
  PARAMS="$PARAMS -username $JENKINS_USER"
fi

# The Jenkins user password
if [ ! -z "$JENKINS_PASS" ]; then
  PARAMS="$PARAMS -password $JENKINS_PASS"
fi

# The Jenkins user password environment variable;
if [ ! -z "$JENKINS_PASS_ENV" ]; then
  PARAMS="$PARAMS -passwordEnvVariable JENKINS_PASS_ENV"
fi

# Name of the slave
if [ ! -z "$JENKINS_NAME" ]; then
  IP=`python -c "import socket; print(socket.gethostbyname(socket.gethostname()))"`
  PARAMS="$PARAMS -name $JENKINS_NAME-$IP"
fi

# Description to be put on the slave
if [ ! -z "$JENKINS_DESCRIPTION" ]; then
  PARAMS="$PARAMS -description $JENKINS_DESCRIPTION"
fi

# Number of executors. Default is equal with the number of available CPUs
if [ ! -z "$JENKINS_EXECUTORS" ]; then
  PARAMS="$PARAMS -executors $JENKINS_EXECUTORS"
fi

# Number of retries before giving up. Unlimited if not specified.
if [ ! -z "$JENKINS_RETRY" ]; then
  PARAMS="$PARAMS -retry $JENKINS_RETRY"
fi

# The mode controlling how Jenkins allocates jobs to
# slaves. Can be either 'normal' (utilize this slave
# as much as possible) or 'exclusive' (leave this
# machine for tied jobs only). Default is normal.
if [ ! -z "$JENKINS_MODE" ]; then
  PARAMS="$PARAMS -mode $JENKINS_MODE"
fi

# The complete target Jenkins URL like 'http://server:8080/jenkins/'.
# If this option is specified, auto-discovery will be skipped
if [ ! -z "$JENKINS_MASTER" ]; then
  PARAMS="$PARAMS -master $JENKINS_MASTER"
fi

# Connect to the specified host and port, instead of
# connecting directly to Jenkins. Useful when
# connection to Hudson needs to be tunneled. Can be
# also HOST: or :PORT, in which case the missing
# portion will be auto-configured like the default
# behavior
if [ ! -z "$JENKINS_TUNNEL" ]; then
  PARAMS="$PARAMS -tunnel $JENKINS_TUNNEL"
fi

# Whitespace-separated list of tool locations to be
# defined on this slave. A tool location is
# specified as 'toolName:location'
if [ ! -z "$JENKINS_TOOL_LOCATIONS" ]; then
  PARAMS="$PARAMS -toolLocations $JENKINS_TOOL_LOCATIONS"
fi

# Do not retry if a successful connection gets closed.
if [ ! -z "$JENKINS_NO_RETRY_AFTER_CONNECTED" ]; then
  PARAMS="$PARAMS -noRetryAfterConnected"
fi

#Use this address for udp-based auto-discovery (default 255.255.255.255)
if [ ! -z "$JENKINS_AUTO_DISCOVERY_ADDRESS" ]; then
  PARAMS="$PARAMS -autoDiscoveryAddress $JENKINS_AUTO_DISCOVERY_ADDRESS"
fi

# Disables SSL verification in the HttpClient.
if [ ! -z "$JENKINS_DISABLE_SSL_VERIFICATION" ]; then
  PARAMS="$PARAMS -disableSslVerification"
fi

# Disables SSL verification in the HttpClient.
if [ ! -z "$JENKINS_SSL_FINGERPRINTS" ]; then
  PARAMS="$PARAMS -sslFingerprints $JENKINS_SSL_FINGERPRINTS"
else
  PARAMS="$PARAMS -sslFingerprints ''"
fi

# Jenkins options
if [ ! -z "$JENKINS_OPTS" ]; then
  PARAMS="$PARAMS $JENKINS_OPTS"
fi


echo "Fixing permissions"
chown -v jenkins:jenkins /var/jenkins_home/worker/

if [ "$1" = "java" ]; then
  exec java $JAVA_OPTS -jar /bin/swarm-client.jar -fsroot /var/jenkins_home/worker/ -labels "$JENKINS_LABELS" $PARAMS
fi

if [[ "$1" == "-"* ]]; then
  exec java $JAVA_OPTS -jar /bin/swarm-client.jar -fsroot /var/jenkins_home/worker/ -labels "$JENKINS_LABELS" $PARAMS "$@"
fi

exec "$@"
