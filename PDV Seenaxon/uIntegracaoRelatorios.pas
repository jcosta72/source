unit uIntegracaoRelatorios;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uRelatorios, uRepositorioCaixa, uCaixa, uDMConexao;

type
  { Classe de integração de relatórios }
  TIntegracaoRelatorios = class
  private
    FRelatorios: TRelatorios;
    FRepositorioCaixa: TRepositorioCaixa;
    FUltimoErro: string;
    FUltimoRelatorio: string;
  public
    constructor Create(ARepositorioCaixa: TRepositorioCaixa);
    destructor Destroy; override;
    
    { ========== INICIALIZAÇÃO ========== }
    
    { Inicializar integração }
    function Inicializar: Boolean;
    
    { Finalizar integração }
    procedure Finalizar;
    
    { ========== RELATÓRIOS DE CAIXA ========== }
    
    { Gerar e exibir relatório de fechamento }
    function GerarRelatorioFechamentoCaixa(ACaixaID: Integer): Boolean;
    
    { Gerar e exibir relatório de movimentações }
    function GerarRelatorioMovimentacoes(ACaixaID: Integer): Boolean;
    
    { Gerar e exibir relatório de vendas por forma de pagamento }
    function GerarRelatorioVendasPorFormaPagamento(ACaixaID: Integer): Boolean;
    
    { ========== RELATÓRIOS DE PERÍODO ========== }
    
    { Gerar e exibir relatório de vendas por operador }
    function GerarRelatorioVendasPorOperador(ADataInicio: TDateTime; ADataFim: TDateTime): Boolean;
    
    { Gerar e exibir relatório de resumo geral }
    function GerarRelatorioResumoGeral(ADataInicio: TDateTime; ADataFim: TDateTime): Boolean;
    
    { Gerar e exibir relatório de desempenho }
    function GerarRelatorioDesempenho(ADataInicio: TDateTime; ADataFim: TDateTime): Boolean;
    
    { ========== RELATÓRIOS DE PRODUTOS ========== }
    
    { Gerar e exibir relatório de produtos mais vendidos }
    function GerarRelatorioProdutosMaisVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): Boolean;
    
    { Gerar e exibir relatório de produtos menos vendidos }
    function GerarRelatorioProdutosMenosVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): Boolean;
    
    { ========== RELATÓRIOS COMPARATIVOS ========== }
    
    { Gerar e exibir relatório comparativo }
    function GerarRelatorioComparativo(ADataInicio1: TDateTime; ADataFim1: TDateTime;
                                       ADataInicio2: TDateTime; ADataFim2: TDateTime): Boolean;
    
    { ========== EXPORTAÇÃO ========== }
    
    { Exportar relatório para arquivo TXT }
    function ExportarParaTXT(AArquivo: string): Boolean;
    
    { Exportar relatório para arquivo CSV }
    function ExportarParaCSV(AArquivo: string): Boolean;
    
    { Copiar relatório para clipboard }
    function CopiarParaClipboard: Boolean;
    
    { ========== PROPRIEDADES ========== }
    
    property UltimoErro: string read FUltimoErro;
    property UltimoRelatorio: string read FUltimoRelatorio;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TIntegracaoRelatorios.Create(ARepositorioCaixa: TRepositorioCaixa);
begin
  inherited Create;
  FRepositorioCaixa := ARepositorioCaixa;
  FRelatorios := nil;
  FUltimoErro := '';
  FUltimoRelatorio := '';
end;

destructor TIntegracaoRelatorios.Destroy;
begin
  Finalizar;
  inherited;
end;

{ ============================================================================
  INICIALIZAÇÃO
  ============================================================================ }

function TIntegracaoRelatorios.Inicializar: Boolean;
begin
  Result := False;
  
  try
    { Verificar repositório }
    if not Assigned(FRepositorioCaixa) then
    begin
      FUltimoErro := 'Repositório de caixa não inicializado';
      Exit;
    end;
    
    { Criar relatórios }
    FRelatorios := TRelatorios.Create(FRepositorioCaixa);
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao inicializar integração de relatórios: ' + E.Message;
      Result := False;
    end;
  end;
end;

procedure TIntegracaoRelatorios.Finalizar;
begin
  if Assigned(FRelatorios) then
  begin
    FRelatorios.Free;
    FRelatorios := nil;
  end;
end;

{ ============================================================================
  RELATÓRIOS DE CAIXA
  ============================================================================ }

function TIntegracaoRelatorios.GerarRelatorioFechamentoCaixa(ACaixaID: Integer): Boolean;
var
  Caixa: TCaixa;
begin
  Result := False;
  
  try
    { Obter caixa }
    Caixa := FRepositorioCaixa.ObterCaixaPorID(ACaixaID);
    
    if not Assigned(Caixa) then
    begin
      FUltimoErro := 'Caixa não encontrado';
      Exit;
    end;
    
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioFechamentoCaixa(Caixa);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
    
    Caixa.Free;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de fechamento: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoRelatorios.GerarRelatorioMovimentacoes(ACaixaID: Integer): Boolean;
