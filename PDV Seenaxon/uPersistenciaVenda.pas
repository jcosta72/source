unit uPersistenciaVenda;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections,
  FireDAC.Comp.Client, FireDAC.Stan.Param,
  uVenda, uItemVenda, uProduto, uDMConexao;

type
  { Classe de persistência de vendas }
  TPersistenciaVenda = class
  private
    FConexao: TFDConnection;
    FUltimoErro: string;
    
    function ValidarVenda(AVenda: TVenda): Boolean;
    function ValidarItemVenda(AItem: TItemVenda): Boolean;
    function ExecutarSQL(ASQL: string; AParams: array of const): Boolean;
  public
    constructor Create(AConexao: TFDConnection);
    destructor Destroy; override;
    
    { ========== CRUD DE VENDAS ========== }
    
    { Salvar nova venda }
    function SalvarVenda(AVenda: TVenda): Boolean;
    
    { Atualizar venda existente }
    function AtualizarVenda(AVenda: TVenda): Boolean;
    
    { Deletar venda }
    function DeletarVenda(AID: Integer): Boolean;
    
    { Obter venda por ID }
    function ObterVendaPorID(AID: Integer): TVenda;
    
    { Obter todas as vendas }
    function ObterTodasVendas: TObjectList<TVenda>;
    
    { Obter vendas por operador }
    function ObterVendasPorOperador(AOperadorID: Integer): TObjectList<TVenda>;
    
    { Obter vendas por caixa }
    function ObterVendasPorCaixa(ACaixaID: Integer): TObjectList<TVenda>;
    
    { Obter vendas por período }
    function ObterVendasPorPeriodo(ADataInicio: TDateTime; ADataFim: TDateTime): TObjectList<TVenda>;
    
    { Obter vendas por forma de pagamento }
    function ObterVendasPorFormaPagamento(AFormaPagamento: Integer): TObjectList<TVenda>;
    
    { ========== CRUD DE ITENS DE VENDA ========== }
    
    { Salvar item de venda }
    function SalvarItemVenda(AVendaID: Integer; AItem: TItemVenda): Boolean;
    
    { Atualizar item de venda }
    function AtualizarItemVenda(AItemID: Integer; AItem: TItemVenda): Boolean;
    
    { Deletar item de venda }
    function DeletarItemVenda(AItemID: Integer): Boolean;
    
    { Obter itens de venda }
    function ObterItensVenda(AVendaID: Integer): TObjectList<TItemVenda>;
    
    { ========== OPERAÇÕES ESPECIAIS ========== }
    
    { Finalizar venda (marcar como concluída) }
    function FinalizarVenda(AVendaID: Integer; AFormaPagamento: Integer; AValorPago: Double): Boolean;
    
    { Cancelar venda }
    function CancelarVenda(AVendaID: Integer; AMotivo: string): Boolean;
    
    { Recuperar venda pendente }
    function RecuperarVendaPendente: TVenda;
    
    { Salvar venda como pendente }
    function SalvarVendaPendente(AVenda: TVenda): Boolean;
    
    { Deletar venda pendente }
    function DeletarVendaPendente(AVendaID: Integer): Boolean;
    
    { ========== ESTATÍSTICAS ========== }
    
    { Obter total de vendas }
    function ObterTotalVendas: Double;
    
    { Obter quantidade de vendas }
    function ObterQuantidadeVendas: Integer;
    
    { Obter valor médio de venda }
    function ObterValorMedioVenda: Double;
    
    { Obter maior venda }
    function ObterMaiorVenda: Double;
    
    { Obter menor venda }
    function ObterMenorVenda: Double;
    
    { Obter total de descontos }
    function ObterTotalDescontos: Double;
    
    { Obter total de acréscimos }
    function ObterTotalAcrescimos: Double;
    
    { Obter quantidade de produtos vendidos }
    function ObterQuantidadeProdutosVendidos: Integer;
    
    { ========== PROPRIEDADES ========== }
    
    property UltimoErro: string read FUltimoErro;
  end;

