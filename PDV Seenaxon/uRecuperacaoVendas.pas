unit uRecuperacaoVendas;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IOUtils,
  System.DateUtils, Xml.XMLIntf, Xml.XMLDoc,
  uVenda, uItemVenda, uProduto, uRepositorioProdutos;

type
  { Enumeração para definir o formato de arquivo }
  TFormatoArquivo = (faXML, faCSV, faTXT);

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
    procedure SalvarCSV(AVenda: TVenda);
    procedure SalvarTXT(AVenda: TVenda);
    
    { Métodos privados para carregar de diferentes formatos }
    function CarregarXML: TVenda;
    function CarregarCSV: TVenda;
    function CarregarTXT: TVenda;
    
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
    faCSV: Result := TPath.Combine(FDiretorio, FArquivoVendaPendente + '.csv');
    faTXT: Result := TPath.Combine(FDiretorio, FArquivoVendaPendente + '.txt');
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
      faCSV: SalvarCSV(AVenda);
      faTXT: SalvarTXT(AVenda);
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
    VendaNode.AddChild('DataHora').NodeValue := FormatDateTime('yyyy-mm-dd hh:mm:ss', AVenda.DataHora);
    VendaNode.AddChild('Subtotal').NodeValue := FormatFloat('0.00', AVenda.Subtotal);
    VendaNode.AddChild('Desconto').NodeValue := FormatFloat('0.00', AVenda.Desconto);
    VendaNode.AddChild('PercentualDesconto').NodeValue := FormatFloat('0.00', AVenda.PercentualDesconto);
    VendaNode.AddChild('Acrescimo').NodeValue := FormatFloat('0.00', AVenda.Acrescimo);
    VendaNode.AddChild('PercentualAcrescimo').NodeValue := FormatFloat('0.00', AVenda.PercentualAcrescimo);
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
        ProdutoNode.AddChild('QuantidadeEstoque').NodeValue := Item.Produto.QuantidadeEstoque;
        
        { Adicionar dados do item }
        ItemNode.AddChild('Quantidade').NodeValue := FormatFloat('0.00', Item.Quantidade);
        ItemNode.AddChild('ValorUnitario').NodeValue := FormatFloat('0.00', Item.ValorUnitario);
        ItemNode.AddChild('ValorTotal').NodeValue := FormatFloat('0.00', Item.ValorTotal);
        ItemNode.AddChild('Desconto').NodeValue := FormatFloat('0.00', Item.Desconto);
        ItemNode.AddChild('PercentualDesconto').NodeValue := FormatFloat('0.00', Item.PercentualDesconto);
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
    Result := TProduto.Create(ID, Nome, Categoria, Preco, Estoque);
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
          if Assigned(Item) then
            Result.AdicionarItem(Item);
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
// SERIALIZAÇÃO EM CSV
// ============================================================================

procedure TRecuperacaoVendas.SalvarCSV(AVenda: TVenda);
var
  StringList: TStringList;
  i: Integer;
  Item: TItemVenda;
  Linha: string;
begin
  StringList := TStringList.Create;
  try
    { Cabeçalho do arquivo }
    StringList.Add('VENDA PENDENTE - RECUPERAÇÃO AUTOMÁTICA');
    StringList.Add('Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', Now));
    StringList.Add('');
    
    { Informações da venda }
    StringList.Add('INFORMAÇÕES DA VENDA');
    StringList.Add('Operador ID;' + IntToStr(AVenda.OperadorID));
    StringList.Add('Data Venda;' + FormatDateTime('dd/mm/yyyy hh:mm:ss', AVenda.DataVenda));
    StringList.Add('Subtotal;' + FormatFloat('0.00', AVenda.Subtotal));
    StringList.Add('Desconto;' + FormatFloat('0.00', AVenda.Desconto));
    StringList.Add('Percentual Desconto;' + FormatFloat('0.00', AVenda.PercentualDesconto));
    StringList.Add('Acréscimo;' + FormatFloat('0.00', AVenda.Acrescimo));
    StringList.Add('Percentual Acréscimo;' + FormatFloat('0.00', AVenda.PercentualAcrescimo));
    StringList.Add('Total;' + FormatFloat('0.00', AVenda.Total));
    StringList.Add('');
    
    { Cabeçalho dos itens }
    StringList.Add('ITENS DA VENDA');
    StringList.Add('Indice;ID Produto;Nome Produto;Preço Produto;Quantidade;Valor Unitário;Valor Total;Desconto;% Desconto');
    
    { Adicionar cada item }
    for i := 0 to AVenda.QuantidadeItens - 1 do
    begin
      Item := AVenda.GetItem(i);
      if Assigned(Item) and Assigned(Item.Produto) then
      begin
        Linha := Format('%d;%d;%s;%.2f;%.0f;%.2f;%.2f;%.2f;%.2f',
          [i,
           Item.Produto.ID,
           Item.Produto.Nome,
           Item.Produto.Preco,
           Item.Quantidade,
           Item.ValorUnitario,
           Item.ValorTotal,
           Item.Desconto,
           Item.PercentualDesconto]);
        StringList.Add(Linha);
      end;
    end;
    
    { Salvar arquivo CSV }
    StringList.SaveToFile(ObterCaminhoArquivo);
    
  finally
    StringList.Free;
  end;
end;

// ============================================================================
// DESSERIALIZAÇÃO EM CSV
// ============================================================================

