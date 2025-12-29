unit uIntegracaoCaixa;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FMX.Dialogs, FMX.Forms,
  uOperador, uCaixa, uRepositorioCaixa, uRepositorioCaixaPersistencia,
  uDMConexao, uRecuperacaoVendas;

type
  { Tipos de evento }
  TCaixaAbertoProcedure = procedure(ACaixa: TCaixa) of object;
  TCaixaFechadoProcedure = procedure(ACaixa: TCaixa) of object;
  TCaixaMovimentacaoProcedure = procedure(ATipo: string; AValor: Double) of object;

  { Classe de integração entre telas de caixa }
  TIntegracaoCaixa = class
  private
    FRepositorioCaixa: TRepositorioCaixa;
    FRepositorioPersistencia: TRepositorioCaixaPersistencia;
    FOperadorAtual: TOperador;
    FRecuperacaoVendas: TRecuperacaoVendas;
    FUltimoErro: string;
    
    { Eventos }
    FOnCaixaAberto: TCaixaAbertoProcedure;
    FOnCaixaFechado: TCaixaFechadoProcedure;
    FOnMovimentacao: TCaixaMovimentacaoProcedure;
    
    { Métodos privados }
    procedure DispararEventoCaixaAberto(ACaixa: TCaixa);
    procedure DispararEventoCaixaFechado(ACaixa: TCaixa);
    procedure DispararEventoMovimentacao(ATipo: string; AValor: Double);
  public
    constructor Create;
    destructor Destroy; override;
    
    { ========== INICIALIZAÇÃO ========== }
    
    { Inicializar integração }
    function Inicializar: Boolean;
    
    { Desconectar e liberar recursos }
    procedure Finalizar;
    
    { ========== VERIFICAÇÃO DE CAIXA ========== }
    
    { Verificar se existe caixa aberto }
    function TemCaixaAberto: Boolean;
    
    { Verificar se operador tem caixa aberto }
    function TemCaixaAbertoOperador(AOperadorID: Integer): Boolean;
    
    { Obter caixa aberto atual }
    function ObterCaixaAtual: TCaixa;
    
    { Obter caixa aberto do operador }
    function ObterCaixaAbertoOperador(AOperadorID: Integer): TCaixa;
    
    { ========== OPERAÇÕES DE CAIXA ========== }
    
    { Abrir caixa }
    function AbrirCaixa(AOperador: TOperador; ASaldoInicial: Double): TCaixa;
    
    { Fechar caixa }
    function FecharCaixa: Boolean;
    
    { Cancelar caixa }
    function CancelarCaixa: Boolean;
    
    { ========== MOVIMENTAÇÕES ========== }
    
    { Realizar sangria }
    function RealizarSangria(AValor: Double; AMotivo: string = ''): Boolean;
    
    { Realizar suprimento }
    function RealizarSuprimento(AValor: Double; AMotivo: string = ''): Boolean;
    
    { ========== SETTERS ========== }
    
    { Definir operador atual }
    procedure SetOperadorAtual(AOperador: TOperador);
    
    { ========== GETTERS ========== }
    
    { Obter repositório de caixa }
    function GetRepositorioCaixa: TRepositorioCaixa;
    
    { Obter repositório de persistência }
    function GetRepositorioPersistencia: TRepositorioCaixaPersistencia;
    
    { Obter último erro }
    function GetUltimoErro: string;
    
    { ========== PROPRIEDADES ========== }
    
    property RepositorioCaixa: TRepositorioCaixa read GetRepositorioCaixa;
    property RepositorioPersistencia: TRepositorioCaixaPersistencia read GetRepositorioPersistencia;
    property OperadorAtual: TOperador read FOperadorAtual;
    property UltimoErro: string read GetUltimoErro;
    
    { ========== EVENTOS ========== }
    
    property OnCaixaAberto: TCaixaAbertoProcedure read FOnCaixaAberto write FOnCaixaAberto;
    property OnCaixaFechado: TCaixaFechadoProcedure read FOnCaixaFechado write FOnCaixaFechado;
    property OnMovimentacao: TCaixaMovimentacaoProcedure read FOnMovimentacao write FOnMovimentacao;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TIntegracaoCaixa.Create;
