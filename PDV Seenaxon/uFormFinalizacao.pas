unit uFormFinalizacao;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Edit, FMX.Buttons, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  uVenda;

type
  TFormFinalizacao = class(TForm)
    PanelPrincipal: TPanel;
    PanelCabecalho: TPanel;
    LabelTitulo: TLabel;
    PanelConteudo: TPanel;
    PanelEsquerda: TPanel;
    PanelResumo: TPanel;
    LabelResumoTitulo: TLabel;
    MemoResumo: TMemo;
    PanelDireita: TPanel;
    PanelPagamento: TPanel;
    LabelPagamentoTitulo: TLabel;
    RadioGroupDinheiro: TRadioButton;
    RadioGroupCartao: TRadioButton;
    RadioGroupPIX: TRadioButton;
    PanelValores: TPanel;
    LabelValorTotal: TLabel;
    EditValorTotal: TEdit;
    LabelValorRecebido: TLabel;
    EditValorRecebido: TEdit;
    LabelTroco: TLabel;
    EditTroco: TEdit;
    PanelBotoes: TPanel;
    ButtonConfirmar: TButton;
    ButtonCancelar: TButton;
    PanelCartao: TPanel;
    LabelBandeira: TLabel;
    ComboBandeira: TComboBox;
    LabelParcelas: TLabel;
    EditParcelas: TEdit;
    PanelPIX: TPanel;
    LabelChavePIX: TLabel;
    EditChavePIX: TEdit;
    LabelMensagem: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure RadioGroupDinheiroChange(Sender: TObject);
    procedure RadioGroupCartaoChange(Sender: TObject);
    procedure RadioGroupPIXChange(Sender: TObject);
    procedure EditValorRecebidoChange(Sender: TObject);
    procedure ButtonConfirmarClick(Sender: TObject);
    procedure ButtonCancelarClick(Sender: TObject);
  private
    FVenda: TVenda;
    FFormaPagamento: string;
    FValorRecebido: Double;
    
    procedure AtualizarResumo;
    procedure AtualizarPainelPagamento;
    procedure CalcularTroco;
    procedure ValidarPagamento;
    procedure AjustarLayout;
  public
    constructor Create(AOwner: TComponent; AVenda: TVenda); reintroduce;
    property FormaPagamento: string read FFormaPagamento;
    property ValorRecebido: Double read FValorRecebido;
  end;

var
  FormFinalizacao: TFormFinalizacao;

implementation

{$R *.fmx}

constructor TFormFinalizacao.Create(AOwner: TComponent; AVenda: TVenda);
begin
  inherited Create(AOwner);
  FVenda := AVenda;
  FFormaPagamento := 'DINHEIRO';
  FValorRecebido := 0;
end;

procedure TFormFinalizacao.FormCreate(Sender: TObject);
begin
  // Inicializa componentes
  RadioGroupDinheiro.IsChecked := True;
  EditValorTotal.Text := FormatFloat('0.00', FVenda.Total);
  EditValorTotal.ReadOnly := True;
  
  // Carrega bandeiras de cartão
  ComboBandeira.Items.Add('VISA');
  ComboBandeira.Items.Add('MASTERCARD');
  ComboBandeira.Items.Add('ELO');
  ComboBandeira.Items.Add('AMEX');
  ComboBandeira.ItemIndex := 0;
  
  // Inicializa parcelas
  EditParcelas.Text := '1';
  
  // Inicializa chave PIX
  EditChavePIX.Text := '';
  
  // Atualiza layout
  AtualizarResumo;
  AtualizarPainelPagamento;
  AjustarLayout;
end;

procedure TFormFinalizacao.FormDestroy(Sender: TObject);
begin
  // Cleanup se necessário
end;

procedure TFormFinalizacao.FormResize(Sender: TObject);
begin
  AjustarLayout;
end;

procedure TFormFinalizacao.AjustarLayout;
var
  LarguraTela: Single;
begin
  LarguraTela := PanelConteudo.Width;
  
  // Ajusta proporção dos painéis baseado na largura
  if LarguraTela < 1000 then
  begin
    // Telas pequenas: 40% esquerda, 60% direita
    PanelEsquerda.Width := LarguraTela * 0.40;
  end
  else if LarguraTela < 1400 then
  begin
    // Telas médias: 45% esquerda, 55% direita
    PanelEsquerda.Width := LarguraTela * 0.45;
  end
  else
  begin
    // Telas grandes: 50% esquerda, 50% direita
    PanelEsquerda.Width := LarguraTela * 0.50;
  end;
end;

procedure TFormFinalizacao.AtualizarResumo;
var
  i: Integer;
  Item: TItemVenda;
  Texto: string;
