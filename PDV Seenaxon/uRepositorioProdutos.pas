unit uRepositorioProdutos;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  uProduto;

type
  TRepositorioProdutos = class
  private
    FProdutos: TObjectList<TProduto>;
    FProximoID: Integer;
    
    procedure CarregarProdutosPadrao;
  public
    constructor Create;
    destructor Destroy; override;
    
    // Operações CRUD
    procedure AdicionarProduto(AProduto: TProduto);
    procedure RemoverProduto(AID: Integer);
    procedure AtualizarProduto(AProduto: TProduto);
    
    // Consultas
    function ObterProduto(AID: Integer): TProduto;
    function ObterTodos: TObjectList<TProduto>;
    function ObterAtivos: TObjectList<TProduto>;
    
    // Buscas
    function BuscarPorNome(ANome: string): TObjectList<TProduto>;
    function BuscarPorCodigoBarras(ACodigo: string): TProduto;
    function BuscarPorCategoria(ACategoria: TCategoria): TObjectList<TProduto>;
    function BuscarPorPreco(APrecoMin, APrecoMax: Double): TObjectList<TProduto>;
    
    // Estatísticas
    function ObterQuantidadeProdutos: Integer;
    function ObterQuantidadeAtivos: Integer;
    function ObterValorTotalEstoque: Double;
    
    property Produtos: TObjectList<TProduto> read FProdutos;
  end;

implementation

constructor TRepositorioProdutos.Create;
begin
  inherited Create;
  FProdutos := TObjectList<TProduto>.Create;
  FProximoID := 1;
  CarregarProdutosPadrao;
end;

destructor TRepositorioProdutos.Destroy;
begin
  if Assigned(FProdutos) then
    FProdutos.Free;
  inherited;
end;

procedure TRepositorioProdutos.CarregarProdutosPadrao;
var
  Produto: TProduto;
begin
  // Bebidas
  Produto := TProduto.Create(FProximoID, 'ÁGUA MINERAL', 'Água mineral 1.5L', 2.50, '7891234567890', ctBebidas, 50);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'REFRIGERANTE COLA', 'Refrigerante 2L', 8.50, '7891234567891', ctBebidas, 30);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'SUCO NATURAL', 'Suco natural 1L', 6.50, '7891234567892', ctBebidas, 25);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'CAFÉ', 'Café 500g', 12.00, '7891234567893', ctBebidas, 40);
  AdicionarProduto(Produto);
  
  // Alimentos
  Produto := TProduto.Create(FProximoID, 'PÃO FRANCÊS', 'Pão francês fresco', 0.50, '7891234567894', ctAlimentos, 100);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'QUEIJO MEIA CURA', 'Queijo 500g', 18.00, '7891234567895', ctAlimentos, 20);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'PRESUNTO', 'Presunto 500g', 15.00, '7891234567896', ctAlimentos, 15);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'MANTEIGA', 'Manteiga 200g', 8.50, '7891234567897', ctAlimentos, 35);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'LEITE INTEGRAL', 'Leite 1L', 4.50, '7891234567898', ctAlimentos, 60);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'IOGURTE', 'Iogurte 500g', 6.00, '7891234567899', ctAlimentos, 45);
  AdicionarProduto(Produto);
  
  // Limpeza
  Produto := TProduto.Create(FProximoID, 'DETERGENTE', 'Detergente 500ml', 2.50, '7891234567900', ctLimpeza, 80);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'DESINFETANTE', 'Desinfetante 1L', 5.50, '7891234567901', ctLimpeza, 50);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'SABÃO EM PÓ', 'Sabão em pó 1kg', 8.00, '7891234567902', ctLimpeza, 40);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'AMACIANTE', 'Amaciante 1L', 7.50, '7891234567903', ctLimpeza, 35);
  AdicionarProduto(Produto);
  
  // Higiene
  Produto := TProduto.Create(FProximoID, 'SABONETE', 'Sabonete 90g', 2.00, '7891234567904', ctHigiene, 100);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'SHAMPOO', 'Shampoo 250ml', 8.50, '7891234567905', ctHigiene, 50);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'CONDICIONADOR', 'Condicionador 250ml', 8.50, '7891234567906', ctHigiene, 45);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'PASTA DE DENTE', 'Pasta de dente 90g', 5.00, '7891234567907', ctHigiene, 70);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'DESODORANTE', 'Desodorante 150ml', 10.00, '7891234567908', ctHigiene, 60);
  AdicionarProduto(Produto);
  
  // Outros
  Produto := TProduto.Create(FProximoID, 'PAPEL HIGIÊNICO', 'Papel higiênico 4 rolos', 5.50, '7891234567909', ctOutros, 100);
  AdicionarProduto(Produto);
  
  Produto := TProduto.Create(FProximoID, 'GUARDANAPO', 'Guardanapo 50 folhas', 2.50, '7891234567910', ctOutros, 80);
  AdicionarProduto(Produto);
