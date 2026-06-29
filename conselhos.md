# Conselhos Analiticos

Este documento registra o que o dataset `dataset_analitico_mei.xlsx` suporta para analise e RAG, sempre a partir do estado real do codigo.

## Secao 5 - Perguntas Suportadas e Limitacoes

### Suportadas no XLSX atual

- Receita por mes:
  suportada pela aba `Fato Vendas`.
  Use `Data Compra`, `ID Venda` e `Total do Pedido (R$)`.

- Ticket medio por periodo:
  suportada pela aba `Fato Vendas`.
  Formula: soma de `Total do Pedido (R$)` por venda unica dividida por quantidade de `ID Venda` distintos.

- Produtos mais vendidos por receita ou quantidade:
  suportada pela aba `Fato Vendas`.
  Para receita por produto, use `Subtotal Item (R$)`, nao `Total do Pedido (R$)`, para evitar duplicar frete e desconto em pedidos com multiplos itens.

- Margem bruta por produto ou categoria:
  suportada pela aba `Fato Vendas`.
  Formula por linha: `Lucro Bruto Item (R$) = (Preco Unitario Venda (R$) - Preco Unitario Custo (R$)) * Quantidade Item`.

- Perfil de clientes por estado, cidade e receita:
  suportada pela aba `Dimensão Clientes` combinada com `Fato Vendas`.

### Nao suportadas no XLSX atual

- Taxa de conversao por produto:
  nao suportada no dataset atual.
  Motivo: o schema real nao possui tabela/model `ProductView`, portanto nao ha eventos de visualizacao para comparar com vendas.
  Para suportar: criar `ProductView` com produto, usuario opcional, data/hora da visualizacao e origem do trafego; depois exportar uma aba `Visualizações` com granularidade de 1 linha por evento.

- Analise de satisfacao por reviews:
  nao suportada no dataset atual.
  Motivo: `Review` existe no Rails, mas nao e exportado pelo `XlsxExporter`; texto livre de comentario tambem exige decisao de limpeza e privacidade antes de entrar no XLSX.
  Para suportar: exportar aba `Avaliações` com `ID Produto`, `ID Cliente`, `Rating`, `Comentario Normalizado` e `Data Review`.

- Carrinho abandonado:
  nao suportado no dataset atual.
  Motivo: `Cart` e `CartItem` existem no Rails, mas nao sao exportados; carrinhos sao entidades operacionais e precisam de snapshot historico para analise confiavel.
  Para suportar: exportar aba `Carrinhos` com `ID Carrinho`, `ID Cliente`, `Status`, `Data Atualizacao`, `ID Produto`, `Quantidade`, `Subtotal Item (R$)`.

## Secao 6 - Versionamento

| Data | Mudanca |
|------|---------|
| 2026-06-29 | Registradas decisoes de exportacao para `ProductView`, `Review`, `Cart` e `CartItem`. O XLSX permanece com `Fato Vendas`, `Dimensão Produtos` e `Dimensão Clientes`. |
