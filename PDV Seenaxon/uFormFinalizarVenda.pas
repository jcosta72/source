unit uFormFinalizarVenda;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.StdCtrls, FMX.Edit, FMX.Memo, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid, FMX.Objects, System.Generics.Collections, FMX.ListBox,
  uRepositorioVenda, uVenda, uItemVenda, uImpressoraFiscal, uRecuperacaoVendas,
  FMX.Memo.Types;

type
  TFormFinalizarVenda = class(TForm)
    LayoutPrincipal: TLayout;
    LayoutCabecalho: TLayout;
    RectangloCabecalho: TRectangle;
    LabelTitulo: TLabel;
    ButtonFechar: TButton;
    LayoutCorpo: TLayout;
    LayoutResumoVenda: TLayout;
    LabelResumo: TLabel;
    MemoResumoVenda: TMemo;
    LayoutPagamento: TLayout;
    LabelPagamento: TLabel;
    LabelFormaPagamento: TLabel;
    ComboFormaPagamento: TComboBox;
    LabelValorTotal: TLabel;
    EditValorTotal: TEdit;
    LabelValorPago: TLabel;
    EditValorPago: TEdit;
    LabelTroco: TLabel;
    EditTroco: TEdit;
    LayoutBotoes: TLayout;
    ButtonProcessarPagamento: TButton;
    ButtonCancelar: TButton;
    LayoutStatus: TLayout;
    LabelStatus: TLabel;
    ProgressBar: TProgressBar;
    TimerProcessamento: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ComboFormaPagamentoChange(Sender: TObject);
    procedure EditValorPagoChange(Sender: TObject);
    procedure ButtonProcessarPagamentoClick(Sender: TObject);
    procedure ButtonCancelarClick(Sender: TObject);
    procedure ButtonFecharClick(Sender: TObject);
    procedure TimerProcessamentoTimer(Sender: TObject);
  private
    FRepositorioVenda: TRepositorioVenda;
    FImpressoraFiscal: TImpressoraFiscal;
    FRecuperacaoVendas: TRecuperacaoVendas;
    FVendaAtual: TVenda;
    FProcessando: Boolean;
    FProgressoProcessamento: Integer;
    
    { Métodos Privados }
    procedure InicializarComponentes;
    procedure ConfigurarEstilos;
    procedure AtualizarResumoVenda;
    procedure CalcularTroco;
    procedure ProcessarPagamento;
    procedure ImprimirCupom;
    procedure ExibirMensagem(AMensagem: string; AErro: Boolean = False);
    procedure HabilitarCampos(AHabilitar: Boolean);
    procedure ValidarPagamento;
  public
    { Public declarations }
    procedure SetRepositorioVenda(ARepositorio: TRepositorioVenda);
    procedure SetVendaAtual(AVenda: TVenda);
  end;

var
  FormFinalizarVenda: TFormFinalizarVenda;

implementation

{$R *.fmx}

const
  ALTURA_CABECALHO = 60;
  ALTURA_RODAPE = 50;
  
  COR_CABECALHO = $FF1A1A1A;
  COR_TEXTO_CLARO = $FFFFFFFF;
  COR_DESTAQUE = $FFFF4500;
  COR_SUCESSO = $FF00AA00;
  COR_ERRO = $FFFF0000;
  COR_AVISO = $FFFFFF00;

{$REGION 'Inicialização'}

procedure TFormFinalizarVenda.FormCreate(Sender: TObject);
begin
  FRepositorioVenda := nil;
  FVendaAtual := nil;
  FProcessando := False;
  FProgressoProcessamento := 0;

  FImpressoraFiscal := TImpressoraFiscal.Create;
  FImpressoraFiscal.EmpresaNome := 'PDV SEENAXON';
  FImpressoraFiscal.EmpresaCNPJ := '00.000.000/0000-00';
  FImpressoraFiscal.EmpresaIE := '00.000.000.000.000';
  FImpressoraFiscal.NumeroCupom := 1;

  FRecuperacaoVendas := TRecuperacaoVendas.Create;
  
  InicializarComponentes;
  ConfigurarEstilos;
end;

