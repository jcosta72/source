unit uRepositorioOperador;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, FireDAC.Comp.Client,
  FireDAC.Stan.Param, Data.DB, uOperador, uCriptografiaSenha, uDMConexao;

type
  {$REGION 'Tipos e Constantes'}
  
  // Resultado de operações
  type
    TResultadoOperacao = record
      Sucesso: Boolean;
      Mensagem: string;
      RegistrosAfetados: Integer;
    end;
  
  {$ENDREGION}

  {$REGION 'Classe TRepositorioOperador'}
  
  /// <summary>
  /// Repositório para gerenciar operações CRUD da tabela Operadores
  /// Implementa padrão Repository com lógica de criptografia de senha
  /// </summary>
  TRepositorioOperador = class
  private
    FConexao: TFDConnection;
    FUltimoErro: string;
    
    /// <summary>Executar query e retornar resultado</summary>
    function ExecutarQuery(ASQL: string; AParams: TArray<TPair<string, Variant>>): TFDQuery;
    
    /// <summary>Converter DataSet para objeto TOperador</summary>
    function DataSetParaOperador(ADataSet: TDataSet): TOperador;
    
  public
    constructor Create;
    destructor Destroy; override;
    
    {$REGION 'Operações CRUD'}
    
    /// <summary>
    /// Inserir novo operador
    /// Criptografa a senha automaticamente com PBKDF2
    /// </summary>
    function Inserir(AOperador: TOperador): TResultadoOperacao;
    
    /// <summary>
    /// Obter operador por ID
    /// </summary>
    function ObterPorID(AOperadorID: Integer): TOperador;
    
    /// <summary>
    /// Obter operador por matrícula
    /// </summary>
    function ObterPorMatricula(AMatricula: string): TOperador;
    
    /// <summary>
    /// Obter todos os operadores
    /// </summary>
    function ObterTodos: TObjectList<TOperador>;
    
    /// <summary>
    /// Obter operadores ativos
    /// </summary>
    function ObterAtivos: TObjectList<TOperador>;
    
    /// <summary>
    /// Atualizar operador
    /// Se a senha for fornecida, criptografa automaticamente
    /// </summary>
    function Atualizar(AOperador: TOperador; AAtualizarSenha: Boolean = False): TResultadoOperacao;
    
    /// <summary>
    /// Deletar operador por ID
    /// </summary>
    function Deletar(AOperadorID: Integer): TResultadoOperacao;
    
    {$ENDREGION}
    
    {$REGION 'Operações de Autenticação'}
    
    /// <summary>
    /// Autenticar operador por matrícula e senha
    /// Valida a senha usando PBKDF2
    /// Registra tentativa de login em LogAcessoOperador
    /// </summary>
    function Autenticar(AMatricula: string; ASenha: string): TOperador;
    
    /// <summary>
    /// Alterar senha de um operador
    /// Criptografa a nova senha com PBKDF2
    /// </summary>
    function AlterarSenha(AOperadorID: Integer; ASenhaAtual: string; 
                         ASenhaNova: string): TResultadoOperacao;
    
    /// <summary>
    /// Resetar senha de um operador (admin)
    /// </summary>
    function ResetarSenha(AOperadorID: Integer; ASenhaTemporaria: string): TResultadoOperacao;
    
    /// <summary>
    /// Verificar se operador está ativo
    /// </summary>
    function EstaAtivo(AOperadorID: Integer): Boolean;
    
    /// <summary>
    /// Bloquear operador temporariamente (força bruta)
    /// </summary>
    function Bloquear(AOperadorID: Integer; AMinutos: Integer = 15): TResultadoOperacao;
    
    /// <summary>
    /// Desbloquear operador
    /// </summary>
    function Desbloquear(AOperadorID: Integer): TResultadoOperacao;
    
    {$ENDREGION}
    
    {$REGION 'Operações de Validação'}
    
    /// <summary>
    /// Verificar se matrícula já existe
    /// </summary>
    function MatriculaExiste(AMatricula: string; AExcluirID: Integer = 0): Boolean;
    
    /// <summary>
    /// Validar dados do operador
    /// </summary>
    function ValidarOperador(AOperador: TOperador): TResultadoOperacao;
    
    {$ENDREGION}
    
    {$REGION 'Operações de Relatório'}
    
    /// <summary>
    /// Obter quantidade de operadores
    /// </summary>
    function ObterQuantidade: Integer;
    
    /// <summary>
    /// Obter operador com mais vendas
    /// </summary>
    function ObterOperadorMaisVendas: TOperador;
    
    /// <summary>
    /// Obter último acesso de um operador
    /// </summary>
    function ObterUltimoAcesso(AOperadorID: Integer): TDateTime;
    
    {$ENDREGION}
    
    // Propriedades
    property UltimoErro: string read FUltimoErro;
  end;
  
  {$ENDREGION}

