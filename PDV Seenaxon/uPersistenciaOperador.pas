unit uPersistenciaOperador;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  uOperador, uCriptografiaSenha, uDMConexao;

type
  { Classe de persistência de operadores }
  TPersistenciaOperador = class
  private
    FConexao: TFDConnection;
    FUltimoErro: string;
    
    function ValidarOperador(AOperador: TOperador): Boolean;
    function ExecutarSQL(ASQL: string; AParams: array of const): Boolean;
  public
    constructor Create(AConexao: TFDConnection);
    destructor Destroy; override;
    
    { ========== CRUD ========== }
    
    { Salvar novo operador }
    function SalvarOperador(AOperador: TOperador): Boolean;
    
    { Atualizar operador existente }
    function AtualizarOperador(AOperador: TOperador): Boolean;
    
    { Deletar operador }
    function DeletarOperador(AID: Integer): Boolean;
    
    { Obter operador por ID }
    function ObterOperadorPorID(AID: Integer): TOperador;
    
    { Obter operador por matrícula }
    function ObterOperadorPorMatricula(AMatricula: string): TOperador;
    
    { Obter todos os operadores }
    function ObterTodosOperadores: TObjectList<TOperador>;
    
    { Obter operadores ativos }
    function ObterOperadoresAtivos: TObjectList<TOperador>;
    
    { Obter operadores inativos }
    function ObterOperadoresInativos: TObjectList<TOperador>;
    
    { ========== AUTENTICAÇÃO ========== }
    
    { Autenticar operador com matrícula e senha }
    function AutenticarOperador(AMatricula: string; ASenha: string): TOperador;
    
    { Validar se operador está ativo }
    function OperadorEstaAtivo(AID: Integer): Boolean;
    
    { Validar se operador está bloqueado }
    function OperadorEstaBloqueado(AID: Integer): Boolean;
    
    { ========== OPERAÇÕES DE SEGURANÇA ========== }
    
    { Alterar senha do operador }
    function AlterarSenha(AID: Integer; ASenhaAtual: string; ASenhaNova: string): Boolean;
    
    { Resetar senha do operador }
    function ResetarSenha(AID: Integer; ASenhaPadrao: string): Boolean;
    
    { Bloquear operador }
    function BloquearOperador(AID: Integer): Boolean;
    
    { Desbloquear operador }
    function DesbloqueiarOperador(AID: Integer): Boolean;
    
    { Ativar operador }
    function AtivarOperador(AID: Integer): Boolean;
    
    { Desativar operador }
    function DesativarOperador(AID: Integer): Boolean;
    
    { ========== AUDITORIA ========== }
    
    { Registrar login bem-sucedido }
    function RegistrarLoginSucesso(AOperadorID: Integer): Boolean;
    
    { Registrar tentativa de login falhada }
    function RegistrarLoginFalha(AMatricula: string; AMotivo: string): Boolean;
    
    { Obter histórico de logins }
    function ObterHistoricoLogins(AOperadorID: Integer; AUltimos: Integer = 10): TStringList;
    
    { ========== ESTATÍSTICAS ========== }
    
    { Obter quantidade de operadores }
    function ObterQuantidadeOperadores: Integer;
    
    { Obter quantidade de operadores ativos }
    function ObterQuantidadeOperadoresAtivos: Integer;
    
    { Obter quantidade de operadores inativos }
    function ObterQuantidadeOperadoresInativos: Integer;
    
    { Obter operador com mais vendas }
    function ObterOperadorComMaisVendas: TOperador;
    
    { Obter operador com melhor ticket médio }
    function ObterOperadorComMelhorTicket: TOperador;
    
    { ========== PROPRIEDADES ========== }
    
    property UltimoErro: string read FUltimoErro;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TPersistenciaOperador.Create(AConexao: TFDConnection);
begin
  inherited Create;
  FConexao := AConexao;
  FUltimoErro := '';
end;

destructor TPersistenciaOperador.Destroy;
begin
  inherited;
