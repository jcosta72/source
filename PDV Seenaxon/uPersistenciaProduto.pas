unit uPersistenciaProduto;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  uProduto, uDMConexao;

type
  { Classe de persistência para TProduto }
  TPersistenciaProduto = class
  private
    FConexao: TFDConnection;
    FUltimoErro: string;
    
    function UnidadeMedidaToString(AUnidade: TUnidadeMedida): string;
    function StringToUnidadeMedida(AString: string): TUnidadeMedida;
  public
    constructor Create(AConexao: TFDConnection);
    destructor Destroy; override;
    
    { ========== OPERAÇÕES CRUD ========== }
    
    { Salvar novo produto }
    function SalvarProduto(AProduto: TProduto): Boolean;
    
    { Atualizar produto existente }
    function AtualizarProduto(AProduto: TProduto): Boolean;
    
    { Deletar produto }
    function DeletarProduto(AID: Integer): Boolean;
    
    { ========== CONSULTAS ========== }
    
    { Obter produto por ID }
    function ObterProdutoPorID(AID: Integer): TProduto;
    
    { Obter todos os produtos }
    function ObterTodosProdutos: TObjectList<TProduto>;
    
    { Obter produtos por categoria }
    function ObterProdutosPorCategoria(ACategoria: TCategoria): TObjectList<TProduto>;
    
    { Obter produtos por unidade de medida }
    function ObterProdutosPorUnidade(AUnidade: TUnidadeMedida): TObjectList<TProduto>;
    
    { Obter produtos ativos }
    function ObterProdutosAtivos: TObjectList<TProduto>;
    
    { Obter produtos inativos }
    function ObterProdutosInativos: TObjectList<TProduto>;
    
    { Buscar produtos por nome }
    function BuscarProdutosPorNome(ANome: string): TObjectList<TProduto>;
    
    { Buscar produtos por código de barras }
    function BuscarProdutoPorCodigoBarras(ACodigo: string): TProduto;
    
    { ========== OPERAÇÕES EM LOTE ========== }
    
    { Salvar múltiplos produtos }
    function SalvarMultiplosProdutos(AProdutos: TObjectList<TProduto>): Boolean;
    
    { Atualizar múltiplos produtos }
    function AtualizarMultiplosProdutos(AProdutos: TObjectList<TProduto>): Boolean;
    
    { Deletar múltiplos produtos }
    function DeletarMultiplosProdutos(AIDs: array of Integer): Boolean;
    
    { ========== ESTATÍSTICAS ========== }
    
    { Obter quantidade total de produtos }
    function ObterQuantidadeProdutos: Integer;
    
    { Obter quantidade de produtos por categoria }
    function ObterQuantidadePorCategoria(ACategoria: TCategoria): Integer;
    
    { Obter quantidade de produtos por unidade }
    function ObterQuantidadePorUnidade(AUnidade: TUnidadeMedida): Integer;
    
    { Obter valor total do estoque }
    function ObterValorTotalEstoque: Double;
    
    { Obter valor total de estoque por categoria }
    function ObterValorEstoqueCategoria(ACategoria: TCategoria): Double;
    
    { Obter preço médio dos produtos }
    function ObterPrecoMedio: Double;
    
    { Obter preço mínimo }
    function ObterPrecoMinimo: Double;
    
    { Obter preço máximo }
    function ObterPrecoMaximo: Double;
    
    { ========== VALIDAÇÕES ========== }
    
    { Verificar se produto existe }
    function ProdutoExiste(AID: Integer): Boolean;
    
    { Verificar se código de barras existe }
    function CodigoBarrasExiste(ACodigo: string): Boolean;
    
    { ========== LIMPEZA ========== }
    
    { Deletar todos os produtos }
    function DeletarTodosProdutos: Boolean;
    
    { ========== PROPRIEDADES ========== }
    
    property UltimoErro: string read FUltimoErro;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TPersistenciaProduto.Create(AConexao: TFDConnection);
begin
  inherited Create;
  FConexao := AConexao;
  FUltimoErro := '';
end;

destructor TPersistenciaProduto.Destroy;
begin
  inherited;
end;

