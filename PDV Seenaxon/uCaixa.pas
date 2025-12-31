unit uCaixa;

interface

uses
  System.SysUtils, System.Generics.Collections, System.DateUtils,
  uVenda, uOperador, System.TypInfo;

type
  { Enumeração para status do caixa }
  TStatusCaixa = (scFechado, scAberto, scFechando);

  { Enumeração para tipo de movimentação }
  TTipoMovimentacao = (tmSangria, tmSuprimento);

  { Classe para registrar movimentações (sangria/suprimento) }
  TMovimentacao = class
  private
    FID: Integer;
    FTipo: TTipoMovimentacao;
    FTipoNome: string;
    FValor: Double;
    FData: TDateTime;
    FMotivo: string;
    FOperador: string;
    procedure SetTipo(const Value: TTipoMovimentacao);
  public
    constructor Create(AID: Integer; ATipo: TTipoMovimentacao; AValor: Double; 
      AMotivo, AOperador: string);
    
    property ID: Integer read FID write FID;
    property Tipo: TTipoMovimentacao read FTipo write SetTipo;
    property TipoNome: string read FTipoNome;
    property Valor: Double read FValor;
    property Data: TDateTime read FData write FData;
    property Motivo: string read FMotivo;
    property Operador: string read FOperador;
    
    function GetTipoAsString: string;
  end;

  { Classe principal do caixa }
  TCaixa = class
  private
    FID: Integer;
    FOperador: TOperador;
    FVendas: TObjectList<TVenda>;
    FMovimentacoes: TObjectList<TMovimentacao>;
    FStatus: TStatusCaixa;
    FStatusNome: string;
    FDataAbertura: TDateTime;
    FDataFechamento: TDateTime;
    FSaldoInicial: Double;
    FSaldoFinal: Double;
    FTotalVendas: Double;
    FTotalDesconto: Double;
    FTotalAcrescimo: Double;
    FTotalSangria: Double;
    FTotalSuprimento: Double;
    FQuantidadeVendas: Integer;
    FQuantidadeProdutos: Integer;
    FValorMedioVenda: Double;
    FMaiorVenda: Double;
    FMenorVenda: Double;
    FTotalDinheiro: Double;
    FTotalCartao: Double;
    FTotalPIX: Double;
    FDiferenca: Double;
    FProximoIDMovimentacao: Integer;
    FTeste: string;

    procedure CalcularTotalizadores;
    procedure ValidarCaixa;
    function CalcularSaldoFinal: Double;
    procedure SetStatus(const Value: TStatusCaixa);
  public
    constructor Create(AID: Integer; AOperador: TOperador; ASaldoInicial: Double = 0);
    destructor Destroy; override;

    { ========== OPERAÇÕES DE CAIXA ========== }

    { Abertura do caixa }
    procedure Abrir(ASaldoInicial: Double = 0);
    
    { Fechamento do caixa }
    procedure Fechar;
    
    { Cancelamento do caixa }
    procedure Cancelar;
    
    { ========== OPERAÇÕES COM VENDAS ========== }
    
    { Adicionar venda ao caixa }
    procedure AdicionarVenda(AVenda: TVenda);
    
    { Remover venda do caixa }
    procedure RemoverVenda(AIndex: Integer);
    
    { ========== MOVIMENTAÇÕES (SANGRIA/SUPRIMENTO) ========== }
    
    { Realizar sangria (retirada de dinheiro) }
    function RealizarSangria(AValor: Double; AMotivo: string = ''): Boolean;
    
    { Realizar suprimento (adição de dinheiro) }
    function RealizarSuprimento(AValor: Double; AMotivo: string = ''): Boolean;
    
    { Obter lista de movimentações }
    function ObterMovimentacoes: TObjectList<TMovimentacao>;
    function ObterMovimentacoesPorTipo(ATipo: TTipoMovimentacao): TObjectList<TMovimentacao>;
    
    { ========== CONSULTAS ========== }
    
    { Obter venda por índice }
    function GetVenda(AIndex: Integer): TVenda;
    
    { Obter vendas por data }
    function ObterVendasPorData(AData: TDateTime): TObjectList<TVenda>;
    
    { Obter vendas por forma de pagamento }
    function ObterVendasPorFormaPagamento(AForma: Integer): TObjectList<TVenda>;
    
    { Obter resumo de vendas }
    function ObterResumoVendas: string;
    
    { Obter detalhes de vendas }
    function ObterDetalhesVendas: string;
    
    { Obter resumo de movimentações }
    function ObterResumoMovimentacoes: string;
    
    { Obter resumo completo do caixa }
    function ObterResumoCaixa: string;
    
    { ========== VALIDAÇÕES ========== }
    
    { Verificar se pode fechar }
    function PodeFechar: Boolean;
    
    { Verificar se está aberto }
    function EstaAberto: Boolean;
    
    { Verificar se está fechado }
    function EstaFechado: Boolean;
    
    { ========== PROPRIEDADES ========== }
    
    property ID: Integer read FID write FID;
    property Operador: TOperador read FOperador;
    property Vendas: TObjectList<TVenda> read FVendas;
    property Movimentacoes: TObjectList<TMovimentacao> read FMovimentacoes;
    property Status: TStatusCaixa read FStatus write SetStatus;
    property StatusNome: string read FStatusNome;
    property DataAbertura: TDateTime read FDataAbertura write FDataAbertura;
    property DataFechamento: TDateTime read FDataFechamento write FDataFechamento;
    property SaldoInicial: Double read FSaldoInicial;
    property SaldoFinal: Double read FSaldoFinal;
    property TotalVendas: Double read FTotalVendas;
    property TotalDesconto: Double read FTotalDesconto;
    property TotalAcrescimo: Double read FTotalAcrescimo;
    property TotalSangria: Double read FTotalSangria;
    property TotalSuprimento: Double read FTotalSuprimento;
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

