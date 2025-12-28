unit uFormLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Layouts, FMX.Objects, FMX.ListBox, FMX.Controls.Presentation,
  FMX.ScrollBox, FireDAC.Comp.Client, FireDAC.Stan.Param, Data.DB,
  uOperador, uRepositorioOperador, uDMConexao;

type
  {$REGION 'Constantes'}
  
  const
    // Constantes de segurança
    TENTATIVAS_MAXIMAS = 3;           // Máximo de tentativas de login
    TEMPO_BLOQUEIO_MINUTOS = 15;      // Tempo de bloqueio após tentativas
    TEMPO_ESPERA_ENTRE_TENTATIVAS = 2; // Segundos entre tentativas
    
    // Constantes de UI
    ALTURA_BOTAO_OPERADOR = 60;
    ESPACAMENTO_BOTOES = 5;
    LARGURA_MINIMA_FORM = 400;
    ALTURA_MINIMA_FORM = 600;
  
  {$ENDREGION}

  {$REGION 'Tipos'}
  
  // Resultado do login
  type
    TResultadoLogin = record
      Sucesso: Boolean;
      Operador: TOperador;
      Mensagem: string;
      BloqueadoAte: TDateTime;
    end;
  
  {$ENDREGION}

  {$REGION 'Classe TFormLogin'}
  
  TFormLogin = class(TForm)
    // Componentes de Layout
    LayoutPrincipal: TLayout;
    LayoutTitulo: TLayout;
    LayoutCorpo: TLayout;
    LayoutRodape: TLayout;
    
    // Componentes de Título
    LabelTitulo: TLabel;
    LabelSubtitulo: TLabel;
    RectangloDivisor: TRectangle;
    
    // Componentes de Entrada
    LabelMatricula: TLabel;
    EditMatricula: TEdit;
    
    LabelSenha: TLabel;
    EditSenha: TEdit;
    
    // Componentes de Mensagem
    LabelMensagem: TLabel;
    
    // Componentes de Operadores Rápidos
    LabelOperadoresRapidos: TLabel;
    ScrollBoxOperadores: TScrollBox;
    LayoutOperadores: TLayout;
    
    // Botões
    ButtonEntrar: TButton;
    ButtonLimpar: TButton;
    ButtonSair: TButton;
    
    // Componentes de Status
    LabelTentativas: TLabel;
    ProgressBarTentativas: TProgressBar;
    
    // Eventos
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    
    procedure ButtonEntrarClick(Sender: TObject);
    procedure ButtonLimparClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);
    
    procedure EditMatriculaChange(Sender: TObject);
    procedure EditSenhaChange(Sender: TObject);
    
    procedure OperadorRapidoClick(Sender: TObject);
    
  private
    FRepositorio: TRepositorioOperador;
    FOperadorAtual: TOperador;
    FTentativasLogin: Integer;
    FBloqueadoAte: TDateTime;
    FUltimaMatricula: string;
    
    /// <summary>Inicializar componentes</summary>
    procedure InicializarComponentes;
    
    /// <summary>Configurar estilos e cores</summary>
    procedure ConfigurarEstilos;
    
    /// <summary>Carregar operadores rápidos</summary>
    procedure CarregarOperadoresRapidos;
    
    /// <summary>Criar botão de operador rápido</summary>
    function CriarBotaoOperador(AOperador: TOperador): TButton;
    
    /// <summary>Realizar login</summary>
    function RealizarLogin: TResultadoLogin;
    
    /// <summary>Validar entrada</summary>
    function ValidarEntrada: TResultadoLogin;
    
    /// <summary>Verificar bloqueio por força bruta</summary>
    function VerificarBloqueio: TResultadoLogin;
    
    /// <summary>Atualizar UI após tentativa de login</summary>
    procedure AtualizarUIAposTentativa(AResultado: TResultadoLogin);
    
    /// <summary>Exibir mensagem de erro</summary>
    procedure ExibirMensagem(AMensagem: string; AErro: Boolean = False);
    
    /// <summary>Limpar campos de entrada</summary>
    procedure LimparCampos;
    
    /// <summary>Habilitar/desabilitar controles</summary>
    procedure HabilitarControles(AHabilitar: Boolean);
    
    /// <summary>Atualizar indicador de tentativas</summary>
    procedure AtualizarIndicadorTentativas;
    
    /// <summary>Registrar tentativa de login em log</summary>
    procedure RegistrarTentativaLogin(ASucesso: Boolean; AMotivo: string = '');
    
  public
    /// <summary>Obter operador autenticado</summary>
    function GetOperadorAutenticado: TOperador;
    
    // Propriedades
    property OperadorAutenticado: TOperador read GetOperadorAutenticado;
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.fmx}