{ ============================================================================
  CONVERSÃO DE TIPOS
  ============================================================================ }

function TPersistenciaProduto.UnidadeMedidaToString(AUnidade: TUnidadeMedida): string;
begin
  case AUnidade of
    umUnidade: Result := 'UNIDADE';
    umKG: Result := 'KG';
    umGramas: Result := 'GRAMAS';
    umLitro: Result := 'LITRO';
    umMililitro: Result := 'MILILITRO';
    umMetro: Result := 'METRO';
    umCentimetro: Result := 'CENTIMETRO';
  else
    Result := 'UNIDADE';
  end;
end;

function TPersistenciaProduto.StringToUnidadeMedida(AString: string): TUnidadeMedida;
begin
  AString := UpperCase(AString);
  
  if AString = 'KG' then
    Result := umKG
  else if AString = 'GRAMAS' then
    Result := umGramas
  else if AString = 'LITRO' then
    Result := umLitro
  else if AString = 'MILILITRO' then
    Result := umMililitro
  else if AString = 'METRO' then
    Result := umMetro
  else if AString = 'CENTIMETRO' then
    Result := umCentimetro
  else
    Result := umUnidade;
end;

{ ============================================================================
  OPERAÇÕES CRUD
  ============================================================================ }

function TPersistenciaProduto.SalvarProduto(AProduto: TProduto): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  if not Assigned(AProduto) then
  begin
    FUltimoErro := 'Produto inválido';
    Exit;
  end;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      
      Query.SQL.Text :=
        'INSERT INTO Produtos (Nome, Descricao, Preco, ImagemPath, CodigoBarras, ' +
        'Categoria, Estoque, Ativo, UnidadeMedida, PrecisaoDecimal, DataCadastro) ' +
        'VALUES (:Nome, :Descricao, :Preco, :ImagemPath, :CodigoBarras, ' +
        ':Categoria, :Estoque, :Ativo, :UnidadeMedida, :PrecisaoDecimal, :DataCadastro)';
      
      Query.ParamByName('Nome').AsString := AProduto.Nome;
      Query.ParamByName('Descricao').AsString := AProduto.Descricao;
      Query.ParamByName('Preco').AsFloat := AProduto.Preco;
      Query.ParamByName('ImagemPath').AsString := AProduto.ImagemPath;
      Query.ParamByName('CodigoBarras').AsString := AProduto.CodigoBarras;
      Query.ParamByName('Categoria').AsInteger := Integer(AProduto.Categoria);
      Query.ParamByName('Estoque').AsInteger := AProduto.Estoque;
      Query.ParamByName('Ativo').AsBoolean := AProduto.Ativo;
      Query.ParamByName('UnidadeMedida').AsString := UnidadeMedidaToString(AProduto.UnidadeMedida);
      Query.ParamByName('PrecisaoDecimal').AsInteger := AProduto.PrecisaoDecimal;
      Query.ParamByName('DataCadastro').AsDateTime := AProduto.DataCadastro;
      
      Query.ExecSQL;
      
      Result := True;
      FUltimoErro := '';
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar produto: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaProduto.AtualizarProduto(AProduto: TProduto): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  if not Assigned(AProduto) then
  begin
    FUltimoErro := 'Produto inválido';
    Exit;
  end;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      
      Query.SQL.Text :=
        'UPDATE Produtos SET ' +
        'Nome = :Nome, Descricao = :Descricao, Preco = :Preco, ' +
        'ImagemPath = :ImagemPath, CodigoBarras = :CodigoBarras, ' +
        'Categoria = :Categoria, Estoque = :Estoque, Ativo = :Ativo, ' +
        'UnidadeMedida = :UnidadeMedida, PrecisaoDecimal = :PrecisaoDecimal ' +
        'WHERE ID = :ID';
      
      Query.ParamByName('ID').AsInteger := AProduto.ID;
      Query.ParamByName('Nome').AsString := AProduto.Nome;
      Query.ParamByName('Descricao').AsString := AProduto.Descricao;
      Query.ParamByName('Preco').AsFloat := AProduto.Preco;
      Query.ParamByName('ImagemPath').AsString := AProduto.ImagemPath;
      Query.ParamByName('CodigoBarras').AsString := AProduto.CodigoBarras;
      Query.ParamByName('Categoria').AsInteger := Integer(AProduto.Categoria);
      Query.ParamByName('Estoque').AsInteger := AProduto.Estoque;
      Query.ParamByName('Ativo').AsBoolean := AProduto.Ativo;
      Query.ParamByName('UnidadeMedida').AsString := UnidadeMedidaToString(AProduto.UnidadeMedida);
      Query.ParamByName('PrecisaoDecimal').AsInteger := AProduto.PrecisaoDecimal;
      
      Query.ExecSQL;
      
      Result := True;
      FUltimoErro := '';
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao atualizar produto: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaProduto.DeletarProduto(AID: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'DELETE FROM Produtos WHERE ID = :ID';
      Query.ParamByName('ID').AsInteger := AID;
      Query.ExecSQL;
      
      Result := True;
      FUltimoErro := '';
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar produto: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  CONSULTAS
  ============================================================================ }

