#!/bin/bash

echo "Building Docker images"
docker build -t jre-alpine:11-hotspot --file hotspot/Dockerfile .
docker build -t jre-alpine:11-openj9 --file openj9/Dockerfile .

echo "Building app"
mvn clean install -DskipTests