implementation

{ ============================================================================
  CONSTRUTOR E DESTRUTOR
  ============================================================================ }

constructor TPersistenciaVenda.Create(AConexao: TFDConnection);
begin
  inherited Create;
  FConexao := AConexao;
  FUltimoErro := '';
end;

destructor TPersistenciaVenda.Destroy;
begin
  inherited;
end;

{ ============================================================================
  MÉTODOS AUXILIARES
  ============================================================================ }

function TPersistenciaVenda.ValidarVenda(AVenda: TVenda): Boolean;
begin
  Result := True;
  
  { Validar operador }
  if AVenda.OperadorID <= 0 then
  begin
    FUltimoErro := 'ID do operador inválido';
    Result := False;
    Exit;
  end;
  
  { Validar caixa }
  if AVenda.CaixaID <= 0 then
  begin
    FUltimoErro := 'ID do caixa inválido';
    Result := False;
    Exit;
  end;
end;

function TPersistenciaVenda.ValidarItemVenda(AItem: TItemVenda): Boolean;
begin
  Result := True;
  
  { Validar quantidade }
  if AItem.Quantidade <= 0 then
  begin
    FUltimoErro := 'Quantidade deve ser maior que zero';
    Result := False;
    Exit;
  end;
  
  { Validar valor unitário }
  if AItem.ValorUnitario <= 0 then
  begin
    FUltimoErro := 'Valor unitário deve ser maior que zero';
    Result := False;
    Exit;
  end;
end;

function TPersistenciaVenda.ExecutarSQL(ASQL: string; AParams: array of const): Boolean;
var
  Query: TFDQuery;
  i: Integer;
begin
  Result := False;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := ASQL;
    
    { Adicionar parâmetros }
    for i := 0 to Length(AParams) - 1 do
    begin
      case AParams[i].VType of
        vtInteger:
          Query.ParamByName('P' + IntToStr(i + 1)).AsInteger := AParams[i].VInteger;
        vtString:
          Query.ParamByName('P' + IntToStr(i + 1)).AsString := string(AParams[i].VString);
        vtExtended:
          Query.ParamByName('P' + IntToStr(i + 1)).AsFloat := AParams[i].VExtended^;
      end;
    end;
    
    { Executar }
    Query.ExecSQL;
    
    Result := True;
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao executar SQL: ' + E.Message;
      Result := False;
    end;
  finally
    Query.Free;
  end;
end;

{ ============================================================================
  CRUD DE VENDAS
  ============================================================================ }

