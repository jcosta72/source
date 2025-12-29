unit uRepositorioCaixaPersistencia;

interface

uses
  System.SysUtils, System.Generics.Collections, System.DateUtils,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  uCaixa, uOperador, uDMConexao;

type
  { Classe para persistência de caixas em banco de dados }
  TRepositorioCaixaPersistencia = class
  private
    FConexao: TFDConnection;
    FUltimoErro: string;
    
    function ExecutarSQL(ASQL: string; AParams: TFDParams = nil): Boolean;
    function ObterValorSQL(ASQL: string; AParams: TFDParams = nil): Variant;
  public
    constructor Create(AConexao: TFDConnection);
    destructor Destroy; override;
    
    { ========== OPERAÇÕES COM CAIXAS ========== }
    
    { Salvar caixa no banco }
    function SalvarCaixa(ACaixa: TCaixa): Boolean;
    
    { Atualizar caixa no banco }
    function AtualizarCaixa(ACaixa: TCaixa): Boolean;
    
    { Deletar caixa do banco }
    function DeletarCaixa(ACaixaID: Integer): Boolean;
    
    { Obter caixa do banco }
    function ObterCaixa(ACaixaID: Integer): TCaixa;
    
    { ========== OPERAÇÕES COM MOVIMENTAÇÕES ========== }
    
    { Salvar movimentação no banco }
    function SalvarMovimentacao(ACaixaID: Integer; ATipo: string; 
      AValor: Double; AMotivo, AOperador: string): Boolean;
    
    { Obter movimentações do caixa }
    function ObterMovimentacoes(ACaixaID: Integer): TObjectList<TMovimentacao>;
    
    { ========== OPERAÇÕES COM FECHAMENTOS ========== }
    
    { Salvar fechamento no banco }
    function SalvarFechamento(ACaixa: TCaixa; AOperadorID: Integer): Boolean;
    
    { Obter fechamento do caixa }
    function ObterFechamento(ACaixaID: Integer): string;
    
    { ========== CONSULTAS ========== }
    
    { Obter caixas abertos }
    function ObterCaixasAbertos: TObjectList<TCaixa>;
    
    { Obter caixas fechados }
    function ObterCaixasFechados: TObjectList<TCaixa>;
    
    { Obter caixa aberto do operador }
    function ObterCaixaAbertoOperador(AOperadorID: Integer): TCaixa;
    
    { Obter caixas por data }
    function ObterCaixasPorData(AData: TDateTime): TObjectList<TCaixa>;
    
    { Obter caixas por operador }
    function ObterCaixasPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
    
    { ========== ESTATÍSTICAS ========== }
    
    { Obter total de vendas }
    function ObterTotalVendas: Double;
    
    { Obter total de sangrias }
    function ObterTotalSangrias: Double;
    
    { Obter total de suprimentos }
    function ObterTotalSuprimentos: Double;
    
    { Obter resumo geral }
    function ObterResumoGeral: string;
    
    { ========== VALIDAÇÕES ========== }
    
    { Verificar se existe caixa aberto }
    function TemCaixaAberto: Boolean;
    
    { Verificar se existe caixa aberto do operador }
    function TemCaixaAbertoOperador(AOperadorID: Integer): Boolean;
    
    { ========== PROPRIEDADES ========== }
    
    property UltimoErro: string read FUltimoErro;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TRepositorioCaixaPersistencia.Create(AConexao: TFDConnection);
begin
  inherited Create;
  FConexao := AConexao;
  FUltimoErro := '';
end;

destructor TRepositorioCaixaPersistencia.Destroy;
begin
  inherited;
end;

{ ============================================================================
  MÉTODOS PRIVADOS
  ============================================================================ }

