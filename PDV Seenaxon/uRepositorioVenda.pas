unit uRepositorioVenda;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Generics.Defaults,
  uVenda, uItemVenda, uProduto;

type
  {$REGION 'Tipos'}
  
  // Status da venda
  TStatusVenda = (svPendente, svFinalizada, svCancelada);
  
  // Tipo de filtro
  TTipoFiltroVenda = (tfTodas, tfPendentes, tfFinalizadas, tfCanceladas);
  
  {$ENDREGION}

  {$REGION 'Classe TRepositorioVenda'}
  
  /// <summary>
  /// Repositório de Vendas com suporte a gerenciamento completo,
  /// histórico, filtros e estatísticas
  /// </summary>
  TRepositorioVenda = class
  private
    FVendas: TObjectList<TVenda>;
    FVendaAtual: TVenda;
    FUltimoErro: string;
    FProximoID: Integer;
    
    /// <summary>Gerar ID único para nova venda</summary>
    function GerarProximoID: Integer;
    
    /// <summary>Validar dados da venda</summary>
    function ValidarVenda(AVenda: TVenda): Boolean;
    
  public
    /// <summary>Construtor</summary>
    constructor Create;
    
    /// <summary>Destrutor</summary>
    destructor Destroy; override;
    
    {$REGION 'Operações de Venda'}
    
    /// <summary>Iniciar nova venda</summary>
    /// <param name="AOperadorID">ID do operador</param>
    /// <returns>Venda criada</returns>
    function IniciarVenda(AOperadorID: Integer): TVenda;
    
    /// <summary>Adicionar item à venda atual</summary>
    /// <param name="AProduto">Produto a adicionar</param>
    /// <param name="AQuantidade">Quantidade</param>
    /// <returns>True se adicionado com sucesso</returns>
    function AdicionarItem(AProduto: TProduto; AQuantidade: Double): Boolean;
    
    /// <summary>Remover item da venda atual</summary>
    /// <param name="AIndex">Índice do item</param>
    /// <returns>True se removido com sucesso</returns>
    function RemoverItem(AIndex: Integer): Boolean;
    
    /// <summary>Atualizar quantidade de item</summary>
    /// <param name="AIndex">Índice do item</param>
    /// <param name="AQuantidade">Nova quantidade</param>
    /// <returns>True se atualizado com sucesso</returns>
    function AtualizarQuantidadeItem(AIndex: Integer; AQuantidade: Double): Boolean;
    
    /// <summary>Aplicar desconto à venda atual</summary>
    /// <param name="AValor">Valor do desconto</param>
    /// <param name="APercentual">Se é percentual ou valor fixo</param>
    /// <returns>True se aplicado com sucesso</returns>
    function AplicarDesconto(AValor: Double; APercentual: Boolean = False): Boolean;
    
    /// <summary>Aplicar acréscimo à venda atual</summary>
    /// <param name="AValor">Valor do acréscimo</param>
    /// <param name="APercentual">Se é percentual ou valor fixo</param>
    /// <returns>True se aplicado com sucesso</returns>
    function AplicarAcrescimo(AValor: Double; APercentual: Boolean = False): Boolean;
    
    /// <summary>Finalizar venda atual</summary>
    /// <param name="AFormaPagemento">Forma de pagamento (1=Dinheiro, 2=Cartão, 3=PIX)</param>
    /// <param name="AValorPago">Valor pago pelo cliente</param>
    /// <returns>True se finalizado com sucesso</returns>
    function FinalizarVenda(AFormaPagamento: Integer; AValorPago: Double): Boolean;
    
    /// <summary>Cancelar venda atual</summary>
    /// <returns>True se cancelado com sucesso</returns>
    function CancelarVenda: Boolean;
    
    /// <summary>Limpar venda atual</summary>
    procedure LimparVendaAtual;
    
    {$ENDREGION}

    {$REGION 'CRUD - Operações Básicas'}
    
    /// <summary>Adicionar venda ao repositório</summary>
    /// <param name="AVenda">Venda a ser adicionada</param>
    /// <returns>True se adicionado com sucesso</returns>
    function Adicionar(AVenda: TVenda): Boolean;
    
    /// <summary>Atualizar venda existente</summary>
    /// <param name="AVenda">Venda com dados atualizados</param>
    /// <returns>True se atualizado com sucesso</returns>
    function Atualizar(AVenda: TVenda): Boolean;
    
    /// <summary>Deletar venda por ID</summary>
    /// <param name="AID">ID da venda</param>
    /// <returns>True se deletado com sucesso</returns>
    function Deletar(AID: Integer): Boolean;
    
    /// <summary>Obter venda por ID</summary>
    /// <param name="AID">ID da venda</param>
    /// <returns>Venda encontrada ou nil</returns>
    function ObterPorID(AID: Integer): TVenda;
    
    /// <summary>Obter todas as vendas</summary>
    /// <returns>Lista de todas as vendas</returns>
    function ObterTodas: TObjectList<TVenda>;
    
    {$ENDREGION}

    {$REGION 'Filtros e Consultas'}
    
    /// <summary>Filtrar vendas por status</summary>
    /// <param name="AStatus">Status da venda</param>
    /// <returns>Lista de vendas encontradas</returns>
    function FiltrarPorStatus(AStatus: TStatusVenda): TObjectList<TVenda>;
    
    /// <summary>Filtrar vendas por operador</summary>
    /// <param name="AOperadorID">ID do operador</param>
    /// <returns>Lista de vendas encontradas</returns>
    function FiltrarPorOperador(AOperadorID: Integer): TObjectList<TVenda>;
    
    /// <summary>Filtrar vendas por forma de pagamento</summary>
    /// <param name="AFormaPagamento">Forma de pagamento</param>
    /// <returns>Lista de vendas encontradas</returns>
    function FiltrarPorFormaPagamento(AFormaPagamento: Integer): TObjectList<TVenda>;
    
    /// <summary>Filtrar vendas por data</summary>
    /// <param name="ADataInicio">Data inicial</param>
    /// <param name="ADataFim">Data final</param>
    /// <returns>Lista de vendas encontradas</returns>
    function FiltrarPorData(ADataInicio, ADataFim: TDateTime): TObjectList<TVenda>;
    
    /// <summary>Filtrar vendas por faixa de valor</summary>
    /// <param name="AValorMinimo">Valor mínimo</param>
    /// <param name="AValorMaximo">Valor máximo</param>
    /// <returns>Lista de vendas encontradas</returns>
    function FiltrarPorFaixaValor(AValorMinimo, AValorMaximo: Double): TObjectList<TVenda>;
    
    {$ENDREGION}

    {$REGION 'Estatísticas'}
    
    /// <summary>Obter quantidade total de vendas</summary>
    /// <returns>Número de vendas</returns>
    function ObterQuantidadeTotal: Integer;
    
    /// <summary>Obter quantidade de vendas finalizadas</summary>
    /// <returns>Número de vendas finalizadas</returns>
    function ObterQuantidadeFinalizadas: Integer;
    
    /// <summary>Obter quantidade de vendas pendentes</summary>
    /// <returns>Número de vendas pendentes</returns>
    function ObterQuantidadePendentes: Integer;
    
    /// <summary>Obter quantidade de vendas canceladas</summary>
    /// <returns>Número de vendas canceladas</returns>
    function ObterQuantidadeCanceladas: Integer;
    
    /// <summary>Obter total de vendas (valor)</summary>
    /// <returns>Valor total de vendas finalizadas</returns>
    function ObterTotalVendas: Double;
    
    /// <summary>Obter total de descontos</summary>
    /// <returns>Valor total de descontos</returns>
    function ObterTotalDescontos: Double;
    
    /// <summary>Obter total de acréscimos</summary>
    /// <returns>Valor total de acréscimos</returns>
    function ObterTotalAcrescimos: Double;
    
    /// <summary>Obter valor médio de venda</summary>
    /// <returns>Valor médio</returns>
    function ObterValorMedioVenda: Double;
    
    /// <summary>Obter maior venda</summary>
    /// <returns>Valor da maior venda</returns>
    function ObterMaiorVenda: Double;
    
    /// <summary>Obter menor venda</summary>
    /// <returns>Valor da menor venda</returns>
    function ObterMenorVenda: Double;
    
    /// <summary>Obter total de itens vendidos</summary>
    /// <returns>Quantidade total de itens</returns>
    function ObterTotalItensVendidos: Integer;
    
    /// <summary>Obter venda mais recente</summary>
    /// <returns>Venda mais recente</returns>
    function ObterVendaMaisRecente: TVenda;
    
    {$ENDREGION}

    {$REGION 'Propriedades'}
    
    /// <summary>Venda atual em edição</summary>
    property VendaAtual: TVenda read FVendaAtual;
    
    /// <summary>Último erro ocorrido</summary>
    property UltimoErro: string read FUltimoErro;
    
    /// <summary>Quantidade total de vendas</summary>
    property Quantidade: Integer read ObterQuantidadeTotal;
    
    {$ENDREGION}
  end;

  {$ENDREGION}

