#!/usr/bin/env bats
# -*- sh -*-

# Guard against bats executing this twice
if [ -z "$TEST_PATH_INITIALIZED" ]; then
    PATH="${BATS_TEST_DIRNAME}/../.local/bin:$PATH"
    SSH_TEST_DIR="${BATS_TMPDIR}/ssh-new-key"
fi

setup() {
    mkdir "${SSH_TEST_DIR}"
}

teardown() {
    rm -rf "${SSH_TEST_DIR}"
}

@test "Simple call" {
    local var HOME="${SSH_TEST_DIR}"
    run ssh-new-key user example.com
    if [ "${status}" -ne 0 ]; then
	echo "actual: ${status}"
	return ${status}
    fi

    [ "${lines[0]}" = "create a new key for user@example.com" ]
    [ -f "$HOME/.ssh/config.d/user@example.com.config" ]

    cat <<EOF | diff "$HOME/.ssh/config.d/user@example.com.config" -
Match User user Host example.com
  IdentityFile ~/.ssh/user@example.com
EOF
}

@test "Missing parameter" {
    run ssh-new-key user
    [ "$status" -eq 64 ]
    [ "${lines[0]}" = "Usage: ssh-new-key <user> <hostname>" ]

    run ssh-new-key example.com
    [ "$status" -eq 64 ]
    [ "${lines[0]}" = "Usage: ssh-new-key <user> <hostname>" ]
}

@test "Config file already exists" {
    local var HOME="${SSH_TEST_DIR}"
    mkdir -p "$HOME/.ssh/config.d"
    touch "$HOME/.ssh/config.d/user@example.com.config"
    run ssh-new-key user example.com
    if [ "${status}" -ne 1 ]; then
	echo "actual: ${status}"
	return 1
    fi

    [ "${lines[0]}" = "File \"$HOME/.ssh/config.d/user@example.com.config\" already exists" ]

}
