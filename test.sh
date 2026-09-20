#!/bin/sh
# Unit test scripts for the future lifecycle fixes in gen.py / concurrent.py:
#
#   1. gen.with_timeout now cancels the inner awaitable on timeout and
#      swallows the resulting CancelledError (no more leaked IO operations).
#   2. gen.WaitIterator serializes next() calls and ignores duplicate
#      completions so a result can never be consumed twice.
#   3. gen.multi(..., return_exceptions=True) returns a MultiResult
#      aggregate (successes + failures) instead of raising and losing
#      all successful results.
#   4. concurrent.chain_future propagates cancellation along the chain.
#
# Run manually from the repository root:  sh test.sh
# Note: tests that bind TCP sockets (GenWebTest, GeneratorCapClientTest,
# SelectorThreadContextvarsTest) require network permissions and may fail
# with PermissionError in restricted sandboxes.

cd $(dirname $0)

set -x

# Focused regression tests for the three fixes.
python -m tornado.test.runtests --verbose \
    tornado.test.gen_test.WithTimeoutTest \
    tornado.test.gen_test.WaitIteratorTest \
    tornado.test.gen_test.GenBasicTest \
    tornado.test.concurrent_test.ChainFutureTest

# Full modules touched by the changes.
python -m tornado.test.runtests \
    tornado.test.gen_test \
    tornado.test.concurrent_test

# Modules that consume with_timeout / WaitIterator / multi internally.
python -m tornado.test.runtests \
    tornado.test.locks_test \
    tornado.test.queues_test \
    tornado.test.asyncio_test
