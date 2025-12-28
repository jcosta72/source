unit uRecuperacaoVendas;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.IOUtils,
  Xml.XMLIntf, Xml.XMLDoc,
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
    
    { Métodos privados para obter caminho e salvar em diferentes formatos }
    function ObterCaminhoArquivo: string;
    procedure SalvarXML(AVenda: TVenda);
    procedure SalvarCSV(AVenda: TVenda);
    procedure SalvarTXT(AVenda: TVenda);
    
    { Métodos privados para carregar de diferentes formatos }
    function CarregarXML: TVenda;
    function CarregarCSV: TVenda;
    function CarregarTXT: TVenda;
    
  public
    constructor Create(ARepositorioProdutos: TRepositorioProdutos; AFormatoArquivo: TFormatoArquivo = faXML);
    destructor Destroy; override;
    
    { Operações de salvamento }
    procedure SalvarVendaPendente(AVenda: TVenda);
    procedure DeletarVendaPendente;
    
    { Operações de carregamento }
    function TemVendaPendente: Boolean;
    function CarregarVendaPendente: TVenda;
    
    { Configuração }
    procedure DefinirDiretorio(ADiretorio: string);
    
    { Propriedades }
    property Diretorio: string read FDiretorio write FDiretorio;
    property Formato: TFormatoArquivo read FFormatoArquivo write FFormatoArquivo;
  end;

implementation

// ============================================================================
// CONSTRUTOR E DESTRUTOR
// ============================================================================

constructor TRecuperacaoVendas.Create(ARepositorioProdutos: TRepositorioProdutos; 
  AFormatoArquivo: TFormatoArquivo = faXML);
begin
  inherited Create;
  FRepositorioProdutos := ARepositorioProdutos;
  FFormatoArquivo := AFormatoArquivo;
  
  { Usar diretório de documentos do usuário }
  FDiretorio := TPath.GetDocumentsPath;
  
  { Criar subdiretório para PDV se não existir }
  FDiretorio := TPath.Combine(FDiretorio, 'PDV_Vendas_Pendentes');
  if not TDirectory.Exists(FDiretorio) then
    TDirectory.CreateDirectory(FDiretorio);
  
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
    TDirectory.CreateDirectory(FDiretorio);
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
    except
      on E: Exception do
      begin
        { Silenciosamente ignorar erro de deleção }
        // Pode adicionar log aqui se necessário
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
    Exit;
  
  { Salvar no formato especificado }
  case FFormatoArquivo of
    faXML: SalvarXML(AVenda);
    faCSV: SalvarCSV(AVenda);
    faTXT: SalvarTXT(AVenda);
  end;
end;

// ============================================================================
// SERIALIZAÇÃO EM XML
// ============================================================================

