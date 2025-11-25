# MER-DER-DLD-DD

**Análise de Criptomoedas - Camada Gold**

Arthur Ribeiro e Sousa - 221007850  
Henrique Camelo Quenino - 221008098  
Rodolfo Cabral Neves - 180011472  

**Professor:** Thiago Luiz de Souza Gomes  
**Data:** 25 de novembro de 2025

---

## 1. Modelo Entidade-Relacionamento (MER)

O modelo entidade-relacionamento da camada Gold representa a estrutura lógica dos dados transformados e prontos para análise. O modelo segue o formato estrela (**Star Schema**), com uma tabela fato central e três dimensões relacionadas, otimizado para consultas analíticas de alto desempenho.

### Entidades Identificadas

- **dim_dta**: Representa as informações de tempo em nível diário, capturando contexto temporal de cada captura de dados.
- **dim_hra**: Representa os horários da coleta dos dados, permitindo análises intra-dia e padrões horários.
- **dim_crp**: Contém os dados descritivos das criptomoedas, incluindo identificadores, símbolos e características estáticas.
- **fat_mtr**: Centraliza as métricas de mercado das criptomoedas, consolidando preços, volumes, variações e indicadores financeiros.

---

## 2. Diagrama Entidade-Relacionamento (DER)

O diagrama abaixo representa o relacionamento entre as entidades, destacando as cardinalidades do modelo estrela:

```
┌─────────────────────┐
│     dim_dta         │
│  (Dimensão Data)    │
│                     │
│ srk_dta (PK)        │
│ dte_cpt             │
│ num_dia, num_mes    │
│ num_ano, nom_mes    │
│ nom_sem, num_tri    │
│ num_sem, flg_fds    │
└──────────┬──────────┘
           │ (1)
           │
      (N) ◄┴►
           │
    ┌──────┴────────┐
    │               │
┌───┴──────┐    ┌───┴────────┐
│ dim_hra  │    │ dim_crp    │
│ (Hora)   │    │(Cripto)    │
│          │    │            │
│srk_hra   │    │srk_crp(PK) │
│hre_cpt   │    │nky_nom(NK) │
│num_hra   │    │cod_sym     │
│num_min   │    │vlr_max_sup │
│num_seg   │    │flg_atv     │
│nom_per   │    │dte_add     │
└────┬─────┘    └────┬───────┘
     │(1)            │(1)
     │               │
     └──┬────────────┘
        │
     (N)│
        │
   ┌────▼──────────────────────┐
   │   fat_mtr                 │
   │  (Tabela Fato - Métricas) │
   │                           │
   │ srk_fat (PK)              │
   │ srk_crp (FK)              │
   │ srk_dta (FK)              │
   │ srk_hra (FK)              │
   │ rnk_cmc                   │
   │ vlr_pre_usd               │
   │ vlr_vlm_24h               │
   │ vlr_mkt                   │
   │ vlr_dom, vlr_tvr          │
   │ qtd_par, qtd_cir_sup      │
   │ qtd_tot_sup               │
   │ vlr_fd_mkt                │
   │ vlr_mkt_tot               │
   │ pct_ytd, pct_1hr          │
   │ pct_24h, pct_7dd          │
   │ pct_30d, pct_60d          │
   │ pct_90d                   │
   └───────────────────────────┘
```

**Cardinalidades:**
- **dim_dta** (1) — (N) **fat_mtr**: Uma data tem muitas métricas
- **dim_hra** (1) — (N) **fat_mtr**: Uma hora tem muitas métricas
- **dim_crp** (1) — (N) **fat_mtr**: Uma criptomoeda tem muitas métricas

---

## 3. Dicionário de Dados Lógico (DLD)

### Tabela: dim_dta

| Campo | Tipo | Descrição | Chave |
|-------|------|-----------|-------|
| srk_dta | INTEGER | Chave surrogada da data | PK |
| dte_cpt | DATE | Data de captura da informação | |
| num_dia | SMALLINT | Dia do mês (1–31) | |
| num_mes | SMALLINT | Mês (1–12) | |
| num_ano | SMALLINT | Ano | |
| nom_mes | VARCHAR(20) | Nome do mês | |
| nom_sem | VARCHAR(20) | Nome do dia da semana | |
| num_tri | SMALLINT | Trimestre (1–4) | |
| num_sem | SMALLINT | Semana do ano | |
| flg_fds | BOOLEAN | Indicador de fim de semana | |

**Índices:**
- `idx_dta_dte` em `dte_cpt` (acesso rápido por data)

---

### Tabela: dim_hra

