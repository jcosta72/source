unit uFormCaixa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.Buttons, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  uOperador, uCaixa, uVenda, uItemVenda;

type
  TFormCaixa = class(TForm)
    PanelPrincipal: TPanel;
    PanelCabecalho: TPanel;
    LabelTitulo: TLabel;
    PanelConteudo: TPanel;
    PanelEsquerda: TPanel;
    PanelDireita: TPanel;
    PanelResumo: TPanel;
    LabelResumo: TLabel;
    MemoResumo: TMemo;
    PanelVendas: TPanel;
    LabelVendas: TLabel;
    ListBoxVendas: TListBox;
    PanelAcoes: TPanel;
    ButtonAbrir: TButton;
    ButtonFechar: TButton;
    ButtonCancelar: TButton;
    PanelSaldoInicial: TPanel;
    LabelSaldoInicial: TLabel;
    EditSaldoInicial: TEdit;
    PanelStatusCaixa: TPanel;
    LabelStatus: TLabel;
    LabelStatusValor: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButtonAbrirClick(Sender: TObject);
    procedure ButtonFecharClick(Sender: TObject);
    procedure ButtonCancelarClick(Sender: TObject);
    procedure ListBoxVendasItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
  private
    FOperador: TOperador;
    FCaixa: TCaixa;
    FTemCaixaAberto: Boolean;
    
    procedure AtualizarInterface;
    procedure AtualizarResumo;
    procedure AtualizarListaVendas;
    procedure AjustarLayout;
    procedure ExibirDetalhesVenda(AIndex: Integer);
  public
    constructor Create(AOwner: TComponent; AOperador: TOperador); reintroduce;
    property Caixa: TCaixa read FCaixa;
  end;

var
  FormCaixa: TFormCaixa;

implementation

{$R *.fmx}

constructor TFormCaixa.Create(AOwner: TComponent; AOperador: TOperador);
begin
  inherited Create(AOwner);
  FOperador := AOperador;
  FCaixa := nil;
  FTemCaixaAberto := False;
end;

procedure TFormCaixa.FormCreate(Sender: TObject);
begin
  // Inicializa interface
  AtualizarInterface;
  AjustarLayout;
end;

procedure TFormCaixa.FormDestroy(Sender: TObject);
begin
  // Cleanup se necessário
end;

procedure TFormCaixa.FormResize(Sender: TObject);
begin
  AjustarLayout;
end;

procedure TFormCaixa.AjustarLayout;
var
  LarguraTela: Single;
begin
  LarguraTela := PanelConteudo.Width;
  
  if LarguraTela < 1000 then
  begin
    PanelEsquerda.Width := LarguraTela * 0.40;
  end
  else if LarguraTela < 1400 then
  begin
    PanelEsquerda.Width := LarguraTela * 0.45;
  end
  else
  begin
    PanelEsquerda.Width := LarguraTela * 0.50;
  end;
end;

procedure TFormCaixa.AtualizarInterface;
begin
  if FTemCaixaAberto and Assigned(FCaixa) then
  begin
    LabelStatusValor.Text := 'ABERTO';
    LabelStatusValor.TextSettings.FontColor := claGreen;
    ButtonAbrir.Enabled := False;
    ButtonFechar.Enabled := True;
    EditSaldoInicial.Enabled := False;
    PanelSaldoInicial.Enabled := False;
  end
  else
  begin
    LabelStatusValor.Text := 'FECHADO';
    LabelStatusValor.TextSettings.FontColor := claRed;
    ButtonAbrir.Enabled := True;
    ButtonFechar.Enabled := False;
    EditSaldoInicial.Enabled := True;
    PanelSaldoInicial.Enabled := True;
  end;
  
  AtualizarResumo;
  AtualizarListaVendas;
end;

procedure TFormCaixa.AtualizarResumo;
begin
  if Assigned(FCaixa) and FTemCaixaAberto then
  begin
    MemoResumo.Text := FCaixa.ObterResumoVendas;
  end
  else
  begin
    MemoResumo.Text := 'Nenhum caixa aberto' + sLineBreak + sLineBreak +
      'Clique em "Abrir Caixa" para iniciar' + sLineBreak +
      'Operador: ' + FOperador.Nome + sLineBreak +
      'Matrícula: ' + FOperador.Matricula;
  end;
end;

procedure TFormCaixa.AtualizarListaVendas;
var
  i: Integer;
  Item: TListBoxItem;
begin
  ListBoxVendas.Clear;
  
  if not Assigned(FCaixa) or (FCaixa.Vendas.Count = 0) then
  begin
    Item := TListBoxItem.Create(ListBoxVendas);
    Item.Parent := ListBoxVendas;
    Item.Text := 'Nenhuma venda registrada';
    Item.Enabled := False;
    Exit;
  end;
  
  for i := 0 to FCaixa.Vendas.Count - 1 do
  begin
    Item := TListBoxItem.Create(ListBoxVendas);
    Item.Parent := ListBoxVendas;
    Item.Text := Format('Venda %d - R$ %.2f - %s', 
      [i + 1, FCaixa.Vendas[i].Total, 
       FormatDateTime('hh:mm:ss', FCaixa.Vendas[i].DataVenda)]);
    Item.Tag := i;
  end;
