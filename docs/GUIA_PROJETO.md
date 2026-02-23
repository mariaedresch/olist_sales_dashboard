# 🧭 Guia do Projeto — Olist Analytics

Este documento descreve como reproduzir o projeto, entender as análises e manter o repositório organizado, simulando um fluxo de trabalho de BI em ambiente corporativo.

---

## 1) Visão geral do fluxo (end-to-end)

**Fonte de dados → Modelagem → Análises SQL → Export CSV → Dashboard (Looker Studio)**

1. Carregar datasets (CSV) do Olist
2. Criar schema e tabelas no MySQL
3. Popular tabelas fato e dimensão
4. Rodar análises SQL (1 a 13)
5. Exportar resultados em CSV
6. Conectar CSVs no Looker Studio e montar o dashboard

---

## 2) Pré-requisitos (ambiente)

- MySQL 8+ (recomendado)
- Ferramenta para executar SQL (MySQL Workbench / DBeaver / CLI)
- Google Sheets (opcional, para organizar/exportar CSV)
- Looker Studio (para dashboard)

---

## 3) Estrutura do repositório (padrão)

- `sql/`  
  Scripts SQL do projeto (modelagem + análises)
- `data/`  
  Resultados das análises exportados em CSV (fontes do dashboard)
- `dashboard/`  
  Export do dashboard em PDF
- `docs/`  
  Documentação de apoio (este guia, decisões técnicas, etc.)

---

## 4) Modelagem e carga no MySQL

📌 Script de modelagem: **`sql/01_modelagem.sql`**  
Ele contempla:

- criação do banco `olist_analytics`
- tabelas dimensão: `dim_clientes`, `dim_produtos`, `dim_tempo`
- tabelas fato: `fato_pedidos`, `fato_itens_pedido`
- integridade referencial (FKs)
- tratamento de duplicidade em itens (consolidação por `order_id` + `product_id`)

### 4.1 Sobre duplicidade (confirmando o tratamento)
✅ Sim: houve tratamento de duplicidade na tabela de itens.

Foi criado um estágio consolidado:

- soma de `valor_item` e `valor_frete`
- agrupamento por `(order_id, product_id)`
- recriação da tabela consolidada como `fato_itens_pedido`

Isso evita distorções em métricas como:
- total de itens vendidos
- percentual de frete por pedido
- faturamento por categoria (itens)

---

## 5) Catálogo das análises (SQL → CSV → Uso no Dashboard)

Abaixo está o “mapa” do que cada análise entrega e como costuma ser usada no dashboard.

> Convenção:
> - **Saída esperada**: colunas do CSV
> - **Uso**: KPI / gráfico / filtro / suporte

### Análise 1 — Total de itens vendidos por ano
- **Objetivo**: volume total de itens vendidos por ano
- **Saída esperada**: `ano`, `total_itens_vendidos`
- **Uso**: KPI + contexto anual

### Análise 2 — Item mais vendido por estado
- **Objetivo**: categoria mais vendida por estado
- **Saída esperada**: `customer_state`, `product_category`, `quantidade_vendida`
- **Uso**: tabela / ranking regional

### Análise 3 — Top 10 categorias mais vendidas (geral)
- **Objetivo**: identificar categorias com maior volume de itens vendidos
- **Saída esperada**: `product_category`, `quantidade_vendida`
- **Uso**: gráfico Top 10

### Análise 4A — Ticket médio por ano
- **Objetivo**: ticket médio anual por pedido
- **Saída esperada**: `ano`, `ticket_medio`
- **Uso**: KPI por ano (quando 1 ano está selecionado)

### Análise 5 — Distribuição de pedidos por status
- **Objetivo**: percentual e volume de pedidos por status
- **Saída esperada**: `status`, `total_pedidos`, `percentual`
- **Uso**: gráfico de distribuição

### Análise 6 — Faturamento total por ano
- **Objetivo**: soma de `valor_total_pedido` por ano
- **Saída esperada**: `ano`, `faturamento_total`
- **Uso**: KPI + comparativo anual

### Análise 7 — Evolução do faturamento (ano/mês)
- **Objetivo**: sazonalidade e tendência de faturamento ao longo do tempo
- **Saída esperada**: `ano`, `mes`, `faturamento`
- **Uso**: gráfico de sazonalidade / barras por mês

### Análise 8 — Percentual médio do frete por ano
- **Objetivo**: participação média do frete no total do pedido (por ano)
- **Saída esperada**: `ano`, `percentual_medio_frete`
- **Uso**: KPI percentual + comparativo anual  
- **Observação**: retornar em decimal (ex.: `0.20`) e formatar como % no BI

### Análise 9 — Ticket médio por estado e ano
- **Objetivo**: ticket médio segmentado por estado e ano
- **Saída esperada**: `ano`, `customer_state`, `ticket_medio_estado`
- **Uso**: gráficos regionais com filtro de ano

### Análise 10 — Faturamento por categoria e ano
- **Objetivo**: faturamento por categoria (itens + frete), ano a ano
- **Saída esperada**: `ano`, `product_category`, `faturamento_categoria`
- **Uso**: gráfico comparativo / ranking

### Análise 11 — Faturamento por estado e ano
- **Objetivo**: faturamento anual por UF
- **Saída esperada**: `ano`, `customer_state`, `faturamento_estado`
- **Uso**: mapa / barras por UF (com ano)

### Análise 12 — Percentual médio do frete por estado e ano
- **Objetivo**: percentual médio do frete (por pedido) segmentado por UF e ano
- **Saída esperada**: `ano`, `customer_state`, `percentual_medio_frete_estado`
- **Uso**: gráfico percentual por estado (com filtro de ano)  
- **Observação**: retornar em decimal (ex.: `0.18`) e formatar como % no BI

### Análise 13 — Base de ticket médio ponderado (3 anos juntos)
- **Objetivo**: calcular ticket médio “real” quando múltiplos anos estão selecionados
- **Saída esperada (recomendado)**:  
  `faturamento_total` (soma), `qtd_pedidos` (count distinct), `ticket_medio_ponderado`
- **Uso**: KPI de Ticket Médio quando nenhum ano está selecionado (ou quando vários anos estão juntos)

---

## 6) Padrões de visualização e consistência (BI)

Para manter o dashboard consistente:

- **Moeda**: `R$` (pt-BR)
- **Porcentagem**: usar decimal no CSV (0.20) e formatar como % no Looker
- **Abreviações**:
  - “mil” para milhares
  - “mi” para milhões
  - (definir um padrão e manter em todas as páginas)

---

## 7) Troubleshooting rápido (problemas comuns)

### Ticket médio “estranho” com todos os anos
Isso acontece quando o BI tenta fazer **média de médias** (sem ponderação).  
✅ Solução adotada no projeto: usar a **Análise 13** para o valor consolidado.

### Percentual explodindo (2000% / 444900%)
Geralmente é **formatação incorreta**:
- Se o CSV já veio em % (ex.: 20) e o BI formata como %, vira 2000%.
- Padrão recomendado:
  - CSV em decimal (`0.20`)
  - Looker formatando como porcentagem

---

## 8) Referências do repositório

- Script de modelagem: `sql/01_modelagem.sql`
- CSVs das análises: `data/`
- Dashboard exportado: `dashboard/dashboard_olist.pdf`

---

## 9) Autoria
Maria Eduarda — Projeto de Análise de Dados  
Simulação de ambiente corporativo (BI + SQL + Looker Studio)
