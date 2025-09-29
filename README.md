# sbd2-cryptocurrency-data-analysis

# Instalação

## Base

```
mkdir -p ./dags ./logs ./plugins ./config # Se ainda não existir
echo -e "AIRFLOW_UID=$(id -u)" >> .env # Se ainda ñ for configurado
docker compose up --build
```

## Chave de Fernet

Instale o utilitário makepasswd antecipadamente antes de executar o seguinte comando

```
echo "FERNET_KEY=$(makepasswd)" >> .env
```

Se tiver algum problema no processo de instalação, consulte a [documentação oficial do Apache Airflow](https://airflow.apache.org/docs/apache-airflow/stable/howto/docker-compose/index.html)
