# PDV Seenaxon - Implementação em Delphi Sydney com FMX

## Visão Geral

Este projeto implementa um **Sistema de Ponto de Venda (PDV)** em Delphi Sydney utilizando **FMX (FireMonkey)** para interface gráfica e **Programação Orientada a Objetos (POO)** para a lógica de negócio. O layout e funcionalidades foram baseados no vídeo do Seenaxon PDV da T2Ti.

## Arquitetura do Projeto

### Estrutura de Classes POO

O projeto foi estruturado em camadas com as seguintes classes principais:

#### 1. **TProduto** (`uProduto.pas`)

Representa um produto no sistema com os seguintes atributos:

- **ID**: Identificador único do produto
- **Nome**: Nome do produto (ex: LIVRO, LAPIS, CANETA)
- **Descrição**: Descrição detalhada do produto
- **Preço**: Valor unitário do produto
- **ImagemPath**: Caminho para a imagem do produto

**Responsabilidades**: Armazenar informações do produto e fornecer acesso aos dados.

#### 2. **TItemVenda** (`uItemVenda.pas`)

Representa um item adicionado ao carrinho de compras:

- **Produto**: Referência ao produto
- **Quantidade**: Quantidade de unidades do produto
- **ValorUnitario**: Preço unitário no momento da venda
- **ValorTotal**: Cálculo automático (Quantidade × ValorUnitario)

**Responsabilidades**: Gerenciar itens individuais do carrinho com cálculos automáticos.

#### 3. **TVenda** (`uVenda.pas`)

Gerencia a venda completa com múltiplos itens:

- **ID**: Identificador da venda
- **Itens**: Lista de TItemVenda
- **Subtotal**: Soma de todos os valores dos itens
- **Desconto**: Valor ou percentual de desconto aplicado
- **Acréscimo**: Valor ou percentual de acréscimo/taxa
- **Total**: Cálculo final (Subtotal - Desconto + Acréscimo)
- **DataVenda**: Data e hora da venda

**Responsabilidades**: Gerenciar a venda completa, cálculos de totais, aplicação de descontos e acréscimos.

**Métodos Principais**:
- `AdicionarItem()`: Adiciona um produto ao carrinho (agrupa produtos iguais)
- `RemoverItem()`: Remove um item do carrinho
- `AtualizarQuantidade()`: Altera a quantidade de um item
- `AplicarDesconto()`: Aplica desconto em valor ou percentual
- `AplicarAcrescimo()`: Aplica acréscimo em valor ou percentual
- `LimparVenda()`: Limpa todos os itens da venda

#### 4. **TOperador** (`uOperador.pas`)

Representa um operador do PDV:

- **ID**: Identificador do operador
- **Nome**: Nome completo
- **Matrícula**: Número de matrícula
- **Senha**: Senha para autenticação
- **DataCadastro**: Data de cadastro
- **Ativo**: Status do operador

**Responsabilidades**: Armazenar dados do operador logado no sistema.

#### 5. **TCaixa** (`uCaixa.pas`)

Gerencia o caixa e suas operações:

- **ID**: Identificador do caixa
- **Operador**: Referência ao operador responsável
- **Vendas**: Lista de vendas realizadas
- **Aberto**: Status do caixa (aberto/fechado)
- **DataAbertura**: Data e hora da abertura
- **DataFechamento**: Data e hora do fechamento
- **SaldoInicial**: Valor inicial do caixa
- **SaldoFinal**: Valor final após todas as vendas
- **TotalVendas**: Soma de todas as vendas

**Responsabilidades**: Gerenciar abertura, fechamento e registro de vendas do caixa.

**Métodos Principais**:
- `Abrir()`: Abre o caixa com saldo inicial
- `Fechar()`: Fecha o caixa e calcula totais
- `AdicionarVenda()`: Registra uma venda no caixa

#### 6. **TRepositorioProdutos** (`uRepositorioProdutos.pas`)

Gerencia produtos em memória (sem persistência em banco de dados):

