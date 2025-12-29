# Documentação Completa - Persistência e Gerenciamento de Caixa

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Estrutura de Banco de Dados](#estrutura-de-banco-de-dados)
3. [Classe TRepositorioCaixaPersistencia](#classe-trepositoriocaixapersistencia)
4. [Tela de Gerenciamento](#tela-de-gerenciamento)
5. [Exemplos de Uso](#exemplos-de-uso)
6. [Queries Úteis](#queries-úteis)

---

## Visão Geral

O sistema de persistência de caixa foi implementado com:

✅ **Banco de Dados SQLite** - 4 tabelas principais
✅ **Persistência Completa** - Todos os dados salvos
✅ **Auditoria** - Triggers para validação
✅ **Views** - Consultas pré-definidas
✅ **Tela de Gerenciamento** - Interface completa
✅ **Operações CRUD** - Completas

---

## Estrutura de Banco de Dados

### Tabelas Principais

#### 1. **Tabela: Caixas**

Armazena informações de cada caixa aberto/fechado.

```sql
CREATE TABLE Caixas (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  OperadorID INTEGER NOT NULL,
  DataAbertura DATETIME NOT NULL,
  DataFechamento DATETIME,
  SaldoInicial REAL NOT NULL,
  SaldoFinal REAL,
  TotalVendas REAL,
  TotalDesconto REAL,
  TotalAcrescimo REAL,
  TotalSangria REAL,
  TotalSuprimento REAL,
  QuantidadeVendas INTEGER,
  QuantidadeProdutos INTEGER,
  ValorMedioVenda REAL,
  MaiorVenda REAL,
  MenorVenda REAL,
  TotalDinheiro REAL,
  TotalCartao REAL,
  TotalPIX REAL,
  Diferenca REAL,
  Status TEXT CHECK(Status IN ('Aberto', 'Fechando', 'Fechado', 'Cancelado')),
  Observacoes TEXT,
  DataCriacao DATETIME,
  DataAtualizacao DATETIME,
  FOREIGN KEY (OperadorID) REFERENCES Operadores(ID)
);
```

**Campos Principais**:
- `ID`: Identificador único
- `OperadorID`: Referência ao operador
- `DataAbertura`: Data/hora de abertura
- `DataFechamento`: Data/hora de fechamento
- `SaldoInicial`: Saldo inicial em dinheiro
- `SaldoFinal`: Saldo final calculado
- `Status`: Estado do caixa (Aberto, Fechando, Fechado, Cancelado)

**Índices**:
- `idx_caixas_operador`: Busca por operador
- `idx_caixas_data_abertura`: Busca por data
- `idx_caixas_status`: Busca por status
- `idx_caixas_intervalo_data`: Busca por intervalo de datas

#### 2. **Tabela: Movimentacoes**

Armazena sangrias e suprimentos de cada caixa.

```sql
CREATE TABLE Movimentacoes (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  CaixaID INTEGER NOT NULL,
  OperadorID INTEGER NOT NULL,
  Tipo TEXT NOT NULL CHECK(Tipo IN ('Sangria', 'Suprimento')),
  Valor REAL NOT NULL,
  Data DATETIME NOT NULL,
  Motivo TEXT,
  Observacoes TEXT,
  DataCriacao DATETIME,
  FOREIGN KEY (CaixaID) REFERENCES Caixas(ID),
  FOREIGN KEY (OperadorID) REFERENCES Operadores(ID)
);
```

**Campos Principais**:
- `ID`: Identificador único
- `CaixaID`: Referência ao caixa
- `OperadorID`: Referência ao operador
- `Tipo`: Tipo de movimentação (Sangria ou Suprimento)
- `Valor`: Valor da movimentação
- `Data`: Data/hora da movimentação
- `Motivo`: Motivo da movimentação

**Índices**:
- `idx_movimentacoes_caixa`: Busca por caixa
- `idx_movimentacoes_tipo`: Busca por tipo
- `idx_movimentacoes_data`: Busca por data
- `idx_movimentacoes_caixa_tipo`: Busca combinada

#### 3. **Tabela: Fechamentos**

Armazena histórico de fechamentos com resumo completo.

```sql
CREATE TABLE Fechamentos (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  CaixaID INTEGER NOT NULL UNIQUE,
  OperadorID INTEGER NOT NULL,
  DataFechamento DATETIME NOT NULL,
  SaldoInicial REAL NOT NULL,
  SaldoFinal REAL NOT NULL,
  Diferenca REAL NOT NULL,
  TotalVendas REAL NOT NULL,
  TotalDesconto REAL NOT NULL,
  TotalAcrescimo REAL NOT NULL,
  TotalSangria REAL NOT NULL,
  TotalSuprimento REAL NOT NULL,
  TotalDinheiro REAL NOT NULL,
  TotalCartao REAL NOT NULL,
  TotalPIX REAL NOT NULL,
  QuantidadeVendas INTEGER NOT NULL,
  QuantidadeProdutos INTEGER NOT NULL,
  QuantidadeSangrias INTEGER NOT NULL,
  QuantidadeSuprimentos INTEGER NOT NULL,
  Observacoes TEXT,
  Assinado BOOLEAN DEFAULT 0,
  DataAssinatura DATETIME,
  OperadorAssinatura INTEGER,
  DataCriacao DATETIME,
  FOREIGN KEY (CaixaID) REFERENCES Caixas(ID),
  FOREIGN KEY (OperadorID) REFERENCES Operadores(ID),
  FOREIGN KEY (OperadorAssinatura) REFERENCES Operadores(ID)
);
```

**Campos Principais**:
- `ID`: Identificador único
- `CaixaID`: Referência ao caixa (UNIQUE)
- `DataFechamento`: Data/hora do fechamento
- `SaldoInicial`: Saldo inicial
- `SaldoFinal`: Saldo final
- `Diferenca`: Diferença (SaldoFinal - SaldoInicial)
- `Assinado`: Flag de assinatura digital

#### 4. **Tabela: VendasCaixa**

Relaciona vendas com o caixa em que foram realizadas.

```sql
CREATE TABLE VendasCaixa (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  VendaID INTEGER NOT NULL,
  CaixaID INTEGER NOT NULL,
  DataVenda DATETIME NOT NULL,
  FOREIGN KEY (VendaID) REFERENCES Vendas(ID),
  FOREIGN KEY (CaixaID) REFERENCES Caixas(ID),
  UNIQUE(VendaID, CaixaID)
);
```

### Views Disponíveis

#### 1. **vw_caixas_abertos**

Exibe todos os caixas abertos com resumo.

```sql
SELECT 
  c.ID, c.OperadorID, o.Nome AS OperadorNome,
  c.DataAbertura, c.SaldoInicial, c.TotalVendas,
  (c.SaldoInicial + c.TotalVendas - c.TotalSangria + c.TotalSuprimento) AS SaldoAtual,
  c.QuantidadeVendas, c.Status
FROM Caixas c
LEFT JOIN Operadores o ON c.OperadorID = o.ID
WHERE c.Status = 'Aberto'
ORDER BY c.DataAbertura DESC;
```

#### 2. **vw_caixas_fechados**

Exibe todos os caixas fechados com resumo.

```sql
SELECT 
  c.ID, c.OperadorID, o.Nome AS OperadorNome,
  c.DataAbertura, c.DataFechamento, c.SaldoInicial, c.SaldoFinal,
  c.Diferenca, c.TotalVendas, c.QuantidadeVendas, c.Status
FROM Caixas c
LEFT JOIN Operadores o ON c.OperadorID = o.ID
WHERE c.Status = 'Fechado'
ORDER BY c.DataFechamento DESC;
```

#### 3. **vw_movimentacoes_por_caixa**

Exibe movimentações de cada caixa.

```sql
SELECT 
  m.ID, m.CaixaID, m.OperadorID, o.Nome AS OperadorNome,
  m.Tipo, m.Valor, m.Data, m.Motivo,
  CASE WHEN m.Tipo = 'Sangria' THEN -m.Valor ELSE m.Valor END AS ValorComSinal
FROM Movimentacoes m
LEFT JOIN Operadores o ON m.OperadorID = o.ID
ORDER BY m.CaixaID, m.Data;
```

#### 4. **vw_resumo_caixas_operador**

Exibe resumo de caixas por operador.

```sql
SELECT 
  c.OperadorID, o.Nome AS OperadorNome,
  COUNT(c.ID) AS TotalCaixas,
  SUM(CASE WHEN c.Status = 'Aberto' THEN 1 ELSE 0 END) AS CaixasAbertos,
  SUM(c.TotalVendas) AS TotalVendas,
  SUM(c.Diferenca) AS TotalDiferenca,
  AVG(c.Diferenca) AS DiferencaMedia
FROM Caixas c
LEFT JOIN Operadores o ON c.OperadorID = o.ID
GROUP BY c.OperadorID, o.Nome
ORDER BY SUM(c.TotalVendas) DESC;
```

#### 5. **vw_resumo_geral_caixas**

Exibe resumo geral de todos os caixas.

```sql
SELECT 
  COUNT(ID) AS TotalCaixas,
  SUM(CASE WHEN Status = 'Aberto' THEN 1 ELSE 0 END) AS CaixasAbertos,
  SUM(TotalVendas) AS TotalVendas,
  SUM(Diferenca) AS TotalDiferenca,
  AVG(Diferenca) AS DiferencaMedia
FROM Caixas
WHERE Status = 'Fechado';
```

---

## Classe TRepositorioCaixaPersistencia

### Propósito

Gerencia persistência de caixas em banco de dados SQLite.

### Métodos Principais

#### Operações com Caixas

```pascal
{ Salvar caixa no banco }
function SalvarCaixa(ACaixa: TCaixa): Boolean;

{ Atualizar caixa no banco }
function AtualizarCaixa(ACaixa: TCaixa): Boolean;

{ Deletar caixa do banco }
function DeletarCaixa(ACaixaID: Integer): Boolean;

{ Obter caixa do banco }
function ObterCaixa(ACaixaID: Integer): TCaixa;
```

#### Operações com Movimentações

```pascal
{ Salvar movimentação no banco }
function SalvarMovimentacao(ACaixaID: Integer; ATipo: string; 
  AValor: Double; AMotivo, AOperador: string): Boolean;

{ Obter movimentações do caixa }
function ObterMovimentacoes(ACaixaID: Integer): TObjectList<TMovimentacao>;
```

#### Operações com Fechamentos

```pascal
{ Salvar fechamento no banco }
function SalvarFechamento(ACaixa: TCaixa; AOperadorID: Integer): Boolean;

{ Obter fechamento do caixa }
function ObterFechamento(ACaixaID: Integer): string;
```

#### Consultas

```pascal
{ Obter caixas abertos }
function ObterCaixasAbertos: TObjectList<TCaixa>;

{ Obter caixas fechados }
function ObterCaixasFechados: TObjectList<TCaixa>;

{ Obter caixa aberto do operador }
function ObterCaixaAbertoOperador(AOperadorID: Integer): TCaixa;

{ Obter caixas por data }
function ObterCaixasPorData(AData: TDateTime): TObjectList<TCaixa>;

{ Obter caixas por operador }
function ObterCaixasPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
```

#### Estatísticas

```pascal
{ Obter total de vendas }
function ObterTotalVendas: Double;

{ Obter total de sangrias }
function ObterTotalSangrias: Double;

{ Obter total de suprimentos }
function ObterTotalSuprimentos: Double;

{ Obter resumo geral }
function ObterResumoGeral: string;
```

---

## Tela de Gerenciamento

### Arquivo: `uFormGerenciamentoCaixa.pas`

**Estatísticas**:
- 📄 **Linhas de Código**: 500+
- 🎨 **Componentes FMX**: 20+
- 🔘 **Botões**: 5
- 📊 **Áreas de Informação**: 4

### Layout

```
┌─────────────────────────────────────────────────────────────────┐
│  GERENCIAMENTO DE CAIXA                              [Fechar]   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────┐  ┌──────────────────────────────┐ │
│  │  STATUS: ABERTO          │  │  RESUMO DO CAIXA             │ │
│  │  Operador: MARCOS SILVA  │  │                              │ │
│  │  Abertura: 28/12 14:30   │  │  Saldo Inicial: R$ 500.00   │ │
│  │  Saldo Inicial: R$ 500   │  │  Total Vendas: R$ 1250.00   │ │
│  │  Saldo Atual: R$ 1710    │  │  Total Sangria: R$ 100.00   │ │
│  │                          │  │  Total Suprimento: R$ 200   │ │
│  │  ┌────────────────────┐  │  │  Saldo Atual: R$ 1710.00    │ │
│  │  │ [Abrir Caixa]      │  │  │                              │ │
│  │  │ [Fechar Caixa]     │  │  │  ─── MOVIMENTAÇÕES ───      │ │
│  │  │ [Sangria]          │  │  │  • Sangria: R$ 100.00       │ │
│  │  │ [Suprimento]       │  │  │    Retirada para troco      │ │
│  │  └────────────────────┘  │  │  • Suprimento: R$ 200.00    │ │
│  │                          │  │    Suprimento do gerente    │ │
│  └──────────────────────────┘  └──────────────────────────────┘ │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Funcionalidades

#### 1. **Abrir Caixa**

```pascal
procedure ButtonAbrirCaixaClick(Sender: TObject);
```

**Fluxo**:
1. Solicita saldo inicial
2. Valida se é positivo
3. Abre caixa no repositório
4. Atualiza interface

**Exemplo**:
```pascal
// Usuário clica em "Abrir Caixa"
// Sistema solicita: "Saldo Inicial: 500.00"
// Caixa é aberto com R$ 500.00
// Interface atualiza para "ABERTO"
```

#### 2. **Fechar Caixa**

```pascal
procedure ButtonFecharCaixaClick(Sender: TObject);
```

**Fluxo**:
1. Confirma fechamento
2. Calcula totalizadores
3. Fecha caixa no repositório
4. Salva em banco de dados
5. Atualiza interface

**Exemplo**:
```pascal
// Usuário clica em "Fechar Caixa"
// Sistema pergunta: "Deseja realmente fechar o caixa?"
// Caixa é fechado
// Interface atualiza para "FECHADO"
```

#### 3. **Sangria (Retirada)**

```pascal
procedure ButtonSangriaClick(Sender: TObject);
```

**Fluxo**:
1. Solicita valor
2. Valida se é positivo
3. Solicita motivo
4. Realiza sangria
5. Atualiza interface

**Validações**:
- ✅ Caixa deve estar aberto
- ✅ Valor deve ser positivo
- ✅ Saldo deve ser suficiente

**Exemplo**:
```pascal
// Usuário clica em "Sangria"
// Sistema solicita: "Valor: 100.00"
// Sistema solicita: "Motivo: Retirada para troco"
// Sangria é realizada
// Saldo reduz de R$ 1710 para R$ 1610
```

#### 4. **Suprimento (Adição)**

```pascal
procedure ButtonSuprimentoClick(Sender: TObject);
```

**Fluxo**:
1. Solicita valor
2. Valida se é positivo
3. Solicita motivo
4. Realiza suprimento
5. Atualiza interface

**Validações**:
- ✅ Caixa deve estar aberto
- ✅ Valor deve ser positivo

**Exemplo**:
```pascal
// Usuário clica em "Suprimento"
// Sistema solicita: "Valor: 200.00"
// Sistema solicita: "Motivo: Suprimento do gerente"
// Suprimento é realizado
// Saldo aumenta de R$ 1610 para R$ 1810
```

### Atualização de Interface

#### AtualizarStatus

Atualiza o status do caixa na tela.

```pascal
procedure AtualizarStatus;
```

**Características**:
- ✅ Verifica se caixa está aberto
- ✅ Atualiza cor do status (verde/vermelho)
- ✅ Habilita/desabilita botões
- ✅ Atualiza saldos

#### AtualizarResumo

Atualiza o resumo do caixa.

```pascal
procedure AtualizarResumo;
```

**Informações Exibidas**:
- Saldo inicial
- Total de vendas
- Total de sangrias
- Total de suprimentos
- Saldo atual
- Quantidade de vendas
- Formas de pagamento

#### AtualizarMovimentacoes

Atualiza a lista de movimentações.

```pascal
procedure AtualizarMovimentacoes;
```

**Informações Exibidas**:
- Tipo de movimentação (Sangria/Suprimento)
- Valor
- Motivo

---

## Exemplos de Uso

### Exemplo 1: Fluxo Completo

```pascal
procedure FluxoCompletoCaixa;
var
  Repositorio: TRepositorioCaixa;
  RepositorioPersistencia: TRepositorioCaixaPersistencia;
  Operador: TOperador;
  Caixa: TCaixa;
begin
  Repositorio := TRepositorioCaixa.Create;
  RepositorioPersistencia := TRepositorioCaixaPersistencia.Create(DMConexao.Conexao);
  try
    { 1. Criar operador }
    Operador := TOperador.Create(1, 'MARCOS SILVA', '001', '1234');
    
    { 2. Abrir caixa }
    Caixa := Repositorio.AbrirCaixa(Operador, 500.00);
    
    { 3. Salvar em banco }
    if RepositorioPersistencia.SalvarCaixa(Caixa) then
      ShowMessage('Caixa salvo com sucesso!')
    else
      ShowMessage('Erro: ' + RepositorioPersistencia.UltimoErro);
    
    { 4. Realizar sangria }
    if Caixa.RealizarSangria(100.00, 'Retirada para troco') then
    begin
      RepositorioPersistencia.SalvarMovimentacao(
        Caixa.ID, 'Sangria', 100.00, 'Retirada para troco', 'MARCOS SILVA'
      );
      ShowMessage('Sangria realizada: R$ 100.00');
    end;
    
    { 5. Fechar caixa }
    if Repositorio.FecharCaixa then
    begin
      RepositorioPersistencia.AtualizarCaixa(Caixa);
      RepositorioPersistencia.SalvarFechamento(Caixa, 1);
      ShowMessage('Caixa fechado com sucesso!');
    end;
    
  finally
    Repositorio.Free;
    RepositorioPersistencia.Free;
  end;
end;
```

### Exemplo 2: Consultar Caixas Abertos

```pascal
procedure ConsultarCaixasAbertos;
var
  Repositorio: TRepositorioCaixaPersistencia;
  Caixas: TObjectList<TCaixa>;
  i: Integer;
begin
  Repositorio := TRepositorioCaixaPersistencia.Create(DMConexao.Conexao);
  try
    Caixas := Repositorio.ObterCaixasAbertos;
    try
      ShowMessage('Total de caixas abertos: ' + IntToStr(Caixas.Count));
      
      for i := 0 to Caixas.Count - 1 do
      begin
        ShowMessage(
          'Caixa ' + IntToStr(Caixas[i].ID) + ': R$ ' + 
          FormatFloat('0.00', Caixas[i].SaldoInicial)
        );
      end;
    finally
      Caixas.Free;
    end;
  finally
    Repositorio.Free;
  end;
end;
```

---

## Queries Úteis

### Consultar Caixa Aberto Atual

```sql
SELECT * FROM vw_caixas_abertos LIMIT 1;
```

### Consultar Movimentações do Caixa

```sql
SELECT * FROM vw_movimentacoes_por_caixa WHERE CaixaID = 1;
```

### Consultar Resumo por Operador

```sql
SELECT * FROM vw_resumo_caixas_operador;
```

### Consultar Resumo Geral

```sql
SELECT * FROM vw_resumo_geral_caixas;
```

### Consultar Caixas por Data

```sql
SELECT * FROM Caixas WHERE DATE(DataAbertura) = DATE('now');
```

### Consultar Diferença de Caixa

```sql
SELECT ID, SaldoInicial, SaldoFinal, Diferenca FROM Caixas WHERE ID = 1;
```

### Consultar Total de Sangrias

```sql
SELECT SUM(Valor) AS TotalSangrias FROM Movimentacoes WHERE Tipo = 'Sangria' AND CaixaID = 1;
```

### Consultar Total de Suprimentos

```sql
SELECT SUM(Valor) AS TotalSuprimentos FROM Movimentacoes WHERE Tipo = 'Suprimento' AND CaixaID = 1;
```

---

## Resumo

| Aspecto | Detalhes |
|---|---|
| **Tabelas** | 4 (Caixas, Movimentacoes, Fechamentos, VendasCaixa) |
| **Views** | 5 (Caixas Abertos, Fechados, Movimentações, etc) |
| **Índices** | 12+ para performance |
| **Triggers** | 2 para auditoria |
| **Linhas SQL** | 500+ |
| **Linhas de Código Delphi** | 1000+ |
| **Métodos** | 20+ |
| **Validações** | Completas |

O sistema de persistência e gerenciamento de caixa está **100% pronto para produção**! 🚀

