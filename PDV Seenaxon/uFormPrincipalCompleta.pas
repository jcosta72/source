unit uFormPrincipalCompleta;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  System.Generics.Collections,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.Buttons, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  uOperador, uCaixa, uVenda, uItemVenda, uProduto, uRepositorioProdutos,
  uRepositorioOperadores, uRepositorioCaixa, uImpressoraFiscal, 
  uRecuperacaoVendas;

type
  TFormPrincipalCompleta = class(TForm)
    PanelPrincipal: TPanel;
    PanelCabecalho: TPanel;
    LabelOperador: TLabel;
    LabelStatus: TLabel;
    ButtonGerenciarCaixa: TButton;
    ButtonSair: TButton;
    PanelPesquisa: TPanel;
    LabelPesquisa: TLabel;
    EditPesquisa: TEdit;
    PanelConteudo: TPanel;
    PanelEsquerda: TPanel;
    PanelDireita: TPanel;
    PanelProdutos: TPanel;
    LabelProdutos: TLabel;
    ListBoxProdutos: TListBox;
    PanelCarrinho: TPanel;
    LabelCarrinho: TLabel;
    ListBoxCarrinho: TListBox;
    PanelResumo: TPanel;
    LabelResumo: TLabel;
    MemoResumo: TMemo;
    PanelBotoes: TPanel;
    ButtonRemover: TButton;
    ButtonAumentar: TButton;
    ButtonDiminuir: TButton;
    ButtonDesconto: TButton;
    ButtonAcrescimo: TButton;
    ButtonFinalizar: TButton;
    ButtonLimpar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure EditPesquisaChange(Sender: TObject);
    procedure ListBoxProdutosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ListBoxCarrinhoItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ButtonRemoverClick(Sender: TObject);
    procedure ButtonAumentarClick(Sender: TObject);
    procedure ButtonDiminuirClick(Sender: TObject);
    procedure ButtonDescontoClick(Sender: TObject);
    procedure ButtonAcrescimoClick(Sender: TObject);
    procedure ButtonFinalizarClick(Sender: TObject);
    procedure ButtonLimparClick(Sender: TObject);
    procedure ButtonGerenciarCaixaClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);
  private
    // ===== REPOSITÓRIOS =====
    FRepositorioProdutos: TRepositorioProdutos;
    FRepositorioOperadores: TRepositorioOperadores;
    FRepositorioCaixa: TRepositorioCaixa;
    
    // ===== OBJETOS DA VENDA =====
    FOperadorAtual: TOperador;
    FCaixaAtual: TCaixa;
    FVendaAtual: TVenda;
    FItemSelecionado: Integer;
    
    // ===== UTILITÁRIOS =====
    FRecuperacaoVendas: TRecuperacaoVendas;
    FImpressoraFiscal: TImpressoraFiscal;
    
    // ===== MÉTODOS PRIVADOS =====
    
    { Inicialização }
    procedure InicializarRepositorios;
    procedure RealizarLogin;
    procedure VerificarVendaPendente;
    
    { Carregamento de Dados }
    procedure CarregarProdutos;
    procedure AtualizarListaProdutos(AProdutos: TObjectList<TProduto>);
    
    { Atualização de Interface }
    procedure AtualizarResumoVenda;
    procedure AtualizarListaCarrinho;
    procedure AjustarLayout;
    procedure ExibirDetalhesItem(AIndex: Integer);
    
    { Operações de Venda }
    procedure SalvarVendaPendente;
    procedure LimparVenda;
    procedure FinalizarVendaCompleta;
    
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  FormPrincipalCompleta: TFormPrincipalCompleta;

implementation

{$R *.fmx}

// ============================================================================
// CONSTRUTOR
// ============================================================================

constructor TFormPrincipalCompleta.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItemSelecionado := -1;
end;

// ============================================================================
// EVENTOS DO FORMULÁRIO
// ============================================================================

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

