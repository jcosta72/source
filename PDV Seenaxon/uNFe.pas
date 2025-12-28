unit uNFe;

interface

uses
  System.SysUtils, System.Classes,
  uVenda, uOperador, uItemVenda;

type
  TNFe = class
  private
    FVenda: TVenda;
    FOperador: TOperador;
    FNumeroNFe: Integer;
    FSerie: Integer;
    FChaveAcesso: string;
    FDataEmissao: TDateTime;
    FCNPJ: string;
    FRazaoSocial: string;
    FInscricaoEstadual: string;
    
    procedure GerarChaveAcesso;
    procedure GerarNumeroNFe;
    function CalcularDigitoVerificador(AChave: string): string;
  public
    constructor Create(AVenda: TVenda; AOperador: TOperador);
    destructor Destroy; override;
    
    procedure Emitir;
    procedure Cancelar;
    procedure Imprimir;
    function GerarXML: string;
    function GerarDANFE: string;
    function ValidarChaveAcesso: Boolean;
    
    property Venda: TVenda read FVenda;
    property Operador: TOperador read FOperador;
    property NumeroNFe: Integer read FNumeroNFe;
    property Serie: Integer read FSerie;
    property ChaveAcesso: string read FChaveAcesso;
    property DataEmissao: TDateTime read FDataEmissao;
    property CNPJ: string read FCNPJ write FCNPJ;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property InscricaoEstadual: string read FInscricaoEstadual write FInscricaoEstadual;
  end;

implementation

constructor TNFe.Create(AVenda: TVenda; AOperador: TOperador);
begin
  inherited Create;
  FVenda := AVenda;
  FOperador := AOperador;
  FSerie := 1;
  FDataEmissao := Now;
  
  // Dados padrão da empresa (devem ser configurados)
  FCNPJ := '00.000.000/0000-00';
  FRazaoSocial := 'Empresa Padrão';
  FInscricaoEstadual := '00.000.000.000.000';
  
  GerarNumeroNFe;
  GerarChaveAcesso;
end;

destructor TNFe.Destroy;
begin
  inherited;
end;

procedure TNFe.GerarNumeroNFe;
begin
  // Gera número sequencial para NFe
  // Em produção, isso viria de um banco de dados
  Randomize;
  FNumeroNFe := Random(999999) + 1;
end;

procedure TNFe.GerarChaveAcesso;
var
  UF: string;
  AAMM: string;
  Sequencia: string;
  DigitoVerificador: string;
begin
  // Formato: UF + AAMM + CNPJ + Modelo + Serie + Numero + DigitoVerificador
  // Exemplo: 35 2501 00000000000191 55 1 000000001 5
  
  UF := '35'; // São Paulo
  AAMM := FormatDateTime('yymm', FDataEmissao);
  Sequencia := Format('%06d', [FNumeroNFe]);
  
  // Remove caracteres especiais do CNPJ
  CNPJ := StringReplace(CNPJ, '.', '', [rfReplaceAll]);
  CNPJ := StringReplace(CNPJ, '/', '', [rfReplaceAll]);
  CNPJ := StringReplace(CNPJ, '-', '', [rfReplaceAll]);
  
  FChaveAcesso := UF + AAMM + CNPJ + '55' + Format('%03d', [FSerie]) + Sequencia;
  
  // Calcula dígito verificador
  DigitoVerificador := CalcularDigitoVerificador(FChaveAcesso);
  FChaveAcesso := FChaveAcesso + DigitoVerificador;
end;

function TNFe.CalcularDigitoVerificador(AChave: string): string;
var
  Soma: Integer;
  Resto: Integer;
  i: Integer;
  Multiplicador: Integer;
