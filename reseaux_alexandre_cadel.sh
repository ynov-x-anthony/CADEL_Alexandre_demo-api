#!/usr/bin/env bash
export MSYS_NO_PATHCONV=1

docker build -t demo-api:1.0 ./api
docker network create demo_front 2>/dev/null || true
docker network create demo_back 2>/dev/null || true

docker run -d --name demo-db \
    --network demo_back \
    -v "$(pwd)/db/init.sql":/docker-entrypoint-initdb.d/init.sql:ro \
    -e POSTGRES_USER=demo -e POSTGRES_PASSWORD=demo -e POSTGRES_DB=demo \
    postgres:16-alpine

until docker exec demo-db pg_isready -U demo; do sleep 1; done

docker run -d --name demo-api --network demo_front --network demo_back -p 8080:3000 -e PGHOST=demo-db demo-api:1.0

until curl -sf localhost:8080/products >/dev/null; do sleep 1; done

docker exec demo-api getent hosts demo-db

docker run --rm --network demo_front alpine nc -zv demo-db 5432

docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAMConfig}} {{.IPAddress}}{{"\n"}}{{end}}' demo-db
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAMConfig}} {{.IPAddress}}{{"\n"}}{{end}}' demo-api

curl -s localhost:8080/products

docker rm -fv demo-db
docker rm -f demo-api

docker network rm demo_back
docker network rm demo_front