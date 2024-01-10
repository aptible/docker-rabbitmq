#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/test_helpers.sh"

@test "RabbitMQ should use working/supported erlang version." {

  if [ "$TAG" = "3.5" ]; then
    apk info erlang | grep "erlang-19.1"
  elif [ "$TAG" = "3.7" ]; then
    apk info erlang | grep "erlang-20.3"
  elif [ "$TAG" = "3.11" ]; then
    apk info erlang | grep "erlang-26.2.1"
  elif [ "$TAG" = "3.12" ]; then
    apk info erlang | grep "erlang-26.2.1"
  fi
}

@test "It should bring up a working RabbitMQ instance" {
  # According to rabbitmqadmin
  start_rabbitmq
  rabbit_client list queues vhost name

  # Bunny caught errors pertaining to invalid/unsupported erlang
  # version, which simply testing with rabbitmqadmin did not.
  gem install bunny || echo ok
  gem list bunny | grep bunny

  ruby /tmp/test/bunny.rb
}

@test "It should be able to declare an exchange" {
    start_rabbitmq
    rabbit_client declare exchange name=my-new-exchange type=fanout
}

@test "It should be able to declare a queue" {
    start_rabbitmq
    rabbit_client declare queue name=my-new-queue durable=false
}

@test "It should be able to publish and retrieve a message" {
    start_rabbitmq

    rabbit_client declare exchange name=my-new-exchange type=fanout
    rabbit_client declare queue name=my-new-queue durable=false
    rabbit_client declare binding source="my-new-exchange" destination_type=queue destination="my-new-queue"

    rabbit_client publish exchange=my-new-exchange routing_key=my-new-queue payload="hello, world"
    rabbit_client get queue=my-new-queue | grep -q "hello, world"
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

@test "It generates valid JSON for --discover" {
  wrapper --discover | python3 -c 'import sys, json; json.load(sys.stdin)'
}

@test "It generates valid JSON for --connection-url" {
  USERNAME="foo" \
  PASSPHRASE="bar" \
  EXPOSE_HOST="qux.com" \
  EXPOSE_PORT_5671=123 \
  EXPOSE_PORT_15671=456 \
  DATABASE=db \
    wrapper --connection-url | python3 -c 'import sys, json; json.load(sys.stdin)'
}

@test "It should delete the guest user and create a user" {
    start_rabbitmq
    ! rabbit_client list users | grep -q guest
    rabbit_client list users | grep -q user
}

@test "It should have our default plugins enabled." {
  start_rabbitmq
  rabbitmq-plugins list rabbitmq_management | grep -F '[E*]'
  rabbitmq-plugins list rabbitmq_management_agent | grep -F '[e*]'
  rabbitmq-plugins list rabbitmq_shovel | grep -F '[E*]'
  rabbitmq-plugins list rabbitmq_shovel_management | grep -F '[E*]'
  rabbitmq-plugins list rabbitmq_web_dispatch | grep -F '[e*]'
  rabbitmq-plugins list rabbitmq_delayed_message_exchange | grep -F '[E*]'
}

@test "It should allow enabling plugins." {
  start_rabbitmq
  rabbitmq-plugins enable rabbitmq_consistent_hash_exchange --online
  rabbitmq-plugins list rabbitmq_consistent_hash_exchange | grep -F '[E*]'
}

@test "It should set the disk free space limit based upon the container size" {
    APTIBLE_CONTAINER_SIZE=2048 start_rabbitmq &> /tmp/rabbit.log
    grep "Disk free limit set to 2048MB" /tmp/rabbit.log
}