{$REGION 'Implementação TFormLogin'}

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  // Criar repositório
  FRepositorio := TRepositorioOperador.Create;
  FOperadorAtual := nil;
  FTentativasLogin := 0;
  FBloqueadoAte := 0;
  FUltimaMatricula := '';
  
  // Configurar formulário
  Caption := 'PDV Seenaxon - Login';
  Width := LARGURA_MINIMA_FORM;
  Height := ALTURA_MINIMA_FORM;
  Position := TFormPosition.ScreenCenter;
  
  // Inicializar componentes
  InicializarComponentes;
  ConfigurarEstilos;
end;

procedure TFormLogin.FormShow(Sender: TObject);
begin
  // Conectar ao banco de dados
  if not DMConexao.EstaConectado then
  begin
    if not DMConexao.Conectar then
    begin
      ExibirMensagem('Erro ao conectar ao banco de dados: ' + DMConexao.UltimoErro, True);
      HabilitarControles(False);
      Exit;
    end;
  end;
  
  // Carregar operadores rápidos
  CarregarOperadoresRapidos;
  
  // Focar no campo de matrícula
  EditMatricula.SetFocus;
end;

procedure TFormLogin.FormDestroy(Sender: TObject);
begin
  if Assigned(FRepositorio) then
    FRepositorio.Free;
  
  if Assigned(FOperadorAtual) then
    FOperadorAtual.Free;
end;

procedure TFormLogin.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // Pressionar Enter para fazer login
  if Key = vkReturn then
  begin
    Key := 0;
    ButtonEntrarClick(nil);
  end
  // Pressionar Escape para sair
  else if Key = vkEscape then
  begin
    Key := 0;
    ButtonSairClick(nil);
  end;
end;

