CREATE DATABASE olist_analytics;
USE olist_analytics;

CREATE TABLE dim_clientes (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);
USE olist_analytics;

CREATE TABLE dim_produtos (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category VARCHAR(100)
);
USE olist_analytics;

CREATE TABLE fato_pedidos (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    valor_total_pedido DECIMAL(10,2)
);

USE olist_analytics;

ALTER TABLE fato_pedidos
ADD CONSTRAINT fk_fato_pedidos_cliente
FOREIGN KEY (customer_id)
REFERENCES dim_clientes(customer_id);

USE olist_analytics;

CREATE TABLE dim_tempo (
    data_id DATE PRIMARY KEY,
    ano INT,
    mes INT,
    nome_mes VARCHAR(20),
    trimestre INT
);

USE olist_analytics;

ALTER TABLE fato_pedidos
ADD data_pedido DATE;

ALTER TABLE fato_pedidos
ADD CONSTRAINT fk_fato_pedidos_tempo
FOREIGN KEY (data_pedido)
REFERENCES dim_tempo(data_id);


USE olist_analytics;

CREATE TABLE fato_itens_pedido (
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    valor_item DECIMAL(10,2),
    valor_frete DECIMAL(10,2),
    PRIMARY KEY (order_id, product_id)
);

USE olist_analytics;

ALTER TABLE fato_itens_pedido
ADD CONSTRAINT fk_itens_pedido_pedido
FOREIGN KEY (order_id)
REFERENCES fato_pedidos(order_id);

ALTER TABLE fato_itens_pedido
ADD CONSTRAINT fk_itens_pedido_produto
FOREIGN KEY (product_id)
REFERENCES dim_produtos(product_id);

USE olist_analytics;

SHOW TABLES;

DESCRIBE dim_clientes;

DESCRIBE dim_produtos;

DESCRIBE dim_tempo;

DESCRIBE fato_pedidos;

DESCRIBE fato_itens_pedido;

SHOW CREATE TABLE fato_pedidos;
SHOW CREATE TABLE fato_itens_pedido;
SHOW CREATE TABLE dim_clientes;
SHOW CREATE TABLE dim_produtos;
SHOW CREATE TABLE dim_tempo;


SELECT COUNT(*) FROM dim_clientes;

SELECT COUNT(*) FROM dim_produtos;

ALTER TABLE fato_itens_pedido
DROP FOREIGN KEY fk_itens_pedido_pedido;


SELECT COUNT(*) FROM fato_itens_pedido;


ALTER TABLE fato_itens_pedido
DROP PRIMARY KEY;

SELECT COUNT(*) FROM fato_itens_pedido;


USE olist_analytics;

TRUNCATE TABLE fato_itens_pedido;

SET GLOBAL local_infile = 1;

CREATE TABLE fato_itens_pedido_tratada AS
SELECT
    order_id,
    product_id,
    SUM(valor_item)   AS valor_item,
    SUM(valor_frete) AS valor_frete
FROM fato_itens_pedido
GROUP BY
    order_id,
    product_id;

SELECT COUNT(*) FROM fato_itens_pedido_tratada;

DROP TABLE fato_itens_pedido;


ALTER TABLE fato_itens_pedido_tratada
RENAME TO fato_itens_pedido;

ALTER TABLE fato_itens_pedido
ADD PRIMARY KEY (order_id, product_id);

ALTER TABLE fato_itens_pedido
ADD CONSTRAINT fk_itens_pedido_produto
FOREIGN KEY (product_id)
REFERENCES dim_produtos(product_id);

DESCRIBE fato_itens_pedido;
SHOW CREATE TABLE fato_itens_pedido;


SELECT COUNT(*) FROM fato_pedidos;


INSERT INTO fato_pedidos (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    valor_total_pedido
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    SUM(p.payment_value) AS valor_total_pedido
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp;


CREATE TABLE stg_orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME
);

CREATE TABLE stg_order_payments (
    order_id VARCHAR(50),
    payment_value DECIMAL(10,2)
);

SELECT COUNT(*) FROM stg_orders;

SELECT COUNT(DISTINCT order_id) FROM stg_orders;

SELECT COUNT(*) FROM stg_order_payments;

SELECT COUNT(DISTINCT order_id) FROM stg_order_payments;


INSERT INTO fato_pedidos (
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    valor_total_pedido
)
SELECT
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    SUM(p.payment_value) AS valor_total_pedido
FROM stg_orders o
JOIN stg_order_payments p
    ON o.order_id = p.order_id
