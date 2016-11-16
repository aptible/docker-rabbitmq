#!/bin/bash
set -o errexit

wait_for_rabbitmq() {
  for _ in $(seq 1 25); do
    if rabbitmqctl -q status 2>/dev/null | grep -q 'rabbit'; then
      return 0
    fi

    echo "Waiting for RabbitMQ to come up..."
    sleep 1
  done

  echo "RabbitMQ admin did not come online!"
  return 1
}

if [[ "$1" == "--initialize" ]]; then
    /usr/bin/initialize-certs

    rabbitmq-server &
    rmq_pid="$!"

    # NOTE: We'd love to use `rabbitmqctl wait` here, but it does not actually
    # work.
    wait_for_rabbitmq

    rabbitmqctl add_user "$USERNAME" "$PASSPHRASE"

    # The vhost is equivalent to the "db" in our case
    rabbitmqctl add_vhost "$DATABASE"

    rabbitmqctl set_permissions -p "$DATABASE" "$USERNAME" ".*" ".*" ".*"
    rabbitmqctl set_user_tags "$USERNAME" administrator

    rabbitmqctl delete_user guest

    echo "Waiting for RabbitMQ to exit..."
    pkill -TERM -P "$rmq_pid"
    wait "$rmq_pid" || true
elif [[ "$1" == "--discover" ]]; then
  cat <<EOM
{
  "configuration": {
    "USERNAME": "aptible",
    "DATABASE": "db",
    "PASSPHRASE": "$(pwgen -s 32)"
  }
}
EOM
elif [[ "$1" == "--connection-url" ]]; then
  cat <<EOM
{
  "urls": [
    {
        "type": "amqps",
        "default": true,
        "internal_port": 5671,
        "url": "amqps://${USERNAME}:${PASSPHRASE}@${EXPOSE_HOST}:${EXPOSE_PORT_5671}/${DATABASE}"
    },
    {
        "type": "management",
        "default": false,
        "internal_port": 15671,
        "url": "https://${USERNAME}:${PASSPHRASE}@${EXPOSE_HOST}:${EXPOSE_PORT_15671}/${DATABASE}"
    }
  ]
}
EOM
elif [[ "$1" == "--client" ]]; then
    echo "This image does not support the --client option. Use rabbitmqadmin instead." && exit 1
else
    /usr/bin/initialize-certs
    echo "Launching RabbitMQ..."
    exec rabbitmq-server
fi
