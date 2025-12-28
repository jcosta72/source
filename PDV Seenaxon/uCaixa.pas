unit uCaixa;

interface

uses
  System.SysUtils, System.Generics.Collections,
  uVenda, uOperador;

type
  TStatusCaixa = (scFechado, scAberto, scFechando);

  TCaixa = class
  private
    FID: Integer;
    FOperador: TOperador;
    FVendas: TObjectList<TVenda>;
    FStatus: TStatusCaixa;
    FDataAbertura: TDateTime;
    FDataFechamento: TDateTime;
    FSaldoInicial: Double;
    FSaldoFinal: Double;
    FTotalVendas: Double;
    FTotalDesconto: Double;
    FTotalAcrescimo: Double;
    FQuantidadeVendas: Integer;
    FQuantidadeProdutos: Integer;
    FValorMedioVenda: Double;
    FMaiorVenda: Double;
    FMenorVenda: Double;
    FTotalDinheiro: Double;
    FTotalCartao: Double;
    FTotalPIX: Double;
    FDiferenca: Double;
    
    procedure CalcularTotalizadores;
    procedure ValidarCaixa;
  public
    constructor Create(AID: Integer; AOperador: TOperador; ASaldoInicial: Double = 0);
    destructor Destroy; override;
    
    // Operações de caixa
    procedure Abrir(ASaldoInicial: Double = 0);
    procedure Fechar;
    procedure Cancelar;
    
    // Operações com vendas
    procedure AdicionarVenda(AVenda: TVenda);
    procedure RemoverVenda(AIndex: Integer);
    
    // Consultas
    function GetVenda(AIndex: Integer): TVenda;
    function ObterVendasPorData(AData: TDateTime): TObjectList<TVenda>;
    function ObterVendasPorFormaPagamento(AForma: Integer): TObjectList<TVenda>;
    function ObterResumoVendas: string;
    function ObterDetalhesVendas: string;
    
    // Validações
    function PodeFechar: Boolean;
    function EstaAberto: Boolean;
    function EstaFechado: Boolean;
    
    // Propriedades
    property ID: Integer read FID write FID;
    property Operador: TOperador read FOperador;
    property Vendas: TObjectList<TVenda> read FVendas;
    property Status: TStatusCaixa read FStatus;
    property DataAbertura: TDateTime read FDataAbertura;
    property DataFechamento: TDateTime read FDataFechamento;
    property SaldoInicial: Double read FSaldoInicial;
    property SaldoFinal: Double read FSaldoFinal;
    property TotalVendas: Double read FTotalVendas;
    property TotalDesconto: Double read FTotalDesconto;
    property TotalAcrescimo: Double read FTotalAcrescimo;
    property QuantidadeVendas: Integer read FQuantidadeVendas;
    property QuantidadeProdutos: Integer read FQuantidadeProdutos;
    property ValorMedioVenda: Double read FValorMedioVenda;
    property MaiorVenda: Double read FMaiorVenda;
    property MenorVenda: Double read FMenorVenda;
    property TotalDinheiro: Double read FTotalDinheiro;
    property TotalCartao: Double read FTotalCartao;
    property TotalPIX: Double read FTotalPIX;
    property Diferenca: Double read FDiferenca;
    property Aberto: Boolean read EstaAberto;
  end;

implementation

constructor TCaixa.Create(AID: Integer; AOperador: TOperador; ASaldoInicial: Double = 0);
begin
  inherited Create;
  FID := AID;
  FOperador := AOperador;
  FVendas := TObjectList<TVenda>.Create;
  FStatus := scFechado;
  FSaldoInicial := ASaldoInicial;
  FSaldoFinal := 0;
  FTotalVendas := 0;
  FTotalDesconto := 0;
  FTotalAcrescimo := 0;
  FQuantidadeVendas := 0;
  FQuantidadeProdutos := 0;
  FValorMedioVenda := 0;
  FMaiorVenda := 0;
  FMenorVenda := 0;
  FTotalDinheiro := 0;
  FTotalCartao := 0;
  FTotalPIX := 0;
  FDiferenca := 0;
end;

destructor TCaixa.Destroy;
begin
  if Assigned(FVendas) then
    FVendas.Free;
  inherited;
end;

procedure TCaixa.ValidarCaixa;
begin
  if FStatus <> scAberto then
    raise Exception.Create('Caixa não está aberto');
end;

procedure TCaixa.CalcularTotalizadores;
var
  i: Integer;
  Venda: TVenda;
  MenorValor: Double;