function TPersistenciaProduto.ObterProdutoPorID(AID: Integer): TProduto;
var
  Query: TFDQuery;
begin
  Result := nil;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos WHERE ID = :ID';
      Query.ParamByName('ID').AsInteger := AID;
      Query.Open;
      
      if not Query.IsEmpty then
      begin
        Result := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          TCategoria(Query.FieldByName('Categoria').AsInteger),
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          StringToUnidadeMedida(Query.FieldByName('UnidadeMedida').AsString)
        );
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter produto: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TPersistenciaProduto.ObterTodosProdutos: TObjectList<TProduto>;
var
  Query: TFDQuery;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos ORDER BY Nome';
      Query.Open;
      
      while not Query.Eof do
      begin
        Produto := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          TCategoria(Query.FieldByName('Categoria').AsInteger),
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          StringToUnidadeMedida(Query.FieldByName('UnidadeMedida').AsString)
        );
        
        Result.Add(Produto);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter produtos: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TPersistenciaProduto.ObterProdutosPorCategoria(ACategoria: TCategoria): TObjectList<TProduto>;
var
  Query: TFDQuery;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos WHERE Categoria = :Categoria ORDER BY Nome';
      Query.ParamByName('Categoria').AsInteger := Integer(ACategoria);
      Query.Open;
      
      while not Query.Eof do
      begin
        Produto := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          ACategoria,
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          StringToUnidadeMedida(Query.FieldByName('UnidadeMedida').AsString)
        );
        
        Result.Add(Produto);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter produtos por categoria: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TPersistenciaProduto.ObterProdutosPorUnidade(AUnidade: TUnidadeMedida): TObjectList<TProduto>;
var
  Query: TFDQuery;
  Produto: TProduto;
  UnidadeStr: string;
begin
  Result := TObjectList<TProduto>.Create;
  UnidadeStr := UnidadeMedidaToString(AUnidade);
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos WHERE UnidadeMedida = :UnidadeMedida ORDER BY Nome';
      Query.ParamByName('UnidadeMedida').AsString := UnidadeStr;
      Query.Open;
      
      while not Query.Eof do
      begin
        Produto := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          TCategoria(Query.FieldByName('Categoria').AsInteger),
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          AUnidade
        );
        
        Result.Add(Produto);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter produtos por unidade: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TPersistenciaProduto.ObterProdutosAtivos: TObjectList<TProduto>;
var
  Query: TFDQuery;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos WHERE Ativo = 1 ORDER BY Nome';
      Query.Open;
      
      while not Query.Eof do
      begin
        Produto := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          TCategoria(Query.FieldByName('Categoria').AsInteger),
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          StringToUnidadeMedida(Query.FieldByName('UnidadeMedida').AsString)
        );
        
        Result.Add(Produto);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter produtos ativos: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TPersistenciaProduto.ObterProdutosInativos: TObjectList<TProduto>;
var
  Query: TFDQuery;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos WHERE Ativo = 0 ORDER BY Nome';
      Query.Open;
      
      while not Query.Eof do
      begin
        Produto := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          TCategoria(Query.FieldByName('Categoria').AsInteger),
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          StringToUnidadeMedida(Query.FieldByName('UnidadeMedida').AsString)
        );
        
        Result.Add(Produto);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter produtos inativos: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TPersistenciaProduto.BuscarProdutosPorNome(ANome: string): TObjectList<TProduto>;
