unit uRepositorioCaixa;

interface

uses
  System.SysUtils, System.Generics.Collections, System.DateUtils,
  uCaixa, uOperador;

type
  { Classe para gerenciar caixas abertos e fechados }
  TRepositorioCaixa = class
  private
    FCaixasAbertos: TObjectList<TCaixa>;
    FCaixasFechados: TObjectList<TCaixa>;
    FCaixaAtual: TCaixa;
    FProximoID: Integer;
    FUltimoErro: string;
    
    function ObterProximoID: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    
    { ========== OPERAÇÕES COM CAIXA ATUAL ========== }
    
    { Abrir novo caixa }
    function AbrirCaixa(AOperador: TOperador; ASaldoInicial: Double = 0): TCaixa;
    
    { Fechar caixa atual }
    function FecharCaixa: Boolean;
    
    { Cancelar caixa atual }
    procedure CancelarCaixa;
    
    { Obter caixa atual }
    function GetCaixaAtual: TCaixa;
    
    { ========== CONSULTAS ========== }
    
    { Obter todos os caixas abertos }
    function ObterCaixasAbertos: TObjectList<TCaixa>;
    
    { Obter todos os caixas fechados }
    function ObterCaixasFechados: TObjectList<TCaixa>;
    
    { Obter caixa por ID }
    function ObterCaixaPorID(AID: Integer): TCaixa;
    
    { Obter caixas por data }
    function ObterCaixasPorData(AData: TDateTime): TObjectList<TCaixa>;
    
    { Obter caixas por operador }
    function ObterCaixasPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
    
    { Obter caixa mais recente }
    function ObterCaixaMaisRecente: TCaixa;
    
    { ========== ESTATÍSTICAS ========== }
    
    { Obter total de caixas }
    function ObterTotalCaixas: Integer;
    
    { Obter total de caixas abertos }
    function ObterTotalCaixasAbertos: Integer;
    
    { Obter total de caixas fechados }
    function ObterTotalCaixasFechados: Integer;
    
    { Obter total de vendas em todos os caixas }
    function ObterTotalVendas: Double;
    
    { Obter total de descontos em todos os caixas }
    function ObterTotalDescontos: Double;
    
    { Obter total de acréscimos em todos os caixas }
    function ObterTotalAcrescimos: Double;
    
    { Obter total de sangrias }
    function ObterTotalSangrias: Double;
    
    { Obter total de suprimentos }
    function ObterTotalSuprimentos: Double;
    
    { Obter relatório de desempenho }
    function ObterRelatorioDesempenho: string;
    
    { ========== VALIDAÇÕES ========== }
    
    { Verificar se existe caixa aberto }
    function TemCaixaAberto: Boolean;
    
    { Verificar se existe caixa atual }
    function TemCaixaAtual: Boolean;
    
    { ========== PROPRIEDADES ========== }
    
    property CaixaAtual: TCaixa read GetCaixaAtual;
    property TotalCaixas: Integer read ObterTotalCaixas;
    property TotalCaixasAbertos: Integer read ObterTotalCaixasAbertos;
    property TotalCaixasFechados: Integer read ObterTotalCaixasFechados;
    property UltimoErro: string read FUltimoErro;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TRepositorioCaixa.Create;
begin
  inherited Create;
  FCaixasAbertos := TObjectList<TCaixa>.Create;
  FCaixasFechados := TObjectList<TCaixa>.Create;
  FCaixaAtual := nil;
  FProximoID := 1;
  FUltimoErro := '';
end;

destructor TRepositorioCaixa.Destroy;
begin
  FCaixasAbertos.Free;
  FCaixasFechados.Free;
  inherited;
end;

{ ============================================================================
  MÉTODOS PRIVADOS
  ============================================================================ }

function TRepositorioCaixa.ObterProximoID: Integer;
begin
  Result := FProximoID;
  Inc(FProximoID);
end;

{ ============================================================================
  OPERAÇÕES COM CAIXA ATUAL
  ============================================================================ }

function TRepositorioCaixa.AbrirCaixa(AOperador: TOperador; 
  ASaldoInicial: Double = 0): TCaixa;
begin
  Result := nil;
  
  { Validar operador }
  if not Assigned(AOperador) then
  begin
    FUltimoErro := 'Operador inválido';
    Exit;
  end;
  
  { Verificar se já existe caixa aberto }
  if TemCaixaAberto then
  begin
    FUltimoErro := 'Já existe um caixa aberto';
    Exit;
  end;
  
  try
    { Criar novo caixa }
    FCaixaAtual := TCaixa.Create(ObterProximoID, AOperador, ASaldoInicial);
    FCaixaAtual.Abrir(ASaldoInicial);
    
    { Adicionar à lista de caixas abertos }
    FCaixasAbertos.Add(FCaixaAtual);
    
    Result := FCaixaAtual;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao abrir caixa: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TRepositorioCaixa.FecharCaixa: Boolean;
var
  Indice: Integer;
