-- 1) Top 10 Criptomoedas por Valor de Mercado
SELECT DISTINCT ON (f.srk_crp)
    d_crp.nky_nom AS nome_cripto,
    f.vlr_mkt AS valor_mercado,
    d_dta.dte_cpt AS data_snapshot,
    d_hra.hre_cpt AS hora_snapshot
FROM
    dw.fat_mtr f
JOIN
    dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
JOIN
    dw.dim_dta d_dta ON f.srk_dta = d_dta.srk_dta
JOIN
    dw.dim_hra d_hra ON f.srk_hra = d_hra.srk_hra
WHERE
    f.srk_dta != -1
ORDER BY
    f.srk_crp,
    f.srk_dta DESC,
    f.srk_hra DESC,
    f.vlr_mkt DESC
LIMIT 10;

-- 2) Top 10 Gainers nas Últimas 24 Horas
WITH LatestSnapshots AS (
    SELECT DISTINCT ON (f.srk_crp)
        f.srk_crp,
        d_crp.nky_nom AS nome_cripto,
        f.pct_24h AS variacao_percentual,
        f.vlr_pre_usd AS preco_usd,
        f.vlr_mkt AS valor_mercado
    FROM
        dw.fat_mtr f
    JOIN
        dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
    WHERE
        f.srk_dta != -1
        AND f.vlr_mkt > 1000000
    ORDER BY
        f.srk_crp,
        f.srk_dta DESC,
        f.srk_hra DESC
)
SELECT
    nome_cripto,
    variacao_percentual,
    preco_usd,
    valor_mercado
FROM
    LatestSnapshots
ORDER BY
    variacao_percentual DESC
LIMIT 10;

-- 3) Top 10 Losers nos Últimas 7 Dias
WITH LatestSnapshots AS (
    SELECT DISTINCT ON (f.srk_crp)
        f.srk_crp,
        d_crp.nky_nom AS nome_cripto,
        f.pct_7dd AS variacao_7d,
        f.vlr_mkt AS valor_mercado
    FROM
        dw.fat_mtr f
    JOIN
        dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
    WHERE
        f.srk_dta != -1
        AND f.vlr_mkt > 1000000
    ORDER BY
        f.srk_crp,
        f.srk_dta DESC,
        f.srk_hra DESC
)
SELECT
    nome_cripto,
    variacao_7d,
    valor_mercado
FROM
    LatestSnapshots
ORDER BY
    variacao_7d ASC
LIMIT 10;

-- 4) Top 10 Criptomoedas por Dominância de Mercado

SELECT
    d_crp.nky_nom AS nome_cripto,
    f.vlr_dom AS dominancia_mercado,
    f.vlr_mkt AS valor_mercado,
    d_dta.dte_cpt AS data_snapshot
FROM (
    SELECT DISTINCT ON (f.srk_crp)
        f.srk_crp,
        f.vlr_mkt,
        f.vlr_dom,
        f.srk_dta,
        f.srk_hra
    FROM
        dw.fat_mtr f
    WHERE
        f.srk_dta != -1
    ORDER BY
        f.srk_crp,
        f.srk_dta DESC,
        f.srk_hra DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
JOIN dw.dim_dta d_dta ON f.srk_dta = d_dta.srk_dta
WHERE
    f.vlr_dom > 0
ORDER BY
    f.vlr_dom DESC
LIMIT 10;

-- 5) Top 10 Moedas com maior valor unitário
SELECT
    d_crp.nky_nom AS nome_cripto,
    f.vlr_pre_usd AS preco_usd,
    f.vlr_mkt AS valor_mercado
FROM (
    SELECT DISTINCT ON (f.srk_crp)
        f.srk_crp,
        f.vlr_pre_usd,
        f.vlr_mkt,
        f.srk_dta,
        f.srk_hra
    FROM
        dw.fat_mtr f
    WHERE
        f.srk_dta != -1
    ORDER BY
        f.srk_crp,
        f.srk_dta DESC,
        f.srk_hra DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
WHERE
    f.vlr_mkt > 1000000
ORDER BY
    f.vlr_pre_usd DESC
LIMIT 10;

-- 6) Top 10 Criptomoedas por Volume de Negociação nas Últimas 24 Horas
SELECT
    d_crp.nky_nom AS nome_cripto,
    ABS(f.pct_24h) AS magnitude_variacao,
    f.pct_24h AS variacao_24h,
    f.vlr_mkt AS valor_mercado
