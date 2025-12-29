unit uInicializacaoSistema;

interface

uses
  System.SysUtils, System.Classes,
  FMX.Dialogs, FMX.Forms,
  uOperador, uCaixa, uIntegracaoCaixa, uDMConexao, uRecuperacaoVendas;

type
  { Classe responsável pela inicialização do sistema }
  TInicializacaoSistema = class
  private
    FIntegracaoCaixa: TIntegracaoCaixa;
    FOperadorAtual: TOperador;
    FCaixaAtual: TCaixa;
    FUltimoErro: string;
    
    function VerificarConexaoBancoDados: Boolean;
    function VerificarCaixaAberto: Boolean;
    function VerificarVendaPendente: Boolean;
    function RealizarLogin: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    
    { Inicializar sistema completo }
    function InicializarSistema: Boolean;
    
    { Finalizar sistema }
    procedure FinalizarSistema;
    
    { Getters }
    function GetIntegracaoCaixa: TIntegracaoCaixa;
    function GetOperadorAtual: TOperador;
    function GetCaixaAtual: TCaixa;
    function GetUltimoErro: string;
    
    { Propriedades }
    property IntegracaoCaixa: TIntegracaoCaixa read GetIntegracaoCaixa;
    property OperadorAtual: TOperador read GetOperadorAtual;
    property CaixaAtual: TCaixa read GetCaixaAtual;
    property UltimoErro: string read GetUltimoErro;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TInicializacaoSistema.Create;
begin
  inherited Create;
  
  FIntegracaoCaixa := nil;
  FOperadorAtual := nil;
  FCaixaAtual := nil;
  FUltimoErro := '';
end;

destructor TInicializacaoSistema.Destroy;
begin
  FinalizarSistema;
  inherited;
end;

{ ============================================================================
  INICIALIZAÇÃO DO SISTEMA
  ============================================================================ }

function TInicializacaoSistema.InicializarSistema: Boolean;
begin
  Result := False;
  
  try
    { PASSO 1: Verificar conexão com banco de dados }
    if not VerificarConexaoBancoDados then
    begin
      FUltimoErro := 'Falha ao conectar com banco de dados';
      Exit;
    end;
    
    { PASSO 2: Inicializar integração de caixa }
    FIntegracaoCaixa := TIntegracaoCaixa.Create;
    if not FIntegracaoCaixa.Inicializar then
    begin
      FUltimoErro := 'Falha ao inicializar integração de caixa: ' + FIntegracaoCaixa.UltimoErro;
      Exit;
    end;
    
    { PASSO 3: Realizar login do operador }
    if not RealizarLogin then
    begin
      FUltimoErro := 'Login cancelado ou falhou';
      Exit;
    end;
    
    { PASSO 4: Verificar caixa aberto }
    if not VerificarCaixaAberto then
    begin
      FUltimoErro := 'Falha ao verificar caixa aberto';
      Exit;
    end;
    
    { PASSO 5: Verificar venda pendente }
    if not VerificarVendaPendente then
    begin
      FUltimoErro := 'Falha ao verificar venda pendente';
      Exit;
    end;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao inicializar sistema: ' + E.Message;
      Result := False;
    end;
  end;
end;

procedure TInicializacaoSistema.FinalizarSistema;
begin
  if Assigned(FIntegracaoCaixa) then
  begin
    FIntegracaoCaixa.Finalizar;
    FIntegracaoCaixa.Free;
  end;
  
  FOperadorAtual := nil;
  FCaixaAtual := nil;
end;

{ ============================================================================
  VERIFICAÇÕES
  ============================================================================ }

function TInicializacaoSistema.VerificarConexaoBancoDados: Boolean;
begin
  Result := False;
  
  try
    { Conectar ao banco de dados }
    if not DMConexao.Conectar then
    begin
      FUltimoErro := 'Erro ao conectar com banco de dados';
      Exit;
    end;
    
    Result := True;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao verificar conexão: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TInicializacaoSistema.RealizarLogin: Boolean;
