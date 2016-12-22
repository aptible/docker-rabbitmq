#!/usr/bin/env bats
wait_for_rabbitmq() {
  for _ in $(seq 1 60); do
    if rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf list queues >/dev/null 2>&1; then
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
    if epmd -kill 2>&1 | grep -qi "killed"; then
      return 0
    fi
    sleep 1
  done

  echo "epmd did not exit!"
  return 1
}

initialize_rabbitmq() {
  echo "test: initialize_rabbitmq..."
  USERNAME=user PASSPHRASE=pass DATABASE=db /usr/bin/wrapper --initialize
}

run_rabbitmq() {
  echo "test: run_rabbitmq..."
  wrapper &
  export SCRIPT_PID=$!
  wait_for_rabbitmq
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

@test "It should bring up a working RabbitMQ instance" {
    initialize_rabbitmq
    run_rabbitmq
    run rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf list queues vhost name
    [ "$status" -eq "0" ]
}

@test "It should be able to declare an exchange" {
    initialize_rabbitmq
    run_rabbitmq
    run rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf declare exchange name=my-new-exchange type=fanout
    [ "$status" -eq "0" ]
}

@test "It should be able to declare a queue" {
    initialize_rabbitmq
    run_rabbitmq
    run rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf declare queue name=my-new-queue durable=false
    [ "$status" -eq "0" ]
}

@test "It should be able to publish and retrieve a message" {
    initialize_rabbitmq
    run_rabbitmq
    run rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf declare exchange name=my-new-exchange type=fanout
    [ "$status" -eq "0" ]
    run rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf declare queue name=my-new-queue durable=false
    [ "$status" -eq "0" ]
    run rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf publish exchange=my-new-exchange routing_key=my-new-queue payload="hello, world"
    [ "$status" -eq "0" ]
    run rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf get queue=my-new-queue requeue=false
    [ "$status" -eq "0" ]
}

@test "It should auto-generate certs when none are provided" {
    name="$(hostname)"
    initialize_rabbitmq | grep "Generating certificate with name $name"
    run_rabbitmq
    curl -kv https://localhost:5671 2>&1 | grep $name
}

@test "It should use certificates from the environment" {
    /usr/bin/initialize-certs bats-test | grep "Generating certificate with name bats-test"
    export SSL_CERTIFICATE="$(cat "/var/db/server/cert.pem")"
    export SSL_KEY="$(cat "/var/db/server/key.pem")"
    rm -rf /var/db/testca
    rm -rf /var/db/server
    initialize_rabbitmq | grep "Taking certificate from environment"
    run_rabbitmq
    curl -kv https://localhost:5671 2>&1 | grep bats-test
}

@test "It should use certificates from the filesystem" {
    /usr/bin/initialize-certs bats-test | grep "Generating certificate with name bats-test"
    initialize_rabbitmq | grep "Certs present on filesystem - using them"
    run_rabbitmq
    curl -kv https://localhost:5671 2>&1 | grep bats-test
}

@test "It should prefer certificates from the environment" {
  /usr/bin/initialize-certs test-old
  OLD_SSL_CERTIFICATE="$(cat "/var/db/server/cert.pem")"
  OLD_SSL_KEY="$(cat "/var/db/server/key.pem")"
  rm -rf /var/db/testca
  rm -rf /var/db/server

  /usr/bin/initialize-certs test-new
  NEW_SSL_CERTIFICATE="$(cat "/var/db/server/cert.pem")"
  NEW_SSL_KEY="$(cat "/var/db/server/key.pem")"
  rm -rf /var/db/testca
  rm -rf /var/db/server

  SSL_CERTIFICATE="$OLD_SSL_CERTIFICATE" SSL_KEY="$OLD_SSL_KEY" \
    initialize_rabbitmq

  SSL_CERTIFICATE="$NEW_SSL_CERTIFICATE" SSL_KEY="$NEW_SSL_KEY" \
    run_rabbitmq

  curl -kv https://localhost:5671 2>&1 | grep test-new
}
