# Documentação Completa da Estrutura de Banco de Dados - PDV Seenaxon

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Tabelas Principais](#tabelas-principais)
3. [Tabelas de Auditoria](#tabelas-de-auditoria)
4. [Tabelas de Conformidade](#tabelas-de-conformidade)
5. [Tabelas de Sincronização](#tabelas-de-sincronização)
6. [Views](#views)
7. [Índices](#índices)
8. [Triggers](#triggers)
9. [Diagrama ER](#diagrama-er)
10. [Exemplos de Uso](#exemplos-de-uso)

---

## Visão Geral

O banco de dados do PDV Seenaxon foi projetado com foco em:

- ✅ **Segurança**: Criptografia, auditoria completa, conformidade LGPD
- ✅ **Performance**: Índices otimizados, queries eficientes
- ✅ **Integridade**: Constraints, foreign keys, triggers
- ✅ **Rastreabilidade**: Logging detalhado de todas as operações
- ✅ **Conformidade**: LGPD, NFe, regulamentações fiscais

### Estatísticas

| Métrica | Valor |
|---------|-------|
| **Total de Tabelas** | 16 |
| **Tabelas Principais** | 5 |
| **Tabelas de Auditoria** | 4 |
| **Tabelas de Conformidade** | 2 |
| **Tabelas de Sincronização** | 3 |
| **Tabelas de Configuração** | 1 |
| **Total de Índices** | 40+ |
| **Total de Views** | 4 |
| **Total de Triggers** | 3 |

---

## Tabelas Principais

### 1. Operadores

**Descrição**: Armazena informações dos operadores do PDV

**Campos**:

| Campo | Tipo | Descrição | Constraints |
|-------|------|-----------|-------------|
| OperadorID | INTEGER | ID único do operador | PRIMARY KEY, AUTOINCREMENT |
| Nome | TEXT | Nome completo | NOT NULL, MIN 3 caracteres |
| Matricula | TEXT | Matrícula única | UNIQUE, NOT NULL, MIN 3 caracteres |
| SenhaHash | TEXT | Hash PBKDF2 (salt:hash) | NOT NULL |
| Email | TEXT | E-mail do operador | |
| Telefone | TEXT | Telefone de contato | |
| Ativo | BOOLEAN | Status do operador | DEFAULT 1 |
| DataCadastro | DATETIME | Data de cadastro | DEFAULT CURRENT_TIMESTAMP |
| DataUltimoAcesso | DATETIME | Último acesso ao sistema | |
| TentativasLoginFalhadas | INTEGER | Contador de tentativas | DEFAULT 0 |
| BloqueadoAte | DATETIME | Bloqueio temporário (força bruta) | |

**Índices**:
- `idx_operadores_matricula` - Busca por matrícula
- `idx_operadores_ativo` - Filtro por status
- `idx_operadores_email` - Busca por e-mail

**Exemplo de Uso**:

```sql
-- Buscar operador por matrícula
SELECT * FROM Operadores WHERE Matricula = '001';

-- Listar operadores ativos
SELECT * FROM Operadores WHERE Ativo = 1;

-- Contar tentativas de login falhadas
SELECT COUNT(*) FROM LogAcessoOperador 
WHERE OperadorID = 1 AND Sucesso = 0 
AND DataHora > datetime('now', '-1 hour');
```

---

### 2. Produtos

**Descrição**: Catálogo de produtos disponíveis para venda

**Campos**:

| Campo | Tipo | Descrição | Constraints |
|-------|------|-----------|-------------|
| ProdutoID | INTEGER | ID único do produto | PRIMARY KEY, AUTOINCREMENT |
| CodigoBarras | TEXT | Código de barras | UNIQUE |
| Nome | TEXT | Nome do produto | NOT NULL, MIN 2 caracteres |
| Descricao | TEXT | Descrição detalhada | |
| Categoria | TEXT | Categoria do produto | |
| Preco | REAL | Preço de venda | NOT NULL, >= 0 |
| PrecoCusto | REAL | Preço de custo | >= 0 |
| QuantidadeEstoque | INTEGER | Quantidade em estoque | DEFAULT 0 |
| QuantidadeMinima | INTEGER | Quantidade mínima | DEFAULT 10 |
| Ativo | BOOLEAN | Status do produto | DEFAULT 1 |
| ImagemPath | TEXT | Caminho da imagem | |
| DataCadastro | DATETIME | Data de cadastro | DEFAULT CURRENT_TIMESTAMP |
| DataAtualizacao | DATETIME | Data de última atualização | |

**Índices**:
- `idx_produtos_nome` - Busca por nome
- `idx_produtos_categoria` - Filtro por categoria
- `idx_produtos_codigo_barras` - Busca por código de barras
- `idx_produtos_ativo` - Filtro por status

**Exemplo de Uso**:

```sql
-- Buscar produto por código de barras
SELECT * FROM Produtos WHERE CodigoBarras = '7891234567890';

-- Listar produtos com baixo estoque
SELECT * FROM Produtos 
WHERE QuantidadeEstoque < QuantidadeMinima AND Ativo = 1;

-- Calcular margem de lucro
SELECT Nome, Preco, PrecoCusto, 
       ((Preco - PrecoCusto) / PrecoCusto * 100) as MargemPercentual
FROM Produtos WHERE Ativo = 1;
```

---

### 3. Caixas

**Descrição**: Registro de abertura e fechamento de caixas

**Campos**:

| Campo | Tipo | Descrição | Constraints |
|-------|------|-----------|-------------|
| CaixaID | INTEGER | ID único do caixa | PRIMARY KEY, AUTOINCREMENT |
| OperadorID | INTEGER | Operador responsável | NOT NULL, FK |
| NumeroSerie | TEXT | Número de série do ECF | |
| SaldoInicial | REAL | Saldo inicial | DEFAULT 0, >= 0 |
| SaldoFinal | REAL | Saldo final | |
| DataAbertura | DATETIME | Data/hora de abertura | DEFAULT CURRENT_TIMESTAMP |
| DataFechamento | DATETIME | Data/hora de fechamento | |
| Status | TEXT | Status do caixa | DEFAULT 'ABERTO' |
| Observacoes | TEXT | Observações adicionais | |

**Status Possíveis**: ABERTO, FECHADO, CANCELADO

**Índices**:
- `idx_caixas_operador` - Busca por operador
- `idx_caixas_data_abertura` - Filtro por data
- `idx_caixas_status` - Filtro por status
- `idx_caixas_operador_data` - Busca composta

**Exemplo de Uso**:

```sql
-- Buscar caixa aberto do operador
SELECT * FROM Caixas 
WHERE OperadorID = 1 AND Status = 'ABERTO';

-- Listar caixas fechados de um período
SELECT * FROM Caixas 
WHERE Status = 'FECHADO' 
AND DataFechamento BETWEEN '2025-12-01' AND '2025-12-31';

-- Calcular diferença de caixa
SELECT CaixaID, SaldoInicial, SaldoFinal, 
       (SaldoFinal - SaldoInicial) as Diferenca
FROM Caixas WHERE Status = 'FECHADO';
```

---

### 4. Vendas

**Descrição**: Registro de todas as vendas realizadas

**Campos**:

| Campo | Tipo | Descrição | Constraints |
|-------|------|-----------|-------------|
| VendaID | INTEGER | ID único da venda | PRIMARY KEY, AUTOINCREMENT |
| CaixaID | INTEGER | Caixa da venda | NOT NULL, FK |
| OperadorID | INTEGER | Operador da venda | NOT NULL, FK |
| Subtotal | REAL | Subtotal sem descontos | NOT NULL, >= 0 |
| Desconto | REAL | Desconto em valor | DEFAULT 0 |
| DescontoPercentual | REAL | Desconto em percentual | DEFAULT 0 |
| Acrescimo | REAL | Acréscimo em valor | DEFAULT 0 |
| AcrescimoPercentual | REAL | Acréscimo em percentual | DEFAULT 0 |
| Total | REAL | Total final | NOT NULL, >= 0 |
| FormaPagamento | TEXT | Forma de pagamento | DINHEIRO/CARTAO/PIX |
| Troco | REAL | Valor do troco | DEFAULT 0 |
| ChaveNFe | TEXT | Chave de acesso da NFe | |
| StatusNFe | TEXT | Status da NFe | DEFAULT 'PENDENTE' |
| DataVenda | DATETIME | Data/hora da venda | DEFAULT CURRENT_TIMESTAMP |
| Observacoes | TEXT | Observações adicionais | |

**Formas de Pagamento**: DINHEIRO, CARTAO, PIX

**Status NFe**: PENDENTE, AUTORIZADA, CANCELADA

**Índices**:
- `idx_vendas_caixa` - Busca por caixa
- `idx_vendas_operador` - Busca por operador
- `idx_vendas_data` - Filtro por data
- `idx_vendas_forma_pagamento` - Filtro por forma
- `idx_vendas_chave_nfe` - Busca por chave NFe
- `idx_vendas_operador_data` - Busca composta
- `idx_vendas_caixa_data` - Busca composta

**Exemplo de Uso**:

```sql
-- Vendas do dia
SELECT * FROM Vendas 
WHERE DATE(DataVenda) = DATE('now');

-- Total de vendas por forma de pagamento
SELECT FormaPagamento, COUNT(*) as Quantidade, SUM(Total) as Total
FROM Vendas 
WHERE DATE(DataVenda) = DATE('now')
GROUP BY FormaPagamento;

-- Vendas com desconto
SELECT * FROM Vendas 
WHERE Desconto > 0 OR DescontoPercentual > 0
ORDER BY DataVenda DESC;
```

---

### 5. ItensVenda

**Descrição**: Itens individuais de cada venda

**Campos**:

| Campo | Tipo | Descrição | Constraints |
|-------|------|-----------|-------------|
| ItemID | INTEGER | ID único do item | PRIMARY KEY, AUTOINCREMENT |
| VendaID | INTEGER | Venda do item | NOT NULL, FK |
| ProdutoID | INTEGER | Produto do item | NOT NULL, FK |
| Quantidade | REAL | Quantidade vendida | NOT NULL, > 0 |
| ValorUnitario | REAL | Valor unitário | NOT NULL, >= 0 |
| Desconto | REAL | Desconto em valor | DEFAULT 0 |
| DescontoPercentual | REAL | Desconto em percentual | DEFAULT 0 |
| Acrescimo | REAL | Acréscimo em valor | DEFAULT 0 |
| AcrescimoPercentual | REAL | Acréscimo em percentual | DEFAULT 0 |
| Total | REAL | Total do item | NOT NULL, >= 0 |

**Índices**:
- `idx_itens_venda` - Busca por venda
- `idx_itens_produto` - Busca por produto

**Exemplo de Uso**:

```sql
-- Itens de uma venda
SELECT iv.*, p.Nome 
FROM ItensVenda iv
JOIN Produtos p ON iv.ProdutoID = p.ProdutoID
WHERE iv.VendaID = 123;

-- Produtos mais vendidos
SELECT p.Nome, SUM(iv.Quantidade) as QuantidadeTotal, SUM(iv.Total) as TotalVendido
FROM ItensVenda iv
JOIN Produtos p ON iv.ProdutoID = p.ProdutoID
WHERE DATE(iv.VendaID) >= DATE('now', '-30 days')
GROUP BY p.ProdutoID, p.Nome
ORDER BY QuantidadeTotal DESC
LIMIT 10;
```

---

## Tabelas de Auditoria

### 6. LogAuditoria (CRÍTICA)

**Descrição**: Registro detalhado de todas as operações críticas

**Campos**:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| LogID | INTEGER | ID único do log |
| DataHora | DATETIME | Data/hora da operação |
| OperadorID | INTEGER | Operador que realizou |
| TipoOperacao | TEXT | Tipo de operação (LOGIN, VENDA, etc) |
| Tabela | TEXT | Tabela afetada |
| RegistroID | INTEGER | ID do registro afetado |
| AcaoRealizada | TEXT | Ação (INSERT, UPDATE, DELETE) |
| DadosAntigos | TEXT | Dados anteriores (JSON) |
| DadosNovos | TEXT | Dados novos (JSON) |
| Detalhes | TEXT | Detalhes adicionais |
| Sucesso | BOOLEAN | Se a operação foi bem-sucedida |
| MensagemErro | TEXT | Mensagem de erro (se houver) |
| EnderecoIP | TEXT | IP do cliente |
| UserAgent | TEXT | User Agent do navegador |

**Tipos de Operação**:
- LOGIN, LOGOUT, ACESSO_NEGADO
- VENDA, DESCONTO, ACRESCIMO
- ABERTURA_CAIXA, FECHAMENTO_CAIXA
- ALTERACAO_PRODUTO, ALTERACAO_OPERADOR
- CANCELAMENTO_VENDA, ERRO_SISTEMA

**Índices**:
- `idx_log_data_hora` - Busca por data/hora
- `idx_log_operador` - Busca por operador
- `idx_log_tipo_operacao` - Busca por tipo
- `idx_log_tabela` - Busca por tabela
- `idx_log_operador_data` - Busca composta
- `idx_log_tipo_data` - Busca composta

**Exemplo de Uso**:

```sql
-- Auditoria de um operador
SELECT * FROM LogAuditoria 
WHERE OperadorID = 1 
AND DataHora >= datetime('now', '-7 days')
ORDER BY DataHora DESC;

-- Operações que falharam
SELECT * FROM LogAuditoria 
WHERE Sucesso = 0
ORDER BY DataHora DESC
LIMIT 100;

-- Resumo de operações por tipo
SELECT TipoOperacao, COUNT(*) as Quantidade
FROM LogAuditoria 
WHERE DATE(DataHora) = DATE('now')
GROUP BY TipoOperacao;
```

---

### 7. LogAcessoOperador

**Descrição**: Registro de tentativas de login (sucesso e falha)

**Campos**:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| AcessoID | INTEGER | ID único |
| OperadorID | INTEGER | ID do operador |
| Matricula | TEXT | Matrícula utilizada |
| DataHora | DATETIME | Data/hora da tentativa |
| Sucesso | BOOLEAN | Se foi bem-sucedido |
| Motivo | TEXT | Motivo (SENHA_INCORRETA, etc) |
| EnderecoIP | TEXT | IP do cliente |
| UserAgent | TEXT | User Agent |

**Exemplo de Uso**:

```sql
-- Tentativas de login falhadas do operador
SELECT * FROM LogAcessoOperador 
WHERE OperadorID = 1 AND Sucesso = 0
ORDER BY DataHora DESC;

-- Detectar força bruta
SELECT Matricula, COUNT(*) as Tentativas
FROM LogAcessoOperador 
WHERE Sucesso = 0 
AND DataHora >= datetime('now', '-1 hour')
GROUP BY Matricula
HAVING COUNT(*) > 3;
```

---

### 8. LogErroSistema

**Descrição**: Registro de erros e exceções do sistema

**Campos**:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| ErroID | INTEGER | ID único |
| DataHora | DATETIME | Data/hora do erro |
| OperadorID | INTEGER | Operador afetado |
| Modulo | TEXT | Módulo onde ocorreu |
| Funcao | TEXT | Função onde ocorreu |
| Mensagem | TEXT | Mensagem de erro |
| StackTrace | TEXT | Rastreamento de pilha |
| Severidade | TEXT | INFO, AVISO, ERRO, CRITICO |
| Resolvido | BOOLEAN | Se foi resolvido |
| DataResolucao | DATETIME | Data de resolução |
| Observacoes | TEXT | Observações |

**Severidades**: INFO, AVISO, ERRO, CRITICO

---

### 9. LogAlteracaoDados

**Descrição**: Rastreamento detalhado de alterações em dados sensíveis

**Campos**:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| AlteracaoID | INTEGER | ID único |
| DataHora | DATETIME | Data/hora da alteração |
| OperadorID | INTEGER | Operador que alterou |
| Tabela | TEXT | Tabela alterada |
| RegistroID | INTEGER | ID do registro |
| Campo | TEXT | Campo alterado |
| ValorAntigo | TEXT | Valor anterior |
| ValorNovo | TEXT | Valor novo |
| Motivo | TEXT | Motivo da alteração |

---

## Tabelas de Conformidade

### 10. ConsentimentoLGPD

**Descrição**: Registro de consentimento de clientes conforme LGPD

**Campos**:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| ConsentimentoID | INTEGER | ID único |
| ClienteID | INTEGER | Cliente |
| DataConsentimento | DATETIME | Data do consentimento |
| DataRevogacao | DATETIME | Data de revogação |
| Consentimento | BOOLEAN | Consentiu ou não |
| TipoConsentimento | TEXT | MARKETING, DADOS_PESSOAIS |
| Versao | TEXT | Versão da política |

---

### 11. SolicitacaoLGPD

**Descrição**: Registro de solicitações de acesso/exclusão de dados (LGPD)

**Campos**:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| SolicitacaoID | INTEGER | ID único |
| ClienteID | INTEGER | Cliente |
| DataSolicitacao | DATETIME | Data da solicitação |
| TipoSolicitacao | TEXT | ACESSO, EXCLUSAO, PORTABILIDADE, CORRECAO |
| Status | TEXT | PENDENTE, PROCESSANDO, CONCLUIDA, RECUSADA |
| DataProcessamento | DATETIME | Data de processamento |
| Resposta | TEXT | Resposta ou motivo |

---

## Tabelas de Sincronização

### 12. SincronizacaoServidor

**Descrição**: Registro de sincronizações com servidor central

### 13. VendasPendentes

**Descrição**: Vendas não sincronizadas com servidor

### 14. HistoricoBackup

**Descrição**: Registro de backups realizados

---

## Views

### VendasPorOperador

Resumo de vendas por operador

```sql
SELECT 
  o.OperadorID,
  o.Nome,
  o.Matricula,
  COUNT(v.VendaID) as QuantidadeVendas,
  SUM(v.Total) as TotalVendas,
  AVG(v.Total) as TicketMedio
FROM Operadores o
LEFT JOIN Vendas v ON o.OperadorID = v.OperadorID
WHERE o.Ativo = 1
GROUP BY o.OperadorID, o.Nome, o.Matricula;
```

### VendasPorFormaPagamento

Resumo de vendas por forma de pagamento

### ProdutosComBaixoEstoque

Produtos com estoque abaixo do mínimo

### RelatorioAuditoria

Resumo de operações auditadas

---

## Índices

Total de **40+ índices** para otimizar performance

### Índices Críticos

1. **idx_operadores_matricula** - Busca rápida de operador
2. **idx_vendas_data** - Filtro por período
3. **idx_vendas_operador_data** - Relatório de vendas
4. **idx_log_data_hora** - Auditoria por período
5. **idx_log_operador_data** - Auditoria por operador

---

## Triggers

### trg_auditoria_vendas_insert

Registra automaticamente quando uma venda é inserida

### trg_auditoria_operadores_update

Registra automaticamente quando um operador é alterado

### trg_auditoria_produtos_update

Registra automaticamente quando um produto é alterado

---

## Diagrama ER

```
┌─────────────────┐
│   Operadores    │
├─────────────────┤
│ OperadorID (PK) │
│ Nome            │
│ Matricula (U)   │
│ SenhaHash       │
│ Ativo           │
└────────┬────────┘
         │
         │ 1:N
         │
    ┌────┴──────────────────────────────┐
    │                                   │
    ▼                                   ▼
┌─────────────┐                  ┌────────────┐
│   Caixas    │                  │  LogAudit  │
├─────────────┤                  ├────────────┤
│ CaixaID(PK) │                  │ LogID (PK) │
│ OperadorID  │                  │ OperadorID │
│ SaldoInicial│                  │ Operacao   │
│ Status      │                  │ DataHora   │
└────────┬────┘                  └────────────┘
         │
         │ 1:N
         │
         ▼
    ┌─────────────┐
    │   Vendas    │
    ├─────────────┤
    │ VendaID(PK) │
    │ CaixaID(FK) │
    │ OperadorID  │
    │ Total       │
    └────────┬────┘
             │
             │ 1:N
             │
             ▼
    ┌──────────────────┐
    │   ItensVenda     │
    ├──────────────────┤
    │ ItemID (PK)      │
    │ VendaID (FK)     │
    │ ProdutoID (FK)   │
    │ Quantidade       │
    └──────────────────┘
             │
             │ N:1
             │
             ▼
    ┌──────────────────┐
    │   Produtos       │
    ├──────────────────┤
    │ ProdutoID (PK)   │
    │ Nome             │
    │ Preco            │
    │ Estoque          │
    └──────────────────┘
```

---

## Exemplos de Uso

### Exemplo 1: Registrar Login

```sql
-- Inserir log de login bem-sucedido
INSERT INTO LogAcessoOperador (OperadorID, Matricula, Sucesso, Motivo)
VALUES (1, '001', 1, NULL);

-- Inserir log de auditoria
INSERT INTO LogAuditoria (OperadorID, TipoOperacao, Detalhes, Sucesso)
VALUES (1, 'LOGIN', 'Login bem-sucedido', 1);
```

### Exemplo 2: Registrar Venda

```sql
-- Inserir venda
INSERT INTO Vendas (CaixaID, OperadorID, Subtotal, Total, FormaPagamento)
VALUES (1, 1, 100.00, 100.00, 'DINHEIRO');

-- Inserir itens da venda
INSERT INTO ItensVenda (VendaID, ProdutoID, Quantidade, ValorUnitario, Total)
VALUES (1, 1, 2, 50.00, 100.00);

-- Registrar em auditoria (automático via trigger)
```

### Exemplo 3: Relatório de Vendas do Dia

```sql
SELECT 
  o.Nome as Operador,
  COUNT(v.VendaID) as QuantidadeVendas,
  SUM(v.Total) as TotalVendas,
  AVG(v.Total) as TicketMedio,
  v.FormaPagamento
FROM Vendas v
JOIN Operadores o ON v.OperadorID = o.OperadorID
WHERE DATE(v.DataVenda) = DATE('now')
GROUP BY o.OperadorID, o.Nome, v.FormaPagamento
ORDER BY TotalVendas DESC;
```

### Exemplo 4: Auditoria de Operações

```sql
-- Listar todas as operações do operador 1 nos últimos 7 dias
SELECT 
  DataHora,
  TipoOperacao,
  Tabela,
  AcaoRealizada,
  Sucesso
FROM LogAuditoria
WHERE OperadorID = 1
AND DataHora >= datetime('now', '-7 days')
ORDER BY DataHora DESC;
```

---

## Boas Práticas

1. **Backup Regular**: Fazer backup do banco de dados diariamente
2. **Monitoramento**: Monitorar tamanho do banco e performance
3. **Limpeza**: Arquivar logs antigos periodicamente
4. **Validação**: Validar integridade referencial regularmente
5. **Segurança**: Manter senhas criptografadas com PBKDF2
6. **Auditoria**: Revisar logs de auditoria regularmente

---

## Conclusão

A estrutura de banco de dados foi projetada para ser robusta, segura e escalável, atendendo aos requisitos de um PDV profissional com conformidade regulatória completa.

