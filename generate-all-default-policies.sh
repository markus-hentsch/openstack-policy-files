#!/bin/bash

# Generates default API policy files for multiple OpenStack APIs
# across multiple releases for comparison and templating.

# directory for the virtualenv
export VENV="./.scs-policies-venv"

# specify the release branches for which to generate policy sets
releases=(
    stable/2023.2
    stable/2023.1
    stable/zed
    stable/yoga
    stable/xena
    stable/wallaby
)

# specify the OpenStack components to generate policy files for
services=(
    nova
    cinder
    glance
    keystone
    barbican
    neutron
)

for r in "${releases[@]}"; do
    virtualenv --clear "$VENV"
    source "$VENV/bin/activate"
    # install pre-reqs
    pip3 install oslo.policy

    for i in "${services[@]}"; do
        echo "service $i ..."
        GIT_URL="https://opendev.org/openstack/$i.git"
        pip3 install git+${GIT_URL}@${r}
        oslopolicy-policy-generator --namespace "$i" \
            --output-file policy-$i-${r/\//-}.yaml 
        echo "service $i done!"
    done
    # leave virtualenv
    deactivate
done
