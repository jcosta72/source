unit uRecuperacaoVendas;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IOUtils,
  System.DateUtils, Xml.XMLIntf, Xml.XMLDoc,
  uVenda, uItemVenda, uProduto, uRepositorioProdutos;

type
  { Enumeração para definir o formato de arquivo }
  TFormatoArquivo = (faXML, faCSV);

  { Classe responsável pela recuperação de vendas pendentes }
  TRecuperacaoVendas = class
  private
    FDiretorio: string;
    FArquivoVendaPendente: string;
    FFormatoArquivo: TFormatoArquivo;
    FRepositorioProdutos: TRepositorioProdutos;
    FUltimoErro: string;
    
    { Métodos privados para obter caminho e salvar em diferentes formatos }
    function ObterCaminhoArquivo: string;
    procedure SalvarXML(AVenda: TVenda);
    
    { Métodos privados para carregar de diferentes formatos }
    function CarregarXML: TVenda;

    { Métodos auxiliares }
    function CriarProdutoDoXML(ProdutoNode: IXMLNode): TProduto;
    function CriarItemDoXML(ItemNode: IXMLNode): TItemVenda;
    
  public
    constructor Create(ARepositorioProdutos: TRepositorioProdutos = nil; 
      AFormatoArquivo: TFormatoArquivo = faXML);
    destructor Destroy; override;
    
    { Operações de salvamento }
    procedure SalvarVendaPendente(AVenda: TVenda);
    procedure DeletarVendaPendente;
    
    { Operações de carregamento }
    function TemVendaPendente: Boolean;
    function CarregarVendaPendente: TVenda;
    
    { Configuração }
    procedure DefinirDiretorio(ADiretorio: string);
    procedure DefinirRepositorioProdutos(ARepositorio: TRepositorioProdutos);
    
    { Propriedades }
    property Diretorio: string read FDiretorio write FDiretorio;
    property Formato: TFormatoArquivo read FFormatoArquivo write FFormatoArquivo;
    property UltimoErro: string read FUltimoErro;
  end;

implementation

// ============================================================================
// CONSTRUTOR E DESTRUTOR
// ============================================================================

constructor TRecuperacaoVendas.Create(ARepositorioProdutos: TRepositorioProdutos = nil;
  AFormatoArquivo: TFormatoArquivo = faXML);
begin
  inherited Create;
  FRepositorioProdutos := ARepositorioProdutos;
  FFormatoArquivo := AFormatoArquivo;
  FUltimoErro := '';
  
  { Usar diretório de documentos do usuário }
  FDiretorio := TPath.GetDocumentsPath;
  
  { Criar subdiretório para PDV se não existir }
  FDiretorio := TPath.Combine(FDiretorio, 'PDV_Vendas_Pendentes');
  if not TDirectory.Exists(FDiretorio) then
  begin
    try
      TDirectory.CreateDirectory(FDiretorio);
    except
      on E: Exception do
        FUltimoErro := 'Erro ao criar diretório: ' + E.Message;
    end;
  end;
  
  FArquivoVendaPendente := 'venda_pendente';
end;

destructor TRecuperacaoVendas.Destroy;
begin
  inherited;
end;

// ============================================================================
// CONFIGURAÇÃO
// ============================================================================

procedure TRecuperacaoVendas.DefinirDiretorio(ADiretorio: string);
begin
  FDiretorio := ADiretorio;
  if not TDirectory.Exists(FDiretorio) then
  begin
    try
      TDirectory.CreateDirectory(FDiretorio);
    except
      on E: Exception do
        FUltimoErro := 'Erro ao criar diretório: ' + E.Message;
    end;
  end;
end;

procedure TRecuperacaoVendas.DefinirRepositorioProdutos(ARepositorio: TRepositorioProdutos);
begin
  FRepositorioProdutos := ARepositorio;
end;

// ============================================================================
// MÉTODOS AUXILIARES
// ============================================================================

function TRecuperacaoVendas.ObterCaminhoArquivo: string;
begin
  { Retornar caminho completo do arquivo baseado no formato }
  case FFormatoArquivo of
    faXML: Result := TPath.Combine(FDiretorio, FArquivoVendaPendente + '.xml');
  else
    Result := TPath.Combine(FDiretorio, FArquivoVendaPendente + '.xml');
  end;