procedure TFormPrincipalCompleta.FormDestroy(Sender: TObject);
begin
  // Liberar venda
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;
  
  // Liberar repositórios
  if Assigned(FRepositorioProdutos) then
    FRepositorioProdutos.Free;
  
  if Assigned(FRepositorioOperadores) then
    FRepositorioOperadores.Free;
  
  if Assigned(FRepositorioCaixa) then
    FRepositorioCaixa.Free;
  
  // Liberar utilitários
  if Assigned(FRecuperacaoVendas) then
    FRecuperacaoVendas.Free;
  
  if Assigned(FImpressoraFiscal) then
    FImpressoraFiscal.Free;
end;

procedure TFormPrincipalCompleta.FormResize(Sender: TObject);
begin
  AjustarLayout;
end;

procedure TFormPrincipalCompleta.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  // Salvar venda pendente se houver itens
  if Assigned(FVendaAtual) and (FVendaAtual.QuantidadeItens > 0) then
  begin
    SalvarVendaPendente;
  end;
  
  CanClose := True;
end;

// ============================================================================
// INICIALIZAÇÃO
// ============================================================================

procedure TFormPrincipalCompleta.InicializarRepositorios;
begin
  { Criar repositórios }
  FRepositorioProdutos := TRepositorioProdutos.Create;
  FRepositorioOperadores := TRepositorioOperadores.Create;
  FRepositorioCaixa := TRepositorioCaixa.Create;
  FRecuperacaoVendas := TRecuperacaoVendas.Create(FRepositorioProdutos, faXML);
  
  { Carregar dados de teste }
  FRepositorioProdutos.CarregarProdutosTeste;
  FRepositorioOperadores.CarregarOperadoresTeste;
end;

procedure TFormPrincipalCompleta.RealizarLogin;
begin
  { Para este exemplo, usaremos um operador de teste }
  FOperadorAtual := TOperador.Create(1, 'MARCOS SILVA DE MATOS', '001', '1234');
  
  { Atualizar label do operador }
  LabelOperador.Text := Format('Operador: %s (Matrícula: %s)', 
    [FOperadorAtual.Nome, FOperadorAtual.Matricula]);
  
  { Criar caixa para o operador }
  FCaixaAtual := TCaixa.Create(1, FOperadorAtual, 0);
end;

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

// ============================================================================
// CARREGAMENTO DE DADOS
// ============================================================================

procedure TFormPrincipalCompleta.CarregarProdutos;
var
  Produtos: TObjectList<TProduto>;
begin
  { Carregar todos os produtos do repositório }
  Produtos := FRepositorioProdutos.ObterTodos;
  try
    AtualizarListaProdutos(Produtos);
  finally
    Produtos.Free;
  end;
end;

procedure TFormPrincipalCompleta.AtualizarListaProdutos(AProdutos: TObjectList<TProduto>);
var
  i: Integer;
  Item: TListBoxItem;
begin
  ListBoxProdutos.Clear;
  
  if AProdutos.Count = 0 then
  begin
    Item := TListBoxItem.Create(ListBoxProdutos);
    Item.Parent := ListBoxProdutos;
    Item.Text := 'Nenhum produto encontrado';
    Item.Enabled := False;
    Exit;
  end;
  
  { Adicionar cada produto à lista }
  for i := 0 to AProdutos.Count - 1 do
  begin
    Item := TListBoxItem.Create(ListBoxProdutos);
    Item.Parent := ListBoxProdutos;
    Item.Text := Format('%s - R$ %.2f', 
      [AProdutos[i].Nome, AProdutos[i].Preco]);
    Item.Tag := AProdutos[i].ID;
  end;
end;

// ============================================================================
// ATUALIZAÇÃO DE INTERFACE
// ============================================================================

procedure TFormPrincipalCompleta.AtualizarResumoVenda;
var
  Texto: string;