procedure TRecuperacaoVendas.SalvarXML(AVenda: TVenda);
var
  XMLDoc: IXMLDocument;
  RootNode, VendaNode, ItensNode, ItemNode: IXMLNode;
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
    VendaNode.AddChild('OperadorID').NodeValue := AVenda.OperadorID;
    VendaNode.AddChild('DataVenda').NodeValue := FormatDateTime('yyyy-mm-dd hh:mm:ss', AVenda.DataVenda);
    VendaNode.AddChild('Subtotal').NodeValue := FormatFloat('0.00', AVenda.Subtotal);
    VendaNode.AddChild('Desconto').NodeValue := FormatFloat('0.00', AVenda.Desconto);
    VendaNode.AddChild('PercentualDesconto').NodeValue := FormatFloat('0.00', AVenda.PercentualDesconto);
    VendaNode.AddChild('Acrescimo').NodeValue := FormatFloat('0.00', AVenda.Acrescimo);
    VendaNode.AddChild('PercentualAcrescimo').NodeValue := FormatFloat('0.00', AVenda.PercentualAcrescimo);
    VendaNode.AddChild('Total').NodeValue := FormatFloat('0.00', AVenda.Total);
    VendaNode.AddChild('QuantidadeItens').NodeValue := AVenda.QuantidadeItens;
    
    { Criar nó de itens }
    ItensNode := VendaNode.AddChild('Itens');
    
    { Adicionar cada item da venda }
    for i := 0 to AVenda.QuantidadeItens - 1 do
    begin
      Item := AVenda.GetItem(i);
      if Assigned(Item) then
      begin
        ItemNode := ItensNode.AddChild('Item');
        ItemNode.Attributes['indice'] := i;
        
        { Adicionar dados do produto }
        with ItemNode.AddChild('Produto') do
        begin
          AddChild('ID').NodeValue := Item.Produto.ID;
          AddChild('Nome').NodeValue := Item.Produto.Nome;
          AddChild('Descricao').NodeValue := Item.Produto.Descricao;
          AddChild('Preco').NodeValue := FormatFloat('0.00', Item.Produto.Preco);
          AddChild('Categoria').NodeValue := Item.Produto.Categoria;
        end;
        
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
      { Tratamento de erro }
      raise Exception.Create('Erro ao salvar venda em XML: ' + E.Message);
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
      if Assigned(Item) then
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
    
  except
    on E: Exception do
      raise Exception.Create('Erro ao salvar venda em CSV: ' + E.Message);
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
    StringList.Add(StringOfChar('=', 80));
    StringList.Add('VENDA PENDENTE - RECUPERAÇÃO AUTOMÁTICA');
    StringList.Add(StringOfChar('=', 80));
    StringList.Add('');
    StringList.Add('Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', Now));
    StringList.Add('');
    
    { Informações da venda }
    StringList.Add('INFORMAÇÕES DA VENDA:');
    StringList.Add(StringOfChar('-', 80));
    StringList.Add(Format('Operador ID: %d', [AVenda.OperadorID]));
    StringList.Add(Format('Data da Venda: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', AVenda.DataVenda)]));
    StringList.Add(Format('Subtotal: R$ %.2f', [AVenda.Subtotal]));
    StringList.Add(Format('Desconto: R$ %.2f', [AVenda.Desconto]));
    
    if AVenda.PercentualDesconto > 0 then
      StringList.Add(Format('Percentual de Desconto: %.2f%%', [AVenda.PercentualDesconto]));
    
    StringList.Add(Format('Acréscimo: R$ %.2f', [AVenda.Acrescimo]));
    
    if AVenda.PercentualAcrescimo > 0 then
      StringList.Add(Format('Percentual de Acréscimo: %.2f%%', [AVenda.PercentualAcrescimo]));
    
    StringList.Add(Format('TOTAL: R$ %.2f', [AVenda.Total]));
    StringList.Add(Format('Quantidade de Itens: %d', [AVenda.QuantidadeItens]));
    StringList.Add('');
    
    { Itens da venda }
    StringList.Add('ITENS DA VENDA:');
    StringList.Add(StringOfChar('-', 80));
    StringList.Add('');
    
    for i := 0 to AVenda.QuantidadeItens - 1 do
    begin
      Item := AVenda.GetItem(i);
      if Assigned(Item) then
      begin
        StringList.Add(Format('%d. %s (ID: %d)', [i + 1, Item.Produto.Nome, Item.Produto.ID]));
        StringList.Add(Format('   Quantidade: %.0f', [Item.Quantidade]));
        StringList.Add(Format('   Preço Unitário: R$ %.2f', [Item.ValorUnitario]));
        StringList.Add(Format('   Valor Total: R$ %.2f', [Item.ValorTotal]));
        
        if Item.Desconto > 0 then
          StringList.Add(Format('   Desconto: R$ %.2f (%.2f%%)', [Item.Desconto, Item.PercentualDesconto]));
        
        StringList.Add('');
      end;
    end;
    
    { Rodapé }
    StringList.Add(StringOfChar('=', 80));
    StringList.Add('Arquivo gerado automaticamente para recuperação de venda pendente.');
    StringList.Add('Data de Geração: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', Now));
    StringList.Add(StringOfChar('=', 80));
    
    { Salvar arquivo TXT }
    StringList.SaveToFile(ObterCaminhoArquivo);
    
  except
    on E: Exception do
      raise Exception.Create('Erro ao salvar venda em TXT: ' + E.Message);
  finally
    StringList.Free;
  end;
end;

// ============================================================================
// CARREGAMENTO DE VENDAS PENDENTES
// ============================================================================

function TRecuperacaoVendas.CarregarVendaPendente: TVenda;
begin
  { Verificar se arquivo existe }
  if not TemVendaPendente then
    Exit(nil);
  
  { Carregar no formato especificado }
  case FFormatoArquivo of
    faXML: Result := CarregarXML;
    faCSV: Result := CarregarCSV;
    faTXT: Result := CarregarTXT;
  else
    Result := nil;
  end;
end;

// ============================================================================
// DESSERIALIZAÇÃO DE XML
// ============================================================================

