unit uPersistenciaCaixa;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.DateUtils,
  FireDAC.Comp.Client, FireDAC.Stan.Param, FireDAC.Stan.Def, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys,
  FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.FMXUI.Wait, System.Variants,
  uCaixa, uOperador, Data.DB;

type
  { Classe responsável pela persistência de caixas em SQLite }
  TPersistenciaCaixa = class
  private
    FConexao: TFDConnection;
    FUltimoErro: string;
    FUltimoID: Integer;
    
    { Métodos auxiliares }
    function ExecutarSQL(ASQL: string; AParams: TFDParams = nil): Boolean;
    function ObterValorSQL(ASQL: string; AParams: TFDParams = nil): Variant;
    function ExecutarQuerySQL(ASQL: string; AParams: TFDParams = nil): TFDQuery;
    procedure LimparParametros(AParams: TFDParams);
  public
    constructor Create(AConexao: TFDConnection);
    destructor Destroy; override;
    
    { ========== OPERAÇÕES COM CAIXAS ========== }
    
    { Salvar novo caixa }
    function SalvarCaixa(ACaixa: TCaixa): Boolean;
    
    { Atualizar caixa existente }
    function AtualizarCaixa(ACaixa: TCaixa): Boolean;
    
    { Deletar caixa }
    function DeletarCaixa(ACaixaID: Integer): Boolean;
    
    { Obter caixa por ID }
    function ObterCaixaPorID(ACaixaID: Integer): TCaixa;
    
    { Obter todos os caixas }
    function ObterTodosCaixas: TObjectList<TCaixa>;
    
    { Obter caixas abertos }
    function ObterCaixasAbertos: TObjectList<TCaixa>;
    
    { Obter caixas fechados }
    function ObterCaixasFechados: TObjectList<TCaixa>;
    
    { Obter caixa aberto do operador }
    function ObterCaixaAbertoOperador(AOperadorID: Integer): TCaixa;
    
    { Obter caixas por operador }
    function ObterCaixasPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
    
    { Obter caixas por data }
    function ObterCaixasPorData(AData: TDateTime): TObjectList<TCaixa>;
    
    { Obter caixas por intervalo de data }
    function ObterCaixasPorIntervalo(ADataInicio, ADataFim: TDateTime): TObjectList<TCaixa>;
    
    { ========== OPERAÇÕES COM MOVIMENTAÇÕES ========== }
    
    { Salvar movimentação }
    function SalvarMovimentacao(ACaixaID: Integer; AMovimentacao: TMovimentacao): Boolean;
    
    { Obter movimentações do caixa }
    function ObterMovimentacoesCaixa(ACaixaID: Integer): TObjectList<TMovimentacao>;
    
    { Obter movimentações por tipo }
    function ObterMovimentacoesPorTipo(ACaixaID: Integer; ATipo: string): TObjectList<TMovimentacao>;
    
    { Deletar movimentação }
    function DeletarMovimentacao(AMovimentacaoID: Integer): Boolean;
    
    { ========== OPERAÇÕES COM FECHAMENTOS ========== }
    
    { Salvar fechamento }
    function SalvarFechamento(ACaixaID: Integer; AOperadorID: Integer; 
      AResumo: string): Boolean;
    
    { Obter fechamento }
    function ObterFechamento(ACaixaID: Integer): string;
    
    { Deletar fechamento }
    function DeletarFechamento(ACaixaID: Integer): Boolean;
    
    { ========== ESTATÍSTICAS ========== }
    
    { Obter total de vendas }
    function ObterTotalVendas(ADataInicio: TDateTime = 0; 
      ADataFim: TDateTime = 0): Double;
    
    { Obter total de sangrias }
    function ObterTotalSangrias(ADataInicio: TDateTime = 0; 
      ADataFim: TDateTime = 0): Double;
    
    { Obter total de suprimentos }
    function ObterTotalSuprimentos(ADataInicio: TDateTime = 0; 
      ADataFim: TDateTime = 0): Double;
    
    { Obter quantidade de caixas }
    function ObterQuantidadeCaixas: Integer;
    
    { Obter quantidade de caixas abertos }
    function ObterQuantidadeCaixasAbertos: Integer;
    
    { Obter quantidade de caixas fechados }
    function ObterQuantidadeCaixasFechados: Integer;
    
    { Obter resumo geral }
    function ObterResumoGeral: string;
    
    { Obter resumo por operador }
    function ObterResumoPorOperador(AOperadorID: Integer): string;
    
    { ========== VALIDAÇÕES ========== }
    
    { Verificar se existe caixa aberto }
    function TemCaixaAberto: Boolean;
    
    { Verificar se operador tem caixa aberto }
    function TemCaixaAbertoOperador(AOperadorID: Integer): Boolean;
    
    { Verificar se caixa existe }
    function CaixaExiste(ACaixaID: Integer): Boolean;
    
    { ========== LIMPEZA ========== }
    
    { Limpar todos os caixas }
    function LimparTodosCaixas: Boolean;
    
    { Limpar caixas antigos (anterior a X dias) }
    function LimparCaixasAntigos(ADias: Integer): Boolean;
    
    { ========== PROPRIEDADES ========== }
    
    property UltimoErro: string read FUltimoErro;
    property UltimoID: Integer read FUltimoID;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TPersistenciaCaixa.Create(AConexao: TFDConnection);
