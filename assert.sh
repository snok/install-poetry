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

assert_in_one_or_the_other() {
  local option1="$1"
  local option2="$2"
  local long="$3"

  if [[ "$long" == *"$option1"* || "$long" == *"$option2"* ]]; then
    echo "assertion succeeded: one of the options were found in ${long}"
    return 0
  else
    echo "assertion failed: neither option was found in ${long}"
    return 1
  fi
}