begin
  Texto := '';
  Texto := Texto + '═══════════════════════════════════════' + sLineBreak;
  Texto := Texto + 'RESUMO DA VENDA' + sLineBreak;
  Texto := Texto + '═══════════════════════════════════════' + sLineBreak + sLineBreak;
  
  Texto := Texto + Format('Operador: %s', [FOperadorAtual.Nome]) + sLineBreak;
  Texto := Texto + Format('Itens: %d', [FVendaAtual.QuantidadeItens]) + sLineBreak;
  Texto := Texto + sLineBreak;
  
  Texto := Texto + '───────────────────────────────────────' + sLineBreak;
  Texto := Texto + Format('Subtotal: R$ %.2f', [FVendaAtual.Subtotal]) + sLineBreak;
  
  if FVendaAtual.Desconto > 0 then
    Texto := Texto + Format('Desconto: -R$ %.2f', [FVendaAtual.Desconto]) + sLineBreak;
  
  if FVendaAtual.Acrescimo > 0 then
    Texto := Texto + Format('Acréscimo: +R$ %.2f', [FVendaAtual.Acrescimo]) + sLineBreak;
  
  Texto := Texto + '───────────────────────────────────────' + sLineBreak;
  Texto := Texto + Format('TOTAL: R$ %.2f', [FVendaAtual.Total]) + sLineBreak;
  Texto := Texto + '═══════════════════════════════════════';
  
  MemoResumo.Text := Texto;
end;

procedure TFormPrincipalCompleta.AtualizarListaCarrinho;
var
  i: Integer;
  Item: TListBoxItem;
  ItemVenda: TItemVenda;
begin
  ListBoxCarrinho.Clear;
  
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    Item := TListBoxItem.Create(ListBoxCarrinho);
    Item.Parent := ListBoxCarrinho;
    Item.Text := 'Carrinho vazio';
    Item.Enabled := False;
    Exit;
  end;
  
  { Adicionar cada item do carrinho }
  for i := 0 to FVendaAtual.QuantidadeItens - 1 do
  begin
    ItemVenda := FVendaAtual.GetItem(i);
    if Assigned(ItemVenda) then
    begin
      Item := TListBoxItem.Create(ListBoxCarrinho);
      Item.Parent := ListBoxCarrinho;
      Item.Text := Format('%d. %s - %.0f x R$ %.2f = R$ %.2f', 
        [i + 1, ItemVenda.Produto.Nome, ItemVenda.Quantidade, 
         ItemVenda.ValorUnitario, ItemVenda.ValorTotal]);
      Item.Tag := i;
    end;
  end;
end;

procedure TFormPrincipalCompleta.AjustarLayout;
var
  LarguraTela: Single;
begin
  LarguraTela := PanelConteudo.Width;
  
  { Ajustar proporção dos painéis conforme tamanho da tela }
  if LarguraTela < 1000 then
  begin
    PanelEsquerda.Width := LarguraTela * 0.65;
  end
  else if LarguraTela < 1400 then
  begin
    PanelEsquerda.Width := LarguraTela * 0.62;
  end
  else
  begin
    PanelEsquerda.Width := LarguraTela * 0.60;
  end;
end;

procedure TFormPrincipalCompleta.ExibirDetalhesItem(AIndex: Integer);
var
  ItemVenda: TItemVenda;
  Texto: string;
begin
  if (AIndex < 0) or (AIndex >= FVendaAtual.QuantidadeItens) then
    Exit;
  
  ItemVenda := FVendaAtual.GetItem(AIndex);
  
  if Assigned(ItemVenda) then
  begin
    Texto := '';
    Texto := Texto + '═══════════════════════════════════════' + sLineBreak;
    Texto := Texto + 'DETALHES DO ITEM' + sLineBreak;
    Texto := Texto + '═══════════════════════════════════════' + sLineBreak + sLineBreak;
    
    Texto := Texto + Format('Produto: %s', [ItemVenda.Produto.Nome]) + sLineBreak;
    Texto := Texto + Format('Quantidade: %.0f', [ItemVenda.Quantidade]) + sLineBreak;
    Texto := Texto + Format('Preço Unitário: R$ %.2f', [ItemVenda.ValorUnitario]) + sLineBreak;
    Texto := Texto + Format('Valor Total: R$ %.2f', [ItemVenda.ValorTotal]) + sLineBreak;
    
    if ItemVenda.Desconto > 0 then
      Texto := Texto + Format('Desconto: R$ %.2f (%.2f%%)', 
        [ItemVenda.Desconto, ItemVenda.PercentualDesconto]) + sLineBreak;
    
    MemoResumo.Text := Texto;
  end;
