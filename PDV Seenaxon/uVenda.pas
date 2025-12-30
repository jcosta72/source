unit uVenda;

interface

uses
  System.SysUtils, System.Generics.Collections,
  uItemVenda, uProduto;

type
  TStatusVenda = (svAberta, svFinalizada, svCancelada);
  TFormaPagamento = (fpDinheiro, fpCartao, fpPIX);

  TVenda = class
  private
    FID: Integer;
    FItens: TObjectList<TItemVenda>;
    FSubtotal: Double;
    FDesconto: Double;
    FDescontoPercentual: Boolean;
    FAcrescimo: Double;
    FAcrescimoPercentual: Boolean;
    FTotal: Double;
    FDataVenda: TDateTime;
    FDataFinalizacao: TDateTime;
    FOperadorID: Integer;
    FStatus: TStatusVenda;
    FFormaPagamento: TFormaPagamento;
    FValorRecebido: Double;
    FTroco: Double;
    FNumeroNFe: string;
    FChaveAcesso: string;
    
    procedure CalcularTotais;
    procedure ValidarVenda;
  public
    constructor Create;
    destructor Destroy; override;
    
    // Operações com itens
    procedure AdicionarItem(AProduto: TProduto; AQuantidade: Double = 1);
    procedure RemoverItem(AIndex: Integer);
    procedure AtualizarQuantidade(AIndex: Integer; AQuantidade: Double);
    procedure AtualizarItemDesconto(AIndex: Integer; AValor: Double; APercentual: Boolean = False);
    
    // Operações com desconto/acréscimo
    procedure AplicarDesconto(AValor: Double; APercentual: Boolean = False);
    procedure AplicarDescontoPercentual(APercentual: Double);
    procedure AplicarAcrescimo(AValor: Double; APercentual: Boolean = False);
    procedure AplicarAcrescimoPercentual(APercentual: Double);
    procedure RemoverDesconto;
    procedure RemoverAcrescimo;
    
    // Operações de finalização
    procedure Finalizar(AFormaPagamento: TFormaPagamento; AValorRecebido: Double = 0);
    procedure Cancelar;
    procedure LimparVenda;
    
    // Consultas
    function GetItem(AIndex: Integer): TItemVenda;
    function GetQuantidadeItens: Integer;
    function GetQuantidadeProdutos: Integer;
    function GetValorMedioItem: Double;
    function GetMaiorItem: TItemVenda;
    function GetMenorItem: TItemVenda;
    function EstaVazia: Boolean;
    function PodeSerFinalizada: Boolean;
    
    // Propriedades
    property ID: Integer read FID write FID;
    property Itens: TObjectList<TItemVenda> read FItens;
    property Subtotal: Double read FSubtotal;
    property Desconto: Double read FDesconto;
    property DescontoPercentual: Boolean read FDescontoPercentual;
    property Acrescimo: Double read FAcrescimo;
    property AcrescimoPercentual: Boolean read FAcrescimoPercentual;
    property Total: Double read FTotal;
    property DataVenda: TDateTime read FDataVenda write FDataVenda;
    property DataFinalizacao: TDateTime read FDataFinalizacao;
    property OperadorID: Integer read FOperadorID write FOperadorID;
    property Status: TStatusVenda read FStatus write FStatus;
    property FormaPagamento: TFormaPagamento read FFormaPagamento write FFormaPagamento;
    property ValorRecebido: Double read FValorRecebido write FValorRecebido;
    property Troco: Double read FTroco;
    property QuantidadeItens: Integer read GetQuantidadeItens;
    property NumeroNFe: string read FNumeroNFe write FNumeroNFe;
    property ChaveAcesso: string read FChaveAcesso write FChaveAcesso;
  end;

implementation

constructor TVenda.Create;
begin
  inherited Create;
  FItens := TObjectList<TItemVenda>.Create;
  FID := 0;
  FSubtotal := 0;
  FDesconto := 0;
  FDescontoPercentual := False;
  FAcrescimo := 0;
  FAcrescimoPercentual := False;
  FTotal := 0;
  FDataVenda := Now;
  FDataFinalizacao := 0;
  FOperadorID := 0;
  FStatus := svAberta;
  FFormaPagamento := fpDinheiro;
  FValorRecebido := 0;
  FTroco := 0;
  FNumeroNFe := '';
  FChaveAcesso := '';