GROUP BY
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp;

SELECT COUNT(*) FROM fato_pedidos;

SELECT
    MIN(valor_total_pedido),
    MAX(valor_total_pedido)
FROM fato_pedidos;


SELECT COUNT(*) AS itens_sem_pedido
FROM fato_itens_pedido fi
LEFT JOIN fato_pedidos fp
    ON fi.order_id = fp.order_id
WHERE fp.order_id IS NULL;


SELECT COUNT(*) AS itens_sem_produto
FROM fato_itens_pedido fi
LEFT JOIN dim_produtos dp
    ON fi.product_id = dp.product_id
WHERE dp.product_id IS NULL;


SELECT COUNT(*) AS pedidos_sem_itens
FROM fato_pedidos fp
LEFT JOIN fato_itens_pedido fi
    ON fp.order_id = fi.order_id
WHERE fi.order_id IS NULL;

SELECT
    ROUND(SUM(valor_total_pedido), 2) AS faturamento_total
FROM fato_pedidos;


SELECT
    fp.order_id,
    fp.valor_total_pedido,
    SUM(fi.valor_item + fi.valor_frete) AS total_itens
FROM fato_pedidos fp
JOIN fato_itens_pedido fi
    ON fp.order_id = fi.order_id
GROUP BY
    fp.order_id,
    fp.valor_total_pedido
HAVING ABS(fp.valor_total_pedido - SUM(fi.valor_item + fi.valor_frete)) > 0.01
LIMIT 10;


SELECT
    order_status,
    COUNT(*) AS qtd
FROM fato_pedidos
WHERE valor_total_pedido = 0
GROUP BY order_status;

SELECT fi.*
FROM fato_itens_pedido fi
LEFT JOIN fato_pedidos fp
    ON fi.order_id = fp.order_id
WHERE fp.order_id IS NULL;



DELETE fi
FROM fato_itens_pedido fi
LEFT JOIN fato_pedidos fp
    ON fi.order_id = fp.order_id
WHERE fp.order_id IS NULL
  AND fi.order_id = 'bfbd0f9bdef84302105ad712db648a6c'
  AND fi.product_id = '5a6b04657a4c5ee34285d1e4619a96b4';

SELECT COUNT(*) AS itens_sem_pedido
FROM fato_itens_pedido fi
LEFT JOIN fato_pedidos fp
    ON fi.order_id = fp.order_id
WHERE fp.order_id IS NULL;

ALTER TABLE fato_itens_pedido
ADD CONSTRAINT fk_itens_pedido_pedido
FOREIGN KEY (order_id)
REFERENCES fato_pedidos(order_id);

SHOW CREATE TABLE fato_itens_pedido;


-- Análise 1: Total de itens vendidos por ano
-- Objetivo: medir o volume total de itens vendidos por ano
-- Fonte:
--  - fato_itens_pedido
--  - fato_pedidos
-- Observação: conta itens e associa o ano pela data de compra do pedido

SELECT
    YEAR(fp.order_purchase_timestamp) AS ano,
    COUNT(*) AS total_itens_vendidos
FROM fato_itens_pedido fi
JOIN fato_pedidos fp
    ON fi.order_id = fp.order_id
GROUP BY YEAR(fp.order_purchase_timestamp)
ORDER BY ano;

-- Análise 2: Item mais vendido por estado (ordenado por volume)
-- Objetivo: identificar o item mais vendido em cada estado
-- Fonte:
--  - fato_itens_pedido
--  - fato_pedidos
--  - dim_clientes
--  - dim_produtos
-- Observação: resultado ordenado do estado com maior volume para o menor

SELECT
    customer_state,
    product_category,
    quantidade_vendida
