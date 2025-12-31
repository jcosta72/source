unit uRelatorios;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uRepositorioCaixa, uCaixa, uVenda, uOperador;

type
  { Classe para geração de relatórios }
  TRelatorios = class
  private
    FRepositorioCaixa: TRepositorioCaixa;
    FUltimoErro: string;
    
    function FormatarCabecalho: string;
    function FormatarRodape: string;
    function FormatarLinha(ATexto: string; ALargura: Integer = 80): string;
  public
    constructor Create(ARepositorioCaixa: TRepositorioCaixa);
    destructor Destroy; override;
    
    { ========== RELATÓRIOS DE CAIXA ========== }
    
    { Gerar relatório de fechamento de caixa }
    function GerarRelatórioFechamentoCaixa(ACaixa: TCaixa): string;
    
    { Gerar relatório de movimentações }
    function GerarRelatórioMovimentacoes(ACaixa: TCaixa): string;
    
    { Gerar relatório de vendas por forma de pagamento }
    function GerarRelatórioVendasPorFormaPagamento(ACaixa: TCaixa): string;
    
    { Gerar relatório de vendas por operador }
    function GerarRelatórioVendasPorOperador(ADataInicio: TDateTime; ADataFim: TDateTime): string;
    
    { Gerar relatório de resumo geral }
    function GerarRelatórioResumoGeral(ADataInicio: TDateTime; ADataFim: TDateTime): string;
    
    { Gerar relatório de desempenho }
    function GerarRelatórioDesempenho(ADataInicio: TDateTime; ADataFim: TDateTime): string;
    
    { Gerar relatório de produtos mais vendidos }
    function GerarRelatórioProdutosMaisVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): string;
    
    { Gerar relatório de produtos menos vendidos }
    function GerarRelatórioProdutosMenosVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): string;
    
    { ========== RELATÓRIOS DE COMPARAÇÃO ========== }
    
    { Comparar dois períodos }
    function GerarRelatórioComparativoPeríodos(ADataInicio1: TDateTime; ADataFim1: TDateTime;
                                               ADataInicio2: TDateTime; ADataFim2: TDateTime): string;
    
    { ========== PROPRIEDADES ========== }
    
    property UltimoErro: string read FUltimoErro;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TRelatorios.Create(ARepositorioCaixa: TRepositorioCaixa);
begin
  inherited Create;
  FRepositorioCaixa := ARepositorioCaixa;
  FUltimoErro := '';
end;

destructor TRelatorios.Destroy;
begin
  inherited;
end;

{ ============================================================================
  MÉTODOS AUXILIARES
  ============================================================================ }

function TRelatorios.FormatarCabecalho: string;
begin
  Result :=
    '╔════════════════════════════════════════════════════════════════════════════════╗' + sLineBreak +
    '║                    PDV SEENAXON - RELATÓRIO DE CAIXA                          ║' + sLineBreak +
    '╚════════════════════════════════════════════════════════════════════════════════╝' + sLineBreak +
    sLineBreak;
end;

function TRelatorios.FormatarRodape: string;
begin
  Result :=
    sLineBreak +
    '╔════════════════════════════════════════════════════════════════════════════════╗' + sLineBreak +
    '║ Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', Now) + ' ' +
    StringOfChar(' ', 50) + '║' + sLineBreak +
    '╚════════════════════════════════════════════════════════════════════════════════╝';
end;

function TRelatorios.FormatarLinha(ATexto: string; ALargura: Integer = 80): string;
var
  Espacos: Integer;
begin
  Espacos := ALargura - Length(ATexto);
  if Espacos < 0 then
    Espacos := 0;
  
  Result := ATexto + StringOfChar(' ', Espacos);
end;

{ ============================================================================
  RELATÓRIOS DE CAIXA
  ============================================================================ }

function TRelatorios.GerarRelatórioFechamentoCaixa(ACaixa: TCaixa): string;
var
  Relatorio: string;
  i: Integer;
