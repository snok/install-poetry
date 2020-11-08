assert_in_one() {
  local option1="$1"
  local option2="$2"
  local option3="$3"
  local long="$4"

  if [[ "$long" == *"$option1"* || "$long" == *"$option2"* || "$long" == *"$option3"* ]]; then
    echo "assertion succeeded: one of the options were found in ${long}"
    return 0
  else
    echo "assertion failed: none of the options were found in ${long}"
    echo -e "options:\n- $option1\n- $option2\n- $option3"
    return 1
  fi
}
assert_in() {
  local short="$1"
  local long="$2"
  # On windows paths use \ and unix uses /, so here we standardize
  long="${long//\\//}"
  if [[ "$long" == *"$short"* ]]; then
    echo "assertion succeeded: ${short} was found in ${long}"
    return 0
  else
    echo "assertion failed: ${short} not found in ${long}"
    return 1
  fi
}
