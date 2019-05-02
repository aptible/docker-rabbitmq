#!/bin/bash
set -o errexit
set -o nounset

IMG="$1"

DB_CONTAINER="rabbit"
DATA_CONTAINER="${DB_CONTAINER}-data"

INFO_LEVEL_LOGIN_MESSAGE="closing AMQP connection|accepting AMQP connection"

function cleanup {
  echo "Cleaning up"
  docker rm -f "$DB_CONTAINER" "$DATA_CONTAINER" &>/dev/null || true
}

function wait_for_db {
  for _ in $(seq 1 30); do
    if docker logs "$DB_CONTAINER" 2>&1 | grep -q "Server startup complete"; then
      sleep 1
      return 0
    fi
    sleep 1
  done

  echo "DB never came online"
  docker logs "$DB_CONTAINER"
  return 1
}

function configure_test {
  docker exec "$DB_CONTAINER" apk add --update ruby >/dev/null 
  docker exec "$DB_CONTAINER" gem install bunny &>/dev/null || true
  docker exec "$DB_CONTAINER" gem list bunny | grep -q bunny
}

trap cleanup EXIT
cleanup

echo "Creating data container"
docker create --name "$DATA_CONTAINER" "$IMG"

echo "Starting DB"
docker run -it --rm -h aptible\
  -e USERNAME=testuser -e PASSPHRASE=pass -e DATABASE=db \
  --volumes-from "$DATA_CONTAINER" \
  "$IMG" --initialize \
  >/dev/null 2>&1

docker run -d -h aptible --name="$DB_CONTAINER" \
  --volumes-from "$DATA_CONTAINER" \
  "$IMG"

echo "Ensure the database is ready"
configure_test
wait_for_db

echo "Login to RabbitMQ"
docker exec -it "$DB_CONTAINER" ruby /tmp/test/bunny.rb &> /dev/null

echo "Ensure logs are present"
docker logs "$DB_CONTAINER" | grep -Eq "$INFO_LEVEL_LOGIN_MESSAGE"

echo "Restart the database with log level of none."
docker stop "$DB_CONTAINER" && docker rm "$DB_CONTAINER"
docker run -d -h aptible --name="$DB_CONTAINER" \
  --volumes-from "$DATA_CONTAINER" \
  -e RABBIT_LOG_LEVEL=none \
  "$IMG"

echo "Ensure the database is ready"
configure_test
wait_for_db

echo "Login to RabbitMQ"
docker exec -it "$DB_CONTAINER" ruby /tmp/test/bunny.rb &> /dev/null

echo "Ensure logs are not present"
! docker logs "$DB_CONTAINER" | grep -Eq "$INFO_LEVEL_LOGIN_MESSAGE"