begin
  inherited Create;
  
  FConexao := AConexao;
  FUltimoErro := '';
  FUltimoID := 0;
end;

destructor TPersistenciaCaixa.Destroy;
begin
  inherited;
end;

{ ============================================================================
  MÉTODOS AUXILIARES
  ============================================================================ }

function TPersistenciaCaixa.ExecutarSQL(ASQL: string; 
  AParams: TFDParams = nil): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := ASQL;
    
    if Assigned(AParams) then
      Query.Params.Assign(AParams);
    
    Query.ExecSQL;
    
    { Obter último ID inserido }
    if Pos('INSERT', UpperCase(ASQL)) > 0 then
    begin
      Query.SQL.Text := 'SELECT last_insert_rowid() as ID';
      Query.Open;
      if not Query.Eof then
        FUltimoID := Query.FieldByName('ID').AsInteger;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao executar SQL: ' + E.Message;
      Result := False;
    end;
  end;
  Query.Free;
end;

function TPersistenciaCaixa.ObterValorSQL(ASQL: string; 
  AParams: TFDParams = nil): Variant;
var
  Query: TFDQuery;
begin
  Result := Null;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := ASQL;
    
    if Assigned(AParams) then
      Query.Params.Assign(AParams);
    
    Query.Open;
    
    if not Query.Eof then
      Result := Query.Fields[0].Value;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter valor: ' + E.Message;
      Result := Null;
    end;
  end;
  Query.Free;
end;

function TPersistenciaCaixa.ExecutarQuerySQL(ASQL: string; 
  AParams: TFDParams = nil): TFDQuery;
begin
  Result := TFDQuery.Create(nil);
  Result.Connection := FConexao;
  Result.SQL.Text := ASQL;
  
  if Assigned(AParams) then
    Result.Params.Assign(AParams);
  
  Result.Open;
end;

procedure TPersistenciaCaixa.LimparParametros(AParams: TFDParams);
begin
  if Assigned(AParams) then
    AParams.Clear;
end;

{ ============================================================================
  OPERAÇÕES COM CAIXAS
  ============================================================================ }