begin
  Relatorio := FormatarCabecalho;
  
  try
    { Cabeçalho do caixa }
    Relatorio := Relatorio +
      '═ INFORMAÇÕES DO CAIXA ═' + sLineBreak +
      'ID do Caixa: ' + IntToStr(ACaixa.ID) + sLineBreak +
      'Operador: ' + ACaixa.Operador.Nome + sLineBreak +
      'Data de Abertura: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', ACaixa.DataAbertura) + sLineBreak +
      'Data de Fechamento: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', ACaixa.DataFechamento) + sLineBreak +
      'Status: ' + ACaixa.StatusNome + sLineBreak +
      sLineBreak;
    
    { Saldos }
    Relatorio := Relatorio +
      '═ SALDOS ═' + sLineBreak +
      'Saldo Inicial: R$ ' + FormatFloat('0.00', ACaixa.SaldoInicial) + sLineBreak +
      'Saldo Final: R$ ' + FormatFloat('0.00', ACaixa.SaldoFinal) + sLineBreak +
      'Diferença: R$ ' + FormatFloat('0.00', ACaixa.Diferenca) + sLineBreak +
      sLineBreak;
    
    { Totalizadores }
    Relatorio := Relatorio +
      '═ TOTALIZADORES ═' + sLineBreak +
      'Total de Vendas: R$ ' + FormatFloat('0.00', ACaixa.TotalVendas) + sLineBreak +
      'Total de Descontos: R$ ' + FormatFloat('0.00', ACaixa.TotalDesconto) + sLineBreak +
      'Total de Acréscimos: R$ ' + FormatFloat('0.00', ACaixa.TotalAcrescimo) + sLineBreak +
      'Total de Sangrias: R$ ' + FormatFloat('0.00', ACaixa.TotalSangria) + sLineBreak +
      'Total de Suprimentos: R$ ' + FormatFloat('0.00', ACaixa.TotalSuprimento) + sLineBreak +
      sLineBreak;
    
    { Formas de pagamento }
    Relatorio := Relatorio +
      '═ FORMAS DE PAGAMENTO ═' + sLineBreak +
      'Dinheiro: R$ ' + FormatFloat('0.00', ACaixa.TotalDinheiro) + sLineBreak +
      'Cartão: R$ ' + FormatFloat('0.00', ACaixa.TotalCartao) + sLineBreak +
      'PIX: R$ ' + FormatFloat('0.00', ACaixa.TotalPIX) + sLineBreak +
      sLineBreak;
    
    { Estatísticas }
    Relatorio := Relatorio +
      '═ ESTATÍSTICAS ═' + sLineBreak +
      'Quantidade de Vendas: ' + IntToStr(ACaixa.QuantidadeVendas) + sLineBreak +
      'Quantidade de Produtos: ' + IntToStr(ACaixa.QuantidadeProdutos) + sLineBreak +
      'Valor Médio da Venda: R$ ' + FormatFloat('0.00', ACaixa.ValorMedioVenda) + sLineBreak +
      'Maior Venda: R$ ' + FormatFloat('0.00', ACaixa.MaiorVenda) + sLineBreak +
      'Menor Venda: R$ ' + FormatFloat('0.00', ACaixa.MenorVenda) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de fechamento: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioMovimentacoes(ACaixa: TCaixa): string;
var
  Relatorio: string;
  Movimentacoes: TObjectList<TMovimentacao>;
  i: Integer;
  Mov: TMovimentacao;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'ID do Caixa: ' + IntToStr(ACaixa.ID) + sLineBreak +
      'Operador: ' + ACaixa.Operador.Nome + sLineBreak +
      'Data: ' + FormatDateTime('dd/mm/yyyy', ACaixa.DataAbertura) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ MOVIMENTAÇÕES ═' + sLineBreak +
      '┌─────────────────────────────────────────────────────────────────────┐' + sLineBreak +
      '│ Tipo         │ Valor         │ Motivo                │ Data/Hora    │' + sLineBreak +
      '├─────────────────────────────────────────────────────────────────────┤' + sLineBreak;
    
    { Listar movimentações }
    Movimentacoes := ACaixa.ObterMovimentacoes;
    
    if Assigned(Movimentacoes) then
    begin
      for i := 0 to Movimentacoes.Count - 1 do
      begin
        Mov := Movimentacoes[i];
        
        Relatorio := Relatorio + Format(
          '│ %-11s │ R$ %9.2f │ %-20s │ %12s │' + sLineBreak,
          [
            Mov.TipoNome,
            Mov.Valor,
            Copy(Mov.Motivo, 1, 20),
            FormatDateTime('hh:mm:ss', Mov.Data)
          ]
        );
      end;
      
      Movimentacoes.Free;
    end;
    
    Relatorio := Relatorio +
      '└─────────────────────────────────────────────────────────────────────┘' + sLineBreak +
      sLineBreak;
    
    { Resumo de movimentações }
    Relatorio := Relatorio +
      '═ RESUMO ═' + sLineBreak +
      'Total de Sangrias: R$ ' + FormatFloat('0.00', ACaixa.TotalSangria) + sLineBreak +
      'Total de Suprimentos: R$ ' + FormatFloat('0.00', ACaixa.TotalSuprimento) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de movimentações: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioVendasPorFormaPagamento(ACaixa: TCaixa): string;
