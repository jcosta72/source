unit uFormDesconto;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Edit, FMX.Buttons, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  uVenda;

type
  TFormDesconto = class(TForm)
    PanelPrincipal: TPanel;
    LabelTitulo: TLabel;
    PanelConteudo: TPanel;
    RadioGroupTipo: TRadioButton;
    RadioGroupPercentual: TRadioButton;
    LabelValor: TLabel;
    EditValor: TEdit;
    LabelUnidade: TLabel;
    LabelPreview: TLabel;
    PanelBotoes: TPanel;
    ButtonAplicar: TButton;
    ButtonCancelar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure RadioGroupTipoChange(Sender: TObject);
    procedure RadioGroupPercentualChange(Sender: TObject);
    procedure EditValorChange(Sender: TObject);
    procedure ButtonAplicarClick(Sender: TObject);
    procedure ButtonCancelarClick(Sender: TObject);
  private
    FVenda: TVenda;
    FDescontoAplicado: Boolean;
    
    procedure AtualizarPreview;
    procedure ValidarEntrada;
  public
    constructor Create(AOwner: TComponent; AVenda: TVenda); reintroduce;
    property DescontoAplicado: Boolean read FDescontoAplicado;
  end;

var
  FormDesconto: TFormDesconto;

implementation

{$R *.fmx}

constructor TFormDesconto.Create(AOwner: TComponent; AVenda: TVenda);
begin
  inherited Create(AOwner);
  FVenda := AVenda;
  FDescontoAplicado := False;
end;

procedure TFormDesconto.FormCreate(Sender: TObject);
begin
  RadioGroupTipo.IsChecked := True;
  LabelUnidade.Text := 'R$';
  EditValor.Text := '0.00';
  AtualizarPreview;
end;

procedure TFormDesconto.RadioGroupTipoChange(Sender: TObject);
begin
  RadioGroupTipo.IsChecked := True;
  RadioGroupPercentual.IsChecked := False;
  LabelUnidade.Text := 'R$';
  AtualizarPreview;
end;

procedure TFormDesconto.RadioGroupPercentualChange(Sender: TObject);
begin
  RadioGroupPercentual.IsChecked := True;
  RadioGroupTipo.IsChecked := False;
  LabelUnidade.Text := '%';
  AtualizarPreview;
end;

procedure TFormDesconto.EditValorChange(Sender: TObject);
begin
  AtualizarPreview;
end;

procedure TFormDesconto.AtualizarPreview;
var
  Valor: Double;
  Desconto: Double;
begin
  if not TryStrToFloat(EditValor.Text, Valor) then
  begin
    LabelPreview.Text := 'Valor inválido';
    Exit;
  end;
  
  if RadioGroupPercentual.IsChecked then
  begin
    // Desconto percentual
    if Valor < 0 then Valor := 0;
    if Valor > 100 then Valor := 100;
    
    Desconto := FVenda.Subtotal * (Valor / 100);
    LabelPreview.Text := Format('Desconto: R$ %.2f (%.0f%% de R$ %.2f)',
      [Desconto, Valor, FVenda.Subtotal]);
  end
  else
  begin
    // Desconto em valor fixo
    if Valor < 0 then Valor := 0;
    if Valor > FVenda.Subtotal then Valor := FVenda.Subtotal;
    
    LabelPreview.Text := Format('Desconto: R$ %.2f (%.2f%% de R$ %.2f)',
      [Valor, (Valor / FVenda.Subtotal) * 100, FVenda.Subtotal]);
  end;
end;

procedure TFormDesconto.ValidarEntrada;
var
  Valor: Double;
begin
  if not TryStrToFloat(EditValor.Text, Valor) then
  begin
    ShowMessage('Digite um valor válido');
    EditValor.SetFocus;
    Exit;
  end;
  
  if RadioGroupPercentual.IsChecked then
  begin
    if (Valor < 0) or (Valor > 100) then
    begin
      ShowMessage('O percentual deve estar entre 0 e 100');
      EditValor.SetFocus;
      Exit;
    end;
  end
  else
  begin
    if Valor < 0 then
    begin
      ShowMessage('O desconto não pode ser negativo');
      EditValor.SetFocus;
      Exit;
    end;
    
    if Valor > FVenda.Subtotal then
    begin
      ShowMessage('O desconto não pode ser maior que o subtotal');
      EditValor.SetFocus;
      Exit;
    end;
  end;
end;

procedure TFormDesconto.ButtonAplicarClick(Sender: TObject);
var
  Valor: Double;
begin
  ValidarEntrada;
  
  if not TryStrToFloat(EditValor.Text, Valor) then
    Exit;
  
  if RadioGroupPercentual.IsChecked then
  begin
    FVenda.AplicarDescontoPercentual(Valor);
  end
  else
  begin
    FVenda.AplicarDesconto(Valor, False);
  end;
  
  FDescontoAplicado := True;
  ModalResult := mrOk;
end;

procedure TFormDesconto.ButtonCancelarClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

end.
