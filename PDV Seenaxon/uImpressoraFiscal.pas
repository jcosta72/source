unit uImpressoraFiscal;

interface

uses
  System.SysUtils, System.Classes,
  uCaixa, uOperador, uVenda, uItemVenda;

type
  TImpressoraFiscal = class
  private
    FCaixa: TCaixa;
    FOperador: TOperador;
    FEmpresaNome: string;
    FEmpresaCNPJ: string;
    FEmpresaIE: string;
    FEmpresaEndereco: string;
    FEmpresaTelefone: string;
    FEmpresaSite: string;
    FNumeroCupom: Integer;
    FSerieECF: string;
    
    function GerarCabecalho: string;
    function GerarItens: string;
    function GerarTotalizadores: string;
    function GerarRodape: string;
    function FormatarLinha(ATexto: string; ALargura: Integer = 48): string;
    function CentralizarTexto(ATexto: string; ALargura: Integer = 48): string;
    function RepetirCaractere(ACaractere: Char; AQuantidade: Integer): string;
  public
    constructor Create(ACaixa: TCaixa; AOperador: TOperador);
    destructor Destroy; override;
    
    // Configuração
    procedure ConfigurarEmpresa(ANome, ACNPJ, AIE, AEndereco, ATelefone, ASite: string);
    procedure ConfigurarECF(ANumero: Integer; ASerie: string);
    
    // Impressão
    function GerarCupomFechamento: string;
    function GerarCupomVenda(AVenda: TVenda): string;
    procedure ImprimirCupomFechamento;
    procedure ImprimirCupomVenda(AVenda: TVenda);
    procedure SalvarCupomFechamento(AArquivo: string);
    procedure SalvarCupomVenda(AVenda: TVenda; AArquivo: string);
    
    // Propriedades
    property Caixa: TCaixa read FCaixa;
    property Operador: TOperador read FOperador;
    property EmpresaNome: string read FEmpresaNome write FEmpresaNome;
    property EmpresaCNPJ: string read FEmpresaCNPJ write FEmpresaCNPJ;
    property EmpresaIE: string read FEmpresaIE write FEmpresaIE;
    property NumeroCupom: Integer read FNumeroCupom write FNumeroCupom;
  end;

implementation

constructor TImpressoraFiscal.Create(ACaixa: TCaixa; AOperador: TOperador);
begin
  inherited Create;
  FCaixa := ACaixa;
  FOperador := AOperador;
  FEmpresaNome := 'PDV SEENAXON';
  FEmpresaCNPJ := '00.000.000/0000-00';
  FEmpresaIE := '00.000.000.000.000';
  FEmpresaEndereco := 'Rua Exemplo, 123 - São Paulo - SP';
  FEmpresaTelefone := '(11) 3000-0000';
  FEmpresaSite := 'www.seenaxon.com.br';
  FNumeroCupom := 1;
  FSerieECF := '001';
end;

destructor TImpressoraFiscal.Destroy;
begin
  inherited;
end;

procedure TImpressoraFiscal.ConfigurarEmpresa(ANome, ACNPJ, AIE, AEndereco, ATelefone, ASite: string);
begin
  FEmpresaNome := ANome;
  FEmpresaCNPJ := ACNPJ;
  FEmpresaIE := AIE;
  FEmpresaEndereco := AEndereco;
  FEmpresaTelefone := ATelefone;
  FEmpresaSite := ASite;
end;

procedure TImpressoraFiscal.ConfigurarECF(ANumero: Integer; ASerie: string);
begin
  FNumeroCupom := ANumero;
  FSerieECF := ASerie;
end;

function TImpressoraFiscal.RepetirCaractere(ACaractere: Char; AQuantidade: Integer): string;
begin
  Result := StringOfChar(ACaractere, AQuantidade);
end;

function TImpressoraFiscal.FormatarLinha(ATexto: string; ALargura: Integer = 48): string;
begin
  Result := ATexto;
  while Length(Result) < ALargura do
    Result := Result + ' ';
  if Length(Result) > ALargura then
    Result := Copy(Result, 1, ALargura);
end;

function TImpressoraFiscal.CentralizarTexto(ATexto: string; ALargura: Integer = 48): string;
var
  Espacos: Integer;
begin
  Espacos := (ALargura - Length(ATexto)) div 2;
  Result := StringOfChar(' ', Espacos) + ATexto;
end;

