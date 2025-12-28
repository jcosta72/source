unit uRelatórioGerencial;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uCaixa, uRepositorioCaixa, uOperador, uVenda;

type
  TRelatórioGerencial = class
  private
    FRepositorioCaixa: TRepositorioCaixa;
    FDataInicio: TDateTime;
    FDataFim: TDateTime;
    
    function FormatarLinha(ATexto: string; ALargura: Integer = 80): string;
    function CentralizarTexto(ATexto: string; ALargura: Integer = 80): string;
    function RepetirCaractere(ACaractere: Char; AQuantidade: Integer): string;
  public
    constructor Create(ARepositorioCaixa: TRepositorioCaixa);
    destructor Destroy; override;
    
    // Configuração
    procedure DefinirPeriodo(ADataInicio, ADataFim: TDateTime);
    
    // Relatórios
    function RelatórioVendasPorOperador: string;
    function RelatórioVendasPorFormaPagamento: string;
    function RelatórioDesempenho: string;
    function RelatórioComparativoOperadores: string;
    function RelatórioDetalhado: string;
    function RelatórioResumoExecutivo: string;
    
    // Métodos auxiliares
    function ObterCaixasPeriodo: TObjectList<TCaixa>;
    function ObterTotalVendasPeriodo: Double;
    function ObterQuantidadeVendasPeriodo: Integer;
    function ObterValorMedioVendaPeriodo: Double;
    
    property DataInicio: TDateTime read FDataInicio write FDataInicio;
    property DataFim: TDateTime read FDataFim write FDataFim;
  end;

implementation

constructor TRelatórioGerencial.Create(ARepositorioCaixa: TRepositorioCaixa);
begin
  inherited Create;
  FRepositorioCaixa := ARepositorioCaixa;
  FDataInicio := Date;
  FDataFim := Date;
end;

destructor TRelatórioGerencial.Destroy;
begin
  inherited;
end;

procedure TRelatórioGerencial.DefinirPeriodo(ADataInicio, ADataFim: TDateTime);
begin
  FDataInicio := ADataInicio;
  FDataFim := ADataFim;
end;

function TRelatórioGerencial.FormatarLinha(ATexto: string; ALargura: Integer = 80): string;
begin
  Result := ATexto;
  while Length(Result) < ALargura do
    Result := Result + ' ';
  if Length(Result) > ALargura then
    Result := Copy(Result, 1, ALargura);
end;

function TRelatórioGerencial.CentralizarTexto(ATexto: string; ALargura: Integer = 80): string;
var
  Espacos: Integer;
begin
  Espacos := (ALargura - Length(ATexto)) div 2;
  Result := StringOfChar(' ', Espacos) + ATexto;
end;

function TRelatórioGerencial.RepetirCaractere(ACaractere: Char; AQuantidade: Integer): string;
begin
  Result := StringOfChar(ACaractere, AQuantidade);
end;

function TRelatórioGerencial.ObterCaixasPeriodo: TObjectList<TCaixa>;
begin
  Result := FRepositorioCaixa.BuscarPorDataIntervalo(FDataInicio, FDataFim);
end;

function TRelatórioGerencial.ObterTotalVendasPeriodo: Double;
var
  Caixas: TObjectList<TCaixa>;
  i: Integer;
begin
  Result := 0;
  Caixas := ObterCaixasPeriodo;
  try
    for i := 0 to Caixas.Count - 1 do
      Result := Result + Caixas[i].TotalVendas;
  finally
    Caixas.Free;
  end;
end;

function TRelatórioGerencial.ObterQuantidadeVendasPeriodo: Integer;
var
  Caixas: TObjectList<TCaixa>;
  i: Integer;
begin
  Result := 0;
  Caixas := ObterCaixasPeriodo;
  try
    for i := 0 to Caixas.Count - 1 do
      Result := Result + Caixas[i].QuantidadeVendas;
  finally
    Caixas.Free;
  end;
end;

function TRelatórioGerencial.ObterValorMedioVendaPeriodo: Double;
var
  Quantidade: Integer;
  Total: Double;
begin
  Quantidade := ObterQuantidadeVendasPeriodo;
  if Quantidade > 0 then
  begin
    Total := ObterTotalVendasPeriodo;
    Result := Total / Quantidade;
  end
  else
    Result := 0;