implementation

{$REGION 'Implementação TRepositorioOperador'}

constructor TRepositorioOperador.Create;
begin
  FConexao := DMConexao.Conexao;
  FUltimoErro := '';
end;

destructor TRepositorioOperador.Destroy;
begin
  inherited Destroy;
end;

function TRepositorioOperador.ExecutarQuery(ASQL: string; 
                                           AParams: TArray<TPair<string, Variant>>): TFDQuery;
var
  I: Integer;
begin
  Result := TFDQuery.Create(nil);
  try
    Result.Connection := FConexao;
    Result.SQL.Text := ASQL;
    
    // Definir parâmetros
    for I := 0 to High(AParams) do
      Result.ParamByName(AParams[I].Key).Value := AParams[I].Value;
  except
    on E: Exception do
    begin
      FUltimoErro := E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TRepositorioOperador.DataSetParaOperador(ADataSet: TDataSet): TOperador;
begin
  Result := TOperador.Create;
  try
    Result.ID := ADataSet.FieldByName('OperadorID').AsInteger;
    Result.Nome := ADataSet.FieldByName('Nome').AsString;
    Result.Matricula := ADataSet.FieldByName('Matricula').AsString;
    Result.Email := ADataSet.FieldByName('Email').AsString;
    Result.Telefone := ADataSet.FieldByName('Telefone').AsString;
    Result.Ativo := ADataSet.FieldByName('Ativo').AsBoolean;
    Result.DataCadastro := ADataSet.FieldByName('DataCadastro').AsDateTime;
    Result.DataUltimoAcesso := ADataSet.FieldByName('DataUltimoAcesso').AsDateTime;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao converter DataSet: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TRepositorioOperador.Inserir(AOperador: TOperador): TResultadoOperacao;
var
  SenhaHash: string;
  Query: TFDQuery;
begin
  Result.Sucesso := False;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  FUltimoErro := '';
  
  try
    // Validar operador
    Result := ValidarOperador(AOperador);
    if not Result.Sucesso then
      Exit;
    
    // Verificar se matrícula já existe
    if MatriculaExiste(AOperador.Matricula) then
    begin
      Result.Mensagem := 'Matrícula já cadastrada';
      FUltimoErro := Result.Mensagem;
      Exit;
    end;
    
    // Criptografar senha
    SenhaHash := TCriptografiaSenha.CriptografarSenha(AOperador.Senha);
    
    // Inserir operador
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'INSERT INTO Operadores (Nome, Matricula, SenhaHash, Email, Telefone, Ativo) ' +
        'VALUES (:Nome, :Matricula, :SenhaHash, :Email, :Telefone, :Ativo)';
      
      Query.ParamByName('Nome').AsString := AOperador.Nome;
      Query.ParamByName('Matricula').AsString := AOperador.Matricula;
      Query.ParamByName('SenhaHash').AsString := SenhaHash;
      Query.ParamByName('Email').AsString := AOperador.Email;
      Query.ParamByName('Telefone').AsString := AOperador.Telefone;
      Query.ParamByName('Ativo').AsBoolean := AOperador.Ativo;
      
      Query.ExecSQL;
      
      Result.Sucesso := True;
      Result.Mensagem := 'Operador inserido com sucesso';
      Result.RegistrosAfetados := Query.RowsAffected;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao inserir operador: ' + E.Message;
      FUltimoErro := Result.Mensagem;
    end;
  end;
