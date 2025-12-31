unit uItemVenda;

interface

uses
  System.SysUtils, System.Classes,
  uProduto;

type
  TItemVenda = class
  private
    FProduto: TProduto;
    FQuantidade: Double;
    FValorUnitario: Double;
    FValorTotal: Double;
    FDesconto: Double;
    FDescontoPercentual: Boolean;
    FIndice: Integer;
    
    procedure CalcularTotal;
    procedure ValidarQuantidade;
  public
    constructor Create(AProduto: TProduto; AQuantidade: Double = 1);
    destructor Destroy; override;
    
    // Setters com validação
    procedure SetQuantidade(AQuantidade: Double);
    procedure SetValorUnitario(AValor: Double);
    procedure AplicarDesconto(AValor: Double; APercentual: Boolean = False);
    procedure RemoverDesconto;
    
    // Getters
    function GetValorComDesconto: Double;
    function GetValorTotalComDesconto: Double;
    function GetPercentualDesconto: Double;
    function GetDescricaoCompleta: string;
    
    // Operações
    procedure Aumentar(AQuantidade: Double = 1);
    procedure Diminuir(AQuantidade: Double = 1);
    procedure DuplicarQuantidade;
    procedure DividirQuantidade;
    
    // Propriedades
    property Produto: TProduto read FProduto;
    property Quantidade: Double read FQuantidade write SetQuantidade;
    property ValorUnitario: Double read FValorUnitario write SetValorUnitario;
    property ValorTotal: Double read FValorTotal;
    property Desconto: Double read FDesconto write FDesconto;
    property DescontoPercentual: Boolean read FDescontoPercentual;
    property Indice: Integer read FIndice write FIndice;
  end;

implementation

constructor TItemVenda.Create(AProduto: TProduto; AQuantidade: Double = 1);
begin
  inherited Create;
  FProduto := AProduto;
  FQuantidade := AQuantidade;
  FValorUnitario := AProduto.Preco;
  FDesconto := 0;
  FDescontoPercentual := False;
  FIndice := -1;
  ValidarQuantidade;
  CalcularTotal;
end;

destructor TItemVenda.Destroy;
begin
  // Não libera o produto pois ele é gerenciado pelo repositório
  inherited;
end;

procedure TItemVenda.ValidarQuantidade;
begin
  if FQuantidade <= 0 then
    FQuantidade := 1;
  
  if FQuantidade > 9999 then
    FQuantidade := 9999;
end;

procedure TItemVenda.CalcularTotal;
begin
  FValorTotal := FValorUnitario * FQuantidade;
  
  // Aplica desconto se houver
  if FDesconto > 0 then
  begin
    if FDescontoPercentual then
      FValorTotal := FValorTotal - (FValorTotal * (FDesconto / 100))
    else
      FValorTotal := FValorTotal - FDesconto;
  end;
  
  // Garante que não fica negativo
  if FValorTotal < 0 then
    FValorTotal := 0;
end;

procedure TItemVenda.SetQuantidade(AQuantidade: Double);
begin
  FQuantidade := AQuantidade;
  ValidarQuantidade;
  CalcularTotal;
end;

procedure TItemVenda.SetValorUnitario(AValor: Double);
begin
  if AValor > 0 then
  begin
    FValorUnitario := AValor;
    CalcularTotal;
  end;
end;

procedure TItemVenda.AplicarDesconto(AValor: Double; APercentual: Boolean = False);
begin
  if APercentual then
  begin
    // Desconto percentual
    if AValor < 0 then AValor := 0;
    if AValor > 100 then AValor := 100;
    FDesconto := AValor;
    FDescontoPercentual := True;
  end
  else
  begin
    // Desconto em valor fixo
    if AValor < 0 then AValor := 0;
    if AValor > (FValorUnitario * FQuantidade) then
      AValor := FValorUnitario * FQuantidade;
    FDesconto := AValor;
    FDescontoPercentual := False;
  end;
  
  CalcularTotal;
end;

procedure TItemVenda.RemoverDesconto;
begin
  FDesconto := 0;
  FDescontoPercentual := False;
  CalcularTotal;
end;

function TItemVenda.GetValorComDesconto: Double;
begin
  if FDesconto > 0 then
  begin
    if FDescontoPercentual then
      Result := FValorUnitario - (FValorUnitario * (FDesconto / 100))
    else
      Result := FValorUnitario - (FDesconto / FQuantidade)
  end
  else
    Result := FValorUnitario;
end;

function TItemVenda.GetValorTotalComDesconto: Double;
begin
  Result := FValorTotal;
end;

function TItemVenda.GetPercentualDesconto: Double;
begin
  if FDescontoPercentual then
    Result := FDesconto
  else
    Result := (FDesconto / (FValorUnitario * FQuantidade)) * 100;
end;

function TItemVenda.GetDescricaoCompleta: string;
var
  DescricaoDesconto: string;
begin
  Result := Format('%s | Qtd: %.0f | R$ %.2f', 
    [FProduto.Nome, FQuantidade, FValorTotal]);
  
  if FDesconto > 0 then
  begin
    if FDescontoPercentual then
      DescricaoDesconto := Format(' (-%.0f%%)', [FDesconto])
    else
      DescricaoDesconto := Format(' (-R$ %.2f)', [FDesconto]);
    
    Result := Result + DescricaoDesconto;
  end;
end;

procedure TItemVenda.Aumentar(AQuantidade: Double = 1);
begin
  SetQuantidade(FQuantidade + AQuantidade);
end;

procedure TItemVenda.Diminuir(AQuantidade: Double = 1);
begin
  if FQuantidade > AQuantidade then
    SetQuantidade(FQuantidade - AQuantidade)
  else
    SetQuantidade(1);
end;

procedure TItemVenda.DuplicarQuantidade;
begin
  SetQuantidade(FQuantidade * 2);
end;

procedure TItemVenda.DividirQuantidade;
begin
  if FQuantidade > 1 then
    SetQuantidade(FQuantidade / 2)
  else
    SetQuantidade(1);
end;

end.
