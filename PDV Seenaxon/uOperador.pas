unit uOperador;

interface

type
  TOperador = class
  private
    FID: Integer;
    FNome: string;
    FMatricula: string;
    FSenha: string;
    FDataCadastro: TDateTime;
    FAtivo: Boolean;
  public
    constructor Create(AID: Integer; ANome, AMatricula, ASenha: string);
    
    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property Matricula: string read FMatricula write FMatricula;
    property Senha: string read FSenha write FSenha;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

uses
  System.SysUtils;

constructor TOperador.Create(AID: Integer; ANome, AMatricula, ASenha: string);
begin
  inherited Create;
  FID := AID;
  FNome := ANome;
  FMatricula := AMatricula;
  FSenha := ASenha;
  FDataCadastro := Now;
  FAtivo := True;
end;

end.