FROM (
    SELECT
        dc.customer_state,
        dp.product_category,
        COUNT(*) AS quantidade_vendida,
        ROW_NUMBER() OVER (
            PARTITION BY dc.customer_state
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM fato_itens_pedido fi
    JOIN fato_pedidos fp
        ON fi.order_id = fp.order_id
    JOIN dim_clientes dc
        ON fp.customer_id = dc.customer_id
    JOIN dim_produtos dp
        ON fi.product_id = dp.product_id
    GROUP BY
        dc.customer_state,
        dp.product_category
) ranked
WHERE rn = 1
ORDER BY quantidade_vendida DESC;


-- Análise 3: Itens mais vendidos no geral (Top 10)
-- Objetivo: identificar quais itens tiveram maior volume de vendas
-- Fonte:
--  - fato_itens_pedido
--  - dim_produtos
-- Observação: análise considera todas as regiões

SELECT
    dp.product_category,
    COUNT(*) AS quantidade_vendida
FROM fato_itens_pedido fi
JOIN dim_produtos dp
    ON fi.product_id = dp.product_id
GROUP BY
    dp.product_category
ORDER BY
    quantidade_vendida DESC
LIMIT 10;


-- Análise 4A: Ticket médio por ano
-- Objetivo: calcular o ticket médio por pedido em cada ano
-- Fonte: tabela fato_pedidos
-- Observação: ticket médio = soma do valor_total_pedido / quantidade de pedidos únicos

SELECT
    YEAR(order_purchase_timestamp) AS ano,
    ROUND(SUM(valor_total_pedido) / COUNT(DISTINCT order_id), 2) AS ticket_medio
FROM fato_pedidos
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY ano;

-- Análise 5: Distribuição de pedidos por status
-- Objetivo: analisar como os pedidos se distribuem entre os diferentes status
-- Fonte: tabela fato_pedidos
-- Observação: cada registro representa um pedido único

SELECT
    order_status AS status,
    COUNT(*) AS total_pedidos,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM fato_pedidos), 2) AS percentual
FROM fato_pedidos
WHERE order_status IS NOT NULL
GROUP BY order_status
ORDER BY total_pedidos DESC;

-- Análise 6: Faturamento total por ano
-- Objetivo: calcular o faturamento total por ano
-- Fonte: tabela fato_pedidos
-- Observação: faturamento calculado como a soma de valor_total_pedido

SELECT
    YEAR(order_purchase_timestamp) AS ano,
    ROUND(SUM(valor_total_pedido), 2) AS faturamento_total
FROM fato_pedidos
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY ano;


-- Análise 7: Evolução do faturamento ao longo do tempo
-- Objetivo: analisar como o faturamento evolui ao longo do tempo
-- Fonte: tabela fato_pedidos
-- Observação: análise baseada na data de compra do pedido

SELECT
    YEAR(order_purchase_timestamp) AS ano,
    MONTH(order_purchase_timestamp) AS mes,
    SUM(valor_total_pedido) AS faturamento
FROM fato_pedidos
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    ano DESC, mes DESC;

-- Análise 8: Percentual médio do frete no valor do pedido por ano
-- Objetivo: calcular quanto o frete representa, em média, no valor final dos pedidos por ano
-- Fórmula por pedido: frete / (itens + frete)
-- Observação: retorna valor em DECIMAL (ex.: 0,20 = 20%). Formate como % no BI.

SELECT
    YEAR(fp.order_purchase_timestamp) AS ano,
    ROUND(AVG(x.percentual_frete), 4) AS percentual_medio_frete
FROM (
    SELECT
        fi.order_id,
        (SUM(fi.valor_frete) / NULLIF(SUM(fi.valor_item) + SUM(fi.valor_frete), 0)) AS percentual_frete
    FROM fato_itens_pedido fi
    GROUP BY fi.order_id
) x
JOIN fato_pedidos fp
    ON x.order_id = fp.order_id
GROUP BY YEAR(fp.order_purchase_timestamp)
ORDER BY ano;


-- Análise 9: Ticket médio por estado e por ano
-- Objetivo: calcular o valor médio gasto por pedido em cada estado, por ano
-- Ticket médio = SUM(valor_total_pedido) / COUNT(DISTINCT order_id)

SELECT 
    YEAR(fp.order_purchase_timestamp) AS ano,
    dc.customer_state,
    ROUND(
        SUM(fp.valor_total_pedido) / COUNT(DISTINCT fp.order_id),
        2
    ) AS ticket_medio_estado
FROM fato_pedidos fp
JOIN dim_clientes dc 
    ON fp.customer_id = dc.customer_id
GROUP BY 
    YEAR(fp.order_purchase_timestamp),
    dc.customer_state
ORDER BY 
    ano,
    ticket_medio_estado DESC;
    
-- Análise 10: Faturamento por Categoria e Ano
-- Objetivo: identificar as categorias que mais geram faturamento por ano
-- Fonte:
--  - fato_itens_pedido
--  - fato_pedidos
--  - dim_produtos
-- Observação: faturamento calculado como (valor_item + valor_frete)

SELECT
    YEAR(fp.order_purchase_timestamp) AS ano,
    dp.product_category,
    ROUND(SUM(fi.valor_item + fi.valor_frete), 2) AS faturamento_categoria
