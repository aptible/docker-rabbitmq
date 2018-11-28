#!/bin/bash
set -o errexit
set -o nounset

IMG="$REGISTRY/$REPOSITORY:$TAG"

echo "Unit Tests..."
docker run -it --rm --entrypoint "bash" "$IMG" \
  -c "apk add --update python >/dev/null && \
      install-bats && \
      bats /tmp/test"


echo "#############"
echo "# Tests OK! #"
echo "#############"
