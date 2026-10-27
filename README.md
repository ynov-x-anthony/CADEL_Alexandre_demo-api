# demo-api

Stack Compose : `api` (Node/Express), `db` (PostgreSQL 16), `adminer`.

## Prérequis

- Docker Engine + Compose v2 (`docker compose version`)
- Windows : travailler depuis WSL

## Démarrage

```bash
cp .env.example .env
cp secrets/db_password.txt.example secrets/db_password.txt   # puis change le mot de passe
docker compose up -d --build
```

Le mot de passe de la base passe par Docker Secrets (`secrets/db_password.txt`, ignoré par git).

## URLs

- API : http://localhost:8080/products
- Adminer : http://localhost:8081 (serveur `db`)

## Test (commande testée)

```bash
docker compose up -d --build && docker compose ps
```

```
SERVICE   STATUS
adminer   Up 21 seconds
api       Up 15 seconds (healthy)
db        Up 21 seconds (healthy)
```

## Repartir de zéro

```bash
docker compose down -v
```