begin
  inherited Create;
  
  FRepositorioCaixa := nil;
  FRepositorioPersistencia := nil;
  FOperadorAtual := nil;
  FRecuperacaoVendas := nil;
  FUltimoErro := '';
  
  FOnCaixaAberto := nil;
  FOnCaixaFechado := nil;
  FOnMovimentacao := nil;
end;

destructor TIntegracaoCaixa.Destroy;
begin
  Finalizar;
  inherited;
end;

{ ============================================================================
  INICIALIZAÇÃO
  ============================================================================ }

function TIntegracaoCaixa.Inicializar: Boolean;
begin
  Result := False;
  
  try
    { Criar repositórios }
    FRepositorioCaixa := TRepositorioCaixa.Create;
    FRepositorioPersistencia := TRepositorioCaixaPersistencia.Create(DMConexao.Conexao);
    FRecuperacaoVendas := TRecuperacaoVendas.Create;
    
    FUltimoErro := '';
    Result := True;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao inicializar integração: ' + E.Message;
      Result := False;
    end;
  end;
end;

procedure TIntegracaoCaixa.Finalizar;
begin
  if Assigned(FRepositorioCaixa) then
    FRepositorioCaixa.Free;
  
  if Assigned(FRepositorioPersistencia) then
    FRepositorioPersistencia.Free;
  
  if Assigned(FRecuperacaoVendas) then
    FRecuperacaoVendas.Free;
  
  FOperadorAtual := nil;
end;

{ ============================================================================
  VERIFICAÇÃO DE CAIXA
  ============================================================================ }

function TIntegracaoCaixa.TemCaixaAberto: Boolean;
begin
  Result := False;
  
  if not Assigned(FRepositorioCaixa) then
    Exit;
  
  Result := FRepositorioCaixa.TemCaixaAberto;
end;

function TIntegracaoCaixa.TemCaixaAbertoOperador(AOperadorID: Integer): Boolean;
begin
  Result := False;
  
  if not Assigned(FRepositorioPersistencia) then
    Exit;
  
  Result := FRepositorioPersistencia.TemCaixaAbertoOperador(AOperadorID);
end;

function TIntegracaoCaixa.ObterCaixaAtual: TCaixa;
begin
  Result := nil;
  
  if not Assigned(FRepositorioCaixa) then
    Exit;
  
  Result := FRepositorioCaixa.CaixaAtual;
end;

function TIntegracaoCaixa.ObterCaixaAbertoOperador(AOperadorID: Integer): TCaixa;
begin
  Result := nil;
  
  if not Assigned(FRepositorioPersistencia) then
    Exit;
  
  Result := FRepositorioPersistencia.ObterCaixaAbertoOperador(AOperadorID);
end;

{ ============================================================================
  OPERAÇÕES DE CAIXA
  ============================================================================ }

function TIntegracaoCaixa.AbrirCaixa(AOperador: TOperador; 
  ASaldoInicial: Double): TCaixa;
var
  Caixa: TCaixa;