var
  Relatorio: string;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'ID do Caixa: ' + IntToStr(ACaixa.ID) + sLineBreak +
      'Operador: ' + ACaixa.Operador.Nome + sLineBreak +
      'Data: ' + FormatDateTime('dd/mm/yyyy', ACaixa.DataAbertura) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ VENDAS POR FORMA DE PAGAMENTO ═' + sLineBreak +
      '┌─────────────────────────────────────────────┐' + sLineBreak +
      '│ Forma de Pagamento   │ Valor               │' + sLineBreak +
      '├─────────────────────────────────────────────┤' + sLineBreak +
      Format('│ %-20s │ R$ %15.2f │' + sLineBreak, ['Dinheiro', ACaixa.TotalDinheiro]) +
      Format('│ %-20s │ R$ %15.2f │' + sLineBreak, ['Cartão', ACaixa.TotalCartao]) +
      Format('│ %-20s │ R$ %15.2f │' + sLineBreak, ['PIX', ACaixa.TotalPIX]) +
      '├─────────────────────────────────────────────┤' + sLineBreak +
      Format('│ %-20s │ R$ %15.2f │' + sLineBreak, ['TOTAL', ACaixa.TotalVendas]) +
      '└─────────────────────────────────────────────┘' + sLineBreak +
      sLineBreak;
    
    { Percentuais }
    Relatorio := Relatorio +
      '═ PERCENTUAIS ═' + sLineBreak;
    
    if ACaixa.TotalVendas > 0 then
    begin
      Relatorio := Relatorio +
        'Dinheiro: ' + FormatFloat('0.00', (ACaixa.TotalDinheiro / ACaixa.TotalVendas) * 100) + '%' + sLineBreak +
        'Cartão: ' + FormatFloat('0.00', (ACaixa.TotalCartao / ACaixa.TotalVendas) * 100) + '%' + sLineBreak +
        'PIX: ' + FormatFloat('0.00', (ACaixa.TotalPIX / ACaixa.TotalVendas) * 100) + '%' + sLineBreak;
    end;
    
    Relatorio := Relatorio + sLineBreak + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de vendas por forma de pagamento: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioVendasPorOperador(ADataInicio: TDateTime; ADataFim: TDateTime): string;
var
  Relatorio: string;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'Período: ' + FormatDateTime('dd/mm/yyyy', ADataInicio) + ' a ' + FormatDateTime('dd/mm/yyyy', ADataFim) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ VENDAS POR OPERADOR ═' + sLineBreak +
      '┌──────────────────────────────────────────────────────────┐' + sLineBreak +
      '│ Operador             │ Qtd Vendas │ Total                │' + sLineBreak +
      '├──────────────────────────────────────────────────────────┤' + sLineBreak;
    
    { Aqui seria preenchido com dados do repositório }
    
    Relatorio := Relatorio +
      '└──────────────────────────────────────────────────────────┘' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de vendas por operador: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioResumoGeral(ADataInicio: TDateTime; ADataFim: TDateTime): string;
