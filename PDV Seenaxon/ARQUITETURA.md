# Arquitetura do PDV Seenaxon em Delphi

## Visão Geral da Arquitetura

O projeto foi estruturado seguindo princípios de **Programação Orientada a Objetos (POO)** e **Padrões de Design**, dividindo-se em três camadas principais:

```
┌─────────────────────────────────────────────────────┐
│         CAMADA DE APRESENTAÇÃO (UI/FMX)             │
│  ┌──────────────────────────────────────────────┐   │
│  │  TFormPrincipal                              │   │
│  │  - Interface gráfica                         │   │
│  │  - Manipulação de eventos                    │   │
│  │  - Atualização de componentes                │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│      CAMADA DE LÓGICA DE NEGÓCIO (DOMAIN)           │
│  ┌──────────────────────────────────────────────┐   │
│  │  TVenda                                      │   │
│  │  - Gerencia venda completa                   │   │
│  │  - Cálculos de totais                        │   │
│  │  - Aplicação de descontos/acréscimos         │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  TItemVenda                                  │   │
│  │  - Representa item do carrinho               │   │
│  │  - Cálculo de valor total do item            │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  TCaixa                                      │   │
│  │  - Gerencia caixa                            │   │
│  │  - Registro de vendas                        │   │
│  │  - Cálculo de totalizações                   │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────────┐
│      CAMADA DE DADOS (DATA ACCESS)                  │
│  ┌──────────────────────────────────────────────┐   │
│  │  TRepositorioProdutos                        │   │
│  │  - Acesso aos produtos                       │   │
│  │  - Busca e filtros                           │   │
│  │  - Armazenamento em memória                  │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  TProduto                                    │   │
│  │  - Dados do produto                          │   │
│  └──────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────┐   │
│  │  TOperador                                   │   │
│  │  - Dados do operador                         │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## Diagrama de Classes

```
┌─────────────────────┐
│    TProduto         │
├─────────────────────┤
│ - ID: Integer       │
│ - Nome: string      │
│ - Descricao: string │
│ - Preco: Double     │
│ - ImagemPath: str   │
└─────────────────────┘
         ↑
         │ usa
         │
┌─────────────────────┐
│   TItemVenda        │
├─────────────────────┤
│ - Produto: TProd    │
│ - Quantidade: Dbl   │
│ - ValorUnitario: Dbl│
│ - ValorTotal: Dbl   │
├─────────────────────┤
│ + CalcularTotal()   │
└─────────────────────┘
         ↑
         │ contém
         │
┌─────────────────────┐
│     TVenda          │
├─────────────────────┤
│ - ID: Integer       │
│ - Itens: List       │
│ - Subtotal: Double  │
│ - Desconto: Double  │
│ - Acrescimo: Double │
│ - Total: Double     │
├─────────────────────┤
│ + AdicionarItem()   │
│ + RemoverItem()     │
│ + AplicarDesconto() │
│ + AplicarAcrescimo()│
│ + CalcularTotais()  │
└─────────────────────┘
         ↑
         │ contém
         │
┌─────────────────────┐
│     TCaixa          │
├─────────────────────┤
│ - ID: Integer       │
│ - Operador: TOper   │
│ - Vendas: List      │
│ - Aberto: Boolean   │
│ - SaldoInicial: Dbl │
│ - SaldoFinal: Dbl   │
├─────────────────────┤
│ + Abrir()           │
│ + Fechar()          │
│ + AdicionarVenda()  │
└─────────────────────┘
         ↑
         │ gerencia
         │
┌─────────────────────┐
│    TOperador        │
├─────────────────────┤
│ - ID: Integer       │
│ - Nome: string      │
│ - Matricula: string │
│ - Senha: string     │
│ - Ativo: Boolean    │
└─────────────────────┘

