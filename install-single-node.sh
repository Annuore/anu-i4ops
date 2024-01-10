
#!/bin/bash

set -eu

# By calling ./install-single-node.sh you can pass any argument to ansible-playbook command
calling_args="$*"
readonly dir=$(dirname $(dirname "$0"))
cd $dir

# Read more about ANSIBLE_* env variables at https://docs.ansible.com/ansible/latest/reference_appendices/config.html#environment-variables
export ANSIBLE_LOG_PATH="logs/$(date +%Y%m%d%H%M%S).log"
export ANSIBLE_INVENTORY=${ANSIBLE_INVENTORY:-hosts.ini}

if [ -z ${ANSIBLE_PRIVATE_KEY_FILE:-} ]; then
    # if private key is not used then ask about password
    calling_args+=" -k -K"
fi

echo "# ANSIBLE_INVENTORY=$ANSIBLE_INVENTORY"
cmd="ansible-playbook install-single-node.yaml $calling_args"
echo "# $cmd"
$cmd

echo "# Logs are saved at: $ANSIBLE_LOG_PATH"