function TPersistenciaCaixa.SalvarCaixa(ACaixa: TCaixa): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  if not Assigned(ACaixa) then
  begin
    FUltimoErro := 'Caixa inválido';
    Exit;
  end;
  
  try
    SQL := 'INSERT INTO Caixas (' +
      'OperadorID, DataAbertura, SaldoInicial, TotalVendas, ' +
      'TotalDesconto, TotalAcrescimo, TotalSangria, TotalSuprimento, ' +
      'QuantidadeVendas, QuantidadeProdutos, TotalDinheiro, TotalCartao, TotalPIX, ' +
      'Status, DataCriacao) ' +
      'VALUES (:OperadorID, :DataAbertura, :SaldoInicial, :TotalVendas, ' +
      ':TotalDesconto, :TotalAcrescimo, :TotalSangria, :TotalSuprimento, ' +
      ':QuantidadeVendas, :QuantidadeProdutos, :TotalDinheiro, :TotalCartao, :TotalPIX, ' +
      ':Status, CURRENT_TIMESTAMP)';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'OperadorID', ptInput).Value := ACaixa.Operador.ID;
      Params.CreateParam(ftDateTime, 'DataAbertura', ptInput).Value := ACaixa.DataAbertura;
      Params.CreateParam(ftFloat, 'SaldoInicial', ptInput).Value := ACaixa.SaldoInicial;
      Params.CreateParam(ftFloat, 'TotalVendas', ptInput).Value := ACaixa.TotalVendas;
      Params.CreateParam(ftFloat, 'TotalDesconto', ptInput).Value := ACaixa.TotalDesconto;
      Params.CreateParam(ftFloat, 'TotalAcrescimo', ptInput).Value := ACaixa.TotalAcrescimo;
      Params.CreateParam(ftFloat, 'TotalSangria', ptInput).Value := ACaixa.TotalSangria;
      Params.CreateParam(ftFloat, 'TotalSuprimento', ptInput).Value := ACaixa.TotalSuprimento;
      Params.CreateParam(ftInteger, 'QuantidadeVendas', ptInput).Value := ACaixa.QuantidadeVendas;
      Params.CreateParam(ftInteger, 'QuantidadeProdutos', ptInput).Value := ACaixa.QuantidadeProdutos;
      Params.CreateParam(ftFloat, 'TotalDinheiro', ptInput).Value := ACaixa.TotalDinheiro;
      Params.CreateParam(ftFloat, 'TotalCartao', ptInput).Value := ACaixa.TotalCartao;
      Params.CreateParam(ftFloat, 'TotalPIX', ptInput).Value := ACaixa.TotalPIX;
      Params.CreateParam(ftString, 'Status', ptInput).Value := 'Aberto';
      
      Result := ExecutarSQL(SQL, Params);
      
      if Result then
        ACaixa.ID := FUltimoID;
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar caixa: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaCaixa.AtualizarCaixa(ACaixa: TCaixa): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  if not Assigned(ACaixa) then
  begin
    FUltimoErro := 'Caixa inválido';
    Exit;
  end;
  
  try
    SQL := 'UPDATE Caixas SET ' +
      'TotalVendas = :TotalVendas, ' +
      'TotalDesconto = :TotalDesconto, ' +
      'TotalAcrescimo = :TotalAcrescimo, ' +
      'TotalSangria = :TotalSangria, ' +
      'TotalSuprimento = :TotalSuprimento, ' +
      'QuantidadeVendas = :QuantidadeVendas, ' +
      'QuantidadeProdutos = :QuantidadeProdutos, ' +
      'TotalDinheiro = :TotalDinheiro, ' +
      'TotalCartao = :TotalCartao, ' +
      'TotalPIX = :TotalPIX, ' +
      'DataAtualizacao = CURRENT_TIMESTAMP ' +
      'WHERE ID = :ID';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftFloat, 'TotalVendas', ptInput).Value := ACaixa.TotalVendas;
      Params.CreateParam(ftFloat, 'TotalDesconto', ptInput).Value := ACaixa.TotalDesconto;
      Params.CreateParam(ftFloat, 'TotalAcrescimo', ptInput).Value := ACaixa.TotalAcrescimo;
      Params.CreateParam(ftFloat, 'TotalSangria', ptInput).Value := ACaixa.TotalSangria;
      Params.CreateParam(ftFloat, 'TotalSuprimento', ptInput).Value := ACaixa.TotalSuprimento;
      Params.CreateParam(ftInteger, 'QuantidadeVendas', ptInput).Value := ACaixa.QuantidadeVendas;
      Params.CreateParam(ftInteger, 'QuantidadeProdutos', ptInput).Value := ACaixa.QuantidadeProdutos;
      Params.CreateParam(ftFloat, 'TotalDinheiro', ptInput).Value := ACaixa.TotalDinheiro;
      Params.CreateParam(ftFloat, 'TotalCartao', ptInput).Value := ACaixa.TotalCartao;
      Params.CreateParam(ftFloat, 'TotalPIX', ptInput).Value := ACaixa.TotalPIX;
      Params.CreateParam(ftInteger, 'ID', ptInput).Value := ACaixa.ID;
      
      Result := ExecutarSQL(SQL, Params);
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao atualizar caixa: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaCaixa.DeletarCaixa(ACaixaID: Integer): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  try
    SQL := 'DELETE FROM Caixas WHERE ID = :ID';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'ID', ptInput).Value := ACaixaID;
      Result := ExecutarSQL(SQL, Params);
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar caixa: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaCaixa.ObterCaixaPorID(ACaixaID: Integer): TCaixa;
var
  Query: TFDQuery;
  Caixa: TCaixa;