procedure TFormLogin.InicializarComponentes;
begin
  // Layout Principal
  LayoutPrincipal := TLayout.Create(Self);
  LayoutPrincipal.Parent := Self;
  LayoutPrincipal.Align := TAlignLayout.Client;
  LayoutPrincipal.Padding.Left := 20;
  LayoutPrincipal.Padding.Top := 20;
  LayoutPrincipal.Padding.Right := 20;
  LayoutPrincipal.Padding.Bottom := 20;
  
  // Layout Título
  LayoutTitulo := TLayout.Create(Self);
  LayoutTitulo.Parent := LayoutPrincipal;
  LayoutTitulo.Align := TAlignLayout.Top;
  LayoutTitulo.Height := 100;
  
  LabelTitulo := TLabel.Create(Self);
  LabelTitulo.Parent := LayoutTitulo;
  LabelTitulo.Text := 'PDV SEENAXON';
  LabelTitulo.TextSettings.FontColor := TAlphaColorRec.Black;
  LabelTitulo.TextSettings.Font.Size := 32;
  LabelTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LabelTitulo.Align := TAlignLayout.Top;
  LabelTitulo.Height := 40;
  
  LabelSubtitulo := TLabel.Create(Self);
  LabelSubtitulo.Parent := LayoutTitulo;
  LabelSubtitulo.Text := 'Sistema de Ponto de Venda';
  LabelSubtitulo.TextSettings.FontColor := TAlphaColorRec.Gray;
  LabelSubtitulo.TextSettings.Font.Size := 14;
  LabelSubtitulo.Align := TAlignLayout.Top;
  LabelSubtitulo.Height := 20;
  LabelSubtitulo.Margins.Top := 5;
  
  RectangloDivisor := TRectangle.Create(Self);
  RectangloDivisor.Parent := LayoutTitulo;
  RectangloDivisor.Fill.Color := TAlphaColorRec.Create(255, 69, 0, 255); // #FF4500
  RectangloDivisor.Stroke.Kind := TBrushKind.None;
  RectangloDivisor.Height := 2;
  RectangloDivisor.Align := TAlignLayout.Bottom;
  
  // Layout Corpo
  LayoutCorpo := TLayout.Create(Self);
  LayoutCorpo.Parent := LayoutPrincipal;
  LayoutCorpo.Align := TAlignLayout.Client;
  LayoutCorpo.Margins.Top := 20;
  
  // Label Matrícula
  LabelMatricula := TLabel.Create(Self);
  LabelMatricula.Parent := LayoutCorpo;
  LabelMatricula.Text := 'Matrícula:';
  LabelMatricula.TextSettings.Font.Size := 12;
  LabelMatricula.Align := TAlignLayout.Top;
  LabelMatricula.Height := 20;
  
  // Edit Matrícula
  EditMatricula := TEdit.Create(Self);
  EditMatricula.Parent := LayoutCorpo;
  EditMatricula.Align := TAlignLayout.Top;
  EditMatricula.Height := 40;
  EditMatricula.Margins.Top := 5;
  EditMatricula.Margins.Bottom := 15;
  EditMatricula.TextSettings.Font.Size := 14;
  EditMatricula.OnChange := EditMatriculaChange;
  
  // Label Senha
  LabelSenha := TLabel.Create(Self);
  LabelSenha.Parent := LayoutCorpo;
  LabelSenha.Text := 'Senha:';
  LabelSenha.TextSettings.Font.Size := 12;
  LabelSenha.Align := TAlignLayout.Top;
  LabelSenha.Height := 20;
  
  // Edit Senha
  EditSenha := TEdit.Create(Self);
  EditSenha.Parent := LayoutCorpo;
  EditSenha.Align := TAlignLayout.Top;
  EditSenha.Height := 40;
  EditSenha.Margins.Top := 5;
  EditSenha.Margins.Bottom := 15;
  EditSenha.TextSettings.Font.Size := 14;
  EditSenha.Password := True;
  EditSenha.OnChange := EditSenhaChange;
  
  // Label Mensagem
  LabelMensagem := TLabel.Create(Self);
  LabelMensagem.Parent := LayoutCorpo;
  LabelMensagem.Align := TAlignLayout.Top;
  LabelMensagem.Height := 40;
  LabelMensagem.Margins.Bottom := 15;
  LabelMensagem.WordWrap := True;
  LabelMensagem.TextSettings.Font.Size := 11;
  
  // Label Tentativas
  LabelTentativas := TLabel.Create(Self);
  LabelTentativas.Parent := LayoutCorpo;
  LabelTentativas.Text := 'Tentativas: 0/' + IntToStr(TENTATIVAS_MAXIMAS);
  LabelTentativas.TextSettings.Font.Size := 10;
  LabelTentativas.Align := TAlignLayout.Top;
  LabelTentativas.Height := 15;
  LabelTentativas.Margins.Bottom := 5;
  
  // Progress Bar Tentativas
  ProgressBarTentativas := TProgressBar.Create(Self);
  ProgressBarTentativas.Parent := LayoutCorpo;
  ProgressBarTentativas.Align := TAlignLayout.Top;
  ProgressBarTentativas.Height := 5;
  ProgressBarTentativas.Max := TENTATIVAS_MAXIMAS;
  ProgressBarTentativas.Value := 0;
  ProgressBarTentativas.Margins.Bottom := 15;
  
  // Label Operadores Rápidos
  LabelOperadoresRapidos := TLabel.Create(Self);
  LabelOperadoresRapidos.Parent := LayoutCorpo;
  LabelOperadoresRapidos.Text := 'Operadores Rápidos:';
  LabelOperadoresRapidos.TextSettings.Font.Size := 12;
  LabelOperadoresRapidos.Align := TAlignLayout.Top;
  LabelOperadoresRapidos.Height := 20;
  LabelOperadoresRapidos.Margins.Top := 10;
  
  // ScrollBox Operadores
  ScrollBoxOperadores := TScrollBox.Create(Self);
  ScrollBoxOperadores.Parent := LayoutCorpo;
  ScrollBoxOperadores.Align := TAlignLayout.Top;
  ScrollBoxOperadores.Height := 150;
  ScrollBoxOperadores.Margins.Top := 5;
  ScrollBoxOperadores.Margins.Bottom := 15;
  
  // Layout Operadores
  LayoutOperadores := TLayout.Create(Self);
  LayoutOperadores.Parent := ScrollBoxOperadores;
  LayoutOperadores.Align := TAlignLayout.Top;
  LayoutOperadores.AutoSize := True;
  
  // Layout Rodapé
  LayoutRodape := TLayout.Create(Self);
  LayoutRodape.Parent := LayoutPrincipal;
  LayoutRodape.Align := TAlignLayout.Bottom;
  LayoutRodape.Height := 60;
  
  // Botão Entrar
  ButtonEntrar := TButton.Create(Self);
  ButtonEntrar.Parent := LayoutRodape;
  ButtonEntrar.Text := 'ENTRAR';
  ButtonEntrar.Align := TAlignLayout.Left;
  ButtonEntrar.Width := 100;
  ButtonEntrar.OnClick := ButtonEntrarClick;
  
  // Botão Limpar
  ButtonLimpar := TButton.Create(Self);
  ButtonLimpar.Parent := LayoutRodape;
  ButtonLimpar.Text := 'LIMPAR';
  ButtonLimpar.Align := TAlignLayout.Left;
  ButtonLimpar.Width := 100;
  ButtonLimpar.Margins.Left := 5;
  ButtonLimpar.OnClick := ButtonLimparClick;
  
  // Botão Sair
  ButtonSair := TButton.Create(Self);
  ButtonSair.Parent := LayoutRodape;
  ButtonSair.Text := 'SAIR';
  ButtonSair.Align := TAlignLayout.Right;
  ButtonSair.Width := 100;
  ButtonSair.OnClick := ButtonSairClick;
