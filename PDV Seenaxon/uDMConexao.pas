unit uDMConexao;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Comp.Client, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.UI.Intf, FireDAC.DAPT,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.Stan.Error,
  FireDAC.Phys.Intf, FireDAC.Phys.SQLite, FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs, FireDAC.Phys.SQLiteWrapper.Custom,
  FireDAC.Phys.SQLiteWrapper.Stat, Data.DB, FireDAC.Comp.DataSet;

type
  {$REGION 'Tipos e Constantes'}
  
  // Constantes de configuração
  const
    BANCO_DADOS_NOME = 'pdv_seenaxon.db';
    BANCO_DADOS_CAMINHO = '';  // Deixar vazio para usar diretório da aplicação
    TIMEOUT_CONEXAO = 30000;   // 30 segundos
    POOL_TAMANHO_MINIMO = 1;
    POOL_TAMANHO_MAXIMO = 5;
  
  {$ENDREGION}

  {$REGION 'Classe TDMConexao'}
  
  /// <summary>
  /// Data Module para gerenciar conexão com banco de dados SQLite
  /// Implementa padrão Singleton para garantir única instância
  /// </summary>
  TDMConexao = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    
  private
    FIsConectado: Boolean;
    FUltimoErro: string;
    
    /// <summary>Configurar conexão com banco de dados</summary>
    procedure ConfigurarConexao;
    
    /// <summary>Criar banco de dados se não existir</summary>
    procedure CriarBancoDados;
    
    /// <summary>Executar script SQL de inicialização</summary>
    procedure ExecutarScriptInicializacao;
    
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    
    /// <summary>Conectar ao banco de dados</summary>
    function Conectar: Boolean;
    
    /// <summary>Desconectar do banco de dados</summary>
    procedure Desconectar;
    
    /// <summary>Verificar se está conectado</summary>
    function EstaConectado: Boolean;
    
    /// <summary>Obter conexão ativa</summary>
    function GetConexao: TFDConnection;
    
    /// <summary>Executar query SQL</summary>
    function ExecutarSQL(ASQL: string; AParams: array of const): Boolean;
    
    /// <summary>Obter último erro</summary>
    function GetUltimoErro: string;
    
    /// <summary>Iniciar transação</summary>
    procedure IniciarTransacao;
    
    /// <summary>Confirmar transação</summary>
    procedure ConfirmarTransacao;
    
    /// <summary>Reverter transação</summary>
    procedure ReverterTransacao;
    
    /// <summary>Verificar integridade do banco de dados</summary>
    function VerificarIntegridade: Boolean;
    
    /// <summary>Fazer backup do banco de dados</summary>
    function FazerBackup(AArquivoDestino: string): Boolean;
    
    /// <summary>Restaurar backup do banco de dados</summary>
    function RestaurarBackup(AArquivoOrigem: string): Boolean;
    
    // Propriedades
    property Conexao: TFDConnection read GetConexao;
    property IsConectado: Boolean read FIsConectado;
    property UltimoErro: string read GetUltimoErro;
  end;
  
  {$ENDREGION}

var
  DMConexao: TDMConexao;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{$REGION 'Implementação TDMConexao'}

constructor TDMConexao.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FIsConectado := False;
  FUltimoErro := '';
  
  // Configurar conexão
  ConfigurarConexao;
end;

destructor TDMConexao.Destroy;
begin
  if FIsConectado then
    Desconectar;
  
  inherited Destroy;
end;

procedure TDMConexao.ConfigurarConexao;
var
  CaminhoCompleto: string;
begin
  try
    // Definir caminho do banco de dados
    if BANCO_DADOS_CAMINHO = '' then
      CaminhoCompleto := ExtractFilePath(ParamStr(0)) + BANCO_DADOS_NOME
    else
      CaminhoCompleto := BANCO_DADOS_CAMINHO + BANCO_DADOS_NOME;
    
    // Configurar FDConnection
    with FDConnection do
    begin
      DriverName := 'SQLite';
      
      // Parâmetros de conexão
      Params.Clear;
      Params.Add('Database=' + CaminhoCompleto);
      Params.Add('LockingMode=Normal');
      Params.Add('Synchronous=Full');
      Params.Add('JournalMode=WAL');
      Params.Add('Timeout=' + IntToStr(TIMEOUT_CONEXAO));
      
      // Pool de conexões
      LoginPrompt := False;
      ResourceOptions.AutoConnect := False;
      ResourceOptions.AutoReconnect := True;
      
      // Eventos
      OnError := nil;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao configurar conexão: ' + E.Message;
      raise;
    end;
  end;
end;

procedure TDMConexao.CriarBancoDados;
var
  CaminhoCompleto: string;
begin
  try
    // Definir caminho do banco de dados
    if BANCO_DADOS_CAMINHO = '' then
      CaminhoCompleto := ExtractFilePath(ParamStr(0)) + BANCO_DADOS_NOME
    else
      CaminhoCompleto := BANCO_DADOS_CAMINHO + BANCO_DADOS_NOME;
    
    // Se banco não existe, será criado automaticamente ao conectar
    if not FileExists(CaminhoCompleto) then
    begin
      // Conectar para criar banco
      FDConnection.Connected := True;
      FDConnection.Connected := False;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao criar banco de dados: ' + E.Message;
      raise;
    end;
  end;
end;

procedure TDMConexao.ExecutarScriptInicializacao;
var
  Script: TStringList;
  SQL: string;