function TPersistenciaVenda.SalvarVenda(AVenda: TVenda): Boolean;
begin
  Result := False;
  
  try
    { Validar venda }
    if not ValidarVenda(AVenda) then
      Exit;
    
    { SQL de inserção }
    if ExecutarSQL(
      'INSERT INTO Vendas (OperadorID, CaixaID, Subtotal, Desconto, Acrescimo, Total, FormaPagamento, ValorPago, Troco, Status, DataVenda) ' +
      'VALUES (:P1, :P2, :P3, :P4, :P5, :P6, :P7, :P8, :P9, :P10, :P11)',
      [AVenda.OperadorID, AVenda.CaixaID, AVenda.Subtotal, AVenda.Desconto, AVenda.Acrescimo, AVenda.Total, 
       AVenda.FormaPagamento, AVenda.ValorPago, AVenda.Troco, 0, Now]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.AtualizarVenda(AVenda: TVenda): Boolean;
begin
  Result := False;
  
  try
    { Validar venda }
    if not ValidarVenda(AVenda) then
      Exit;
    
    { SQL de atualização }
    if ExecutarSQL(
      'UPDATE Vendas SET OperadorID = :P1, CaixaID = :P2, Subtotal = :P3, Desconto = :P4, Acrescimo = :P5, Total = :P6, ' +
      'FormaPagamento = :P7, ValorPago = :P8, Troco = :P9, Status = :P10, DataAtualizacao = :P11 WHERE ID = :P12',
      [AVenda.OperadorID, AVenda.CaixaID, AVenda.Subtotal, AVenda.Desconto, AVenda.Acrescimo, AVenda.Total,
       AVenda.FormaPagamento, AVenda.ValorPago, AVenda.Troco, AVenda.Status, Now, AVenda.ID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao atualizar venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.DeletarVenda(AID: Integer): Boolean;
begin
  Result := False;
  
  try
    { Deletar itens primeiro }
    ExecutarSQL('DELETE FROM ItensVenda WHERE VendaID = :P1', [AID]);
    
    { Deletar venda }
    if ExecutarSQL('DELETE FROM Vendas WHERE ID = :P1', [AID]) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.ObterVendaPorID(AID: Integer): TVenda;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Vendas WHERE ID = :P1';
    Query.ParamByName('P1').AsInteger := AID;
    Query.Open;
    
    if not Query.Eof then
    begin
      Result := TVenda.Create;
      Result.ID := Query.FieldByName('ID').AsInteger;
      Result.OperadorID := Query.FieldByName('OperadorID').AsInteger;
      Result.CaixaID := Query.FieldByName('CaixaID').AsInteger;
      Result.Subtotal := Query.FieldByName('Subtotal').AsFloat;
      Result.Desconto := Query.FieldByName('Desconto').AsFloat;
      Result.Acrescimo := Query.FieldByName('Acrescimo').AsFloat;
      Result.Total := Query.FieldByName('Total').AsFloat;
      Result.FormaPagamento := Query.FieldByName('FormaPagamento').AsInteger;
      Result.ValorPago := Query.FieldByName('ValorPago').AsFloat;
      Result.Troco := Query.FieldByName('Troco').AsFloat;
      Result.Status := Query.FieldByName('Status').AsInteger;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter venda: ' + E.Message;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterTodasVendas: TObjectList<TVenda>;
var
  Query: TFDQuery;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Vendas ORDER BY DataVenda DESC';
    Query.Open;
    
    while not Query.Eof do
    begin
      Venda := TVenda.Create;
      Venda.ID := Query.FieldByName('ID').AsInteger;
      Venda.OperadorID := Query.FieldByName('OperadorID').AsInteger;
      Venda.CaixaID := Query.FieldByName('CaixaID').AsInteger;
      Venda.Subtotal := Query.FieldByName('Subtotal').AsFloat;
      Venda.Desconto := Query.FieldByName('Desconto').AsFloat;
      Venda.Acrescimo := Query.FieldByName('Acrescimo').AsFloat;
      Venda.Total := Query.FieldByName('Total').AsFloat;
      Venda.FormaPagamento := Query.FieldByName('FormaPagamento').AsInteger;
      Venda.ValorPago := Query.FieldByName('ValorPago').AsFloat;
      Venda.Troco := Query.FieldByName('Troco').AsFloat;
      Venda.Status := Query.FieldByName('Status').AsInteger;
      
      Result.Add(Venda);
      Query.Next;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter vendas: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterVendasPorOperador(AOperadorID: Integer): TObjectList<TVenda>;
var
  Query: TFDQuery;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Vendas WHERE OperadorID = :P1 ORDER BY DataVenda DESC';
    Query.ParamByName('P1').AsInteger := AOperadorID;
    Query.Open;
    
    while not Query.Eof do
    begin
      Venda := TVenda.Create;
      Venda.ID := Query.FieldByName('ID').AsInteger;
      Venda.OperadorID := Query.FieldByName('OperadorID').AsInteger;
      Venda.CaixaID := Query.FieldByName('CaixaID').AsInteger;
      Venda.Subtotal := Query.FieldByName('Subtotal').AsFloat;
      Venda.Desconto := Query.FieldByName('Desconto').AsFloat;
      Venda.Acrescimo := Query.FieldByName('Acrescimo').AsFloat;
      Venda.Total := Query.FieldByName('Total').AsFloat;
      Venda.FormaPagamento := Query.FieldByName('FormaPagamento').AsInteger;
      Venda.ValorPago := Query.FieldByName('ValorPago').AsFloat;
      Venda.Troco := Query.FieldByName('Troco').AsFloat;
      Venda.Status := Query.FieldByName('Status').AsInteger;
      
      Result.Add(Venda);
      Query.Next;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter vendas por operador: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterVendasPorCaixa(ACaixaID: Integer): TObjectList<TVenda>;
var
  Query: TFDQuery;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Vendas WHERE CaixaID = :P1 ORDER BY DataVenda DESC';
    Query.ParamByName('P1').AsInteger := ACaixaID;
    Query.Open;
    
    while not Query.Eof do
    begin
      Venda := TVenda.Create;
      Venda.ID := Query.FieldByName('ID').AsInteger;
      Venda.OperadorID := Query.FieldByName('OperadorID').AsInteger;
      Venda.CaixaID := Query.FieldByName('CaixaID').AsInteger;
      Venda.Subtotal := Query.FieldByName('Subtotal').AsFloat;
      Venda.Desconto := Query.FieldByName('Desconto').AsFloat;
      Venda.Acrescimo := Query.FieldByName('Acrescimo').AsFloat;
      Venda.Total := Query.FieldByName('Total').AsFloat;
      Venda.FormaPagamento := Query.FieldByName('FormaPagamento').AsInteger;
      Venda.ValorPago := Query.FieldByName('ValorPago').AsFloat;
      Venda.Troco := Query.FieldByName('Troco').AsFloat;
      Venda.Status := Query.FieldByName('Status').AsInteger;
      
      Result.Add(Venda);
      Query.Next;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter vendas por caixa: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterVendasPorPeriodo(ADataInicio: TDateTime; ADataFim: TDateTime): TObjectList<TVenda>;
var
  Query: TFDQuery;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Vendas WHERE DataVenda BETWEEN :P1 AND :P2 ORDER BY DataVenda DESC';
    Query.ParamByName('P1').AsDateTime := ADataInicio;
    Query.ParamByName('P2').AsDateTime := ADataFim;
    Query.Open;
    
    while not Query.Eof do
    begin
      Venda := TVenda.Create;
      Venda.ID := Query.FieldByName('ID').AsInteger;
      Venda.OperadorID := Query.FieldByName('OperadorID').AsInteger;
      Venda.CaixaID := Query.FieldByName('CaixaID').AsInteger;
      Venda.Subtotal := Query.FieldByName('Subtotal').AsFloat;
      Venda.Desconto := Query.FieldByName('Desconto').AsFloat;
      Venda.Acrescimo := Query.FieldByName('Acrescimo').AsFloat;
      Venda.Total := Query.FieldByName('Total').AsFloat;
      Venda.FormaPagamento := Query.FieldByName('FormaPagamento').AsInteger;
      Venda.ValorPago := Query.FieldByName('ValorPago').AsFloat;
      Venda.Troco := Query.FieldByName('Troco').AsFloat;
      Venda.Status := Query.FieldByName('Status').AsInteger;
      
      Result.Add(Venda);
      Query.Next;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter vendas por período: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterVendasPorFormaPagamento(AFormaPagamento: Integer): TObjectList<TVenda>;
var
  Query: TFDQuery;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Vendas WHERE FormaPagamento = :P1 ORDER BY DataVenda DESC';
    Query.ParamByName('P1').AsInteger := AFormaPagamento;
    Query.Open;
    
    while not Query.Eof do
    begin
      Venda := TVenda.Create;
      Venda.ID := Query.FieldByName('ID').AsInteger;
      Venda.OperadorID := Query.FieldByName('OperadorID').AsInteger;
      Venda.CaixaID := Query.FieldByName('CaixaID').AsInteger;
      Venda.Subtotal := Query.FieldByName('Subtotal').AsFloat;
      Venda.Desconto := Query.FieldByName('Desconto').AsFloat;
      Venda.Acrescimo := Query.FieldByName('Acrescimo').AsFloat;
      Venda.Total := Query.FieldByName('Total').AsFloat;
      Venda.FormaPagamento := Query.FieldByName('FormaPagamento').AsInteger;
      Venda.ValorPago := Query.FieldByName('ValorPago').AsFloat;
      Venda.Troco := Query.FieldByName('Troco').AsFloat;
      Venda.Status := Query.FieldByName('Status').AsInteger;
      
      Result.Add(Venda);
      Query.Next;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter vendas por forma de pagamento: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

{ ============================================================================
  CRUD DE ITENS DE VENDA
  ============================================================================ }

function TPersistenciaVenda.SalvarItemVenda(AVendaID: Integer; AItem: TItemVenda): Boolean;
begin
  Result := False;
  
  try
    { Validar item }
    if not ValidarItemVenda(AItem) then
      Exit;
    
    { SQL de inserção - Suporte a decimais }
    if ExecutarSQL(
      'INSERT INTO ItensVenda (VendaID, ProdutoID, Quantidade, ValorUnitario, Desconto, Total, UnidadeMedida) ' +
      'VALUES (:P1, :P2, :P3, :P4, :P5, :P6, :P7)',
      [AVendaID, AItem.Produto.ID, AItem.Quantidade, AItem.ValorUnitario, AItem.Desconto, AItem.Total, Ord(AItem.Produto.UnidadeMedida)]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao salvar item de venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.AtualizarItemVenda(AItemID: Integer; AItem: TItemVenda): Boolean;
begin
  Result := False;
  
  try
    { Validar item }
    if not ValidarItemVenda(AItem) then
      Exit;
    
    { SQL de atualização - Suporte a decimais }
    if ExecutarSQL(
      'UPDATE ItensVenda SET Quantidade = :P1, ValorUnitario = :P2, Desconto = :P3, Total = :P4 WHERE ID = :P5',
      [AItem.Quantidade, AItem.ValorUnitario, AItem.Desconto, AItem.Total, AItemID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao atualizar item de venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.DeletarItemVenda(AItemID: Integer): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL('DELETE FROM ItensVenda WHERE ID = :P1', [AItemID]) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao deletar item de venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.ObterItensVenda(AVendaID: Integer): TObjectList<TItemVenda>;
var
  Query: TFDQuery;
  Item: TItemVenda;
begin
  Result := TObjectList<TItemVenda>.Create;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM ItensVenda WHERE VendaID = :P1 ORDER BY ID';
    Query.ParamByName('P1').AsInteger := AVendaID;
    Query.Open;
    
    while not Query.Eof do
    begin
      Item := TItemVenda.Create(nil);
      Item.Quantidade := Query.FieldByName('Quantidade').AsFloat;
      Item.ValorUnitario := Query.FieldByName('ValorUnitario').AsFloat;
      Item.Desconto := Query.FieldByName('Desconto').AsFloat;
      
      Result.Add(Item);
      Query.Next;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter itens de venda: ' + E.Message;
      Result.Free;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

{ ============================================================================
  OPERAÇÕES ESPECIAIS
  ============================================================================ }

function TPersistenciaVenda.FinalizarVenda(AVendaID: Integer; AFormaPagamento: Integer; AValorPago: Double): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'UPDATE Vendas SET FormaPagamento = :P1, ValorPago = :P2, Status = :P3, DataAtualizacao = :P4 WHERE ID = :P5',
      [AFormaPagamento, AValorPago, 1, Now, AVendaID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao finalizar venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.CancelarVenda(AVendaID: Integer; AMotivo: string): Boolean;
begin
  Result := False;
  
  try
    if ExecutarSQL(
      'UPDATE Vendas SET Status = :P1, Motivo = :P2, DataAtualizacao = :P3 WHERE ID = :P4',
      [2, AMotivo, Now, AVendaID]
    ) then
    begin
      Result := True;
      FUltimoErro := '';
    end;
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao cancelar venda: ' + E.Message;
      Result := False;
    end;
  end;
end;

function TPersistenciaVenda.RecuperarVendaPendente: TVenda;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT * FROM Vendas WHERE Status = 0 ORDER BY DataVenda DESC LIMIT 1';
    Query.Open;
    
    if not Query.Eof then
    begin
      Result := TVenda.Create;
      Result.ID := Query.FieldByName('ID').AsInteger;
      Result.OperadorID := Query.FieldByName('OperadorID').AsInteger;
      Result.CaixaID := Query.FieldByName('CaixaID').AsInteger;
      Result.Subtotal := Query.FieldByName('Subtotal').AsFloat;
      Result.Desconto := Query.FieldByName('Desconto').AsFloat;
      Result.Acrescimo := Query.FieldByName('Acrescimo').AsFloat;
      Result.Total := Query.FieldByName('Total').AsFloat;
      Result.Status := Query.FieldByName('Status').AsInteger;
    end;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao recuperar venda pendente: ' + E.Message;
      Result := nil;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.SalvarVendaPendente(AVenda: TVenda): Boolean;
begin
  { Usa o mesmo método de SalvarVenda }
  Result := SalvarVenda(AVenda);
end;

function TPersistenciaVenda.DeletarVendaPendente(AVendaID: Integer): Boolean;
begin
  { Usa o mesmo método de DeletarVenda }
  Result := DeletarVenda(AVendaID);
end;

{ ============================================================================
  ESTATÍSTICAS
  ============================================================================ }

function TPersistenciaVenda.ObterTotalVendas: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT SUM(Total) as Total FROM Vendas WHERE Status = 1';
    Query.Open;
    
    if not Query.Eof then
      Result := Query.FieldByName('Total').AsFloat;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter total de vendas: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterQuantidadeVendas: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT COUNT(*) as Total FROM Vendas WHERE Status = 1';
    Query.Open;
    
    if not Query.Eof then
      Result := Query.FieldByName('Total').AsInteger;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter quantidade de vendas: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterValorMedioVenda: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT AVG(Total) as Media FROM Vendas WHERE Status = 1';
    Query.Open;
    
    if not Query.Eof then
      Result := Query.FieldByName('Media').AsFloat;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter valor médio de venda: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterMaiorVenda: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT MAX(Total) as Maior FROM Vendas WHERE Status = 1';
    Query.Open;
    
    if not Query.Eof then
      Result := Query.FieldByName('Maior').AsFloat;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter maior venda: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterMenorVenda: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT MIN(Total) as Menor FROM Vendas WHERE Status = 1';
    Query.Open;
    
    if not Query.Eof then
      Result := Query.FieldByName('Menor').AsFloat;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter menor venda: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterTotalDescontos: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT SUM(Desconto) as Total FROM Vendas WHERE Status = 1';
    Query.Open;
    
    if not Query.Eof then
      Result := Query.FieldByName('Total').AsFloat;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter total de descontos: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterTotalAcrescimos: Double;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT SUM(Acrescimo) as Total FROM Vendas WHERE Status = 1';
    Query.Open;
    
    if not Query.Eof then
      Result := Query.FieldByName('Total').AsFloat;
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter total de acréscimos: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

function TPersistenciaVenda.ObterQuantidadeProdutosVendidos: Integer;
var
  Query: TFDQuery;
begin
  Result := 0;
  Query := TFDQuery.Create(nil);
  
  try
    Query.Connection := FConexao;
    Query.SQL.Text := 'SELECT SUM(Quantidade) as Total FROM ItensVenda WHERE VendaID IN (SELECT ID FROM Vendas WHERE Status = 1)';
    Query.Open;
    
    if not Query.Eof then
      Result := Trunc(Query.FieldByName('Total').AsFloat);
    
    FUltimoErro := '';
  except
    on E: Exception do
    begin
      FUltimoErro := 'Erro ao obter quantidade de produtos vendidos: ' + E.Message;
      Result := 0;
    end;
  finally
    Query.Free;
  end;
end;

end.
