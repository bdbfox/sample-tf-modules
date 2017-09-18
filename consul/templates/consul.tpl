#!/bin/bash

cat >/etc/ecs/ecs.config <<FINISH
ECS_CLUSTER=${clustername}
FINISH

yum -y update