- **Produtos**: Lista de TProduto
- **ProximoID**: Contador para IDs

**Responsabilidades**: Fornecer acesso aos produtos com busca e filtros.

**Métodos Principais**:
- `AdicionarProduto()`: Adiciona um novo produto
- `RemoverProduto()`: Remove um produto
- `ObterProduto()`: Obtém um produto por ID
- `BuscarPorNome()`: Busca produtos por nome ou descrição
- `BuscarPorCodigoBarras()`: Busca por código de barras
- `ObterTodos()`: Retorna todos os produtos

### Interface FMX (`uFormPrincipal.pas`)

A interface foi desenvolvida em FMX reproduzindo o layout do Seenaxon PDV:

#### Layout Principal

**Cabeçalho** (60px de altura):
- Nome do operador logado
- Status do caixa (Aberto/Fechado)

**Conteúdo Principal** (dividido em duas seções):

**Painel Esquerdo** (800px de largura):
- **Barra de Pesquisa**: Campo para buscar produtos por código de barras ou nome
- **Lista de Produtos**: ListBox com produtos disponíveis
  - Exibe nome e preço do produto
  - Clique adiciona o produto ao carrinho

**Painel Direito** (480px de largura):
- **Resumo da Venda**: Memo com:
  - Lista de itens adicionados
  - Quantidade e valor de cada item
  - Subtotal
  - Desconto aplicado (se houver)
  - Acréscimo aplicado (se houver)
  - Total final em destaque
  
- **Botões de Ação**:
  - **Desconto**: Abre diálogo para aplicar desconto
  - **Acréscimo**: Abre diálogo para aplicar acréscimo/taxa
  - **Finalizar Venda**: Processa a venda e limpa o carrinho
  - **Limpar Carrinho**: Remove todos os itens sem finalizar
  
- **Botões Rápidos**:
  - **Remover**: Remove o item selecionado
  - **Aumentar**: Aumenta quantidade do item
  - **Diminuir**: Diminui quantidade do item

#### Componentes FMX Utilizados

- **TPanel**: Divisão do layout
- **TLabel**: Exibição de textos
- **TEdit**: Campo de entrada para pesquisa
- **TListBox**: Lista de produtos
- **TMemo**: Exibição do resumo da venda
- **TButton**: Botões de ação

## Fluxo de Operação

### 1. Inicialização do Sistema

```
FormCreate()
  ├─ Cria repositório de produtos com dados de teste
  ├─ Cria operador (MARCOS SILVA DE MATOS)
  ├─ Cria caixa e abre com saldo inicial
  ├─ Cria venda atual (vazia)
  └─ Atualiza interface com dados do operador
```

### 2. Adição de Produtos

```
Usuário digita código de barras ou clica em produto
  ├─ EditPesquisaChange() filtra produtos
  └─ ListBoxProdutosItemClick()
      ├─ Obtém produto do repositório
      ├─ FVendaAtual.AdicionarItem()
      └─ AtualizarResumoVenda()
```

### 3. Aplicação de Desconto

```
Usuário clica em "Desconto"
  ├─ InputBox solicita valor
  ├─ FVendaAtual.AplicarDesconto()
  └─ AtualizarResumoVenda()
```

### 4. Finalização da Venda

```
Usuário clica em "Finalizar Venda"
  ├─ Valida se há itens
  ├─ FCaixaAtual.AdicionarVenda(FVendaAtual)
  ├─ Cria nova TVenda
  ├─ AtualizarResumoVenda()
  └─ Exibe mensagem de sucesso
```

## Dados de Teste

O sistema vem pré-carregado com os seguintes produtos:

| ID | Nome | Descrição | Preço |
|---|---|---|---|
| 1 | LIVRO | Livro Teste | R$ 1,50 |
| 2 | LAPIS | Lápis Teste | R$ 1,50 |
| 3 | CANETA | Caneta Teste | R$ 10,00 |
| 4 | BORRACHA | Borracha Teste | R$ 2,00 |
| 5 | CADERNO | Caderno Teste | R$ 15,00 |