end;

// ============================================================================
// OPERAÇÕES DE VERIFICAÇÃO E DELEÇÃO
// ============================================================================

function TRecuperacaoVendas.TemVendaPendente: Boolean;
begin
  { Verificar se arquivo de venda pendente existe }
  Result := TFile.Exists(ObterCaminhoArquivo);
end;

procedure TRecuperacaoVendas.DeletarVendaPendente;
begin
  { Deletar arquivo de venda pendente se existir }
  if TFile.Exists(ObterCaminhoArquivo) then
  begin
    try
      TFile.Delete(ObterCaminhoArquivo);
      FUltimoErro := '';
    except
      on E: Exception do
      begin
        FUltimoErro := 'Erro ao deletar venda pendente: ' + E.Message;
      end;
    end;
  end;
end;

// ============================================================================
// SALVAMENTO DE VENDAS PENDENTES
// ============================================================================

procedure TRecuperacaoVendas.SalvarVendaPendente(AVenda: TVenda);
begin
  { Validar venda }
  if not Assigned(AVenda) or (AVenda.QuantidadeItens = 0) then
  begin
    FUltimoErro := 'Venda inválida ou sem itens';
    Exit;
  end;
  
  { Salvar no formato especificado }
  try
    case FFormatoArquivo of
      faXML: SalvarXML(AVenda);
    end;
    FUltimoErro := '';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao salvar venda pendente: ' + E.Message;
  end;
end;

// ============================================================================
// SERIALIZAÇÃO EM XML
// ============================================================================

procedure TRecuperacaoVendas.SalvarXML(AVenda: TVenda);
var
  XMLDoc: IXMLDocument;
  RootNode, VendaNode, ItensNode, ItemNode, ProdutoNode: IXMLNode;
  i: Integer;
  Item: TItemVenda;
begin
  try
    { Criar novo documento XML }
    XMLDoc := NewXMLDocument;
    XMLDoc.Active := True;
    XMLDoc.Encoding := 'UTF-8';
    XMLDoc.Version := '1.0';
    
    { Criar nó raiz }
    RootNode := XMLDoc.AddChild('VendaPendente');
    RootNode.Attributes['versao'] := '1.0';
    RootNode.Attributes['data'] := FormatDateTime('yyyy-mm-dd hh:mm:ss', Now);
    RootNode.Attributes['timestamp'] := IntToStr(DateTimeToUnix(Now));
    
    { Criar nó de venda }
    VendaNode := RootNode.AddChild('Venda');
    
    { Adicionar dados da venda }
    VendaNode.AddChild('ID').NodeValue := AVenda.ID;
    VendaNode.AddChild('OperadorID').NodeValue := AVenda.OperadorID;
    VendaNode.AddChild('DataVenda').NodeValue := FormatDateTime('yyyy-mm-dd hh:mm:ss', AVenda.DataVenda);
    VendaNode.AddChild('DataHora').NodeValue := FormatDateTime('yyyy-mm-dd hh:mm:ss', AVenda.DataVenda);
    VendaNode.AddChild('Subtotal').NodeValue := FormatFloat('0.00', AVenda.Subtotal);
    VendaNode.AddChild('Desconto').NodeValue := FormatFloat('0.00', AVenda.Desconto);
    VendaNode.AddChild('PercentualDesconto').NodeValue := FormatFloat('0.00', AVenda.Desconto);
    VendaNode.AddChild('Acrescimo').NodeValue := FormatFloat('0.00', AVenda.Acrescimo);
    VendaNode.AddChild('PercentualAcrescimo').NodeValue := FormatFloat('0.00', AVenda.Acrescimo);
    VendaNode.AddChild('Total').NodeValue := FormatFloat('0.00', AVenda.Total);
    VendaNode.AddChild('QuantidadeItens').NodeValue := AVenda.QuantidadeItens;
    VendaNode.AddChild('FormaPagamento').NodeValue := AVenda.FormaPagamento;
    
    { Criar nó de itens }
    ItensNode := VendaNode.AddChild('Itens');
    
    { Adicionar cada item da venda }
    for i := 0 to AVenda.QuantidadeItens - 1 do
    begin
      Item := AVenda.GetItem(i);
      if Assigned(Item) and Assigned(Item.Produto) then
      begin
        ItemNode := ItensNode.AddChild('Item');
        ItemNode.Attributes['indice'] := i;
        
        { Adicionar dados do produto }
        ProdutoNode := ItemNode.AddChild('Produto');
        ProdutoNode.AddChild('ID').NodeValue := Item.Produto.ID;
        ProdutoNode.AddChild('Nome').NodeValue := Item.Produto.Nome;
        ProdutoNode.AddChild('Descricao').NodeValue := Item.Produto.Descricao;
        ProdutoNode.AddChild('Preco').NodeValue := FormatFloat('0.00', Item.Produto.Preco);
        ProdutoNode.AddChild('Categoria').NodeValue := Item.Produto.Categoria;
        ProdutoNode.AddChild('QuantidadeEstoque').NodeValue := Item.Produto.Estoque;
        
        { Adicionar dados do item }
        ItemNode.AddChild('Quantidade').NodeValue := FormatFloat('0.00', Item.Quantidade);
        ItemNode.AddChild('ValorUnitario').NodeValue := FormatFloat('0.00', Item.ValorUnitario);
        ItemNode.AddChild('ValorTotal').NodeValue := FormatFloat('0.00', Item.ValorTotal);
        ItemNode.AddChild('Desconto').NodeValue := FormatFloat('0.00', Item.Desconto);
        ItemNode.AddChild('PercentualDesconto').NodeValue := FormatFloat('0.00', Item.Desconto);
      end;
    end;
    
    { Salvar documento XML }
    XMLDoc.SaveToFile(ObterCaminhoArquivo);
    
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar venda em XML: ' + E.Message;
      raise;
    end;
  end;