begin
  Soma := 0;
  Multiplicador := 2;
  
  // Calcula da direita para esquerda
  for i := Length(AChave) downto 1 do
  begin
    Soma := Soma + (StrToInt(AChave[i]) * Multiplicador);
    Multiplicador := Multiplicador + 1;
    if Multiplicador > 9 then
      Multiplicador := 2;
  end;
  
  Resto := Soma mod 11;
  
  if Resto = 0 then
    Result := '0'
  else if Resto = 1 then
    Result := '0'
  else
    Result := IntToStr(11 - Resto);
end;

procedure TNFe.Emitir;
begin
  // Emite a NFe
  // Em produção, isso enviaria para a SEFAZ
  ShowMessage(Format('NFe emitida com sucesso!' + sLineBreak +
    'Número: %d' + sLineBreak +
    'Série: %d' + sLineBreak +
    'Chave de Acesso: %s',
    [FNumeroNFe, FSerie, FChaveAcesso]));
end;

procedure TNFe.Cancelar;
begin
  // Cancela a NFe
  // Em produção, isso enviaria para a SEFAZ
  ShowMessage('NFe cancelada com sucesso!');
end;

procedure TNFe.Imprimir;
begin
  // Imprime a DANFE (Documento Auxiliar da NFe)
  ShowMessage('Imprimindo DANFE...');
end;

function TNFe.GerarXML: string;
var
  XML: TStringList;
  i: Integer;
  Item: TItemVenda;
begin
  XML := TStringList.Create;
  try
    XML.Add('<?xml version="1.0" encoding="UTF-8"?>');
    XML.Add('<NFe>');
    XML.Add('  <infNFe Id="NFe' + FChaveAcesso + '">');
    XML.Add('    <ide>');
    XML.Add('      <cUF>35</cUF>');
    XML.Add('      <natOp>VENDA</natOp>');
    XML.Add('      <indPag>0</indPag>');
    XML.Add('      <mod>55</mod>');
    XML.Add('      <serie>' + IntToStr(FSerie) + '</serie>');
    XML.Add('      <nNF>' + IntToStr(FNumeroNFe) + '</nNF>');
    XML.Add('      <dEmi>' + FormatDateTime('yyyy-mm-dd', FDataEmissao) + '</dEmi>');
    XML.Add('      <hEmi>' + FormatDateTime('hh:mm:ss', FDataEmissao) + '</hEmi>');
    XML.Add('    </ide>');
    XML.Add('    <emit>');
    XML.Add('      <CNPJ>' + FCNPJ + '</CNPJ>');
    XML.Add('      <xNome>' + FRazaoSocial + '</xNome>');
    XML.Add('      <IE>' + FInscricaoEstadual + '</IE>');
    XML.Add('    </emit>');
    XML.Add('    <dest>');
    XML.Add('      <CNPJ>00000000000000</CNPJ>');
    XML.Add('      <xNome>CONSUMIDOR</xNome>');
    XML.Add('    </dest>');
    XML.Add('    <det>');
    
    // Adiciona itens da venda
    for i := 0 to FVenda.QuantidadeItens - 1 do
    begin
      Item := FVenda.GetItem(i);
      if Assigned(Item) then
      begin
        XML.Add('      <prod>');
        XML.Add('        <code>' + IntToStr(Item.Produto.ID) + '</code>');
        XML.Add('        <xProd>' + Item.Produto.Nome + '</xProd>');
        XML.Add('        <NCM>00000000</NCM>');
        XML.Add('        <qCom>' + FormatFloat('0.00', Item.Quantidade) + '</qCom>');
        XML.Add('        <uCom>UN</uCom>');
        XML.Add('        <vUnCom>' + FormatFloat('0.00', Item.ValorUnitario) + '</vUnCom>');
        XML.Add('        <vItem>' + FormatFloat('0.00', Item.ValorTotal) + '</vItem>');
        XML.Add('      </prod>');
      end;
    end;
    
    XML.Add('    </det>');
    XML.Add('    <total>');
    XML.Add('      <vSubtotal>' + FormatFloat('0.00', FVenda.Subtotal) + '</vSubtotal>');
    XML.Add('      <vDesc>' + FormatFloat('0.00', FVenda.Desconto) + '</vDesc>');
    XML.Add('      <vAcres>' + FormatFloat('0.00', FVenda.Acrescimo) + '</vAcres>');
    XML.Add('      <vNF>' + FormatFloat('0.00', FVenda.Total) + '</vNF>');
    XML.Add('    </total>');
    XML.Add('  </infNFe>');
    XML.Add('</NFe>');
    
    Result := XML.Text;
  finally
    XML.Free;
  end;