end;

destructor TVenda.Destroy;
begin
  if Assigned(FItens) then
    FItens.Free;
  inherited;
end;

procedure TVenda.ValidarVenda;
begin
  if FItens.Count = 0 then
    raise Exception.Create('Venda sem itens');
  
  if FTotal <= 0 then
    raise Exception.Create('Total inválido');
end;

procedure TVenda.CalcularTotais;
var
  i: Integer;
begin
  FSubtotal := 0;
  
  for i := 0 to FItens.Count - 1 do
    FSubtotal := FSubtotal + FItens[i].ValorTotal;
  
  FTotal := FSubtotal - FDesconto + FAcrescimo;
  
  if FTotal < 0 then
    FTotal := 0;
end;

procedure TVenda.AdicionarItem(AProduto: TProduto; AQuantidade: Double = 1);
var
  Item: TItemVenda;
  i: Integer;
begin
  if FStatus <> svAberta then
    raise Exception.Create('Venda não está aberta');
  
  if not Assigned(AProduto) then
    raise Exception.Create('Produto inválido');
  
  // Verifica se o produto já existe na venda
  for i := 0 to FItens.Count - 1 do
  begin
    if FItens[i].Produto.ID = AProduto.ID then
    begin
      FItens[i].SetQuantidade(FItens[i].Quantidade + AQuantidade);
      CalcularTotais;
      Exit;
    end;
  end;
  
  // Se não existe, adiciona novo item
  Item := TItemVenda.Create(AProduto, AQuantidade);
  Item.Indice := FItens.Count;
  FItens.Add(Item);
  CalcularTotais;
end;

procedure TVenda.RemoverItem(AIndex: Integer);
begin
  if FStatus <> svAberta then
    raise Exception.Create('Venda não está aberta');
  
  if (AIndex >= 0) and (AIndex < FItens.Count) then
  begin
    FItens.Delete(AIndex);
    CalcularTotais;
  end;
end;

procedure TVenda.AtualizarQuantidade(AIndex: Integer; AQuantidade: Double);
begin
  if FStatus <> svAberta then
    raise Exception.Create('Venda não está aberta');
  
  if (AIndex >= 0) and (AIndex < FItens.Count) then
  begin
    if AQuantidade <= 0 then
      RemoverItem(AIndex)
    else
    begin
      FItens[AIndex].SetQuantidade(AQuantidade);
      CalcularTotais;
    end;
  end;
end;

procedure TVenda.AtualizarItemDesconto(AIndex: Integer; AValor: Double; APercentual: Boolean = False);
begin
  if FStatus <> svAberta then
    raise Exception.Create('Venda não está aberta');
  
  if (AIndex >= 0) and (AIndex < FItens.Count) then
  begin
    FItens[AIndex].AplicarDesconto(AValor, APercentual);
    CalcularTotais;
  end;
end;

procedure TVenda.AplicarDesconto(AValor: Double; APercentual: Boolean = False);
begin
  if FStatus <> svAberta then
    raise Exception.Create('Venda não está aberta');
  
  if APercentual then
  begin
    if AValor < 0 then AValor := 0;
    if AValor > 100 then AValor := 100;
    FDesconto := FSubtotal * (AValor / 100);
    FDescontoPercentual := True;
  end
  else
  begin
    if AValor < 0 then AValor := 0;
    if AValor > FSubtotal then AValor := FSubtotal;
    FDesconto := AValor;
    FDescontoPercentual := False;
  end;
  
  CalcularTotais;
end;

procedure TVenda.AplicarDescontoPercentual(APercentual: Double);
begin
  if APercentual < 0 then
    APercentual := 0;
  if APercentual > 100 then
    APercentual := 100;
  
  FDesconto := FSubtotal * (APercentual / 100);
  FDescontoPercentual := True;
  CalcularTotais;
end;