end;

function TRelatórioGerencial.RelatórioVendasPorOperador: string;
var
  Caixas: TObjectList<TCaixa>;
  Operadores: TDictionary<Integer, Double>;
  Operador: TOperador;
  i: Integer;
  Total: Double;
begin
  Result := '';
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + CentralizarTexto('RELATÓRIO DE VENDAS POR OPERADOR') + sLineBreak;
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + Format('Período: %s a %s', 
    [FormatDateTime('dd/mm/yyyy', FDataInicio), FormatDateTime('dd/mm/yyyy', FDataFim)]) + sLineBreak;
  Result := Result + sLineBreak;
  
  Caixas := ObterCaixasPeriodo;
  Operadores := TDictionary<Integer, Double>.Create;
  try
    // Agrupa vendas por operador
    for i := 0 to Caixas.Count - 1 do
    begin
      if Operadores.ContainsKey(Caixas[i].Operador.ID) then
        Operadores[Caixas[i].Operador.ID] := Operadores[Caixas[i].Operador.ID] + Caixas[i].TotalVendas
      else
        Operadores.Add(Caixas[i].Operador.ID, Caixas[i].TotalVendas);
    end;
    
    // Exibe relatório
    Result := Result + FormatarLinha('OPERADOR', 40) + FormatarLinha('TOTAL VENDAS', 20) + sLineBreak;
    Result := Result + RepetirCaractere('-', 80) + sLineBreak;
    
    Total := 0;
    for i := 0 to Caixas.Count - 1 do
    begin
      if Operadores.ContainsKey(Caixas[i].Operador.ID) then
      begin
        Result := Result + FormatarLinha(Caixas[i].Operador.Nome, 40) + 
          Format('R$ %10.2f', [Operadores[Caixas[i].Operador.ID]]) + sLineBreak;
        Total := Total + Operadores[Caixas[i].Operador.ID];
        Operadores.Remove(Caixas[i].Operador.ID);
      end;
    end;
    
    Result := Result + RepetirCaractere('-', 80) + sLineBreak;
    Result := Result + FormatarLinha('TOTAL GERAL', 40) + Format('R$ %10.2f', [Total]) + sLineBreak;
  finally
    Operadores.Free;
    Caixas.Free;
  end;
end;

function TRelatórioGerencial.RelatórioVendasPorFormaPagamento: string;
var
  Caixas: TObjectList<TCaixa>;
  TotalDinheiro, TotalCartao, TotalPIX: Double;
  i: Integer;
begin
  Result := '';
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + CentralizarTexto('RELATÓRIO DE VENDAS POR FORMA DE PAGAMENTO') + sLineBreak;
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + Format('Período: %s a %s', 
    [FormatDateTime('dd/mm/yyyy', FDataInicio), FormatDateTime('dd/mm/yyyy', FDataFim)]) + sLineBreak;
  Result := Result + sLineBreak;
  
  Caixas := ObterCaixasPeriodo;
  TotalDinheiro := 0;
  TotalCartao := 0;
  TotalPIX := 0;
  
  try
    for i := 0 to Caixas.Count - 1 do
    begin
      TotalDinheiro := TotalDinheiro + Caixas[i].TotalDinheiro;
      TotalCartao := TotalCartao + Caixas[i].TotalCartao;
      TotalPIX := TotalPIX + Caixas[i].TotalPIX;
    end;
    
    Result := Result + FormatarLinha('FORMA DE PAGAMENTO', 40) + FormatarLinha('TOTAL', 20) + sLineBreak;
    Result := Result + RepetirCaractere('-', 80) + sLineBreak;
    Result := Result + FormatarLinha('DINHEIRO', 40) + Format('R$ %10.2f', [TotalDinheiro]) + sLineBreak;
    Result := Result + FormatarLinha('CARTÃO', 40) + Format('R$ %10.2f', [TotalCartao]) + sLineBreak;
    Result := Result + FormatarLinha('PIX', 40) + Format('R$ %10.2f', [TotalPIX]) + sLineBreak;
    Result := Result + RepetirCaractere('-', 80) + sLineBreak;
    Result := Result + FormatarLinha('TOTAL GERAL', 40) + 
      Format('R$ %10.2f', [TotalDinheiro + TotalCartao + TotalPIX]) + sLineBreak;
  finally
    Caixas.Free;
  end;
