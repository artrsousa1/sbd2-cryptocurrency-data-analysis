-- Moedas mais voláteis (último período)
-- Identificando as mais voláteis no último período registrado, usando o volume negociado nas últimas 24 horas (volume_24h) como métrica de volatilidade.
SELECT 
    dc."NK_Name" as moeda,
    dc."CMC_Rank" as rank,
    STDDEV(fm."volume_24h") as desvio_padrao_24h,
    AVG(ABS(fm."volume_24h")) as volatilidade_media_absoluta,
    COUNT(*) as observacoes
FROM dw.fact_market fm
JOIN dw.dim_currency dc ON fm."SK_Currency" = dc."SK_Currency"
GROUP BY dc."NK_Name", dc."CMC_Rank"
HAVING COUNT(*) > 1
ORDER BY volatilidade_media_absoluta DESC
LIMIT 15;

-- Top 10 moedas com maior valor de mercado
SELECT 
    dc."NK_Name" as moeda,
    dc."CMC_Rank" as rank,
    fm."price" as preco_usd,
    fm."market_cap" as market_cap,
    fm."volume_24h" as volume_24h,
    fm."percent_change_24h" as variacao_24h,
    dt."NK_Date" as data_atualizacao
FROM dw.fact_market fm
JOIN dw.dim_currency dc ON fm."SK_Currency" = dc."SK_Currency"
JOIN dw.dim_time dt ON fm."SK_Time" = dt."SK_Time"
WHERE dt."NK_Date" = (SELECT MAX("NK_Date") FROM dw.dim_time)
ORDER BY fm."market_cap" DESC
LIMIT 10;

-- Dominância das principais moedas por período
-- Mostrar a dominância de mercado das principais criptomoedas ao longo do tempo, permitindo ver quais moedas têm maior participação no market cap global.
-- A dominância é a porcentagem da capitalização de mercado de uma moeda em relação ao mercado total.

SELECT 
    dt."NK_Date" as data,
    dc."NK_Name" as moeda,
    fm."dominance" as dominancia,
    fm."market_cap" as market_cap
FROM dw.fact_market fm
JOIN dw.dim_currency dc ON fm."SK_Currency" = dc."SK_Currency"
JOIN dw.dim_time dt ON fm."SK_Time" = dt."SK_Time"
WHERE dc."NK_Name" IN ('Bitcoin', 'Ethereum', 'Tether USDt', 'BNB', 'XRP')
ORDER BY dt."NK_Date" DESC, fm."dominance" DESC;

-- métricas consolidadas diárias do mercado de criptomoedas para um dashboard, 
-- agregando informações como número de moedas, capitalização total, volume negociado, variação média e preços extremos.
SELECT 
    dt."NK_Date" as data,
    COUNT(DISTINCT dc."SK_Currency") as total_moedas,
    SUM(fm."market_cap") as market_cap_total,
    SUM(fm."volume_24h") as volume_total_24h,
    AVG(fm."percent_change_24h") as variacao_media_24h,
    MAX(fm."price") as maior_preco,
    MIN(fm."price") as menor_preco
FROM dw.fact_market fm
JOIN dw.dim_currency dc ON fm."SK_Currency" = dc."SK_Currency"
JOIN dw.dim_time dt ON fm."SK_Time" = dt."SK_Time"
GROUP BY dt."NK_Date"
ORDER BY dt."NK_Date" DESC;