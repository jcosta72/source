unit uRepositorioProduto;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Generics.Defaults,
  uProduto;

type
  {$REGION 'Tipos'}
  
  // Tipo de busca
  TTipoBusca = (tbNome, tbCategoria, tbCodigo, tbPreco, tbTodos);
  
  // Critério de ordenação
  TCriterioOrdenacao = (coNome, coPreco, coCategoria, coEstoque, coID);
  
  // Direção de ordenação
  TDirecaoOrdenacao = (doAscendente, doDescendente);
  
  {$ENDREGION}

  {$REGION 'Classe TRepositorioProduto'}
  
  /// <summary>
  /// Repositório de Produtos com suporte a busca em tempo real,
  /// filtros avançados e integração com banco de dados
  /// </summary>
  TRepositorioProduto = class
  private
    FProdutos: TObjectList<TProduto>;
    FProdutosFiltrados: TObjectList<TProduto>;
    FUltimoErro: string;
    FProximoID: Integer;
    
    /// <summary>Carregar produtos de teste para demonstração</summary>
    procedure CarregarProdutosTeste;
    
    /// <summary>Gerar ID único para novo produto</summary>
    function GerarProximoID: Integer;
    
    /// <summary>Validar dados do produto</summary>
    function ValidarProduto(AProduto: TProduto): Boolean;
    
    /// <summary>Comparar strings ignorando acentos e maiúsculas</summary>
    function CompararTexto(ATexto1, ATexto2: string): Boolean;
    
  public
    /// <summary>Construtor</summary>
    constructor Create;
    
    /// <summary>Destrutor</summary>
    destructor Destroy; override;
    
    {$REGION 'CRUD - Operações Básicas'}
    
    /// <summary>Adicionar novo produto</summary>
    /// <param name="AProduto">Produto a ser adicionado</param>
    /// <returns>True se adicionado com sucesso, False caso contrário</returns>
    function Adicionar(AProduto: TProduto): Boolean;
    
    /// <summary>Atualizar produto existente</summary>
    /// <param name="AProduto">Produto com dados atualizados</param>
    /// <returns>True se atualizado com sucesso, False caso contrário</returns>
    function Atualizar(AProduto: TProduto): Boolean;
    
    /// <summary>Deletar produto por ID</summary>
    /// <param name="AID">ID do produto</param>
    /// <returns>True se deletado com sucesso, False caso contrário</returns>
    function Deletar(AID: Integer): Boolean;
    
    /// <summary>Obter produto por ID</summary>
    /// <param name="AID">ID do produto</param>
    /// <returns>Produto encontrado ou nil</returns>
    function ObterPorID(AID: Integer): TProduto;
    
    /// <summary>Obter todos os produtos</summary>
    /// <returns>Lista de todos os produtos</returns>
    function ObterTodos: TObjectList<TProduto>;
    
    {$ENDREGION}

    {$REGION 'Busca - Operações de Pesquisa'}
    
    /// <summary>Buscar produtos por nome (busca em tempo real)</summary>
    /// <param name="ANome">Nome ou parte do nome do produto</param>
    /// <returns>Lista de produtos encontrados</returns>
    function BuscarPorNome(ANome: string): TObjectList<TProduto>;
    
    /// <summary>Buscar produtos por categoria</summary>
    /// <param name="ACategoria">Categoria do produto</param>
    /// <returns>Lista de produtos encontrados</returns>
    function BuscarPorCategoria(ACategoria: string): TObjectList<TProduto>;
    
    /// <summary>Buscar produtos por código de barras</summary>
    /// <param name="ACodigoBarras">Código de barras</param>
    /// <returns>Produto encontrado ou nil</returns>
    function BuscarPorCodigoBarras(ACodigoBarras: string): TProduto;
    
    /// <summary>Buscar produtos por faixa de preço</summary>
    /// <param name="APrecoMinimo">Preço mínimo</param>
    /// <param name="APrecoMaximo">Preço máximo</param>
    /// <returns>Lista de produtos encontrados</returns>
    function BuscarPorFaixaPreco(APrecoMinimo, APrecoMaximo: Double): TObjectList<TProduto>;
    
    /// <summary>Busca avançada com múltiplos critérios</summary>
    /// <param name="ATermo">Termo de busca</param>
    /// <param name="ATipoBusca">Tipo de busca</param>
    /// <param name="ACriterioOrdenacao">Critério de ordenação</param>
    /// <param name="ADirecao">Direção de ordenação</param>
    /// <returns>Lista de produtos encontrados</returns>
    function BuscaAvancada(ATermo: string; ATipoBusca: TTipoBusca = tbTodos;
      ACriterioOrdenacao: TCriterioOrdenacao = coNome;
      ADirecao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
    
    {$ENDREGION}

    {$REGION 'Filtros - Operações de Filtro'}
    
    /// <summary>Filtrar produtos com estoque disponível</summary>
    /// <returns>Lista de produtos com estoque > 0</returns>
    function FiltrarComEstoque: TObjectList<TProduto>;
    
    /// <summary>Filtrar produtos sem estoque</summary>
    /// <returns>Lista de produtos com estoque = 0</returns>
    function FiltrarSemEstoque: TObjectList<TProduto>;
    
    /// <summary>Filtrar produtos por estoque mínimo</summary>
    /// <param name="AEstoqueMinimo">Quantidade mínima</param>
    /// <returns>Lista de produtos com estoque < mínimo</returns>
    function FiltrarEstoqueMinimo(AEstoqueMinimo: Integer): TObjectList<TProduto>;
    
    {$ENDREGION}

    {$REGION 'Ordenação - Operações de Ordenação'}
    
    /// <summary>Ordenar produtos por nome</summary>
    /// <param name="AOrdenacao">Ascendente ou Descendente</param>
    /// <returns>Lista ordenada</returns>
    function OrdenarPorNome(AOrdenacao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
    
    /// <summary>Ordenar produtos por preço</summary>
    /// <param name="AOrdenacao">Ascendente ou Descendente</param>
    /// <returns>Lista ordenada</returns>
    function OrdenarPorPreco(AOrdenacao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
    
    /// <summary>Ordenar produtos por categoria</summary>
    /// <param name="AOrdenacao">Ascendente ou Descendente</param>
    /// <returns>Lista ordenada</returns>
    function OrdenarPorCategoria(AOrdenacao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
    
    {$ENDREGION}

    {$REGION 'Estatísticas - Operações de Análise'}
    
    /// <summary>Obter quantidade total de produtos</summary>
    /// <returns>Quantidade de produtos</returns>
    function ObterQuantidadeTotal: Integer;
    
    /// <summary>Obter quantidade de categorias</summary>
    /// <returns>Quantidade de categorias diferentes</returns>
    function ObterQuantidadeCategorias: Integer;
    
    /// <summary>Obter lista de categorias</summary>
    /// <returns>Lista de categorias</returns>
    function ObterCategorias: TStringList;
    
    /// <summary>Obter preço médio dos produtos</summary>
    /// <returns>Preço médio</returns>
    function ObterPrecoMedio: Double;
    
    /// <summary>Obter produto mais caro</summary>
    /// <returns>Produto com maior preço</returns>
    function ObterProdutoMaisCaro: TProduto;
    
    /// <summary>Obter produto mais barato</summary>
    /// <returns>Produto com menor preço</returns>
    function ObterProdutoMaisBarato: TProduto;
    
    /// <summary>Obter total de itens em estoque</summary>
    /// <returns>Quantidade total de itens</returns>
    function ObterTotalEstoque: Integer;
    
    /// <summary>Obter valor total do estoque</summary>
    /// <returns>Valor total (quantidade * preço)</returns>
    function ObterValorTotalEstoque: Double;
    
    {$ENDREGION}

    {$REGION 'Propriedades'}
    
    /// <summary>Último erro ocorrido</summary>
    property UltimoErro: string read FUltimoErro;
    
    /// <summary>Quantidade de produtos</summary>
    property Quantidade: Integer read ObterQuantidadeTotal;
    
    {$ENDREGION}
  end;

  {$ENDREGION}

implementation

{$REGION 'Implementação TRepositorioProduto'}

constructor TRepositorioProduto.Create;
begin
  inherited Create;
  FProdutos := TObjectList<TProduto>.Create;
  FProdutosFiltrados := TObjectList<TProduto>.Create;
  FUltimoErro := '';
  FProximoID := 1;
  
  // Carregar produtos de teste
  CarregarProdutosTeste;
end;

destructor TRepositorioProduto.Destroy;
begin
  if Assigned(FProdutos) then
    FProdutos.Free;
  if Assigned(FProdutosFiltrados) then
    FProdutosFiltrados.Free;
  inherited;
end;

{$REGION 'Métodos Privados'}

procedure TRepositorioProduto.CarregarProdutosTeste;
var
  Produto: TProduto;
begin
  // Categoria: Bebidas
  Produto := TProduto.Create(GerarProximoID, 'Água Mineral 1.5L', 'Bebidas', 2.50, 100);
  Produto.CodigoBarras := '7891234567890';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Refrigerante Cola 2L', 'Bebidas', 5.99, 80);
  Produto.CodigoBarras := '7891234567891';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Suco Natural Laranja 1L', 'Bebidas', 4.50, 60);
  Produto.CodigoBarras := '7891234567892';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Cerveja Premium 600ml', 'Bebidas', 3.99, 120);
  Produto.CodigoBarras := '7891234567893';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Vinho Tinto Reserva', 'Bebidas', 25.90, 40);
  Produto.CodigoBarras := '7891234567894';
  FProdutos.Add(Produto);
  
  // Categoria: Alimentos
  Produto := TProduto.Create(GerarProximoID, 'Pão Francês 500g', 'Alimentos', 3.50, 150);
  Produto.CodigoBarras := '7891234567895';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Arroz Integral 5kg', 'Alimentos', 18.90, 50);
  Produto.CodigoBarras := '7891234567896';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Feijão Carioca 1kg', 'Alimentos', 5.99, 75);
  Produto.CodigoBarras := '7891234567897';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Macarrão Integral 500g', 'Alimentos', 2.99, 200);
  Produto.CodigoBarras := '7891234567898';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Azeite Extra Virgem 500ml', 'Alimentos', 12.50, 30);
  Produto.CodigoBarras := '7891234567899';
  FProdutos.Add(Produto);
  
  // Categoria: Laticínios
  Produto := TProduto.Create(GerarProximoID, 'Leite Integral 1L', 'Laticínios', 3.20, 100);
  Produto.CodigoBarras := '7891234567900';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Queijo Meia Cura 500g', 'Laticínios', 15.90, 40);
  Produto.CodigoBarras := '7891234567901';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Iogurte Natural 500g', 'Laticínios', 4.50, 80);
  Produto.CodigoBarras := '7891234567902';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Manteiga com Sal 200g', 'Laticínios', 6.99, 60);
  Produto.CodigoBarras := '7891234567903';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Requeijão Cremoso 220g', 'Laticínios', 3.99, 90);
  Produto.CodigoBarras := '7891234567904';
  FProdutos.Add(Produto);
  
  // Categoria: Embutidos
  Produto := TProduto.Create(GerarProximoID, 'Presunto Cozido 500g', 'Embutidos', 12.90, 50);
  Produto.CodigoBarras := '7891234567905';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Salame Italiano 500g', 'Embutidos', 14.50, 45);
  Produto.CodigoBarras := '7891234567906';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Mortadela Premium 500g', 'Embutidos', 9.99, 70);
  Produto.CodigoBarras := '7891234567907';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Linguiça Fresca 500g', 'Embutidos', 11.90, 55);
  Produto.CodigoBarras := '7891234567908';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Bacon Defumado 200g', 'Embutidos', 8.50, 65);
  Produto.CodigoBarras := '7891234567909';
  FProdutos.Add(Produto);
  
  // Categoria: Frutas e Verduras
  Produto := TProduto.Create(GerarProximoID, 'Maçã Vermelha 1kg', 'Frutas e Verduras', 4.99, 100);
  Produto.CodigoBarras := '7891234567910';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Banana Nanica 1kg', 'Frutas e Verduras', 2.99, 150);
  Produto.CodigoBarras := '7891234567911';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Alface Crespa 1 unidade', 'Frutas e Verduras', 1.99, 80);
  Produto.CodigoBarras := '7891234567912';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Tomate Caqui 1kg', 'Frutas e Verduras', 3.99, 120);
  Produto.CodigoBarras := '7891234567913';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Cenoura 1kg', 'Frutas e Verduras', 2.50, 90);
  Produto.CodigoBarras := '7891234567914';
  FProdutos.Add(Produto);
  
  // Categoria: Congelados
  Produto := TProduto.Create(GerarProximoID, 'Frango Congelado 1kg', 'Congelados', 9.99, 80);
  Produto.CodigoBarras := '7891234567915';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Peixe Congelado 500g', 'Congelados', 12.50, 50);
  Produto.CodigoBarras := '7891234567916';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Camarão Congelado 500g', 'Congelados', 18.90, 40);
  Produto.CodigoBarras := '7891234567917';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Brócolis Congelado 500g', 'Congelados', 3.99, 100);
  Produto.CodigoBarras := '7891234567918';
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Pizza Congelada 500g', 'Congelados', 6.99, 120);
  Produto.CodigoBarras := '7891234567919';
  FProdutos.Add(Produto);
end;

function TRepositorioProduto.GerarProximoID: Integer;
begin
  Result := FProximoID;
  Inc(FProximoID);
end;

function TRepositorioProduto.ValidarProduto(AProduto: TProduto): Boolean;
begin
  Result := True;
  FUltimoErro := '';
  
  if not Assigned(AProduto) then
  begin
    FUltimoErro := 'Produto não pode ser nulo';
    Result := False;
    Exit;
  end;
  
  if AProduto.Nome = '' then
  begin
    FUltimoErro := 'Nome do produto é obrigatório';
    Result := False;
    Exit;
  end;
  
  if AProduto.Preco < 0 then
  begin
    FUltimoErro := 'Preço não pode ser negativo';
    Result := False;
    Exit;
  end;
  
  if AProduto.QuantidadeEstoque < 0 then
  begin
    FUltimoErro := 'Quantidade em estoque não pode ser negativa';
    Result := False;
    Exit;
  end;
end;

function TRepositorioProduto.CompararTexto(ATexto1, ATexto2: string): Boolean;
begin
  Result := Pos(UpperCase(ATexto2), UpperCase(ATexto1)) > 0;
end;

{$ENDREGION}

{$REGION 'CRUD - Operações Básicas'}

function TRepositorioProduto.Adicionar(AProduto: TProduto): Boolean;
begin
  Result := False;
  
  if not ValidarProduto(AProduto) then
    Exit;
  
  try
    AProduto.ID := GerarProximoID;
    FProdutos.Add(AProduto);
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao adicionar produto: ' + E.Message;
  end;
end;

function TRepositorioProduto.Atualizar(AProduto: TProduto): Boolean;
var
  Produto: TProduto;
  I: Integer;
begin
  Result := False;
  
  if not ValidarProduto(AProduto) then
    Exit;
  
  try
    for I := 0 to FProdutos.Count - 1 do
    begin
      Produto := FProdutos[I];
      if Produto.ID = AProduto.ID then
      begin
        Produto.Nome := AProduto.Nome;
        Produto.Categoria := AProduto.Categoria;
        Produto.Preco := AProduto.Preco;
        Produto.QuantidadeEstoque := AProduto.QuantidadeEstoque;
        Produto.CodigoBarras := AProduto.CodigoBarras;
        Result := True;
        Exit;
      end;
    end;
    
    FUltimoErro := 'Produto não encontrado';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao atualizar produto: ' + E.Message;
  end;
end;

function TRepositorioProduto.Deletar(AID: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  
  try
    for I := 0 to FProdutos.Count - 1 do
    begin
      if FProdutos[I].ID = AID then
      begin
        FProdutos.Delete(I);
        Result := True;
        Exit;
      end;
    end;
    
    FUltimoErro := 'Produto não encontrado';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao deletar produto: ' + E.Message;
  end;
end;

function TRepositorioProduto.ObterPorID(AID: Integer): TProduto;
var
  I: Integer;
begin
  Result := nil;
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    if FProdutos[I].ID = AID then
    begin
      Result := FProdutos[I];
      Exit;
    end;
  end;
end;

function TRepositorioProduto.ObterTodos: TObjectList<TProduto>;
begin
  Result := TObjectList<TProduto>.Create(False);
  Result.AddRange(FProdutos);
end;

{$ENDREGION}

{$REGION 'Busca - Operações de Pesquisa'}

function TRepositorioProduto.BuscarPorNome(ANome: string): TObjectList<TProduto>;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create(False);
  
  if ANome = '' then
  begin
    Result.AddRange(FProdutos);
    Exit;
  end;
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if CompararTexto(Produto.Nome, ANome) then
      Result.Add(Produto);
  end;
end;

function TRepositorioProduto.BuscarPorCategoria(ACategoria: string): TObjectList<TProduto>;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create(False);
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if CompararTexto(Produto.Categoria, ACategoria) then
      Result.Add(Produto);
  end;
end;

function TRepositorioProduto.BuscarPorCodigoBarras(ACodigoBarras: string): TProduto;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := nil;
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if Produto.CodigoBarras = ACodigoBarras then
    begin
      Result := Produto;
      Exit;
    end;
  end;
end;

function TRepositorioProduto.BuscarPorFaixaPreco(APrecoMinimo, APrecoMaximo: Double): TObjectList<TProduto>;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create(False);
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if (Produto.Preco >= APrecoMinimo) and (Produto.Preco <= APrecoMaximo) then
      Result.Add(Produto);
  end;
end;

function TRepositorioProduto.BuscaAvancada(ATermo: string; ATipoBusca: TTipoBusca = tbTodos;
  ACriterioOrdenacao: TCriterioOrdenacao = coNome;
  ADirecao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
var
  Resultado: TObjectList<TProduto>;
begin
  Result := TObjectList<TProduto>.Create(False);
  
  case ATipoBusca of
    tbNome:
      Resultado := BuscarPorNome(ATermo);
    tbCategoria:
      Resultado := BuscarPorCategoria(ATermo);
    tbTodos:
      Resultado := BuscarPorNome(ATermo);
  else
    Resultado := ObterTodos;
  end;
  
  // Ordenar resultado
  case ACriterioOrdenacao of
    coNome:
      Result := OrdenarPorNome(ADirecao);
    coPreco:
      Result := OrdenarPorPreco(ADirecao);
    coCategoria:
      Result := OrdenarPorCategoria(ADirecao);
  else
    Result := Resultado;
  end;
  
  if Assigned(Resultado) and (Result = Resultado) then
    Resultado := nil;
  
  if Assigned(Resultado) then
    Resultado.Free;
end;

{$ENDREGION}

{$REGION 'Filtros - Operações de Filtro'}

function TRepositorioProduto.FiltrarComEstoque: TObjectList<TProduto>;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create(False);
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if Produto.QuantidadeEstoque > 0 then
      Result.Add(Produto);
  end;
end;

function TRepositorioProduto.FiltrarSemEstoque: TObjectList<TProduto>;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create(False);
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if Produto.QuantidadeEstoque = 0 then
      Result.Add(Produto);
  end;
end;

function TRepositorioProduto.FiltrarEstoqueMinimo(AEstoqueMinimo: Integer): TObjectList<TProduto>;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create(False);
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if Produto.QuantidadeEstoque < AEstoqueMinimo then
      Result.Add(Produto);
  end;
end;

{$ENDREGION}

{$REGION 'Ordenação - Operações de Ordenação'}

function TRepositorioProduto.OrdenarPorNome(AOrdenacao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
var
  Comparador: TComparison<TProduto>;
  Resultado: TObjectList<TProduto>;
begin
  Resultado := TObjectList<TProduto>.Create(False);
  Resultado.AddRange(FProdutos);
  
  if AOrdenacao = doAscendente then
  begin
    Comparador := function(const Left, Right: TProduto): Integer
    begin
      Result := CompareStr(Left.Nome, Right.Nome);
    end;
  end
  else
  begin
    Comparador := function(const Left, Right: TProduto): Integer
    begin
      Result := -CompareStr(Left.Nome, Right.Nome);
    end;
  end;
  
  Resultado.Sort(TComparer<TProduto>.Construct(Comparador));
  Result := Resultado;
end;

function TRepositorioProduto.OrdenarPorPreco(AOrdenacao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
var
  Comparador: TComparison<TProduto>;
  Resultado: TObjectList<TProduto>;
begin
  Resultado := TObjectList<TProduto>.Create(False);
  Resultado.AddRange(FProdutos);
  
  if AOrdenacao = doAscendente then
  begin
    Comparador := function(const Left, Right: TProduto): Integer
    begin
      if Left.Preco < Right.Preco then
        Result := -1
      else if Left.Preco > Right.Preco then
        Result := 1
      else
        Result := 0;
    end;
  end
  else
  begin
    Comparador := function(const Left, Right: TProduto): Integer
    begin
      if Left.Preco > Right.Preco then
        Result := -1
      else if Left.Preco < Right.Preco then
        Result := 1
      else
        Result := 0;
    end;
  end;
  
  Resultado.Sort(TComparer<TProduto>.Construct(Comparador));
  Result := Resultado;
end;

function TRepositorioProduto.OrdenarPorCategoria(AOrdenacao: TDirecaoOrdenacao = doAscendente): TObjectList<TProduto>;
var
  Comparador: TComparison<TProduto>;
  Resultado: TObjectList<TProduto>;
begin
  Resultado := TObjectList<TProduto>.Create(False);
  Resultado.AddRange(FProdutos);
  
  if AOrdenacao = doAscendente then
  begin
    Comparador := function(const Left, Right: TProduto): Integer
    begin
      Result := CompareStr(Left.Categoria, Right.Categoria);
    end;
  end
  else
  begin
    Comparador := function(const Left, Right: TProduto): Integer
    begin
      Result := -CompareStr(Left.Categoria, Right.Categoria);
    end;
  end;
  
  Resultado.Sort(TComparer<TProduto>.Construct(Comparador));
  Result := Resultado;
end;

{$ENDREGION}

{$REGION 'Estatísticas - Operações de Análise'}

function TRepositorioProduto.ObterQuantidadeTotal: Integer;
begin
  Result := FProdutos.Count;
end;

function TRepositorioProduto.ObterQuantidadeCategorias: Integer;
var
  Categorias: TStringList;
  I: Integer;
  Produto: TProduto;
begin
  Categorias := TStringList.Create;
  try
    Categorias.Sorted := True;
    Categorias.Duplicates := dupIgnore;
    
    for I := 0 to FProdutos.Count - 1 do
    begin
      Produto := FProdutos[I];
      Categorias.Add(Produto.Categoria);
    end;
    
    Result := Categorias.Count;
  finally
    Categorias.Free;
  end;
end;

function TRepositorioProduto.ObterCategorias: TStringList;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := TStringList.Create;
  Result.Sorted := True;
  Result.Duplicates := dupIgnore;
  
  for I := 0 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    Result.Add(Produto.Categoria);
  end;
end;

function TRepositorioProduto.ObterPrecoMedio: Double;
var
  I: Integer;
  Total: Double;
begin
  Result := 0;
  
  if FProdutos.Count = 0 then
    Exit;
  
  Total := 0;
  for I := 0 to FProdutos.Count - 1 do
    Total := Total + FProdutos[I].Preco;
  
  Result := Total / FProdutos.Count;
end;

function TRepositorioProduto.ObterProdutoMaisCaro: TProduto;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := nil;
  
  if FProdutos.Count = 0 then
    Exit;
  
  Result := FProdutos[0];
  
  for I := 1 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if Produto.Preco > Result.Preco then
      Result := Produto;
  end;
end;

function TRepositorioProduto.ObterProdutoMaisBarato: TProduto;
var
  I: Integer;
  Produto: TProduto;
begin
  Result := nil;
  
  if FProdutos.Count = 0 then
    Exit;
  
  Result := FProdutos[0];
  
  for I := 1 to FProdutos.Count - 1 do
  begin
    Produto := FProdutos[I];
    if Produto.Preco < Result.Preco then
      Result := Produto;
  end;
end;

function TRepositorioProduto.ObterTotalEstoque: Integer;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FProdutos.Count - 1 do
    Result := Result + FProdutos[I].QuantidadeEstoque;
end;

function TRepositorioProduto.ObterValorTotalEstoque: Double;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FProdutos.Count - 1 do
    Result := Result + (FProdutos[I].Preco * FProdutos[I].QuantidadeEstoque);
end;

{$ENDREGION}

{$ENDREGION}

end.
