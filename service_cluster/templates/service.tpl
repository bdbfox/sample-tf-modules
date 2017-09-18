#!/bin/bash

cat >/etc/ecs/ecs.config <<FINISH
ECS_CLUSTER=${clustername}
FINISH

yum -y update

# Get my IP
IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`

cat >config.yaml <<FINISH
namers:
- kind: io.l5d.consul
  includeTag: false
  useHealthCheck: true
  host: $IP
routers:
- protocol: http
  label: /http-consul
  service:
    responseClassifier:
      kind: io.l5d.http.retryableIdempotent5XX
  identifier:
   kind: io.l5d.path
   segments: 1
   consume: true
  dtab: |
    /svc => /#/io.l5d.consul/dc0;
  servers:
  - port: 4140
    ip: 0.0.0.0
  client:
   requeueBudget:
     percentCanRetry: 5.0
FINISH

# start docker for consul agent
docker run -d --net=host --name=consulagent \
  consul agent \
  -bind=$IP \
  -client=0.0.0.0 \
  -datacenter=dc0 \
  -retry-join-ec2-tag-key=aws:autoscaling:groupName \
  -retry-join-ec2-tag-value=${group_name}

# start docker for registrator
docker run -d --net=host \
  --name=registrator \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
  -ip="$IP" \
  consul://localhost:8500

# start docker for linkerd
docker run -d \
  -p 4140:4140 \
  -p 9990:9990 \
  --net=bridge \
  --name=linkerd \
  --volume=`pwd`/config.yaml:/config.yaml \
  buoyantio/linkerd:1.1.3 \
  /config.yaml