function TRecuperacaoVendas.CarregarXML: TVenda;
var
  XMLDoc: IXMLDocument;
  RootNode, VendaNode, ItensNode, ItemNode, ProdutoNode: IXMLNode;
  i: Integer;
  Venda: TVenda;
  Produto: TProduto;
  Item: TItemVenda;
  ProdutoID: Integer;
  Quantidade: Double;
  Desconto: Double;
  PercentualDesconto: Double;
begin
  Result := nil;
  
  { Verificar se arquivo existe }
  if not TFile.Exists(ObterCaminhoArquivo) then
    Exit;
  
  try
    { Carregar documento XML }
    XMLDoc := LoadXMLDocument(ObterCaminhoArquivo);
    RootNode := XMLDoc.DocumentElement;
    
    { Validar nó raiz }
    if RootNode.NodeName <> 'VendaPendente' then
      Exit;
    
    { Buscar nó de venda }
    VendaNode := RootNode.ChildNodes.FindNode('Venda');
    if not Assigned(VendaNode) then
      Exit;
    
    { Criar nova venda }
    Venda := TVenda.Create;
    
    try
      { Restaurar dados da venda }
      if Assigned(VendaNode.ChildNodes.FindNode('OperadorID')) then
        Venda.OperadorID := StrToIntDef(VendaNode.ChildNodes.FindNode('OperadorID').NodeValue, 0);
      
      { Restaurar itens }
      ItensNode := VendaNode.ChildNodes.FindNode('Itens');
      if Assigned(ItensNode) then
      begin
        for i := 0 to ItensNode.ChildNodes.Count - 1 do
        begin
          ItemNode := ItensNode.ChildNodes[i];
          
          if ItemNode.NodeName = 'Item' then
          begin
            { Extrair ID do produto }
            ProdutoNode := ItemNode.ChildNodes.FindNode('Produto');
            if Assigned(ProdutoNode) then
            begin
              ProdutoID := StrToIntDef(ProdutoNode.ChildNodes.FindNode('ID').NodeValue, 0);
              
              { Extrair quantidade }
              Quantidade := StrToFloatDef(ItemNode.ChildNodes.FindNode('Quantidade').NodeValue, 0);
              
              { Buscar produto no repositório }
              Produto := FRepositorioProdutos.BuscarPorID(ProdutoID);
              if Assigned(Produto) then
              begin
                { Criar item de venda }
                Item := TItemVenda.Create(Produto, Quantidade);
                
                { Restaurar desconto do item se houver }
                if Assigned(ItemNode.ChildNodes.FindNode('Desconto')) then
                begin
                  Desconto := StrToFloatDef(ItemNode.ChildNodes.FindNode('Desconto').NodeValue, 0);
                  PercentualDesconto := StrToFloatDef(ItemNode.ChildNodes.FindNode('PercentualDesconto').NodeValue, 0);
                  
                  if Desconto > 0 then
                    Item.AplicarDesconto(Desconto, PercentualDesconto > 0);
                end;
                
                { Adicionar item à venda }
                Venda.AdicionarItem(Item);
              end;
            end;
          end;
        end;
      end;
      
      Result := Venda;
      
    except
      { Em caso de erro, liberar venda }
      Venda.Free;
      Result := nil;
    end;
    
  except
    on E: Exception do
    begin
      { Tratamento de erro }
      Result := nil;
      // Pode adicionar log aqui se necessário
    end;
  end;
end;

// ============================================================================
// DESSERIALIZAÇÃO DE CSV
// ============================================================================

function TRecuperacaoVendas.CarregarCSV: TVenda;
var
  StringList: TStringList;
  i: Integer;
  Linha: string;
  Partes: TArray<string>;
  Venda: TVenda;
  Produto: TProduto;
  Item: TItemVenda;
  ProdutoID: Integer;
  Quantidade: Double;
  EmItens: Boolean;
