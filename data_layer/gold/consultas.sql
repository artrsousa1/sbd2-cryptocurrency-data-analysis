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
WITH LatestSnapshots AS (
    SELECT DISTINCT ON (srk_crp)
        srk_crp, rnk_cmc, vlr_mkt, vlr_vlm_24h, vlr_dom, vlr_tvr, 
        qtd_par, srk_dta
    FROM dw.fat_mtr
    WHERE srk_dta != -1
    ORDER BY srk_crp, srk_dta DESC
)
SELECT
    d_crp.nky_nom AS nome_cripto,
    d_crp.cod_sym AS simbolo,
    f.rnk_cmc AS ranking_cmc,
    f.vlr_mkt AS valor_mercado,
    f.vlr_vlm_24h AS volume_24h,
    (f.vlr_vlm_24h / NULLIF(f.vlr_mkt, 0)) AS razao_volume_mkt,
    f.vlr_dom AS dominancia_mercado,
    f.vlr_tvr AS taxa_rotatividade,
    f.qtd_par AS qtd_pares_negociacao
FROM LatestSnapshots f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
WHERE d_crp.flg_atv = true
  AND f.vlr_mkt > 1000000
ORDER BY
    f.vlr_dom DESC,
    f.vlr_mkt DESC
LIMIT 10;