end;

{ ============================================================================
  MÉTODOS AUXILIARES
  ============================================================================ }

function TPersistenciaOperador.ValidarOperador(AOperador: TOperador): Boolean;
begin
  Result := True;
  
  { Validar nome }
  if Trim(AOperador.Nome) = '' then
  begin
    FUltimoErro := 'Nome do operador é obrigatório';
    Result := False;
    Exit;
  end;
  
  { Validar matrícula }
  if Trim(AOperador.Matricula) = '' then
  begin
    FUltimoErro := 'Matrícula do operador é obrigatória';
    Result := False;
    Exit;
  end;
  
  { Validar senha }
  if Trim(AOperador.Senha) = '' then
  begin
    FUltimoErro := 'Senha do operador é obrigatória';
    Result := False;
    Exit;
  end;
end;

function TPersistenciaOperador.ExecutarSQL(ASQL: string; AParams: array of const): Boolean;
var
  Query: TFDQuery;
  i: Integer;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := ASQL;

      { Adicionar parâmetros }
      for i := 0 to Length(AParams) - 1 do
      begin
        case AParams[i].VType of
          vtInteger:
            Query.ParamByName('P' + IntToStr(i + 1)).AsInteger := AParams[i].VInteger;
          vtString:
            Query.ParamByName('P' + IntToStr(i + 1)).AsString := string(AParams[i].VString);
          vtExtended:
            Query.ParamByName('P' + IntToStr(i + 1)).AsFloat := AParams[i].VExtended^;
        end;
      end;

      { Executar }
      Query.ExecSQL;

      Result := True;
      FUltimoErro := '';
    except on E: Exception do
      begin
        FUltimoErro := 'Erro ao executar SQL: ' + E.Message;
        Result := False;
      end;
    end;
  finally
    Query.Free;
  end;
end;

{ ============================================================================
  CRUD
  ============================================================================ }

function TPersistenciaOperador.SalvarOperador(AOperador: TOperador): Boolean;
var
  SenhaHash: string;
