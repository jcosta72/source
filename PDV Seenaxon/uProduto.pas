unit uProduto;

interface

uses
  System.SysUtils;

type
  TCategoria = (ctBebidas, ctAlimentos, ctLimpeza, ctHigiene, ctOutros);
  
  { Unidade de medida para produtos }
  TUnidadeMedida = (umUnidade, umKG, umGramas, umLitro, umMililitro, umMetro, umCentimetro);

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
    FUnidadeMedida: TUnidadeMedida;
    FPermiteDecimais: Boolean;
    FPrecisaoDecimal: Integer;
    
    function GetCategoriaNome: string;
    function GetPrecoFormatado: string;
    function GetDescricaoCompleta: string;
    function GetUnidadeMedidaNome: string;
    function GetPermiteDecimaisAutomatico: Boolean;
    function GetFormatoQuantidade: string;
  public
    constructor Create(AID: Integer; ANome, ADescricao: string; APreco: Double; 
      ACodigoBarras: string = ''; ACategoria: TCategoria = ctOutros; 
      AEstoque: Integer = 0; AImagemPath: string = ''; 
      AUnidadeMedida: TUnidadeMedida = umUnidade);
    
    { Métodos de validação }
    function ValidarEstoque(AQuantidade: Integer): Boolean;
    function TemEstoque: Boolean;
    procedure AtualizarEstoque(AQuantidade: Integer);
    
    { Métodos de busca }
    function ContemPalavra(APalavra: string): Boolean;
    function ContemCodigoBarras(ACodigo: string): Boolean;
    
    { Métodos de formatação de quantidade }
    function FormatarQuantidade(AQuantidade: Double): string;
    function ValidarQuantidade(AQuantidade: Double): Boolean;
    function AjustarQuantidade(AQuantidade: Double): Double;
    
    { Propriedades }
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
    property UnidadeMedida: TUnidadeMedida read FUnidadeMedida write FUnidadeMedida;
    property PermiteDecimais: Boolean read GetPermiteDecimaisAutomatico;
    property PrecisaoDecimal: Integer read FPrecisaoDecimal write FPrecisaoDecimal;
    
    { Propriedades calculadas }
    property CategoriaNome: string read GetCategoriaNome;
    property PrecoFormatado: string read GetPrecoFormatado;
    property DescricaoCompleta: string read GetDescricaoCompleta;
    property UnidadeMedidaNome: string read GetUnidadeMedidaNome;
    property FormatoQuantidade: string read GetFormatoQuantidade;
  end;

implementation

constructor TProduto.Create(AID: Integer; ANome, ADescricao: string; APreco: Double; 
  ACodigoBarras: string = ''; ACategoria: TCategoria = ctOutros; 
  AEstoque: Integer = 0; AImagemPath: string = ''; 
  AUnidadeMedida: TUnidadeMedida = umUnidade);
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
  FUnidadeMedida := AUnidadeMedida;
  FAtivo := True;
  FDataCadastro := Now;
  
  { Definir precisão decimal baseado na unidade de medida }
  case FUnidadeMedida of
    umKG, umGramas, umLitro, umMililitro, umMetro, umCentimetro:
      FPrecisaoDecimal := 2;
  else
    FPrecisaoDecimal := 0;
  end;
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

function TProduto.GetUnidadeMedidaNome: string;
begin
  case FUnidadeMedida of
    umUnidade: Result := 'Unidade';
    umKG: Result := 'KG';
    umGramas: Result := 'g';
    umLitro: Result := 'L';
    umMililitro: Result := 'mL';
    umMetro: Result := 'm';
    umCentimetro: Result := 'cm';
  else
    Result := 'Unidade';
  end;
end;

function TProduto.GetPermiteDecimaisAutomatico: Boolean;
begin
  { Unidades de medida que permitem casas decimais }
  Result := FUnidadeMedida in [umKG, umGramas, umLitro, umMililitro, umMetro, umCentimetro];
end;

function TProduto.GetFormatoQuantidade: string;
begin
  if PermiteDecimais then
    Result := '0.00'
  else
    Result := '0';
end;

function TProduto.GetPrecoFormatado: string;
begin
  Result := FormatFloat('R$ 0.00', FPreco);
end;

function TProduto.GetDescricaoCompleta: string;
begin
  Result := Format('%s - %s (%s) [%s]', 
    [FNome, FDescricao, CategoriaNome, UnidadeMedidaNome]);
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

function TProduto.FormatarQuantidade(AQuantidade: Double): string;
begin
  if PermiteDecimais then
    Result := FormatFloat(GetFormatoQuantidade, AQuantidade)
  else
    Result := IntToStr(Trunc(AQuantidade));
end;

function TProduto.ValidarQuantidade(AQuantidade: Double): Boolean;
begin
  { Validar quantidade }
  if AQuantidade <= 0 then
    Result := False
  else if not PermiteDecimais then
    { Se não permite decimais, deve ser inteiro }
    Result := (AQuantidade = Trunc(AQuantidade))
  else
    { Se permite decimais, verificar precisão }
    Result := True;
end;

function TProduto.AjustarQuantidade(AQuantidade: Double): Double;
begin
  Result := AQuantidade;
  
  { Se não permite decimais, arredondar para inteiro }
  if not PermiteDecimais then
    Result := Trunc(Result)
  else
  begin
    { Se permite decimais, arredondar para a precisão definida }
    case FPrecisaoDecimal of
      0: Result := Trunc(Result);
      1: Result := Round(Result * 10) / 10;
      2: Result := Round(Result * 100) / 100;
      3: Result := Round(Result * 1000) / 1000;
    else
      Result := Round(Result * 100) / 100;
    end;
  end;
end;

end.
