# Documentação - Tela Principal Responsiva com Recuperação de Vendas

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Fluxo de Inicialização](#fluxo-de-inicialização)
3. [Componentes da Interface](#componentes-da-interface)
4. [Métodos Principais](#métodos-principais)
5. [Integração com TRecuperacaoVendas](#integração-com-trecuperacaovendas)
6. [Fluxo de Venda Completo](#fluxo-de-venda-completo)
7. [Exemplos de Uso](#exemplos-de-uso)

---

## Visão Geral

A classe `TFormPrincipalResponsivo` é a **tela principal do PDV** que integra toda a lógica de negócio com uma interface responsiva e amigável.

### Características Principais

✅ **Inicialização Completa** - Repositórios, login, verificação de venda pendente
✅ **Recuperação Automática** - Pergunta ao usuário se deseja retomar venda pendente
✅ **Interface Responsiva** - Adapta a qualquer tamanho de tela
✅ **Gerenciamento de Carrinho** - Adicionar, remover, ajustar quantidade
✅ **Descontos e Acréscimos** - Aplicar em valor ou percentual
✅ **Múltiplas Formas de Pagamento** - Dinheiro, Cartão, PIX
✅ **Impressão Fiscal** - Cupom automático após venda
✅ **Salvamento Automático** - Venda pendente salva a cada ação

---

## Fluxo de Inicialização

### Sequência Passo a Passo

```
1. FormCreate é chamado
   ↓
2. InicializarRepositorios()
   ├─ Criar TRepositorioProdutos
   ├─ Criar TRepositorioOperadores
   ├─ Criar TRepositorioCaixa
   ├─ Criar TRecuperacaoVendas
   └─ Carregar dados de teste
   ↓
3. RealizarLogin()
   ├─ Solicitar matrícula
   ├─ Solicitar senha
   ├─ Validar credenciais
   ├─ Criar TOperador
   └─ Atualizar label do operador
   ↓
4. VerificarVendaPendente()
   ├─ Verificar se existe arquivo de venda pendente
   ├─ Se SIM:
   │  ├─ Perguntar ao usuário
   │  ├─ Se aceitar: Carregar venda
   │  └─ Se recusar: Deletar arquivo
   └─ Se NÃO: Continuar normalmente
   ↓
5. CarregarProdutos()
   ├─ Buscar todos os produtos
   └─ Atualizar ListBox de produtos
   ↓
6. AbrirCaixa()
   ├─ Criar TCaixa
   ├─ Solicitar saldo inicial
   ├─ Abrir caixa
   └─ Atualizar label do caixa
   ↓
7. AjustarLayout()
   ├─ Configurar painéis
   ├─ Calcular proporções
   └─ Ajustar responsividade
   ↓
8. Criar TVenda inicial
   ├─ Instanciar TVenda
   └─ Definir OperadorID
   ↓
9. AtualizarResumoVenda()
   └─ Exibir resumo inicial (carrinho vazio)
   ↓
10. TimerHora.Enabled := True
    └─ Iniciar atualização de hora
```

---

## Componentes da Interface

### Painel de Cabeçalho

```
┌─────────────────────────────────────────────────────────────┐
│ Operador: JOÃO SILVA (001) | Caixa: Aberto - R$ 100.00    │
│                                                              │
│ [Gerenciar Caixa] [Sair]                    14:30:45        │
└─────────────────────────────────────────────────────────────┘
```

**Componentes:**
- `LabelOperador` - Nome e matrícula do operador
- `LabelCaixa` - Status e saldo do caixa
- `LabelHora` - Hora atual (atualizada a cada segundo)
- `ButtonGerenciarCaixa` - Abre formulário de caixa
- `ButtonSair` - Sair do sistema

### Painel de Corpo

#### Esquerda (Produtos)

```
┌─────────────────────────────────┐
│ Pesquisa de Produtos            │
│ [Buscar produto...]             │
│                                 │
│ Produtos:                       │
│ ┌─────────────────────────────┐ │
│ │ LIVRO - R$ 29.90            │ │
│ │ CANETA - R$ 5.00            │ │
│ │ CADERNO - R$ 25.00          │ │
│ │ LÁPIS - R$ 2.50             │ │
│ │ BORRACHA - R$ 1.50          │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

**Componentes:**
- `EditPesquisa` - Campo de busca (em tempo real)
- `ListBoxProdutos` - Lista de produtos disponíveis

#### Direita (Carrinho)

```
┌──────────────────────────────┐
│ Carrinho de Compras          │
│ ┌──────────────────────────┐ │
│ │ 2 x LIVRO - R$ 59.80     │ │
│ │ 3 x CANETA - R$ 15.00    │ │
│ │ 1 x CADERNO - R$ 25.00   │ │
│ └──────────────────────────┘ │
│                              │
│ Resumo da Venda:             │
│ ┌──────────────────────────┐ │
│ │ Itens: 3                 │ │
│ │ Subtotal: R$ 99.80       │ │
│ │ Desconto: R$ 10.00       │ │
│ │ TOTAL: R$ 89.80          │ │
│ └──────────────────────────┘ │
└──────────────────────────────┘
```

**Componentes:**
- `ListBoxCarrinho` - Lista de itens adicionados
- `MemoResumo` - Resumo da venda com cálculos

### Painel de Rodapé (Botões)

```
┌────────────────────────────────────────────────────────────┐
│ [Aumentar] [Diminuir] [Remover] | [Desconto] [Acréscimo]  │
│ [Limpar] [Finalizar]                                       │
└────────────────────────────────────────────────────────────┘
```

**Componentes:**
- `ButtonAumentar` - Aumentar quantidade do item selecionado
- `ButtonDiminuir` - Diminuir quantidade do item selecionado
- `ButtonRemover` - Remover item do carrinho
- `ButtonDesconto` - Aplicar desconto à venda
- `ButtonAcrescimo` - Aplicar acréscimo à venda
- `ButtonLimpar` - Limpar todo o carrinho
- `ButtonFinalizar` - Finalizar venda

---

## Métodos Principais

### Inicialização

#### InicializarRepositorios

```pascal
procedure InicializarRepositorios;
```

**Funcionalidades:**
- ✅ Criar TRepositorioProdutos
- ✅ Carregar produtos de teste
- ✅ Criar TRepositorioOperadores
- ✅ Carregar operadores de teste
- ✅ Criar TRepositorioCaixa
- ✅ Criar TRecuperacaoVendas

#### RealizarLogin

```pascal
procedure RealizarLogin;
```

**Funcionalidades:**
- ✅ Solicitar matrícula
- ✅ Solicitar senha
- ✅ Validar credenciais (máx 3 tentativas)
- ✅ Criar TOperador
- ✅ Atualizar interface

#### VerificarVendaPendente

```pascal
procedure VerificarVendaPendente;
```

**Funcionalidades:**
- ✅ Verificar se existe arquivo de venda pendente
- ✅ Perguntar ao usuário se deseja retomar
- ✅ Carregar venda se aceitar
- ✅ Deletar arquivo se recusar
- ✅ Exibir mensagem de sucesso

#### CarregarProdutos

```pascal
procedure CarregarProdutos;
```

**Funcionalidades:**
- ✅ Obter todos os produtos do repositório
- ✅ Adicionar à ListBox
- ✅ Exibir nome e preço

#### AbrirCaixa

```pascal
procedure AbrirCaixa;
```

**Funcionalidades:**
- ✅ Criar TCaixa
- ✅ Solicitar saldo inicial
- ✅ Validar valor
- ✅ Abrir caixa
- ✅ Adicionar ao repositório

### Atualização de Interface

#### AtualizarResumoVenda

```pascal
procedure AtualizarResumoVenda;
```

**Exibe:**
- Quantidade de itens
- Subtotal
- Desconto (se houver)
- Acréscimo (se houver)
- Total

#### AtualizarListaCarrinho

```pascal
procedure AtualizarListaCarrinho;
```

**Funcionalidades:**
- ✅ Limpar ListBox
- ✅ Iterar sobre itens
- ✅ Exibir quantidade, nome e valor
- ✅ Atualizar resumo

#### AtualizarListaProdutos

```pascal
procedure AtualizarListaProdutos;
```

**Funcionalidades:**
- ✅ Verificar texto de pesquisa
- ✅ Se vazio: carregar todos os produtos
- ✅ Se preenchido: buscar por nome
- ✅ Atualizar ListBox

### Operações de Venda

#### SalvarVendaPendente

```pascal
procedure SalvarVendaPendente;
```

**Funcionalidades:**
- ✅ Validar venda (não nula, com itens)
- ✅ Chamar TRecuperacaoVendas.SalvarVendaPendente
- ✅ Salvar em arquivo XML

#### FinalizarVendaCompleta

```pascal
procedure FinalizarVendaCompleta;
```

**Funcionalidades:**
- ✅ Adicionar venda ao caixa
- ✅ Criar TImpressoraFiscal
- ✅ Gerar cupom
- ✅ Imprimir cupom
- ✅ Deletar arquivo de venda pendente
- ✅ Limpar venda
- ✅ Exibir mensagem de sucesso

---

## Integração com TRecuperacaoVendas

### Fluxo de Recuperação

```
FormCreate
    ↓
VerificarVendaPendente()
    ├─ FRecuperacaoVendas.TemVendaPendente
    ├─ Se SIM:
    │  ├─ MessageDlg: "Deseja retomar?"
    │  ├─ Se SIM:
    │  │  ├─ FRecuperacaoVendas.CarregarVendaPendente
    │  │  ├─ Atribuir a FVendaAtual
    │  │  ├─ FRecuperacaoVendas.DeletarVendaPendente
    │  │  └─ ShowMessage: "Venda retomada!"
    │  └─ Se NÃO:
    │     └─ FRecuperacaoVendas.DeletarVendaPendente
    └─ Se NÃO: Continuar normalmente
```

### Salvamento Automático

```
Cada ação que modifica a venda:
    ├─ ListBoxProdutosItemClick
    ├─ ButtonAumentarClick
    ├─ ButtonDiminuirClick
    ├─ ButtonRemoverClick
    ├─ ButtonDescontoClick
    ├─ ButtonAcrescimoClick
    └─ Chama: SalvarVendaPendente()
        └─ FRecuperacaoVendas.SalvarVendaPendente(FVendaAtual)
```

### Limpeza Após Finalização

```
FinalizarVendaCompleta()
    ├─ ... (processar venda)
    ├─ FRecuperacaoVendas.DeletarVendaPendente
    ├─ LimparVenda()
    └─ ShowMessage: "Venda finalizada!"
```

---

## Fluxo de Venda Completo

### Exemplo: Venda com Desconto

```
1. Sistema inicia
   ├─ Verifica venda pendente
   └─ Carrega produtos

2. Operador clica em "LIVRO"
   ├─ Produto adicionado ao carrinho
   ├─ Venda pendente salva
   └─ ShowMessage: "LIVRO adicionado ao carrinho"

3. Operador clica em "CANETA"
   ├─ Produto adicionado ao carrinho
   ├─ Venda pendente salva
   └─ ShowMessage: "CANETA adicionado ao carrinho"

4. Operador seleciona LIVRO no carrinho
   ├─ Detalhes do item exibidos
   └─ Pronto para ajuste

5. Operador clica em "AUMENTAR"
   ├─ Quantidade aumentada de 1 para 2
   ├─ Resumo atualizado
   ├─ Venda pendente salva
   └─ Detalhes atualizados

6. Operador clica em "DESCONTO"
   ├─ Solicita valor do desconto
   ├─ Desconto aplicado
   ├─ Resumo atualizado
   ├─ Venda pendente salva
   └─ ShowMessage: "Desconto de R$ 10.00 aplicado"

7. Operador clica em "FINALIZAR"
   ├─ Valida carrinho (não vazio)
   ├─ Valida caixa (aberto)
   ├─ Pergunta forma de pagamento
   ├─ Operador escolhe "Dinheiro"
   ├─ Solicita valor recebido
   ├─ Finaliza venda
   ├─ Adiciona ao caixa
   ├─ Imprime cupom
   ├─ Deleta arquivo de venda pendente
   ├─ Limpa carrinho
   └─ ShowMessage: "Venda finalizada com sucesso!"
```

---

## Exemplos de Uso

### Exemplo 1: Inicializar Tela Principal

```pascal
var
  FormPrincipal: TFormPrincipalResponsivo;
begin
  FormPrincipal := TFormPrincipalResponsivo.Create(nil);
  try
    FormPrincipal.ShowModal;
  finally
    FormPrincipal.Free;
  end;
end;
```

### Exemplo 2: Recuperação de Venda Pendente

```
Cenário: Sistema cai durante a venda

1. Operador estava fazendo venda
   ├─ Adicionou 5 produtos
   ├─ Aplicou desconto de R$ 10
   └─ Arquivo de venda pendente foi salvo automaticamente

2. Sistema cai (falta de energia)

3. Operador reinicia o sistema

4. FormCreate é chamado
   └─ VerificarVendaPendente()
      ├─ Detecta arquivo de venda pendente
      ├─ Exibe diálogo: "Existe uma venda pendente. Deseja retomá-la?"
      └─ Operador clica em "SIM"

5. Venda é recuperada
   ├─ Todos os 5 produtos são carregados
   ├─ Desconto de R$ 10 é restaurado
   ├─ Total é recalculado
   ├─ Arquivo é deletado
   └─ ShowMessage: "Venda retomada com sucesso! Itens: 5 | Total: R$ 140.00"

6. Operador continua normalmente
   ├─ Pode adicionar mais produtos
   ├─ Pode remover produtos
   ├─ Pode aplicar desconto adicional
   └─ Pode finalizar a venda
```

### Exemplo 3: Ajuste de Quantidade

```pascal
// Operador seleciona item no carrinho
FItemSelecionadoCarrinho := 0; // Índice do item

// Operador clica em "AUMENTAR"
ButtonAumentarClick(nil);

// Internamente:
// 1. Obter item: ItemVenda := FVendaAtual.GetItem(0);
// 2. Aumentar: ItemVenda.Aumentar(1);
// 3. Atualizar: AtualizarListaCarrinho();
// 4. Salvar: SalvarVendaPendente();
```

### Exemplo 4: Aplicar Desconto

```pascal
// Operador clica em "DESCONTO"
ButtonDescontoClick(nil);

// Internamente:
// 1. InputQuery: "Digite o valor do desconto (R$):"
// 2. Usuário digita: "10.00"
// 3. Validar: TryStrToFloat("10.00", ValorDesconto) = True
// 4. Aplicar: FVendaAtual.AplicarDesconto(10.00, False);
// 5. Atualizar: AtualizarListaCarrinho();
// 6. Salvar: SalvarVendaPendente();
// 7. ShowMessage: "Desconto de R$ 10.00 aplicado"
```

### Exemplo 5: Finalizar Venda

```pascal
// Operador clica em "FINALIZAR"
ButtonFinalizarClick(nil);

// Internamente:
// 1. Validar carrinho (não vazio)
// 2. Validar caixa (aberto)
// 3. MessageDlg: Escolher forma de pagamento
// 4. Operador escolhe: "Dinheiro"
// 5. InputQuery: "Digite o valor recebido (R$):"
// 6. Usuário digita: "100.00"
// 7. Finalizar venda: FVendaAtual.Finalizar(fpDinheiro, 100.00);
// 8. FinalizarVendaCompleta()
//    ├─ Adicionar ao caixa
//    ├─ Imprimir cupom
//    ├─ Deletar arquivo pendente
//    ├─ Limpar venda
//    └─ ShowMessage: "Venda finalizada com sucesso!"
```

---

## 🎯 Resumo

A tela principal responsiva integra:

✅ **Inicialização Completa** - Todos os repositórios e componentes
✅ **Recuperação Automática** - Pergunta ao usuário se deseja retomar
✅ **Interface Responsiva** - Adapta a qualquer resolução
✅ **Gerenciamento Completo** - Carrinho, descontos, acréscimos
✅ **Salvamento Automático** - Venda pendente salva a cada ação
✅ **Finalização Profissional** - Múltiplas formas de pagamento e impressão fiscal
✅ **Tratamento de Erros** - Validações em todos os passos

O sistema garante que **nenhuma venda seja perdida** e oferece uma **experiência de usuário profissional e intuitiva**!