function TImpressoraFiscal.GerarCabecalho: string;
begin
  Result := '';
  Result := Result + RepetirCaractere('*', 48) + sLineBreak;
  Result := Result + CentralizarTexto(FEmpresaNome) + sLineBreak;
  Result := Result + RepetirCaractere('*', 48) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + FormatarLinha('CNPJ: ' + FEmpresaCNPJ) + sLineBreak;
  Result := Result + FormatarLinha('IE: ' + FEmpresaIE) + sLineBreak;
  Result := Result + FormatarLinha('Endereço: ' + FEmpresaEndereco) + sLineBreak;
  Result := Result + FormatarLinha('Telefone: ' + FEmpresaTelefone) + sLineBreak;
  Result := Result + sLineBreak;
end;

function TImpressoraFiscal.GerarItens: string;
var
  i: Integer;
  Item: TItemVenda;
begin
  Result := '';
  Result := Result + RepetirCaractere('-', 48) + sLineBreak;
  Result := Result + FormatarLinha('DESCRIÇÃO', 28) + FormatarLinha('QTD', 8) + FormatarLinha('VLR', 12) + sLineBreak;
  Result := Result + RepetirCaractere('-', 48) + sLineBreak;
  
  if Assigned(FCaixa) and (FCaixa.Vendas.Count > 0) then
  begin
    for i := 0 to FCaixa.Vendas.Count - 1 do
    begin
      if Assigned(FCaixa.Vendas[i]) then
      begin
        Result := Result + Format('Venda %d', [i + 1]) + sLineBreak;
        // Aqui você pode adicionar detalhes de cada venda se necessário
      end;
    end;
  end;
  
  Result := Result + RepetirCaractere('-', 48) + sLineBreak;
end;

function TImpressoraFiscal.GerarTotalizadores: string;
begin
  Result := '';
  
  if Assigned(FCaixa) then
  begin
    Result := Result + sLineBreak;
    Result := Result + Format('Saldo Inicial: R$ %10.2f', [FCaixa.SaldoInicial]) + sLineBreak;
    Result := Result + Format('Total Vendas: R$ %10.2f', [FCaixa.TotalVendas]) + sLineBreak;
    Result := Result + Format('Total Desconto: R$ %10.2f', [FCaixa.TotalDesconto]) + sLineBreak;
    Result := Result + Format('Total Acréscimo: R$ %10.2f', [FCaixa.TotalAcrescimo]) + sLineBreak;
    Result := Result + sLineBreak;
    Result := Result + Format('Saldo Final: R$ %10.2f', [FCaixa.SaldoFinal]) + sLineBreak;
    Result := Result + sLineBreak;
    Result := Result + Format('Dinheiro: R$ %10.2f', [FCaixa.TotalDinheiro]) + sLineBreak;
    Result := Result + Format('Cartão: R$ %10.2f', [FCaixa.TotalCartao]) + sLineBreak;
    Result := Result + Format('PIX: R$ %10.2f', [FCaixa.TotalPIX]) + sLineBreak;
  end;
end;

function TImpressoraFiscal.GerarRodape: string;
begin
  Result := '';
  Result := Result + sLineBreak;
  Result := Result + RepetirCaractere('-', 48) + sLineBreak;
  Result := Result + CentralizarTexto('OBRIGADO PELA COMPRA!') + sLineBreak;
  Result := Result + CentralizarTexto('Volte sempre!') + sLineBreak;
  Result := Result + RepetirCaractere('*', 48) + sLineBreak;
  Result := Result + sLineBreak;
  Result := Result + CentralizarTexto('SAC: ' + FEmpresaTelefone) + sLineBreak;
  Result := Result + CentralizarTexto(FEmpresaSite) + sLineBreak;
  Result := Result + sLineBreak;
end;

function TImpressoraFiscal.GerarCupomFechamento: string;
var
  Cupom: string;
