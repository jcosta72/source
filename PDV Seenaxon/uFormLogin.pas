unit uFormLogin;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Edit, FMX.Buttons, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.ListBox,
  uOperador, uRepositorioOperadores;

type
  TFormLogin = class(TForm)
    PanelPrincipal: TPanel;
    PanelLogo: TPanel;
    LabelTitulo: TLabel;
    LabelSubtitulo: TLabel;
    PanelFormulario: TPanel;
    LabelMatricula: TLabel;
    EditMatricula: TEdit;
    LabelSenha: TLabel;
    EditSenha: TEdit;
    PanelBotoes: TPanel;
    ButtonEntrar: TButton;
    ButtonSair: TButton;
    LabelMensagem: TLabel;
    PanelOperadores: TPanel;
    LabelOperadoresRapidos: TLabel;
    ListBoxOperadores: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonEntrarClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);
    procedure EditMatriculaKeyDown(Sender: TObject; var Key: Word; var KeyData: TShiftState);
    procedure EditSenhaKeyDown(Sender: TObject; var Key: Word; var KeyData: TShiftState);
    procedure ListBoxOperadoresItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
  private
    FRepositorioOperadores: TRepositorioOperadores;
    FOperadorLogado: TOperador;
    
    procedure CarregarOperadores;
    procedure LimparCampos;
    procedure ExibirMensagem(AMensagem: string; AErro: Boolean = False);
    procedure RealizarLogin;
  public
    property OperadorLogado: TOperador read FOperadorLogado;
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.fmx}

procedure TFormLogin.FormCreate(Sender: TObject);
begin
  FRepositorioOperadores := TRepositorioOperadores.Create;
  FOperadorLogado := nil;
  
  CarregarOperadores;
  LimparCampos;
  
  // Define foco no primeiro campo
  EditMatricula.SetFocus;
  
  LabelMensagem.Text := '';
end;

procedure TFormLogin.FormDestroy(Sender: TObject);
begin
  if Assigned(FRepositorioOperadores) then
    FRepositorioOperadores.Free;
end;

procedure TFormLogin.CarregarOperadores;
var
  i: Integer;
  Item: TListBoxItem;
  Operador: TOperador;
begin
  ListBoxOperadores.Clear;
  
  for i := 0 to FRepositorioOperadores.ObterTodos.Count - 1 do
  begin
    Operador := FRepositorioOperadores.ObterTodos[i];
    if Operador.Ativo then
    begin
      Item := TListBoxItem.Create(ListBoxOperadores);
      Item.Parent := ListBoxOperadores;
      Item.Text := Format('%s (Matrícula: %s)', [Operador.Nome, Operador.Matricula]);
      Item.Tag := Operador.ID;
    end;
  end;
end;

procedure TFormLogin.LimparCampos;
begin
  EditMatricula.Text := '';
  EditSenha.Text := '';
  LabelMensagem.Text := '';
end;

procedure TFormLogin.ExibirMensagem(AMensagem: string; AErro: Boolean = False);
begin
  LabelMensagem.Text := AMensagem;
  if AErro then
    LabelMensagem.TextSettings.FontColor := claRed
  else
    LabelMensagem.TextSettings.FontColor := claGreen;
end;

procedure TFormLogin.RealizarLogin;
var
  Matricula, Senha: string;
begin
  Matricula := EditMatricula.Text.Trim;
  Senha := EditSenha.Text;
  
  // Validações
  if Matricula.IsEmpty then
  begin
    ExibirMensagem('Digite a matrícula do operador', True);
    EditMatricula.SetFocus;
    Exit;
  end;
  
  if Senha.IsEmpty then
  begin
    ExibirMensagem('Digite a senha', True);
    EditSenha.SetFocus;
    Exit;
  end;
  
  // Valida credenciais
  FOperadorLogado := FRepositorioOperadores.ValidarCredenciais(Matricula, Senha);
  
  if Assigned(FOperadorLogado) then
  begin
    ExibirMensagem(Format('Bem-vindo, %s!', [FOperadorLogado.Nome]), False);
    
    // Aguarda um pouco para exibir a mensagem
    Sleep(500);
    
    // Fecha o formulário de login
    ModalResult := mrOk;
  end
  else
  begin
    ExibirMensagem('Matrícula ou senha incorreta!', True);
    LimparCampos;
    EditMatricula.SetFocus;
  end;
end;

procedure TFormLogin.ButtonEntrarClick(Sender: TObject);
begin
  RealizarLogin;
end;

procedure TFormLogin.ButtonSairClick(Sender: TObject);
begin
  FOperadorLogado := nil;
  ModalResult := mrCancel;
end;

procedure TFormLogin.EditMatriculaKeyDown(Sender: TObject; var Key: Word; var KeyData: TShiftState);
begin
  if Key = vkReturn then
  begin
    EditSenha.SetFocus;
    Key := 0;
  end;
end;

procedure TFormLogin.EditSenhaKeyDown(Sender: TObject; var Key: Word; var KeyData: TShiftState);
begin
  if Key = vkReturn then
  begin
    RealizarLogin;
    Key := 0;
  end;
end;

procedure TFormLogin.ListBoxOperadoresItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
var
  Operador: TOperador;
begin
  if Assigned(Item) then
  begin
    Operador := FRepositorioOperadores.ObterOperador(Item.Tag);
    if Assigned(Operador) then
    begin
      EditMatricula.Text := Operador.Matricula;
      EditSenha.SetFocus;
      ExibirMensagem('Digite a senha para ' + Operador.Nome, False);
    end;
  end;
end;

end.