end;

procedure TFormLogin.ConfigurarEstilos;
begin
  // Configurar cores
  Self.Fill.Color := TAlphaColorRec.White;
  
  // Configurar Edit Matrícula
  EditMatricula.StyledSettings := [TStyledSetting.ssFamily, TStyledSetting.ssSize];
  
  // Configurar Edit Senha
  EditSenha.StyledSettings := [TStyledSetting.ssFamily, TStyledSetting.ssSize];
end;

procedure TFormLogin.CarregarOperadoresRapidos;
var
  Operadores: TObjectList<TOperador>;
  Operador: TOperador;
  I: Integer;
begin
  try
    // Limpar operadores anteriores
    LayoutOperadores.DeleteChildren;
    
    // Obter operadores ativos
    Operadores := FRepositorio.ObterAtivos;
    
    if Assigned(Operadores) then
    begin
      for I := 0 to Operadores.Count - 1 do
      begin
        Operador := Operadores[I];
        CriarBotaoOperador(Operador);
      end;
      
      Operadores.Free;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao carregar operadores: ' + E.Message, True);
  end;
end;

function TFormLogin.CriarBotaoOperador(AOperador: TOperador): TButton;
begin
  Result := TButton.Create(Self);
  Result.Parent := LayoutOperadores;
  Result.Text := AOperador.Nome + ' (' + AOperador.Matricula + ')';
  Result.Align := TAlignLayout.Top;
  Result.Height := ALTURA_BOTAO_OPERADOR;
  Result.Margins.Bottom := ESPACAMENTO_BOTOES;
  Result.Tag := AOperador.ID;
  Result.OnClick := OperadorRapidoClick;
end;

procedure TFormLogin.OperadorRapidoClick(Sender: TObject);
var
  Button: TButton;
  Operador: TOperador;
begin
  if not (Sender is TButton) then
    Exit;
  
  Button := TButton(Sender);
  
  try
    // Obter operador
    Operador := FRepositorio.ObterPorID(Button.Tag);
    
    if Assigned(Operador) then
    begin
      // Preencher matrícula
      EditMatricula.Text := Operador.Matricula;
      EditSenha.SetFocus;
      Operador.Free;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao selecionar operador: ' + E.Message, True);
  end;