var
  Relatorio: string;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'Período: ' + FormatDateTime('dd/mm/yyyy', ADataInicio) + ' a ' + FormatDateTime('dd/mm/yyyy', ADataFim) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ RESUMO GERAL ═' + sLineBreak +
      'Total de Caixas Fechados: ' + sLineBreak +
      'Total de Vendas: ' + sLineBreak +
      'Total de Produtos Vendidos: ' + sLineBreak +
      'Valor Total de Vendas: ' + sLineBreak +
      'Valor Total de Descontos: ' + sLineBreak +
      'Valor Total de Acréscimos: ' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de resumo geral: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioDesempenho(ADataInicio: TDateTime; ADataFim: TDateTime): string;
var
  Relatorio: string;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'Período: ' + FormatDateTime('dd/mm/yyyy', ADataInicio) + ' a ' + FormatDateTime('dd/mm/yyyy', ADataFim) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ DESEMPENHO ═' + sLineBreak +
      'Ticket Médio: ' + sLineBreak +
      'Venda Máxima: ' + sLineBreak +
      'Venda Mínima: ' + sLineBreak +
      'Operador com Melhor Desempenho: ' + sLineBreak +
      'Produto Mais Vendido: ' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de desempenho: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioProdutosMaisVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): string;
var
  Relatorio: string;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'Período: ' + FormatDateTime('dd/mm/yyyy', ADataInicio) + ' a ' + FormatDateTime('dd/mm/yyyy', ADataFim) + sLineBreak +
      'Top ' + IntToStr(ATop) + ' Produtos' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ PRODUTOS MAIS VENDIDOS ═' + sLineBreak +
      '┌──────────────────────────────────────────────────────────┐' + sLineBreak +
      '│ Posição │ Produto              │ Qtd │ Total             │' + sLineBreak +
      '├──────────────────────────────────────────────────────────┤' + sLineBreak;
    
    { Aqui seria preenchido com dados do repositório }
    
    Relatorio := Relatorio +
      '└──────────────────────────────────────────────────────────┘' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de produtos mais vendidos: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioProdutosMenosVendidos(ADataInicio: TDateTime; ADataFim: TDateTime; ATop: Integer = 10): string;
var
  Relatorio: string;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'Período: ' + FormatDateTime('dd/mm/yyyy', ADataInicio) + ' a ' + FormatDateTime('dd/mm/yyyy', ADataFim) + sLineBreak +
      'Top ' + IntToStr(ATop) + ' Produtos' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ PRODUTOS MENOS VENDIDOS ═' + sLineBreak +
      '┌──────────────────────────────────────────────────────────┐' + sLineBreak +
      '│ Posição │ Produto              │ Qtd │ Total             │' + sLineBreak +
      '├──────────────────────────────────────────────────────────┤' + sLineBreak;
    
    { Aqui seria preenchido com dados do repositório }
    
    Relatorio := Relatorio +
      '└──────────────────────────────────────────────────────────┘' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório de produtos menos vendidos: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TRelatorios.GerarRelatórioComparativoPeríodos(ADataInicio1: TDateTime; ADataFim1: TDateTime;
                                                      ADataInicio2: TDateTime; ADataFim2: TDateTime): string;
var
  Relatorio: string;
begin
  Relatorio := FormatarCabecalho;
  
  try
    Relatorio := Relatorio +
      'Período 1: ' + FormatDateTime('dd/mm/yyyy', ADataInicio1) + ' a ' + FormatDateTime('dd/mm/yyyy', ADataFim1) + sLineBreak +
      'Período 2: ' + FormatDateTime('dd/mm/yyyy', ADataInicio2) + ' a ' + FormatDateTime('dd/mm/yyyy', ADataFim2) + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio +
      '═ COMPARATIVO DE PERÍODOS ═' + sLineBreak +
      '┌────────────────────────────────────────────────────────────────────┐' + sLineBreak +
      '│ Métrica                  │ Período 1    │ Período 2    │ Variação │' + sLineBreak +
      '├────────────────────────────────────────────────────────────────────┤' + sLineBreak;
    
    { Aqui seria preenchido com dados do repositório }
    
    Relatorio := Relatorio +
      '└────────────────────────────────────────────────────────────────────┘' + sLineBreak +
      sLineBreak;
    
    Relatorio := Relatorio + FormatarRodape;
    
    Result := Relatorio;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao gerar relatório comparativo: ' + E.Message;
      Result := '';
    end;
  end;
end;

end.