end;

procedure TFormCaixa.ButtonAbrirClick(Sender: TObject);
var
  SaldoInicial: Double;
begin
  if not TryStrToFloat(EditSaldoInicial.Text, SaldoInicial) then
  begin
    ShowMessage('Digite um valor válido para o saldo inicial');
    Exit;
  end;
  
  if SaldoInicial < 0 then
  begin
    ShowMessage('O saldo inicial não pode ser negativo');
    Exit;
  end;
  
  // Cria novo caixa
  if Assigned(FCaixa) then
    FCaixa.Free;
  
  FCaixa := TCaixa.Create(1, FOperador, SaldoInicial);
  FCaixa.Abrir(SaldoInicial);
  FTemCaixaAberto := True;
  
  AtualizarInterface;
  ShowMessage('Caixa aberto com sucesso!');
end;

procedure TFormCaixa.ButtonFecharClick(Sender: TObject);
begin
  if not Assigned(FCaixa) or not FCaixa.EstaAberto then
  begin
    ShowMessage('Nenhum caixa aberto');
    Exit;
  end;
  
  if FCaixa.QuantidadeVendas = 0 then
  begin
    ShowMessage('Não é possível fechar um caixa sem vendas');
    Exit;
  end;
  
  if MessageDlg('Deseja realmente fechar o caixa?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    FCaixa.Fechar;
    FTemCaixaAberto := False;
    AtualizarInterface;
    ShowMessage('Caixa fechado com sucesso!');
  end;
end;

procedure TFormCaixa.ButtonCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFormCaixa.ListBoxVendasItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  if Assigned(Item) and (Item.Tag >= 0) then
  begin
    ExibirDetalhesVenda(Item.Tag);
  end;
end;

procedure TFormCaixa.ExibirDetalhesVenda(AIndex: Integer);
var
  Venda: TVenda;
  Detalhes: string;
  i: Integer;
  ItemVenda: TItemVenda;
begin
  if not Assigned(FCaixa) or (AIndex < 0) or (AIndex >= FCaixa.Vendas.Count) then
    Exit;
  
  Venda := FCaixa.Vendas[AIndex];
  
  Detalhes := 'DETALHES DA VENDA' + sLineBreak + sLineBreak;
  Detalhes := Detalhes + Format('Venda #%d', [AIndex + 1]) + sLineBreak;
  Detalhes := Detalhes + Format('Data: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', Venda.DataVenda)]) + sLineBreak;
  Detalhes := Detalhes + sLineBreak;
  
  Detalhes := Detalhes + 'ITENS:' + sLineBreak;
  for i := 0 to Venda.QuantidadeItens - 1 do
  begin
    ItemVenda := Venda.GetItem(i);
    if Assigned(ItemVenda) then
    begin
      Detalhes := Detalhes + Format('%d. %s', [i + 1, ItemVenda.Produto.Nome]) + sLineBreak;
      Detalhes := Detalhes + Format('   Qtd: %.0f | Valor: R$ %.2f', 
        [ItemVenda.Quantidade, ItemVenda.ValorTotal]) + sLineBreak;
    end;
  end;
  
  Detalhes := Detalhes + sLineBreak;
  Detalhes := Detalhes + Format('Subtotal: R$ %.2f', [Venda.Subtotal]) + sLineBreak;
  
  if Venda.Desconto > 0 then
    Detalhes := Detalhes + Format('Desconto: -R$ %.2f', [Venda.Desconto]) + sLineBreak;
  
  if Venda.Acrescimo > 0 then
    Detalhes := Detalhes + Format('Acréscimo: +R$ %.2f', [Venda.Acrescimo]) + sLineBreak;
  
  Detalhes := Detalhes + sLineBreak;
  Detalhes := Detalhes + Format('TOTAL: R$ %.2f', [Venda.Total]) + sLineBreak;
  Detalhes := Detalhes + sLineBreak;
  
  case Venda.FormaPagamento of
    fpDinheiro:
    begin
      Detalhes := Detalhes + 'Pagamento: DINHEIRO' + sLineBreak;
      Detalhes := Detalhes + Format('Recebido: R$ %.2f', [Venda.ValorRecebido]) + sLineBreak;
      Detalhes := Detalhes + Format('Troco: R$ %.2f', [Venda.Troco]) + sLineBreak;
    end;
    fpCartao:
      Detalhes := Detalhes + 'Pagamento: CARTÃO DE CRÉDITO' + sLineBreak;
    fpPIX:
      Detalhes := Detalhes + 'Pagamento: PIX' + sLineBreak;
  end;
  
  MemoResumo.Text := Detalhes;
end;

end.
