unit uRepositorioCaixa;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uCaixa, uOperador;

type
  TRepositorioCaixa = class
  private
    FCaixas: TObjectList<TCaixa>;
    FProximoID: Integer;
    FCaixaAberto: TCaixa;
  public
    constructor Create;
    destructor Destroy; override;
    
    // Operações CRUD
    procedure AdicionarCaixa(ACaixa: TCaixa);
    procedure RemoverCaixa(AID: Integer);
    procedure AtualizarCaixa(ACaixa: TCaixa);
    
    // Consultas
    function ObterCaixa(AID: Integer): TCaixa;
    function ObterTodos: TObjectList<TCaixa>;
    function ObterAbertos: TObjectList<TCaixa>;
    function ObterFechados: TObjectList<TCaixa>;
    
    // Buscas
    function BuscarPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
    function BuscarPorData(AData: TDateTime): TObjectList<TCaixa>;
    function BuscarPorDataIntervalo(ADataInicio, ADataFim: TDateTime): TObjectList<TCaixa>;
    
    // Operações de caixa aberto
    function AbrirCaixa(AOperador: TOperador; ASaldoInicial: Double): TCaixa;
    procedure FecharCaixa(AID: Integer);
    function ObterCaixaAberto: TCaixa;
    function TemCaixaAberto: Boolean;
    
    // Estatísticas
    function ObterTotalVendas: Double;
    function ObterTotalVendasPorOperador(AOperadorID: Integer): Double;
    function ObterQuantidadeCaixas: Integer;
    function ObterQuantidadeAbertos: Integer;
    function ObterQuantidadeFechados: Integer;
    function ObterValorTotalCaixas: Double;
    function ObterResumoGeral: string;
    
    property Caixas: TObjectList<TCaixa> read FCaixas;
    property CaixaAberto: TCaixa read FCaixaAberto;
  end;

implementation

constructor TRepositorioCaixa.Create;
begin
  inherited Create;
  FCaixas := TObjectList<TCaixa>.Create;
  FProximoID := 1;
  FCaixaAberto := nil;
end;

destructor TRepositorioCaixa.Destroy;
begin
  if Assigned(FCaixas) then
    FCaixas.Free;
  inherited;
end;

procedure TRepositorioCaixa.AdicionarCaixa(ACaixa: TCaixa);
begin
  if Assigned(ACaixa) then
  begin
    ACaixa.ID := FProximoID;
    FCaixas.Add(ACaixa);
    Inc(FProximoID);
  end;
end;

procedure TRepositorioCaixa.RemoverCaixa(AID: Integer);
var
  i: Integer;
begin
  for i := FCaixas.Count - 1 downto 0 do
  begin
    if FCaixas[i].ID = AID then
    begin
      FCaixas.Delete(i);
      Exit;
    end;
  end;
end;

procedure TRepositorioCaixa.AtualizarCaixa(ACaixa: TCaixa);
var
  i: Integer;
begin
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].ID = ACaixa.ID then
    begin
      FCaixas[i] := ACaixa;
      Exit;
    end;
  end;
end;

function TRepositorioCaixa.ObterCaixa(AID: Integer): TCaixa;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].ID = AID then
    begin
      Result := FCaixas[i];
      Exit;
    end;
  end;
end;

function TRepositorioCaixa.ObterTodos: TObjectList<TCaixa>;
var
  i: Integer;
  Lista: TObjectList<TCaixa>;
begin
  Lista := TObjectList<TCaixa>.Create(False);
  for i := 0 to FCaixas.Count - 1 do
    Lista.Add(FCaixas[i]);
  Result := Lista;
end;

function TRepositorioCaixa.ObterAbertos: TObjectList<TCaixa>;
var
  i: Integer;
  Lista: TObjectList<TCaixa>;
begin
  Lista := TObjectList<TCaixa>.Create(False);
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].EstaAberto then
      Lista.Add(FCaixas[i]);
  end;
  Result := Lista;
end;

function TRepositorioCaixa.ObterFechados: TObjectList<TCaixa>;
var
  i: Integer;
  Lista: TObjectList<TCaixa>;
begin
  Lista := TObjectList<TCaixa>.Create(False);
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].EstaFechado then
      Lista.Add(FCaixas[i]);
  end;
  Result := Lista;
end;

