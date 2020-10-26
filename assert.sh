assert_in() {
  local short="$1"
  local long="$2"

  if [[ "$long" == *"$short"* ]]; then
    echo "assertion succeeded: ${short} was found in ${long}"
    return 0
  else
    echo "assertion failed: ${short} not found in ${long}"
    return 1
  fi
}