begin
  Result := False;
  
  { Validar caixa atual }
  if not Assigned(FCaixaAtual) then
  begin
    FUltimoErro := 'Nenhum caixa aberto';
    Exit;
  end;
  
  try
    { Fechar caixa }
    FCaixaAtual.Fechar;
    
    { Mover de abertos para fechados }
    Indice := FCaixasAbertos.IndexOf(FCaixaAtual);
    if Indice >= 0 then
    begin
      FCaixasAbertos.Delete(Indice);
      FCaixasFechados.Add(FCaixaAtual);
    end;
    
    FCaixaAtual := nil;
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao fechar caixa: ' + E.Message;
      Result := False;
    end;
  end;
end;

procedure TRepositorioCaixa.CancelarCaixa;
var
  Indice: Integer;
begin
  if not Assigned(FCaixaAtual) then
    Exit;
  
  try
    FCaixaAtual.Cancelar;
    
    Indice := FCaixasAbertos.IndexOf(FCaixaAtual);
    if Indice >= 0 then
      FCaixasAbertos.Delete(Indice);
    
    FCaixaAtual := nil;
    FUltimoErro := '';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao cancelar caixa: ' + E.Message;
  end;
end;

function TRepositorioCaixa.GetCaixaAtual: TCaixa;
begin
  Result := FCaixaAtual;
end;

{ ============================================================================
  CONSULTAS
  ============================================================================ }

function TRepositorioCaixa.ObterCaixasAbertos: TObjectList<TCaixa>;
var
  Resultado: TObjectList<TCaixa>;
  i: Integer;
begin
  Resultado := TObjectList<TCaixa>.Create(False);
  
  for i := 0 to FCaixasAbertos.Count - 1 do
    Resultado.Add(FCaixasAbertos[i]);
  
  Result := Resultado;
end;

function TRepositorioCaixa.ObterCaixasFechados: TObjectList<TCaixa>;
var
  Resultado: TObjectList<TCaixa>;
  i: Integer;
begin
  Resultado := TObjectList<TCaixa>.Create(False);
  
  for i := 0 to FCaixasFechados.Count - 1 do
    Resultado.Add(FCaixasFechados[i]);
  
  Result := Resultado;
end;

function TRepositorioCaixa.ObterCaixaPorID(AID: Integer): TCaixa;
var
  i: Integer;
