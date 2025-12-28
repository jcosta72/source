unit uRepositorioOperadores;

interface

uses
  System.Generics.Collections,
  uOperador;

type
  TRepositorioOperadores = class
  private
    FOperadores: TObjectList<TOperador>;
    FProximoID: Integer;
  public
    constructor Create;
    destructor Destroy; override;
    
    procedure AdicionarOperador(AOperador: TOperador);
    procedure RemoverOperador(AID: Integer);
    function ObterOperador(AID: Integer): TOperador;
    function BuscarPorMatricula(AMatricula: string): TOperador;
    function ValidarCredenciais(AMatricula, ASenha: string): TOperador;
    function ObterTodos: TObjectList<TOperador>;
    procedure Limpar;
    
    property Operadores: TObjectList<TOperador> read FOperadores;
    property ProximoID: Integer read FProximoID;
  end;

implementation

uses
  System.SysUtils;

constructor TRepositorioOperadores.Create;
begin
  inherited Create;
  FOperadores := TObjectList<TOperador>.Create;
  FProximoID := 1;
  
  // Adiciona operadores de teste
  AdicionarOperador(TOperador.Create(FProximoID, 'MARCOS SILVA DE MATOS', '001', '1234'));
  Inc(FProximoID);
  AdicionarOperador(TOperador.Create(FProximoID, 'JOÃO SANTOS', '002', '5678'));
  Inc(FProximoID);
  AdicionarOperador(TOperador.Create(FProximoID, 'MARIA OLIVEIRA', '003', '9012'));
  Inc(FProximoID);
  AdicionarOperador(TOperador.Create(FProximoID, 'PEDRO COSTA', '004', '3456'));
  Inc(FProximoID);
end;

destructor TRepositorioOperadores.Destroy;
begin
  if Assigned(FOperadores) then
    FOperadores.Free;
  inherited;
end;

procedure TRepositorioOperadores.AdicionarOperador(AOperador: TOperador);
begin
  if Assigned(AOperador) then
    FOperadores.Add(AOperador);
end;

procedure TRepositorioOperadores.RemoverOperador(AID: Integer);
var
  i: Integer;
begin
  for i := 0 to FOperadores.Count - 1 do
  begin
    if FOperadores[i].ID = AID then
    begin
      FOperadores.Delete(i);
      Exit;
    end;
  end;
end;

function TRepositorioOperadores.ObterOperador(AID: Integer): TOperador;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FOperadores.Count - 1 do
  begin
    if FOperadores[i].ID = AID then
    begin
      Result := FOperadores[i];
      Exit;
    end;
  end;
end;

function TRepositorioOperadores.BuscarPorMatricula(AMatricula: string): TOperador;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FOperadores.Count - 1 do
  begin
    if FOperadores[i].Matricula = AMatricula then
    begin
      Result := FOperadores[i];
      Exit;
    end;
  end;
end;

function TRepositorioOperadores.ValidarCredenciais(AMatricula, ASenha: string): TOperador;
var
  Operador: TOperador;
begin
  Result := nil;
  Operador := BuscarPorMatricula(AMatricula);
  
  if Assigned(Operador) then
  begin
    if (Operador.Senha = ASenha) and Operador.Ativo then
      Result := Operador;
  end;
end;

function TRepositorioOperadores.ObterTodos: TObjectList<TOperador>;
begin
  Result := FOperadores;
end;

procedure TRepositorioOperadores.Limpar;
begin
  FOperadores.Clear;
  FProximoID := 1;
end;

end.
