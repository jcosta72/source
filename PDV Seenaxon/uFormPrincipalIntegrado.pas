unit uFormPrincipalIntegrado;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.Buttons, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  System.Generics.Collections,
  uProduto, uVenda, uOperador, uCaixa, uRepositorioProdutos, uItemVenda,
  uFormLogin, uFormCaixa, uRepositorioOperadores;

type
  TFormPrincipalIntegrado = class(TForm)
    PanelPrincipal: TPanel;
    PanelCabecalho: TPanel;
    LabelOperador: TLabel;
    LabelStatusCaixa: TLabel;
    ButtonCaixa: TButton;
    ButtonSair: TButton;
    PanelConteudo: TPanel;
    PanelEsquerda: TPanel;
    PanelDireita: TPanel;
    PanelTabela: TPanel;
    LabelProdutos: TLabel;
    ListBoxProdutos: TListBox;
    PanelPesquisa: TPanel;
    EditPesquisa: TEdit;
    LabelPesquisa: TLabel;
    PanelBotoes: TPanel;
    PanelResumo: TPanel;
    LabelResumo: TLabel;
    MemoResumo: TMemo;
    PanelAcoes: TPanel;
    ButtonDesconto: TButton;
    ButtonAcrescimo: TButton;
    ButtonFinalizarVenda: TButton;
    ButtonLimparCarrinho: TButton;
    PanelBotoesRapidos: TPanel;
    ButtonRemover: TButton;
    ButtonAumentar: TButton;
    ButtonDiminuir: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditPesquisaChange(Sender: TObject);
    procedure ListBoxProdutosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ButtonDescontoClick(Sender: TObject);
    procedure ButtonAcrescimoClick(Sender: TObject);
    procedure ButtonFinalizarVendaClick(Sender: TObject);
    procedure ButtonLimparCarrinhoClick(Sender: TObject);
    procedure ButtonRemoverClick(Sender: TObject);
    procedure ButtonAumentarClick(Sender: TObject);
    procedure ButtonDiminuirClick(Sender: TObject);
    procedure ButtonCaixaClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);
  private
    FRepositorioProdutos: TRepositorioProdutos;
    FRepositorioOperadores: TRepositorioOperadores;
    FVendaAtual: TVenda;
    FOperadorAtual: TOperador;
    FCaixaAtual: TCaixa;
    FItemSelecionado: Integer;
    
    procedure CarregarProdutos;
    procedure AtualizarResumoVenda;
    procedure AtualizarListaProdutos;
    procedure ExibirProdutos(AProdutos: TObjectList<TProduto>);
    procedure RealizarLogin;
    procedure AtualizarStatusCaixa;
  public
    { Public declarations }
  end;

var
  FormPrincipalIntegrado: TFormPrincipalIntegrado;

implementation

{$R *.fmx}

procedure TFormPrincipalIntegrado.FormCreate(Sender: TObject);
begin
  // Inicializa repositórios
  FRepositorioProdutos := TRepositorioProdutos.Create;
  FRepositorioOperadores := TRepositorioOperadores.Create;
  
  // Realiza login
  RealizarLogin;
end;

procedure TFormPrincipalIntegrado.FormDestroy(Sender: TObject);
begin
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;
  if Assigned(FCaixaAtual) then
    FCaixaAtual.Free;
  if Assigned(FRepositorioProdutos) then
    FRepositorioProdutos.Free;
  if Assigned(FRepositorioOperadores) then
    FRepositorioOperadores.Free;
end;

procedure TFormPrincipalIntegrado.RealizarLogin;
var
  FormLogin: TFormLogin;
begin
  FormLogin := TFormLogin.Create(nil);
  try
    if FormLogin.ShowModal = mrOk then
    begin
      FOperadorAtual := FormLogin.OperadorLogado;
      
      // Cria caixa para o operador
      FCaixaAtual := TCaixa.Create(1, FOperadorAtual, 0);
      
      // Cria venda atual
      FVendaAtual := TVenda.Create;
      
      // Atualiza interface
      LabelOperador.Text := FOperadorAtual.Nome + ' - Operador';
      AtualizarStatusCaixa;
      
      // Carrega produtos
      CarregarProdutos;
      
      FItemSelecionado := -1;
    end
    else
    begin
      // Usuário cancelou o login
      Application.Terminate;
    end;
  finally
    FormLogin.Free;
  end;
