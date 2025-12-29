unit uFormGerenciamentoCaixa;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Layouts, FMX.Objects, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  FMX.Memo, FMX.Edit, FMX.Controls.Presentation, FMX.ListBox,
  System.Generics.Collections,
  uCaixa, uRepositorioCaixa, uOperador;

type
  TFormGerenciamentoCaixa = class(TForm)
    LayoutPrincipal: TLayout;
    LayoutCabecalho: TLayout;
    LabelTitulo: TLabel;
    ButtonFechar: TButton;
    LayoutConteudo: TLayout;
    LayoutEsquerda: TLayout;
    LayoutStatus: TLayout;
    LabelStatusTitulo: TLabel;
    LabelStatus: TLabel;
    LayoutOperador: TLayout;
    LabelOperadorTitulo: TLabel;
    LabelOperador: TLabel;
    LayoutDataAbertura: TLayout;
    LabelDataAberturaTitulo: TLabel;
    LabelDataAbertura: TLabel;
    LayoutSaldoInicial: TLayout;
    LabelSaldoInicialTitulo: TLabel;
    LabelSaldoInicial: TLabel;
    LayoutSaldoAtual: TLayout;
    LabelSaldoAtualTitulo: TLabel;
    LabelSaldoAtual: TLabel;
    LayoutBotoes: TLayout;
    ButtonAbrirCaixa: TButton;
    ButtonFecharCaixa: TButton;
    ButtonSangria: TButton;
    ButtonSuprimento: TButton;
    LayoutDireita: TLayout;
    LayoutResumo: TLayout;
    LabelResumoTitulo: TLabel;
    MemoResumo: TMemo;
    LayoutMovimentacoes: TLayout;
    LabelMovimentacoesTitulo: TLabel;
    ListBoxMovimentacoes: TListBox;
    LayoutRodape: TLayout;
    LabelRodape: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonAbrirCaixaClick(Sender: TObject);
    procedure ButtonFecharCaixaClick(Sender: TObject);
    procedure ButtonSangriaClick(Sender: TObject);
    procedure ButtonSuprimentoClick(Sender: TObject);
    procedure ButtonFecharClick(Sender: TObject);
  private
    FRepositorio: TRepositorioCaixa;
    FOperador: TOperador;
    
    procedure InicializarUI;
    procedure AtualizarStatus;
    procedure AtualizarResumo;
    procedure AtualizarMovimentacoes;
    procedure AjustarLayout;
  public
    procedure SetOperador(AOperador: TOperador);
    procedure SetRepositorio(ARepositorio: TRepositorioCaixa);
  end;

var
  FormGerenciamentoCaixa: TFormGerenciamentoCaixa;

implementation

{$R *.fmx}

{ ============================================================================
  EVENTOS DO FORMULÁRIO
  ============================================================================ }

procedure TFormGerenciamentoCaixa.FormCreate(Sender: TObject);
begin
  FRepositorio := nil;
  FOperador := nil;
  
  InicializarUI;
  AjustarLayout;
end;

procedure TFormGerenciamentoCaixa.FormDestroy(Sender: TObject);
begin
  // Não liberar repositório e operador, pois são gerenciados externamente
end;

{ ============================================================================
  INICIALIZAÇÃO
  ============================================================================ }

procedure TFormGerenciamentoCaixa.InicializarUI;
begin
  { Configurar cores }
  LayoutCabecalho.Fill.Color := $FF1A1A1A;
  LabelTitulo.TextSettings.FontColor := $FFFFFFFF;
  
  { Configurar botões }
  ButtonAbrirCaixa.Text := 'Abrir Caixa';
  ButtonFecharCaixa.Text := 'Fechar Caixa';
  ButtonSangria.Text := 'Sangria';
  ButtonSuprimento.Text := 'Suprimento';
  ButtonFechar.Text := 'Fechar';
  
  { Desabilitar botões inicialmente }
  ButtonFecharCaixa.Enabled := False;
  ButtonSangria.Enabled := False;
  ButtonSuprimento.Enabled := False;
  
  AtualizarStatus;