procedure TFormFinalizarVenda.FormShow(Sender: TObject);
begin
  AtualizarResumoVenda;
  HabilitarCampos(True);
  ComboFormaPagamento.ItemIndex := 0;
end;

procedure TFormFinalizarVenda.InicializarComponentes;
begin
  // Configurar ComboFormaPagamento
  ComboFormaPagamento.Items.Clear;
  ComboFormaPagamento.Items.Add('Dinheiro');
  ComboFormaPagamento.Items.Add('Cartão de Crédito');
  ComboFormaPagamento.Items.Add('PIX');
  ComboFormaPagamento.ItemIndex := 0;
  
  // Configurar EditValorTotal
  EditValorTotal.ReadOnly := True;
  EditValorTotal.Text := '0.00';
  
  // Configurar EditValorPago
  EditValorPago.Text := '0.00';
  EditValorPago.KeyboardType := TVirtualKeyboardType.NumberPad;

  // Configurar EditTroco
  EditTroco.ReadOnly := True;
  EditTroco.Text := '0.00';
  
  // Configurar ProgressBar
  ProgressBar.Value := 0;
  ProgressBar.Max := 100;
  
  // Configurar Timer
  TimerProcessamento.Interval := 100;
  TimerProcessamento.Enabled := False;
end;

procedure TFormFinalizarVenda.ConfigurarEstilos;
begin
  // Configurar cores do cabeçalho
  RectangloCabecalho.Fill.Color := COR_CABECALHO;
  LabelTitulo.TextSettings.FontColor := COR_DESTAQUE;
  
  // Configurar cores dos labels
  LabelResumo.TextSettings.FontColor := COR_DESTAQUE;
  LabelPagamento.TextSettings.FontColor := COR_DESTAQUE;
  
  // Configurar cores dos botões
  ButtonProcessarPagamento.TextSettings.FontColor := COR_SUCESSO;
  ButtonCancelar.TextSettings.FontColor := COR_ERRO;
  ButtonFechar.TextSettings.FontColor := COR_TEXTO_CLARO;
  
  // Configurar status
  LabelStatus.TextSettings.FontColor := COR_TEXTO_CLARO;
end;

{$ENDREGION}

{$REGION 'Métodos Públicos'}

procedure TFormFinalizarVenda.SetRepositorioVenda(ARepositorio: TRepositorioVenda);
begin
  FRepositorioVenda := ARepositorio;
  if Assigned(FRepositorioVenda) then
    FVendaAtual := FRepositorioVenda.VendaAtual;
end;

procedure TFormFinalizarVenda.SetVendaAtual(AVenda: TVenda);
begin
  FVendaAtual := AVenda;
end;

{$ENDREGION}

{$REGION 'Métodos Privados'}

procedure TFormFinalizarVenda.AtualizarResumoVenda;
var
  Resumo: string;
  I: Integer;
  Item: TItemVenda;
begin
  if not Assigned(FVendaAtual) then
  begin
    MemoResumoVenda.Text := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  Resumo := '';
  
  // Cabeçalho
  Resumo := Resumo + '=== RESUMO DA VENDA ===' + sLineBreak;
  Resumo := Resumo + 'ID: ' + IntToStr(FVendaAtual.ID) + sLineBreak;
  Resumo := Resumo + 'Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', FVendaAtual.DataVenda) + sLineBreak;
  Resumo := Resumo + sLineBreak;
  
  // Itens
  Resumo := Resumo + '--- ITENS ---' + sLineBreak;
  for I := 0 to FVendaAtual.Itens.Count - 1 do
  begin
    Item := FVendaAtual.Itens[I];
    Resumo := Resumo + Item.Produto.Nome + sLineBreak;
    Resumo := Resumo + '  Qtd: ' + FormatFloat('0.00', Item.Quantidade) + 
              ' x R$ ' + FormatFloat('0.00', Item.Produto.Preco) + 
              ' = R$ ' + FormatFloat('0.00', Item.ValorTotal) + sLineBreak;
  end;
  
  Resumo := Resumo + sLineBreak;
  
  // Totalizadores
  Resumo := Resumo + '--- TOTALIZADORES ---' + sLineBreak;
  Resumo := Resumo + 'Subtotal:  R$ ' + FormatFloat('0.00', FVendaAtual.Subtotal) + sLineBreak;
  
  if FVendaAtual.Desconto > 0 then
    Resumo := Resumo + 'Desconto:  R$ ' + FormatFloat('0.00', FVendaAtual.Desconto) + sLineBreak;
  
  if FVendaAtual.Acrescimo > 0 then
    Resumo := Resumo + 'Acréscimo: R$ ' + FormatFloat('0.00', FVendaAtual.Acrescimo) + sLineBreak;
  
  Resumo := Resumo + sLineBreak;
  Resumo := Resumo + 'TOTAL:     R$ ' + FormatFloat('0.00', FVendaAtual.Total);
  
  MemoResumoVenda.Text := Resumo;
  
  // Atualizar campo de valor total
  EditValorTotal.Text := FormatFloat('0.00', FVendaAtual.Total);