begin
  Cupom := '';
  
  // Cabeçalho
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + CentralizarTexto('FECHAMENTO DE CAIXA') + sLineBreak;
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Informações da empresa
  Cupom := Cupom + CentralizarTexto(FEmpresaNome) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  Cupom := Cupom + FormatarLinha('CNPJ: ' + FEmpresaCNPJ) + sLineBreak;
  Cupom := Cupom + FormatarLinha('IE: ' + FEmpresaIE) + sLineBreak;
  Cupom := Cupom + FormatarLinha('Endereço: ' + FEmpresaEndereco) + sLineBreak;
  Cupom := Cupom + FormatarLinha('Telefone: ' + FEmpresaTelefone) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Informações do ECF
  Cupom := Cupom + Format('Cupom: %06d  Série: %s', [FNumeroCupom, FSerieECF]) + sLineBreak;
  Cupom := Cupom + Format('Data: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', Now)]) + sLineBreak;
  Cupom := Cupom + Format('Operador: %s (%s)', [FOperador.Nome, FOperador.Matricula]) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Resumo do caixa
  if Assigned(FCaixa) then
  begin
    Cupom := Cupom + Format('Abertura: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', FCaixa.DataAbertura)]) + sLineBreak;
    Cupom := Cupom + Format('Fechamento: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', FCaixa.DataFechamento)]) + sLineBreak;
    Cupom := Cupom + sLineBreak;
    
    Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
    Cupom := Cupom + 'RESUMO FINANCEIRO' + sLineBreak;
    Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
    Cupom := Cupom + sLineBreak;
    
    Cupom := Cupom + Format('Saldo Inicial: R$ %10.2f', [FCaixa.SaldoInicial]) + sLineBreak;
    Cupom := Cupom + Format('Total Vendas: R$ %10.2f', [FCaixa.TotalVendas]) + sLineBreak;
    Cupom := Cupom + Format('Total Desconto: R$ %10.2f', [FCaixa.TotalDesconto]) + sLineBreak;
    Cupom := Cupom + Format('Total Acréscimo: R$ %10.2f', [FCaixa.TotalAcrescimo]) + sLineBreak;
    Cupom := Cupom + sLineBreak;
    
    Cupom := Cupom + Format('Saldo Final: R$ %10.2f', [FCaixa.SaldoFinal]) + sLineBreak;
    Cupom := Cupom + sLineBreak;
    
    Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
    Cupom := Cupom + 'FORMAS DE PAGAMENTO' + sLineBreak;
    Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
    Cupom := Cupom + sLineBreak;
    
    Cupom := Cupom + Format('Dinheiro: R$ %10.2f', [FCaixa.TotalDinheiro]) + sLineBreak;
    Cupom := Cupom + Format('Cartão: R$ %10.2f', [FCaixa.TotalCartao]) + sLineBreak;
    Cupom := Cupom + Format('PIX: R$ %10.2f', [FCaixa.TotalPIX]) + sLineBreak;
    Cupom := Cupom + sLineBreak;
    
    Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
    Cupom := Cupom + 'ESTATÍSTICAS' + sLineBreak;
    Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
    Cupom := Cupom + sLineBreak;
    
    Cupom := Cupom + Format('Quantidade Vendas: %d', [FCaixa.QuantidadeVendas]) + sLineBreak;
    Cupom := Cupom + Format('Quantidade Produtos: %d', [FCaixa.QuantidadeProdutos]) + sLineBreak;
    Cupom := Cupom + Format('Valor Médio Venda: R$ %.2f', [FCaixa.ValorMedioVenda]) + sLineBreak;
    Cupom := Cupom + Format('Maior Venda: R$ %.2f', [FCaixa.MaiorVenda]) + sLineBreak;
    Cupom := Cupom + Format('Menor Venda: R$ %.2f', [FCaixa.MenorVenda]) + sLineBreak;
    Cupom := Cupom + sLineBreak;
  end;
  
  // Rodapé
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + CentralizarTexto('OBRIGADO!') + sLineBreak;
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  Cupom := Cupom + CentralizarTexto('SAC: ' + FEmpresaTelefone) + sLineBreak;
  Cupom := Cupom + CentralizarTexto(FEmpresaSite) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  Result := Cupom;
end;

function TImpressoraFiscal.GerarCupomVenda(AVenda: TVenda): string;
var
  Cupom: string;
  i: Integer;
  Item: TItemVenda;