end;

procedure TFormPrincipalIntegrado.AtualizarStatusCaixa;
begin
  if FCaixaAtual.Aberto then
  begin
    LabelStatusCaixa.Text := 'Caixa Aberto';
    LabelStatusCaixa.TextSettings.FontColor := claGreen;
    ButtonCaixa.Text := 'Gerenciar Caixa';
  end
  else
  begin
    LabelStatusCaixa.Text := 'Caixa Fechado';
    LabelStatusCaixa.TextSettings.FontColor := claRed;
    ButtonCaixa.Text := 'Abrir Caixa';
  end;
end;

procedure TFormPrincipalIntegrado.ButtonCaixaClick(Sender: TObject);
var
  FormCaixa: TFormCaixa;
begin
  FormCaixa := TFormCaixa.Create(nil, FOperadorAtual);
  try
    // Copia referência do caixa
    if not FCaixaAtual.Aberto then
      FormCaixa.FCaixa := FCaixaAtual;
    
    FormCaixa.ShowModal;
    
    // Atualiza referência do caixa
    FCaixaAtual := FormCaixa.Caixa;
    
    // Atualiza status
    AtualizarStatusCaixa;
  finally
    FormCaixa.Free;
  end;
end;

procedure TFormPrincipalIntegrado.ButtonSairClick(Sender: TObject);
begin
  if MessageDlg('Deseja sair do sistema?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    Application.Terminate;
  end;
end;

procedure TFormPrincipalIntegrado.CarregarProdutos;
begin
  AtualizarListaProdutos;
end;

procedure TFormPrincipalIntegrado.AtualizarListaProdutos;
begin
  ExibirProdutos(FRepositorioProdutos.ObterTodos);
end;

procedure TFormPrincipalIntegrado.ExibirProdutos(AProdutos: TObjectList<TProduto>);
var
  i: Integer;
  Item: TListBoxItem;
  Produto: TProduto;
begin
  ListBoxProdutos.Clear;
  
  for i := 0 to AProdutos.Count - 1 do
  begin
    Produto := AProdutos[i];
    Item := TListBoxItem.Create(ListBoxProdutos);
    Item.Parent := ListBoxProdutos;
    Item.Text := Format('%s - R$ %.2f', [Produto.Nome, Produto.Preco]);
    Item.Tag := Produto.ID;
  end;
end;

procedure TFormPrincipalIntegrado.EditPesquisaChange(Sender: TObject);
var
  Resultados: TObjectList<TProduto>;
begin
  if EditPesquisa.Text = '' then
    AtualizarListaProdutos
  else
  begin
    Resultados := FRepositorioProdutos.BuscarPorNome(EditPesquisa.Text);
    try
      ExibirProdutos(Resultados);
    finally
      Resultados.Free;
    end;
  end;
end;

procedure TFormPrincipalIntegrado.ListBoxProdutosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
var
  Produto: TProduto;
begin
  if not FCaixaAtual.Aberto then
  begin
    ShowMessage('Abra o caixa antes de realizar vendas');
    Exit;
  end;
  
  if Assigned(Item) then
  begin
    Produto := FRepositorioProdutos.ObterProduto(Item.Tag);
    if Assigned(Produto) then
    begin
      FVendaAtual.AdicionarItem(Produto, 1);
      AtualizarResumoVenda;
    end;
  end;
end;

procedure TFormPrincipalIntegrado.AtualizarResumoVenda;
var
  i: Integer;
  Item: TItemVenda;
  Texto: string;
begin
  Texto := 'RESUMO DA VENDA' + sLineBreak + sLineBreak;
  Texto := Texto + 'Produtos:' + sLineBreak;
  
  for i := 0 to FVendaAtual.QuantidadeItens - 1 do
  begin
    Item := FVendaAtual.GetItem(i);
    if Assigned(Item) then
      Texto := Texto + Format('%d. %s - Qtd: %.0f - R$ %.2f' + sLineBreak,
        [i + 1, Item.Produto.Nome, Item.Quantidade, Item.ValorTotal]);
  end;
  
  Texto := Texto + sLineBreak;
  Texto := Texto + Format('Subtotal: R$ %.2f' + sLineBreak, [FVendaAtual.Subtotal]);
  
  if FVendaAtual.Desconto > 0 then
    Texto := Texto + Format('Desconto: -R$ %.2f' + sLineBreak, [FVendaAtual.Desconto]);
  
  if FVendaAtual.Acrescimo > 0 then
    Texto := Texto + Format('Acréscimo: +R$ %.2f' + sLineBreak, [FVendaAtual.Acrescimo]);
  
  Texto := Texto + sLineBreak;
  Texto := Texto + Format('TOTAL: R$ %.2f', [FVendaAtual.Total]);
  
  MemoResumo.Text := Texto;
end;

procedure TFormPrincipalIntegrado.ButtonDescontoClick(Sender: TObject);
var
  Valor: Double;
  Entrada: string;
begin
  Entrada := InputBox('Desconto', 'Digite o valor do desconto (R$):', '0.00');
  if TryStrToFloat(Entrada, Valor) then
  begin
    FVendaAtual.AplicarDesconto(Valor, False);
    AtualizarResumoVenda;
  end;
end;

procedure TFormPrincipalIntegrado.ButtonAcrescimoClick(Sender: TObject);
var
  Valor: Double;
  Entrada: string;
begin
  Entrada := InputBox('Acréscimo', 'Digite o valor do acréscimo (R$):', '0.00');
  if TryStrToFloat(Entrada, Valor) then
  begin
    FVendaAtual.AplicarAcrescimo(Valor, False);
    AtualizarResumoVenda;
  end;
end;

procedure TFormPrincipalIntegrado.ButtonFinalizarVendaClick(Sender: TObject);
begin
  if FVendaAtual.QuantidadeItens > 0 then
  begin
    // Adiciona venda ao caixa
    FCaixaAtual.AdicionarVenda(FVendaAtual);
    
    // Cria nova venda
    FVendaAtual := TVenda.Create;
    AtualizarResumoVenda;
    
    ShowMessage('Venda finalizada com sucesso!');
  end
  else
    ShowMessage('Adicione produtos antes de finalizar a venda.');
end;

procedure TFormPrincipalIntegrado.ButtonLimparCarrinhoClick(Sender: TObject);
begin
  if FVendaAtual.QuantidadeItens > 0 then
  begin
    if MessageDlg('Deseja limpar o carrinho?', TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    begin
      FVendaAtual.LimparVenda;
      AtualizarResumoVenda;
    end;
  end;
end;

procedure TFormPrincipalIntegrado.ButtonRemoverClick(Sender: TObject);
begin
  if FItemSelecionado >= 0 then
  begin
    FVendaAtual.RemoverItem(FItemSelecionado);
    AtualizarResumoVenda;
    FItemSelecionado := -1;
  end;
end;

procedure TFormPrincipalIntegrado.ButtonAumentarClick(Sender: TObject);
var
  Item: TItemVenda;
begin
  if FItemSelecionado >= 0 then
  begin
    Item := FVendaAtual.GetItem(FItemSelecionado);
    if Assigned(Item) then
    begin
      Item.SetQuantidade(Item.Quantidade + 1);
      AtualizarResumoVenda;
    end;
  end;
end;

procedure TFormPrincipalIntegrado.ButtonDiminuirClick(Sender: TObject);
var
  Item: TItemVenda;
begin
  if FItemSelecionado >= 0 then
  begin
    Item := FVendaAtual.GetItem(FItemSelecionado);
    if Assigned(Item) then
    begin
      if Item.Quantidade > 1 then
      begin
        Item.SetQuantidade(Item.Quantidade - 1);
        AtualizarResumoVenda;
      end
      else
        FVendaAtual.RemoverItem(FItemSelecionado);
      AtualizarResumoVenda;
    end;
  end;
end;

end.