end;

// ============================================================================
// OPERAÇÕES DE VENDA
// ============================================================================

procedure TFormPrincipalCompleta.SalvarVendaPendente;
begin
  { Salvar venda em arquivo para recuperação em caso de interrupção }
  if Assigned(FVendaAtual) and (FVendaAtual.QuantidadeItens > 0) then
  begin
    FRecuperacaoVendas.SalvarVendaPendente(FVendaAtual);
  end;
end;

procedure TFormPrincipalCompleta.LimparVenda;
begin
  { Liberar venda anterior }
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;
  
  { Criar nova venda }
  FVendaAtual := TVenda.Create;
  FVendaAtual.OperadorID := FOperadorAtual.ID;
  FItemSelecionado := -1;
  
  { Atualizar interface }
  AtualizarResumoVenda;
  AtualizarListaCarrinho;
end;

procedure TFormPrincipalCompleta.FinalizarVendaCompleta;
begin
  { Finalizar venda com dinheiro (para este exemplo) }
  FVendaAtual.Finalizar(fpDinheiro, FVendaAtual.Total);
  
  { Adicionar venda ao caixa }
  FCaixaAtual := FRepositorioCaixa.ObterCaixaAberto;
  if not Assigned(FCaixaAtual) then
  begin
    { Se não houver caixa aberto, criar um }
    FCaixaAtual := FRepositorioCaixa.AbrirCaixa(FOperadorAtual, 100.00);
  end;
  
  if Assigned(FCaixaAtual) then
  begin
    FCaixaAtual.AdicionarVenda(FVendaAtual);
  end;
  
  { Imprimir cupom fiscal }
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
  
  { Deletar arquivo de venda pendente }
  FRecuperacaoVendas.DeletarVendaPendente;
  
  { Limpar venda para próxima }
  LimparVenda;
  
  ShowMessage('Venda finalizada com sucesso!');
end;

// ============================================================================
// EVENTOS DE CLIQUE
// ============================================================================

procedure TFormPrincipalCompleta.EditPesquisaChange(Sender: TObject);
var
  Produtos: TObjectList<TProduto>;
begin
  { Buscar produtos por nome em tempo real }
  if EditPesquisa.Text = '' then
  begin
    CarregarProdutos;
  end
  else
  begin
    Produtos := FRepositorioProdutos.BuscarPorNome(EditPesquisa.Text);
    try
      AtualizarListaProdutos(Produtos);
    finally
      Produtos.Free;
    end;
  end;
end;

procedure TFormPrincipalCompleta.ListBoxProdutosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
var
  Produto: TProduto;
  NovoItem: TItemVenda;
begin
  { Adicionar produto ao carrinho quando clicado }
  Produto := FRepositorioProdutos.BuscarPorID(Item.Tag);
  
  if Assigned(Produto) then
  begin
    { Criar novo item de venda }
    NovoItem := TItemVenda.Create(Produto, 1);
    
    { Adicionar à venda }
    FVendaAtual.AdicionarItem(NovoItem);
    
    { Atualizar interface }
    AtualizarResumoVenda;
    AtualizarListaCarrinho;
    
    { Salvar venda pendente }
    SalvarVendaPendente;
    
    ShowMessage(Format('%s adicionado ao carrinho', [Produto.Nome]));
  end;
end;

procedure TFormPrincipalCompleta.ListBoxCarrinhoItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  { Exibir detalhes do item quando clicado }
  if Assigned(Item) then
  begin
    FItemSelecionado := Item.Tag;
    ExibirDetalhesItem(FItemSelecionado);
  end;
end;

