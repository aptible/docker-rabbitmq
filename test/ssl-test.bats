#!/usr/bin/env bats

source "${BATS_TEST_DIRNAME}/test_helpers.sh"

local_s_client() {
  openssl s_client -connect localhost:5671 "$@" < /dev/null
  openssl s_client -connect localhost:15671 "$@" < /dev/null
}

@test "It should allow connections" {
  start_rabbitmq

  local_s_client
}

@test "It should allow connections using either TLS 1.2 or TLS 1.3" {
  start_rabbitmq

  local_s_client -no_ssl3 -no_tls1 -no_tls1_1
}

@test "It should disallow connections using TLS1.1 or earlier" {
  start_rabbitmq

  ! local_s_client -no_tls1_3 -no_tls1_2
}

@test "It should disallow connections using SSLv3" {
  start_rabbitmq

  ! local_s_client -ssl3
}