end;

// ============================================================================
// DESSERIALIZAÇÃO EM XML
// ============================================================================

function TRecuperacaoVendas.CriarProdutoDoXML(ProdutoNode: IXMLNode): TProduto;
var
  ID, Estoque: Integer;
  Nome, Descricao, Categoria: string;
  Preco: Double;
begin
  Result := nil;
  
  try
    if not Assigned(ProdutoNode) then
      Exit;
    
    { Extrair dados do nó XML }
    ID := StrToIntDef(ProdutoNode.ChildNodes.FindNode('ID').NodeValue, 0);
    Nome := ProdutoNode.ChildNodes.FindNode('Nome').NodeValue;
    Descricao := ProdutoNode.ChildNodes.FindNode('Descricao').NodeValue;
    Preco := StrToFloatDef(ProdutoNode.ChildNodes.FindNode('Preco').NodeValue, 0);
    Categoria := ProdutoNode.ChildNodes.FindNode('Categoria').NodeValue;
    Estoque := StrToIntDef(ProdutoNode.ChildNodes.FindNode('QuantidadeEstoque').NodeValue, 0);
    
    { Criar produto }
    Result := TProduto.Create(ID, Nome, Categoria, Preco, '', ctOutros, Estoque);
    Result.Descricao := Descricao;
    
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao criar produto do XML: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TRecuperacaoVendas.CriarItemDoXML(ItemNode: IXMLNode): TItemVenda;
var
  Produto: TProduto;
  Quantidade, ValorUnitario, Desconto, PercentualDesconto: Double;
  ProdutoNode: IXMLNode;
