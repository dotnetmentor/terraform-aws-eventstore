install-scavenging-crontab () {
  apt-get update
  apt-get -y install grepcidr

  local crondir="/etc/cron.d"
  local crontab="$${crondir:?}/eventstore-scavenging-cron"

  local cidr_blocks
  local cron_schedules
  local ip
  local index

  cidr_blocks=(${cidr_blocks})
  cron_schedules=(${cron_schedules})
  ip="$(ec2metadata --local-ipv4)"
  index=0

  for cidr_block in $${cidr_blocks[*]}; do
    if grepcidr "$${cidr_block:?}" <(echo "$${ip:?}") >/dev/null; then
      cron_schedule="$${cron_schedules[index]}"
      echo "$${ip:?} is in range of $${cidr_block:?}"
      echo "using cron schedule $${cron_schedule:?}"
    fi
    index=$$((index++))
  done

  if [[ "$${cron_schedule}" != "" ]]; then
    echo "Adding scavenging crontab ($${crontab:?})"
    mkdir -p "$${crondir:?}" &> /dev/null

    echo "SHELL=/bin/bash
$${cron_schedule:?} root curl -i -d {} -X POST http://localhost:2113/admin/scavenge -u '${admin_username}:${admin_password}' 2>&1 | /usr/bin/logger -t eventstore-scavenging-cron
" > $${crontab:?}
  fi
}

install-scavenging-crontab