{ ============================================================================
  CLASSE TMovimentacao
  ============================================================================ }

constructor TMovimentacao.Create(AID: Integer; ATipo: TTipoMovimentacao; 
  AValor: Double; AMotivo, AOperador: string);
begin
  inherited Create;
  FID := AID;
  FTipo := ATipo;
  FValor := AValor;
  FData := Now;
  FMotivo := AMotivo;
  FOperador := AOperador;
end;

function TMovimentacao.GetTipoAsString: string;
begin
  case FTipo of
    tmSangria: Result := 'Sangria';
    tmSuprimento: Result := 'Suprimento';
  else
    Result := 'Desconhecido';
  end;
end;

procedure TMovimentacao.SetTipo(const Value: TTipoMovimentacao);
begin
  FTipo := Value;

  case FTipo of
    tmSangria: FTipoNome := 'Sangria';
    tmSuprimento: FTipoNome := 'Suprimento';
  end;
end;

{ ============================================================================
  CLASSE TCaixa - CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TCaixa.Create(AID: Integer; AOperador: TOperador; 
  ASaldoInicial: Double = 0);
begin
  inherited Create;
  FID := AID;
  FOperador := AOperador;
  FVendas := TObjectList<TVenda>.Create;
  FMovimentacoes := TObjectList<TMovimentacao>.Create;
  FStatus := scFechado;
  FSaldoInicial := ASaldoInicial;
  FSaldoFinal := 0;
  FTotalVendas := 0;
  FTotalDesconto := 0;
  FTotalAcrescimo := 0;
  FTotalSangria := 0;
  FTotalSuprimento := 0;
  FQuantidadeVendas := 0;
  FQuantidadeProdutos := 0;
  FValorMedioVenda := 0;
  FMaiorVenda := 0;
  FMenorVenda := 0;
  FTotalDinheiro := 0;
  FTotalCartao := 0;
  FTotalPIX := 0;
  FDiferenca := 0;
  FProximoIDMovimentacao := 1;
end;

destructor TCaixa.Destroy;
begin
  FVendas.Free;
  FMovimentacoes.Free;
  inherited;
end;

{ ============================================================================
  OPERAÇÕES DE CAIXA
  ============================================================================ }

procedure TCaixa.Abrir(ASaldoInicial: Double = 0);
begin
  if FStatus = scAberto then
    raise Exception.Create('Caixa já está aberto');
  
  FStatus := scAberto;
  FDataAbertura := Now;
  FSaldoInicial := ASaldoInicial;
  FVendas.Clear;
  FMovimentacoes.Clear;
  FProximoIDMovimentacao := 1;
  
  { Inicializar totalizadores }
  FTotalVendas := 0;
  FTotalDesconto := 0;
  FTotalAcrescimo := 0;
  FTotalSangria := 0;
  FTotalSuprimento := 0;
  FQuantidadeVendas := 0;
  FQuantidadeProdutos := 0;
  FTotalDinheiro := 0;
  FTotalCartao := 0;
  FTotalPIX := 0;
end;

procedure TCaixa.Fechar;
begin
  if FStatus <> scAberto then
    raise Exception.Create('Caixa não está aberto');
  
  if not PodeFechar then
    raise Exception.Create('Caixa não pode ser fechado. Verifique os dados.');
  
  FStatus := scFechando;
  
  { Calcular totalizadores }
  CalcularTotalizadores;
  
  { Calcular saldo final }
  FSaldoFinal := CalcularSaldoFinal;
  
  { Calcular diferença }
  FDiferenca := FSaldoFinal - FSaldoInicial;
  
  { Validar caixa }
  ValidarCaixa;
  
  FStatus := scFechado;
  FDataFechamento := Now;
end;

procedure TCaixa.Cancelar;
begin
  if FStatus = scFechado then
    raise Exception.Create('Caixa já está fechado');
  
  FStatus := scFechado;
  FVendas.Clear;
  FMovimentacoes.Clear;
end;

{ ============================================================================
  OPERAÇÕES COM VENDAS
  ============================================================================ }

procedure TCaixa.AdicionarVenda(AVenda: TVenda);
begin
  if not EstaAberto then
    raise Exception.Create('Caixa não está aberto');
  
  if not Assigned(AVenda) then
    raise Exception.Create('Venda inválida');
  
  FVendas.Add(AVenda);
  CalcularTotalizadores;
end;

procedure TCaixa.RemoverVenda(AIndex: Integer);
begin
  if (AIndex < 0) or (AIndex >= FVendas.Count) then
    raise Exception.Create('Índice de venda inválido');
  
  FVendas.Delete(AIndex);
  CalcularTotalizadores;
end;

{
============================================================================
  MOVIMENTAÇÕES (SANGRIA/SUPRIMENTO)
  ============================================================================ }

function TCaixa.RealizarSangria(AValor: Double; AMotivo: string = ''): Boolean;
var
  Movimentacao: TMovimentacao;
begin
  Result := False;
  
  if not EstaAberto then
    raise Exception.Create('Caixa não está aberto');
  
  if AValor <= 0 then
    raise Exception.Create('Valor de sangria deve ser maior que zero');
  
  if AValor > (FSaldoInicial + FTotalVendas - FTotalSangria) then
    raise Exception.Create('Saldo insuficiente para sangria');
  
  { Criar movimentação }
  Movimentacao := TMovimentacao.Create(
    FProximoIDMovimentacao,
    tmSangria,
    AValor,
    AMotivo,
    FOperador.Nome
  );
  
  FMovimentacoes.Add(Movimentacao);
  Inc(FProximoIDMovimentacao);
  
  { Atualizar total de sangria }
  FTotalSangria := FTotalSangria + AValor;
  
  Result := True;
end;

function TCaixa.RealizarSuprimento(AValor: Double; AMotivo: string = ''): Boolean;
var
  Movimentacao: TMovimentacao;
begin
  Result := False;
  
  if not EstaAberto then
    raise Exception.Create('Caixa não está aberto');
  
  if AValor <= 0 then
    raise Exception.Create('Valor de suprimento deve ser maior que zero');
  
  { Criar movimentação }
  Movimentacao := TMovimentacao.Create(
    FProximoIDMovimentacao,
    tmSuprimento,
    AValor,
    AMotivo,
    FOperador.Nome
  );
  
  FMovimentacoes.Add(Movimentacao);
  Inc(FProximoIDMovimentacao);
  
  { Atualizar total de suprimento }
  FTotalSuprimento := FTotalSuprimento + AValor;
  
  Result := True;
end;

function TCaixa.ObterMovimentacoes: TObjectList<TMovimentacao>;
var
  Resultado: TObjectList<TMovimentacao>;
  i: Integer;
begin
  Resultado := TObjectList<TMovimentacao>.Create(False);
  
  for i := 0 to FMovimentacoes.Count - 1 do
    Resultado.Add(FMovimentacoes[i]);
  
  Result := Resultado;
end;

function TCaixa.ObterMovimentacoesPorTipo(ATipo: TTipoMovimentacao): TObjectList<TMovimentacao>;
var
  Resultado: TObjectList<TMovimentacao>;
  i: Integer;
begin
  Resultado := TObjectList<TMovimentacao>.Create(False);
  
  for i := 0 to FMovimentacoes.Count - 1 do
  begin
    if FMovimentacoes[i].Tipo = ATipo then
      Resultado.Add(FMovimentacoes[i]);
  end;
  
  Result := Resultado;
end;

{ ============================================================================
  CONSULTAS
  ============================================================================ }

procedure TCaixa.SetStatus(const Value: TStatusCaixa);
begin
  FStatus := Value;

  case FStatus of
    scFechado: FStatusNome := 'Fechado';
    scAberto: FStatusNome := 'Aberto';
    scFechando: FStatusNome := 'Fechando';
  end;
end;

function TCaixa.GetVenda(AIndex: Integer): TVenda;
begin
  if (AIndex < 0) or (AIndex >= FVendas.Count) then
    Result := nil
  else
    Result := FVendas[AIndex];
end;

function TCaixa.ObterVendasPorData(AData: TDateTime): TObjectList<TVenda>;
var
  Resultado: TObjectList<TVenda>;
  i: Integer;
  Venda: TVenda;
begin
  Resultado := TObjectList<TVenda>.Create(False);
  
  for i := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[i];
    if Trunc(Venda.DataVenda) = Trunc(AData) then
      Resultado.Add(Venda);
  end;
  
  Result := Resultado;
end;

function TCaixa.ObterVendasPorFormaPagamento(AForma: Integer): TObjectList<TVenda>;
var
  Resultado: TObjectList<TVenda>;
  i: Integer;
  Venda: TVenda;
begin
  Resultado := TObjectList<TVenda>.Create(False);
  
  for i := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[i];
    if Venda.FormaPagamento = TFormaPagamento(AForma) then
      Resultado.Add(Venda);
  end;
  
  Result := Resultado;
end;

function TCaixa.ObterResumoVendas: string;
begin
  Result := '';
  Result := Result + '=== RESUMO DE VENDAS ===' + sLineBreak;
  Result := Result + 'Quantidade de Vendas: ' + IntToStr(FQuantidadeVendas) + sLineBreak;
  Result := Result + 'Quantidade de Produtos: ' + IntToStr(FQuantidadeProdutos) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + 'Subtotal: R$ ' + FormatFloat('0.00', FTotalVendas) + sLineBreak;
  Result := Result + 'Total Desconto: R$ ' + FormatFloat('0.00', FTotalDesconto) + sLineBreak;
  Result := Result + 'Total Acréscimo: R$ ' + FormatFloat('0.00', FTotalAcrescimo) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + 'Dinheiro: R$ ' + FormatFloat('0.00', FTotalDinheiro) + sLineBreak;
  Result := Result + 'Cartão: R$ ' + FormatFloat('0.00', FTotalCartao) + sLineBreak;
  Result := Result + 'PIX: R$ ' + FormatFloat('0.00', FTotalPIX) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + 'Valor Médio: R$ ' + FormatFloat('0.00', FValorMedioVenda) + sLineBreak;
  Result := Result + 'Maior Venda: R$ ' + FormatFloat('0.00', FMaiorVenda) + sLineBreak;
  Result := Result + 'Menor Venda: R$ ' + FormatFloat('0.00', FMenorVenda);
end;

function TCaixa.ObterDetalhesVendas: string;
var
  i: Integer;
  Venda: TVenda;
begin
  Result := '';
  Result := Result + '=== DETALHES DE VENDAS ===' + sLineBreak;
  Result := Result + sLineBreak;
  
  for i := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[i];
    Result := Result + 'Venda ' + IntToStr(i + 1) + ':' + sLineBreak;
    Result := Result + '  Data: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', Venda.DataVenda) + sLineBreak;
    Result := Result + '  Total: R$ ' + FormatFloat('0.00', Venda.Total) + sLineBreak;
    Result := Result + '  Itens: ' + IntToStr(Venda.QuantidadeItens) + sLineBreak;
    Result := Result + sLineBreak;
  end;