begin
  Result := False;
  
  try
    { Validar operador }
    if not ValidarOperador(AOperador) then
      Exit;
    
    { Criptografar senha }
    SenhaHash := TCriptografiaSenha.CriptografarSenha(AOperador.Senha);
    
    { SQL de inserção }
    if ExecutarSQL(
      'INSERT INTO Operadores (Nome, Matricula, Senha, Ativo, DataCadastro) ' +
      'VALUES (:P1, :P2, :P3, :P4, :P5)',
      [AOperador.Nome, AOperador.Matricula, SenhaHash, 1, Now]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.AtualizarOperador(AOperador: TOperador): Boolean;
var
  SenhaHash: string;
begin
  Result := False;
  
  try
    { Validar operador }
    if not ValidarOperador(AOperador) then
      Exit;
    
    { Criptografar senha }
    SenhaHash := TCriptografiaSenha.CriptografarSenha(AOperador.Senha);
    
    { SQL de atualização }
    if ExecutarSQL(
      'UPDATE Operadores SET Nome = :P1, Matricula = :P2, Senha = :P3, Ativo = :P4, DataAtualizacao = :P5 WHERE ID = :P6',
      [AOperador.Nome, AOperador.Matricula, SenhaHash, Ord(AOperador.Ativo), Now, AOperador.ID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao atualizar operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.DeletarOperador(AID: Integer): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL('DELETE FROM Operadores WHERE ID = :P1', [AID]) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.ObterOperadorPorID(AID: Integer): TOperador;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);

  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores WHERE ID = :P1';
      Query.ParamByName('P1').AsInteger := AID;
      Query.Open;

      if not Query.Eof then
      begin
        Result := TOperador.Create;
        Result.ID := Query.FieldByName('ID').AsInteger;
        Result.Nome := Query.FieldByName('Nome').AsString;
        Result.Matricula := Query.FieldByName('Matricula').AsString;
        Result.Senha := Query.FieldByName('Senha').AsString;
        Result.Ativo := Query.FieldByName('Ativo').AsBoolean;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter operador: ' + E.Message;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterOperadorPorMatricula(AMatricula: string): TOperador;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);

  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores WHERE Matricula = :P1';
      Query.ParamByName('P1').AsString := AMatricula;
      Query.Open;

      if not Query.Eof then
      begin
        Result := TOperador.Create;
        Result.ID := Query.FieldByName('ID').AsInteger;
        Result.Nome := Query.FieldByName('Nome').AsString;
        Result.Matricula := Query.FieldByName('Matricula').AsString;
        Result.Senha := Query.FieldByName('Senha').AsString;
        Result.Ativo := Query.FieldByName('Ativo').AsBoolean;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter operador: ' + E.Message;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterTodosOperadores: TObjectList<TOperador>;
var
  Query: TFDQuery;
  Operador: TOperador;
begin
  Result := TObjectList<TOperador>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores ORDER BY Nome';
      Query.Open;

      while not Query.Eof do
      begin
        Operador := TOperador.Create;
        Operador.ID := Query.FieldByName('ID').AsInteger;
        Operador.Nome := Query.FieldByName('Nome').AsString;
        Operador.Matricula := Query.FieldByName('Matricula').AsString;
        Operador.Senha := Query.FieldByName('Senha').AsString;
        Operador.Ativo := Query.FieldByName('Ativo').AsBoolean;

        Result.Add(Operador);
        Query.Next;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter operadores: ' + E.Message;
        Result.Free;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterOperadoresAtivos: TObjectList<TOperador>;
var
  Query: TFDQuery;
  Operador: TOperador;
begin
  Result := TObjectList<TOperador>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores WHERE Ativo = 1 ORDER BY Nome';
      Query.Open;

      while not Query.Eof do
      begin
        Operador := TOperador.Create;
        Operador.ID := Query.FieldByName('ID').AsInteger;
        Operador.Nome := Query.FieldByName('Nome').AsString;
        Operador.Matricula := Query.FieldByName('Matricula').AsString;
        Operador.Senha := Query.FieldByName('Senha').AsString;
        Operador.Ativo := Query.FieldByName('Ativo').AsBoolean;

        Result.Add(Operador);
        Query.Next;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter operadores ativos: ' + E.Message;
        Result.Free;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterOperadoresInativos: TObjectList<TOperador>;
var
  Query: TFDQuery;
  Operador: TOperador;
begin
  Result := TObjectList<TOperador>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Operadores WHERE Ativo = 0 ORDER BY Nome';
      Query.Open;

      while not Query.Eof do
      begin
        Operador := TOperador.Create;
        Operador.ID := Query.FieldByName('ID').AsInteger;
        Operador.Nome := Query.FieldByName('Nome').AsString;
        Operador.Matricula := Query.FieldByName('Matricula').AsString;
        Operador.Senha := Query.FieldByName('Senha').AsString;
        Operador.Ativo := Query.FieldByName('Ativo').AsBoolean;

        Result.Add(Operador);
        Query.Next;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter operadores inativos: ' + E.Message;
        Result.Free;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

{ ============================================================================
  AUTENTICAÇÃO
  ============================================================================ }

function TPersistenciaOperador.AutenticarOperador(AMatricula: string; ASenha: string): TOperador;
var
  Operador: TOperador;
begin
  Result := nil;
  
  try
    { Obter operador por matrícula }
    Operador := ObterOperadorPorMatricula(AMatricula);
    
    if not Assigned(Operador) then
    begin
      FUltimoErro := 'Operador não encontrado';
      RegistrarLoginFalha(AMatricula, 'Operador não encontrado');
      Exit;
    end;
    
    { Verificar se está ativo }
    if not Operador.Ativo then
    begin
      FUltimoErro := 'Operador inativo';
      RegistrarLoginFalha(AMatricula, 'Operador inativo');
      Operador.Free;
      Exit;
    end;
    
    { Validar senha }
    if not TCriptografiaSenha.ValidarSenha(ASenha, Operador.Senha) then
    begin
      FUltimoErro := 'Senha incorreta';
      RegistrarLoginFalha(AMatricula, 'Senha incorreta');
      Operador.Free;
      Exit;
    end;
    
    { Registrar login bem-sucedido }
    RegistrarLoginSucesso(Operador.ID);
    
    Result := Operador;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao autenticar operador: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TPersistenciaOperador.OperadorEstaAtivo(AID: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT Ativo FROM Operadores WHERE ID = :P1';
      Query.ParamByName('P1').AsInteger := AID;
      Query.Open;

      if not Query.Eof then
        Result := Query.FieldByName('Ativo').AsBoolean;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao verificar se operador está ativo: ' + E.Message;
        Result := False;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.OperadorEstaBloqueado(AID: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT Bloqueado FROM Operadores WHERE ID = :P1';
      Query.ParamByName('P1').AsInteger := AID;
      Query.Open;

      if not Query.Eof then
        Result := Query.FieldByName('Bloqueado').AsBoolean;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao verificar se operador está bloqueado: ' + E.Message;
        Result := False;
      end;
    end;
  finally
    Query.Free;
  end;
end;

{ ============================================================================
  OPERAÇÕES DE SEGURANÇA
  ============================================================================ }

function TPersistenciaOperador.AlterarSenha(AID: Integer; ASenhaAtual: string; ASenhaNova: string): Boolean;
var
  Operador: TOperador;
  SenhaHash: string;
begin
  Result := False;
  
  try
    { Obter operador }
    Operador := ObterOperadorPorID(AID);
    
    if not Assigned(Operador) then
    begin
      FUltimoErro := 'Operador não encontrado';
      Exit;
    end;
    
    { Validar senha atual }
    if not TCriptografiaSenha.ValidarSenha(ASenhaAtual, Operador.Senha) then
    begin
      FUltimoErro := 'Senha atual incorreta';
      Operador.Free;
      Exit;
    end;
    
    { Criptografar nova senha }
    SenhaHash := TCriptografiaSenha.CriptografarSenha(ASenhaNova);
    
    { Atualizar no banco }
    if ExecutarSQL(
      'UPDATE Operadores SET Senha = :P1, DataAtualizacao = :P2 WHERE ID = :P3',
      [SenhaHash, Now, AID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
    
    Operador.Free;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao alterar senha: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.ResetarSenha(AID: Integer; ASenhaPadrao: string): Boolean;
var
  SenhaHash: string;
begin
  Result := False;
  
  try
    { Criptografar senha padrão }
    SenhaHash := TCriptografiaSenha.CriptografarSenha(ASenhaPadrao);
    
    { Atualizar no banco }
    if ExecutarSQL(
      'UPDATE Operadores SET Senha = :P1, DataAtualizacao = :P2 WHERE ID = :P3',
      [SenhaHash, Now, AID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao resetar senha: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.BloquearOperador(AID: Integer): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'UPDATE Operadores SET Bloqueado = 1, DataAtualizacao = :P1 WHERE ID = :P2',
      [Now, AID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao bloquear operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.DesbloqueiarOperador(AID: Integer): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'UPDATE Operadores SET Bloqueado = 0, DataAtualizacao = :P1 WHERE ID = :P2',
      [Now, AID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao desbloquear operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.AtivarOperador(AID: Integer): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'UPDATE Operadores SET Ativo = 1, DataAtualizacao = :P1 WHERE ID = :P2',
      [Now, AID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao ativar operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.DesativarOperador(AID: Integer): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'UPDATE Operadores SET Ativo = 0, DataAtualizacao = :P1 WHERE ID = :P2',
      [Now, AID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao desativar operador: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  AUDITORIA
  ============================================================================ }

function TPersistenciaOperador.RegistrarLoginSucesso(AOperadorID: Integer): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'INSERT INTO LogAcessoOperador (OperadorID, Sucesso, Motivo, DataHora) VALUES (:P1, :P2, :P3, :P4)',
      [AOperadorID, 1, 'Login bem-sucedido', Now]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao registrar login bem-sucedido: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.RegistrarLoginFalha(AMatricula: string; AMotivo: string): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'INSERT INTO LogAcessoOperador (Matricula, Sucesso, Motivo, DataHora) VALUES (:P1, :P2, :P3, :P4)',
      [AMatricula, 0, AMotivo, Now]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao registrar login falhado: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaOperador.ObterHistoricoLogins(AOperadorID: Integer; AUltimos: Integer = 10): TStringList;
var
  Query: TFDQuery;
begin
  Result := TStringList.Create;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM LogAcessoOperador WHERE OperadorID = :P1 ORDER BY DataHora DESC LIMIT :P2';
      Query.ParamByName('P1').AsInteger := AOperadorID;
      Query.ParamByName('P2').AsInteger := AUltimos;
      Query.Open;

      while not Query.Eof do
      begin
        Result.Add(
          FormatDateTime('dd/mm/yyyy hh:mm:ss', Query.FieldByName('DataHora').AsDateTime) + ' - ' +
          Query.FieldByName('Motivo').AsString
        );
        Query.Next;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter histórico de logins: ' + E.Message;
        Result.Free;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

{ ============================================================================
  ESTATÍSTICAS
  ============================================================================ }

function TPersistenciaOperador.ObterQuantidadeOperadores: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Operadores';
      Query.Open;

      if not Query.Eof then
        Result := Query.FieldByName('Total').AsInteger;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter quantidade de operadores: ' + E.Message;
        Result := 0;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterQuantidadeOperadoresAtivos: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Operadores WHERE Ativo = 1';
      Query.Open;

      if not Query.Eof then
        Result := Query.FieldByName('Total').AsInteger;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter quantidade de operadores ativos: ' + E.Message;
        Result := 0;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterQuantidadeOperadoresInativos: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Operadores WHERE Ativo = 0';
      Query.Open;

      if not Query.Eof then
        Result := Query.FieldByName('Total').AsInteger;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter quantidade de operadores inativos: ' + E.Message;
        Result := 0;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterOperadorComMaisVendas: TOperador;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text :=
        'SELECT o.* FROM Operadores o ' +
        'JOIN Vendas v ON o.ID = v.OperadorID ' +
        'GROUP BY o.ID ' +
        'ORDER BY COUNT(v.ID) DESC ' +
        'LIMIT 1';
      Query.Open;

      if not Query.Eof then
      begin
        Result := TOperador.Create;
        Result.ID := Query.FieldByName('ID').AsInteger;
        Result.Nome := Query.FieldByName('Nome').AsString;
        Result.Matricula := Query.FieldByName('Matricula').AsString;
        Result.Ativo := Query.FieldByName('Ativo').AsBoolean;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter operador com mais vendas: ' + E.Message;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaOperador.ObterOperadorComMelhorTicket: TOperador;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  
  try
    try
      Query.Connection := FConexao;
      Query.SQL.Text :=
        'SELECT o.*, AVG(v.Total) as TicketMedio FROM Operadores o ' +
        'JOIN Vendas v ON o.ID = v.OperadorID ' +
        'GROUP BY o.ID ' +
        'ORDER BY TicketMedio DESC ' +
        'LIMIT 1';
      Query.Open;

      if not Query.Eof then
      begin
        Result := TOperador.Create;
        Result.ID := Query.FieldByName('ID').AsInteger;
        Result.Nome := Query.FieldByName('Nome').AsString;
        Result.Matricula := Query.FieldByName('Matricula').AsString;
        Result.Ativo := Query.FieldByName('Ativo').AsBoolean;
      end;

      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao obter operador com melhor ticket: ' + E.Message;
        Result := nil;
      end;
    end;
  finally
    Query.Free;
  end;
end;

end.
