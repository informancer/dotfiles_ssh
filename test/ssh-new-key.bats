#!/usr/bin/env bats
# -*- sh -*-

# Guard against bats executing this twice
if [ -z "$TEST_PATH_INITIALIZED" ]; then
    PATH="${BATS_TEST_DIRNAME}/../.local/bin;$PATH"
fi
       
@test "Simple call" {
    run ssh-new-key
    [ "$status" -eq 0 ]
}
