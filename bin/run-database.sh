#!/bin/bash
set -o errexit

SSL_DIR=/ssl

with_retry () {
  # When RabbitMQ is just booting up, it might be impossible to e.g. create a
  # new user because no worker is available to service our request (the error
  # looks like `noproc,{gen_server2,call ...}`). Even if we wait until RabbitMQ
  # appears to be online (i.e. it shows in rabbitmqctl's status output), we can
  # stil run into an error while adding the user. So, we just retry a lot!
  local n=30
  local d=2

  for _ in $(seq 1 "$n"); do
    if "$@"; then
      return 0
    fi

    echo "Errored (may retry in ${d}): ${*}"
    sleep "$d"
  done

  echo "Failed permanently after ${n} attempts: ${*}"
  return 1
}

delete_user_if_exists () {
  local user="$1"

  if rabbitmqctl delete_user "$user"; then
    # Deletion succeeded. We're done here.
    return 0
  else
    # Deletion failed. Check that we can successfully list users, and if so
    # then check that the user we meant to delete is absent from the list.
    local userList
    userList="$(rabbitmqctl list_users)"
    if ! echo "$userList" | grep -E "^$user"; then
      echo "user $user was already deleted"
      return 0
    fi
  fi

  return 1
}

add_user_if_not_exists () {
  # See above for the logic here
  local user="$1"
  local pass="$2"

  if rabbitmqctl add_user "$user" "$pass"; then
    return 0
  else
    local userList
    userList="$(rabbitmqctl list_users)"
    if echo "$userList" | grep -E "^$user"; then
      echo "user $user was already added"
      return 0
    fi
  fi

  return 1
}

add_vhost_if_not_exists () {
  # See above for the logic here
  local vhost="$1"

  if rabbitmqctl add_vhost "$vhost"; then
    return 0
  else
    local vhostList
    vhostList="$(rabbitmqctl list_vhosts)"
    if echo "$vhostList" | grep -E "^$vhost"; then
      echo "vhost $vhost was already added"
      return 0
    fi
  fi

  return 1
}

bootstrap_configuration () {
  local bindHost="$1";

  local baseConfig
  baseConfig="$(mktemp)"

  # shellcheck disable=SC2002
  cat "/etc/rabbitmq.config.template" \
    | sed "s:__SSL_DIR__:${SSL_DIR}:g" \
    | sed "s:__BIND_HOST__:${bindHost}:g"\
    > "${baseConfig}"

  # RabbitMQ wants us to have a .config at the end of the filename.
  mv "$baseConfig" "${baseConfig}.config"

  export RABBITMQ_CONFIG_FILE="$baseConfig"
}

if [[ "$1" == "--initialize" ]]; then
    /usr/bin/initialize-certs
    bootstrap_configuration "127.0.0.1"

    rabbitmq-server &
    rmq_pid="$!"

    with_retry add_user_if_not_exists "$USERNAME" "$PASSPHRASE"
    with_retry add_vhost_if_not_exists "$DATABASE"
    with_retry delete_user_if_exists "guest"

    with_retry rabbitmqctl set_permissions -p "$DATABASE" "$USERNAME" ".*" ".*" ".*"
    with_retry rabbitmqctl set_user_tags "$USERNAME" "administrator"

    echo "Waiting for RabbitMQ to exit..."
    pkill -TERM -P "$rmq_pid"
    wait "$rmq_pid" || true
elif [[ "$1" == "--discover" ]]; then
  cat <<EOM
{
  "version": "1.0",
  "environment": {
    "USERNAME": "aptible",
    "DATABASE": "db",
    "PASSPHRASE": "$(pwgen -s 32)"
  }
}
EOM
elif [[ "$1" == "--connection-url" ]]; then
  cat <<EOM
{
  "version": "1.0",
  "credentials": [
    {
        "type": "amqps",
        "default": true,
        "connection_url": "amqps://${USERNAME}:${PASSPHRASE}@${EXPOSE_HOST}:${EXPOSE_PORT_5671}/${DATABASE}"
    },
    {
        "type": "management",
        "default": false,
        "connection_url": "https://${USERNAME}:${PASSPHRASE}@${EXPOSE_HOST}:${EXPOSE_PORT_15671}"
    },
    {
        "type": "management-api",
        "default": false,
        "connection_url": "https://${USERNAME}:${PASSPHRASE}@${EXPOSE_HOST}:${EXPOSE_PORT_15671}/api/vhosts/${DATABASE}"
    }
  ]
}
EOM
elif [[ "$1" == "--client" ]]; then
    echo "This image does not support the --client option. Use rabbitmqadmin instead." && exit 1
else
    bootstrap_configuration "0.0.0.0"
    /usr/bin/initialize-certs
    echo "Launching RabbitMQ..."
    exec rabbitmq-server
fi
