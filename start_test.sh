#!/bin/bash

hotspot_name="hotspot"
openj9_name="openj9"
docker rm -f ${hotspot_name} ${openj9_name}

set -e
network_name="performance-network"
if [[ -z $(docker network ls | grep ${network_name}) ]]; then
  echo "Creating Docker network [${network_name}]"
  docker network create ${network_name}
fi

echo "Checking postgres setup"
db_container_name="performance-db"
container_id=$(docker ps -aq -f name="${db_container_name}")
if [[ -z "${container_id}" ]]; then
  echo "DB does not exist and is not running, creating [${db_container_name}]"
  docker run --name ${db_container_name} -p 5432:5432 -e POSTGRES_PASSWORD=sbapp -d --network ${network_name} postgres
  else
    if $( docker container inspect -f '{{.State.Running}}' ${db_container_name} ); then
      echo "DB is already running"
    else
      echo "DB is not running but exists, starting..."
      docker start "${db_container_name}"
    fi
fi

x-terminal-emulator -e docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo "Starting HotSpot test"
docker run --name ${hotspot_name} -p 8080:8080 --network ${network_name} -d performance-hotspot:latest
# No need to wait in the loop - docker stats is slow
for i in {0..15}; do
  date +"%H:%M:%S:%N"
  docker stats --no-stream --format "CPU:{{.CPUPerc}}\tMem:{{.MemUsage}}" ${hotspot_name}
done
echo "Stopping container [${hotspot_name}] and waiting 2 seconds"
docker stop ${hotspot_name}
sleep 2

echo "Starting OpenJ9 test"
docker run --name ${openj9_name} -p 8080:8080 --network ${network_name} -d performance-openj9:latest
# No need to wait in the loop - docker stats is slow
for i in {0..15}; do
  date +"%H:%M:%S:%N"
  docker stats --no-stream --format "CPU:{{.CPUPerc}}\tMem:{{.MemUsage}}" ${openj9_name}
done
echo "Stopping container [${openj9_name}] and waiting 2 seconds"
docker stop ${openj9_name}
sleep 2

echo "HotSpot startup time (from log)"
docker logs ${hotspot_name} | grep seconds
echo "OpenJ9 startup time (from log)"
docker logs ${openj9_name} | grep seconds