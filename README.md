# SBD2 - Análise de Dados de Criptomoedas

## Introdução

Este repositório apresenta a modelagem de dados para o trabalho final da Disciplina de Bancos de Dados 2. Para
tal utilizamos o CoinMarketCap Cryptocurrency Dataset 2023 disponível no kaggle. O Dataset contém informações
abrangentes sobre preços de criptomoedas, capitalização de mercado e outras métricas relevantes, coletadas do site
CoinMarketCap.

## Pré-requisitos

Para executar este projeto, você precisará ter o Docker e o Docker Compose instalados em sua máquina. Certifique-se de
ter as versões mais recentes para garantir a compatibilidade.

## Como instalar e executar

1. Clone o repositório:

```bash
https://github.com/artrsousa1/sbd2-cryptocurrency-data-analysis.git

cd sbd2-cryptocurrency-data-analysis
```

2. Altere a permissão entrypoint que executa o ETL:

```bash
chmod +x entrypoint.sh
```

3. Execute o docker compose para iniciar os serviços:

```bash
docker compose up --build
```

