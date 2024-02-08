#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/test_helpers.sh"

local_s_client() {
  openssl s_client -connect localhost:5671 "$@" < /dev/null
  openssl s_client -connect localhost:15671 "$@" < /dev/null
}

@test "It should allow connections using TLS 1.3" {
  start_rabbitmq

  local_s_client -tls1_3
}

@test "It should allow connections using TLS 1.2" {
  start_rabbitmq

  local_s_client -tls1_2
}

@test "It should not allow connections using TLS 1.1" {
  if [ !version_check ]; then
      skip "RabbitMQ version 3.9 and lower allows TLS 1.1"
  fi
  start_rabbitmq

  ! local_s_client -tls1_1
}

@test "It should not allow connections using TLS 1.0" {
  if [ !version_check ]; then
      skip "RabbitMQ version 3.9 and lower allows TLS 1.0"
  fi
  start_rabbitmq

  ! local_s_client -tls1
}

@test "It should not allow connections using SSLv3" {
  start_rabbitmq

  ! local_s_client -ssl3
}