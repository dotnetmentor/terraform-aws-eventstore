#!/bin/bash
set -e

export DATA_MOUNT_PATHS=('/dev/xvdb' '/dev/xvdc')
export DATA_POOL_NAME='ebs'
export DATA_DIR="/$${DATA_POOL_NAME:?}/data"
export DEBIAN_FRONTEND='noninteractive'
export ES_VERSION='${cluster_version}'
export ES_INSTALL_URL="https://packagecloud.io/install/repositories/EventStore/EventStore-OSS/script.deb.sh"
export ES_DB_PATH="$${DATA_DIR:?}/eventstore/data"
export ES_LOG_PATH="$${DATA_DIR:?}/eventstore/log"
export LOG_FORWARDING_ENABLED='${log_forwarding_elasticsearch_enabled}'

echo
echo 'Ensuring apt-get is updated (at least once)'
apt-get update

echo
echo 'Adding hostname to hosts'
echo "127.0.0.1 $(hostname)" >> /etc/hosts
cat /etc/hosts

echo
echo 'Ensure journald is setup'
mkdir -p /var/log/journal
systemd-tmpfiles --create --prefix /var/log/journal
systemctl restart systemd-journald

echo
echo 'Ensuring chronyd is setup (NTP)'
apt-get -y install chrony
cp /etc/chrony/chrony.conf /etc/chrony/orig_chrony.conf
echo "# chrony configured with Amazon Time Sync Service
server 169.254.169.123 prefer iburst
pool 2.debian.pool.ntp.org offline iburst
keyfile /etc/chrony/chrony.keys
commandkey 1
driftfile /var/lib/chrony/chrony.drift
log tracking measurements statistics
logdir /var/log/chrony
maxupdateskew 100.0
dumponexit
dumpdir /var/lib/chrony
logchange 0.5
hwclockfile /etc/adjtime
rtcsync
" > /etc/chrony/chrony.conf
service chrony restart
service chrony status

if [[ "$${LOG_FORWARDING_ENABLED}" == "true" ]]; then
  echo
  echo 'Installing fluentbit'
  wget -qO - https://packages.fluentbit.io/fluentbit.key | apt-key add -
  echo "
  ## fluentbit
  deb https://packages.fluentbit.io/ubuntu/xenial xenial main" >> /etc/apt/sources.list
  apt-get update
  apt-get install td-agent-bit

  echo
  echo 'Configure fluentbit'
  echo "[SERVICE]
    Flush         1
    Log_Level     info
    Daemon        Off
    HTTP_Server   Off
    Parsers_File parsers.conf
    Plugins_File plugins.conf

[INPUT]
    Name            systemd
    Path            /var/log/journal/
    Read_From_Tail  True
    Tag             eventstore-host-${environment}
    Mem_Buf_Limit   20MB

[OUTPUT]
    Name            es
    Match           *
    Host            ${log_forwarding_elasticsearch_endpoint}
    Port            ${log_forwarding_elasticsearch_port}
    tls             On
    tls.verify      Off
    Logstash_Format On
    Logstash_Prefix logstash-${environment}
    Time_Key        time
    Retry_Limit     False
    Include_Tag_Key True
    Tag_Key         FLB_KEY
" > /etc/td-agent-bit/td-agent-bit.conf

  echo
  echo 'Starting fluentbit'
  service td-agent-bit restart
  service td-agent-bit status
fi

echo
echo 'Installing Eventstore'
apt-get install tzdata curl iproute2 -y
curl -s "$${ES_INSTALL_URL}" | bash
apt-get install eventstore-oss="$${ES_VERSION}" -y

echo
echo 'Installing ZFS'
apt-get install zfsutils-linux -y

echo
echo 'Preparing mirrored ZFS pool'
zpool create -f "$${DATA_POOL_NAME:?}" mirror "$${DATA_MOUNT_PATHS[0]}" "$${DATA_MOUNT_PATHS[1]}"
sleep 3
zpool status
mkdir -p "$${DATA_DIR:?}"

echo
echo 'Preparing eventstore directories'
mkdir -p $${ES_DB_PATH}
mkdir -p $${ES_LOG_PATH}
sudo chown -R eventstore:eventstore $${ES_DB_PATH}
sudo chown -R eventstore:eventstore $${ES_LOG_PATH}

echo
echo 'Performing cleanup'
apt-get autoremove
apt-get clean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* || true

echo
echo 'Configuring eventstore'
cat <<EOFCONF > "/etc/eventstore/eventstore.conf"
---
RunProjections: None
StartStandardProjections: True
Db: $${ES_DB_PATH}
Log: $${ES_LOG_PATH}
ClusterSize: ${cluster_size}
ClusterGossipPort: 2112
ClusterDns: ${cluster_dns}
ExtIp: $$(ec2metadata --local-ipv4)
IntIp: $$(ec2metadata --local-ipv4)
ExtIpAdvertiseAs: $$(ec2metadata --${external_ip_type}-ipv4)
IntIpAdvertiseAs: $$(ec2metadata --${internal_ip_type}-ipv4)
IntHttpPrefixes: http://*:2112/
ExtHttpPrefixes: http://*:2113/
AddInterfacePrefixes: false
EOFCONF

echo
echo 'Starting eventstore'
systemctl start eventstore
systemctl status eventstore
