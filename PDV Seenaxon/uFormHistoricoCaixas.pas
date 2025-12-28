unit uFormHistoricoCaixas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.Buttons, FMX.Objects, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Calendar,
  System.Generics.Collections,
  uRepositorioCaixa, uCaixa, uRelatórioGerencial;

type
  TFormHistoricoCaixas = class(TForm)
    PanelPrincipal: TPanel;
    PanelCabecalho: TPanel;
    LabelTitulo: TLabel;
    PanelFiltros: TPanel;
    LabelDataInicio: TLabel;
    EditDataInicio: TEdit;
    LabelDataFim: TLabel;
    EditDataFim: TEdit;
    ButtonPesquisar: TButton;
    ButtonLimpar: TButton;
    PanelConteudo: TPanel;
    PanelEsquerda: TPanel;
    PanelDireita: TPanel;
    PanelLista: TPanel;
    LabelLista: TLabel;
    ListBoxCaixas: TListBox;
    PanelResumo: TPanel;
    LabelResumo: TLabel;
    MemoResumo: TMemo;
    PanelAcoes: TPanel;
    ButtonExportarPDF: TButton;
    ButtonExportarCSV: TButton;
    ButtonVoltar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButtonPesquisarClick(Sender: TObject);
    procedure ButtonLimparClick(Sender: TObject);
    procedure ListBoxCaixasItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ButtonVoltarClick(Sender: TObject);
    procedure ButtonExportarPDFClick(Sender: TObject);
    procedure ButtonExportarCSVClick(Sender: TObject);
  private
    FRepositorioCaixa: TRepositorioCaixa;
    FRelatórioGerencial: TRelatórioGerencial;
    
    procedure AtualizarListaCaixas;
    procedure AjustarLayout;
    procedure ExibirResumo(AIndex: Integer);
    procedure ExibirRelatórioGerencial;
  public
    constructor Create(AOwner: TComponent; ARepositorioCaixa: TRepositorioCaixa); reintroduce;
  end;

var
  FormHistoricoCaixas: TFormHistoricoCaixas;

implementation

{$R *.fmx}

constructor TFormHistoricoCaixas.Create(AOwner: TComponent; ARepositorioCaixa: TRepositorioCaixa);
begin
  inherited Create(AOwner);
  FRepositorioCaixa := ARepositorioCaixa;
  FRelatórioGerencial := TRelatórioGerencial.Create(ARepositorioCaixa);
end;

procedure TFormHistoricoCaixas.FormCreate(Sender: TObject);
begin
  // Define datas padrão
  EditDataInicio.Text := FormatDateTime('dd/mm/yyyy', Date - 30);
  EditDataFim.Text := FormatDateTime('dd/mm/yyyy', Date);
  
  AjustarLayout;
  AtualizarListaCaixas;
end;

procedure TFormHistoricoCaixas.FormDestroy(Sender: TObject);
begin
  if Assigned(FRelatórioGerencial) then
    FRelatórioGerencial.Free;
end;

procedure TFormHistoricoCaixas.FormResize(Sender: TObject);
begin
  AjustarLayout;
end;

procedure TFormHistoricoCaixas.AjustarLayout;
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

procedure TFormHistoricoCaixas.AtualizarListaCaixas;
var
  Caixas: TObjectList<TCaixa>;
  i: Integer;
  Item: TListBoxItem;
  DataInicio, DataFim: TDateTime;
begin
  ListBoxCaixas.Clear;
  MemoResumo.Text := '';
  
  // Validar datas
  if not TryStrToDate(EditDataInicio.Text, DataInicio, 'dd/mm/yyyy') then
  begin
    ShowMessage('Data de início inválida');
    Exit;
  end;
  
  if not TryStrToDate(EditDataFim.Text, DataFim, 'dd/mm/yyyy') then
  begin
    ShowMessage('Data de fim inválida');
    Exit;
  end;
  
  // Buscar caixas no período
  Caixas := FRepositorioCaixa.BuscarPorDataIntervalo(DataInicio, DataFim);
  try
    if Caixas.Count = 0 then
    begin
      Item := TListBoxItem.Create(ListBoxCaixas);
      Item.Parent := ListBoxCaixas;
      Item.Text := 'Nenhum caixa encontrado neste período';
      Item.Enabled := False;
      Exit;
    end;
    
    for i := 0 to Caixas.Count - 1 do
    begin
      Item := TListBoxItem.Create(ListBoxCaixas);
      Item.Parent := ListBoxCaixas;
      Item.Text := Format('Caixa %d - %s - R$ %.2f - %s', 
        [Caixas[i].ID,
         Caixas[i].Operador.Nome,
         Caixas[i].TotalVendas,
         FormatDateTime('dd/mm/yyyy', Caixas[i].DataAbertura)]);
      Item.Tag := i;
    end;
    
    // Exibir relatório gerencial
    FRelatórioGerencial.DefinirPeriodo(DataInicio, DataFim);
    ExibirRelatórioGerencial;
  finally
    Caixas.Free;
  end;