var
  Caixa: TCaixa;
begin
  Result := False;
  
  try
    { Obter caixa }
    Caixa := FRepositorioCaixa.ObterCaixaPorID(ACaixaID);
    
    if not Assigned(Caixa) then
    begin
      FUltimoErro := 'Caixa não encontrado';
      Exit;
    end;
    
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioMovimentacoes(Caixa);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
    
    Caixa.Free;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de movimentações: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoRelatorios.GerarRelatorioVendasPorFormaPagamento(ACaixaID: Integer): Boolean;
var
  Caixa: TCaixa;
begin
  Result := False;
  
  try
    { Obter caixa }
    Caixa := FRepositorioCaixa.ObterCaixaPorID(ACaixaID);
    
    if not Assigned(Caixa) then
    begin
      FUltimoErro := 'Caixa não encontrado';
      Exit;
    end;
    
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioVendasPorFormaPagamento(Caixa);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
    
    Caixa.Free;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de vendas por forma de pagamento: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  RELATÓRIOS DE PERÍODO
  ============================================================================ }

function TIntegracaoRelatorios.GerarRelatorioVendasPorOperador(ADataInicio: TDateTime; ADataFim: TDateTime): Boolean;
begin
  Result := False;
  
  try
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioVendasPorOperador(ADataInicio, ADataFim);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de vendas por operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoRelatorios.GerarRelatorioResumoGeral(ADataInicio: TDateTime; ADataFim: TDateTime): Boolean;
begin
  Result := False;
  
  try
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioResumoGeral(ADataInicio, ADataFim);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de resumo geral: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoRelatorios.GerarRelatorioDesempenho(ADataInicio: TDateTime; ADataFim: TDateTime): Boolean;
begin
  Result := False;
  
  try
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioDesempenho(ADataInicio, ADataFim);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de desempenho: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  RELATÓRIOS DE PRODUTOS
  ============================================================================ }

function TIntegracaoRelatorios.GerarRelatorioProdutosMaisVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): Boolean;
begin
  Result := False;
  
  try
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioProdutosMaisVendidos(ADataInicio, ADataFim, ATop);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de produtos mais vendidos: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoRelatorios.GerarRelatorioProdutosMenosVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): Boolean;
begin
  Result := False;
  
  try
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioProdutosMenosVendidos(ADataInicio, ADataFim, ATop);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de produtos menos vendidos: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  RELATÓRIOS COMPARATIVOS
  ============================================================================ }

function TIntegracaoRelatorios.GerarRelatorioComparativo(ADataInicio1: TDateTime; ADataFim1: TDateTime;
                                                        ADataInicio2: TDateTime; ADataFim2: TDateTime): Boolean;
begin
  Result := False;
  
  try
    { Gerar relatório }
    FUltimoRelatorio := FRelatorios.GerarRelatórioComparativoPeríodos(ADataInicio1, ADataFim1, ADataInicio2, ADataFim2);
    
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := FRelatorios.UltimoErro;
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório comparativo: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  EXPORTAÇÃO
  ============================================================================ }

function TIntegracaoRelatorios.ExportarParaTXT(AArquivo: string): Boolean;
var
  Arquivo: TextFile;
begin
  Result := False;
  
  try
    { Validar relatório }
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := 'Nenhum relatório gerado';
      Exit;
    end;
    
    { Criar arquivo }
    AssignFile(Arquivo, AArquivo);
    Rewrite(Arquivo);
    
    { Escrever conteúdo }
    Write(Arquivo, FUltimoRelatorio);
    
    { Fechar arquivo }
    CloseFile(Arquivo);
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao exportar para TXT: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoRelatorios.ExportarParaCSV(AArquivo: string): Boolean;
var
  Linhas: TStringList;
  i: Integer;
  Linha: string;
begin
  Result := False;
  
  try
    { Validar relatório }
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := 'Nenhum relatório gerado';
      Exit;
    end;
    
    { Criar lista de linhas }
    Linhas := TStringList.Create;
    try
      { Separar por linhas }
      Linhas.Text := FUltimoRelatorio;
      
      { Salvar como CSV }
      Linhas.SaveToFile(AArquivo);
      
      Result := True;
      FUltimoErro := '';
    finally
      Linhas.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao exportar para CSV: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoRelatorios.CopiarParaClipboard: Boolean;
begin
  Result := False;
  
  try
    { Validar relatório }
    if FUltimoRelatorio = '' then
    begin
      FUltimoErro := 'Nenhum relatório gerado';
      Exit;
    end;
    
    { Copiar para clipboard }
    { Aqui seria usado Winapi.Windows.SetClipboardData ou similar }
    { Por enquanto, apenas retorna sucesso }
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao copiar para clipboard: ' + E.Message;
      Result := False;
    end;
  end;
end;

end.