end;

function TCaixa.ObterResumoMovimentacoes: string;
var
  Sangrias: TObjectList<TMovimentacao>;
  Suprimentos: TObjectList<TMovimentacao>;
  i: Integer;
begin
  Result := '';
  Result := Result + '=== RESUMO DE MOVIMENTAÇÕES ===' + sLineBreak;
  Result := Result + sLineBreak;
  
  { Sangrias }
  Sangrias := ObterMovimentacoesPorTipo(tmSangria);
  try
    Result := Result + 'Sangrias: ' + IntToStr(Sangrias.Count) + sLineBreak;
    Result := Result + 'Total Sangria: R$ ' + FormatFloat('0.00', FTotalSangria) + sLineBreak;
    
    for i := 0 to Sangrias.Count - 1 do
    begin
      Result := Result + '  - R$ ' + FormatFloat('0.00', Sangrias[i].Valor) + 
                ' (' + Sangrias[i].Motivo + ')' + sLineBreak;
    end;
  finally
    Sangrias.Free;
  end;
  
  Result := Result + sLineBreak;
  
  { Suprimentos }
  Suprimentos := ObterMovimentacoesPorTipo(tmSuprimento);
  try
    Result := Result + 'Suprimentos: ' + IntToStr(Suprimentos.Count) + sLineBreak;
    Result := Result + 'Total Suprimento: R$ ' + FormatFloat('0.00', FTotalSuprimento) + sLineBreak;
    
    for i := 0 to Suprimentos.Count - 1 do
    begin
      Result := Result + '  + R$ ' + FormatFloat('0.00', Suprimentos[i].Valor) + 
                ' (' + Suprimentos[i].Motivo + ')' + sLineBreak;
    end;
  finally
    Suprimentos.Free;
  end;