begin
  Result := nil;
  
  try
    Query := ExecutarQuerySQL(
      'SELECT * FROM Caixas WHERE ID = :ID',
      TFDParams.Create
    );
    Query.ParamByName('ID').Value := ACaixaID;
    
    if not Query.Eof then
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;

      if not Query.FieldByName('DataFechamento').IsNull then
        Caixa.DataFechamento := Query.FieldByName('DataFechamento').AsDateTime;
      
      Result := Caixa;
    end;
    
    Query.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixa: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TPersistenciaCaixa.ObterTodosCaixas: TObjectList<TCaixa>;
var
  Query: TFDQuery;
  Caixas: TObjectList<TCaixa>;
  Caixa: TCaixa;
begin
  Caixas := TObjectList<TCaixa>.Create;
  
  try
    Query := ExecutarQuerySQL('SELECT * FROM Caixas ORDER BY DataAbertura DESC');
    
    while not Query.Eof do
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;
      
      if not Query.FieldByName('DataFechamento').IsNull then
        Caixa.DataFechamento := Query.FieldByName('DataFechamento').AsDateTime;
      
      Caixas.Add(Caixa);
      Query.Next;
    end;
    
    Query.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixas: ' + E.Message;
      Caixas.Free;
      Caixas := TObjectList<TCaixa>.Create;
    end;
  end;
  
  Result := Caixas;
end;

function TPersistenciaCaixa.ObterCaixasAbertos: TObjectList<TCaixa>;
var
  Query: TFDQuery;
  Caixas: TObjectList<TCaixa>;
  Caixa: TCaixa;
begin
  Caixas := TObjectList<TCaixa>.Create;
  
  try
    Query := ExecutarQuerySQL(
      'SELECT * FROM Caixas WHERE Status = ''Aberto'' ORDER BY DataAbertura DESC'
    );
    
    while not Query.Eof do
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;
      
      Caixas.Add(Caixa);
      Query.Next;
    end;
    
    Query.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixas abertos: ' + E.Message;
      Caixas.Free;
      Caixas := TObjectList<TCaixa>.Create;
    end;
  end;
  
  Result := Caixas;
end;

function TPersistenciaCaixa.ObterCaixasFechados: TObjectList<TCaixa>;
var
  Query: TFDQuery;
  Caixas: TObjectList<TCaixa>;
  Caixa: TCaixa;
begin
  Caixas := TObjectList<TCaixa>.Create;
  
  try
    Query := ExecutarQuerySQL(
      'SELECT * FROM Caixas WHERE Status = ''Fechado'' ORDER BY DataFechamento DESC'
    );
    
    while not Query.Eof do
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;

      if not Query.FieldByName('DataFechamento').IsNull then
        Caixa.DataFechamento := Query.FieldByName('DataFechamento').AsDateTime;
      
      Caixas.Add(Caixa);
      Query.Next;
    end;
    
    Query.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixas fechados: ' + E.Message;
      Caixas.Free;
      Caixas := TObjectList<TCaixa>.Create;
    end;
  end;
  
  Result := Caixas;
end;

function TPersistenciaCaixa.ObterCaixaAbertoOperador(AOperadorID: Integer): TCaixa;
var
  Query: TFDQuery;
  Params: TFDParams;
  Caixa: TCaixa;
begin
  Result := nil;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftInteger, 'OperadorID', ptInput).Value := AOperadorID;
    
    Query := ExecutarQuerySQL(
      'SELECT * FROM Caixas WHERE OperadorID = :OperadorID AND Status = ''Aberto'' LIMIT 1',
      Params
    );
    
    if not Query.Eof then
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;
      
      Result := Caixa;
    end;
    
    Query.Free;
    Params.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixa aberto do operador: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TPersistenciaCaixa.ObterCaixasPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
var
  Query: TFDQuery;
  Params: TFDParams;
  Caixas: TObjectList<TCaixa>;
  Caixa: TCaixa;
begin
  Caixas := TObjectList<TCaixa>.Create;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftInteger, 'OperadorID', ptInput).Value := AOperadorID;
    
    Query := ExecutarQuerySQL(
      'SELECT * FROM Caixas WHERE OperadorID = :OperadorID ORDER BY DataAbertura DESC',
      Params
    );
    
    while not Query.Eof do
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );

      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;
      
      if not Query.FieldByName('DataFechamento').IsNull then
        Caixa.DataFechamento := Query.FieldByName('DataFechamento').AsDateTime;
      
      Caixas.Add(Caixa);
      Query.Next;
    end;
    
    Query.Free;
    Params.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixas por operador: ' + E.Message;
      Caixas.Free;
      Caixas := TObjectList<TCaixa>.Create;
    end;
  end;
  
  Result := Caixas;
