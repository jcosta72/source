# Gerenciamento Completo de Caixa

## 1️⃣ Classe TCaixa Completa com Gerenciamento de Ciclo de Vida

### Arquivo: `uCaixa.pas`

**Novos Tipos Enumerados**:
```pascal
type
  TStatusCaixa = (scFechado, scAberto, scFechando);
```

**Novas Propriedades**:
```pascal
property Status: TStatusCaixa read FStatus;
property TotalDesconto: Double read FTotalDesconto;
property TotalAcrescimo: Double read FTotalAcrescimo;
property QuantidadeVendas: Integer read FQuantidadeVendas;
property QuantidadeProdutos: Integer read FQuantidadeProdutos;
property ValorMedioVenda: Double read FValorMedioVenda;
property MaiorVenda: Double read FMaiorVenda;
property MenorVenda: Double read FMenorVenda;
property TotalDinheiro: Double read FTotalDinheiro;
property TotalCartao: Double read FTotalCartao;
property TotalPIX: Double read FTotalPIX;
property Diferenca: Double read FDiferenca;
```

**Novos Métodos de Operação**:
```pascal
procedure Cancelar;
procedure RemoverVenda(AIndex: Integer);
```

**Novos Métodos de Consulta**:
```pascal
function GetVenda(AIndex: Integer): TVenda;
function ObterVendasPorData(AData: TDateTime): TObjectList<TVenda>;
function ObterVendasPorFormaPagamento(AForma: Integer): TObjectList<TVenda>;
function ObterResumoVendas: string;
function ObterDetalhesVendas: string;
```

**Novos Métodos de Validação**:
```pascal
function PodeFechar: Boolean;
function EstaAberto: Boolean;
function EstaFechado: Boolean;
```

### Ciclo de Vida do Caixa

```
1. Criar Caixa (scFechado)
   ↓
2. Abrir Caixa (scAberto)
   ├─ Define data/hora de abertura
   ├─ Define saldo inicial
   ├─ Limpa lista de vendas
   ↓
3. Adicionar Vendas (scAberto)
   ├─ AdicionarVenda()
   ├─ RemoverVenda()
   ├─ Calcula totalizadores automaticamente
   ↓
4. Validar Fechamento
   ├─ PodeFechar() → True
   ├─ Deve ter pelo menos 1 venda
   ↓
5. Fechar Caixa (scFechando → scFechado)
   ├─ Calcula totalizadores finais
   ├─ Define data/hora de fechamento
   ├─ Calcula diferença
   ↓
6. Histórico Registrado
```

### Totalizadores Calculados Automaticamente

✅ **Totalizadores Gerais**
- Total de vendas
- Total de descontos
- Total de acréscimos
- Quantidade de vendas
- Quantidade de produtos

✅ **Estatísticas**
- Valor médio por venda
- Maior venda
- Menor venda

✅ **Por Forma de Pagamento**
- Total em dinheiro
- Total em cartão
- Total em PIX

✅ **Diferença**
- Diferença entre saldo final esperado e real

### Exemplo de Uso

```pascal
var
  Operador: TOperador;
  Caixa: TCaixa;
  Venda: TVenda;
begin
  // Criar operador
  Operador := TOperador.Create(1, 'JOÃO SILVA', '001', '1234');
  
  // Criar e abrir caixa
  Caixa := TCaixa.Create(1, Operador, 100.00);
  Caixa.Abrir(100.00);
  
  // Criar e adicionar venda
  Venda := TVenda.Create;
  Venda.OperadorID := Operador.ID;
  // ... adicionar itens à venda ...
  Venda.Finalizar(fpDinheiro, 150.00);
  
  Caixa.AdicionarVenda(Venda);
  
  // Consultar dados
  ShowMessage(Format('Total Vendas: R$ %.2f', [Caixa.TotalVendas]));
  ShowMessage(Format('Quantidade Vendas: %d', [Caixa.QuantidadeVendas]));
  ShowMessage(Format('Valor Médio: R$ %.2f', [Caixa.ValorMedioVenda]));
  
  // Fechar caixa
  if Caixa.PodeFechar then
    Caixa.Fechar;
  
  // Obter resumo
  ShowMessage(Caixa.ObterResumoVendas);
end;
```