begin
  Result := nil;
  
  { Procurar em caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
  begin
    if FCaixasAbertos[i].ID = AID then
    begin
      Result := FCaixasAbertos[i];
      Exit;
    end;
  end;
  
  { Procurar em caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
  begin
    if FCaixasFechados[i].ID = AID then
    begin
      Result := FCaixasFechados[i];
      Exit;
    end;
  end;
end;

function TRepositorioCaixa.ObterCaixasPorData(AData: TDateTime): TObjectList<TCaixa>;
var
  Resultado: TObjectList<TCaixa>;
  i: Integer;
  Caixa: TCaixa;
begin
  Resultado := TObjectList<TCaixa>.Create(False);
  
  { Procurar em caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
  begin
    Caixa := FCaixasAbertos[i];
    if Trunc(Caixa.DataAbertura) = Trunc(AData) then
      Resultado.Add(Caixa);
  end;
  
  { Procurar em caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
  begin
    Caixa := FCaixasFechados[i];
    if Trunc(Caixa.DataAbertura) = Trunc(AData) then
      Resultado.Add(Caixa);
  end;
  
  Result := Resultado;
end;

function TRepositorioCaixa.ObterCaixasPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
var
  Resultado: TObjectList<TCaixa>;
  i: Integer;
  Caixa: TCaixa;
begin
  Resultado := TObjectList<TCaixa>.Create(False);
  
  { Procurar em caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
  begin
    Caixa := FCaixasAbertos[i];
    if Caixa.Operador.ID = AOperadorID then
      Resultado.Add(Caixa);
  end;
  
  { Procurar em caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
  begin
    Caixa := FCaixasFechados[i];
    if Caixa.Operador.ID = AOperadorID then
      Resultado.Add(Caixa);
  end;
  
  Result := Resultado;
end;

function TRepositorioCaixa.ObterCaixaMaisRecente: TCaixa;
var
  i: Integer;
  MaisRecente: TCaixa;
begin
  Result := nil;
  MaisRecente := nil;
  
  { Procurar em caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
  begin
    if not Assigned(MaisRecente) or 
       (FCaixasAbertos[i].DataAbertura > MaisRecente.DataAbertura) then
      MaisRecente := FCaixasAbertos[i];
  end;
  
  { Procurar em caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
  begin
    if not Assigned(MaisRecente) or 
       (FCaixasFechados[i].DataAbertura > MaisRecente.DataAbertura) then
      MaisRecente := FCaixasFechados[i];
  end;
  
  Result := MaisRecente;
end;

{ ============================================================================
  ESTATÍSTICAS
  ============================================================================ }

function TRepositorioCaixa.ObterTotalCaixas: Integer;
begin
  Result := FCaixasAbertos.Count + FCaixasFechados.Count;
end;

function TRepositorioCaixa.ObterTotalCaixasAbertos: Integer;
begin
  Result := FCaixasAbertos.Count;
end;

function TRepositorioCaixa.ObterTotalCaixasFechados: Integer;
begin
  Result := FCaixasFechados.Count;
end;

function TRepositorioCaixa.ObterTotalVendas: Double;
var
  i: Integer;
  Total: Double;
begin
  Total := 0;
  
  { Somar caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
    Total := Total + FCaixasAbertos[i].TotalVendas;
  
  { Somar caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
    Total := Total + FCaixasFechados[i].TotalVendas;
  
  Result := Total;
end;

function TRepositorioCaixa.ObterTotalDescontos: Double;
var
  i: Integer;
  Total: Double;
begin
  Total := 0;
  
  { Somar caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
    Total := Total + FCaixasAbertos[i].TotalDesconto;
  
  { Somar caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
    Total := Total + FCaixasFechados[i].TotalDesconto;
  
  Result := Total;
end;

function TRepositorioCaixa.ObterTotalAcrescimos: Double;
var
  i: Integer;
  Total: Double;
begin
  Total := 0;
  
  { Somar caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
    Total := Total + FCaixasAbertos[i].TotalAcrescimo;
  
  { Somar caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
    Total := Total + FCaixasFechados[i].TotalAcrescimo;
  
  Result := Total;
end;

function TRepositorioCaixa.ObterTotalSangrias: Double;
var
  i: Integer;
  Total: Double;
begin
  Total := 0;
  
  { Somar caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
    Total := Total + FCaixasAbertos[i].TotalSangria;
  
  { Somar caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
    Total := Total + FCaixasFechados[i].TotalSangria;
  
  Result := Total;
end;

function TRepositorioCaixa.ObterTotalSuprimentos: Double;
var
  i: Integer;
  Total: Double;
begin
  Total := 0;
  
  { Somar caixas abertos }
  for i := 0 to FCaixasAbertos.Count - 1 do
    Total := Total + FCaixasAbertos[i].TotalSuprimento;
  
  { Somar caixas fechados }
  for i := 0 to FCaixasFechados.Count - 1 do
    Total := Total + FCaixasFechados[i].TotalSuprimento;
  
  Result := Total;
end;

function TRepositorioCaixa.ObterRelatorioDesempenho: string;
begin
  Result := '';
  Result := Result + '╔════════════════════════════════════════════════════════════╗' + sLineBreak;
  Result := Result + '║              RELATÓRIO DE DESEMPENHO DO CAIXA              ║' + sLineBreak;
  Result := Result + '╚════════════════════════════════════════════════════════════╝' + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── ESTATÍSTICAS GERAIS ───' + sLineBreak;
  Result := Result + 'Total de Caixas: ' + IntToStr(ObterTotalCaixas) + sLineBreak;
  Result := Result + 'Caixas Abertos: ' + IntToStr(ObterTotalCaixasAbertos) + sLineBreak;
  Result := Result + 'Caixas Fechados: ' + IntToStr(ObterTotalCaixasFechados) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── TOTALIZADORES ───' + sLineBreak;
  Result := Result + 'Total de Vendas: R$ ' + FormatFloat('0.00', ObterTotalVendas) + sLineBreak;
  Result := Result + 'Total de Descontos: R$ ' + FormatFloat('0.00', ObterTotalDescontos) + sLineBreak;
  Result := Result + 'Total de Acréscimos: R$ ' + FormatFloat('0.00', ObterTotalAcrescimos) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── MOVIMENTAÇÕES ───' + sLineBreak;
  Result := Result + 'Total de Sangrias: R$ ' + FormatFloat('0.00', ObterTotalSangrias) + sLineBreak;
  Result := Result + 'Total de Suprimentos: R$ ' + FormatFloat('0.00', ObterTotalSuprimentos) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + '─── CAIXA MAIS RECENTE ───' + sLineBreak;
  if Assigned(ObterCaixaMaisRecente) then
  begin
    Result := Result + 'ID: ' + IntToStr(ObterCaixaMaisRecente.ID) + sLineBreak;
    Result := Result + 'Operador: ' + ObterCaixaMaisRecente.Operador.Nome + sLineBreak;
    Result := Result + 'Abertura: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', ObterCaixaMaisRecente.DataAbertura) + sLineBreak;
  end
  else
  begin
    Result := Result + 'Nenhum caixa registrado';
  end;
end;

{ ============================================================================
  VALIDAÇÕES
  ============================================================================ }

function TRepositorioCaixa.TemCaixaAberto: Boolean;
begin
  Result := Assigned(FCaixaAtual) and FCaixaAtual.EstaAberto;
end;

function TRepositorioCaixa.TemCaixaAtual: Boolean;
begin
  Result := Assigned(FCaixaAtual);
end;

end.
