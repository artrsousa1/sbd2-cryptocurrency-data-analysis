-- ============================================================
--  SCHEMA GOLD (DATA WAREHOUSE)
-- ============================================================
CREATE SCHEMA IF NOT EXISTS dw;

-- ============================================================
--  DIM_CURRENCY
-- ============================================================
CREATE TABLE IF NOT EXISTS dw.dim_currency (
    SK_Currency BIGSERIAL PRIMARY KEY,
    NK_Symbol VARCHAR(10) NOT NULL,
    Name VARCHAR(100),
    CMC_Rank INT,
    Date_Added DATE,
    Is_Active BOOLEAN,
    CONSTRAINT uq_dim_currency_symbol UNIQUE (NK_Symbol)
);

COMMENT ON TABLE dw.dim_currency IS 'Dimensão de moedas, representando cada criptomoeda única.';
COMMENT ON COLUMN dw.dim_currency.SK_Currency IS 'Chave substituta (surrogate key) gerada pelo DW.';
COMMENT ON COLUMN dw.dim_currency.NK_Symbol IS 'Chave de negócio (natural key), símbolo da moeda.';
COMMENT ON COLUMN dw.dim_currency.CMC_Rank IS 'Posição no ranking global.';
COMMENT ON COLUMN dw.dim_currency.Is_Active IS 'Indica se a moeda está ativa no mercado.';

-- ============================================================
--  DIM_TIME
-- ============================================================
CREATE TABLE IF NOT EXISTS dw.dim_time (
    SK_Time BIGSERIAL PRIMARY KEY,
    NK_Date DATE NOT NULL,
    Day_Of_Week VARCHAR(15),
    Month_Name VARCHAR(20),
    Quarter_Number INT,
    Year_Number INT,
    CONSTRAINT uq_dim_time_date UNIQUE (NK_Date)
);

COMMENT ON TABLE dw.dim_time IS 'Dimensão temporal usada para análise de séries históricas.';
COMMENT ON COLUMN dw.dim_time.SK_Time IS 'Chave substituta da dimensão tempo.';
COMMENT ON COLUMN dw.dim_time.NK_Date IS 'Chave de negócio que representa a data no formato YYYY-MM-DD.';

CREATE TABLE IF NOT EXISTS dw.fact_market (
    SK_Fact_Market BIGSERIAL PRIMARY KEY,
    FK_SK_Currency BIGINT NOT NULL,
    FK_SK_Time BIGINT NOT NULL,
    FK_SK_Market_Status BIGINT NOT NULL,
    Price_Value FLOAT,
    Volume_24h_Amount FLOAT,
    Market_Cap_Value FLOAT,
    Percent_Change_1h_Value FLOAT,
    Percent_Change_24h_Value FLOAT,
    Percent_Change_7d_Value FLOAT,
    CONSTRAINT fk_currency FOREIGN KEY (FK_SK_Currency)
        REFERENCES dw.dim_currency (SK_Currency),
    CONSTRAINT fk_time FOREIGN KEY (FK_SK_Time)
        REFERENCES dw.dim_time (SK_Time)
);

COMMENT ON TABLE dw.fact_market IS 'Tabela de fatos central com métricas financeiras e de desempenho das criptomoedas.';
COMMENT ON COLUMN dw.fact_market.FK_SK_Currency IS 'Chave estrangeira para Dim_Currency.';
COMMENT ON COLUMN dw.fact_market.FK_SK_Time IS 'Chave estrangeira para Dim_Time.';
COMMENT ON COLUMN dw.fact_market.Price_Value IS 'Preço atual da moeda.';
COMMENT ON COLUMN dw.fact_market.Volume_24h_Amount IS 'Volume transacionado nas últimas 24h.';
COMMENT ON COLUMN dw.fact_market.Market_Cap_Value IS 'Valor de mercado total.';
COMMENT ON COLUMN dw.fact_market.Percent_Change_1h_Value IS 'Variação percentual em 1 hora.';
COMMENT ON COLUMN dw.fact_market.Percent_Change_24h_Value IS 'Variação percentual em 24 horas.';
COMMENT ON COLUMN dw.fact_market.Percent_Change_7d_Value IS 'Variação percentual em 7 dias.';
