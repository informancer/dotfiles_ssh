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
    run ssh-new-key -p passphrase user example.com 
    if [ "${status}" -ne 0 ]; then
	echo "actual: ${status}"
	return ${status}
    fi

    if [ "${lines[0]}" != "create a new key for user@example.com" ]; then
       echo "actual: ${lines[0]}"
    fi
    [ -f "$HOME/.ssh/config.d/user@example.com.config" ]

    cat <<EOF | diff "$HOME/.ssh/config.d/user@example.com.config" -
Match User user Host example.com
  IdentityFile ~/.ssh/user@example.com
EOF
    [ -f "$HOME/.ssh/user@example.com" ]
}

@test "Simple call (alternative user and host)" {
    local var HOME="${SSH_TEST_DIR}"
    run ssh-new-key -p passphrase other alternative.com
    if [ "${status}" -ne 0 ]; then
	echo "actual: ${status}"
	return ${status}
    fi

    [ "${lines[0]}" = "create a new key for other@alternative.com" ]
    [ -f "$HOME/.ssh/config.d/other@alternative.com.config" ]

    cat <<EOF | diff "$HOME/.ssh/config.d/other@alternative.com.config" -
Match User other Host alternative.com
  IdentityFile ~/.ssh/other@alternative.com
EOF
    [ -f "$HOME/.ssh/other@alternative.com" ]
}


@test "Missing parameter" {
    run ssh-new-key user
    [ "$status" -eq 64 ]
    [ "${lines[0]}" = "Usage: ssh-new-key [-p passphrase] [-k <keyfile>] [--overwrite-config] <user> <hostname>" ]

    run ssh-new-key example.com
    [ "$status" -eq 64 ]
    [ "${lines[0]}" = "Usage: ssh-new-key [-p passphrase] [-k <keyfile>] [--overwrite-config] <user> <hostname>" ]
}

@test "Config file already exists and --overwrite-config is not given" {
    local var HOME="${SSH_TEST_DIR}"
    mkdir -p "$HOME/.ssh/config.d"
    touch "$HOME/.ssh/config.d/user@example.com.config"
    run ssh-new-key user example.com
    if [ "${status}" -ne 1 ]; then
	echo "actual: ${status}"
	return 1
    fi

    [ "${lines[0]}" = "File \"$HOME/.ssh/config.d/user@example.com.config\" already exists" ]
    [ "${lines[1]}" = "Use --overwrite-config to force recreation of the configuration" ]

}

@test "Config file already exists but --overwrite-config is given" {
    local var HOME="${SSH_TEST_DIR}"
    mkdir -p "$HOME/.ssh/config.d"
    cat <<EOF > "$HOME/.ssh/config.d/user@example.com.config"
Content to overwrite
EOF
    run ssh-new-key -p passphrase --overwrite-config user example.com
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
    [ -f "$HOME/.ssh/user@example.com" ]
}

@test "Pass key name as short parameter" {
    local var HOME="${SSH_TEST_DIR}"
    run ssh-new-key -k given user example.com
    if [ "${status}" -ne 0 ]; then
	echo "actual: ${status}"
	return ${status}
    fi

    [ "${lines[0]}" = "create a new key for user@example.com" ]
    [ -f "$HOME/.ssh/config.d/user@example.com.config" ]

    cat <<EOF | diff "$HOME/.ssh/config.d/user@example.com.config" -
Match User user Host example.com
  IdentityFile ~/.ssh/given
EOF
    [ -f "$HOME/.ssh/given" ]
}

@test "Pass key name as long parameter" {
    local var HOME="${SSH_TEST_DIR}"
    run ssh-new-key --keyfile given user example.com
    if [ "${status}" -ne 0 ]; then
	echo "actual: ${status}"
	return ${status}
    fi

    [ "${lines[0]}" = "create a new key for user@example.com" ]
    [ -f "$HOME/.ssh/config.d/user@example.com.config" ]

    cat <<EOF | diff "$HOME/.ssh/config.d/user@example.com.config" -
Match User user Host example.com
  IdentityFile ~/.ssh/given
EOF
    [ -f "$HOME/.ssh/given" ]
}
