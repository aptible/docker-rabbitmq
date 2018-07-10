#!/bin/bash
set -o errexit
set -o nounset

IMG="$REGISTRY/$REPOSITORY:$TAG"

echo "Unit Tests..."
docker run -it --rm --entrypoint "bash" "$IMG" \
  -c "apk-install python >/dev/null && bats /tmp/test"


echo "#############"
echo "# Tests OK! #"
echo "#############"