begin
  Result := nil;
  
  if not Assigned(FRepositorioCaixa) or not Assigned(FRepositorioPersistencia) then
  begin
    FUltimoErro := 'Repositórios não inicializados';
    Exit;
  end;
  
  if not Assigned(AOperador) then
  begin
    FUltimoErro := 'Operador inválido';
    Exit;
  end;
  
  if ASaldoInicial < 0 then
  begin
    FUltimoErro := 'Saldo inicial não pode ser negativo';
    Exit;
  end;
  
  try
    { Abrir caixa no repositório }
    Caixa := FRepositorioCaixa.AbrirCaixa(AOperador, ASaldoInicial);
    
    if not Assigned(Caixa) then
    begin
      FUltimoErro := 'Erro ao abrir caixa: ' + FRepositorioCaixa.UltimoErro;
      Exit;
    end;
    
    { Salvar em banco de dados }
    if not FRepositorioPersistencia.SalvarCaixa(Caixa) then
    begin
      FUltimoErro := 'Erro ao salvar caixa em banco: ' + FRepositorioPersistencia.UltimoErro;
      Exit;
    end;
    
    { Atualizar operador }
    FOperadorAtual := AOperador;
    
    { Disparar evento }
    DispararEventoCaixaAberto(Caixa);
    
    Result := Caixa;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao abrir caixa: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TIntegracaoCaixa.FecharCaixa: Boolean;
var
  Caixa: TCaixa;
begin
  Result := False;
  
  if not Assigned(FRepositorioCaixa) or not Assigned(FRepositorioPersistencia) then
  begin
    FUltimoErro := 'Repositórios não inicializados';
    Exit;
  end;
  
  Caixa := FRepositorioCaixa.CaixaAtual;
  
  if not Assigned(Caixa) then
  begin
    FUltimoErro := 'Nenhum caixa aberto';
    Exit;
  end;
  
  try
    { Fechar caixa no repositório }
    if not FRepositorioCaixa.FecharCaixa then
    begin
      FUltimoErro := 'Erro ao fechar caixa: ' + FRepositorioCaixa.UltimoErro;
      Exit;
    end;
    
    { Atualizar em banco de dados }
    if not FRepositorioPersistencia.AtualizarCaixa(Caixa) then
    begin
      FUltimoErro := 'Erro ao atualizar caixa em banco: ' + FRepositorioPersistencia.UltimoErro;
      Exit;
    end;
    
    { Salvar fechamento }
    if not FRepositorioPersistencia.SalvarFechamento(Caixa, FOperadorAtual.ID) then
    begin
      FUltimoErro := 'Erro ao salvar fechamento: ' + FRepositorioPersistencia.UltimoErro;
      Exit;
    end;
    
    { Disparar evento }
    DispararEventoCaixaFechado(Caixa);
    
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

function TIntegracaoCaixa.CancelarCaixa: Boolean;
var
  Caixa: TCaixa;
begin
  Result := False;
  
  if not Assigned(FRepositorioCaixa) then
  begin
    FUltimoErro := 'Repositório não inicializado';
    Exit;
  end;
  
  Caixa := FRepositorioCaixa.CaixaAtual;
  
  if not Assigned(Caixa) then
  begin
    FUltimoErro := 'Nenhum caixa aberto';
    Exit;
  end;
  
  try
    Result := FRepositorioCaixa.CancelarCaixa;
    
    if Result then
      FUltimoErro := ''
    else
      FUltimoErro := 'Erro ao cancelar caixa: ' + FRepositorioCaixa.UltimoErro;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao cancelar caixa: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  MOVIMENTAÇÕES
  ============================================================================ }

function TIntegracaoCaixa.RealizarSangria(AValor: Double; 
  AMotivo: string = ''): Boolean;
var
  Caixa: TCaixa;