function TRepositorioCaixaPersistencia.ExecutarSQL(ASQL: string; 
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

function TRepositorioCaixaPersistencia.ObterValorSQL(ASQL: string; 
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

{ ============================================================================
  OPERAÇÕES COM CAIXAS
  ============================================================================ }

function TRepositorioCaixaPersistencia.SalvarCaixa(ACaixa: TCaixa): Boolean;
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
      'QuantidadeVendas, QuantidadeProdutos, TotalDinheiro, TotalCartao, TotalPIX, Status) ' +
      'VALUES (:OperadorID, :DataAbertura, :SaldoInicial, :TotalVendas, ' +
      ':TotalDesconto, :TotalAcrescimo, :TotalSangria, :TotalSuprimento, ' +
      ':QuantidadeVendas, :QuantidadeProdutos, :TotalDinheiro, :TotalCartao, :TotalPIX, :Status)';
    
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

function TRepositorioCaixaPersistencia.AtualizarCaixa(ACaixa: TCaixa): Boolean;
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

function TRepositorioCaixaPersistencia.DeletarCaixa(ACaixaID: Integer): Boolean;
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

function TRepositorioCaixaPersistencia.ObterCaixa(ACaixaID: Integer): TCaixa;
var
  Query: TFDQuery;
  Caixa: TCaixa;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Caixas WHERE ID = :ID';
    Query.ParamByName('ID').Value := ACaixaID;
    Query.Open;
    
    if not Query.Eof then
    begin
      Caixa := TCaixa.Create(
        Query.FieldByName('ID').AsInteger,
        nil,  // Operador será carregado separadamente
        Query.FieldByName('SaldoInicial').AsFloat
      );
      
      Caixa.FDataAbertura := Query.FieldByName('DataAbertura').AsDateTime;
      if not Query.FieldByName('DataFechamento').IsNull then
        Caixa.FDataFechamento := Query.FieldByName('DataFechamento').AsDateTime;
      
      Result := Caixa;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter caixa: ' + E.Message;
      Result := nil;
    end;
  end;
  Query.Free;
end;

{ ============================================================================
  OPERAÇÕES COM MOVIMENTAÇÕES
  ============================================================================ }

function TRepositorioCaixaPersistencia.SalvarMovimentacao(ACaixaID: Integer; 
  ATipo: string; AValor: Double; AMotivo, AOperador: string): Boolean;
var
  SQL: string;
  Params: TFDParams;
begin
  Result := False;
  
  try
    SQL := 'INSERT INTO Movimentacoes (CaixaID, OperadorID, Tipo, Valor, Motivo) ' +
      'VALUES (:CaixaID, (SELECT ID FROM Operadores WHERE Nome = :Operador), :Tipo, :Valor, :Motivo)';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixaID;
      Params.CreateParam(ftString, 'Operador', ptInput).Value := AOperador;
      Params.CreateParam(ftString, 'Tipo', ptInput).Value := ATipo;
      Params.CreateParam(ftFloat, 'Valor', ptInput).Value := AValor;
      Params.CreateParam(ftString, 'Motivo', ptInput).Value := AMotivo;
      
      Result := ExecutarSQL(SQL, Params);
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

function TRepositorioCaixaPersistencia.ObterMovimentacoes(ACaixaID: Integer): TObjectList<TMovimentacao>;
var
  Query: TFDQuery;
  Movimentacoes: TObjectList<TMovimentacao>;
  Movimentacao: TMovimentacao;
begin
  Movimentacoes := TObjectList<TMovimentacao>.Create;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Movimentacoes WHERE CaixaID = :CaixaID ORDER BY Data';
    Query.ParamByName('CaixaID').Value := ACaixaID;
    Query.Open;
    
    while not Query.Eof do
    begin
      Movimentacao := TMovimentacao.Create(
        Query.FieldByName('ID').AsInteger,
        TTipoMovimentacao(Ord(Query.FieldByName('Tipo').AsString = 'Suprimento')),
        Query.FieldByName('Valor').AsFloat,
        Query.FieldByName('Motivo').AsString,
        Query.FieldByName('Operador').AsString
      );
      
      Movimentacoes.Add(Movimentacao);
      Query.Next;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter movimentações: ' + E.Message;
      Movimentacoes.Free;
      Movimentacoes := TObjectList<TMovimentacao>.Create;
    end;
  end;
  Query.Free;
  Result := Movimentacoes;
end;

{ ============================================================================
  OPERAÇÕES COM FECHAMENTOS
  ============================================================================ }

function TRepositorioCaixaPersistencia.SalvarFechamento(ACaixa: TCaixa; 
  AOperadorID: Integer): Boolean;
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
    SQL := 'INSERT INTO Fechamentos (' +
      'CaixaID, OperadorID, DataFechamento, SaldoInicial, SaldoFinal, Diferenca, ' +
      'TotalVendas, TotalDesconto, TotalAcrescimo, TotalSangria, TotalSuprimento, ' +
      'TotalDinheiro, TotalCartao, TotalPIX, QuantidadeVendas, QuantidadeProdutos, ' +
      'QuantidadeSangrias, QuantidadeSuprimentos) ' +
      'VALUES (:CaixaID, :OperadorID, CURRENT_TIMESTAMP, :SaldoInicial, :SaldoFinal, :Diferenca, ' +
      ':TotalVendas, :TotalDesconto, :TotalAcrescimo, :TotalSangria, :TotalSuprimento, ' +
      ':TotalDinheiro, :TotalCartao, :TotalPIX, :QuantidadeVendas, :QuantidadeProdutos, ' +
      ':QuantidadeSangrias, :QuantidadeSuprimentos)';
    
    Params := TFDParams.Create;
    try
      Params.CreateParam(ftInteger, 'CaixaID', ptInput).Value := ACaixa.ID;
      Params.CreateParam(ftInteger, 'OperadorID', ptInput).Value := AOperadorID;
      Params.CreateParam(ftFloat, 'SaldoInicial', ptInput).Value := ACaixa.SaldoInicial;
      Params.CreateParam(ftFloat, 'SaldoFinal', ptInput).Value := ACaixa.SaldoFinal;
      Params.CreateParam(ftFloat, 'Diferenca', ptInput).Value := ACaixa.Diferenca;
      Params.CreateParam(ftFloat, 'TotalVendas', ptInput).Value := ACaixa.TotalVendas;
      Params.CreateParam(ftFloat, 'TotalDesconto', ptInput).Value := ACaixa.TotalDesconto;
      Params.CreateParam(ftFloat, 'TotalAcrescimo', ptInput).Value := ACaixa.TotalAcrescimo;
      Params.CreateParam(ftFloat, 'TotalSangria', ptInput).Value := ACaixa.TotalSangria;
      Params.CreateParam(ftFloat, 'TotalSuprimento', ptInput).Value := ACaixa.TotalSuprimento;
      Params.CreateParam(ftFloat, 'TotalDinheiro', ptInput).Value := ACaixa.TotalDinheiro;
      Params.CreateParam(ftFloat, 'TotalCartao', ptInput).Value := ACaixa.TotalCartao;
      Params.CreateParam(ftFloat, 'TotalPIX', ptInput).Value := ACaixa.TotalPIX;
      Params.CreateParam(ftInteger, 'QuantidadeVendas', ptInput).Value := ACaixa.QuantidadeVendas;
      Params.CreateParam(ftInteger, 'QuantidadeProdutos', ptInput).Value := ACaixa.QuantidadeProdutos;
      Params.CreateParam(ftInteger, 'QuantidadeSangrias', ptInput).Value := 0;  // TODO: Calcular
      Params.CreateParam(ftInteger, 'QuantidadeSuprimentos', ptInput).Value := 0; // TODO: Calcular
      
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

function TRepositorioCaixaPersistencia.ObterFechamento(ACaixaID: Integer): string;
var
  Query: TFDQuery;
begin
  Result := '';
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Fechamentos WHERE CaixaID = :CaixaID';
    Query.ParamByName('CaixaID').Value := ACaixaID;
    Query.Open;
    
    if not Query.Eof then
    begin
      Result := 'Caixa ID: ' + Query.FieldByName('CaixaID').AsString + sLineBreak +
                'Saldo Inicial: R$ ' + FormatFloat('0.00', Query.FieldByName('SaldoInicial').AsFloat) + sLineBreak +
                'Saldo Final: R$ ' + FormatFloat('0.00', Query.FieldByName('SaldoFinal').AsFloat) + sLineBreak +
                'Diferença: R$ ' + FormatFloat('0.00', Query.FieldByName('Diferenca').AsFloat);
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter fechamento: ' + E.Message;
      Result := '';
    end;
  end;
  Query.Free;
end;

{ ============================================================================
  CONSULTAS
  ============================================================================ }

function TRepositorioCaixaPersistencia.ObterCaixasAbertos: TObjectList<TCaixa>;
begin
  Result := TObjectList<TCaixa>.Create;
  // TODO: Implementar
end;

function TRepositorioCaixaPersistencia.ObterCaixasFechados: TObjectList<TCaixa>;
begin
  Result := TObjectList<TCaixa>.Create;
  // TODO: Implementar
end;

function TRepositorioCaixaPersistencia.ObterCaixaAbertoOperador(AOperadorID: Integer): TCaixa;
begin
  Result := nil;
  // TODO: Implementar
end;

function TRepositorioCaixaPersistencia.ObterCaixasPorData(AData: TDateTime): TObjectList<TCaixa>;
begin
  Result := TObjectList<TCaixa>.Create;
  // TODO: Implementar
end;

function TRepositorioCaixaPersistencia.ObterCaixasPorOperador(AOperadorID: Integer): TObjectList<TCaixa>;
begin
  Result := TObjectList<TCaixa>.Create;
  // TODO: Implementar
end;

{ ============================================================================
  ESTATÍSTICAS
  ============================================================================ }

function TRepositorioCaixaPersistencia.ObterTotalVendas: Double;
begin
  Result := VarAsType(ObterValorSQL('SELECT SUM(TotalVendas) FROM Caixas'), varDouble);
  if VarIsNull(Result) then
    Result := 0;
end;

function TRepositorioCaixaPersistencia.ObterTotalSangrias: Double;
begin
  Result := VarAsType(ObterValorSQL('SELECT SUM(Valor) FROM Movimentacoes WHERE Tipo = ''Sangria'''), varDouble);
  if VarIsNull(Result) then
    Result := 0;
end;

function TRepositorioCaixaPersistencia.ObterTotalSuprimentos: Double;
begin
  Result := VarAsType(ObterValorSQL('SELECT SUM(Valor) FROM Movimentacoes WHERE Tipo = ''Suprimento'''), varDouble);
  if VarIsNull(Result) then
    Result := 0;
end;

function TRepositorioCaixaPersistencia.ObterResumoGeral: string;
begin
  Result := '';
  Result := Result + '╔════════════════════════════════════════════════════════════╗' + sLineBreak;
  Result := Result + '║              RESUMO GERAL DE CAIXAS                        ║' + sLineBreak;
  Result := Result + '╚════════════════════════════════════════════════════════════╝' + sLineBreak;
  Result := Result + sLineBreak;
  
  Result := Result + 'Total de Vendas: R$ ' + FormatFloat('0.00', ObterTotalVendas) + sLineBreak;
  Result := Result + 'Total de Sangrias: R$ ' + FormatFloat('0.00', ObterTotalSangrias) + sLineBreak;
  Result := Result + 'Total de Suprimentos: R$ ' + FormatFloat('0.00', ObterTotalSuprimentos) + sLineBreak;
end;

{ ============================================================================
  VALIDAÇÕES
  ============================================================================ }

function TRepositorioCaixaPersistencia.TemCaixaAberto: Boolean;
var
  Resultado: Variant;
begin
  Resultado := ObterValorSQL('SELECT COUNT(*) FROM Caixas WHERE Status = ''Aberto''');
  Result := VarAsType(Resultado, varInteger) > 0;
end;

function TRepositorioCaixaPersistencia.TemCaixaAbertoOperador(AOperadorID: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT COUNT(*) FROM Caixas WHERE OperadorID = :OperadorID AND Status = ''Aberto''';
    Query.ParamByName('OperadorID').Value := AOperadorID;
    Query.Open;
    
    Result := Query.Fields[0].AsInteger > 0;
  except
    Result := False;
  end;
  Query.Free;
end;

end.
