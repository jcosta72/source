unit uOperador;

interface

type
  TOperador = class
  private
    FID: Integer;
    FNome: string;
    FMatricula: string;
    FEmail: string;
    FTelefone: string;
    FSenha: string;
    FDataCadastro: TDateTime;
    FDataUltimoAcesso: TDateTime;
    FAtivo: Boolean;
  public
    //constructor Create(AID: Integer; ANome, AMatricula, ASenha: string);
    constructor Create;

    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property Matricula: string read FMatricula write FMatricula;
    property Email: string read FEmail write FEmail;
    property Telefone: string read FTelefone write FTelefone;
    property Senha: string read FSenha write FSenha;
    property DataCadastro: TDateTime read FDataCadastro write FDataCadastro;
    property DataUltimoAcesso: TDateTime read FDataUltimoAcesso write FDataUltimoAcesso;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

uses
  System.SysUtils;

constructor TOperador.Create;
begin
  inherited Create;
//  FID := AID;
//  FNome := ANome;
//  FMatricula := AMatricula;
//  FSenha := ASenha;
  FDataCadastro := Now;
  FAtivo := True;
end;

end.