end;

function TRepositorioOperador.ObterPorID(AOperadorID: Integer): TOperador;
var
  Query: TFDQuery;
begin
  Result := nil;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.Open;
      
      if not Query.Eof then
        Result := DataSetParaOperador(Query);
    finally
      Query.Free;
    end;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao obter operador: ' + E.Message;
  end;
end;

function TRepositorioOperador.ObterPorMatricula(AMatricula: string): TOperador;
var
  Query: TFDQuery;
begin
  Result := nil;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores WHERE Matricula = :Matricula';
      Query.ParamByName('Matricula').AsString := AMatricula;
      Query.Open;
      
      if not Query.Eof then
        Result := DataSetParaOperador(Query);
    finally
      Query.Free;
    end;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao obter operador: ' + E.Message;
  end;
end;

function TRepositorioOperador.ObterTodos: TObjectList<TOperador>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TOperador>.Create;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores ORDER BY Nome';
      Query.Open;
      
      while not Query.Eof do
      begin
        Result.Add(DataSetParaOperador(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter operadores: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TRepositorioOperador.ObterAtivos: TObjectList<TOperador>;
var
  Query: TFDQuery;
begin
  Result := TObjectList<TOperador>.Create;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores WHERE Ativo = 1 ORDER BY Nome';
      Query.Open;
      
      while not Query.Eof do
      begin
        Result.Add(DataSetParaOperador(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter operadores ativos: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TRepositorioOperador.Atualizar(AOperador: TOperador; 
                                       AAtualizarSenha: Boolean = False): TResultadoOperacao;
var
  Query: TFDQuery;
  SenhaHash: string;
begin
  Result.Sucesso := False;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      
      if AAtualizarSenha then
      begin
        // Atualizar com senha
        SenhaHash := TCriptografiaSenha.CriptografarSenha(AOperador.Senha);
        Query.SQL.Text := 
          'UPDATE Operadores SET Nome = :Nome, Email = :Email, Telefone = :Telefone, ' +
          'Ativo = :Ativo, SenhaHash = :SenhaHash WHERE OperadorID = :OperadorID';
        Query.ParamByName('SenhaHash').AsString := SenhaHash;
      end
      else
      begin
        // Atualizar sem senha
        Query.SQL.Text := 
          'UPDATE Operadores SET Nome = :Nome, Email = :Email, Telefone = :Telefone, ' +
          'Ativo = :Ativo WHERE OperadorID = :OperadorID';
      end;
      
      Query.ParamByName('Nome').AsString := AOperador.Nome;
      Query.ParamByName('Email').AsString := AOperador.Email;
      Query.ParamByName('Telefone').AsString := AOperador.Telefone;
      Query.ParamByName('Ativo').AsBoolean := AOperador.Ativo;
      Query.ParamByName('OperadorID').AsInteger := AOperador.ID;
      
      Query.ExecSQL;
      
      Result.Sucesso := True;
      Result.Mensagem := 'Operador atualizado com sucesso';
      Result.RegistrosAfetados := Query.RowsAffected;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao atualizar operador: ' + E.Message;
      FUltimoErro := Result.Mensagem;
    end;
  end;
end;

function TRepositorioOperador.Deletar(AOperadorID: Integer): TResultadoOperacao;
var
  Query: TFDQuery;
begin
  Result.Sucesso := False;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'DELETE FROM Operadores WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.ExecSQL;
      
      Result.Sucesso := True;
      Result.Mensagem := 'Operador deletado com sucesso';
      Result.RegistrosAfetados := Query.RowsAffected;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao deletar operador: ' + E.Message;
      FUltimoErro := Result.Mensagem;
    end;
  end;
end;

function TRepositorioOperador.Autenticar(AMatricula: string; 
                                        ASenha: string): TOperador;
var
  Operador: TOperador;
  Query: TFDQuery;
  SenhaHash: string;
begin
  Result := nil;
  FUltimoErro := '';
  
  try
    // Obter operador por matrícula
    Operador := ObterPorMatricula(AMatricula);
    
    if Operador = nil then
    begin
      FUltimoErro := 'Operador não encontrado';
      
      // Registrar tentativa falhada
      Query := TFDQuery.Create(nil);
      try
        Query.Connection := FConexao;
        Query.SQL.Text := 
          'INSERT INTO LogAcessoOperador (Matricula, Sucesso, Motivo) ' +
          'VALUES (:Matricula, :Sucesso, :Motivo)';
        Query.ParamByName('Matricula').AsString := AMatricula;
        Query.ParamByName('Sucesso').AsBoolean := False;
        Query.ParamByName('Motivo').AsString := 'OPERADOR_NAO_ENCONTRADO';
        Query.ExecSQL;
      finally
        Query.Free;
      end;
      
      Exit;
    end;
    
    // Verificar se está ativo
    if not Operador.Ativo then
    begin
      FUltimoErro := 'Operador inativo';
      Operador.Free;
      
      // Registrar tentativa falhada
      Query := TFDQuery.Create(nil);
      try
        Query.Connection := FConexao;
        Query.SQL.Text := 
          'INSERT INTO LogAcessoOperador (OperadorID, Matricula, Sucesso, Motivo) ' +
          'VALUES (:OperadorID, :Matricula, :Sucesso, :Motivo)';
        Query.ParamByName('OperadorID').AsInteger := Operador.ID;
        Query.ParamByName('Matricula').AsString := AMatricula;
        Query.ParamByName('Sucesso').AsBoolean := False;
        Query.ParamByName('Motivo').AsString := 'OPERADOR_INATIVO';
        Query.ExecSQL;
      finally
        Query.Free;
      end;
      
      Exit;
    end;
    
    // Obter hash armazenado
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT SenhaHash FROM Operadores WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := Operador.ID;
      Query.Open;
      
      if not Query.Eof then
        SenhaHash := Query.FieldByName('SenhaHash').AsString
      else
        SenhaHash := '';
    finally
      Query.Free;
    end;
    
    // Validar senha
    if not TCriptografiaSenha.ValidarSenha(ASenha, SenhaHash) then
    begin
      FUltimoErro := 'Senha incorreta';
      Operador.Free;
      
      // Registrar tentativa falhada
      Query := TFDQuery.Create(nil);
      try
        Query.Connection := FConexao;
        Query.SQL.Text := 
          'INSERT INTO LogAcessoOperador (OperadorID, Matricula, Sucesso, Motivo) ' +
          'VALUES (:OperadorID, :Matricula, :Sucesso, :Motivo)';
        Query.ParamByName('OperadorID').AsInteger := Operador.ID;
        Query.ParamByName('Matricula').AsString := AMatricula;
        Query.ParamByName('Sucesso').AsBoolean := False;
        Query.ParamByName('Motivo').AsString := 'SENHA_INCORRETA';
        Query.ExecSQL;
      finally
        Query.Free;
      end;
      
      Exit;
    end;
    
    // Atualizar último acesso
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'UPDATE Operadores SET DataUltimoAcesso = CURRENT_TIMESTAMP ' +
        'WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := Operador.ID;
      Query.ExecSQL;
    finally
      Query.Free;
    end;
    
    // Registrar login bem-sucedido
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'INSERT INTO LogAcessoOperador (OperadorID, Matricula, Sucesso, Motivo) ' +
        'VALUES (:OperadorID, :Matricula, :Sucesso, :Motivo)';
      Query.ParamByName('OperadorID').AsInteger := Operador.ID;
      Query.ParamByName('Matricula').AsString := AMatricula;
      Query.ParamByName('Sucesso').AsBoolean := True;
      Query.ParamByName('Motivo').AsString := 'LOGIN_SUCESSO';
      Query.ExecSQL;
    finally
      Query.Free;
    end;
    
    Result := Operador;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao autenticar: ' + E.Message;
      if Assigned(Operador) then
        Operador.Free;
    end;
  end;
end;

function TRepositorioOperador.AlterarSenha(AOperadorID: Integer; ASenhaAtual: string; 
                                          ASenhaNova: string): TResultadoOperacao;
var
  Operador: TOperador;
  Query: TFDQuery;
  SenhaHashAtual: string;
  SenhaHashNova: string;
begin
  Result.Sucesso := False;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  FUltimoErro := '';
  
  try
    // Obter operador
    Operador := ObterPorID(AOperadorID);
    
    if Operador = nil then
    begin
      Result.Mensagem := 'Operador não encontrado';
      FUltimoErro := Result.Mensagem;
      Exit;
    end;
    
    // Obter hash atual
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT SenhaHash FROM Operadores WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.Open;
      
      if not Query.Eof then
        SenhaHashAtual := Query.FieldByName('SenhaHash').AsString
      else
        SenhaHashAtual := '';
    finally
      Query.Free;
    end;
    
    // Validar senha atual
    if not TCriptografiaSenha.ValidarSenha(ASenhaAtual, SenhaHashAtual) then
    begin
      Result.Mensagem := 'Senha atual incorreta';
      FUltimoErro := Result.Mensagem;
      Operador.Free;
      Exit;
    end;
    
    // Criptografar nova senha
    SenhaHashNova := TCriptografiaSenha.CriptografarSenha(ASenhaNova);
    
    // Atualizar senha
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'UPDATE Operadores SET SenhaHash = :SenhaHash WHERE OperadorID = :OperadorID';
      Query.ParamByName('SenhaHash').AsString := SenhaHashNova;
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.ExecSQL;
      
      Result.Sucesso := True;
      Result.Mensagem := 'Senha alterada com sucesso';
      Result.RegistrosAfetados := Query.RowsAffected;
    finally
      Query.Free;
    end;
    
    Operador.Free;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao alterar senha: ' + E.Message;
      FUltimoErro := Result.Mensagem;
    end;
  end;
end;

function TRepositorioOperador.ResetarSenha(AOperadorID: Integer; 
                                          ASenhaTemporaria: string): TResultadoOperacao;
var
  Query: TFDQuery;
  SenhaHash: string;
begin
  Result.Sucesso := False;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  FUltimoErro := '';
  
  try
    // Criptografar senha temporária
    SenhaHash := TCriptografiaSenha.CriptografarSenha(ASenhaTemporaria);
    
    // Atualizar senha
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'UPDATE Operadores SET SenhaHash = :SenhaHash WHERE OperadorID = :OperadorID';
      Query.ParamByName('SenhaHash').AsString := SenhaHash;
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.ExecSQL;
      
      Result.Sucesso := True;
      Result.Mensagem := 'Senha resetada com sucesso. Senha temporária: ' + ASenhaTemporaria;
      Result.RegistrosAfetados := Query.RowsAffected;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao resetar senha: ' + E.Message;
      FUltimoErro := Result.Mensagem;
    end;
  end;
end;

function TRepositorioOperador.EstaAtivo(AOperadorID: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT Ativo FROM Operadores WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.Open;
      
      if not Query.Eof then
        Result := Query.FieldByName('Ativo').AsBoolean;
    finally
      Query.Free;
    end;
  except
    Result := False;
  end;
end;

function TRepositorioOperador.Bloquear(AOperadorID: Integer; 
                                      AMinutos: Integer = 15): TResultadoOperacao;
var
  Query: TFDQuery;
begin
  Result.Sucesso := False;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'UPDATE Operadores SET BloqueadoAte = datetime(''now'', ''+' + 
        IntToStr(AMinutos) + ' minutes'') WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.ExecSQL;
      
      Result.Sucesso := True;
      Result.Mensagem := 'Operador bloqueado por ' + IntToStr(AMinutos) + ' minutos';
      Result.RegistrosAfetados := Query.RowsAffected;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao bloquear operador: ' + E.Message;
      FUltimoErro := Result.Mensagem;
    end;
  end;
end;

function TRepositorioOperador.Desbloquear(AOperadorID: Integer): TResultadoOperacao;
var
  Query: TFDQuery;
begin
  Result.Sucesso := False;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  FUltimoErro := '';
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'UPDATE Operadores SET BloqueadoAte = NULL, TentativasLoginFalhadas = 0 ' +
        'WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.ExecSQL;
      
      Result.Sucesso := True;
      Result.Mensagem := 'Operador desbloqueado com sucesso';
      Result.RegistrosAfetados := Query.RowsAffected;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao desbloquear operador: ' + E.Message;
      FUltimoErro := Result.Mensagem;
    end;
  end;
end;

function TRepositorioOperador.MatriculaExiste(AMatricula: string; 
                                             AExcluirID: Integer = 0): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      
      if AExcluirID > 0 then
        Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Operadores ' +
                         'WHERE Matricula = :Matricula AND OperadorID <> :OperadorID'
      else
        Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Operadores ' +
                         'WHERE Matricula = :Matricula';
      
      Query.ParamByName('Matricula').AsString := AMatricula;
      
      if AExcluirID > 0 then
        Query.ParamByName('OperadorID').AsInteger := AExcluirID;
      
      Query.Open;
      
      Result := Query.FieldByName('Total').AsInteger > 0;
    finally
      Query.Free;
    end;
  except
    Result := False;
  end;
end;

function TRepositorioOperador.ValidarOperador(AOperador: TOperador): TResultadoOperacao;
begin
  Result.Sucesso := True;
  Result.Mensagem := '';
  Result.RegistrosAfetados := 0;
  
  // Validar nome
  if Trim(AOperador.Nome) = '' then
  begin
    Result.Sucesso := False;
    Result.Mensagem := 'Nome não pode estar vazio';
    Exit;
  end;
  
  if Length(AOperador.Nome) < 3 then
  begin
    Result.Sucesso := False;
    Result.Mensagem := 'Nome deve ter no mínimo 3 caracteres';
    Exit;
  end;
  
  // Validar matrícula
  if Trim(AOperador.Matricula) = '' then
  begin
    Result.Sucesso := False;
    Result.Mensagem := 'Matrícula não pode estar vazia';
    Exit;
  end;
  
  if Length(AOperador.Matricula) < 3 then
  begin
    Result.Sucesso := False;
    Result.Mensagem := 'Matrícula deve ter no mínimo 3 caracteres';
    Exit;
  end;
  
  // Validar senha
  if Trim(AOperador.Senha) = '' then
  begin
    Result.Sucesso := False;
    Result.Mensagem := 'Senha não pode estar vazia';
    Exit;
  end;
  
  if Length(AOperador.Senha) < 4 then
  begin
    Result.Sucesso := False;
    Result.Mensagem := 'Senha deve ter no mínimo 4 caracteres';
    Exit;
  end;
end;

function TRepositorioOperador.ObterQuantidade: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Operadores';
      Query.Open;
      
      Result := Query.FieldByName('Total').AsInteger;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TRepositorioOperador.ObterOperadorMaisVendas: TOperador;
var
  Query: TFDQuery;
begin
  Result := nil;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'SELECT o.* FROM Operadores o ' +
        'LEFT JOIN Vendas v ON o.OperadorID = v.OperadorID ' +
        'GROUP BY o.OperadorID ' +
        'ORDER BY COUNT(v.VendaID) DESC ' +
        'LIMIT 1';
      Query.Open;
      
      if not Query.Eof then
        Result := DataSetParaOperador(Query);
    finally
      Query.Free;
    end;
  except
    Result := nil;
  end;
end;

function TRepositorioOperador.ObterUltimoAcesso(AOperadorID: Integer): TDateTime;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 
        'SELECT DataUltimoAcesso FROM Operadores WHERE OperadorID = :OperadorID';
      Query.ParamByName('OperadorID').AsInteger := AOperadorID;
      Query.Open;
      
      if not Query.Eof then
        Result := Query.FieldByName('DataUltimoAcesso').AsDateTime;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

{$ENDREGION}

end.