begin
  Result := False;
  
  if not Assigned(FRepositorioCaixa) or not Assigned(FRepositorioPersistencia) then
  begin
    FUltimoErro := 'Repositórios não inicializados';
    Exit;
  end;
  
  Caixa := FRepositorioCaixa.CaixaAtual;
  
  if not Assigned(Caixa) then
  begin
    FUltimoErro := 'Nenhum caixa aberto';
    Exit;
  end;
  
  if AValor <= 0 then
  begin
    FUltimoErro := 'Valor deve ser positivo';
    Exit;
  end;
  
  try
    { Realizar sangria no repositório }
    if not Caixa.RealizarSangria(AValor, AMotivo) then
    begin
      FUltimoErro := 'Erro ao realizar sangria: saldo insuficiente';
      Exit;
    end;
    
    { Salvar movimentação em banco }
    if not FRepositorioPersistencia.SalvarMovimentacao(
      Caixa.ID, 'Sangria', AValor, AMotivo, FOperadorAtual.Nome) then
    begin
      FUltimoErro := 'Erro ao salvar sangria em banco: ' + FRepositorioPersistencia.UltimoErro;
      Exit;
    end;
    
    { Atualizar caixa em banco }
    if not FRepositorioPersistencia.AtualizarCaixa(Caixa) then
    begin
      FUltimoErro := 'Erro ao atualizar caixa em banco: ' + FRepositorioPersistencia.UltimoErro;
      Exit;
    end;
    
    { Disparar evento }
    DispararEventoMovimentacao('Sangria', AValor);
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao realizar sangria: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TIntegracaoCaixa.RealizarSuprimento(AValor: Double; 
  AMotivo: string = ''): Boolean;
var
  Caixa: TCaixa;
begin
  Result := False;
  
  if not Assigned(FRepositorioCaixa) or not Assigned(FRepositorioPersistencia) then
  begin
    FUltimoErro := 'Repositórios não inicializados';
    Exit;
  end;
  
  Caixa := FRepositorioCaixa.CaixaAtual;
  
  if not Assigned(Caixa) then
  begin
    FUltimoErro := 'Nenhum caixa aberto';
    Exit;
  end;
  
  if AValor <= 0 then
  begin
    FUltimoErro := 'Valor deve ser positivo';
    Exit;
  end;
  
  try
    { Realizar suprimento no repositório }
    if not Caixa.RealizarSuprimento(AValor, AMotivo) then
    begin
      FUltimoErro := 'Erro ao realizar suprimento';
      Exit;
    end;
    
    { Salvar movimentação em banco }
    if not FRepositorioPersistencia.SalvarMovimentacao(
      Caixa.ID, 'Suprimento', AValor, AMotivo, FOperadorAtual.Nome) then
    begin
      FUltimoErro := 'Erro ao salvar suprimento em banco: ' + FRepositorioPersistencia.UltimoErro;
      Exit;
    end;
    
    { Atualizar caixa em banco }
    if not FRepositorioPersistencia.AtualizarCaixa(Caixa) then
    begin
      FUltimoErro := 'Erro ao atualizar caixa em banco: ' + FRepositorioPersistencia.UltimoErro;
      Exit;
    end;
    
    { Disparar evento }
    DispararEventoMovimentacao('Suprimento', AValor);
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao realizar suprimento: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  SETTERS
  ============================================================================ }

procedure TIntegracaoCaixa.SetOperadorAtual(AOperador: TOperador);
begin
  FOperadorAtual := AOperador;
end;

{ ============================================================================
  GETTERS
  ============================================================================ }

function TIntegracaoCaixa.GetRepositorioCaixa: TRepositorioCaixa;
begin
  Result := FRepositorioCaixa;
end;

function TIntegracaoCaixa.GetRepositorioPersistencia: TRepositorioCaixaPersistencia;
begin
  Result := FRepositorioPersistencia;
end;

function TIntegracaoCaixa.GetUltimoErro: string;
begin
  Result := FUltimoErro;
end;

{ ============================================================================
  EVENTOS
  ============================================================================ }

procedure TIntegracaoCaixa.DispararEventoCaixaAberto(ACaixa: TCaixa);
begin
  if Assigned(FOnCaixaAberto) then
    FOnCaixaAberto(ACaixa);
end;

procedure TIntegracaoCaixa.DispararEventoCaixaFechado(ACaixa: TCaixa);
begin
  if Assigned(FOnCaixaFechado) then
    FOnCaixaFechado(ACaixa);
end;

procedure TIntegracaoCaixa.DispararEventoMovimentacao(ATipo: string; AValor: Double);
begin
  if Assigned(FOnMovimentacao) then
    FOnMovimentacao(ATipo, AValor);
end;

end.
