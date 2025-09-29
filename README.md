# sbd2-cryptocurrency-data-analysis

# Instalação

```
mkdir -p ./dags ./logs ./plugins ./config # Se ainda não existir
echo -e "AIRFLOW_UID=$(id -u)" >> .env # Se ainda ñ for configurado
docker compose up --build
```