end;

procedure TRepositorioProdutos.AdicionarProduto(AProduto: TProduto);
begin
  if Assigned(AProduto) then
  begin
    AProduto.ID := FProximoID;
    FProdutos.Add(AProduto);
    Inc(FProximoID);
  end;
end;

procedure TRepositorioProdutos.RemoverProduto(AID: Integer);
var
  i: Integer;
begin
  for i := FProdutos.Count - 1 downto 0 do
  begin
    if FProdutos[i].ID = AID then
    begin
      FProdutos.Delete(i);
      Exit;
    end;
  end;
end;

procedure TRepositorioProdutos.AtualizarProduto(AProduto: TProduto);
var
  i: Integer;
begin
  for i := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[i].ID = AProduto.ID then
    begin
      FProdutos[i] := AProduto;
      Exit;
    end;
  end;
end;

function TRepositorioProdutos.ObterProduto(AID: Integer): TProduto;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[i].ID = AID then
    begin
      Result := FProdutos[i];
      Exit;
    end;
  end;
end;

function TRepositorioProdutos.ObterTodos: TObjectList<TProduto>;
var
  i: Integer;
  Lista: TObjectList<TProduto>;
begin
  Lista := TObjectList<TProduto>.Create(False); // False = não libera objetos
  for i := 0 to FProdutos.Count - 1 do
    Lista.Add(FProdutos[i]);
  Result := Lista;
end;

function TRepositorioProdutos.ObterAtivos: TObjectList<TProduto>;
var
  i: Integer;
  Lista: TObjectList<TProduto>;
begin
  Lista := TObjectList<TProduto>.Create(False);
  for i := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[i].Ativo then
      Lista.Add(FProdutos[i]);
  end;
  Result := Lista;
end;

function TRepositorioProdutos.BuscarPorNome(ANome: string): TObjectList<TProduto>;
var
  i: Integer;
  Lista: TObjectList<TProduto>;
begin
  Lista := TObjectList<TProduto>.Create(False);
  
  if ANome = '' then
  begin
    Result := ObterTodos;
    Lista.Free;
    Exit;
  end;
  
  for i := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[i].ContemPalavra(ANome) then
      Lista.Add(FProdutos[i]);
  end;
  
  Result := Lista;
end;

function TRepositorioProdutos.BuscarPorCodigoBarras(ACodigo: string): TProduto;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[i].ContemCodigoBarras(ACodigo) then
    begin
      Result := FProdutos[i];
      Exit;
    end;
  end;
end;

function TRepositorioProdutos.BuscarPorCategoria(ACategoria: TCategoria): TObjectList<TProduto>;
var
  i: Integer;
  Lista: TObjectList<TProduto>;
begin
  Lista := TObjectList<TProduto>.Create(False);
  
  for i := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[i].Categoria = ACategoria then
      Lista.Add(FProdutos[i]);
  end;
  
  Result := Lista;
end;

function TRepositorioProdutos.BuscarPorPreco(APrecoMin, APrecoMax: Double): TObjectList<TProduto>;
var
  i: Integer;
  Lista: TObjectList<TProduto>;
begin
  Lista := TObjectList<TProduto>.Create(False);
  
  for i := 0 to FProdutos.Count - 1 do
  begin
    if (FProdutos[i].Preco >= APrecoMin) and (FProdutos[i].Preco <= APrecoMax) then
      Lista.Add(FProdutos[i]);
  end;
  
  Result := Lista;
end;

function TRepositorioProdutos.ObterQuantidadeProdutos: Integer;
begin
  Result := FProdutos.Count;
end;

function TRepositorioProdutos.ObterQuantidadeAtivos: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[i].Ativo then
      Inc(Result);
  end;
end;

function TRepositorioProdutos.ObterValorTotalEstoque: Double;
var
  i: Integer;
begin
  Result := 0;
  for i := 0 to FProdutos.Count - 1 do
    Result := Result + (FProdutos[i].Preco * FProdutos[i].Estoque);
end;

end.