implementation

{$REGION 'Implementação TRepositorioVenda'}

constructor TRepositorioVenda.Create;
begin
  inherited Create;
  FVendas := TObjectList<TVenda>.Create;
  FVendaAtual := nil;
  FUltimoErro := '';
  FProximoID := 1;
end;

destructor TRepositorioVenda.Destroy;
begin
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;
  if Assigned(FVendas) then
    FVendas.Free;
  inherited;
end;

{$REGION 'Métodos Privados'}

function TRepositorioVenda.GerarProximoID: Integer;
begin
  Result := FProximoID;
  Inc(FProximoID);
end;

function TRepositorioVenda.ValidarVenda(AVenda: TVenda): Boolean;
begin
  Result := True;
  FUltimoErro := '';
  
  if not Assigned(AVenda) then
  begin
    FUltimoErro := 'Venda não pode ser nula';
    Result := False;
    Exit;
  end;
  
  if AVenda.OperadorID <= 0 then
  begin
    FUltimoErro := 'ID do operador inválido';
    Result := False;
    Exit;
  end;
end;

{$ENDREGION}

{$REGION 'Operações de Venda'}

function TRepositorioVenda.IniciarVenda(AOperadorID: Integer): TVenda;
begin
  // Limpar venda anterior
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;
  
  // Criar nova venda
  FVendaAtual := TVenda.Create;
  FVendaAtual.ID := GerarProximoID;
  FVendaAtual.OperadorID := AOperadorID;
  FVendaAtual.DataVenda := Now;
  
  Result := FVendaAtual;