begin
  Cupom := '';
  
  if not Assigned(AVenda) then
  begin
    Result := '';
    Exit;
  end;
  
  // Cabeçalho
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + CentralizarTexto(FEmpresaNome) + sLineBreak;
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Informações da empresa
  Cupom := Cupom + FormatarLinha('CNPJ: ' + FEmpresaCNPJ) + sLineBreak;
  Cupom := Cupom + FormatarLinha('IE: ' + FEmpresaIE) + sLineBreak;
  Cupom := Cupom + FormatarLinha('Endereço: ' + FEmpresaEndereco) + sLineBreak;
  Cupom := Cupom + FormatarLinha('Telefone: ' + FEmpresaTelefone) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Informações da venda
  Cupom := Cupom + Format('Cupom: %06d  Série: %s', [FNumeroCupom, FSerieECF]) + sLineBreak;
  Cupom := Cupom + Format('Data: %s', [FormatDateTime('dd/mm/yyyy hh:mm:ss', AVenda.DataVenda)]) + sLineBreak;
  Cupom := Cupom + Format('Operador: %s', [FOperador.Nome]) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Itens
  Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
  Cupom := Cupom + FormatarLinha('DESCRIÇÃO', 28) + FormatarLinha('QTD', 8) + FormatarLinha('VLR', 12) + sLineBreak;
  Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
  
  for i := 0 to AVenda.QuantidadeItens - 1 do
  begin
    Item := AVenda.GetItem(i);
    if Assigned(Item) then
    begin
      Cupom := Cupom + FormatarLinha(Item.Produto.Nome, 28) +
        Format('%6.0f', [Item.Quantidade]) + sLineBreak;
      Cupom := Cupom + Format('  Subtotal: R$ %10.2f', [Item.ValorTotal]) + sLineBreak;
    end;
  end;
  
  Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Totalizadores
  Cupom := Cupom + Format('SUBTOTAL: R$ %10.2f', [AVenda.Subtotal]) + sLineBreak;
  
  if AVenda.Desconto > 0 then
    Cupom := Cupom + Format('DESCONTO: R$ %10.2f', [AVenda.Desconto]) + sLineBreak;
  
  if AVenda.Acrescimo > 0 then
    Cupom := Cupom + Format('ACRÉSCIMO: R$ %10.2f', [AVenda.Acrescimo]) + sLineBreak;
  
  Cupom := Cupom + sLineBreak;
  Cupom := Cupom + Format('TOTAL: R$ %10.2f', [AVenda.Total]) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  // Forma de pagamento
  Cupom := Cupom + RepetirCaractere('-', 48) + sLineBreak;
  case AVenda.FormaPagamento of
    fpDinheiro:
    begin
      Cupom := Cupom + 'FORMA DE PAGAMENTO: DINHEIRO' + sLineBreak;
      Cupom := Cupom + Format('Valor recebido: R$ %.2f', [AVenda.ValorRecebido]) + sLineBreak;
      Cupom := Cupom + Format('Troco: R$ %.2f', [AVenda.Troco]) + sLineBreak;
    end;
    fpCartao:
      Cupom := Cupom + 'FORMA DE PAGAMENTO: CARTÃO DE CRÉDITO' + sLineBreak;
    fpPIX:
      Cupom := Cupom + 'FORMA DE PAGAMENTO: PIX' + sLineBreak;
  end;
  
  Cupom := Cupom + sLineBreak;
  
  // Rodapé
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + CentralizarTexto('OBRIGADO PELA COMPRA!') + sLineBreak;
  Cupom := Cupom + CentralizarTexto('Volte sempre!') + sLineBreak;
  Cupom := Cupom + RepetirCaractere('*', 48) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  Cupom := Cupom + CentralizarTexto('SAC: ' + FEmpresaTelefone) + sLineBreak;
  Cupom := Cupom + CentralizarTexto(FEmpresaSite) + sLineBreak;
  Cupom := Cupom + sLineBreak;
  
  Result := Cupom;
end;

procedure TImpressoraFiscal.ImprimirCupomFechamento;
begin
  ShowMessage(GerarCupomFechamento);
end;

procedure TImpressoraFiscal.ImprimirCupomVenda(AVenda: TVenda);
begin
  ShowMessage(GerarCupomVenda(AVenda));
end;

procedure TImpressoraFiscal.SalvarCupomFechamento(AArquivo: string);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.Text := GerarCupomFechamento;
    StringList.SaveToFile(AArquivo);
  finally
    StringList.Free;
  end;
end;

procedure TImpressoraFiscal.SalvarCupomVenda(AVenda: TVenda; AArquivo: string);
var
  StringList: TStringList;
begin
  StringList := TStringList.Create;
  try
    StringList.Text := GerarCupomVenda(AVenda);
    StringList.SaveToFile(AArquivo);
  finally
    StringList.Free;
  end;
end;

end.