end;

procedure TFormHistoricoCaixas.ButtonPesquisarClick(Sender: TObject);
begin
  AtualizarListaCaixas;
end;

procedure TFormHistoricoCaixas.ButtonLimparClick(Sender: TObject);
begin
  EditDataInicio.Text := FormatDateTime('dd/mm/yyyy', Date - 30);
  EditDataFim.Text := FormatDateTime('dd/mm/yyyy', Date);
  AtualizarListaCaixas;
end;

procedure TFormHistoricoCaixas.ListBoxCaixasItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  if Assigned(Item) and (Item.Tag >= 0) then
  begin
    ExibirResumo(Item.Tag);
  end;
end;

procedure TFormHistoricoCaixas.ExibirResumo(AIndex: Integer);
var
  Caixas: TObjectList<TCaixa>;
  DataInicio, DataFim: TDateTime;
begin
  if not TryStrToDate(EditDataInicio.Text, DataInicio, 'dd/mm/yyyy') then
    Exit;
  
  if not TryStrToDate(EditDataFim.Text, DataFim, 'dd/mm/yyyy') then
    Exit;
  
  Caixas := FRepositorioCaixa.BuscarPorDataIntervalo(DataInicio, DataFim);
  try
    if (AIndex >= 0) and (AIndex < Caixas.Count) then
    begin
      MemoResumo.Text := Caixas[AIndex].ObterResumoVendas;
    end;
  finally
    Caixas.Free;
  end;
end;

procedure TFormHistoricoCaixas.ExibirRelatórioGerencial;
begin
  MemoResumo.Text := FRelatórioGerencial.RelatórioDesempenho + sLineBreak + sLineBreak +
    FRelatórioGerencial.RelatórioVendasPorFormaPagamento;
end;

procedure TFormHistoricoCaixas.ButtonExportarPDFClick(Sender: TObject);
begin
  ShowMessage('Exportação para PDF será implementada em breve');
end;

procedure TFormHistoricoCaixas.ButtonExportarCSVClick(Sender: TObject);
var
  StringList: TStringList;
  Caixas: TObjectList<TCaixa>;
  i: Integer;
  DataInicio, DataFim: TDateTime;
  NomeArquivo: string;
begin
  if not TryStrToDate(EditDataInicio.Text, DataInicio, 'dd/mm/yyyy') then
  begin
    ShowMessage('Data de início inválida');
    Exit;
  end;
  
  if not TryStrToDate(EditDataFim.Text, DataFim, 'dd/mm/yyyy') then
  begin
    ShowMessage('Data de fim inválida');
    Exit;
  end;
  
  Caixas := FRepositorioCaixa.BuscarPorDataIntervalo(DataInicio, DataFim);
  StringList := TStringList.Create;
  try
    // Cabeçalho
    StringList.Add('HISTÓRICO DE CAIXAS');
    StringList.Add('Período: ' + FormatDateTime('dd/mm/yyyy', DataInicio) + ' a ' + FormatDateTime('dd/mm/yyyy', DataFim));
    StringList.Add('');
    StringList.Add('ID;Operador;Data Abertura;Data Fechamento;Saldo Inicial;Total Vendas;Saldo Final;Quantidade Vendas');
    
    // Dados
    for i := 0 to Caixas.Count - 1 do
    begin
      StringList.Add(Format('%d;%s;%s;%s;%.2f;%.2f;%.2f;%d',
        [Caixas[i].ID,
         Caixas[i].Operador.Nome,
         FormatDateTime('dd/mm/yyyy hh:mm:ss', Caixas[i].DataAbertura),
         FormatDateTime('dd/mm/yyyy hh:mm:ss', Caixas[i].DataFechamento),
         Caixas[i].SaldoInicial,
         Caixas[i].TotalVendas,
         Caixas[i].SaldoFinal,
         Caixas[i].QuantidadeVendas]));
    end;
    
    // Salvar arquivo
    NomeArquivo := GetHomePath + '/historico_caixas_' + FormatDateTime('yyyymmdd_hhmmss', Now) + '.csv';
    StringList.SaveToFile(NomeArquivo);
    ShowMessage('Arquivo exportado com sucesso: ' + NomeArquivo);
  finally
    StringList.Free;
    Caixas.Free;
  end;
end;

procedure TFormHistoricoCaixas.ButtonVoltarClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