end;

function TPersistenciaCaixa.ObterCaixasPorData(AData: TDateTime): TObjectList<TCaixa>;
var
  Query: TFDQuery;
  Params: TFDParams;
  Caixas: TObjectList<TCaixa>;
  Caixa: TCaixa;
begin
  Caixas := TObjectList<TCaixa>.Create;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftString, 'Data', ptInput).Value := FormatDateTime('yyyy-mm-dd', AData);
    
    Query := ExecutarQuerySQL(
      'SELECT * FROM Caixas WHERE DATE(DataAbertura) = :Data ORDER BY DataAbertura DESC',
      Params
    );
    
    while not Query.Eof do
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;
      
      if not Query.FieldByName('DataFechamento').IsNull then
        Caixa.DataFechamento := Query.FieldByName('DataFechamento').AsDateTime;
      
      Caixas.Add(Caixa);
      Query.Next;
    end;
    
    Query.Free;
    Params.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixas por data: ' + E.Message;
      Caixas.Free;
      Caixas := TObjectList<TCaixa>.Create;
    end;
  end;
  
  Result := Caixas;
end;

function TPersistenciaCaixa.ObterCaixasPorIntervalo(ADataInicio, 
  ADataFim: TDateTime): TObjectList<TCaixa>;
var
  Query: TFDQuery;
  Params: TFDParams;
  Caixas: TObjectList<TCaixa>;
  Caixa: TCaixa;
begin
  Caixas := TObjectList<TCaixa>.Create;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftString, 'DataInicio', ptInput).Value := FormatDateTime('yyyy-mm-dd', ADataInicio);
    Params.CreateParam(ftString, 'DataFim', ptInput).Value := FormatDateTime('yyyy-mm-dd', ADataFim);
    
    Query := ExecutarQuerySQL(
      'SELECT * FROM Caixas WHERE DATE(DataAbertura) BETWEEN :DataInicio AND :DataFim ' +
      'ORDER BY DataAbertura DESC',
      Params
    );
    
    while not Query.Eof do
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.Operador.ID := Query.FieldByName('OperadorID').AsInteger;
      Caixa.DataAbertura := Query.FieldByName('DataAbertura').AsDateTime;

      if not Query.FieldByName('DataFechamento').IsNull then
        Caixa.DataFechamento := Query.FieldByName('DataFechamento').AsDateTime;
      
      Caixas.Add(Caixa);
      Query.Next;
    end;
    
    Query.Free;
    Params.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixas por intervalo: ' + E.Message;
      Caixas.Free;
      Caixas := TObjectList<TCaixa>.Create;
    end;
  end;
  
  Result := Caixas;
end;

{ ============================================================================
  OPERAÇÕES COM MOVIMENTAÇÕES
  ============================================================================ }

function TPersistenciaCaixa.SalvarMovimentacao(ACaixaID: Integer; 
  AMovimentacao: TMovimentacao): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  if not Assigned(AMovimentacao) then
  begin
    FUltimoErro := 'Movimentação inválida';
    Exit;
  end;
  
  try
    SQL := 'INSERT INTO Movimentacoes (' +
      'CaixaID, OperadorID, Tipo, Valor, Data, Motivo, DataCriacao) ' +
      'VALUES (:CaixaID, :OperadorID, :Tipo, :Valor, :Data, :Motivo, CURRENT_TIMESTAMP)';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixaID;
      Params.CreateParam(ftInteger, 'OperadorID', ptInput).Value := AMovimentacao.Operador.ToInteger ;
      Params.CreateParam(ftString, 'Tipo', ptInput).Value := AMovimentacao.Tipo;
      Params.CreateParam(ftFloat, 'Valor', ptInput).Value := AMovimentacao.Valor;
      Params.CreateParam(ftDateTime, 'Data', ptInput).Value := AMovimentacao.Data;
      Params.CreateParam(ftString, 'Motivo', ptInput).Value := AMovimentacao.Motivo;
      
      Result := ExecutarSQL(SQL, Params);
      
      if Result then
        AMovimentacao.ID := FUltimoID;
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar movimentação: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaCaixa.ObterMovimentacoesCaixa(ACaixaID: Integer): TObjectList<TMovimentacao>;
var
  Query: TFDQuery;
  Params: TFDParams;
  Movimentacoes: TObjectList<TMovimentacao>;
  Movimentacao: TMovimentacao;