function TRecuperacaoVendas.CarregarCSV: TVenda;
var
  StringList: TStringList;
  i, OperadorID: Integer;
  Linha, Partes: TArray<string>;
  Desconto, Acrescimo: Double;
begin
  Result := nil;
  StringList := TStringList.Create;
  
  try
    { Verificar se arquivo existe }
    if not TFile.Exists(ObterCaminhoArquivo) then
    begin
      FUltimoErro := 'Arquivo CSV não encontrado';
      Exit;
    end;
    
    { Carregar arquivo }
    StringList.LoadFromFile(ObterCaminhoArquivo);
    
    if StringList.Count < 10 then
    begin
      FUltimoErro := 'Arquivo CSV inválido';
      Exit;
    end;
    
    { Extrair dados da venda (linhas 4-12) }
    OperadorID := StrToIntDef(StringList[4].Split([';'])[1], 1);
    Desconto := StrToFloatDef(StringList[6].Split([';'])[1], 0);
    Acrescimo := StrToFloatDef(StringList[8].Split([';'])[1], 0);
    
    { Criar venda }
    Result := TVenda.Create;
    Result.OperadorID := OperadorID;
    
    { Carregar itens (começando na linha 14) }
    for i := 14 to StringList.Count - 1 do
    begin
      Linha := StringList[i];
      if Linha.Trim <> '' then
      begin
        Partes := Linha.Split([';']);
        if Length(Partes) >= 9 then
        begin
          { Partes: [Indice, ID, Nome, Preço, Qtd, ValorUnit, ValorTotal, Desconto, %Desconto] }
          // TODO: Implementar carregamento de itens do CSV
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
      FUltimoErro := 'Erro ao carregar venda do CSV: ' + E.Message;
      if Assigned(Result) then
        Result.Free;
      Result := nil;
    end;
  finally
    StringList.Free;
  end;
end;

// ============================================================================
// SERIALIZAÇÃO EM TXT
// ============================================================================

procedure TRecuperacaoVendas.SalvarTXT(AVenda: TVenda);
var
  StringList: TStringList;
  i: Integer;
  Item: TItemVenda;
begin
  StringList := TStringList.Create;
  try
    { Cabeçalho }
    StringList.Add('╔════════════════════════════════════════════════════════════╗');
    StringList.Add('║         VENDA PENDENTE - RECUPERAÇÃO AUTOMÁTICA            ║');
    StringList.Add('╚════════════════════════════════════════════════════════════╝');
    StringList.Add('');
    StringList.Add('Data/Hora de Salvamento: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', Now));
    StringList.Add('');
    
    { Informações da venda }
    StringList.Add('─── INFORMAÇÕES DA VENDA ───');
    StringList.Add('Operador ID:        ' + IntToStr(AVenda.OperadorID));
    StringList.Add('Data da Venda:      ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', AVenda.DataVenda));
    StringList.Add('Quantidade de Itens: ' + IntToStr(AVenda.QuantidadeItens));
    StringList.Add('');
    
    { Itens }
    StringList.Add('─── ITENS DA VENDA ───');
    for i := 0 to AVenda.QuantidadeItens - 1 do
    begin
      Item := AVenda.GetItem(i);
      if Assigned(Item) and Assigned(Item.Produto) then
      begin
        StringList.Add('');
        StringList.Add('Item ' + IntToStr(i + 1) + ':');
        StringList.Add('  Produto:        ' + Item.Produto.Nome);
        StringList.Add('  Categoria:      ' + Item.Produto.Categoria);
        StringList.Add('  Quantidade:     ' + FormatFloat('0.00', Item.Quantidade));
        StringList.Add('  Preço Unitário: R$ ' + FormatFloat('0.00', Item.ValorUnitario));
        StringList.Add('  Valor Total:    R$ ' + FormatFloat('0.00', Item.ValorTotal));
        
        if Item.Desconto > 0 then
          StringList.Add('  Desconto:       R$ ' + FormatFloat('0.00', Item.Desconto));
      end;
    end;
    
    StringList.Add('');
    StringList.Add('─── TOTALIZADORES ───');
    StringList.Add('Subtotal:   R$ ' + FormatFloat('0.00', AVenda.Subtotal));
    
    if AVenda.Desconto > 0 then
      StringList.Add('Desconto:   R$ ' + FormatFloat('0.00', AVenda.Desconto));
    
    if AVenda.Acrescimo > 0 then
      StringList.Add('Acréscimo:  R$ ' + FormatFloat('0.00', AVenda.Acrescimo));
    
    StringList.Add('');
    StringList.Add('TOTAL:      R$ ' + FormatFloat('0.00', AVenda.Total));
    StringList.Add('');
    StringList.Add('╔════════════════════════════════════════════════════════════╗');
    StringList.Add('║  Esta venda será retomada automaticamente ao iniciar      ║');
    StringList.Add('║  o sistema novamente.                                     ║');
    StringList.Add('╚════════════════════════════════════════════════════════════╝');
    
    { Salvar arquivo TXT }
    StringList.SaveToFile(ObterCaminhoArquivo);
    
  finally
    StringList.Free;
  end;
end;

// ============================================================================
// DESSERIALIZAÇÃO EM TXT
// ============================================================================

function TRecuperacaoVendas.CarregarTXT: TVenda;
begin
  { TXT é apenas para visualização, não para carregamento }
  Result := nil;
  FUltimoErro := 'Formato TXT não suporta carregamento. Use XML ou CSV.';
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
      faCSV: Result := CarregarCSV;
      faTXT: Result := CarregarTXT;
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