end;

function TRepositorioVenda.AdicionarItem(AProduto: TProduto; AQuantidade: Double): Boolean;
var
  Item: TItemVenda;
  I: Integer;
begin
  Result := False;
  FUltimoErro := '';
  
  if not Assigned(FVendaAtual) then
  begin
    FUltimoErro := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  if not Assigned(AProduto) then
  begin
    FUltimoErro := 'Produto não pode ser nulo';
    Exit;
  end;
  
  if AQuantidade <= 0 then
  begin
    FUltimoErro := 'Quantidade deve ser maior que zero';
    Exit;
  end;
  
  try
    // Verificar se produto já existe na venda
    for I := 0 to FVendaAtual.Itens.Count - 1 do
    begin
      if FVendaAtual.Itens[I].Produto.ID = AProduto.ID then
      begin
        // Aumentar quantidade
        FVendaAtual.Itens[I].Aumentar(AQuantidade);
        Result := True;
        Exit;
      end;
    end;
    
    // Adicionar novo item
    Item := TItemVenda.Create(AProduto, AQuantidade);
    FVendaAtual.Itens.Add(Item);
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao adicionar item: ' + E.Message;
  end;
end;

function TRepositorioVenda.RemoverItem(AIndex: Integer): Boolean;
begin
  Result := False;
  FUltimoErro := '';
  
  if not Assigned(FVendaAtual) then
  begin
    FUltimoErro := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  if (AIndex < 0) or (AIndex >= FVendaAtual.Itens.Count) then
  begin
    FUltimoErro := 'Índice de item inválido';
    Exit;
  end;
  
  try
    FVendaAtual.Itens.Delete(AIndex);
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao remover item: ' + E.Message;
  end;
end;

function TRepositorioVenda.AtualizarQuantidadeItem(AIndex: Integer; AQuantidade: Double): Boolean;
begin
  Result := False;
  FUltimoErro := '';
  
  if not Assigned(FVendaAtual) then
  begin
    FUltimoErro := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  if (AIndex < 0) or (AIndex >= FVendaAtual.Itens.Count) then
  begin
    FUltimoErro := 'Índice de item inválido';
    Exit;
  end;
  
  if AQuantidade <= 0 then
  begin
    FUltimoErro := 'Quantidade deve ser maior que zero';
    Exit;
  end;
  
  try
    FVendaAtual.Itens[AIndex].Quantidade := AQuantidade;
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao atualizar quantidade: ' + E.Message;
  end;
end;

function TRepositorioVenda.AplicarDesconto(AValor: Double; APercentual: Boolean = False): Boolean;
begin
  Result := False;
  FUltimoErro := '';
  
  if not Assigned(FVendaAtual) then
  begin
    FUltimoErro := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  if AValor < 0 then
  begin
    FUltimoErro := 'Valor de desconto não pode ser negativo';
    Exit;
  end;
  
  try
    if APercentual then
      FVendaAtual.AplicarDescontoPercentual(AValor)
    else
      FVendaAtual.AplicarDescontoValor(AValor);
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao aplicar desconto: ' + E.Message;
  end;
end;