procedure TVenda.AplicarAcrescimo(AValor: Double; APercentual: Boolean = False);
begin
  if FStatus <> svAberta then
    raise Exception.Create('Venda não está aberta');
  
  if APercentual then
  begin
    if AValor < 0 then AValor := 0;
    if AValor > 100 then AValor := 100;
    FAcrescimo := (FSubtotal - FDesconto) * (AValor / 100);
    FAcrescimoPercentual := True;
  end
  else
  begin
    if AValor < 0 then AValor := 0;
    FAcrescimo := AValor;
    FAcrescimoPercentual := False;
  end;
  
  CalcularTotais;
end;

procedure TVenda.AplicarAcrescimoPercentual(APercentual: Double);
begin
  if APercentual < 0 then
    APercentual := 0;
  if APercentual > 100 then
    APercentual := 100;
  
  FAcrescimo := (FSubtotal - FDesconto) * (APercentual / 100);
  FAcrescimoPercentual := True;
  CalcularTotais;
end;

procedure TVenda.RemoverDesconto;
begin
  FDesconto := 0;
  FDescontoPercentual := False;
  CalcularTotais;
end;

procedure TVenda.RemoverAcrescimo;
begin
  FAcrescimo := 0;
  FAcrescimoPercentual := False;
  CalcularTotais;
end;

procedure TVenda.Finalizar(AFormaPagamento: TFormaPagamento; AValorRecebido: Double = 0);
begin
  ValidarVenda;
  
  if FStatus <> svAberta then
    raise Exception.Create('Venda não está aberta');
  
  FFormaPagamento := AFormaPagamento;
  FValorRecebido := AValorRecebido;
  
  // Calcula troco se for dinheiro
  if AFormaPagamento = fpDinheiro then
  begin
    FTroco := AValorRecebido - FTotal;
    if FTroco < 0 then
      raise Exception.Create('Valor insuficiente');
  end
  else
  begin
    FTroco := 0;
  end;
  
  FStatus := svFinalizada;
  FDataFinalizacao := Now;
end;

procedure TVenda.Cancelar;
begin
  FStatus := svCancelada;
  FDataFinalizacao := Now;
end;

procedure TVenda.LimparVenda;
begin
  FItens.Clear;
  FSubtotal := 0;
  FDesconto := 0;
  FAcrescimo := 0;
  FTotal := 0;
  FStatus := svAberta;
  FFormaPagamento := fpDinheiro;
  FValorRecebido := 0;
  FTroco := 0;
  FNumeroNFe := '';
  FChaveAcesso := '';
end;

function TVenda.GetItem(AIndex: Integer): TItemVenda;
begin
  if (AIndex >= 0) and (AIndex < FItens.Count) then
    Result := FItens[AIndex]
  else
    Result := nil;
end;

function TVenda.GetQuantidadeItens: Integer;
begin
  Result := FItens.Count;
end;

function TVenda.GetQuantidadeProdutos: Integer;
var
  i: Integer;
  Total: Double;
begin
  Total := 0;
  for i := 0 to FItens.Count - 1 do
    Total := Total + FItens[i].Quantidade;
  Result := Trunc(Total);
end;

function TVenda.GetValorMedioItem: Double;
begin
  if FItens.Count > 0 then
    Result := FSubtotal / FItens.Count
  else
    Result := 0;
end;

function TVenda.GetMaiorItem: TItemVenda;
var
  i: Integer;
  Maior: TItemVenda;
begin
  Result := nil;
  if FItens.Count = 0 then
    Exit;
  
  Maior := FItens[0];
  for i := 1 to FItens.Count - 1 do
  begin
    if FItens[i].ValorTotal > Maior.ValorTotal then
      Maior := FItens[i];
  end;
  
  Result := Maior;
end;

function TVenda.GetMenorItem: TItemVenda;
var
  i: Integer;
  Menor: TItemVenda;
begin
  Result := nil;
  if FItens.Count = 0 then
    Exit;
  
  Menor := FItens[0];
  for i := 1 to FItens.Count - 1 do
  begin
    if FItens[i].ValorTotal < Menor.ValorTotal then
      Menor := FItens[i];
  end;
  
  Result := Menor;
end;

function TVenda.EstaVazia: Boolean;
begin
  Result := FItens.Count = 0;
end;

function TVenda.PodeSerFinalizada: Boolean;
begin
  Result := (FItens.Count > 0) and (FTotal > 0) and (FStatus = svAberta);
end;

end.