begin
  Result := nil;
  
  try
    if not Assigned(ItemNode) then
      Exit;
    
    { Obter nó do produto }
    ProdutoNode := ItemNode.ChildNodes.FindNode('Produto');
    if not Assigned(ProdutoNode) then
      Exit;
    
    { Criar produto }
    Produto := CriarProdutoDoXML(ProdutoNode);
    if not Assigned(Produto) then
      Exit;
    
    { Extrair dados do item }
    Quantidade := StrToFloatDef(ItemNode.ChildNodes.FindNode('Quantidade').NodeValue, 1);
    ValorUnitario := StrToFloatDef(ItemNode.ChildNodes.FindNode('ValorUnitario').NodeValue, Produto.Preco);
    Desconto := StrToFloatDef(ItemNode.ChildNodes.FindNode('Desconto').NodeValue, 0);
    PercentualDesconto := StrToFloatDef(ItemNode.ChildNodes.FindNode('PercentualDesconto').NodeValue, 0);
    
    { Criar item }
    Result := TItemVenda.Create(Produto, Quantidade);
    Result.ValorUnitario := ValorUnitario;
    
    { Aplicar desconto se houver }
    if Desconto > 0 then
      Result.AplicarDesconto(Desconto, False)
    else if PercentualDesconto > 0 then
      Result.AplicarDesconto(PercentualDesconto, True);
    
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao criar item do XML: ' + E.Message;
      Result := nil;
    end;
  end;
end;

function TRecuperacaoVendas.CarregarXML: TVenda;
var
  XMLDoc: IXMLDocument;
  RootNode, VendaNode, ItensNode, ItemNode: IXMLNode;
  i: Integer;
  Item: TItemVenda;
  Produto: TProduto;
  OperadorID: Integer;
  Desconto, Acrescimo: Double;
begin
  Result := nil;
  
  try
    { Verificar se arquivo existe }
    if not TFile.Exists(ObterCaminhoArquivo) then
    begin
      FUltimoErro := 'Arquivo de venda pendente não encontrado';
      Exit;
    end;
    
    { Carregar documento XML }
    XMLDoc := LoadXMLDocument(ObterCaminhoArquivo);
    if not Assigned(XMLDoc) then
    begin
      FUltimoErro := 'Erro ao carregar documento XML';
      Exit;
    end;
    
    { Obter nó raiz }
    RootNode := XMLDoc.DocumentElement;
    if not Assigned(RootNode) then
    begin
      FUltimoErro := 'Nó raiz não encontrado no XML';
      Exit;
    end;
    
    { Obter nó de venda }
    VendaNode := RootNode.ChildNodes.FindNode('Venda');
    if not Assigned(VendaNode) then
    begin
      FUltimoErro := 'Nó de venda não encontrado no XML';
      Exit;
    end;
    
    { Extrair dados da venda }
    OperadorID := StrToIntDef(VendaNode.ChildNodes.FindNode('OperadorID').NodeValue, 1);
    Desconto := StrToFloatDef(VendaNode.ChildNodes.FindNode('Desconto').NodeValue, 0);
    Acrescimo := StrToFloatDef(VendaNode.ChildNodes.FindNode('Acrescimo').NodeValue, 0);
    
    { Criar nova venda }
    Result := TVenda.Create;
    Result.OperadorID := OperadorID;
    
    { Obter nó de itens }
    ItensNode := VendaNode.ChildNodes.FindNode('Itens');
    if Assigned(ItensNode) then
    begin
      { Carregar cada item }
      for i := 0 to ItensNode.ChildNodes.Count - 1 do
      begin
        ItemNode := ItensNode.ChildNodes[i];
        if ItemNode.NodeName = 'Item' then
        begin
          Item := CriarItemDoXML(ItemNode);
          //Produto := CriarItemDoXML(ItemNode);
          if Assigned(Item) then
            Result.AdicionarItem(Produto);
        end;
      end;
    end;
    
    { Aplicar desconto e acréscimo }
    if Desconto > 0 then
      Result.AplicarDesconto(Desconto, False);
    
    if Acrescimo > 0 then
      Result.AplicarAcrescimo(Acrescimo, False);
    
    FUltimoErro := '';
    
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao carregar venda do XML: ' + E.Message;
      if Assigned(Result) then
        Result.Free;
      Result := nil;
    end;
  end;
end;

// ============================================================================
// OPERAÇÕES PRINCIPAIS
// ============================================================================

function TRecuperacaoVendas.CarregarVendaPendente: TVenda;
begin
  { Carregar no formato especificado }
  try
    case FFormatoArquivo of
      faXML: Result := CarregarXML;
    else
      Result := CarregarXML;
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao carregar venda pendente: ' + E.Message;
      Result := nil;
    end;
  end;
end;

end.
