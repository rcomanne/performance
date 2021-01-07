#!/bin/bash

function duckTest() {
  for i in {1..10}; do
    echo -en "Waiting $(( 10 - ${i} )) seconds \033[0K\r"
    sleep 1
  done
  total=0
  echo "========================================"
  for i in {1..10}; do
    date +"%H:%M:%S"
    echo -en "Generate iteration [${i}]\033[0K\r"
    total=$(( total + $(curl -sS -X GET localhost:8080/ducks/generate?sort=false) ))
    echo -en "Generation [${i}] took $(curl -sS -X GET localhost:8080/ducks/generate)ms\n"
    docker stats --no-stream --format "{{.Name}}\t\tCPU: {{.CPUPerc}}\tMem: {{.MemUsage}}"
  done
  echo "====="
  echo "Get all ducks"
  out=$(curl -sS -X GET localhost:8080/ducks)
  echo "Sort all ducks"
  echo "Sorting ducks took $(curl -sS -X GET localhost:8080/ducks/sort)ms"
  echo "Delete all ducks"
  curl -sS -X DELETE localhost:8080/ducks
  avg=$(( ${total}/10 ))
  echo "Average generation took ${avg}ms for [$1]"
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

#x-terminal-emulator -e docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"
x-terminal-emulator -e docker stats

echo -e "\n\nRunning HotSpot test"
out=$(docker run --name ${hotspot_name} -p 8080:8080 --network ${network_name} -d performance-hotspot:latest)
time duckTest ${hotspot_name}
echo "Stopping container [${hotspot_name}] and waiting 2 seconds"
out=$(docker stop ${hotspot_name})
sleep 2

echo -e "\n\nRunning OpenJ9 test"
out=$(docker run --name ${openj9_name} -p 8080:8080 --network ${network_name} -d performance-openj9:latest)
time duckTest ${openj9_name}
echo "Stopping container [${openj9_name}] and waiting 2 seconds"
out=$(docker stop ${openj9_name})
sleep 2