#!/bin/bash

rabbit_client(){
  # Rabbitmqadmin 3.5 contains a patch to handle the self signed SSL, see here :
  # https://github.com/aptible/docker-rabbitmq/commit/0fb8a57a3206a15e340ad9a33b6f93ef18cb2f49
  # Rabbitmqadmin 3.7 has a flag that can handle this

  if [[ "$TAG" == "3.5" ]]; then
    rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf "$@"
  elif [[ "$TAG" == "3.7" ]]; then
    rabbitmqadmin --ssl-insecure -c /usr/local/bin/rabbitmqadmin.conf "$@"
  elif [[ "$TAG" == "3.9" ]]; then
    rabbitmqadmin --ssl-insecure -c /usr/local/bin/rabbitmqadmin.conf "$@"
  else
    # We should explicitly handle tags as above, but for new tags try to start rather than skip
    rabbitmqadmin --ssl-insecure -c /usr/local/bin/rabbitmqadmin.conf "$@"
  fi
}

wait_for_rabbitmq() {
  for _ in $(seq 1 60); do
    if rabbit_client list queues >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "RabbitMQ did not come online!"
  return 1
}

wait_until_epmd_exits() {
  # Force shutdown the Erlang application server, regardless of whether it was
  # started.
  for _ in $(seq 1 60); do
    if epmd -kill 2>&1 | grep -qiE "(killed|cannot connect)"; then
      return 0
    fi
    sleep 1
  done

  echo "epmd did not exit!"
  return 1
}

initialize_rabbitmq() {
  echo "test: initialize_rabbitmq..."
  USERNAME=testuser PASSPHRASE=pass DATABASE=db /usr/bin/wrapper --initialize
}

run_rabbitmq() {
  echo "test: run_rabbitmq..."
  wrapper &
  export SCRIPT_PID=$!
  wait_for_rabbitmq
}

start_rabbitmq(){
  initialize_rabbitmq
  run_rabbitmq
}

setup() {
  unset SCRIPT_PID

  export RABBITMQ_MNESIA_BASE=/tmp/datadir
  rm -rf "$RABBITMQ_MNESIA_BASE"
  mkdir -p "$RABBITMQ_MNESIA_BASE"
}

teardown() {
# If RabbitMQ was started, shut it down
  if [[ -n "$SCRIPT_PID" ]]; then
    pkill -TERM -P "$SCRIPT_PID"
    wait "$SCRIPT_PID"
  fi
  wait_until_epmd_exits

  rm -rf /var/db/testca
  rm -rf /var/db/server
}