begin
  FTotalVendas := 0;
  FTotalDesconto := 0;
  FTotalAcrescimo := 0;
  FQuantidadeVendas := 0;
  FQuantidadeProdutos := 0;
  FValorMedioVenda := 0;
  FMaiorVenda := 0;
  FMenorVenda := 999999;
  FTotalDinheiro := 0;
  FTotalCartao := 0;
  FTotalPIX := 0;
  
  for i := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[i];
    
    if Venda.Status = svFinalizada then
    begin
      // Totalizadores gerais
      FTotalVendas := FTotalVendas + Venda.Total;
      FTotalDesconto := FTotalDesconto + Venda.Desconto;
      FTotalAcrescimo := FTotalAcrescimo + Venda.Acrescimo;
      FQuantidadeVendas := FQuantidadeVendas + 1;
      FQuantidadeProdutos := FQuantidadeProdutos + Venda.GetQuantidadeProdutos;
      
      // Maior e menor venda
      if Venda.Total > FMaiorVenda then
        FMaiorVenda := Venda.Total;
      
      if Venda.Total < FMenorVenda then
        FMenorVenda := Venda.Total;
      
      // Totalizadores por forma de pagamento
      case Venda.FormaPagamento of
        fpDinheiro: FTotalDinheiro := FTotalDinheiro + Venda.Total;
        fpCartao: FTotalCartao := FTotalCartao + Venda.Total;
        fpPIX: FTotalPIX := FTotalPIX + Venda.Total;
      end;
    end;
  end;
  
  // Calcula valor médio
  if FQuantidadeVendas > 0 then
    FValorMedioVenda := FTotalVendas / FQuantidadeVendas
  else
    FValorMedioVenda := 0;
  
  // Se não houve vendas, menor venda é 0
  if FMenorVenda = 999999 then
    FMenorVenda := 0;
  
  // Calcula saldo final e diferença
  FSaldoFinal := FSaldoInicial + FTotalVendas;
  FDiferenca := 0; // Será calculado no fechamento
end;

procedure TCaixa.Abrir(ASaldoInicial: Double = 0);
begin
  if FStatus = scAberto then
    raise Exception.Create('Caixa já está aberto');
  
  FStatus := scAberto;
  FDataAbertura := Now;
  FDataFechamento := 0;
  FSaldoInicial := ASaldoInicial;
  FSaldoFinal := 0;
  FVendas.Clear;
  FTotalVendas := 0;
  FTotalDesconto := 0;
  FTotalAcrescimo := 0;
  FQuantidadeVendas := 0;
  FQuantidadeProdutos := 0;
  FValorMedioVenda := 0;
  FMaiorVenda := 0;
  FMenorVenda := 0;
  FTotalDinheiro := 0;
  FTotalCartao := 0;
  FTotalPIX := 0;
  FDiferenca := 0;
end;

procedure TCaixa.Fechar;
begin
  ValidarCaixa;
  
  FStatus := scFechando;
  
  // Calcula totalizadores finais
  CalcularTotalizadores;
  
  // Calcula diferença
  FDiferenca := FSaldoFinal - FSaldoInicial - FTotalVendas;
  
  FStatus := scFechado;
  FDataFechamento := Now;
end;

procedure TCaixa.Cancelar;
begin
  if FStatus <> scAberto then
    raise Exception.Create('Só é possível cancelar um caixa aberto');
  
  FStatus := scFechado;
  FDataFechamento := Now;
  FVendas.Clear;
end;

procedure TCaixa.AdicionarVenda(AVenda: TVenda);
begin
  ValidarCaixa;
  
  if not Assigned(AVenda) then
    raise Exception.Create('Venda inválida');
  
  if AVenda.Status <> svFinalizada then
    raise Exception.Create('Venda não foi finalizada');
  
  FVendas.Add(AVenda);
  CalcularTotalizadores;
end;

procedure TCaixa.RemoverVenda(AIndex: Integer);
begin
  ValidarCaixa;
  
  if (AIndex >= 0) and (AIndex < FVendas.Count) then
  begin
    FVendas.Delete(AIndex);
    CalcularTotalizadores;
  end;
end;

function TCaixa.GetVenda(AIndex: Integer): TVenda;
begin
  if (AIndex >= 0) and (AIndex < FVendas.Count) then
    Result := FVendas[AIndex]
  else
    Result := nil;
end;

function TCaixa.ObterVendasPorData(AData: TDateTime): TObjectList<TVenda>;
var
  i: Integer;
  Lista: TObjectList<TVenda>;
