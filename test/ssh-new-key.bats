#!/usr/bin/env bats
# -*- sh -*-

# Guard against bats executing this twice
if [ -z "$TEST_PATH_INITIALIZED" ]; then
    PATH="${BATS_TEST_DIRNAME}/../.local/bin:$PATH"
fi
       
@test "Simple call" {
    run ssh-new-key user example.com
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "create a new key for user@example.com" ]
}

@test "Missing parameter" {
    run ssh-new-key user
    [ "$status" -eq 64 ]
    [ "${lines[0]}" = "Usage: ssh-new-key <user> <hostname>" ]

    run ssh-new-key example.com
    [ "$status" -eq 64 ]
    [ "${lines[0]}" = "Usage: ssh-new-key <user> <hostname>" ]
}
