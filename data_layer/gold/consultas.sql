-- 1) Top 10 Criptomoedas por Valor de Mercado
SELECT DISTINCT ON (f.srk_crp)
    d_crp.nky_nom AS nome_cripto,
    TO_CHAR(f.vlr_mkt, 'FM$999,999,999,999,999.00') AS valor_de_mercado,
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
        d_crp.nky_nom,
        f.pct_24h,
        f.vlr_pre_usd,
        f.vlr_mkt
    FROM
        dw.fat_mtr f
    JOIN
        dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
    WHERE
        f.srk_dta != -1
    ORDER BY
        f.srk_crp,
        f.srk_dta DESC,
        f.srk_hra DESC
)
SELECT
    nky_nom AS nome_cripto,
    TO_CHAR(pct_24h, 'FM999,999,990.00%') AS variacao_24h,
    TO_CHAR(vlr_pre_usd, 'FM$999,999,990.000000') AS preco_atual
FROM
    LatestSnapshots
WHERE
    vlr_mkt > 1000000
ORDER BY
    pct_24h DESC
LIMIT 10;


-- 3) Top 10 Losers nos Últimas 7 Dias
WITH LatestSnapshots AS (
    SELECT DISTINCT ON (f.srk_crp)
        f.srk_crp,
        d_crp.nky_nom,
        f.pct_7dd,
        f.vlr_mkt
    FROM
        dw.fat_mtr f
    JOIN
        dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
    WHERE
        f.srk_dta != -1
    ORDER BY
        f.srk_crp,
        f.srk_dta DESC,
        f.srk_hra DESC
)
SELECT
    nky_nom AS nome_cripto,
    TO_CHAR(pct_7dd, 'FM999,999,990.00%') AS variacao_7d,
    TO_CHAR(vlr_mkt, 'FM$999,999,999,999,999.00') AS valor_de_mercado
FROM
    LatestSnapshots
WHERE
    vlr_mkt > 1000000
ORDER BY
    pct_7dd ASC
LIMIT 10;


-- 4) Top 10 Criptomoedas por Dominância de Mercado
SELECT
    d_crp.nky_nom AS Nome_Cripto,
    TO_CHAR(f.vlr_dom, 'FM990.00%') AS Dominancia_de_Mercado,
    TO_CHAR(f.vlr_mkt, 'FM$999,999,999,999,999.00') AS Valor_de_Mercado,
    d_dta.dte_cpt AS Data_Snapshot,
    d_hra.hre_cpt AS Hora_Snapshot
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
JOIN dw.dim_hra d_hra ON f.srk_hra = d_hra.srk_hra
WHERE
    f.vlr_dom > 0
ORDER BY
    f.vlr_dom DESC
LIMIT 10;


-- 5) Top 10 Moedas com maior valor unitário
SELECT
    d_crp.nky_nom AS Nome_Cripto,
    TO_CHAR(f.vlr_pre_usd, 'FM$999,999,999,990.00') AS Preco_por_Moeda,
    TO_CHAR(f.vlr_mkt, 'FM$999,999,999,999.00') AS Valor_de_Mercado
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
    d_crp.nky_nom AS Nome_Cripto,
    ABS(f.pct_24h) AS magnitude_da_variacao,
    TO_CHAR(f.pct_24h, 'FM999,999,990.00%') AS Variacao_24h_Real
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
    d_crp.nky_nom AS Nome_Cripto,
    TO_CHAR(f.pct_7dd, 'FM990.00%') AS Variacao_7d,
    TO_CHAR(f.pct_90d, 'FM990.00%') AS Variacao_90d
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

-- 8) Análise de Potencial Inflacionário: Risco de Diluição por Criptomoeda
-- Identifica moedas com maior potencial de inflação (oferta circulante vs máxima)
-- Útil para avaliar risco de desvalorização por emissão massiva
SELECT
    d_crp.nky_nom AS Nome_Cripto,
    d_crp.cod_sym AS Simbolo,
    f.qtd_cir_sup AS Oferta_Circulante,
    d_crp.vlr_max_sup AS Oferta_Maxima,
    CASE 
        WHEN d_crp.vlr_max_sup IS NULL THEN 0
        WHEN d_crp.vlr_max_sup = 0 THEN 0
        ELSE ROUND((f.qtd_cir_sup / d_crp.vlr_max_sup) * 100, 2)
    END AS Proporcao_Circulante_Pct,
    CASE 
        WHEN d_crp.vlr_max_sup IS NULL THEN 100
        WHEN d_crp.vlr_max_sup = 0 THEN 100
        ELSE ROUND((1 - (f.qtd_cir_sup / d_crp.vlr_max_sup)) * 100, 2)
    END AS Potencial_Inflacionario_Pct,
    TO_CHAR(f.vlr_mktcap, 'FM$999,999,999,999.00') AS Market_Cap_Atual,
    f.rnk_cmc AS Ranking_CMC,
    d_dta.dte_cpt AS Data_Analise