begin
  Lista := TObjectList<TVenda>.Create(False);
  
  for i := 0 to FVendas.Count - 1 do
  begin
    if Trunc(FVendas[i].DataVenda) = Trunc(AData) then
      Lista.Add(FVendas[i]);
  end;
  
  Result := Lista;
end;

function TCaixa.ObterVendasPorFormaPagamento(AForma: Integer): TObjectList<TVenda>;
var
  i: Integer;
  Lista: TObjectList<TVenda>;
begin
  Lista := TObjectList<TVenda>.Create(False);
  
  for i := 0 to FVendas.Count - 1 do
  begin
    if Ord(FVendas[i].FormaPagamento) = AForma then
      Lista.Add(FVendas[i]);
  end;
  
  Result := Lista;
end;

function TCaixa.ObterResumoVendas: string;
begin
  Result := '';
  Result := Result + 'RESUMO DO CAIXA' + sLineBreak + sLineBreak;
  Result := Result + Format('Data Abertura: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', FDataAbertura)]) + sLineBreak;
  
  if FStatus = scFechado then
    Result := Result + Format('Data Fechamento: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', FDataFechamento)]) + sLineBreak
  else
    Result := Result + 'Status: ABERTO' + sLineBreak;
  
  Result := Result + sLineBreak;
  Result := Result + Format('Saldo Inicial: R$ %.2f', [FSaldoInicial]) + sLineBreak;
  Result := Result + Format('Total Vendas: R$ %.2f', [FTotalVendas]) + sLineBreak;
  Result := Result + Format('Saldo Final: R$ %.2f', [FSaldoFinal]) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + Format('Quantidade Vendas: %d', [FQuantidadeVendas]) + sLineBreak;
  Result := Result + Format('Quantidade Produtos: %d', [FQuantidadeProdutos]) + sLineBreak;
  Result := Result + Format('Valor Médio Venda: R$ %.2f', [FValorMedioVenda]) + sLineBreak;
  Result := Result + Format('Maior Venda: R$ %.2f', [FMaiorVenda]) + sLineBreak;
  Result := Result + Format('Menor Venda: R$ %.2f', [FMenorVenda]) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + Format('Total Desconto: R$ %.2f', [FTotalDesconto]) + sLineBreak;
  Result := Result + Format('Total Acréscimo: R$ %.2f', [FTotalAcrescimo]) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + Format('Dinheiro: R$ %.2f', [FTotalDinheiro]) + sLineBreak;
  Result := Result + Format('Cartão: R$ %.2f', [FTotalCartao]) + sLineBreak;
  Result := Result + Format('PIX: R$ %.2f', [FTotalPIX]) + sLineBreak;
end;

function TCaixa.ObterDetalhesVendas: string;
var
  i: Integer;
  Venda: TVenda;
begin
  Result := '';
  Result := Result + 'DETALHES DAS VENDAS' + sLineBreak + sLineBreak;
  
  for i := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[i];
    Result := Result + Format('Venda %d:', [i + 1]) + sLineBreak;
    Result := Result + Format('  Data: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', Venda.DataVenda)]) + sLineBreak;
    Result := Result + Format('  Itens: %d', [Venda.QuantidadeItens]) + sLineBreak;
    Result := Result + Format('  Subtotal: R$ %.2f', [Venda.Subtotal]) + sLineBreak;
    
    if Venda.Desconto > 0 then
      Result := Result + Format('  Desconto: R$ %.2f', [Venda.Desconto]) + sLineBreak;
    
    if Venda.Acrescimo > 0 then
      Result := Result + Format('  Acréscimo: R$ %.2f', [Venda.Acrescimo]) + sLineBreak;
    
    Result := Result + Format('  Total: R$ %.2f', [Venda.Total]) + sLineBreak;
    
    case Venda.FormaPagamento of
      fpDinheiro: Result := Result + '  Pagamento: DINHEIRO' + sLineBreak;
      fpCartao: Result := Result + '  Pagamento: CARTÃO' + sLineBreak;
      fpPIX: Result := Result + '  Pagamento: PIX' + sLineBreak;
    end;
    
    Result := Result + sLineBreak;
  end;
end;

function TCaixa.PodeFechar: Boolean;
begin
  Result := (FStatus = scAberto) and (FQuantidadeVendas > 0);
end;

function TCaixa.EstaAberto: Boolean;
begin
  Result := FStatus = scAberto;
end;

function TCaixa.EstaFechado: Boolean;
begin
  Result := FStatus = scFechado;
end;

end.