FROM (
    SELECT DISTINCT ON (f.srk_crp)
        f.srk_crp,
        f.pct_24h,
        f.vlr_mkt,
        f.srk_dta,
        f.srk_hra
    FROM
        dw.fat_mtr f
    WHERE
        f.srk_dta != -1
    ORDER BY
        f.srk_crp,
        f.srk_dta DESC,
        f.srk_hra DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
WHERE
    f.vlr_mkt > 1000000
ORDER BY
    ABS(f.pct_24h) DESC
LIMIT 10;

-- 7) Moedas com quedas recentes e altas nos últimos 90 dias
SELECT
    d_crp.nky_nom AS nome_cripto,
    f.pct_7dd AS variacao_7d,
    f.pct_90d AS variacao_90d,
    f.vlr_mkt AS valor_mercado
FROM dw.fat_mtr f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
WHERE f.srk_dta != -1
  AND (f.srk_dta, f.srk_hra) = (
      SELECT MAX(f2.srk_dta), MAX(f2.srk_hra)
      FROM dw.fat_mtr f2
      WHERE f2.srk_crp = f.srk_crp
  )
  AND f.pct_7dd < -5 
  AND f.pct_90d > 20
  AND f.vlr_mkt > 10000000
ORDER BY
  f.pct_7dd ASC;

-- 8) Moedas Baixas em Rápida Desvalorização

WITH RankedSnapshots AS (
    SELECT
        f.vlr_pre_usd,
        f.pct_30d,
        f.vlr_mkt,
        d_crp.nky_nom,
        ROW_NUMBER() OVER (
            PARTITION BY f.srk_crp
            ORDER BY f.srk_dta DESC, f.srk_hra DESC
        ) AS rn
    FROM
        dw.fat_mtr f
    JOIN
        dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
    WHERE
        f.srk_dta != -1
)
SELECT
    rs.nky_nom AS nome_cripto,
    rs.vlr_pre_usd AS preco_usd,
    rs.pct_30d AS variacao_30d,
    rs.vlr_mkt AS valor_mercado
FROM
    RankedSnapshots rs
WHERE
    rs.rn = 1                              
    AND rs.vlr_pre_usd < 1.00            
    AND rs.pct_30d < -10.00              
    AND rs.vlr_mkt > 1000000             
ORDER BY
    rs.pct_30d ASC
LIMIT 10;



-- 9) Análise de Volatilidade Multi-Período: Risco e Comportamento Temporal
-- Agrega variações percentuais em múltiplos horizontes para identificar padrões de risco
-- Útil para portfolio risk management e decisões de investimento
SELECT
    d_crp.nky_nom AS Nome_Cripto,
    d_crp.cod_sym AS Simbolo,
    f.pct_1hr AS Variacao_1_Hora_Pct,
    f.pct_24h AS Variacao_24_Horas_Pct,
    f.pct_7dd AS Variacao_7_Dias_Pct,
    f.pct_30d AS Variacao_30_Dias_Pct,
    f.pct_60d AS Variacao_60_Dias_Pct,
    f.pct_90d AS Variacao_90_Dias_Pct,
    f.pct_ytd AS Variacao_YTD_Pct,
    ROUND(((ABS(f.pct_1hr) + ABS(f.pct_24h) + ABS(f.pct_7dd)) / 3), 2) AS Volatilidade_Media_Curto_Prazo,
    ROUND(((ABS(f.pct_30d) + ABS(f.pct_60d) + ABS(f.pct_90d)) / 3), 2) AS Volatilidade_Media_Longo_Prazo,
    CASE 
        WHEN ABS(f.pct_24h) > 10 THEN 'ALTÍSSIMO'
        WHEN ABS(f.pct_24h) > 5 THEN 'ALTO'
        WHEN ABS(f.pct_24h) > 2 THEN 'MODERADO'
        ELSE 'BAIXO'
    END AS Classificacao_Risco_24h,
    TO_CHAR(f.vlr_pre_usd, 'FM$999,999,990.00') AS Preco_USD,
    TO_CHAR(f.vlr_mkt, 'FM$999,999,999,999.00') AS Market_Cap,
    d_dta.dte_cpt AS Data_Analise,
    d_hra.hre_cpt AS Hora_Analise