procedure TFormPrincipalCompleta.ButtonRemoverClick(Sender: TObject);
begin
  { Remover item selecionado }
  if FItemSelecionado >= 0 then
  begin
    FVendaAtual.RemoverItem(FItemSelecionado);
    FItemSelecionado := -1;
    AtualizarResumoVenda;
    AtualizarListaCarrinho;
    SalvarVendaPendente;
    ShowMessage('Item removido');
  end
  else
  begin
    ShowMessage('Selecione um item para remover');
  end;
end;

procedure TFormPrincipalCompleta.ButtonAumentarClick(Sender: TObject);
var
  ItemVenda: TItemVenda;
begin
  { Aumentar quantidade do item selecionado }
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
  end
  else
  begin
    ShowMessage('Selecione um item para aumentar');
  end;
end;

procedure TFormPrincipalCompleta.ButtonDiminuirClick(Sender: TObject);
var
  ItemVenda: TItemVenda;
begin
  { Diminuir quantidade do item selecionado }
  if FItemSelecionado >= 0 then
  begin
    ItemVenda := FVendaAtual.GetItem(FItemSelecionado);
    if Assigned(ItemVenda) then
    begin
      if ItemVenda.Quantidade > 1 then
      begin
        ItemVenda.Diminuir(1);
        AtualizarResumoVenda;
        AtualizarListaCarrinho;
        ExibirDetalhesItem(FItemSelecionado);
        SalvarVendaPendente;
      end
      else
      begin
        ShowMessage('Quantidade mínima é 1');
      end;
    end;
  end
  else
  begin
    ShowMessage('Selecione um item para diminuir');
  end;
end;

procedure TFormPrincipalCompleta.ButtonDescontoClick(Sender: TObject);
var
  Desconto: string;
  ValorDesconto: Double;
begin
  { Aplicar desconto à venda }
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;
  
  { Solicitar valor do desconto }
  if InputQuery('Desconto', 'Digite o valor do desconto (R$):', Desconto) then
  begin
    if TryStrToFloat(Desconto, ValorDesconto) then
    begin
      FVendaAtual.AplicarDesconto(ValorDesconto, False);
      AtualizarResumoVenda;
      SalvarVendaPendente;
    end
    else
    begin
      ShowMessage('Valor inválido');
    end;
  end;
end;

procedure TFormPrincipalCompleta.ButtonAcrescimoClick(Sender: TObject);
var
  Acrescimo: string;
  ValorAcrescimo: Double;
begin
  { Aplicar acréscimo à venda }
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;
  
  { Solicitar valor do acréscimo }
  if InputQuery('Acréscimo', 'Digite o valor do acréscimo (R$):', Acrescimo) then
  begin
    if TryStrToFloat(Acrescimo, ValorAcrescimo) then
    begin
      FVendaAtual.AplicarAcrescimo(ValorAcrescimo, False);
      AtualizarResumoVenda;
      SalvarVendaPendente;
    end
    else
    begin
      ShowMessage('Valor inválido');
    end;
  end;
end;

procedure TFormPrincipalCompleta.ButtonFinalizarClick(Sender: TObject);
begin
  { Finalizar venda completa }
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;
  
  { Verificar se caixa está aberto }
  if not FRepositorioCaixa.TemCaixaAberto then
  begin
    ShowMessage('Abra o caixa primeiro');
    Exit;
  end;
  
  { Finalizar venda }
  FinalizarVendaCompleta;
end;

procedure TFormPrincipalCompleta.ButtonLimparClick(Sender: TObject);
begin
  { Limpar carrinho com confirmação }
  if MessageDlg('Deseja limpar o carrinho?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    LimparVenda;
    FRecuperacaoVendas.DeletarVendaPendente;
  end;
end;

procedure TFormPrincipalCompleta.ButtonGerenciarCaixaClick(Sender: TObject);
begin
  { Abrir gerenciamento de caixa }
  ShowMessage('Gerenciar Caixa - Implementar integração com uFormCaixa');
end;

procedure TFormPrincipalCompleta.ButtonSairClick(Sender: TObject);
begin
  { Sair do sistema }
  Close;
end;

end.
