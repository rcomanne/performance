#!/bin/bash

function duckTest() {
  for i in {0..10}; do
    echo -en "Waiting for $(( 10 - ${i} )) seconds \033[0K\r"
    sleep 1
  done
  for i in {1..5}; do
    echo -e "\n====="
    date +"%H:%M:%S:%N"
    echo "Generate"
    output=$(curl -sS -X GET localhost:8080/ducks/generate)
    docker stats --no-stream --format "CPU:{{.CPUPerc}}\tMem:{{.MemUsage}}" $1
    echo "====="
  done
  echo ""
  echo "Get all ducks"
  curl -sS -X GET localhost:8080/ducks/
  echo ""
  echo "Delete ducks"
  curl -sS -X DELETE localhost:8080/ducks
}

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

echo -e "\n\nStarting HotSpot test"
echo "========================================"
docker run --name ${hotspot_name} -p 8080:8080 --network ${network_name} -d performance-hotspot:latest
duckTest ${hotspot_name}
echo "Stopping container [${openj9_name}] and waiting 2 seconds"
docker stop ${hotspot_name}
sleep 2

echo -e "\n\nStarting OpenJ9 test"
echo "========================================"
docker run --name ${openj9_name} -p 8080:8080 --network ${network_name} -d performance-openj9:latest
duckTest ${openj9_name}
echo "Stopping container [${openj9_name}] and waiting 2 seconds"
docker stop ${openj9_name}
sleep 2