end;

function TNFe.GerarDANFE: string;
var
  DANFE: TStringList;
  i: Integer;
  Item: TItemVenda;
begin
  DANFE := TStringList.Create;
  try
    DANFE.Add('╔════════════════════════════════════════════════════════════════╗');
    DANFE.Add('║                    DANFE - DOCUMENTO AUXILIAR                 ║');
    DANFE.Add('║                  DA NOTA FISCAL ELETRÔNICA                    ║');
    DANFE.Add('╚════════════════════════════════════════════════════════════════╝');
    DANFE.Add('');
    DANFE.Add('Chave de Acesso: ' + FChaveAcesso);
    DANFE.Add('');
    DANFE.Add('EMITENTE:');
    DANFE.Add('  Razão Social: ' + FRazaoSocial);
    DANFE.Add('  CNPJ: ' + FCNPJ);
    DANFE.Add('  IE: ' + FInscricaoEstadual);
    DANFE.Add('');
    DANFE.Add('NOTA FISCAL:');
    DANFE.Add('  Número: ' + IntToStr(FNumeroNFe));
    DANFE.Add('  Série: ' + IntToStr(FSerie));
    DANFE.Add('  Data: ' + FormatDateTime('dd/mm/yyyy hh:mm:ss', FDataEmissao));
    DANFE.Add('');
    DANFE.Add('OPERADOR:');
    DANFE.Add('  Nome: ' + FOperador.Nome);
    DANFE.Add('  Matrícula: ' + FOperador.Matricula);
    DANFE.Add('');
    DANFE.Add('ITENS:');
    DANFE.Add('─────────────────────────────────────────────────────────────────');
    DANFE.Add('Seq | Produto                    | Qtd    | Valor Unit | Valor Total');
    DANFE.Add('─────────────────────────────────────────────────────────────────');
    
    for i := 0 to FVenda.QuantidadeItens - 1 do
    begin
      Item := FVenda.GetItem(i);
      if Assigned(Item) then
      begin
        DANFE.Add(Format('%3d | %-26s | %6.2f | %10.2f | %11.2f',
          [i + 1, Item.Produto.Nome, Item.Quantidade, Item.ValorUnitario, Item.ValorTotal]));
      end;
    end;
    
    DANFE.Add('─────────────────────────────────────────────────────────────────');
    DANFE.Add('');
    DANFE.Add('TOTALIZADORES:');
    DANFE.Add('  Subtotal: R$ ' + FormatFloat('0.00', FVenda.Subtotal));
    DANFE.Add('  Desconto: R$ ' + FormatFloat('0.00', FVenda.Desconto));
    DANFE.Add('  Acréscimo: R$ ' + FormatFloat('0.00', FVenda.Acrescimo));
    DANFE.Add('  ─────────────────────────');
    DANFE.Add('  TOTAL: R$ ' + FormatFloat('0.00', FVenda.Total));
    DANFE.Add('');
    DANFE.Add('╔════════════════════════════════════════════════════════════════╗');
    DANFE.Add('║                    FIM DO DOCUMENTO AUXILIAR                   ║');
    DANFE.Add('╚════════════════════════════════════════════════════════════════╝');
    
    Result := DANFE.Text;
  finally
    DANFE.Free;
  end;
end;

function TNFe.ValidarChaveAcesso: Boolean;
begin
  // Valida se a chave de acesso está correta
  // Verifica tamanho (44 dígitos) e dígito verificador
  Result := (Length(FChaveAcesso) = 44);
end;

end.
