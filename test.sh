#!/bin/bash
set -o errexit
set -o nounset

IMG="$REGISTRY/$REPOSITORY:$TAG"

echo "Unit Tests..."
docker run -it --rm --entrypoint "bash" "$IMG" \
  -c "apk add --update python ruby >/dev/null && \
      install-bats && \
      bats /tmp/test"

TESTS=(
  test-logging
 )

for t in "${TESTS[@]}"; do
  echo "--- START ${t} ---"
  "./${t}.sh" "$IMG"
  echo "--- OK    ${t} ---"
  echo
done

echo "#############"
echo "# Tests OK! #"
echo "#############"