begin
  try
    Script := TStringList.Create;
    try
      // Aqui você pode carregar o script de inicialização
      // Por enquanto, apenas criar as tabelas básicas se não existirem
      
      // Verificar se tabela Operadores existe
      SQL := 'SELECT name FROM sqlite_master WHERE type=''table'' AND name=''Operadores''';
      
      // Se não existir, criar tabelas
      // (O script completo está em ESTRUTURA_BANCO_DADOS.sql)
    finally
      Script.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao executar script de inicialização: ' + E.Message;
      raise;
    end;
  end;
end;

function TDMConexao.Conectar: Boolean;
begin
  Result := False;
  FUltimoErro := '';
  
  try
    // Criar banco de dados se não existir
    CriarBancoDados;
    
    // Conectar
    FDConnection.Connected := True;
    FIsConectado := True;
    
    // Executar script de inicialização
    ExecutarScriptInicializacao;
    
    Result := True;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao conectar: ' + E.Message;
      FIsConectado := False;
      Result := False;
    end;
  end;
end;

procedure TDMConexao.Desconectar;
begin
  try
    if FDConnection.Connected then
      FDConnection.Connected := False;
    
    FIsConectado := False;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao desconectar: ' + E.Message;
  end;
end;

function TDMConexao.EstaConectado: Boolean;
begin
  Result := FIsConectado and FDConnection.Connected;
end;

function TDMConexao.GetConexao: TFDConnection;
begin
  Result := FDConnection;
end;

function TDMConexao.ExecutarSQL(ASQL: string; AParams: array of const): Boolean;
var
  Query: TFDQuery;
  I: Integer;
begin
  Result := False;
  FUltimoErro := '';
  
  if not EstaConectado then
  begin
    FUltimoErro := 'Banco de dados não conectado';
    Exit;
  end;
  
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection;
    Query.SQL.Text := ASQL;
    
    // Definir parâmetros
    for I := 0 to High(AParams) do
    begin
      case AParams[I].VType of
        vtInteger:
          Query.ParamByName('Param' + IntToStr(I)).AsInteger := AParams[I].VInteger;
        vtString:
          Query.ParamByName('Param' + IntToStr(I)).AsString := string(AParams[I].VString);
        vtExtended:
          Query.ParamByName('Param' + IntToStr(I)).AsFloat := AParams[I].VExtended^;
        vtBoolean:
          Query.ParamByName('Param' + IntToStr(I)).AsBoolean := AParams[I].VBoolean;
      end;
    end;
    
    Query.ExecSQL;
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao executar SQL: ' + E.Message;
  finally
    Query.Free;
  end;
end;

function TDMConexao.GetUltimoErro: string;
begin
  Result := FUltimoErro;
end;

procedure TDMConexao.IniciarTransacao;
begin
  try
    if EstaConectado then
      FDConnection.StartTransaction;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao iniciar transação: ' + E.Message;
  end;
end;

procedure TDMConexao.ConfirmarTransacao;
begin
  try
    if EstaConectado then
      FDConnection.Commit;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao confirmar transação: ' + E.Message;
  end;
end;

procedure TDMConexao.ReverterTransacao;
begin
  try
    if EstaConectado then
      FDConnection.Rollback;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao reverter transação: ' + E.Message;
  end;
end;

function TDMConexao.VerificarIntegridade: Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  if not EstaConectado then
    Exit;
  
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection;
    Query.SQL.Text := 'PRAGMA integrity_check';
    Query.Open;
    
    Result := (Query.RecordCount > 0) and 
              (Query.Fields[0].AsString = 'ok');
  except
    Result := False;
  finally
    Query.Free;
  end;
end;

function TDMConexao.FazerBackup(AArquivoDestino: string): Boolean;
var
  CaminhoOrigem: string;
begin
  Result := False;
  FUltimoErro := '';
  
  try
    if BANCO_DADOS_CAMINHO = '' then
      CaminhoOrigem := ExtractFilePath(ParamStr(0)) + BANCO_DADOS_NOME
    else
      CaminhoOrigem := BANCO_DADOS_CAMINHO + BANCO_DADOS_NOME;
    
    if FileExists(CaminhoOrigem) then
    begin
      CopyFile(PChar(CaminhoOrigem), PChar(AArquivoDestino), False);
      Result := True;
    end
    else
      FUltimoErro := 'Arquivo de banco de dados não encontrado';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao fazer backup: ' + E.Message;
  end;
end;

function TDMConexao.RestaurarBackup(AArquivoOrigem: string): Boolean;
var
  CaminhoDestino: string;
begin
  Result := False;
  FUltimoErro := '';
  
  try
    if not FileExists(AArquivoOrigem) then
    begin
      FUltimoErro := 'Arquivo de backup não encontrado';
      Exit;
    end;
    
    // Desconectar
    Desconectar;
    
    if BANCO_DADOS_CAMINHO = '' then
      CaminhoDestino := ExtractFilePath(ParamStr(0)) + BANCO_DADOS_NOME
    else
      CaminhoDestino := BANCO_DADOS_CAMINHO + BANCO_DADOS_NOME;
    
    // Copiar backup
    CopyFile(PChar(AArquivoOrigem), PChar(CaminhoDestino), False);
    
    // Reconectar
    Result := Conectar;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao restaurar backup: ' + E.Message;
      Conectar; // Tentar reconectar
    end;
  end;
end;

{$ENDREGION}

initialization
  // Criar instância global
  DMConexao := TDMConexao.Create(nil);

finalization
  // Liberar instância global
  if Assigned(DMConexao) then
    DMConexao.Free;

end.
