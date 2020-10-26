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

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

assert_higher_than_1.1() {
  if [ "$(version $1)" -ge "$(version "1.1.0")" ]; then
      echo "Version ${1} is higher than 1.1.0"
      return 1
  fi
  return 0
}
test() {
  x=$1
  y=$2
  if [  ]; then
    echo "${x} is less than ${y}"
  else
    echo "${x} is not less than ${y}"
  fi
}