function TRepositorioVenda.AplicarAcrescimo(AValor: Double; APercentual: Boolean = False): Boolean;
begin
  Result := False;
  FUltimoErro := '';
  
  if not Assigned(FVendaAtual) then
  begin
    FUltimoErro := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  if AValor < 0 then
  begin
    FUltimoErro := 'Valor de acréscimo não pode ser negativo';
    Exit;
  end;
  
  try
    if APercentual then
      FVendaAtual.AplicarAcrescimoPercentual(AValor)
    else
      FVendaAtual.AplicarAcrescimoValor(AValor);
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao aplicar acréscimo: ' + E.Message;
  end;
end;

function TRepositorioVenda.FinalizarVenda(AFormaPagamento: Integer; AValorPago: Double): Boolean;
begin
  Result := False;
  FUltimoErro := '';
  
  if not Assigned(FVendaAtual) then
  begin
    FUltimoErro := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  if FVendaAtual.Itens.Count = 0 then
  begin
    FUltimoErro := 'Venda sem itens não pode ser finalizada';
    Exit;
  end;
  
  if (AFormaPagamento < 1) or (AFormaPagamento > 3) then
  begin
    FUltimoErro := 'Forma de pagamento inválida (1=Dinheiro, 2=Cartão, 3=PIX)';
    Exit;
  end;
  
  if AValorPago < FVendaAtual.Total then
  begin
    FUltimoErro := 'Valor pago insuficiente';
    Exit;
  end;
  
  try
    FVendaAtual.FormaPagamento := AFormaPagamento;
    FVendaAtual.ValorPago := AValorPago;
    FVendaAtual.Status := Integer(svFinalizada);
    
    // Adicionar ao repositório
    FVendas.Add(FVendaAtual);
    FVendaAtual := nil;
    
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao finalizar venda: ' + E.Message;
  end;
end;

function TRepositorioVenda.CancelarVenda: Boolean;
begin
  Result := False;
  FUltimoErro := '';
  
  if not Assigned(FVendaAtual) then
  begin
    FUltimoErro := 'Nenhuma venda em andamento';
    Exit;
  end;
  
  try
    FVendaAtual.Status := Integer(svCancelada);
    FVendas.Add(FVendaAtual);
    FVendaAtual := nil;
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao cancelar venda: ' + E.Message;
  end;
end;

procedure TRepositorioVenda.LimparVendaAtual;
begin
  if Assigned(FVendaAtual) then
  begin
    FVendaAtual.Free;
    FVendaAtual := nil;
  end;
end;

{$ENDREGION}

{$REGION 'CRUD - Operações Básicas'}

function TRepositorioVenda.Adicionar(AVenda: TVenda): Boolean;
begin
  Result := False;
  
  if not ValidarVenda(AVenda) then
    Exit;
  
  try
    AVenda.ID := GerarProximoID;
    FVendas.Add(AVenda);
    Result := True;
  except
    on E: Exception do
      FUltimoErro := 'Erro ao adicionar venda: ' + E.Message;
  end;
end;

function TRepositorioVenda.Atualizar(AVenda: TVenda): Boolean;
var
  Venda: TVenda;
  I: Integer;
begin
  Result := False;
  
  if not ValidarVenda(AVenda) then
    Exit;
  
  try
    for I := 0 to FVendas.Count - 1 do
    begin
      Venda := FVendas[I];
      if Venda.ID = AVenda.ID then
      begin
        Venda.Status := AVenda.Status;
        Venda.Desconto := AVenda.Desconto;
        Venda.Acrescimo := AVenda.Acrescimo;
        Venda.FormaPagamento := AVenda.FormaPagamento;
        Result := True;
        Exit;
      end;
    end;
    
    FUltimoErro := 'Venda não encontrada';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao atualizar venda: ' + E.Message;
  end;
end;

function TRepositorioVenda.Deletar(AID: Integer): Boolean;
var
  I: Integer;
begin
  Result := False;
  
  try
    for I := 0 to FVendas.Count - 1 do
    begin
      if FVendas[I].ID = AID then
      begin
        FVendas.Delete(I);
        Result := True;
        Exit;
      end;
    end;
    
    FUltimoErro := 'Venda não encontrada';
  except
    on E: Exception do
      FUltimoErro := 'Erro ao deletar venda: ' + E.Message;
  end;
end;

function TRepositorioVenda.ObterPorID(AID: Integer): TVenda;
var
  I: Integer;
begin
  Result := nil;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    if FVendas[I].ID = AID then
    begin
      Result := FVendas[I];
      Exit;
    end;
  end;
end;

function TRepositorioVenda.ObterTodas: TObjectList<TVenda>;
begin
  Result := TObjectList<TVenda>.Create(False);
  Result.AddRange(FVendas);