### Métodos de Relatório

```pascal
function ObterResumoVendas: string;
```

Retorna um resumo formatado contendo:
- Data e hora de abertura/fechamento
- Saldo inicial e final
- Quantidade e valor de vendas
- Totalizadores por forma de pagamento
- Descontos e acréscimos

```pascal
function ObterDetalhesVendas: string;
```

Retorna detalhes de cada venda com:
- Número da venda
- Data e hora
- Quantidade de itens
- Subtotal, desconto, acréscimo e total
- Forma de pagamento

---

## 2️⃣ Classe TRepositorioCaixa para Gerenciar Histórico

### Arquivo: `uRepositorioCaixa.pas`

**Funcionalidades Implementadas**:

#### Operações CRUD
```pascal
procedure AdicionarCaixa(ACaixa: TCaixa);
procedure RemoverCaixa(AID: Integer);
procedure AtualizarCaixa(ACaixa: TCaixa);
```

#### Consultas
```pascal
function ObterCaixa(AID: Integer): TCaixa;
function ObterTodos: TObjectList<TCaixa>;
function ObterAbertos: TObjectList<TCaixa>;
function ObterFechados: TObjectList<TCaixa>;
```

#### Buscas Avançadas
```pascal
function BuscarPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
function BuscarPorData(AData: TDateTime): TObjectList<TCaixa>;
function BuscarPorDataIntervalo(ADataInicio, ADataFim: TDateTime): TObjectList<TCaixa>;
```

#### Operações de Caixa Aberto
```pascal
function AbrirCaixa(AOperador: TOperador; ASaldoInicial: Double): TCaixa;
procedure FecharCaixa(AID: Integer);
function ObterCaixaAberto: TCaixa;
function TemCaixaAberto: Boolean;
```

#### Estatísticas
```pascal
function ObterTotalVendas: Double;
function ObterTotalVendasPorOperador(AOperadorID: Integer): Double;
function ObterQuantidadeCaixas: Integer;
function ObterQuantidadeAbertos: Integer;
function ObterQuantidadeFechados: Integer;
function ObterValorTotalCaixas: Double;
function ObterResumoGeral: string;
```

### Exemplo de Uso

```pascal
var
  Repositorio: TRepositorioCaixa;
  Operador: TOperador;
  Caixa: TCaixa;
  Caixas: TObjectList<TCaixa>;
  i: Integer;
begin
  Repositorio := TRepositorioCaixa.Create;
  try
    // Abrir caixa
    Operador := TOperador.Create(1, 'JOÃO', '001', '1234');
    Caixa := Repositorio.AbrirCaixa(Operador, 100.00);
    
    // ... adicionar vendas ...
    
    // Fechar caixa
    Repositorio.FecharCaixa(Caixa.ID);
    
    // Buscar caixas fechados
    Caixas := Repositorio.ObterFechados;
    try
      ShowMessage(Format('Total de caixas fechados: %d', [Caixas.Count]));
    finally
      Caixas.Free;
    end;
    
    // Estatísticas
    ShowMessage(Format('Total de vendas: R$ %.2f', [Repositorio.ObterTotalVendas]));
    ShowMessage(Format('Resumo: %s', [Repositorio.ObterResumoGeral]));
  finally
    Repositorio.Free;
  end;
end;
```

---

## 3️⃣ Tela de Gerenciamento de Caixa (uFormCaixa.pas)

### Arquivo: `uFormCaixa.pas` + `uFormCaixa.fmx`

**Layout Responsivo**:

```
┌─────────────────────────────────────────────────────────────┐
│ GERENCIAMENTO DE CAIXA                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Status: ABERTO                                              │
│ Saldo Inicial: R$ 100.00                                    │
│                                                             │
│ RESUMO DO CAIXA (50%)    │ HISTÓRICO DE VENDAS (50%)       │
│ ──────────────────────────│ ──────────────────────────      │
│ Data Abertura: 28/12/2025│ Venda 1 - R$ 29.90 - 14:30:45  │
│ Saldo Inicial: R$ 100.00 │ Venda 2 - R$ 15.50 - 14:35:20  │
│ Total Vendas: R$ 45.40   │ Venda 3 - R$ 89.90 - 14:40:15  │
│ Saldo Final: R$ 145.40   │ Venda 4 - R$ 25.00 - 14:45:30  │
│                          │ Venda 5 - R$ 12.50 - 14:50:45  │
│ Quantidade Vendas: 5     │                                 │
│ Quantidade Produtos: 12  │                                 │
│ Valor Médio: R$ 9.08     │                                 │
│ Maior Venda: R$ 89.90    │                                 │
│ Menor Venda: R$ 12.50    │                                 │
│                          │                                 │
│ Dinheiro: R$ 45.40       │                                 │
│ Cartão: R$ 0.00          │                                 │
│ PIX: R$ 0.00             │                                 │
│                          │                                 │
│ [Abrir Caixa] [Fechar]   │                                 │
│ [Cancelar]               │                                 │
│                          │                                 │
└─────────────────────────────────────────────────────────────┘
```

### Componentes Principais

#### Painel de Status
- ✅ Status do caixa (Aberto/Fechado)
- ✅ Saldo inicial
- ✅ Data de abertura

#### Painel de Resumo (Esquerda)
- ✅ Resumo completo do caixa
- ✅ Totalizadores
- ✅ Estatísticas
- ✅ Totalizadores por forma de pagamento

#### Painel de Histórico (Direita)
- ✅ Lista de vendas realizadas
- ✅ Clique para ver detalhes
- ✅ Exibe hora de cada venda

#### Painel de Ações
- ✅ Botão para abrir caixa
- ✅ Botão para fechar caixa
- ✅ Botão para cancelar

### Funcionalidades

#### Abrir Caixa
```pascal
procedure ButtonAbrirClick(Sender: TObject);
```

- ✅ Valida saldo inicial
- ✅ Cria novo caixa
- ✅ Abre caixa
- ✅ Atualiza interface

#### Fechar Caixa
```pascal
procedure ButtonFecharClick(Sender: TObject);
```

- ✅ Valida se caixa está aberto
- ✅ Valida se tem vendas
- ✅ Pede confirmação
- ✅ Fecha caixa
- ✅ Atualiza interface

#### Visualizar Detalhes de Venda
```pascal
procedure ExibirDetalhesVenda(AIndex: Integer);
```

Exibe:
- Número da venda
- Data e hora
- Lista de itens com quantidades e valores
- Subtotal, desconto, acréscimo
- Total
- Forma de pagamento
- Valor recebido e troco (se dinheiro)

### Fluxo de Operação

```
1. Operador abre formulário de caixa
   ↓
2. Operador digita saldo inicial
   ↓
3. Operador clica "Abrir Caixa"
   ├─ Caixa é criado e aberto
   ├─ Interface é atualizada
   ├─ Status muda para "ABERTO"
   ↓
4. Operador realiza vendas na tela principal
   ├─ Cada venda é adicionada ao caixa
   ├─ Resumo é atualizado
   ├─ Histórico é atualizado
   ↓
5. Operador clica em venda para ver detalhes
   ├─ Detalhes são exibidos no painel de resumo
   ↓
6. Operador clica "Fechar Caixa"
   ├─ Confirmação é solicitada
   ├─ Caixa é fechado
   ├─ Totalizadores finais são calculados
   ├─ Status muda para "FECHADO"
   ↓
7. Operador clica "Cancelar" para voltar
```

### Responsividade

#### Telas Pequenas (< 1000px)
- Painel esquerda: 40% da largura
- Painel direita: 60% da largura

#### Telas Médias (1000-1400px)
- Painel esquerda: 45% da largura
- Painel direita: 55% da largura

#### Telas Grandes (> 1400px)
- Painel esquerda: 50% da largura
- Painel direita: 50% da largura

---

## 📊 Fluxo de Dados Completo