end;

function TRelatórioGerencial.RelatórioDesempenho: string;
var
  TotalVendas: Double;
  QuantidadeVendas: Integer;
  ValorMedio: Double;
  Caixas: TObjectList<TCaixa>;
  i: Integer;
  MaiorVenda, MenorVenda: Double;
begin
  Result := '';
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + CentralizarTexto('RELATÓRIO DE DESEMPENHO') + sLineBreak;
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + Format('Período: %s a %s', 
    [FormatDateTime('dd/mm/yyyy', FDataInicio), FormatDateTime('dd/mm/yyyy', FDataFim)]) + sLineBreak;
  Result := Result + sLineBreak;
  
  TotalVendas := ObterTotalVendasPeriodo;
  QuantidadeVendas := ObterQuantidadeVendasPeriodo;
  ValorMedio := ObterValorMedioVendaPeriodo;
  
  Caixas := ObterCaixasPeriodo;
  MaiorVenda := 0;
  MenorVenda := 999999;
  
  try
    for i := 0 to Caixas.Count - 1 do
    begin
      if Caixas[i].MaiorVenda > MaiorVenda then
        MaiorVenda := Caixas[i].MaiorVenda;
      if Caixas[i].MenorVenda < MenorVenda then
        MenorVenda := Caixas[i].MenorVenda;
    end;
    
    if MenorVenda = 999999 then
      MenorVenda := 0;
    
    Result := Result + 'INDICADORES GERAIS:' + sLineBreak;
    Result := Result + RepetirCaractere('-', 80) + sLineBreak;
    Result := Result + Format('Total de Vendas: R$ %.2f', [TotalVendas]) + sLineBreak;
    Result := Result + Format('Quantidade de Vendas: %d', [QuantidadeVendas]) + sLineBreak;
    Result := Result + Format('Valor Médio por Venda: R$ %.2f', [ValorMedio]) + sLineBreak;
    Result := Result + Format('Maior Venda: R$ %.2f', [MaiorVenda]) + sLineBreak;
    Result := Result + Format('Menor Venda: R$ %.2f', [MenorVenda]) + sLineBreak;
    Result := Result + sLineBreak;
    
    Result := Result + 'CAIXAS PROCESSADOS:' + sLineBreak;
    Result := Result + RepetirCaractere('-', 80) + sLineBreak;
    Result := Result + Format('Total de Caixas: %d', [Caixas.Count]) + sLineBreak;
  finally
    Caixas.Free;
  end;
end;

function TRelatórioGerencial.RelatórioComparativoOperadores: string;
var
  Caixas: TObjectList<TCaixa>;
  OperadorVendas: TDictionary<string, Double>;
  OperadorQuantidade: TDictionary<string, Integer>;
  i: Integer;
  Chave: string;
  Valor: Double;
  Quantidade: Integer;
begin
  Result := '';
  Result := Result + RepetirCaractere('=', 100) + sLineBreak;
  Result := Result + CentralizarTexto('RELATÓRIO COMPARATIVO DE OPERADORES', 100) + sLineBreak;
  Result := Result + RepetirCaractere('=', 100) + sLineBreak;
  Result := Result + Format('Período: %s a %s', 
    [FormatDateTime('dd/mm/yyyy', FDataInicio), FormatDateTime('dd/mm/yyyy', FDataFim)]) + sLineBreak;
  Result := Result + sLineBreak;
  
  Caixas := ObterCaixasPeriodo;
  OperadorVendas := TDictionary<string, Double>.Create;
  OperadorQuantidade := TDictionary<string, Integer>.Create;
  
  try
    // Agrupa dados por operador
    for i := 0 to Caixas.Count - 1 do
    begin
      Chave := Caixas[i].Operador.Nome;
      
      if OperadorVendas.ContainsKey(Chave) then
      begin
        OperadorVendas[Chave] := OperadorVendas[Chave] + Caixas[i].TotalVendas;
        OperadorQuantidade[Chave] := OperadorQuantidade[Chave] + Caixas[i].QuantidadeVendas;
      end
      else
      begin
        OperadorVendas.Add(Chave, Caixas[i].TotalVendas);
        OperadorQuantidade.Add(Chave, Caixas[i].QuantidadeVendas);
      end;
    end;
    
    // Exibe relatório
    Result := Result + FormatarLinha('OPERADOR', 30) + 
      FormatarLinha('TOTAL VENDAS', 25) + 
      FormatarLinha('QUANTIDADE', 20) + 
      FormatarLinha('MÉDIA/VENDA', 20) + sLineBreak;
    Result := Result + RepetirCaractere('-', 100) + sLineBreak;
    
    for Chave in OperadorVendas.Keys do
    begin
      Valor := OperadorVendas[Chave];
      Quantidade := OperadorQuantidade[Chave];
      Result := Result + FormatarLinha(Chave, 30) + 
        Format('R$ %15.2f', [Valor]) + 
        Format('%10d', [Quantidade]) + 
        Format('R$ %10.2f', [Valor / Quantidade]) + sLineBreak;
    end;
    
    Result := Result + RepetirCaractere('-', 100) + sLineBreak;
  finally
    OperadorVendas.Free;
    OperadorQuantidade.Free;
    Caixas.Free;
  end;