begin
  Result := False;
  
  try
    { TODO: Implementar tela de login }
    { Por enquanto, usar operador de teste }
    FOperadorAtual := TOperador.Create(1, 'MARCOS SILVA DE MATOS', '001', '1234');
    FIntegracaoCaixa.SetOperadorAtual(FOperadorAtual);
    
    Result := True;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao realizar login: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TInicializacaoSistema.VerificarCaixaAberto: Boolean;
var
  Confirmacao: Integer;
  SaldoInicial: Double;
begin
  Result := False;
  
  try
    { Verificar se existe caixa aberto para este operador }
    if FIntegracaoCaixa.TemCaixaAbertoOperador(FOperadorAtual.ID) then
    begin
      { Caixa já aberto, carregar }
      FCaixaAtual := FIntegracaoCaixa.ObterCaixaAbertoOperador(FOperadorAtual.ID);
      
      if Assigned(FCaixaAtual) then
      begin
        ShowMessage('Caixa já estava aberto!' + sLineBreak +
          'Saldo Inicial: R$ ' + FormatFloat('0.00', FCaixaAtual.SaldoInicial) + sLineBreak +
          'Saldo Atual: R$ ' + FormatFloat('0.00', FCaixaAtual.SaldoAtual));
        Result := True;
        Exit;
      end;
    end;
    
    { Nenhum caixa aberto, perguntar se deseja abrir }
    Confirmacao := MessageDlg(
      'Nenhum caixa aberto para este operador.' + sLineBreak +
      'Deseja abrir um novo caixa?',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      0
    );
    
    if Confirmacao <> mrYes then
    begin
      FUltimoErro := 'Operação cancelada pelo usuário';
      Exit;
    end;
    
    { Solicitar saldo inicial }
    SaldoInicial := StrToFloatDef(InputBox(
      'Abrir Caixa',
      'Saldo Inicial (R$):',
      '0.00'
    ), 0.00);
    
    if SaldoInicial < 0 then
    begin
      ShowMessage('Erro: Saldo inicial não pode ser negativo');
      Exit;
    end;
    
    { Abrir caixa }
    FCaixaAtual := FIntegracaoCaixa.AbrirCaixa(FOperadorAtual, SaldoInicial);
    
    if not Assigned(FCaixaAtual) then
    begin
      FUltimoErro := 'Erro ao abrir caixa: ' + FIntegracaoCaixa.UltimoErro;
      Exit;
    end;
    
    ShowMessage('Caixa aberto com sucesso!' + sLineBreak +
      'Saldo Inicial: R$ ' + FormatFloat('0.00', SaldoInicial));
    
    Result := True;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao verificar caixa: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TInicializacaoSistema.VerificarVendaPendente: Boolean;
var
  RecuperacaoVendas: TRecuperacaoVendas;
  Confirmacao: Integer;
begin
  Result := True;
  
  try
    RecuperacaoVendas := TRecuperacaoVendas.Create;
    try
      { Verificar se existe venda pendente }
      if not RecuperacaoVendas.TemVendaPendente then
        Exit;
      
      { Perguntar se deseja retomar }
      Confirmacao := MessageDlg(
        'Existe uma venda pendente não finalizada.' + sLineBreak +
        'Deseja retomá-la?',
        TMsgDlgType.mtConfirmation,
        [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
        0
      );
      
      if Confirmacao = mrYes then
      begin
        { TODO: Carregar venda pendente e exibir na tela principal }
        ShowMessage('Venda pendente carregada com sucesso!');
      end
      else
      begin
        { Deletar venda pendente }
        RecuperacaoVendas.DeletarVendaPendente;
        ShowMessage('Venda pendente descartada');
      end;
      
      Result := True;
    finally
      RecuperacaoVendas.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao verificar venda pendente: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  GETTERS
  ============================================================================ }

function TInicializacaoSistema.GetIntegracaoCaixa: TIntegracaoCaixa;
begin
  Result := FIntegracaoCaixa;
end;

function TInicializacaoSistema.GetOperadorAtual: TOperador;
begin
  Result := FOperadorAtual;
end;

function TInicializacaoSistema.GetCaixaAtual: TCaixa;
begin
  Result := FCaixaAtual;
end;

function TInicializacaoSistema.GetUltimoErro: string;
begin
  Result := FUltimoErro;
end;

end.