```
TRepositorioCaixa
    ├─ Gerencia caixas abertos/fechados
    ├─ Mantém histórico
    ↓
TCaixa (Aberto)
    ├─ Registra abertura
    ├─ Adiciona vendas
    ├─ Calcula totalizadores
    ↓
TVenda (Finalizada)
    ├─ Registra venda
    ├─ Define forma de pagamento
    ├─ Calcula troco
    ↓
TCaixa (Fechado)
    ├─ Calcula totalizadores finais
    ├─ Calcula diferença
    ├─ Registra fechamento
    ↓
TRepositorioCaixa
    ├─ Armazena histórico
    ├─ Permite consultas
```

---

## 🎯 Validações Implementadas

✅ **Abertura de Caixa**
- Saldo inicial deve ser numérico
- Saldo inicial não pode ser negativo
- Não pode abrir se já existe caixa aberto

✅ **Adição de Venda**
- Venda deve estar finalizada
- Caixa deve estar aberto
- Venda deve ter itens

✅ **Fechamento de Caixa**
- Caixa deve estar aberto
- Deve ter pelo menos 1 venda
- Confirmação obrigatória

✅ **Consultas**
- Busca por operador
- Busca por data
- Busca por intervalo de datas
- Busca por forma de pagamento

---

## 📈 Relatórios Disponíveis

### Resumo do Caixa
```
RESUMO DO CAIXA

Data Abertura: 28/12/2025 14:00:00
Data Fechamento: 28/12/2025 18:30:00

Saldo Inicial: R$ 100.00
Total Vendas: R$ 172.80
Saldo Final: R$ 272.80

Quantidade Vendas: 5
Quantidade Produtos: 12
Valor Médio Venda: R$ 34.56
Maior Venda: R$ 89.90
Menor Venda: R$ 12.50

Total Desconto: R$ 5.00
Total Acréscimo: R$ 0.00

Dinheiro: R$ 172.80
Cartão: R$ 0.00
PIX: R$ 0.00
```

### Detalhes das Vendas
```
DETALHES DAS VENDAS

Venda 1:
  Data: 28/12/2025 14:30:45
  Itens: 3
  Subtotal: R$ 29.90
  Total: R$ 29.90
  Pagamento: DINHEIRO

Venda 2:
  Data: 28/12/2025 14:35:20
  Itens: 2
  Subtotal: R$ 15.50
  Total: R$ 15.50
  Pagamento: DINHEIRO

...
```

---

## 🔄 Integração com Tela Principal

A tela principal (`uFormPrincipalResponsivo.pas`) integra-se com o gerenciamento de caixa:

```pascal
// Abrir caixa
FormCaixa := TFormCaixa.Create(nil, FOperadorAtual);
FormCaixa.ShowModal;

// Adicionar venda ao caixa
FCaixaAtual.AdicionarVenda(FVendaAtual);

// Verificar se caixa está aberto
if FCaixaAtual.EstaAberto then
  // Permitir vendas
```

---

## 📁 Arquivos Criados/Modificados

| Arquivo | Status | Descrição |
|---------|--------|-----------|
| `uCaixa.pas` | ✏️ ATUALIZADO | Gerenciamento completo |
| `uRepositorioCaixa.pas` | ✨ NOVO | Repositório de histórico |
| `uFormCaixa.pas` | ✏️ ATUALIZADO | Tela de gerenciamento |

---

## 🚀 Próximas Melhorias

- [ ] Exportar relatório em PDF
- [ ] Sincronizar com servidor
- [ ] Backup automático
- [ ] Auditoria de operações
- [ ] Integração com sistema fiscal
- [ ] Múltiplos caixas simultâneos
- [ ] Transferência entre caixas
- [ ] Suprimento e sangria

---

## Conclusão

O sistema de gerenciamento de caixa está **100% funcional** com:

✅ **Ciclo de vida completo** - Abertura, operação, fechamento
✅ **Histórico completo** - Todas as vendas registradas
✅ **Totalizadores automáticos** - Cálculos em tempo real
✅ **Relatórios detalhados** - Resumo e detalhes
✅ **Validações robustas** - Integridade dos dados
✅ **Interface responsiva** - Adapta a qualquer tela
✅ **Integração completa** - Com tela principal e vendas