begin
  Texto := 'RESUMO DA VENDA' + sLineBreak + sLineBreak;
  Texto := Texto + 'Itens:' + sLineBreak;
  
  for i := 0 to FVenda.QuantidadeItens - 1 do
  begin
    Item := FVenda.GetItem(i);
    if Assigned(Item) then
      Texto := Texto + Format('%d. %s - Qtd: %.0f - R$ %.2f' + sLineBreak,
        [i + 1, Item.Produto.Nome, Item.Quantidade, Item.ValorTotal]);
  end;
  
  Texto := Texto + sLineBreak;
  Texto := Texto + Format('Subtotal: R$ %.2f' + sLineBreak, [FVenda.Subtotal]);
  
  if FVenda.Desconto > 0 then
    Texto := Texto + Format('Desconto: -R$ %.2f' + sLineBreak, [FVenda.Desconto]);
  
  if FVenda.Acrescimo > 0 then
    Texto := Texto + Format('Acréscimo: +R$ %.2f' + sLineBreak, [FVenda.Acrescimo]);
  
  Texto := Texto + sLineBreak;
  Texto := Texto + Format('TOTAL: R$ %.2f', [FVenda.Total]);
  
  MemoResumo.Text := Texto;
end;

procedure TFormFinalizacao.AtualizarPainelPagamento;
begin
  // Esconde todos os painéis específicos
  PanelCartao.Visible := False;
  PanelPIX.Visible := False;
  
  // Mostra o painel correto baseado na forma de pagamento
  if RadioGroupDinheiro.IsChecked then
  begin
    FFormaPagamento := 'DINHEIRO';
    EditValorRecebido.SetFocus;
  end
  else if RadioGroupCartao.IsChecked then
  begin
    FFormaPagamento := 'CARTAO';
    PanelCartao.Visible := True;
    ComboBandeira.SetFocus;
  end
  else if RadioGroupPIX.IsChecked then
  begin
    FFormaPagamento := 'PIX';
    PanelPIX.Visible := True;
    EditChavePIX.SetFocus;
  end;
end;

procedure TFormFinalizacao.CalcularTroco;
var
  Troco: Double;
begin
  if FFormaPagamento = 'DINHEIRO' then
  begin
    if TryStrToFloat(EditValorRecebido.Text, FValorRecebido) then
    begin
      Troco := FValorRecebido - FVenda.Total;
      if Troco >= 0 then
      begin
        EditTroco.Text := FormatFloat('0.00', Troco);
        LabelMensagem.Text := '';
      end
      else
      begin
        EditTroco.Text := '0.00';
        LabelMensagem.Text := 'Valor insuficiente!';
        LabelMensagem.TextSettings.FontColor := claRed;
      end;
    end
    else
    begin
      EditTroco.Text := '0.00';
      LabelMensagem.Text := 'Digite um valor válido';
      LabelMensagem.TextSettings.FontColor := claRed;
    end;
  end
  else
  begin
    EditTroco.Text := '0.00';
    LabelMensagem.Text := '';
  end;
end;

procedure TFormFinalizacao.ValidarPagamento;
var
  Parcelas: Integer;
begin
  LabelMensagem.Text := '';
  
  if FFormaPagamento = 'DINHEIRO' then
  begin
    if FValorRecebido < FVenda.Total then
    begin
      LabelMensagem.Text := 'Valor insuficiente!';
      LabelMensagem.TextSettings.FontColor := claRed;
      Exit;
    end;
  end
  else if FFormaPagamento = 'CARTAO' then
  begin
    if not TryStrToInt(EditParcelas.Text, Parcelas) or (Parcelas < 1) or (Parcelas > 12) then
    begin
      LabelMensagem.Text := 'Parcelas devem estar entre 1 e 12';
      LabelMensagem.TextSettings.FontColor := claRed;
      Exit;
    end;
  end
  else if FFormaPagamento = 'PIX' then
  begin
    if EditChavePIX.Text = '' then
    begin
      LabelMensagem.Text := 'Informe a chave PIX';
      LabelMensagem.TextSettings.FontColor := claRed;
      Exit;
    end;
  end;
  
  LabelMensagem.Text := 'Pagamento validado com sucesso!';
  LabelMensagem.TextSettings.FontColor := claGreen;
end;

procedure TFormFinalizacao.RadioGroupDinheiroChange(Sender: TObject);
begin
  RadioGroupDinheiro.IsChecked := True;
  RadioGroupCartao.IsChecked := False;
  RadioGroupPIX.IsChecked := False;
  AtualizarPainelPagamento;
end;

procedure TFormFinalizacao.RadioGroupCartaoChange(Sender: TObject);
begin
  RadioGroupDinheiro.IsChecked := False;
  RadioGroupCartao.IsChecked := True;
  RadioGroupPIX.IsChecked := False;
  AtualizarPainelPagamento;
end;

procedure TFormFinalizacao.RadioGroupPIXChange(Sender: TObject);
begin
  RadioGroupDinheiro.IsChecked := False;
  RadioGroupCartao.IsChecked := False;
  RadioGroupPIX.IsChecked := True;
  AtualizarPainelPagamento;
end;

procedure TFormFinalizacao.EditValorRecebidoChange(Sender: TObject);
begin
  CalcularTroco;
end;

procedure TFormFinalizacao.ButtonConfirmarClick(Sender: TObject);
begin
  ValidarPagamento;
  
  if LabelMensagem.TextSettings.FontColor <> claGreen then
    Exit;
  
  ModalResult := mrOk;
end;

procedure TFormFinalizacao.ButtonCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
