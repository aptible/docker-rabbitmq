#!/bin/bash
set -o errexit
set -o nounset

IMG="$1"
TAG="$2"

if [[ "$TAG" == "3.5" ]]; then
  ADMIN_CMD="rabbitmqadmin -c /usr/local/bin/rabbitmqadmin.conf"
elif [[ "$TAG" == "3.7" ]]; then
  ADMIN_CMD="rabbitmqadmin --ssl-insecure -c /usr/local/bin/rabbitmqadmin.conf"
fi

DB_CONTAINER="rabbit"
DATA_CONTAINER="${DB_CONTAINER}-data"
RABBIT_USER="testuser"
RABBIT_PASS="pass"

function cleanup {
  echo "Cleaning up"
  docker rm -f "$DB_CONTAINER" "$DATA_CONTAINER" > /dev/null 2>&1 || true
}

wait_for_rabbitmq() {
  docker exec -it "$DB_CONTAINER" apk add --update python &>/dev/null
  for _ in $(seq 1 60); do
    if docker exec -it "$DB_CONTAINER" $ADMIN_CMD list users &>/dev/null; then
      return 0
    fi
    sleep 1
  done

  echo "RabbitMQ did not come online!"

  return 1
}

trap cleanup EXIT
cleanup

echo "Creating data container"
docker create --name "$DATA_CONTAINER" "$IMG" &> /dev/null

echo "Initializing DB"
docker run -it --rm\
  -e USERNAME="$RABBIT_USER" -e PASSPHRASE="$RABBIT_PASS" -e DATABASE="db" \
  --volumes-from "$DATA_CONTAINER" -h aptible \
  "${IMG}" --initialize &> /dev/null

echo "Starting DB"
docker run -it --rm -d --name="$DB_CONTAINER" \
  --volumes-from "$DATA_CONTAINER" -h aptible \
  "${IMG}" &> /dev/null

echo "Waiting for DB"
wait_for_rabbitmq

echo "Testing for existing plugin"
docker exec -it "$DB_CONTAINER" rabbitmq-plugins list rabbitmq_management | grep -F '[E*]' &> /dev/null

echo "Enabling new plugin"
docker exec -it "$DB_CONTAINER" rabbitmq-plugins enable rabbitmq_consistent_hash_exchange --online &> /dev/null

echo "Testing for new plugin"
docker exec -it "$DB_CONTAINER" rabbitmq-plugins list rabbitmq_consistent_hash_exchange | grep -F '[E*]' &> /dev/null

echo "Wiping out the database container"
docker stop -t 10 "$DB_CONTAINER" &> /dev/null
sleep 10


echo "Starting DB again with the persistent volume"
docker run -d --rm  --name="${DB_CONTAINER}" \
  --volumes-from "$DATA_CONTAINER" -h aptible \
  "${IMG}" &> /dev/null

echo "Waiting for DB"
wait_for_rabbitmq

echo "Testing for existing plugin"
docker exec -it "$DB_CONTAINER" rabbitmq-plugins list rabbitmq_management | grep -F '[E*]' &> /dev/null

echo "Testing for new plugin persistence"
docker exec -it "$DB_CONTAINER" rabbitmq-plugins list rabbitmq_consistent_hash_exchange | grep -F '[E*]' &> /dev/null

echo "Done!"