end;

function TFormLogin.ValidarEntrada: TResultadoLogin;
begin
  Result.Sucesso := False;
  Result.Operador := nil;
  Result.Mensagem := '';
  Result.BloqueadoAte := 0;
  
  // Validar matrícula
  if Trim(EditMatricula.Text) = '' then
  begin
    Result.Mensagem := 'Matrícula não pode estar vazia';
    Exit;
  end;
  
  // Validar senha
  if Trim(EditSenha.Text) = '' then
  begin
    Result.Mensagem := 'Senha não pode estar vazia';
    Exit;
  end;
  
  Result.Sucesso := True;
end;

function TFormLogin.VerificarBloqueio: TResultadoLogin;
var
  Query: TFDQuery;
  BloqueadoAte: TDateTime;
begin
  Result.Sucesso := False;
  Result.Operador := nil;
  Result.Mensagem := '';
  Result.BloqueadoAte := 0;
  
  try
    // Verificar se operador está bloqueado
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := DMConexao.Conexao;
      Query.SQL.Text := 
        'SELECT BloqueadoAte FROM Operadores WHERE Matricula = :Matricula';
      Query.ParamByName('Matricula').AsString := EditMatricula.Text;
      Query.Open;
      
      if not Query.Eof then
      begin
        BloqueadoAte := Query.FieldByName('BloqueadoAte').AsDateTime;
        
        if BloqueadoAte > Now then
        begin
          Result.BloqueadoAte := BloqueadoAte;
          Result.Mensagem := 'Operador bloqueado até ' + 
                            FormatDateTime('hh:mm:ss', BloqueadoAte);
          Exit;
        end;
      end;
    finally
      Query.Free;
    end;
    
    Result.Sucesso := True;
  except
    on E: Exception do
    begin
      Result.Mensagem := 'Erro ao verificar bloqueio: ' + E.Message;
    end;
  end;
end;

function TFormLogin.RealizarLogin: TResultadoLogin;
var
  Operador: TOperador;
  Query: TFDQuery;
begin
  Result.Sucesso := False;
  Result.Operador := nil;
  Result.Mensagem := '';
  Result.BloqueadoAte := 0;
  
  try
    // Validar entrada
    Result := ValidarEntrada;
    if not Result.Sucesso then
      Exit;
    
    // Verificar bloqueio
    Result := VerificarBloqueio;
    if not Result.Sucesso then
      Exit;
    
    // Aguardar entre tentativas
    if FUltimaMatricula = EditMatricula.Text then
      Sleep(TEMPO_ESPERA_ENTRE_TENTATIVAS * 1000);
    
    FUltimaMatricula := EditMatricula.Text;
    
    // Autenticar
    Operador := FRepositorio.Autenticar(EditMatricula.Text, EditSenha.Text);
    
    if Assigned(Operador) then
    begin
      // Login bem-sucedido
      Result.Sucesso := True;
      Result.Operador := Operador;
      Result.Mensagem := 'Login bem-sucedido!';
      FTentativasLogin := 0;
      
      // Registrar em log
      RegistrarTentativaLogin(True);
    end
    else
    begin
      // Login falhou
      Result.Sucesso := False;
      Result.Mensagem := FRepositorio.UltimoErro;
      Inc(FTentativasLogin);
      
      // Registrar em log
      RegistrarTentativaLogin(False, Result.Mensagem);
      
      // Verificar se deve bloquear
      if FTentativasLogin >= TENTATIVAS_MAXIMAS then
      begin
        // Bloquear operador
        Query := TFDQuery.Create(nil);
        try
          Query.Connection := DMConexao.Conexao;
          Query.SQL.Text := 
            'UPDATE Operadores SET BloqueadoAte = datetime(''now'', ''+' + 
            IntToStr(TEMPO_BLOQUEIO_MINUTOS) + ' minutes''), ' +
            'TentativasLoginFalhadas = TentativasLoginFalhadas + 1 ' +
            'WHERE Matricula = :Matricula';
          Query.ParamByName('Matricula').AsString := EditMatricula.Text;
          Query.ExecSQL;
          
          Result.Mensagem := 'Operador bloqueado por ' + IntToStr(TEMPO_BLOQUEIO_MINUTOS) + 
                            ' minutos após ' + IntToStr(TENTATIVAS_MAXIMAS) + ' tentativas';
        finally
          Query.Free;
        end;
      end;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro ao realizar login: ' + E.Message;
    end;
  end;