begin
  Result := nil;
  
  { Verificar se arquivo existe }
  if not TFile.Exists(ObterCaminhoArquivo) then
    Exit;
  
  StringList := TStringList.Create;
  try
    { Carregar arquivo CSV }
    StringList.LoadFromFile(ObterCaminhoArquivo);
    
    { Criar nova venda }
    Venda := TVenda.Create;
    EmItens := False;
    
    try
      { Processar cada linha }
      for i := 0 to StringList.Count - 1 do
      begin
        Linha := StringList[i];
        
        { Detectar início da seção de itens }
        if Linha = 'ITENS DA VENDA' then
        begin
          EmItens := True;
          Continue;
        end;
        
        { Processar linhas de itens }
        if EmItens and (Linha <> '') and 
           (Linha <> 'Indice;ID Produto;Nome Produto;Preço Produto;Quantidade;Valor Unitário;Valor Total;Desconto;% Desconto') then
        begin
          { Dividir linha por ponto-e-vírgula }
          Partes := Linha.Split([';']);
          
          { Validar número de campos }
          if Length(Partes) >= 5 then
          begin
            try
              { Extrair ID do produto (campo 1) }
              ProdutoID := StrToIntDef(Trim(Partes[1]), 0);
              
              { Extrair quantidade (campo 4) }
              Quantidade := StrToFloatDef(Trim(Partes[4]), 0);
              
              { Buscar produto no repositório }
              Produto := FRepositorioProdutos.BuscarPorID(ProdutoID);
              if Assigned(Produto) then
              begin
                { Criar item de venda }
                Item := TItemVenda.Create(Produto, Quantidade);
                
                { Restaurar desconto se houver (campos 7 e 8) }
                if Length(Partes) >= 9 then
                begin
                  var Desconto := StrToFloatDef(Trim(Partes[7]), 0);
                  if Desconto > 0 then
                    Item.AplicarDesconto(Desconto, False);
                end;
                
                { Adicionar item à venda }
                Venda.AdicionarItem(Item);
              end;
            except
              { Ignorar linhas com erro de parsing }
              Continue;
            end;
          end;
        end;
      end;
      
      Result := Venda;
      
    except
      { Em caso de erro, liberar venda }
      Venda.Free;
      Result := nil;
    end;
    
  finally
    StringList.Free;
  end;
end;

// ============================================================================
// DESSERIALIZAÇÃO DE TXT
// ============================================================================

function TRecuperacaoVendas.CarregarTXT: TVenda;
var
  StringList: TStringList;
  i: Integer;
  Linha: string;
  Venda: TVenda;
  Produto: TProduto;
  Item: TItemVenda;
  ProdutoID: Integer;
  Quantidade: Double;
  EmItens: Boolean;
  Partes: TArray<string>;
  NomeItem: string;
begin
  Result := nil;
  
  { Verificar se arquivo existe }
  if not TFile.Exists(ObterCaminhoArquivo) then
    Exit;
  
  StringList := TStringList.Create;
  try
    { Carregar arquivo TXT }
    StringList.LoadFromFile(ObterCaminhoArquivo);
    
    { Criar nova venda }
    Venda := TVenda.Create;
    EmItens := False;
    i := 0;
    
    try
      { Processar cada linha }
      while i < StringList.Count do
      begin
        Linha := StringList[i];
        
        { Detectar início da seção de itens }
        if Pos('ITENS DA VENDA:', Linha) > 0 then
        begin
          EmItens := True;
          Inc(i);
          Continue;
        end;
        
        { Processar linhas de itens }
        if EmItens and (Pos('. ', Linha) > 0) and (Pos('ID:', Linha) > 0) then
        begin
          try
            { Extrair nome do item e ID }
            { Formato: "N. Nome (ID: X)" }
            var IDPos := Pos('ID: ', Linha);
            if IDPos > 0 then
            begin
              var IDStr := Copy(Linha, IDPos + 4, Length(Linha));
              IDStr := Copy(IDStr, 1, Pos(')', IDStr) - 1);
              ProdutoID := StrToIntDef(Trim(IDStr), 0);
              
              { Próxima linha deve ter Quantidade }
              if (i + 1 < StringList.Count) and (Pos('Quantidade:', StringList[i + 1]) > 0) then
              begin
                var QuantidadeStr := StringList[i + 1];
                QuantidadeStr := Copy(QuantidadeStr, Pos(':', QuantidadeStr) + 1, Length(QuantidadeStr));
                Quantidade := StrToFloatDef(Trim(QuantidadeStr), 0);
                
                { Buscar produto no repositório }
                Produto := FRepositorioProdutos.BuscarPorID(ProdutoID);
                if Assigned(Produto) then
                begin
                  { Criar item de venda }
                  Item := TItemVenda.Create(Produto, Quantidade);
                  
                  { Adicionar item à venda }
                  Venda.AdicionarItem(Item);
                end;
              end;
            end;
          except
            { Ignorar linhas com erro de parsing }
          end;
        end;
        
        Inc(i);
      end;
      
      Result := Venda;
      
    except
      { Em caso de erro, liberar venda }
      Venda.Free;
      Result := nil;
    end;
    
  finally
    StringList.Free;
  end;
end;

end.