begin
  Movimentacoes := TObjectList<TMovimentacao>.Create;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixaID;
    
    Query := ExecutarQuerySQL(
      'SELECT * FROM Movimentacoes WHERE CaixaID = :CaixaID ORDER BY Data',
      Params
    );
    
    while not Query.Eof do
    begin
      Movimentacao := TMovimentacao.Create(
        Query.FieldByName('ID').AsInteger,
        TTipoMovimentacao(Query.FieldByName('Tipo').Asinteger),
        Query.FieldByName('Valor').AsFloat,
        Query.FieldByName('Motivo').AsString,
        Query.FieldByName('OperadorID').AsString
      );
      
      Movimentacao.Data := Query.FieldByName('Data').AsDateTime;
      
      Movimentacoes.Add(Movimentacao);
      Query.Next;
    end;
    
    Query.Free;
    Params.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter movimentações: ' + E.Message;
      Movimentacoes.Free;
      Movimentacoes := TObjectList<TMovimentacao>.Create;
    end;
  end;
  
  Result := Movimentacoes;
end;

function TPersistenciaCaixa.ObterMovimentacoesPorTipo(ACaixaID: Integer; 
  ATipo: string): TObjectList<TMovimentacao>;
var
  Query: TFDQuery;
  Params: TFDParams;
  Movimentacoes: TObjectList<TMovimentacao>;
  Movimentacao: TMovimentacao;
begin
  Movimentacoes := TObjectList<TMovimentacao>.Create;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixaID;
    Params.CreateParam(ftString, 'Tipo', ptInput).Value := ATipo;
    
    Query := ExecutarQuerySQL(
      'SELECT * FROM Movimentacoes WHERE CaixaID = :CaixaID AND Tipo = :Tipo ORDER BY Data',
      Params
    );
    
    while not Query.Eof do
    begin
      Movimentacao := TMovimentacao.Create(
        Query.FieldByName('ID').AsInteger,
        TTipoMovimentacao(Query.FieldByName('Tipo').AsInteger),
        Query.FieldByName('Valor').AsFloat,
        Query.FieldByName('Motivo').AsString,
        Query.FieldByName('OperadorID').AsString
      );
      
      Movimentacao.Data := Query.FieldByName('Data').AsDateTime;
      
      Movimentacoes.Add(Movimentacao);
      Query.Next;
    end;
    
    Query.Free;
    Params.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter movimentações por tipo: ' + E.Message;
      Movimentacoes.Free;
      Movimentacoes := TObjectList<TMovimentacao>.Create;
    end;
  end;
  
  Result := Movimentacoes;
end;

function TPersistenciaCaixa.DeletarMovimentacao(AMovimentacaoID: Integer): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  try
    SQL := 'DELETE FROM Movimentacoes WHERE ID = :ID';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'ID', ptInput).Value := AMovimentacaoID;
      Result := ExecutarSQL(SQL, Params);
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar movimentação: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  OPERAÇÕES COM FECHAMENTOS
  ============================================================================ }

function TPersistenciaCaixa.SalvarFechamento(ACaixaID: Integer; 
  AOperadorID: Integer; AResumo: string): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  try
    SQL := 'INSERT INTO Fechamentos (' +
      'CaixaID, OperadorID, Resumo, DataCriacao) ' +
      'VALUES (:CaixaID, :OperadorID, :Resumo, CURRENT_TIMESTAMP)';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixaID;
      Params.CreateParam(ftInteger, 'OperadorID', ptInput).Value := AOperadorID;
      Params.CreateParam(ftString, 'Resumo', ptInput).Value := AResumo;
      
      Result := ExecutarSQL(SQL, Params);
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar fechamento: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaCaixa.ObterFechamento(ACaixaID: Integer): string;
var
  Query: TFDQuery;
  Params: TFDParams;
