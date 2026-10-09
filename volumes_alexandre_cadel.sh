#!/usr/bin/env bash
export MSYS_NO_PATHCONV=1

docker build -t demo-api:1.0 ./api
docker volume create demo_pgdata 2>/dev/null || true
docker network create demo_net 2>/dev/null || true

docker run -d --name demo-db --network demo_net \
    -v demo_pgdata:/var/lib/postgresql/data \
    -v "$(pwd)/db/init.sql":/docker-entrypoint-initdb.d/init.sql:ro \
    -e POSTGRES_USER=demo -e POSTGRES_PASSWORD=demo -e POSTGRES_DB=demo \
    postgres:16-alpine

until docker exec demo-db pg_isready -U demo; do sleep 1; done

docker run -d --name demo-api --network demo_net -p 8080:3000 -e PGHOST=demo-db demo-api:1.0

curl -s -X POST -H 'content-type: application/json' \
  -d '{"name":"Casquette Démo","price_cents":1200}' localhost:8080/products

docker rm -f demo-db demo-api

docker run -d --name demo-db --network demo_net \
    -v demo_pgdata:/var/lib/postgresql/data \
    -v "$(pwd)/db/init.sql":/docker-entrypoint-initdb.d/init.sql:ro \
    -e POSTGRES_USER=demo -e POSTGRES_PASSWORD=demo -e POSTGRES_DB=demo \
    postgres:16-alpine

until docker exec demo-db pg_isready -U demo; do sleep 1; done

docker run -d --name demo-api --network demo_net -p 8080:3000 -e PGHOST=demo-db demo-api:1.0

docker volume ls | grep demo_pgdata
curl -s localhost:8080/products