FROM (
    SELECT DISTINCT ON (srk_crp)
        srk_crp, qtd_cir_sup, qtd_tot_sup, vlr_mktcap, rnk_cmc, srk_dta
    FROM dw.fat_mtr
    WHERE srk_dta != -1
    ORDER BY srk_crp, srk_dta DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
JOIN dw.dim_dta d_dta ON f.srk_dta = d_dta.srk_dta
WHERE d_crp.flg_atv = true
  AND f.vlr_mktcap > 1000000
ORDER BY
    Potencial_Inflacionario_Pct DESC;


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
    ROUND(
        ((ABS(f.pct_1hr) + ABS(f.pct_24h) + ABS(f.pct_7dd)) / 3), 2
    ) AS Volatilidade_Media_Curto_Prazo,
    ROUND(
        ((ABS(f.pct_30d) + ABS(f.pct_60d) + ABS(f.pct_90d)) / 3), 2
    ) AS Volatilidade_Media_Longo_Prazo,
    CASE 
        WHEN ABS(f.pct_24h) > 10 THEN 'ALTÍSSIMO'
        WHEN ABS(f.pct_24h) > 5 THEN 'ALTO'
        WHEN ABS(f.pct_24h) > 2 THEN 'MODERADO'
        ELSE 'BAIXO'
    END AS Classificacao_Risco_24h,
    TO_CHAR(f.vlr_pre_usd, 'FM$999,999,990.00') AS Preco_USD,
    TO_CHAR(f.vlr_mktcap, 'FM$999,999,999,999.00') AS Market_Cap,
    d_dta.dte_cpt AS Data_Analise,
    d_hra.hre_cpt AS Hora_Analise
FROM (
    SELECT DISTINCT ON (srk_crp)
        srk_crp, pct_1hr, pct_24h, pct_7dd, pct_30d, pct_60d, pct_90d, 
        pct_ytd, vlr_pre_usd, vlr_mktcap, srk_dta, srk_hra
    FROM dw.fat_mtr
    WHERE srk_dta != -1
    ORDER BY srk_crp, srk_dta DESC, srk_hra DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
JOIN dw.dim_dta d_dta ON f.srk_dta = d_dta.srk_dta
JOIN dw.dim_hra d_hra ON f.srk_hra = d_hra.srk_hra
WHERE d_crp.flg_atv = true
  AND f.vlr_mktcap > 1000000
ORDER BY
    Volatilidade_Media_Curto_Prazo DESC;


-- 10) Análise de Saúde de Mercado: Volume, Dominância e Liquidez
-- Correlaciona volume de negociação, dominância e market cap para avaliar saúde e liquidez do ativo
-- Útil para decisões operacionais e detecção de anomalias
SELECT
    d_crp.nky_nom AS Nome_Cripto,
    d_crp.cod_sym AS Simbolo,
    f.rnk_cmc AS Ranking_CMC,
    TO_CHAR(f.vlr_mktcap, 'FM$999,999,999,999.00') AS Market_Cap,
    TO_CHAR(f.vlr_vlm_24h, 'FM$999,999,999,999.00') AS Volume_24h_USD,
    ROUND(
        (f.vlr_vlm_24h / NULLIF(f.vlr_mktcap, 0)) * 100, 2
    ) AS Razao_Volume_MarketCap_Pct,
    TO_CHAR(f.vlr_dom, 'FM990.00%') AS Dominancia_Mercado_Pct,
    ROUND(f.vlr_tvr, 4) AS Taxa_Rotatividade,
    f.qtd_par AS Quantidade_Pares_Negociacao,
    CASE 
        WHEN (f.vlr_vlm_24h / NULLIF(f.vlr_mktcap, 0)) > 0.5 THEN 'ALTAMENTE LÍQUIDA'
        WHEN (f.vlr_vlm_24h / NULLIF(f.vlr_mktcap, 0)) > 0.2 THEN 'LÍQUIDA'
        WHEN (f.vlr_vlm_24h / NULLIF(f.vlr_mktcap, 0)) > 0.05 THEN 'MODERADAMENTE LÍQUIDA'
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
        srk_crp, rnk_cmc, vlr_mktcap, vlr_vlm_24h, vlr_dom, vlr_tvr, 
        qtd_par, srk_dta
    FROM dw.fat_mtr
    WHERE srk_dta != -1
    ORDER BY srk_crp, srk_dta DESC
) f
JOIN dw.dim_crp d_crp ON f.srk_crp = d_crp.srk_crp
JOIN dw.dim_dta d_dta ON f.srk_dta = d_dta.srk_dta
WHERE d_crp.flg_atv = true
  AND f.vlr_mktcap > 1000000
ORDER BY
    f.vlr_dom DESC,
    f.vlr_mktcap DESC;