Operador de Teste:
- **Nome**: MARCOS SILVA DE MATOS
- **Matrícula**: 001
- **Senha**: 1234

## Funcionalidades Implementadas

### Gerenciamento de Produtos
- ✅ Busca por nome ou código de barras
- ✅ Filtro em tempo real
- ✅ Exibição de preço

### Gerenciamento de Vendas
- ✅ Adição de produtos ao carrinho
- ✅ Agrupamento automático de produtos iguais
- ✅ Ajuste de quantidade
- ✅ Remoção de itens
- ✅ Cálculo automático de totais

### Operações Financeiras
- ✅ Aplicação de descontos (valor fixo)
- ✅ Aplicação de acréscimos (valor fixo)
- ✅ Cálculo de subtotal, desconto, acréscimo e total
- ✅ Finalização de venda

### Controle de Caixa
- ✅ Abertura de caixa com saldo inicial
- ✅ Registro de vendas
- ✅ Cálculo de total de vendas
- ✅ Fechamento de caixa

## Extensões Futuras

O projeto foi estruturado para permitir fáceis extensões:

### 1. Persistência em Banco de Dados
Criar classes `TRepositorioProdutosDB`, `TRepositorioVendasDB` que herdem de interfaces comuns.

### 2. Autenticação de Operador
Implementar tela de login com validação de matrícula e senha.

### 3. Integração com NFe
Adicionar classe `TNFe` para geração de documentos fiscais.

### 4. Relatórios
Criar classe `TRelatorios` para gerar relatórios de vendas.

### 5. Descontos Percentuais
Modificar `AplicarDesconto()` para aceitar percentuais.

### 6. Múltiplos Operadores
Implementar gerenciamento de múltiplos operadores.

## Compilação e Execução

### Requisitos
- Delphi Sydney (ou superior)
- FMX (FireMonkey)

### Passos
1. Abrir `DelphiPDV.dpr` no Delphi
2. Compilar o projeto
3. Executar

## Estrutura de Arquivos

```
DelphiPDV/
├── DelphiPDV.dpr              # Arquivo principal do projeto
├── uFormPrincipal.pas         # Formulário principal (interface)
├── uFormPrincipal.fmx         # Layout FMX do formulário
├── uProduto.pas               # Classe TProduto
├── uItemVenda.pas             # Classe TItemVenda
├── uVenda.pas                 # Classe TVenda
├── uOperador.pas              # Classe TOperador
├── uCaixa.pas                 # Classe TCaixa
├── uRepositorioProdutos.pas   # Classe TRepositorioProdutos
├── README.md                  # Este arquivo
└── ANALISE_PDV_SEENAXON.md   # Análise do vídeo
```

## Padrões de Design Utilizados

### 1. **Model-View-Controller (MVC)**
- **Model**: Classes de negócio (TProduto, TVenda, TCaixa)
- **View**: Formulário FMX (TFormPrincipal)
- **Controller**: Métodos de manipulação de eventos

### 2. **Repository Pattern**
- `TRepositorioProdutos` abstrai o acesso aos dados

### 3. **Encapsulation**
- Todas as classes utilizam propriedades para acesso aos dados

### 4. **Single Responsibility Principle**
- Cada classe tem uma responsabilidade bem definida

## Notas Importantes

1. **Sem Persistência**: O projeto não utiliza banco de dados. Os dados são mantidos apenas em memória durante a execução.

2. **Produtos de Teste**: Os produtos são carregados automaticamente na inicialização.

3. **Cálculos Automáticos**: Todos os cálculos (subtotal, total, etc.) são atualizados automaticamente.

4. **Validações**: O sistema valida entrada de dados (ex: quantidade > 0).

5. **Interface Responsiva**: A interface foi desenvolvida em FMX para ser responsiva em diferentes resoluções.

## Conclusão

Este projeto demonstra a implementação de um sistema PDV completo utilizando Delphi Sydney com FMX, seguindo princípios de POO e padrões de design. A arquitetura modular permite fáceis extensões e manutenção do código.