┌──────────────────────────────┐
│ TRepositorioProdutos         │
├──────────────────────────────┤
│ - Produtos: List<TProduto>   │
├──────────────────────────────┤
│ + AdicionarProduto()         │
│ + RemoverProduto()           │
│ + ObterProduto()             │
│ + BuscarPorNome()            │
│ + BuscarPorCodigoBarras()    │
│ + ObterTodos()               │
└──────────────────────────────┘
```

## Padrões de Design Utilizados

### 1. Model-View-Controller (MVC)

**Objetivo**: Separar a lógica de negócio da interface gráfica.

**Implementação**:
- **Model**: Classes `TProduto`, `TVenda`, `TItemVenda`, `TCaixa`, `TOperador`
- **View**: Componentes FMX em `TFormPrincipal`
- **Controller**: Métodos de evento em `TFormPrincipal`

**Benefícios**:
- Código mais organizado
- Fácil manutenção
- Possibilidade de testar lógica independentemente da UI

### 2. Repository Pattern

**Objetivo**: Abstrair o acesso aos dados.

**Implementação**:
```pascal
TRepositorioProdutos
  ├─ ObterProduto(ID)
  ├─ BuscarPorNome(Nome)
  ├─ BuscarPorCodigoBarras(Codigo)
  └─ ObterTodos()
```

**Benefícios**:
- Fácil trocar implementação (memória → banco de dados)
- Centraliza lógica de acesso aos dados
- Facilita testes

### 3. Encapsulation

**Objetivo**: Proteger dados internos das classes.

**Implementação**:
- Todos os atributos são privados (`F` prefix)
- Acesso via propriedades públicas
- Validações em métodos setter

**Exemplo**:
```pascal
TItemVenda = class
private
  FQuantidade: Double;
public
  procedure SetQuantidade(AQuantidade: Double);
  property Quantidade: Double read FQuantidade;
end;
```

### 4. Single Responsibility Principle

**Objetivo**: Cada classe tem uma única responsabilidade.

| Classe | Responsabilidade |
|--------|------------------|
| TProduto | Armazenar dados do produto |
| TItemVenda | Gerenciar item do carrinho |
| TVenda | Gerenciar venda completa |
| TCaixa | Gerenciar caixa |
| TOperador | Armazenar dados do operador |
| TRepositorioProdutos | Acesso aos produtos |

### 5. Dependency Injection

**Objetivo**: Reduzir acoplamento entre classes.

**Implementação**:
```pascal
// TCaixa recebe TOperador como parâmetro
TCaixa.Create(AID: Integer; AOperador: TOperador; ASaldoInicial: Double);

// TVenda recebe TProduto como parâmetro
TVenda.AdicionarItem(AProduto: TProduto; AQuantidade: Double);
```

## Fluxo de Dados

### Adição de Produto

```
Usuário clica em produto
    ↓
ListBoxProdutosItemClick()
    ↓
ObterProduto() do repositório
    ↓
TVenda.AdicionarItem(TProduto)
    ↓
TItemVenda.Create() e CalcularTotal()
    ↓
TVenda.CalcularTotais()
    ↓
AtualizarResumoVenda()
    ↓
Interface atualizada
```

### Aplicação de Desconto

```
Usuário clica em "Desconto"
    ↓
InputBox solicita valor
    ↓
TVenda.AplicarDesconto(Valor)
    ↓
TVenda.CalcularTotais()
    ↓
AtualizarResumoVenda()
    ↓
Interface atualizada
```

### Finalização de Venda

```
Usuário clica em "Finalizar Venda"
    ↓
Validação: QuantidadeItens > 0
    ↓
TCaixa.AdicionarVenda(TVenda)
    ↓
TVenda adicionada à lista de vendas
    ↓
TCaixa.CalcularTotalVendas()
    ↓
Nova TVenda criada
    ↓
AtualizarResumoVenda()
    ↓
Interface zerada
```

## Cálculos Automáticos

### Cálculo de Valor Total do Item

```
ValorTotal = ValorUnitario × Quantidade
```

### Cálculo de Subtotal

```
Subtotal = Σ(ValorTotal de cada item)
```

### Cálculo de Total

```
Total = Subtotal - Desconto + Acréscimo
```

## Validações

### Validação de Quantidade

```pascal
if AQuantidade > 0 then
  FQuantidade := AQuantidade