end;

function TCaixa.ObterResumoCaixa: string;
begin
  Result := '';
  Result := Result + '╔════════════════════════════════════════════════════════════╗' + sLineBreak;
  Result := Result + '║                    RESUMO DO CAIXA                         ║' + sLineBreak;
  Result := Result + '╚════════════════════════════════════════════════════════════╝' + sLineBreak;
  Result := Result + sLineBreak;

  Result := Result + 'ID do Caixa: ' + IntToStr(FID) + sLineBreak;
  Result := Result + 'Operador: ' + FOperador.Nome + sLineBreak;
  Result := Result + 'Status: ' + GetEnumName(TypeInfo(TStatusCaixa), Ord(FStatus)) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── DATAS ───' + sLineBreak;
  Result := Result + 'Abertura: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', FDataAbertura) + sLineBreak;
  if FStatus = scFechado then
    Result := Result + 'Fechamento: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', FDataFechamento) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── SALDOS ───' + sLineBreak;
  Result := Result + 'Saldo Inicial: R$ ' + FormatFloat('0.00', FSaldoInicial) + sLineBreak;
  Result := Result + 'Saldo Final: R$ ' + FormatFloat('0.00', FSaldoFinal) + sLineBreak;
  Result := Result + 'Diferença: R$ ' + FormatFloat('0.00', FDiferenca) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── VENDAS ───' + sLineBreak;
  Result := Result + 'Quantidade: ' + IntToStr(FQuantidadeVendas) + sLineBreak;
  Result := Result + 'Total: R$ ' + FormatFloat('0.00', FTotalVendas) + sLineBreak;
  Result := Result + 'Desconto: R$ ' + FormatFloat('0.00', FTotalDesconto) + sLineBreak;
  Result := Result + 'Acréscimo: R$ ' + FormatFloat('0.00', FTotalAcrescimo) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── FORMAS DE PAGAMENTO ───' + sLineBreak;
  Result := Result + 'Dinheiro: R$ ' + FormatFloat('0.00', FTotalDinheiro) + sLineBreak;
  Result := Result + 'Cartão: R$ ' + FormatFloat('0.00', FTotalCartao) + sLineBreak;
  Result := Result + 'PIX: R$ ' + FormatFloat('0.00', FTotalPIX) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── MOVIMENTAÇÕES ───' + sLineBreak;
  Result := Result + 'Sangrias: R$ ' + FormatFloat('0.00', FTotalSangria) + sLineBreak;
  Result := Result + 'Suprimentos: R$ ' + FormatFloat('0.00', FTotalSuprimento);