var
  Query: TFDQuery;
  Produto: TProduto;
begin
  Result := TObjectList<TProduto>.Create;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos WHERE Nome LIKE :Nome ORDER BY Nome';
      Query.ParamByName('Nome').AsString := '%' + ANome + '%';
      Query.Open;
      
      while not Query.Eof do
      begin
        Produto := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          TCategoria(Query.FieldByName('Categoria').AsInteger),
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          StringToUnidadeMedida(Query.FieldByName('UnidadeMedida').AsString)
        );
        
        Result.Add(Produto);
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao buscar produtos: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  end;
end;

function TPersistenciaProduto.BuscarProdutoPorCodigoBarras(ACodigo: string): TProduto;
var
  Query: TFDQuery;
begin
  Result := nil;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT * FROM Produtos WHERE CodigoBarras = :Codigo';
      Query.ParamByName('Codigo').AsString := ACodigo;
      Query.Open;
      
      if not Query.IsEmpty then
      begin
        Result := TProduto.Create(
          Query.FieldByName('ID').AsInteger,
          Query.FieldByName('Nome').AsString,
          Query.FieldByName('Descricao').AsString,
          Query.FieldByName('Preco').AsFloat,
          Query.FieldByName('CodigoBarras').AsString,
          TCategoria(Query.FieldByName('Categoria').AsInteger),
          Query.FieldByName('Estoque').AsInteger,
          Query.FieldByName('ImagemPath').AsString,
          StringToUnidadeMedida(Query.FieldByName('UnidadeMedida').AsString)
        );
      end;
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao buscar produto por código: ' + E.Message;
      Result := nil;
    end;
  end;
end;

{ ============================================================================
  OPERAÇÕES EM LOTE
  ============================================================================ }

function TPersistenciaProduto.SalvarMultiplosProdutos(AProdutos: TObjectList<TProduto>): Boolean;
var
  i: Integer;
begin
  Result := True;
  
  if not Assigned(AProdutos) or (AProdutos.Count = 0) then
  begin
    FUltimoErro := 'Lista de produtos vazia';
    Result := False;
    Exit;
  end;
  
  try
    FConexao.StartTransaction;
    
    for i := 0 to AProdutos.Count - 1 do
    begin
      if not SalvarProduto(AProdutos[i]) then
      begin
        FConexao.Rollback;
        Result := False;
        Exit;
      end;
    end;
    
    FConexao.Commit;
  except
    on E: Exception do
    begin
      FConexao.Rollback;
      FUltimoErro := 'Erro ao salvar múltiplos produtos: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaProduto.AtualizarMultiplosProdutos(AProdutos: TObjectList<TProduto>): Boolean;
var
  i: Integer;
begin
  Result := True;
  
  if not Assigned(AProdutos) or (AProdutos.Count = 0) then
  begin
    FUltimoErro := 'Lista de produtos vazia';
    Result := False;
    Exit;
  end;
  
  try
    FConexao.StartTransaction;
    
    for i := 0 to AProdutos.Count - 1 do
    begin
      if not AtualizarProduto(AProdutos[i]) then
      begin
        FConexao.Rollback;
        Result := False;
        Exit;
      end;
    end;
    
    FConexao.Commit;
  except
    on E: Exception do
    begin
      FConexao.Rollback;
      FUltimoErro := 'Erro ao atualizar múltiplos produtos: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaProduto.DeletarMultiplosProdutos(AIDs: array of Integer): Boolean;
var
  i: Integer;
begin
  Result := True;
  
  if Length(AIDs) = 0 then
  begin
    FUltimoErro := 'Lista de IDs vazia';
    Result := False;
    Exit;
  end;
  
  try
    FConexao.StartTransaction;
    
    for i := Low(AIDs) to High(AIDs) do
    begin
      if not DeletarProduto(AIDs[i]) then
      begin
        FConexao.Rollback;
        Result := False;
        Exit;
      end;
    end;
    
    FConexao.Commit;
  except
    on E: Exception do
    begin
      FConexao.Rollback;
      FUltimoErro := 'Erro ao deletar múltiplos produtos: ' + E.Message;
      Result := False;
    end;
  end;
