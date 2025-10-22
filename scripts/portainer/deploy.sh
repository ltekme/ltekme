mkdir portainer
cd portainer

apk add wget
wget https://raw.githubusercontent.com/ltekme/ltekme/refs/heads/main/scripts/portainer/docker-compose.yaml

docker compose up -d