end;

procedure TFormFinalizarVenda.CalcularTroco;
var
  ValorTotal, ValorPago, Troco: Double;
begin
  if not TryStrToFloat(EditValorTotal.Text, ValorTotal) then
    ValorTotal := 0;
  
  if not TryStrToFloat(EditValorPago.Text, ValorPago) then
    ValorPago := 0;
  
  Troco := ValorPago - ValorTotal;
  
  if Troco < 0 then
  begin
    EditTroco.TextSettings.FontColor := COR_ERRO;
    EditTroco.Text := FormatFloat('0.00', Abs(Troco));
    LabelTroco.Text := 'Faltam: ';
  end
  else
  begin
    EditTroco.TextSettings.FontColor := COR_SUCESSO;
    EditTroco.Text := FormatFloat('0.00', Troco);
    LabelTroco.Text := 'Troco: ';
  end;
end;

procedure TFormFinalizarVenda.ValidarPagamento;
var
  ValorTotal, ValorPago: Double;
  FormaPagamento: Integer;
begin
  if not Assigned(FVendaAtual) then
  begin
    ExibirMensagem('Nenhuma venda em andamento', True);
    Exit;
  end;
  
  if FVendaAtual.Itens.Count = 0 then
  begin
    ExibirMensagem('Venda sem itens não pode ser finalizada', True);
    Exit;
  end;
  
  if not TryStrToFloat(EditValorTotal.Text, ValorTotal) then
  begin
    ExibirMensagem('Valor total inválido', True);
    Exit;
  end;
  
  if not TryStrToFloat(EditValorPago.Text, ValorPago) then
  begin
    ExibirMensagem('Valor pago inválido', True);
    Exit;
  end;
  
  if ValorPago < ValorTotal then
  begin
    ExibirMensagem('Valor pago insuficiente', True);
    Exit;
  end;
  
  FormaPagamento := ComboFormaPagamento.ItemIndex + 1;
  
  if (FormaPagamento < 1) or (FormaPagamento > 3) then
  begin
    ExibirMensagem('Forma de pagamento inválida', True);
    Exit;
  end;
  
  // Se passou em todas as validações, processar pagamento
  ProcessarPagamento;
end;

procedure TFormFinalizarVenda.ProcessarPagamento;
var
  FormaPagamento: Integer;
  ValorPago: Double;
begin
  if FProcessando then
    Exit;
  
  FProcessando := True;
  FProgressoProcessamento := 0;
  HabilitarCampos(False);
  
  FormaPagamento := ComboFormaPagamento.ItemIndex + 1;
  if not TryStrToFloat(EditValorPago.Text, ValorPago) then
    ValorPago := 0;
  
  // Iniciar processamento
  ExibirMensagem('Processando pagamento...', False);
  TimerProcessamento.Enabled := True;
  
  // Simular processamento
  // Em produção, aqui seria feita a integração com gateway de pagamento
  if FormaPagamento = 2 then // Cartão
  begin
    ExibirMensagem('Aguarde... Processando cartão...', False);
  end
  else if FormaPagamento = 3 then // PIX
  begin
    ExibirMensagem('Aguarde... Gerando QR Code PIX...', False);
  end;
end;

procedure TFormFinalizarVenda.ImprimirCupom;
var
  Cupom: string;