begin
  Result := '';
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixaID;
    
    Query := ExecutarQuerySQL(
      'SELECT * FROM Fechamentos WHERE CaixaID = :CaixaID',
      Params
    );
    
    if not Query.Eof then
      Result := Query.FieldByName('Resumo').AsString;
    
    Query.Free;
    Params.Free;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter fechamento: ' + E.Message;
      Result := '';
    end;
  end;
end;

function TPersistenciaCaixa.DeletarFechamento(ACaixaID: Integer): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  try
    SQL := 'DELETE FROM Fechamentos WHERE CaixaID = :CaixaID';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixaID;
      Result := ExecutarSQL(SQL, Params);
    finally
      Params.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar fechamento: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  ESTATÍSTICAS
  ============================================================================ }

function TPersistenciaCaixa.ObterTotalVendas(ADataInicio: TDateTime = 0; 
  ADataFim: TDateTime = 0): Double;
var
  SQL: string;
  Resultado: Variant;
begin
  Result := 0;
  
  try
    if ADataInicio = 0 then
      SQL := 'SELECT SUM(TotalVendas) as Total FROM Caixas'
    else
      SQL := 'SELECT SUM(TotalVendas) as Total FROM Caixas ' +
        'WHERE DATE(DataAbertura) BETWEEN DATE(:DataInicio) AND DATE(:DataFim)';
    
    Resultado := ObterValorSQL(SQL);
    
    if not VarIsNull(Resultado) then
      Result := VarAsType(Resultado, varDouble)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TPersistenciaCaixa.ObterTotalSangrias(ADataInicio: TDateTime = 0; 
  ADataFim: TDateTime = 0): Double;
var
  SQL: string;
  Resultado: Variant;
begin
  Result := 0;
  
  try
    if ADataInicio = 0 then
      SQL := 'SELECT SUM(Valor) as Total FROM Movimentacoes WHERE Tipo = ''Sangria'''
    else
      SQL := 'SELECT SUM(Valor) as Total FROM Movimentacoes ' +
        'WHERE Tipo = ''Sangria'' AND DATE(Data) BETWEEN DATE(:DataInicio) AND DATE(:DataFim)';
    
    Resultado := ObterValorSQL(SQL);
    
    if not VarIsNull(Resultado) then
      Result := VarAsType(Resultado, varDouble)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TPersistenciaCaixa.ObterTotalSuprimentos(ADataInicio: TDateTime = 0; 
  ADataFim: TDateTime = 0): Double;
var
  SQL: string;
  Resultado: Variant;
begin
  Result := 0;
  
  try
    if ADataInicio = 0 then
      SQL := 'SELECT SUM(Valor) as Total FROM Movimentacoes WHERE Tipo = ''Suprimento'''
    else
      SQL := 'SELECT SUM(Valor) as Total FROM Movimentacoes ' +
        'WHERE Tipo = ''Suprimento'' AND DATE(Data) BETWEEN DATE(:DataInicio) AND DATE(:DataFim)';
    
    Resultado := ObterValorSQL(SQL);
    
    if not VarIsNull(Resultado) then
      Result := VarAsType(Resultado, varDouble)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TPersistenciaCaixa.ObterQuantidadeCaixas: Integer;
var
  Resultado: Variant;
begin
  Result := 0;
  
  try
    Resultado := ObterValorSQL('SELECT COUNT(*) as Total FROM Caixas');
    
    if not VarIsNull(Resultado) then
      Result := VarAsType(Resultado, varInteger)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TPersistenciaCaixa.ObterQuantidadeCaixasAbertos: Integer;
var
  Resultado: Variant;
begin
  Result := 0;
  
  try
    Resultado := ObterValorSQL('SELECT COUNT(*) as Total FROM Caixas WHERE Status = ''Aberto''');
    
    if not VarIsNull(Resultado) then
      Result := VarAsType(Resultado, varInteger)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TPersistenciaCaixa.ObterQuantidadeCaixasFechados: Integer;
var
  Resultado: Variant;
