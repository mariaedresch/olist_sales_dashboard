# 📊 Olist Analytics | Performance de Vendas e Indicadores Estratégicos

## 📌 Visão Geral

Este projeto simula uma iniciativa de Business Intelligence aplicada a um marketplace brasileiro de e-commerce (Olist).

O objetivo foi estruturar uma base de dados relacional, desenvolver análises estratégicas em SQL e construir um dashboard executivo no Looker Studio para apoiar a tomada de decisão baseada em dados.

O projeto foi desenvolvido com foco em visão analítica, organização estrutural e clareza estratégica, simulando um cenário real de atuação em ambiente corporativo.

---

## 🎯 Objetivos Estratégicos

O projeto foi desenvolvido com os seguintes objetivos:

- Estruturar um modelo de dados confiável e escalável  
- Consolidar informações de pedidos, clientes e produtos  
- Criar indicadores-chave de desempenho (KPIs)  
- Analisar o comportamento de faturamento ao longo do tempo  
- Avaliar variações regionais de desempenho  
- Identificar impacto do frete na composição da receita  
- Construir um dashboard executivo para suporte gerencial  

---

## 🏗 Arquitetura e Modelagem de Dados

A modelagem foi construída seguindo abordagem dimensional (modelo estrela), com separação entre tabelas fato e tabelas dimensão.

### 🔹 Tabelas Fato
- `fato_pedidos`
- `fato_itens_pedido`

### 🔹 Tabelas Dimensão
- `dim_clientes`
- `dim_produtos`
- `dim_tempo`

A modelagem priorizou:

- Integridade referencial  
- Clareza nas relações  
- Facilidade de manutenção  
- Base adequada para análises agregadas  

📂 Script de modelagem disponível em:  
👉 [Visualizar Script de Modelagem](sql/01_modelagem.sql)

---

## 🔎 Metodologia Analítica

As análises foram desenvolvidas em SQL utilizando agregações, funções de data e cálculos derivados.

Cada consulta foi construída com objetivo específico de negócio, sendo os resultados exportados em CSV para construção do dashboard.

### Principais análises realizadas:

1. Total de itens vendidos por ano  
2. Produto mais vendido por estado  
3. Top 10 categorias mais vendidas  
4. Ticket médio por ano  
5. Distribuição de pedidos por status  
6. Faturamento total por ano  
7. Evolução do faturamento ao longo do tempo  
8. Percentual médio de frete  
9. Ticket médio por estado e ano  
10. Faturamento por categoria e ano  
11. Faturamento por estado e ano  
12. Percentual de frete por estado  
13. Base para cálculo de ticket médio ponderado  

📂 Resultados disponíveis em:  
👉 [Acessar Arquivos de Resultados das Análises](data/)

---

## 📌 Decisões Técnicas Relevantes

- O ticket médio foi definido como:  
  **Soma do valor total dos pedidos ÷ quantidade de pedidos distintos.**

- Para evitar distorções quando múltiplos anos estão selecionados no dashboard, foi criada uma base específica para cálculo ponderado do ticket médio.

- Os indicadores foram padronizados quanto à formatação monetária e agregação para manter consistência visual e analítica.

- A organização dos arquivos foi estruturada para facilitar reprodutibilidade e entendimento por outros analistas.

---

## 📈 Dashboard Executivo

O dashboard foi desenvolvido no Looker Studio com foco em visão gerencial e leitura estratégica.

### Indicadores apresentados:

- Faturamento Total  
- Total de Itens Vendidos  
- Ticket Médio  
- Percentual Médio de Frete  
- Sazonalidade de Vendas  
- Faturamento por Estado  
- Faturamento por Categoria  

📄 Visualização do dashboard:  
🌐 Dashboard Interativo (Looker Studio):
👉 [Acessar Dashboard Online](https://lookerstudio.google.com/reporting/03da6c27-58d8-4c10-8877-a91ee1d39aa8)

📄 Versão estática em PDF:
👉 [Visualizar Dashboard Executivo (PDF)](dashboard/dashboard_olist.pdf)
---

## 🧠 Principais Insights Estratégicos

- Crescimento consistente de faturamento entre 2016 e 2018  
- Concentração significativa de receita em determinados estados  
- Variação relevante do ticket médio entre regiões  
- Percentual de frete representa parcela relevante do valor total do pedido  
- Algumas categorias demonstram performance superior de forma recorrente  

---

## 🛠 Tecnologias Utilizadas

- MySQL  
- SQL (Modelagem e Análises)  
- Google Sheets  
- Looker Studio  
- GitHub  

---

## 📂 Estrutura do Repositório

```
├── dashboard/
│   └── dashboard_olist.pdf
│
├── data/
│   └── Arquivos CSV com resultados das análises
│
├── sql/
│   └── 01_modelagem.sql
│
└── README.md
```

---

## 👩‍💻 Autora

Maria Eduarda  
Projeto de Análise de Dados  
Simulação de Ambiente Corporativo  
