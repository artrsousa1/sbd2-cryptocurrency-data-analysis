-- 1) Top 10 Criptomoedas por Valor de Mercado
SELECT DISTINCT ON (f.sk_crpt)
    d_crpt.nk_nome AS nome_cripto,
    TO_CHAR(f.vlr_mktcap, 'FM$999,999,999,999,999.00') AS valor_de_mercado,
    d_data.dt_cpta AS data_snapshot,
    d_hora.hr_cpta AS hora_snapshot
FROM
    dw.fato_metricas_crpt f
JOIN
    dw.dim_crpt d_crpt ON f.sk_crpt = d_crpt.sk_crpt
JOIN
    dw.dim_data d_data ON f.sk_data = d_data.sk_data
JOIN
    dw.dim_hora d_hora ON f.sk_hora = d_hora.sk_hora
WHERE
    f.sk_data != -1
ORDER BY
    f.sk_crpt,
    f.sk_data DESC,
    f.sk_hora DESC,
    f.vlr_mktcap DESC
LIMIT 10;

-- 2) Top 10 Gainers nas Últimas 24 Horas
WITH LatestSnapshots AS (
    SELECT DISTINCT ON (f.sk_crpt)
        f.sk_crpt,
        d_crpt.nk_nome,
        f.pc_24h,
        f.vlr_preco_usd,
        f.vlr_mktcap
    FROM
        dw.fato_metricas_crpt f
    JOIN
        dw.dim_crpt d_crpt ON f.sk_crpt = d_crpt.sk_crpt
    WHERE
        f.sk_data != -1
    ORDER BY
        f.sk_crpt,
        f.sk_data DESC,
        f.sk_hora DESC
)
SELECT
    nk_nome AS nome_cripto,
    TO_CHAR(pc_24h, 'FM999,999,990.00%') AS variacao_24h,
    TO_CHAR(vlr_preco_usd, 'FM$999,999,990.000000') AS preco_atual
FROM
    LatestSnapshots
WHERE
    vlr_mktcap > 1000000
ORDER BY
    pc_24h DESC
LIMIT 10;

-- 3) Top 10 Losers nos Últimas 7 Dias
WITH LatestSnapshots AS (
    SELECT DISTINCT ON (f.sk_crpt)
        f.sk_crpt,
        d_crpt.nk_nome,
        f.pc_7d,
        f.vlr_mktcap
    FROM
        dw.fato_metricas_crpt f
    JOIN
        dw.dim_crpt d_crpt ON f.sk_crpt = d_crpt.sk_crpt
    WHERE
        f.sk_data != -1
    ORDER BY
        f.sk_crpt,
        f.sk_data DESC,
        f.sk_hora DESC
)
SELECT
    nk_nome AS nome_cripto,
    TO_CHAR(pc_7d, 'FM999,999,990.00%') AS variacao_7d,
    TO_CHAR(vlr_mktcap, 'FM$999,999,999,999,999.00') AS valor_de_mercado
FROM
    LatestSnapshots
WHERE
    vlr_mktcap > 1000000
ORDER BY
    pc_7d ASC
LIMIT 10;

-- 4) Top 10 Criptomoedas por Dominância de Mercado
SELECT
    d_crpt.nk_nome AS Nome_Cripto,
    TO_CHAR(f.vlr_dmn, 'FM990.00%') AS Dominancia_de_Mercado,
    TO_CHAR(f.vlr_mktcap, 'FM$999,999,999,999,999.00') AS Valor_de_Mercado,
    d_data.dt_cpta AS Data_Snapshot,
    d_hora.hr_cpta AS Hora_Snapshot
FROM (
    SELECT DISTINCT ON (f.sk_crpt)
        f.sk_crpt,
        f.vlr_mktcap,
        f.vlr_dmn,
        f.sk_data,
        f.sk_hora
    FROM
        dw.fato_metricas_crpt f
    WHERE
        f.sk_data != -1
    ORDER BY
        f.sk_crpt,
        f.sk_data DESC,
        f.sk_hora DESC
) f
JOIN dw.dim_crpt d_crpt ON f.sk_crpt = d_crpt.sk_crpt
JOIN dw.dim_data d_data ON f.sk_data = d_data.sk_data
JOIN dw.dim_hora d_hora ON f.sk_hora = d_hora.sk_hora
WHERE
    f.vlr_dmn > 0
ORDER BY
    f.vlr_dmn DESC
LIMIT 10;

-- 5) Top 10 Moedas com maior valor unitário
SELECT
    d_crpt.nk_nome AS Nome_Cripto,
    TO_CHAR(f.vlr_preco_usd, 'FM$999,999,999,990.00') AS Preco_por_Moeda,
    TO_CHAR(f.vlr_mktcap, 'FM$999,999,999,999.00') AS Valor_de_Mercado
FROM (
    SELECT DISTINCT ON (f.sk_crpt)
        f.sk_crpt,
        f.vlr_preco_usd,
        f.vlr_mktcap,
        f.sk_data,
        f.sk_hora
    FROM
        dw.fato_metricas_crpt f
    WHERE
        f.sk_data != -1
    ORDER BY
        f.sk_crpt,
        f.sk_data DESC,
        f.sk_hora DESC
) f
JOIN dw.dim_crpt d_crpt ON f.sk_crpt = d_crpt.sk_crpt
WHERE
    f.vlr_mktcap > 1000000
ORDER BY
    f.vlr_preco_usd DESC
LIMIT 10;

-- 6) Top 10 Criptomoedas por Volume de Negociação nas Últimas 24 Horas
SELECT
    d_crpt.nk_nome AS Nome_Cripto,
    ABS(f.pc_24h) AS magnitude_da_variacao,
    TO_CHAR(f.pc_24h, 'FM999,999,990.00%') AS Variacao_24h_Real
FROM (
    SELECT DISTINCT ON (f.sk_crpt)
        f.sk_crpt,
        f.pc_24h,
        f.vlr_mktcap,
        f.sk_data,
        f.sk_hora
    FROM
        dw.fato_metricas_crpt f
    WHERE
        f.sk_data != -1
    ORDER BY
        f.sk_crpt,
        f.sk_data DESC,
        f.sk_hora DESC
) f
JOIN dw.dim_crpt d_crpt ON f.sk_crpt = d_crpt.sk_crpt
WHERE
    f.vlr_mktcap > 1000000
ORDER BY
    ABS(f.pc_24h) DESC
LIMIT 10;

-- 7) Moedas com quedas recentes e altas nos últimos 90 dias
SELECT
    d_crpt.nk_nome AS Nome_Cripto,
    TO_CHAR(f.pc_7d, 'FM990.00%') AS Variacao_7d,
    TO_CHAR(f.pc_90d, 'FM990.00%') AS Variacao_90d
FROM dw.fato_metricas_crpt f
JOIN dw.dim_crpt d_crpt ON f.sk_crpt = d_crpt.sk_crpt
WHERE f.sk_data != -1
  AND (f.sk_data, f.sk_hora) = (
      SELECT MAX(f2.sk_data), MAX(f2.sk_hora)
      FROM dw.fato_metricas_crpt f2
      WHERE f2.sk_crpt = f.sk_crpt
  )
  AND f.pc_7d < -5 
  AND f.pc_90d > 20
  AND f.vlr_mktcap > 10000000
ORDER BY
  f.pc_7d ASC;