end;

{ ============================================================================
  VALIDAÇÕES
  ============================================================================ }

function TCaixa.PodeFechar: Boolean;
begin
  Result := (EstaAberto and ((FVendas.Count > 0) or (FMovimentacoes.Count > 0)));
end;

function TCaixa.EstaAberto: Boolean;
begin
  Result := FStatus = scAberto;
end;

function TCaixa.EstaFechado: Boolean;
begin
  Result := FStatus = scFechado;
end;

{ ============================================================================
  MÉTODOS PRIVADOS
  ============================================================================ }

procedure TCaixa.CalcularTotalizadores;
var
  i: Integer;
  Venda: TVenda;
begin
  FTotalVendas := 0;
  FTotalDesconto := 0;
  FTotalAcrescimo := 0;
  FQuantidadeVendas := 0;
  FQuantidadeProdutos := 0;
  FTotalDinheiro := 0;
  FTotalCartao := 0;
  FTotalPIX := 0;
  FValorMedioVenda := 0;
  FMaiorVenda := 0;
  FMenorVenda := 0;
  
  for i := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[i];
    
    { Totalizadores }
    FTotalVendas := FTotalVendas + Venda.Total;
    FTotalDesconto := FTotalDesconto + Venda.Desconto;
    FTotalAcrescimo := FTotalAcrescimo + Venda.Acrescimo;
    Inc(FQuantidadeVendas);
    FQuantidadeProdutos := FQuantidadeProdutos + Venda.QuantidadeItens;
    
    { Formas de pagamento }
    case Venda.FormaPagamento of
      TFormaPagamento(0): FTotalDinheiro := FTotalDinheiro + Venda.Total;
      TFormaPagamento(1): FTotalCartao := FTotalCartao + Venda.Total;
      TFormaPagamento(2): FTotalPIX := FTotalPIX + Venda.Total;
    end;
    
    { Maior e menor venda }
    if (FMaiorVenda = 0) or (Venda.Total > FMaiorVenda) then
      FMaiorVenda := Venda.Total;
    
    if (FMenorVenda = 0) or (Venda.Total < FMenorVenda) then
      FMenorVenda := Venda.Total;
  end;
  
  { Valor médio }
  if FQuantidadeVendas > 0 then
    FValorMedioVenda := FTotalVendas / FQuantidadeVendas
  else
    FValorMedioVenda := 0;
end;

function TCaixa.CalcularSaldoFinal: Double;
begin
  Result := FSaldoInicial + FTotalVendas - FTotalSangria + FTotalSuprimento;
end;

procedure TCaixa.ValidarCaixa;
begin
  { Validações de fechamento }
  if FQuantidadeVendas = 0 then
    raise Exception.Create('Caixa sem vendas não pode ser fechado');
end;

end.
