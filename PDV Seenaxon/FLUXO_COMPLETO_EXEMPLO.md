# Fluxo Completo do Sistema PDV - Exemplos Práticos

## 📋 Índice

1. [Fluxo de Inicialização](#fluxo-de-inicialização)
2. [Fluxo de Venda Completa](#fluxo-de-venda-completa)
3. [Recuperação de Venda Pendente](#recuperação-de-venda-pendente)
4. [Exemplos de Código](#exemplos-de-código)
5. [Casos de Uso](#casos-de-uso)

---

## Fluxo de Inicialização

### Sequência de Eventos ao Iniciar o Sistema

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
   ├─ Criar TOperador
   ├─ Criar TCaixa
   └─ Atualizar interface com dados do operador
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
6. AjustarLayout()
   ├─ Calcular proporções dos painéis
   └─ Ajustar responsividade
   ↓
7. Criar TVenda inicial
   ├─ Instanciar TVenda
   └─ Definir OperadorID
   ↓
8. AtualizarResumoVenda()
   └─ Exibir resumo inicial (carrinho vazio)
```

### Código de Inicialização

```pascal
procedure TFormPrincipalCompleta.FormCreate(Sender: TObject);
begin
  { Passo 1: Inicializar repositórios }
  InicializarRepositorios;
  
  { Passo 2: Realizar login do operador }
  RealizarLogin;
  
  { Passo 3: Verificar venda pendente (recuperação após interrupção) }
  VerificarVendaPendente;
  
  { Passo 4: Carregar produtos }
  CarregarProdutos;
  
  { Passo 5: Ajustar layout responsivo }
  AjustarLayout;
  
  { Passo 6: Criar venda inicial }
  if not Assigned(FVendaAtual) then
  begin
    FVendaAtual := TVenda.Create;
    FVendaAtual.OperadorID := FOperadorAtual.ID;
  end;
  
  { Passo 7: Atualizar interface }
  AtualizarResumoVenda;
  AtualizarListaCarrinho;
end;
```

---

## Fluxo de Venda Completa

### Sequência Passo a Passo

```
TELA PRINCIPAL CARREGADA
    ↓
OPERADOR CLICA EM PRODUTO (ex: LIVRO)
    ↓
ListBoxProdutosItemClick é disparado
    ├─ Buscar produto no repositório
    ├─ Criar TItemVenda
    ├─ Adicionar à TVenda
    ├─ AtualizarResumoVenda()
    ├─ AtualizarListaCarrinho()
    ├─ SalvarVendaPendente()
    └─ Exibir mensagem de confirmação
    ↓
OPERADOR CLICA EM OUTRO PRODUTO (ex: CANETA)
    ├─ Repetir processo anterior
    └─ Carrinho agora tem 2 itens
    ↓
OPERADOR SELECIONA ITEM NO CARRINHO
    ├─ ListBoxCarrinhoItemClick é disparado
    ├─ ExibirDetalhesItem()
    └─ Mostrar informações do item
    ↓
OPERADOR CLICA EM "AUMENTAR"
    ├─ ButtonAumentarClick é disparado
    ├─ Buscar item selecionado
    ├─ Aumentar quantidade em 1
    ├─ AtualizarResumoVenda()
    ├─ AtualizarListaCarrinho()
    ├─ SalvarVendaPendente()
    └─ Atualizar detalhes do item
    ↓
OPERADOR CLICA EM "DESCONTO"
    ├─ ButtonDescontoClick é disparado
    ├─ Solicitar valor do desconto
    ├─ Validar valor
    ├─ AplicarDesconto() na venda
    ├─ AtualizarResumoVenda()
    ├─ SalvarVendaPendente()
    └─ Exibir novo total
    ↓
OPERADOR CLICA EM "FINALIZAR"
    ├─ ButtonFinalizarClick é disparado
    ├─ Validar carrinho não vazio
    ├─ Validar caixa aberto
    ├─ FinalizarVendaCompleta()
    │  ├─ Finalizar venda com forma de pagamento
    │  ├─ Adicionar venda ao caixa
    │  ├─ Criar TImpressoraFiscal
    │  ├─ Gerar cupom
    │  ├─ Imprimir cupom
    │  ├─ Deletar arquivo de venda pendente
    │  └─ LimparVenda()
    └─ Exibir mensagem de sucesso
    ↓
NOVA VENDA PRONTA PARA COMEÇAR
```

### Código do Fluxo de Venda

```pascal
{ Passo 1: Adicionar produto }
procedure TFormPrincipalCompleta.ListBoxProdutosItemClick(
  const Sender: TCustomListBox; const Item: TListBoxItem);
var
  Produto: TProduto;
  NovoItem: TItemVenda;
begin
  Produto := FRepositorioProdutos.BuscarPorID(Item.Tag);
  
  if Assigned(Produto) then
  begin
    NovoItem := TItemVenda.Create(Produto, 1);
    FVendaAtual.AdicionarItem(NovoItem);
    
    AtualizarResumoVenda;
    AtualizarListaCarrinho;
    SalvarVendaPendente;
    
    ShowMessage(Format('%s adicionado ao carrinho', [Produto.Nome]));
  end;
end;

{ Passo 2: Aumentar quantidade }
procedure TFormPrincipalCompleta.ButtonAumentarClick(Sender: TObject);
var
  ItemVenda: TItemVenda;
begin
  if FItemSelecionado >= 0 then
  begin
    ItemVenda := FVendaAtual.GetItem(FItemSelecionado);
    if Assigned(ItemVenda) then
    begin
      ItemVenda.Aumentar(1);
      AtualizarResumoVenda;
      AtualizarListaCarrinho;
      ExibirDetalhesItem(FItemSelecionado);
      SalvarVendaPendente;
    end;
  end;
end;

{ Passo 3: Aplicar desconto }
procedure TFormPrincipalCompleta.ButtonDescontoClick(Sender: TObject);
var
  Desconto: string;
  ValorDesconto: Double;
begin
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;
  
  if InputQuery('Desconto', 'Digite o valor do desconto (R$):', Desconto) then
  begin
    if TryStrToFloat(Desconto, ValorDesconto) then
    begin
      FVendaAtual.AplicarDesconto(ValorDesconto, False);
      AtualizarResumoVenda;
      SalvarVendaPendente;
    end;
  end;
end;

{ Passo 4: Finalizar venda }
procedure TFormPrincipalCompleta.ButtonFinalizarClick(Sender: TObject);
begin
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;
  
  if not FRepositorioCaixa.TemCaixaAberto then
  begin
    ShowMessage('Abra o caixa primeiro');
    Exit;
  end;
  
  FinalizarVendaCompleta;
end;

{ Passo 5: Finalizar venda completa }
procedure TFormPrincipalCompleta.FinalizarVendaCompleta;
begin
  FVendaAtual.Finalizar(fpDinheiro, FVendaAtual.Total);
  
  FCaixaAtual := FRepositorioCaixa.ObterCaixaAberto;
  if Assigned(FCaixaAtual) then
  begin
    FCaixaAtual.AdicionarVenda(FVendaAtual);
  end;
  
  FImpressoraFiscal := TImpressoraFiscal.Create(FCaixaAtual, FOperadorAtual);
  try
    FImpressoraFiscal.ConfigurarEmpresa('PDV SEENAXON', '00.000.000/0000-00',
      '00.000.000.000.000', 'Rua Exemplo, 123 - São Paulo - SP', 
      '(11) 3000-0000', 'www.seenaxon.com.br');
    FImpressoraFiscal.ConfigurarECF(FCaixaAtual.Vendas.Count, '001');
    FImpressoraFiscal.ImprimirCupomVenda(FVendaAtual);
  finally
    FImpressoraFiscal.Free;
  end;
  
  FRecuperacaoVendas.DeletarVendaPendente;
  LimparVenda;
  
  ShowMessage('Venda finalizada com sucesso!');
end;
```

---

## Recuperação de Venda Pendente

### Cenário: Sistema Cai Durante a Venda

```
OPERADOR ESTÁ REALIZANDO VENDA
    ├─ Adicionou 5 produtos
    ├─ Aplicou desconto de R$ 10
    ├─ Total: R$ 150
    └─ Arquivo de venda pendente é salvo a cada ação
    ↓
SISTEMA CAIR (falta de energia, crash, etc)
    ↓
OPERADOR REINICIA O SISTEMA
    ↓
FormCreate é chamado
    ├─ InicializarRepositorios()
    ├─ RealizarLogin()
    └─ VerificarVendaPendente()
       ├─ Detecta arquivo de venda pendente
       ├─ Exibe diálogo: "Existe uma venda pendente. Deseja retomá-la?"
       └─ Operador clica em "SIM"
    ↓
CarregarVendaPendente()
    ├─ Ler arquivo XML
    ├─ Reconstruir TVenda
    ├─ Reconstruir todos os TItemVenda
    ├─ Restaurar descontos
    ├─ Restaurar acréscimos
    └─ Deletar arquivo
    ↓
VENDA RESTAURADA COM SUCESSO
    ├─ Operador vê: "Venda retomada com sucesso!"
    ├─ Operador vê: "Itens: 5 | Total: R$ 150"
    └─ Carrinho mostra todos os 5 produtos
    ↓
OPERADOR CONTINUA NORMALMENTE
    ├─ Pode adicionar mais produtos
    ├─ Pode remover produtos
    ├─ Pode aplicar desconto adicional
    └─ Pode finalizar a venda
```

### Código de Recuperação

```pascal
procedure TFormPrincipalCompleta.VerificarVendaPendente;
var
  VendaPendente: TVenda;
begin
  { Verificar se existe arquivo de venda pendente }
  if FRecuperacaoVendas.TemVendaPendente then
  begin
    { Perguntar ao usuário se deseja retomar }
    if MessageDlg('Existe uma venda pendente. Deseja retomá-la?', 
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    begin
      { Carregar venda pendente }
      VendaPendente := FRecuperacaoVendas.CarregarVendaPendente;
      
      if Assigned(VendaPendente) then
      begin
        { Liberar venda anterior se existir }
        if Assigned(FVendaAtual) then
          FVendaAtual.Free;
        
        { Usar venda recuperada }
        FVendaAtual := VendaPendente;
        FVendaAtual.OperadorID := FOperadorAtual.ID;
        
        { Deletar arquivo de recuperação }
        FRecuperacaoVendas.DeletarVendaPendente;
        
        ShowMessage('Venda retomada com sucesso!' + sLineBreak +
          Format('Itens: %d | Total: R$ %.2f', 
          [FVendaAtual.QuantidadeItens, FVendaAtual.Total]));
      end;
    end
    else
    begin
      { Deletar arquivo de recuperação }
      FRecuperacaoVendas.DeletarVendaPendente;
    end;
  end;
end;
```

### Arquivo XML Gerado

```xml
<?xml version="1.0" encoding="UTF-8"?>
<VendaPendente versao="1.0" data="2025-12-28 14:30:45">
  <Venda>
    <OperadorID>1</OperadorID>
    <Subtotal>150.00</Subtotal>
    <Desconto>10.00</Desconto>
    <PercentualDesconto>6.67</PercentualDesconto>
    <Acrescimo>0.00</Acrescimo>
    <PercentualAcrescimo>0.00</PercentualAcrescimo>
    <Total>140.00</Total>
    <Itens>
      <Item>
        <ProdutoID>1</ProdutoID>
        <ProdutoNome>LIVRO</ProdutoNome>
        <ProdutoPreco>29.90</ProdutoPreco>
        <Quantidade>2</Quantidade>
        <ValorUnitario>29.90</ValorUnitario>
        <ValorTotal>59.80</ValorTotal>
      </Item>
      <Item>
        <ProdutoID>2</ProdutoID>
        <ProdutoNome>CANETA</ProdutoNome>
        <ProdutoPreco>5.00</ProdutoPreco>
        <Quantidade>3</Quantidade>
        <ValorUnitario>5.00</ValorUnitario>
        <ValorTotal>15.00</ValorTotal>
      </Item>
      <Item>
        <ProdutoID>3</ProdutoID>
        <ProdutoNome>CADERNO</ProdutoNome>
        <ProdutoPreco>25.00</ProdutoPreco>
        <Quantidade>1</Quantidade>
        <ValorUnitario>25.00</ValorUnitario>
        <ValorTotal>25.00</ValorTotal>
      </Item>
      <Item>
        <ProdutoID>4</ProdutoID>
        <ProdutoNome>LÁPIS</ProdutoNome>
        <ProdutoPreco>2.50</ProdutoPreco>
        <Quantidade>10</Quantidade>
        <ValorUnitario>2.50</ValorUnitario>
        <ValorTotal>25.00</ValorTotal>
      </Item>
      <Item>
        <ProdutoID>5</ProdutoID>
        <ProdutoNome>BORRACHA</ProdutoNome>
        <ProdutoPreco>1.50</ProdutoPreco>
        <Quantidade>5</Quantidade>
        <ValorUnitario>1.50</ValorUnitario>
        <ValorTotal>7.50</ValorTotal>
      </Item>
    </Itens>
  </Venda>
</VendaPendente>
```

---

## Exemplos de Código

### Exemplo 1: Criar Repositório e Carregar Produtos

```pascal
var
  Repositorio: TRepositorioProdutos;
  Produtos: TObjectList<TProduto>;
  i: Integer;
begin
  { Criar repositório }
  Repositorio := TRepositorioProdutos.Create;
  try
    { Carregar dados de teste }
    Repositorio.CarregarProdutosTeste;
    
    { Obter todos os produtos }
    Produtos := Repositorio.ObterTodos;
    try
      { Exibir produtos }
      for i := 0 to Produtos.Count - 1 do
      begin
        WriteLn(Format('ID: %d | Nome: %s | Preço: R$ %.2f',
          [Produtos[i].ID, Produtos[i].Nome, Produtos[i].Preco]));
      end;
    finally
      Produtos.Free;
    end;
  finally
    Repositorio.Free;
  end;
end;
```

### Exemplo 2: Criar Venda e Adicionar Itens

```pascal
var
  Produto1, Produto2: TProduto;
  Item1, Item2: TItemVenda;
  Venda: TVenda;
begin
  { Criar produtos }
  Produto1 := TProduto.Create(1, 'LIVRO', 'Livro de Ficção', 29.90);
  Produto2 := TProduto.Create(2, 'CANETA', 'Caneta Azul', 5.00);
  
  { Criar venda }
  Venda := TVenda.Create;
  Venda.OperadorID := 1;
  
  { Criar itens }
  Item1 := TItemVenda.Create(Produto1, 2);
  Item2 := TItemVenda.Create(Produto2, 5);
  
  { Adicionar itens à venda }
  Venda.AdicionarItem(Item1);
  Venda.AdicionarItem(Item2);
  
  { Exibir resumo }
  WriteLn(Format('Subtotal: R$ %.2f', [Venda.Subtotal]));
  WriteLn(Format('Total: R$ %.2f', [Venda.Total]));
  
  { Aplicar desconto }
  Venda.AplicarDesconto(10, True); { 10% }
  WriteLn(Format('Desconto: R$ %.2f', [Venda.Desconto]));
  WriteLn(Format('Total com desconto: R$ %.2f', [Venda.Total]));
  
  { Liberar }
  Venda.Free;
  Produto1.Free;
  Produto2.Free;
end;
```

### Exemplo 3: Finalizar Venda e Imprimir Cupom

```pascal
var
  Caixa: TCaixa;
  Operador: TOperador;
  Venda: TVenda;
  Impressora: TImpressoraFiscal;
  Produto: TProduto;
  Item: TItemVenda;
begin
  { Criar operador }
  Operador := TOperador.Create(1, 'JOÃO SILVA', '001', '1234');
  
  { Criar caixa }
  Caixa := TCaixa.Create(1, Operador, 100.00);
  Caixa.Abrir(100.00);
  
  { Criar venda }
  Venda := TVenda.Create;
  Venda.OperadorID := Operador.ID;
  
  { Adicionar produto }
  Produto := TProduto.Create(1, 'LIVRO', 'Livro', 29.90);
  Item := TItemVenda.Create(Produto, 2);
  Venda.AdicionarItem(Item);
  
  { Finalizar venda }
  Venda.Finalizar(fpDinheiro, 100.00);
  
  { Adicionar ao caixa }
  Caixa.AdicionarVenda(Venda);
  
  { Imprimir cupom }
  Impressora := TImpressoraFiscal.Create(Caixa, Operador);
  try
    Impressora.ConfigurarEmpresa('PDV SEENAXON', '00.000.000/0000-00',
      '00.000.000.000.000', 'Rua Exemplo, 123', '(11) 3000-0000', 'www.seenaxon.com.br');
    Impressora.ImprimirCupomVenda(Venda);
  finally
    Impressora.Free;
  end;
  
  { Fechar caixa }
  Caixa.Fechar;
  
  { Liberar }
  Venda.Free;
  Caixa.Free;
  Operador.Free;
  Produto.Free;
end;
```

### Exemplo 4: Salvar e Recuperar Venda Pendente

```pascal
var
  Recuperacao: TRecuperacaoVendas;
  Repositorio: TRepositorioProdutos;
  Venda: TVenda;
  VendaRecuperada: TVenda;
  Produto: TProduto;
  Item: TItemVenda;
begin
  { Criar repositório }
  Repositorio := TRepositorioProdutos.Create;
  Repositorio.CarregarProdutosTeste;
  
  { Criar recuperação }
  Recuperacao := TRecuperacaoVendas.Create(Repositorio, faXML);
  
  { Criar venda }
  Venda := TVenda.Create;
  Venda.OperadorID := 1;
  
  { Adicionar produtos }
  Produto := TProduto.Create(1, 'LIVRO', 'Livro', 29.90);
  Item := TItemVenda.Create(Produto, 2);
  Venda.AdicionarItem(Item);
  
  { Salvar venda pendente }
  Recuperacao.SalvarVendaPendente(Venda);
  WriteLn('Venda salva com sucesso!');
  
  { Simular crash do sistema }
  Venda.Free;
  
  { Recuperar venda }
  if Recuperacao.TemVendaPendente then
  begin
    VendaRecuperada := Recuperacao.CarregarVendaPendente;
    WriteLn(Format('Venda recuperada! Itens: %d | Total: R$ %.2f',
      [VendaRecuperada.QuantidadeItens, VendaRecuperada.Total]));
    VendaRecuperada.Free;
  end;
  
  { Deletar arquivo }
  Recuperacao.DeletarVendaPendente;
  
  { Liberar }
  Recuperacao.Free;
  Repositorio.Free;
  Produto.Free;
end;
```

---

## Casos de Uso

### Caso 1: Venda Simples com Dinheiro

```
1. Operador clica em "LIVRO" → Adicionado ao carrinho
2. Operador clica em "CANETA" → Adicionado ao carrinho
3. Operador clica em "FINALIZAR" → Venda finalizada
4. Cupom impresso → Venda concluída
```

### Caso 2: Venda com Desconto

```
1. Operador clica em "LIVRO" → Adicionado ao carrinho
2. Operador clica em "DESCONTO" → Digita R$ 5.00
3. Desconto aplicado → Total reduzido
4. Operador clica em "FINALIZAR" → Venda finalizada
5. Cupom impresso com desconto → Venda concluída
```

### Caso 3: Venda com Ajuste de Quantidade

```
1. Operador clica em "LIVRO" → Adicionado (1 unidade)
2. Operador seleciona item → Clica em "AUMENTAR" 3 vezes
3. Quantidade agora é 4 → Total atualizado
4. Operador clica em "FINALIZAR" → Venda finalizada
5. Cupom impresso com 4 unidades → Venda concluída
```

### Caso 4: Recuperação Após Interrupção

```
1. Operador clica em "LIVRO" → Adicionado
2. Operador clica em "CANETA" → Adicionado
3. Operador aplica desconto → R$ 5.00
4. SISTEMA CAI (falta de energia)
5. Operador reinicia sistema
6. Diálogo: "Existe venda pendente. Retomar?"
7. Operador clica em "SIM"
8. Venda recuperada com 2 itens e desconto
9. Operador finaliza venda → Venda concluída
```

### Caso 5: Múltiplas Vendas em Sequência

```
Venda 1:
1. Adicionar produtos
2. Finalizar
3. Imprimir cupom

Venda 2 (Automática):
1. Carrinho limpo
2. Pronto para nova venda
3. Adicionar produtos
4. Finalizar
5. Imprimir cupom

... (repetir para cada venda)
```

---

## 🎯 Resumo do Fluxo

| Etapa | Função | Status |
|-------|--------|--------|
| **Inicialização** | FormCreate → Repositórios → Login → Verificar Pendente | ✅ Completo |
| **Carregamento** | Carregar Produtos → Atualizar Interface | ✅ Completo |
| **Adição** | Clicar Produto → Criar Item → Adicionar à Venda | ✅ Completo |
| **Ajuste** | Aumentar/Diminuir Quantidade → Atualizar Totais | ✅ Completo |
| **Desconto** | Aplicar Desconto → Recalcular Total | ✅ Completo |
| **Finalização** | Finalizar Venda → Imprimir Cupom → Limpar Carrinho | ✅ Completo |
| **Recuperação** | Detectar Pendente → Perguntar → Carregar → Continuar | ✅ Completo |

---

## 📁 Arquivo Principal

**Arquivo:** `uFormPrincipalCompleta.pas`

Este arquivo contém a implementação completa do fluxo do sistema com:
- ✅ Inicialização com verificação de venda pendente
- ✅ Carregamento de produtos
- ✅ Adição/remoção de itens
- ✅ Ajuste de quantidade
- ✅ Aplicação de desconto/acréscimo
- ✅ Finalização de venda
- ✅ Impressão de cupom
- ✅ Recuperação de vendas pendentes
- ✅ Interface responsiva

O código está totalmente comentado e pronto para ser integrado ao seu projeto Delphi Sydney com FMX!
