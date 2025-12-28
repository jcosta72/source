unit uProduto;

interface

uses
  System.SysUtils;

type
  TCategoria = (ctBebidas, ctAlimentos, ctLimpeza, ctHigiene, ctOutros);

  TProduto = class
  private
    FID: Integer;
    FNome: string;
    FDescricao: string;
    FPreco: Double;
    FImagemPath: string;
    FCodigoBarras: string;
    FCategoria: TCategoria;
    FEstoque: Integer;
    FAtivo: Boolean;
    FDataCadastro: TDateTime;
    
    function GetCategoriaNome: string;
    function GetPrecoFormatado: string;
    function GetDescricaoCompleta: string;
  public
    constructor Create(AID: Integer; ANome, ADescricao: string; APreco: Double; 
      ACodigoBarras: string = ''; ACategoria: TCategoria = ctOutros; 
      AEstoque: Integer = 0; AImagemPath: string = '');
    
    // Métodos de validação
    function ValidarEstoque(AQuantidade: Integer): Boolean;
    function TemEstoque: Boolean;
    procedure AtualizarEstoque(AQuantidade: Integer);
    
    // Métodos de busca
    function ContemPalavra(APalavra: string): Boolean;
    function ContemCodigoBarras(ACodigo: string): Boolean;
    
    // Propriedades
    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property Descricao: string read FDescricao write FDescricao;
    property Preco: Double read FPreco write FPreco;
    property ImagemPath: string read FImagemPath write FImagemPath;
    property CodigoBarras: string read FCodigoBarras write FCodigoBarras;
    property Categoria: TCategoria read FCategoria write FCategoria;
    property Estoque: Integer read FEstoque write FEstoque;
    property Ativo: Boolean read FAtivo write FAtivo;
    property DataCadastro: TDateTime read FDataCadastro;
    
    // Propriedades calculadas
    property CategoriaNome: string read GetCategoriaNome;
    property PrecoFormatado: string read GetPrecoFormatado;
    property DescricaoCompleta: string read GetDescricaoCompleta;
  end;

implementation

constructor TProduto.Create(AID: Integer; ANome, ADescricao: string; APreco: Double; 
  ACodigoBarras: string = ''; ACategoria: TCategoria = ctOutros; 
  AEstoque: Integer = 0; AImagemPath: string = '');
begin
  inherited Create;
  FID := AID;
  FNome := ANome;
  FDescricao := ADescricao;
  FPreco := APreco;
  FCodigoBarras := ACodigoBarras;
  FCategoria := ACategoria;
  FEstoque := AEstoque;
  FImagemPath := AImagemPath;
  FAtivo := True;
  FDataCadastro := Now;
end;

function TProduto.GetCategoriaNome: string;
begin
  case FCategoria of
    ctBebidas: Result := 'Bebidas';
    ctAlimentos: Result := 'Alimentos';
    ctLimpeza: Result := 'Limpeza';
    ctHigiene: Result := 'Higiene';
  else
    Result := 'Outros';
  end;
end;

function TProduto.GetPrecoFormatado: string;
begin
  Result := FormatFloat('R$ 0.00', FPreco);
end;

function TProduto.GetDescricaoCompleta: string;
begin
  Result := Format('%s - %s (%s)', [FNome, FDescricao, CategoriaNome]);
end;

function TProduto.ValidarEstoque(AQuantidade: Integer): Boolean;
begin
  Result := (FEstoque >= AQuantidade) and (AQuantidade > 0);
end;

function TProduto.TemEstoque: Boolean;
begin
  Result := FEstoque > 0;
end;

procedure TProduto.AtualizarEstoque(AQuantidade: Integer);
begin
  FEstoque := FEstoque - AQuantidade;
  if FEstoque < 0 then
    FEstoque := 0;
end;

function TProduto.ContemPalavra(APalavra: string): Boolean;
var
  PalavraUpper: string;
begin
  PalavraUpper := UpperCase(APalavra);
  Result := (Pos(PalavraUpper, UpperCase(FNome)) > 0) or
            (Pos(PalavraUpper, UpperCase(FDescricao)) > 0);
end;

function TProduto.ContemCodigoBarras(ACodigo: string): Boolean;
begin
  Result := FCodigoBarras = ACodigo;
end;

end.