else
  raise Exception.Create('Quantidade deve ser maior que zero');
```

### Validação de Preço

```pascal
if APreco > 0 then
  FPreco := APreco
else
  raise Exception.Create('Preço deve ser maior que zero');
```

### Validação de Finalização

```pascal
if FVendaAtual.QuantidadeItens > 0 then
  // Finalizar venda
else
  ShowMessage('Adicione produtos antes de finalizar');
```

## Extensibilidade

### Como Adicionar Novo Tipo de Desconto

**Passo 1**: Estender classe `TVenda`
```pascal
procedure AplicarDescontoPercentual(APercentual: Double);
begin
  FDesconto := FSubtotal * (APercentual / 100);
  FDescontoPercentual := True;
  CalcularTotais;
end;
```

**Passo 2**: Chamar do formulário
```pascal
procedure TFormPrincipal.ButtonDescontoPercentualClick(Sender: TObject);
begin
  FVendaAtual.AplicarDescontoPercentual(10); // 10%
  AtualizarResumoVenda;
end;
```

### Como Adicionar Persistência em Banco de Dados

**Passo 1**: Criar interface
```pascal
IRepositorioProdutos = interface
  function ObterProduto(AID: Integer): TProduto;
  function BuscarPorNome(ANome: string): TObjectList<TProduto>;
end;
```

**Passo 2**: Implementar para banco de dados
```pascal
TRepositorioProdutosDB = class(TInterfacedObject, IRepositorioProdutos)
  // Implementação com SQL
end;
```

**Passo 3**: Usar no formulário
```pascal
FRepositorioProdutos := TRepositorioProdutosDB.Create;
```

## Performance

### Otimizações Implementadas

1. **Cálculos Lazy**: Totais são recalculados apenas quando necessário
2. **Busca Eficiente**: Uso de `ContainsText` para busca case-insensitive
3. **Memória**: Produtos armazenados em lista (não em array dinâmico)

### Possíveis Melhorias

1. **Cache**: Cachear resultados de busca
2. **Índices**: Adicionar índices para busca rápida
3. **Paginação**: Paginar lista de produtos
4. **Lazy Loading**: Carregar produtos sob demanda

## Testes

### Testes Unitários

Implementados em `uTestes.pas`:

```pascal
TTestes.ExecutarTodos
  ├─ TestarProduto
  ├─ TestarItemVenda
  ├─ TestarVenda
  ├─ TestarOperador
  ├─ TestarCaixa
  └─ TestarRepositorioProdutos
```

### Cobertura de Testes

- ✅ Criação de objetos
- ✅ Cálculos automáticos
- ✅ Validações
- ✅ Operações CRUD
- ✅ Buscas e filtros

## Segurança

### Validações de Entrada

- Quantidade deve ser > 0
- Preço deve ser > 0
- Desconto não pode ser negativo
- Acréscimo não pode ser negativo

### Proteção de Dados

- Atributos privados com acesso via propriedades
- Métodos setter com validações
- Encapsulation de lógica complexa

## Documentação

### Arquivos de Documentação

1. **README.md**: Visão geral do projeto
2. **GUIA_USO.md**: Guia de uso do sistema
3. **ARQUITETURA.md**: Este arquivo
4. **ANALISE_PDV_SEENAXON.md**: Análise do vídeo

### Comentários no Código

Todas as classes e métodos possuem comentários explicativos.

## Conclusão

A arquitetura do PDV Seenaxon em Delphi foi projetada para ser:

- **Modular**: Fácil de manter e estender
- **Testável**: Lógica separada da UI
- **Escalável**: Preparada para crescimento
- **Segura**: Com validações e encapsulation
- **Documentada**: Com guias e comentários

Seguindo princípios de POO e padrões de design, o projeto oferece uma base sólida para um sistema PDV profissional.