end;

function TRelatórioGerencial.RelatórioDetalhado: string;
var
  Caixas: TObjectList<TCaixa>;
  i, j: Integer;
  Venda: TVenda;
begin
  Result := '';
  Result := Result + RepetirCaractere('=', 100) + sLineBreak;
  Result := Result + CentralizarTexto('RELATÓRIO DETALHADO DE VENDAS', 100) + sLineBreak;
  Result := Result + RepetirCaractere('=', 100) + sLineBreak;
  Result := Result + Format('Período: %s a %s', 
    [FormatDateTime('dd/mm/yyyy', FDataInicio), FormatDateTime('dd/mm/yyyy', FDataFim)]) + sLineBreak;
  Result := Result + sLineBreak;
  
  Caixas := ObterCaixasPeriodo;
  try
    for i := 0 to Caixas.Count - 1 do
    begin
      Result := Result + Format('CAIXA %d - %s', [Caixas[i].ID, Caixas[i].Operador.Nome]) + sLineBreak;
      Result := Result + Format('Abertura: %s | Fechamento: %s', 
        [FormatDateTime('dd/mm/yyyy hh:mm:ss', Caixas[i].DataAbertura),
         FormatDateTime('dd/mm/yyyy hh:mm:ss', Caixas[i].DataFechamento)]) + sLineBreak;
      Result := Result + RepetirCaractere('-', 100) + sLineBreak;
      
      for j := 0 to Caixas[i].Vendas.Count - 1 do
      begin
        Venda := Caixas[i].Vendas[j];
        Result := Result + Format('  Venda %d: R$ %.2f (%d itens) - %s', 
          [j + 1, Venda.Total, Venda.QuantidadeItens, 
           FormatDateTime('hh:mm:ss', Venda.DataVenda)]) + sLineBreak;
      end;
      
      Result := Result + sLineBreak;
    end;
  finally
    Caixas.Free;
  end;
end;

function TRelatórioGerencial.RelatórioResumoExecutivo: string;
begin
  Result := '';
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + CentralizarTexto('RESUMO EXECUTIVO', 80) + sLineBreak;
  Result := Result + RepetirCaractere('=', 80) + sLineBreak;
  Result := Result + Format('Período: %s a %s', 
    [FormatDateTime('dd/mm/yyyy', FDataInicio), FormatDateTime('dd/mm/yyyy', FDataFim)]) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + 'INDICADORES PRINCIPAIS:' + sLineBreak;
  Result := Result + RepetirCaractere('-', 80) + sLineBreak;
  Result := Result + Format('Total de Vendas: R$ %.2f', [ObterTotalVendasPeriodo]) + sLineBreak;
  Result := Result + Format('Quantidade de Vendas: %d', [ObterQuantidadeVendasPeriodo]) + sLineBreak;
  Result := Result + Format('Valor Médio por Venda: R$ %.2f', [ObterValorMedioVendaPeriodo]) + sLineBreak;
  Result := Result + Format('Total de Caixas: %d', [FRepositorioCaixa.BuscarPorDataIntervalo(FDataInicio, FDataFim).Count]) + sLineBreak;
end;

end.
