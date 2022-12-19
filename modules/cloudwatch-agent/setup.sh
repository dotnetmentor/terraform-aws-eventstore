export CLOUDWATCH_AGENT_ENABLED='${enabled}'

install-cloudwatch-agent() {
  if [[ "$${CLOUDWATCH_AGENT_ENABLED:?}" == 'true' ]]; then
    echo
    echo 'Installing AWS Cloudwatch Agent'
    wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
    sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

    echo 'Configuring AWS Cloudwatch Agent'
    echo '${config_json}' >"/opt/aws/amazon-cloudwatch-agent/bin/config.json"

    echo
    echo 'Starting AWS Cloudwatch Agent'
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
    systemctl status amazon-cloudwatch-agent
  else
    echo
    echo "Skipping install (CLOUDWATCH_AGENT_ENABLED=$${CLOUDWATCH_AGENT_ENABLED:?})"
  fi
}

install-cloudwatch-agent