function TRepositorioCaixa.BuscarPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
var
  i: Integer;
  Lista: TObjectList<TCaixa>;
begin
  Lista := TObjectList<TCaixa>.Create(False);
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].Operador.ID = AOperadorID then
      Lista.Add(FCaixas[i]);
  end;
  Result := Lista;
end;

function TRepositorioCaixa.BuscarPorData(AData: TDateTime): TObjectList<TCaixa>;
var
  i: Integer;
  Lista: TObjectList<TCaixa>;
begin
  Lista := TObjectList<TCaixa>.Create(False);
  for i := 0 to FCaixas.Count - 1 do
  begin
    if Trunc(FCaixas[i].DataAbertura) = Trunc(AData) then
      Lista.Add(FCaixas[i]);
  end;
  Result := Lista;
end;

function TRepositorioCaixa.BuscarPorDataIntervalo(ADataInicio, ADataFim: TDateTime): TObjectList<TCaixa>;
var
  i: Integer;
  Lista: TObjectList<TCaixa>;
begin
  Lista := TObjectList<TCaixa>.Create(False);
  for i := 0 to FCaixas.Count - 1 do
  begin
    if (Trunc(FCaixas[i].DataAbertura) >= Trunc(ADataInicio)) and
       (Trunc(FCaixas[i].DataAbertura) <= Trunc(ADataFim)) then
      Lista.Add(FCaixas[i]);
  end;
  Result := Lista;
end;

function TRepositorioCaixa.AbrirCaixa(AOperador: TOperador; ASaldoInicial: Double): TCaixa;
var
  Caixa: TCaixa;
begin
  if TemCaixaAberto then
    raise Exception.Create('Já existe um caixa aberto');
  
  Caixa := TCaixa.Create(FProximoID, AOperador, ASaldoInicial);
  Caixa.Abrir(ASaldoInicial);
  AdicionarCaixa(Caixa);
  FCaixaAberto := Caixa;
  Result := Caixa;
end;

procedure TRepositorioCaixa.FecharCaixa(AID: Integer);
var
  Caixa: TCaixa;
begin
  Caixa := ObterCaixa(AID);
  if Assigned(Caixa) then
  begin
    Caixa.Fechar;
    if FCaixaAberto = Caixa then
      FCaixaAberto := nil;
  end;
end;

function TRepositorioCaixa.ObterCaixaAberto: TCaixa;
begin
  Result := FCaixaAberto;
end;

function TRepositorioCaixa.TemCaixaAberto: Boolean;
begin
  Result := Assigned(FCaixaAberto) and FCaixaAberto.EstaAberto;
end;

function TRepositorioCaixa.ObterTotalVendas: Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FCaixas.Count - 1 do
    Result := Result + FCaixas[i].TotalVendas;
end;

function TRepositorioCaixa.ObterTotalVendasPorOperador(AOperadorID: Integer): Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].Operador.ID = AOperadorID then
      Result := Result + FCaixas[i].TotalVendas;
  end;
end;

function TRepositorioCaixa.ObterQuantidadeCaixas: Integer;
begin
  Result := FCaixas.Count;
end;

function TRepositorioCaixa.ObterQuantidadeAbertos: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].EstaAberto then
      Inc(Result);
  end;
end;

function TRepositorioCaixa.ObterQuantidadeFechados: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FCaixas.Count - 1 do
  begin
    if FCaixas[i].EstaFechado then
      Inc(Result);
  end;
end;

function TRepositorioCaixa.ObterValorTotalCaixas: Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FCaixas.Count - 1 do
    Result := Result + FCaixas[i].SaldoFinal;
end;

function TRepositorioCaixa.ObterResumoGeral: string;
begin
  Result := '';
  Result := Result + 'RESUMO GERAL DE CAIXAS' + sLineBreak + sLineBreak;
  Result := Result + Format('Total de Caixas: %d', [ObterQuantidadeCaixas]) + sLineBreak;
  Result := Result + Format('Caixas Abertos: %d', [ObterQuantidadeAbertos]) + sLineBreak;
  Result := Result + Format('Caixas Fechados: %d', [ObterQuantidadeFechados]) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + Format('Total de Vendas: R$ %.2f', [ObterTotalVendas]) + sLineBreak;
  Result := Result + Format('Valor Total Caixas: R$ %.2f', [ObterValorTotalCaixas]) + sLineBreak;
end;

end.