end;

procedure TFormLogin.AtualizarUIAposTentativa(AResultado: TResultadoLogin);
begin
  // Atualizar indicador de tentativas
  AtualizarIndicadorTentativas;
  
  // Exibir mensagem
  ExibirMensagem(AResultado.Mensagem, not AResultado.Sucesso);
  
  // Se login bem-sucedido
  if AResultado.Sucesso then
  begin
    FOperadorAtual := AResultado.Operador;
    ModalResult := mrOk;
  end
  else
  begin
    // Limpar senha
    EditSenha.Text := '';
    EditSenha.SetFocus;
  end;
end;

procedure TFormLogin.ButtonEntrarClick(Sender: TObject);
var
  Resultado: TResultadoLogin;
begin
  HabilitarControles(False);
  try
    Resultado := RealizarLogin;
    AtualizarUIAposTentativa(Resultado);
  finally
    HabilitarControles(True);
  end;
end;

procedure TFormLogin.ButtonLimparClick(Sender: TObject);
begin
  LimparCampos;
  FTentativasLogin := 0;
  AtualizarIndicadorTentativas;
  ExibirMensagem('');
  EditMatricula.SetFocus;
end;

procedure TFormLogin.ButtonSairClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFormLogin.EditMatriculaChange(Sender: TObject);
begin
  // Limpar mensagem ao editar
  if LabelMensagem.Text <> '' then
    ExibirMensagem('');
end;

procedure TFormLogin.EditSenhaChange(Sender: TObject);
begin
  // Limpar mensagem ao editar
  if LabelMensagem.Text <> '' then
    ExibirMensagem('');
end;

procedure TFormLogin.LimparCampos;
begin
  EditMatricula.Text := '';
  EditSenha.Text := '';
end;

procedure TFormLogin.HabilitarControles(AHabilitar: Boolean);
begin
  EditMatricula.Enabled := AHabilitar;
  EditSenha.Enabled := AHabilitar;
  ButtonEntrar.Enabled := AHabilitar;
  ButtonLimpar.Enabled := AHabilitar;
  ScrollBoxOperadores.Enabled := AHabilitar;
end;

procedure TFormLogin.ExibirMensagem(AMensagem: string; AErro: Boolean = False);
begin
  LabelMensagem.Text := AMensagem;
  
  if AErro then
    LabelMensagem.TextSettings.FontColor := TAlphaColorRec.Red
  else
    LabelMensagem.TextSettings.FontColor := TAlphaColorRec.Green;
end;

procedure TFormLogin.AtualizarIndicadorTentativas;
begin
  LabelTentativas.Text := 'Tentativas: ' + IntToStr(FTentativasLogin) + '/' + 
                         IntToStr(TENTATIVAS_MAXIMAS);
  ProgressBarTentativas.Value := FTentativasLogin;
end;

procedure TFormLogin.RegistrarTentativaLogin(ASucesso: Boolean; AMotivo: string = '');
var
  Query: TFDQuery;
begin
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := DMConexao.Conexao;
      Query.SQL.Text := 
        'INSERT INTO LogAcessoOperador (Matricula, Sucesso, Motivo) ' +
        'VALUES (:Matricula, :Sucesso, :Motivo)';
      Query.ParamByName('Matricula').AsString := EditMatricula.Text;
      Query.ParamByName('Sucesso').AsBoolean := ASucesso;
      
      if ASucesso then
        Query.ParamByName('Motivo').AsString := 'LOGIN_SUCESSO'
      else
        Query.ParamByName('Motivo').AsString := AMotivo;
      
      Query.ExecSQL;
    finally
      Query.Free;
    end;
  except
    // Ignorar erros de log
  end;
end;

function TFormLogin.GetOperadorAutenticado: TOperador;
begin
  Result := FOperadorAtual;
end;

{$ENDREGION}

end.