FROM (
    SELECT DISTINCT ON (srk_crp)
        srk_crp, pct_1hr, pct_24h, pct_7dd, pct_30d, pct_60d, pct_90d, 
        pct_ytd, vlr_pre_usd, vlr_mkt, srk_dta, srk_hra
    FROM dw.fat_mtr
    WHERE srk_dta != -1
    ORDER BY srk_crp, srk_dta DESC, srk_hra DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
JOIN dw.dim_dta d_dta ON f.srk_dta = d_dta.srk_dta
JOIN dw.dim_hra d_hra ON f.srk_hra = d_hra.srk_hra
WHERE d_crp.flg_atv = true
  AND f.vlr_mkt > 1000000
ORDER BY
    Volatilidade_Media_Curto_Prazo DESC
LIMIT 10;


-- 10) Análise de Saúde de Mercado: Volume, Dominância e Liquidez
-- Correlaciona volume de negociação, dominância e market cap para avaliar saúde e liquidez do ativo
-- Útil para decisões operacionais e detecção de anomalias
SELECT
    d_crp.nky_nom AS Nome_Cripto,
    d_crp.cod_sym AS Simbolo,
    f.rnk_cmc AS Ranking_CMC,
    TO_CHAR(f.vlr_mkt, 'FM$999,999,999,999.00') AS Market_Cap,
    TO_CHAR(f.vlr_vlm_24h, 'FM$999,999,999,999.00') AS Volume_24h_USD,
    ROUND((f.vlr_vlm_24h / NULLIF(f.vlr_mkt, 0)) * 100, 2) AS Razao_Volume_MarketCap_Pct,
    TO_CHAR(f.vlr_dom, 'FM990.00%') AS Dominancia_Mercado_Pct,
    ROUND(f.vlr_tvr, 4) AS Taxa_Rotatividade,
    f.qtd_par AS Quantidade_Pares_Negociacao,
    CASE 
        WHEN (f.vlr_vlm_24h / NULLIF(f.vlr_mkt, 0)) > 0.5 THEN 'ALTAMENTE LÍQUIDA'
        WHEN (f.vlr_vlm_24h / NULLIF(f.vlr_mkt, 0)) > 0.2 THEN 'LÍQUIDA'
        WHEN (f.vlr_vlm_24h / NULLIF(f.vlr_mkt, 0)) > 0.05 THEN 'MODERADAMENTE LÍQUIDA'
        ELSE 'POUCO LÍQUIDA'
    END AS Classificacao_Liquidez,
    CASE 
        WHEN f.vlr_dom > 5 THEN 'DOMINANTE'
        WHEN f.vlr_dom > 1 THEN 'SIGNIFICATIVA'
        WHEN f.vlr_dom > 0.1 THEN 'PRESENÇA NOTÁVEL'
        ELSE 'PRESENÇA MÍNIMA'
    END AS Classificacao_Dominancia,
    d_dta.dte_cpt AS Data_Analise,
    d_dta.nom_mes AS Mes_Analise,
    d_dta.num_ano AS Ano_Analise
FROM (
    SELECT DISTINCT ON (srk_crp)
        srk_crp, rnk_cmc, vlr_mkt, vlr_vlm_24h, vlr_dom, vlr_tvr, 
        qtd_par, srk_dta
    FROM dw.fat_mtr
    WHERE srk_dta != -1
    ORDER BY srk_crp, srk_dta DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
JOIN dw.dim_dta d_dta ON f.srk_dta = d_dta.srk_dta
WHERE d_crp.flg_atv = true
  AND f.vlr_mkt > 1000000
ORDER BY
    f.vlr_dom DESC,
    f.vlr_mkt DESC
LIMIT 10;