end;

procedure TFormGerenciamentoCaixa.AjustarLayout;
begin
  { Ajustar tamanhos conforme resolução }
  if ClientWidth < 1000 then
  begin
    LayoutEsquerda.Width := ClientWidth * 0.4;
    LayoutDireita.Width := ClientWidth * 0.6;
  end
  else if ClientWidth < 1400 then
  begin
    LayoutEsquerda.Width := ClientWidth * 0.35;
    LayoutDireita.Width := ClientWidth * 0.65;
  end
  else
  begin
    LayoutEsquerda.Width := ClientWidth * 0.3;
    LayoutDireita.Width := ClientWidth * 0.7;
  end;
end;

{ ============================================================================
  SETTERS
  ============================================================================ }

procedure TFormGerenciamentoCaixa.SetOperador(AOperador: TOperador);
begin
  FOperador := AOperador;
  
  if Assigned(FOperador) then
  begin
    LabelOperador.Text := FOperador.Nome + ' (' + FOperador.Matricula + ')';
  end;
end;

procedure TFormGerenciamentoCaixa.SetRepositorio(ARepositorio: TRepositorioCaixa);
begin
  FRepositorio := ARepositorio;
  AtualizarStatus;
end;

{ ============================================================================
  ATUALIZAÇÃO DE UI
  ============================================================================ }

procedure TFormGerenciamentoCaixa.AtualizarStatus;
var
  Caixa: TCaixa;
begin
  if not Assigned(FRepositorio) then
    Exit;
  
  Caixa := FRepositorio.CaixaAtual;
  
  if Assigned(Caixa) and Caixa.EstaAberto then
  begin
    { Caixa aberto }
    LabelStatus.Text := 'ABERTO';
    LabelStatus.TextSettings.FontColor := $FF00AA00; { Verde }
    
    LabelDataAbertura.Text := FormatDateTime('dd/mm/yyyy hh:mm:ss', Caixa.DataAbertura);
    LabelSaldoInicial.Text := 'R$ ' + FormatFloat('0.00', Caixa.SaldoInicial);
    LabelSaldoAtual.Text := 'R$ ' + FormatFloat('0.00', 
      Caixa.SaldoInicial + Caixa.TotalVendas - Caixa.TotalSangria + Caixa.TotalSuprimento);
    
    { Habilitar botões }
    ButtonAbrirCaixa.Enabled := False;
    ButtonFecharCaixa.Enabled := True;
    ButtonSangria.Enabled := True;
    ButtonSuprimento.Enabled := True;
    
    AtualizarResumo;
    AtualizarMovimentacoes;
  end
  else
  begin
    { Caixa fechado }
    LabelStatus.Text := 'FECHADO';
    LabelStatus.TextSettings.FontColor := $FFFF0000; { Vermelho }
    
    LabelDataAbertura.Text := '-';
    LabelSaldoInicial.Text := 'R$ 0.00';
    LabelSaldoAtual.Text := 'R$ 0.00';
    
    { Habilitar apenas abrir caixa }
    ButtonAbrirCaixa.Enabled := True;
    ButtonFecharCaixa.Enabled := False;
    ButtonSangria.Enabled := False;
    ButtonSuprimento.Enabled := False;
    
    MemoResumo.Lines.Clear;
    ListBoxMovimentacoes.Items.Clear;
  end;
end;

procedure TFormGerenciamentoCaixa.AtualizarResumo;
var
  Caixa: TCaixa;
