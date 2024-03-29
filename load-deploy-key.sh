#!/bin/sh

# This script configures the ssh-agent, loading a GitHub deploy key
#
# Required configuration:
# see https://github.com/mlocati/travisci-github-deploy-key/blob/master/README.md
#
# Author: Michele Locati <michele@locati.it>
# License: MIT
# Source: https://github.com/mlocati/travisci-github-deploy-key
#

# When any command fails the shell immediately shall exit
set -o errexit
# Fail when the shell tries to use an unset variable
set -o nounset

# Check environment
if test -z "${TRAVIS_BUILD_DIR:-}"; then
    echo 'Invalid environment: the variable TRAVIS_BUILD_DIR is not defined' >&2
    exit 1
fi

if test -z "${DEPLOYKEY_FILE:-}"; then
    DEPLOYKEY_FILE="$TRAVIS_BUILD_DIR/.travis/github_deploy_key.enc"
else
    DEPLOYKEY_FILE="$TRAVIS_BUILD_DIR/$DEPLOYKEY_FILE"
fi
if test ! -f "$DEPLOYKEY_FILE"; then
    printf 'Invalid environment: unable to find the file containing the encrypted deploy key "%s"\n' "$DEPLOYKEY_FILE" >&2
    exit 1
fi
if test -z "${DEPLOYKEY_PASSWORD:-}"; then
    echo 'Invalid environment: the variable DEPLOYKEY_PASSWORD is not defined' >&2
    exit 1
fi

# Let's be sure that the SSH directory is there
mkdir -p "$HOME/.ssh"
chmod 0700 "$HOME/.ssh"

# Let's define the path where the key will be saved
SSH_FILE=$(mktemp -u "$HOME/.ssh/XXXXX")

# Using AES-256-CBC, let's decrypt (-d)  the encrypted deploy key (-in)
# using the password (-k), saving in SHA-256 format (-md)
# to the SSH_FILE file (-out)
openssl aes-256-cbc -d -in "$DEPLOYKEY_FILE" -pass "pass:$DEPLOYKEY_PASSWORD" -md sha256 -out "$SSH_FILE"

# Let's secure the unencrypted deploy key
chmod 600 "$SSH_FILE"

# Let's start the SSH agent
eval "$(ssh-agent)"

# Let's add the deploy key to the SSH agent
ssh-add "$SSH_FILE"

# Let's tell OpenSSH that for github.com we should use the deploy key
printf 'Host github.com\n    BatchMode yes\n    IdentityFile %s\n    LogLevel ERROR\n' "$SSH_FILE" >> "$HOME/.ssh/config"
