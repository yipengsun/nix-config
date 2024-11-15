#!/usr/bin/env bash

# input parameters
HOSTNAME=$1


# figure out the directory of this script
SCRIPT_DIR=$(dirname $0)
OUTPUT_DIR=$(dirname $SCRIPT_DIR)/gen/$HOSTNAME

echo "The output directory is: $OUTPUT_DIR"
mkdir -p $OUTPUT_DIR


# request confirmation explicitly
read -p "Do you want to proceed? (y/n): " ANSWER
if [[ "$ANSWER" == "n" || "$ANSWER" == "N" ]]; then
    echo "Exiting..."
    exit 0
fi


# generate ssh keys
SSH_DIR=$OUTPUT_DIR/etc/ssh
mkdir -p $SSH_DIR

ssh-keygen -q -N "" -t rsa -b 4096 -f $SSH_DIR/ssh_host_rsa_key
ssh-keygen -q -N "" -t ecdsa -f $SSH_DIR/ssh_host_ecdsa_key
ssh-keygen -q -N "" -t ed25519 -f $SSH_DIR/ssh_host_ed25519_key

#sudo chown -R root:root $SSH_DIR
for i in $SSH_DIR/*; do
    chmod 600 $i
done