end;

{$ENDREGION}

{$REGION 'Filtros e Consultas'}

function TRepositorioVenda.FiltrarPorStatus(AStatus: TStatusVenda): TObjectList<TVenda>;
var
  I: Integer;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create(False);
  
  for I := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[I];
    if Venda.Status = Integer(AStatus) then
      Result.Add(Venda);
  end;
end;

function TRepositorioVenda.FiltrarPorOperador(AOperadorID: Integer): TObjectList<TVenda>;
var
  I: Integer;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create(False);
  
  for I := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[I];
    if Venda.OperadorID = AOperadorID then
      Result.Add(Venda);
  end;
end;

function TRepositorioVenda.FiltrarPorFormaPagamento(AFormaPagamento: Integer): TObjectList<TVenda>;
var
  I: Integer;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create(False);
  
  for I := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[I];
    if Venda.FormaPagamento = AFormaPagamento then
      Result.Add(Venda);
  end;
end;

function TRepositorioVenda.FiltrarPorData(ADataInicio, ADataFim: TDateTime): TObjectList<TVenda>;
var
  I: Integer;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create(False);
  
  for I := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[I];
    if (Venda.DataVenda >= ADataInicio) and (Venda.DataVenda <= ADataFim) then
      Result.Add(Venda);
  end;
end;

function TRepositorioVenda.FiltrarPorFaixaValor(AValorMinimo, AValorMaximo: Double): TObjectList<TVenda>;
var
  I: Integer;
  Venda: TVenda;
begin
  Result := TObjectList<TVenda>.Create(False);
  
  for I := 0 to FVendas.Count - 1 do
  begin
    Venda := FVendas[I];
    if (Venda.Total >= AValorMinimo) and (Venda.Total <= AValorMaximo) then
      Result.Add(Venda);
  end;
end;

{$ENDREGION}

{$REGION 'Estatísticas'}

function TRepositorioVenda.ObterQuantidadeTotal: Integer;
begin
  Result := FVendas.Count;
end;

function TRepositorioVenda.ObterQuantidadeFinalizadas: Integer;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    if FVendas[I].Status = Integer(svFinalizada) then
      Inc(Result);
  end;
end;

function TRepositorioVenda.ObterQuantidadePendentes: Integer;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    if FVendas[I].Status = Integer(svPendente) then
      Inc(Result);
  end;
end;

function TRepositorioVenda.ObterQuantidadeCanceladas: Integer;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    if FVendas[I].Status = Integer(svCancelada) then
      Inc(Result);
  end;
end;

function TRepositorioVenda.ObterTotalVendas: Double;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    if FVendas[I].Status = Integer(svFinalizada) then
      Result := Result + FVendas[I].Total;
  end;
end;

function TRepositorioVenda.ObterTotalDescontos: Double;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
    Result := Result + FVendas[I].Desconto;
end;

function TRepositorioVenda.ObterTotalAcrescimos: Double;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
    Result := Result + FVendas[I].Acrescimo;
end;

function TRepositorioVenda.ObterValorMedioVenda: Double;
var
  Finalizadas: Integer;
begin
  Result := 0;
  Finalizadas := ObterQuantidadeFinalizadas;
  
  if Finalizadas > 0 then
    Result := ObterTotalVendas / Finalizadas;
end;

function TRepositorioVenda.ObterMaiorVenda: Double;
var
  I: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    if FVendas[I].Total > Result then
      Result := FVendas[I].Total;
  end;
end;

function TRepositorioVenda.ObterMenorVenda: Double;
var
  I: Integer;
begin
  Result := MaxDouble;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    if (FVendas[I].Total > 0) and (FVendas[I].Total < Result) then
      Result := FVendas[I].Total;
  end;
  
  if Result = MaxDouble then
    Result := 0;
end;

function TRepositorioVenda.ObterTotalItensVendidos: Integer;
var
  I, J: Integer;
begin
  Result := 0;
  
  for I := 0 to FVendas.Count - 1 do
  begin
    for J := 0 to FVendas[I].Itens.Count - 1 do
      Result := Result + Trunc(FVendas[I].Itens[J].Quantidade);
  end;
end;

function TRepositorioVenda.ObterVendaMaisRecente: TVenda;
var
  I: Integer;
begin
  Result := nil;
  
  if FVendas.Count = 0 then
    Exit;
  
  Result := FVendas[0];
  
  for I := 1 to FVendas.Count - 1 do
  begin
    if FVendas[I].DataVenda > Result.DataVenda then
      Result := FVendas[I];
  end;
end;

{$ENDREGION}

{$ENDREGION}

end.