begin
  if not Assigned(FRepositorio) then
    Exit;
  
  Caixa := FRepositorio.CaixaAtual;
  
  if not Assigned(Caixa) or not Caixa.EstaAberto then
    Exit;
  
  MemoResumo.Lines.Clear;
  MemoResumo.Lines.Add('╔════════════════════════════════════════╗');
  MemoResumo.Lines.Add('║         RESUMO DO CAIXA ATUAL          ║');
  MemoResumo.Lines.Add('╚════════════════════════════════════════╝');
  MemoResumo.Lines.Add('');
  
  MemoResumo.Lines.Add('─── SALDOS ───');
  MemoResumo.Lines.Add('Saldo Inicial: R$ ' + FormatFloat('0.00', Caixa.SaldoInicial));
  MemoResumo.Lines.Add('Total de Vendas: R$ ' + FormatFloat('0.00', Caixa.TotalVendas));
  MemoResumo.Lines.Add('Total Sangria: R$ ' + FormatFloat('0.00', Caixa.TotalSangria));
  MemoResumo.Lines.Add('Total Suprimento: R$ ' + FormatFloat('0.00', Caixa.TotalSuprimento));
  MemoResumo.Lines.Add('Saldo Atual: R$ ' + FormatFloat('0.00', 
    Caixa.SaldoInicial + Caixa.TotalVendas - Caixa.TotalSangria + Caixa.TotalSuprimento));
  MemoResumo.Lines.Add('');
  
  MemoResumo.Lines.Add('─── VENDAS ───');
  MemoResumo.Lines.Add('Quantidade: ' + IntToStr(Caixa.QuantidadeVendas));
  MemoResumo.Lines.Add('Produtos: ' + IntToStr(Caixa.QuantidadeProdutos));
  MemoResumo.Lines.Add('Desconto: R$ ' + FormatFloat('0.00', Caixa.TotalDesconto));
  MemoResumo.Lines.Add('Acréscimo: R$ ' + FormatFloat('0.00', Caixa.TotalAcrescimo));
  MemoResumo.Lines.Add('');
  
  MemoResumo.Lines.Add('─── FORMAS DE PAGAMENTO ───');
  MemoResumo.Lines.Add('Dinheiro: R$ ' + FormatFloat('0.00', Caixa.TotalDinheiro));
  MemoResumo.Lines.Add('Cartão: R$ ' + FormatFloat('0.00', Caixa.TotalCartao));
  MemoResumo.Lines.Add('PIX: R$ ' + FormatFloat('0.00', Caixa.TotalPIX));
end;

procedure TFormGerenciamentoCaixa.AtualizarMovimentacoes;
var
  Caixa: TCaixa;
  Movimentacoes: TObjectList<TMovimentacao>;
  i: Integer;
  Item: TListBoxItem;
begin
  ListBoxMovimentacoes.Items.Clear;
  
  if not Assigned(FRepositorio) then
    Exit;
  
  Caixa := FRepositorio.CaixaAtual;
  
  if not Assigned(Caixa) then
    Exit;
  
  Movimentacoes := Caixa.ObterMovimentacoes;
  try
    for i := 0 to Movimentacoes.Count - 1 do
    begin
      Item := TListBoxItem.Create(ListBoxMovimentacoes);
      Item.Parent := ListBoxMovimentacoes;
      Item.Text := Movimentacoes[i].GetTipoAsString + ': R$ ' + 
        FormatFloat('0.00', Movimentacoes[i].Valor) + ' - ' + 
        Movimentacoes[i].Motivo;
      Item.Height := 40;
    end;
  finally
    Movimentacoes.Free;
  end;
end;

{ ============================================================================
  EVENTOS DOS BOTÕES
  ============================================================================ }

procedure TFormGerenciamentoCaixa.ButtonAbrirCaixaClick(Sender: TObject);
var
  SaldoInicial: Double;
  Caixa: TCaixa;