| Campo | Tipo | Descrição | Chave |
|-------|------|-----------|-------|
| srk_hra | INTEGER | Chave surrogada da hora | PK |
| hre_cpt | TIME | Hora da captura | |
| num_hra | SMALLINT | Hora (0–23) | |
| num_min | SMALLINT | Minuto (0–59) | |
| num_seg | SMALLINT | Segundo (0–59) | |
| nom_per | VARCHAR(20) | Período do dia (manhã, tarde, noite) | |

**Índices:**
- `idx_hra_hre` em `hre_cpt` (acesso rápido por hora)

---

### Tabela: dim_crp

| Campo | Tipo | Descrição | Chave |
|-------|------|-----------|-------|
| srk_crp | BIGSERIAL | Chave surrogada da criptomoeda | PK |
| nky_nom | VARCHAR(255) | Nome da criptomoeda (chave natural, única) | NK |
| cod_sym | VARCHAR(32) | Código/símbolo do ativo (BTC, ETH, etc.) | |
| vlr_max_sup | NUMERIC(38,10) | Oferta máxima possível | |
| flg_atv | BOOLEAN | Indica se a moeda está ativa | |
| dte_add | DATE | Data de adição no CoinMarketCap | |

**Índices:**
- `idx_crp_nom` em `nky_nom` (acesso rápido por nome)

---

### Tabela: fat_mtr (Fato - Métricas)

| Campo | Tipo | Descrição | Chave |
|-------|------|-----------|-------|
| srk_fat | BIGSERIAL | Identificador único do fato | PK |
| srk_crp | BIGINT | Referência para dim_crp | FK |
| srk_dta | INTEGER | Referência para dim_dta | FK |
| srk_hra | INTEGER | Referência para dim_hra | FK |
| rnk_cmc | INTEGER | Ranking no CoinMarketCap | |
| vlr_pre_usd | NUMERIC(30,8) | Preço em dólares americanos | |
| vlr_vlm_24h | NUMERIC(30,2) | Volume negociado em 24h (USD) | |
| vlr_mkt | NUMERIC(30,2) | Market Cap (capitalização de mercado) | |
| vlr_dom | NUMERIC(8,4) | Dominância no mercado (%) | |
| vlr_tvr | NUMERIC(12,6) | Turnover/Taxa de rotatividade | |
| qtd_par | INTEGER | Quantidade de pares de mercado | |
| qtd_cir_sup | NUMERIC(30,8) | Oferta circulante | |
| qtd_tot_sup | NUMERIC(30,8) | Oferta total | |
| vlr_fd_mkt | NUMERIC(30,2) | Market Cap totalmente diluído | |
| vlr_mkt_tot | NUMERIC(30,2) | Market Cap pelo Total Supply | |
| pct_ytd | NUMERIC(38,10) | Variação percentual acumulada no ano | |
| pct_1hr | NUMERIC(38,10) | Variação percentual (1 hora) | |
| pct_24h | NUMERIC(38,10) | Variação percentual (24 horas) | |
| pct_7dd | NUMERIC(38,10) | Variação percentual (7 dias) | |
| pct_30d | NUMERIC(38,10) | Variação percentual (30 dias) | |
| pct_60d | NUMERIC(38,10) | Variação percentual (60 dias) | |
| pct_90d | NUMERIC(38,10) | Variação percentual (90 dias) | |

**Índices:**
- `idx_fat_crp` em `srk_crp` (chave estrangeira)
- `idx_fat_dta` em `srk_dta` (chave estrangeira)
- `idx_fat_hra` em `srk_hra` (chave estrangeira)
- `idx_fat_dta_crp` em `(srk_dta, srk_crp)` (busca por data e criptomoeda)
- `idx_fat_mkt` em `vlr_mkt DESC` (otimização para rankings)

---

## 4. Relacionamentos e Cardinalidades

| Relacionamento | Descrição |
|---|---|
| **dim_dta (1) — (N) fat_mtr** | Uma data tem múltiplas métricas capturadas em diferentes horas |
| **dim_hra (1) — (N) fat_mtr** | Uma hora tem múltiplas métricas para diferentes criptomoedas |
| **dim_crp (1) — (N) fat_mtr** | Uma criptomoeda tem múltiplas métricas ao longo do tempo |

---

## 5. Resumo da Arquitetura

O modelo segue o padrão **Star Schema**, em que:

- **Tabela Fato Central (fat_mtr)**: Centraliza os dados de métricas de mercado de criptomoedas, consolidando preços, volumes, variações percentuais e indicadores de dominância. Otimizada para agregações e análises comparativas.

- **Tabelas de Dimensão**:
  - **dim_dta**: Fornece contexto temporal em nível diário, permitindo análises sazonais, análises por trimestre e comparações temporais.
  - **dim_hra**: Fornece contexto intra-diário, possibilitando identificação de padrões horários e análises de comportamento de curto prazo.
  - **dim_crp**: Fornece contexto descritivo da criptomoeda, incluindo oferta máxima para cálculos de potencial inflacionário.