FROM fato_itens_pedido fi
JOIN fato_pedidos fp
    ON fi.order_id = fp.order_id
JOIN dim_produtos dp
    ON fi.product_id = dp.product_id
GROUP BY
    YEAR(fp.order_purchase_timestamp),
    dp.product_category
ORDER BY
    ano, faturamento_categoria DESC;


-- Análise 11: Faturamento por Estado e Ano
-- Objetivo: calcular o faturamento total gerado em cada estado por ano
-- Fonte:
--  - fato_pedidos (valor_total_pedido, order_purchase_timestamp)
--  - dim_clientes (customer_state)
-- Observação: faturamento calculado como a soma de valor_total_pedido

SELECT
    YEAR(fp.order_purchase_timestamp) AS ano,
    dc.customer_state,
    ROUND(SUM(fp.valor_total_pedido), 2) AS faturamento_estado
FROM fato_pedidos fp
JOIN dim_clientes dc
    ON fp.customer_id = dc.customer_id
GROUP BY
    YEAR(fp.order_purchase_timestamp),
    dc.customer_state
ORDER BY
    ano, faturamento_estado DESC;


-- Conferir quantidade de meses por ano

SELECT
    YEAR(order_purchase_timestamp) AS ano,
    MONTH(order_purchase_timestamp) AS mes,
    COUNT(*) AS total_pedidos
FROM fato_pedidos
GROUP BY
    YEAR(order_purchase_timestamp),
    MONTH(order_purchase_timestamp)
ORDER BY
    ano,
    mes;

-- Análise 12: Percentual Médio do Frete por Estado e Ano
-- Objetivo: calcular quanto o frete representa, em média, no valor final dos pedidos,
--           segmentado por estado e por ano.
-- Fonte:
--  - fato_itens_pedido (order_id, valor_item, valor_frete)
--  - fato_pedidos (order_id, order_purchase_timestamp, customer_id)
--  - dim_clientes (customer_id, customer_state)
-- Observação:
--  1) O percentual é calculado por pedido como:
--     frete_pedido / (itens_pedido + frete_pedido)
--  2) Primeiro somamos valores de itens e frete por pedido (order_id),
--     depois calculamos o percentual do pedido,
--     e por fim tiramos a média por estado e ano.
--  3) Retorna valor em DECIMAL (ex.: 0,20 = 20%). Formatar como % no BI.

SELECT
    YEAR(fp.order_purchase_timestamp) AS ano,
    dc.customer_state,
    ROUND(AVG(x.percentual_frete_pedido), 4) AS percentual_medio_frete_estado
FROM (
    SELECT
        fi.order_id,
        (SUM(fi.valor_frete) / NULLIF(SUM(fi.valor_item) + SUM(fi.valor_frete), 0)) AS percentual_frete_pedido
    FROM fato_itens_pedido fi
    GROUP BY fi.order_id
) x
JOIN fato_pedidos fp
    ON x.order_id = fp.order_id
JOIN dim_clientes dc
    ON fp.customer_id = dc.customer_id
GROUP BY
    YEAR(fp.order_purchase_timestamp),
    dc.customer_state
ORDER BY
    ano,
    percentual_medio_frete_estado DESC;
    
    
    -- pedidos duplicados no staging
SELECT order_id, COUNT(*) qtd
FROM stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;



-- pagamentos duplicados no staging (mesmo valor repetido por erro de carga)
SELECT order_id, COUNT(*) qtd
FROM stg_order_payments
GROUP BY order_id
HAVING COUNT(*) > 1;
    
    
    
-- Análise 13: Base para Ticket Médio (média ponderada) por ano
-- Objetivo: disponibilizar os componentes necessários para calcular o ticket médio corretamente no BI,
--           permitindo agregação correta quando nenhum ano (ou múltiplos anos) estiver selecionado.
-- Fonte: tabela fato_pedidos
-- Componentes retornados:
--   - qtd_pedidos: quantidade de pedidos únicos no ano (COUNT DISTINCT order_id)
--   - faturamento_total: soma do valor total dos pedidos no ano (SUM(valor_total_pedido))

SELECT
    YEAR(order_purchase_timestamp) AS ano,
    COUNT(DISTINCT order_id) AS qtd_pedidos,
    ROUND(SUM(valor_total_pedido), 2) AS faturamento_total
FROM fato_pedidos
GROUP BY YEAR(order_purchase_timestamp)
ORDER BY ano;