begin
  if not Assigned(FRepositorio) or not Assigned(FOperador) then
  begin
    ShowMessage('Erro: Repositório ou Operador não configurado');
    Exit;
  end;
  
  { Solicitar saldo inicial }
  SaldoInicial := StrToFloatDef(InputBox('Abrir Caixa', 'Saldo Inicial:', '0.00'), 0.00);
  
  if SaldoInicial < 0 then
  begin
    ShowMessage('Erro: Saldo inicial não pode ser negativo');
    Exit;
  end;
  
  { Abrir caixa }
  Caixa := FRepositorio.AbrirCaixa(FOperador, SaldoInicial);
  
  if Assigned(Caixa) then
  begin
    ShowMessage('Caixa aberto com sucesso!' + sLineBreak + 
      'Saldo Inicial: R$ ' + FormatFloat('0.00', SaldoInicial));
    AtualizarStatus;
  end
  else
  begin
    ShowMessage('Erro ao abrir caixa: ' + FRepositorio.UltimoErro);
  end;
end;

procedure TFormGerenciamentoCaixa.ButtonFecharCaixaClick(Sender: TObject);
var
  Confirmacao: Integer;
begin
  if not Assigned(FRepositorio) then
    Exit;
  
  { Confirmar fechamento }
  Confirmacao := MessageDlg('Deseja realmente fechar o caixa?', 
    TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0);
  
  if Confirmacao <> mrYes then
    Exit;
  
  { Fechar caixa }
  if FRepositorio.FecharCaixa then
  begin
    ShowMessage('Caixa fechado com sucesso!');
    AtualizarStatus;
  end
  else
  begin
    ShowMessage('Erro ao fechar caixa: ' + FRepositorio.UltimoErro);
  end;
end;

procedure TFormGerenciamentoCaixa.ButtonSangriaClick(Sender: TObject);
var
  Valor: Double;
  Motivo: string;
  Caixa: TCaixa;
begin
  if not Assigned(FRepositorio) then
    Exit;
  
  Caixa := FRepositorio.CaixaAtual;
  
  if not Assigned(Caixa) or not Caixa.EstaAberto then
  begin
    ShowMessage('Erro: Caixa não está aberto');
    Exit;
  end;
  
  { Solicitar valor }
  Valor := StrToFloatDef(InputBox('Sangria', 'Valor:', '0.00'), 0.00);
  
  if Valor <= 0 then
  begin
    ShowMessage('Erro: Valor deve ser positivo');
    Exit;
  end;
  
  { Solicitar motivo }
  Motivo := InputBox('Sangria', 'Motivo:', '');
  
  { Realizar sangria }
  if Caixa.RealizarSangria(Valor, Motivo) then
  begin
    ShowMessage('Sangria realizada com sucesso!' + sLineBreak + 
      'Valor: R$ ' + FormatFloat('0.00', Valor));
    AtualizarStatus;
  end
  else
  begin
    ShowMessage('Erro ao realizar sangria: Saldo insuficiente');
  end;
end;

procedure TFormGerenciamentoCaixa.ButtonSuprimentoClick(Sender: TObject);
var
  Valor: Double;
  Motivo: string;
  Caixa: TCaixa;
begin
  if not Assigned(FRepositorio) then
    Exit;
  
  Caixa := FRepositorio.CaixaAtual;
  
  if not Assigned(Caixa) or not Caixa.EstaAberto then
  begin
    ShowMessage('Erro: Caixa não está aberto');
    Exit;
  end;
  
  { Solicitar valor }
  Valor := StrToFloatDef(InputBox('Suprimento', 'Valor:', '0.00'), 0.00);
  
  if Valor <= 0 then
  begin
    ShowMessage('Erro: Valor deve ser positivo');
    Exit;
  end;
  
  { Solicitar motivo }
  Motivo := InputBox('Suprimento', 'Motivo:', '');
  
  { Realizar suprimento }
  if Caixa.RealizarSuprimento(Valor, Motivo) then
  begin
    ShowMessage('Suprimento realizado com sucesso!' + sLineBreak + 
      'Valor: R$ ' + FormatFloat('0.00', Valor));
    AtualizarStatus;
  end
  else
  begin
    ShowMessage('Erro ao realizar suprimento');
  end;
end;

procedure TFormGerenciamentoCaixa.ButtonFecharClick(Sender: TObject);
begin
  Close;
end;

end.