begin
  Result := 0;
  
  try
    Resultado := ObterValorSQL('SELECT COUNT(*) as Total FROM Caixas WHERE Status = ''Fechado''');
    
    if not VarIsNull(Resultado) then
      Result := VarAsType(Resultado, varInteger)
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TPersistenciaCaixa.ObterResumoGeral: string;
begin
  Result := '';
  Result := Result + '╔════════════════════════════════════════════════════════════╗' + sLineBreak;
  Result := Result + '║              RESUMO GERAL DE CAIXAS                        ║' + sLineBreak;
  Result := Result + '╚════════════════════════════════════════════════════════════╝' + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + 'Total de Caixas: ' + IntToStr(ObterQuantidadeCaixas) + sLineBreak;
  Result := Result + 'Caixas Abertos: ' + IntToStr(ObterQuantidadeCaixasAbertos) + sLineBreak;
  Result := Result + 'Caixas Fechados: ' + IntToStr(ObterQuantidadeCaixasFechados) + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + 'Total de Vendas: R$ ' + FormatFloat('0.00', ObterTotalVendas) + sLineBreak;
  Result := Result + 'Total de Sangrias: R$ ' + FormatFloat('0.00', ObterTotalSangrias) + sLineBreak;
  Result := Result + 'Total de Suprimentos: R$ ' + FormatFloat('0.00', ObterTotalSuprimentos) + sLineBreak;
end;

function TPersistenciaCaixa.ObterResumoPorOperador(AOperadorID: Integer): string;
var
  Caixas: TObjectList<TCaixa>;
  i: Integer;
  TotalVendas: Double;
begin
  Result := '';
  TotalVendas := 0;
  
  Caixas := ObterCaixasPorOperador(AOperadorID);
  try
    Result := Result + '╔════════════════════════════════════════════════════════════╗' + sLineBreak;
    Result := Result + '║         RESUMO POR OPERADOR                               ║' + sLineBreak;
    Result := Result + '╚════════════════════════════════════════════════════════════╝' + sLineBreak;
    Result := Result + sLineBreak;
    
    Result := Result + 'Total de Caixas: ' + IntToStr(Caixas.Count) + sLineBreak;
    
    for i := 0 to Caixas.Count - 1 do
      TotalVendas := TotalVendas + Caixas[i].TotalVendas;
    
    Result := Result + 'Total de Vendas: R$ ' + FormatFloat('0.00', TotalVendas) + sLineBreak;
  finally
    Caixas.Free;
  end;
end;

{ ============================================================================
  VALIDAÇÕES
  ============================================================================ }

function TPersistenciaCaixa.TemCaixaAberto: Boolean;
var
  Resultado: Variant;
begin
  Result := False;
  
  try
    Resultado := ObterValorSQL('SELECT COUNT(*) FROM Caixas WHERE Status = ''Aberto''');
    Result := VarAsType(Resultado, varInteger) > 0;
  except
    Result := False;
  end;
end;

function TPersistenciaCaixa.TemCaixaAbertoOperador(AOperadorID: Integer): Boolean;
var
  Query: TFDQuery;
  Params: TFDParams;
begin
  Result := False;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftInteger, 'OperadorID', ptInput).Value := AOperadorID;
    
    Query := ExecutarQuerySQL(
      'SELECT COUNT(*) FROM Caixas WHERE OperadorID = :OperadorID AND Status = ''Aberto''',
      Params
    );
    
    Result := Query.Fields[0].AsInteger > 0;
    
    Query.Free;
    Params.Free;
  except
    Result := False;
  end;
end;

function TPersistenciaCaixa.CaixaExiste(ACaixaID: Integer): Boolean;
var
  Query: TFDQuery;
  Params: TFDParams;
begin
  Result := False;
  
  try
    Params := TFDParams.Create;
    Params.CreateParam(ftInteger, 'ID', ptInput).Value := ACaixaID;
    
    Query := ExecutarQuerySQL(
      'SELECT COUNT(*) FROM Caixas WHERE ID = :ID',
      Params
    );
    
    Result := Query.Fields[0].AsInteger > 0;
    
    Query.Free;
    Params.Free;
  except
    Result := False;
  end;
end;

{ ============================================================================
  LIMPEZA
  ============================================================================ }

function TPersistenciaCaixa.LimparTodosCaixas: Boolean;
var
  SQL: string;
begin
  Result := False;
  
  try
    SQL := 'DELETE FROM Caixas';
    Result := ExecutarSQL(SQL);
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao limpar caixas: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaCaixa.LimparCaixasAntigos(ADias: Integer): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  try
    SQL := 'DELETE FROM Caixas WHERE DATE(DataAbertura) < DATE(''now'', ''-' + IntToStr(ADias) + ' days'')';
    Result := ExecutarSQL(SQL);
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao limpar caixas antigos: ' + E.Message;
      Result := False;
    end;
  end;
end;

end.