end;

{ ============================================================================
  ESTATÍSTICAS
  ============================================================================ }

function TPersistenciaProduto.ObterQuantidadeProdutos: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Produtos';
      Query.Open;
      
      Result := Query.FieldByName('Total').AsInteger;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TPersistenciaProduto.ObterQuantidadePorCategoria(ACategoria: TCategoria): Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Produtos WHERE Categoria = :Categoria';
      Query.ParamByName('Categoria').AsInteger := Integer(ACategoria);
      Query.Open;
      
      Result := Query.FieldByName('Total').AsInteger;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TPersistenciaProduto.ObterQuantidadePorUnidade(AUnidade: TUnidadeMedida): Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Produtos WHERE UnidadeMedida = :UnidadeMedida';
      Query.ParamByName('UnidadeMedida').AsString := UnidadeMedidaToString(AUnidade);
      Query.Open;
      
      Result := Query.FieldByName('Total').AsInteger;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TPersistenciaProduto.ObterValorTotalEstoque: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT SUM(Preco * Estoque) as Total FROM Produtos WHERE Ativo = 1';
      Query.Open;
      
      if not Query.FieldByName('Total').IsNull then
        Result := Query.FieldByName('Total').AsFloat;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TPersistenciaProduto.ObterValorEstoqueCategoria(ACategoria: TCategoria): Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT SUM(Preco * Estoque) as Total FROM Produtos WHERE Categoria = :Categoria AND Ativo = 1';
      Query.ParamByName('Categoria').AsInteger := Integer(ACategoria);
      Query.Open;
      
      if not Query.FieldByName('Total').IsNull then
        Result := Query.FieldByName('Total').AsFloat;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TPersistenciaProduto.ObterPrecoMedio: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT AVG(Preco) as Media FROM Produtos WHERE Ativo = 1';
      Query.Open;
      
      if not Query.FieldByName('Media').IsNull then
        Result := Query.FieldByName('Media').AsFloat;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TPersistenciaProduto.ObterPrecoMinimo: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT MIN(Preco) as Minimo FROM Produtos WHERE Ativo = 1';
      Query.Open;
      
      if not Query.FieldByName('Minimo').IsNull then
        Result := Query.FieldByName('Minimo').AsFloat;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

function TPersistenciaProduto.ObterPrecoMaximo: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT MAX(Preco) as Maximo FROM Produtos WHERE Ativo = 1';
      Query.Open;
      
      if not Query.FieldByName('Maximo').IsNull then
        Result := Query.FieldByName('Maximo').AsFloat;
    finally
      Query.Free;
    end;
  except
    Result := 0;
  end;
end;

{ ============================================================================
  VALIDAÇÕES
  ============================================================================ }

function TPersistenciaProduto.ProdutoExiste(AID: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Produtos WHERE ID = :ID';
      Query.ParamByName('ID').AsInteger := AID;
      Query.Open;
      
      Result := Query.FieldByName('Total').AsInteger > 0;
    finally
      Query.Free;
    end;
  except
    Result := False;
  end;
end;

function TPersistenciaProduto.CodigoBarrasExiste(ACodigo: string): Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Produtos WHERE CodigoBarras = :Codigo';
      Query.ParamByName('Codigo').AsString := ACodigo;
      Query.Open;
      
      Result := Query.FieldByName('Total').AsInteger > 0;
    finally
      Query.Free;
    end;
  except
    Result := False;
  end;
end;

{ ============================================================================
  LIMPEZA
  ============================================================================ }

function TPersistenciaProduto.DeletarTodosProdutos: Boolean;
var
  Query: TFDQuery;
begin
  Result := False;
  
  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConexao;
      Query.SQL.Text := 'DELETE FROM Produtos';
      Query.ExecSQL;
      
      Result := True;
      FUltimoErro := '';
    finally
      Query.Free;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar todos os produtos: ' + E.Message;
      Result := False;
    end;
  end;
end;

end.