begin
  if not Assigned(FVendaAtual) then
    Exit;
  
  try
    // Gerar cupom fiscal
    Cupom := FImpressoraFiscal.GerarCupomVenda(FVendaAtual);
    
    // Exibir cupom
    ShowMessage(Cupom);
    
    // Salvar cupom em arquivo
    FImpressoraFiscal.SalvarCupomVenda(FVendaAtual, 
      ExtractFilePath(ParamStr(0)) + 'cupons\cupom_' + IntToStr(FVendaAtual.ID) + '.txt');
    
    ExibirMensagem('Cupom impresso com sucesso!', False);
  except
    on E: Exception do
      ExibirMensagem('Erro ao imprimir cupom: ' + E.Message, True);
  end;
end;

procedure TFormFinalizarVenda.ExibirMensagem(AMensagem: string; AErro: Boolean = False);
begin
  LabelStatus.Text := AMensagem;
  
  if AErro then
    LabelStatus.TextSettings.FontColor := COR_ERRO
  else
    LabelStatus.TextSettings.FontColor := COR_SUCESSO;
end;

procedure TFormFinalizarVenda.HabilitarCampos(AHabilitar: Boolean);
begin
  ComboFormaPagamento.Enabled := AHabilitar;
  EditValorPago.Enabled := AHabilitar;
  ButtonProcessarPagamento.Enabled := AHabilitar;
  ButtonCancelar.Enabled := AHabilitar;
end;

{$ENDREGION}

{$REGION 'Eventos'}

procedure TFormFinalizarVenda.ComboFormaPagamentoChange(Sender: TObject);
begin
  case ComboFormaPagamento.ItemIndex of
    0: // Dinheiro
      ExibirMensagem('Forma de pagamento: Dinheiro', False);
    1: // Cartão
      ExibirMensagem('Forma de pagamento: Cartão de Crédito', False);
    2: // PIX
      ExibirMensagem('Forma de pagamento: PIX', False);
  end;
end;

procedure TFormFinalizarVenda.EditValorPagoChange(Sender: TObject);
begin
  CalcularTroco;
end;

procedure TFormFinalizarVenda.ButtonProcessarPagamentoClick(Sender: TObject);
begin
  ValidarPagamento;
end;

procedure TFormFinalizarVenda.ButtonCancelarClick(Sender: TObject);
begin
  if MessageDlg('Deseja cancelar esta venda?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    if Assigned(FRepositorioVenda) then
    begin
      if FRepositorioVenda.CancelarVenda then
      begin
        ExibirMensagem('Venda cancelada!', False);
        ModalResult := mrCancel;
      end
      else
      begin
        ExibirMensagem('Erro ao cancelar venda: ' + FRepositorioVenda.UltimoErro, True);
      end;
    end;
  end;
end;

procedure TFormFinalizarVenda.ButtonFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFormFinalizarVenda.TimerProcessamentoTimer(Sender: TObject);
var
  FormaPagamento: Integer;
  ValorPago: Double;
begin
  Inc(FProgressoProcessamento, 10);
  ProgressBar.Value := FProgressoProcessamento;
  
  if FProgressoProcessamento >= 100 then
  begin
    TimerProcessamento.Enabled := False;
    FProcessando := False;
    
    // Finalizar venda
    FormaPagamento := ComboFormaPagamento.ItemIndex + 1;
    if not TryStrToFloat(EditValorPago.Text, ValorPago) then
      ValorPago := 0;
    
    if Assigned(FRepositorioVenda) then
    begin
      if FRepositorioVenda.FinalizarVenda( TFormaPagamento(FormaPagamento), ValorPago) then
      begin
        ExibirMensagem('Pagamento processado com sucesso!', False);
        
        // Imprimir cupom
        ImprimirCupom;
        
        // Salvar venda pendente (para recuperação)
        if Assigned(FRecuperacaoVendas) then
          FRecuperacaoVendas.DeletarVendaPendente;
        
        // Fechar formulário com sucesso
        ModalResult := mrOk;
      end
      else
      begin
        ExibirMensagem('Erro ao finalizar venda: ' + FRepositorioVenda.UltimoErro, True);
        HabilitarCampos(True);
        ProgressBar.Value := 0;
        FProgressoProcessamento := 0;
      end;
    end;
  end;
end;

{$ENDREGION}

end.
