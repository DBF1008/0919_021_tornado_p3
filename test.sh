#!/bin/sh
# Manually run the Tornado unit tests.
#
# Usage:
#   ./test.sh                 # run the full test suite
#   ./test.sh gen             # run only tornado.test.gen_test
#   ./test.sh concurrent      # run only tornado.test.concurrent_test
#   ./test.sh gen concurrent  # run several modules
#   ./test.sh tornado.test.gen_test.WaitIteratorTest  # run one test class
#
# Any argument containing a dot is passed through to the test runner
# unchanged; short names are expanded to tornado.test.<name>_test.

cd "$(dirname "$0")"

PYTHON=${PYTHON:-python3}

if [ $# -eq 0 ]; then
    exec "$PYTHON" -m tornado.test.runtests
fi

modules=""
for arg in "$@"; do
    case "$arg" in
        *.*) modules="$modules $arg" ;;
        *)   modules="$modules tornado.test.${arg}_test" ;;
    esac
done

# shellcheck disable=SC2086
exec "$PYTHON" -m tornado.test.runtests $modules
