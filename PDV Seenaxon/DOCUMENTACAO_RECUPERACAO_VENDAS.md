# Documentação Completa - Classe TRecuperacaoVendas

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Métodos Públicos](#métodos-públicos)
4. [Métodos Privados](#métodos-privados)
5. [Formatos de Arquivo](#formatos-de-arquivo)
6. [Exemplos de Uso](#exemplos-de-uso)
7. [Tratamento de Erros](#tratamento-de-erros)
8. [Casos de Uso](#casos-de-uso)

---

## Visão Geral

A classe `TRecuperacaoVendas` é responsável por **salvar, recuperar e gerenciar vendas pendentes** em arquivo, permitindo que o sistema se recupere automaticamente em caso de interrupção (falta de energia, crash, etc).

### Características Principais

✅ **Serialização Completa** - Salva todos os dados da venda
✅ **Múltiplos Formatos** - XML, CSV e TXT
✅ **Desserialização Automática** - Reconstrói a venda com precisão
✅ **Tratamento de Erros** - Validações em todos os passos
✅ **Diretório Configurável** - Flexibilidade de armazenamento
✅ **Limpeza Automática** - Remove arquivo após recuperação

---

## Arquitetura

### Estrutura de Classe

```pascal
TRecuperacaoVendas = class
  private
    FDiretorio: string;                    // Diretório de armazenamento
    FArquivoVendaPendente: string;         // Nome do arquivo
    FFormatoArquivo: TFormatoArquivo;      // Formato (XML, CSV, TXT)
    FRepositorioProdutos: TRepositorioProdutos; // Referência ao repositório
    
    // Métodos privados de salvamento
    procedure SalvarXML(AVenda: TVenda);
    procedure SalvarCSV(AVenda: TVenda);
    procedure SalvarTXT(AVenda: TVenda);
    
    // Métodos privados de carregamento
    function CarregarXML: TVenda;
    function CarregarCSV: TVenda;
    function CarregarTXT: TVenda;
  public
    // Métodos públicos
    procedure SalvarVendaPendente(AVenda: TVenda);
    procedure DeletarVendaPendente;
    function TemVendaPendente: Boolean;
    function CarregarVendaPendente: TVenda;
    procedure DefinirDiretorio(ADiretorio: string);
end;
```

### Fluxo de Dados

```
TVenda (em memória)
    ↓
SalvarVendaPendente()
    ├─ Validar venda
    ├─ Escolher formato
    ├─ Serializar dados
    └─ Salvar em arquivo
    ↓
Arquivo (XML/CSV/TXT)
    ↓
CarregarVendaPendente()
    ├─ Verificar arquivo
    ├─ Desserializar dados
    ├─ Reconstruir TVenda
    └─ Retornar TVenda
    ↓
TVenda (em memória)
```

---

## Métodos Públicos

### 1. Constructor

```pascal
constructor Create(
  ARepositorioProdutos: TRepositorioProdutos;
  AFormatoArquivo: TFormatoArquivo = faXML
);
```

**Parâmetros:**
- `ARepositorioProdutos`: Referência ao repositório de produtos (obrigatório)
- `AFormatoArquivo`: Formato de arquivo (padrão: XML)

**Exemplo:**
```pascal
var
  Recuperacao: TRecuperacaoVendas;
  Repositorio: TRepositorioProdutos;
begin
  Repositorio := TRepositorioProdutos.Create;
  Repositorio.CarregarProdutosTeste;
  
  { Criar com formato XML }
  Recuperacao := TRecuperacaoVendas.Create(Repositorio, faXML);
  
  { Ou com formato CSV }
  Recuperacao := TRecuperacaoVendas.Create(Repositorio, faCSV);
end;
```

### 2. SalvarVendaPendente

```pascal
procedure SalvarVendaPendente(AVenda: TVenda);
```

**Descrição:** Salva a venda atual em arquivo para recuperação posterior.

**Validações:**
- Venda não pode ser nil
- Venda deve ter pelo menos 1 item

**Exemplo:**
```pascal
var
  Venda: TVenda;
  Recuperacao: TRecuperacaoVendas;
begin
  Venda := TVenda.Create;
  Venda.OperadorID := 1;
  
  { Adicionar produtos... }
  
  { Salvar venda pendente }
  Recuperacao.SalvarVendaPendente(Venda);
  
  ShowMessage('Venda salva com sucesso!');
end;
```

### 3. DeletarVendaPendente

```pascal
procedure DeletarVendaPendente;
```

**Descrição:** Deleta o arquivo de venda pendente se existir.

**Tratamento de Erros:** Silenciosamente ignora erros de deleção.

**Exemplo:**
```pascal
begin
  if Recuperacao.TemVendaPendente then
  begin
    Recuperacao.DeletarVendaPendente;
    ShowMessage('Venda pendente deletada');
  end;
end;
```

### 4. TemVendaPendente

```pascal
function TemVendaPendente: Boolean;
```

**Descrição:** Verifica se existe um arquivo de venda pendente.

**Retorno:** `True` se arquivo existe, `False` caso contrário.

**Exemplo:**
```pascal
begin
  if Recuperacao.TemVendaPendente then
  begin
    ShowMessage('Existe venda pendente!');
  end;
end;
```

### 5. CarregarVendaPendente

```pascal
function CarregarVendaPendente: TVenda;
```

**Descrição:** Carrega a venda pendente do arquivo e reconstrói todos os itens.

**Retorno:** `TVenda` se sucesso, `nil` se falhar.

**Exemplo:**
```pascal
var
  VendaRecuperada: TVenda;
begin
  if Recuperacao.TemVendaPendente then
  begin
    VendaRecuperada := Recuperacao.CarregarVendaPendente;
    if Assigned(VendaRecuperada) then
    begin
      ShowMessage(Format('Venda recuperada! Itens: %d | Total: R$ %.2f',
        [VendaRecuperada.QuantidadeItens, VendaRecuperada.Total]));
    end;
  end;
end;
```

### 6. DefinirDiretorio

```pascal
procedure DefinirDiretorio(ADiretorio: string);
```

**Descrição:** Define o diretório de armazenamento dos arquivos de venda pendente.

**Validação:** Cria o diretório se não existir.

**Exemplo:**
```pascal
begin
  Recuperacao.DefinirDiretorio('C:\Vendas_Pendentes');
  
  { Ou usar diretório do aplicativo }
  Recuperacao.DefinirDiretorio(ExtractFilePath(ParamStr(0)) + 'Vendas');
end;
```

---

## Métodos Privados

### Serialização (Salvamento)

#### SalvarXML

```pascal
procedure SalvarXML(AVenda: TVenda);
```

**Estrutura do XML:**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<VendaPendente versao="1.0" data="2025-12-28 14:30:45" timestamp="1735401045">
  <Venda>
    <OperadorID>1</OperadorID>
    <DataVenda>2025-12-28 14:30:45</DataVenda>
    <Subtotal>150.00</Subtotal>
    <Desconto>10.00</Desconto>
    <PercentualDesconto>6.67</PercentualDesconto>
    <Acrescimo>0.00</Acrescimo>
    <PercentualAcrescimo>0.00</PercentualAcrescimo>
    <Total>140.00</Total>
    <QuantidadeItens>2</QuantidadeItens>
    <Itens>
      <Item indice="0">
        <Produto>
          <ID>1</ID>
          <Nome>LIVRO</Nome>
          <Descricao>Livro de Ficção</Descricao>
          <Preco>29.90</Preco>
          <Categoria>LIVROS</Categoria>
        </Produto>
        <Quantidade>2.00</Quantidade>
        <ValorUnitario>29.90</ValorUnitario>
        <ValorTotal>59.80</ValorTotal>
        <Desconto>5.98</Desconto>
        <PercentualDesconto>10.00</PercentualDesconto>
      </Item>
      <Item indice="1">
        <Produto>
          <ID>2</ID>
          <Nome>CANETA</Nome>
          <Descricao>Caneta Azul</Descricao>
          <Preco>5.00</Preco>
          <Categoria>PAPELARIA</Categoria>
        </Produto>
        <Quantidade>3.00</Quantidade>
        <ValorUnitario>5.00</ValorUnitario>
        <ValorTotal>15.00</ValorTotal>
        <Desconto>0.00</Desconto>
        <PercentualDesconto>0.00</PercentualDesconto>
      </Item>
    </Itens>
  </Venda>
</VendaPendente>
```

**Vantagens:**
- Estrutura hierárquica clara
- Fácil de parsear
- Suporta atributos (versão, data, timestamp)
- Ideal para dados complexos

#### SalvarCSV

```pascal
procedure SalvarCSV(AVenda: TVenda);
```

**Estrutura do CSV:**
```
VENDA PENDENTE - RECUPERAÇÃO AUTOMÁTICA
Data/Hora: 28/12/2025 14:30:45

INFORMAÇÕES DA VENDA
Operador ID;1
Data Venda;28/12/2025 14:30:45
Subtotal;150.00
Desconto;10.00
Percentual Desconto;6.67
Acréscimo;0.00
Percentual Acréscimo;0.00
Total;140.00

ITENS DA VENDA
Indice;ID Produto;Nome Produto;Preço Produto;Quantidade;Valor Unitário;Valor Total;Desconto;% Desconto
0;1;LIVRO;29.90;2.00;29.90;59.80;5.98;10.00
1;2;CANETA;5.00;3.00;5.00;15.00;0.00;0.00
```

**Vantagens:**
- Compatível com Excel e planilhas
- Fácil de visualizar
- Formato padrão

#### SalvarTXT

```pascal
procedure SalvarTXT(AVenda: TVenda);
```

**Estrutura do TXT:**
```
================================================================================
VENDA PENDENTE - RECUPERAÇÃO AUTOMÁTICA
================================================================================

Data/Hora: 28/12/2025 14:30:45

INFORMAÇÕES DA VENDA:
--------------------------------------------------------------------------------
Operador ID: 1
Data da Venda: 28/12/2025 14:30:45
Subtotal: R$ 150.00
Desconto: R$ 10.00
Percentual de Desconto: 6.67%
Acréscimo: R$ 0.00
TOTAL: R$ 140.00
Quantidade de Itens: 2

ITENS DA VENDA:
--------------------------------------------------------------------------------

1. LIVRO (ID: 1)
   Quantidade: 2.00
   Preço Unitário: R$ 29.90
   Valor Total: R$ 59.80
   Desconto: R$ 5.98 (10.00%)

2. CANETA (ID: 2)
   Quantidade: 3.00
   Preço Unitário: R$ 5.00
   Valor Total: R$ 15.00

================================================================================
Arquivo gerado automaticamente para recuperação de venda pendente.
Data de Geração: 28/12/2025 14:30:45
================================================================================
```

**Vantagens:**
- Legível por humanos
- Ideal para visualização
- Formatação clara

### Desserialização (Carregamento)

#### CarregarXML

```pascal
function CarregarXML: TVenda;
```

**Processo:**
1. Verificar se arquivo existe
2. Carregar documento XML
3. Validar nó raiz
4. Extrair dados da venda
5. Iterar sobre itens
6. Buscar produtos no repositório
7. Reconstruir TVenda com todos os itens
8. Retornar TVenda

**Tratamento de Erros:** Retorna `nil` em caso de erro.

#### CarregarCSV

```pascal
function CarregarCSV: TVenda;
```

**Processo:**
1. Verificar se arquivo existe
2. Carregar linhas do arquivo
3. Encontrar seção "ITENS DA VENDA"
4. Parsear cada linha de item
5. Dividir por ponto-e-vírgula
6. Extrair ID e quantidade
7. Buscar produto no repositório
8. Reconstruir TVenda

**Tratamento de Erros:** Ignora linhas com erro de parsing.

#### CarregarTXT

```pascal
function CarregarTXT: TVenda;
```

**Processo:**
1. Verificar se arquivo existe
2. Carregar linhas do arquivo
3. Encontrar seção "ITENS DA VENDA:"
4. Procurar por linhas com padrão "N. Nome (ID: X)"
5. Extrair ID do produto
6. Buscar quantidade na próxima linha
7. Buscar produto no repositório
8. Reconstruir TVenda

**Tratamento de Erros:** Ignora linhas com erro de parsing.

---

## Formatos de Arquivo

### Comparação

| Aspecto | XML | CSV | TXT |
|---------|-----|-----|-----|
| **Legibilidade** | Boa | Excelente | Excelente |
| **Compatibilidade** | Excelente | Excelente | Excelente |
| **Tamanho** | Médio | Pequeno | Médio |
| **Estrutura** | Hierárquica | Tabular | Livre |
| **Validação** | Rigorosa | Flexível | Flexível |
| **Recomendado** | ✅ Padrão | ✅ Planilhas | ✅ Visualização |

---

## Exemplos de Uso

### Exemplo 1: Salvar Venda Pendente

```pascal
var
  Repositorio: TRepositorioProdutos;
  Recuperacao: TRecuperacaoVendas;
  Venda: TVenda;
  Produto: TProduto;
  Item: TItemVenda;
begin
  { Criar repositório }
  Repositorio := TRepositorioProdutos.Create;
  Repositorio.CarregarProdutosTeste;
  
  { Criar recuperação }
  Recuperacao := TRecuperacaoVendas.Create(Repositorio, faXML);
  
  { Criar venda }
  Venda := TVenda.Create;
  Venda.OperadorID := 1;
  
  { Adicionar produtos }
  Produto := TProduto.Create(1, 'LIVRO', 'Livro Teste', 29.90);
  Item := TItemVenda.Create(Produto, 2);
  Venda.AdicionarItem(Item);
  
  { Aplicar desconto }
  Venda.AplicarDesconto(10, True);
  
  { Salvar venda pendente }
  Recuperacao.SalvarVendaPendente(Venda);
  
  ShowMessage('Venda salva com sucesso!');
  
  { Liberar }
  Venda.Free;
  Recuperacao.Free;
  Repositorio.Free;
end;
```

### Exemplo 2: Recuperar Venda Pendente

```pascal
var
  Repositorio: TRepositorioProdutos;
  Recuperacao: TRecuperacaoVendas;
  VendaRecuperada: TVenda;
begin
  { Criar repositório }
  Repositorio := TRepositorioProdutos.Create;
  Repositorio.CarregarProdutosTeste;
  
  { Criar recuperação }
  Recuperacao := TRecuperacaoVendas.Create(Repositorio, faXML);
  
  { Verificar se existe venda pendente }
  if Recuperacao.TemVendaPendente then
  begin
    { Carregar venda }
    VendaRecuperada := Recuperacao.CarregarVendaPendente;
    
    if Assigned(VendaRecuperada) then
    begin
      ShowMessage(Format('Venda recuperada!' + sLineBreak +
        'Itens: %d' + sLineBreak +
        'Total: R$ %.2f',
        [VendaRecuperada.QuantidadeItens, VendaRecuperada.Total]));
      
      { Usar venda recuperada... }
      
      { Deletar arquivo após usar }
      Recuperacao.DeletarVendaPendente;
      
      { Liberar }
      VendaRecuperada.Free;
    end;
  end;
  
  { Liberar }
  Recuperacao.Free;
  Repositorio.Free;
end;
```

### Exemplo 3: Mudar Formato de Arquivo

```pascal
var
  Recuperacao: TRecuperacaoVendas;
  Repositorio: TRepositorioProdutos;
begin
  Repositorio := TRepositorioProdutos.Create;
  
  { Criar com XML }
  Recuperacao := TRecuperacaoVendas.Create(Repositorio, faXML);
  
  { Mudar para CSV }
  Recuperacao.Formato := faCSV;
  
  { Mudar para TXT }
  Recuperacao.Formato := faTXT;
  
  { Liberar }
  Recuperacao.Free;
  Repositorio.Free;
end;
```

### Exemplo 4: Definir Diretório Customizado

```pascal
var
  Recuperacao: TRecuperacaoVendas;
  Repositorio: TRepositorioProdutos;
  CaminhoCustomizado: string;
begin
  Repositorio := TRepositorioProdutos.Create;
  Recuperacao := TRecuperacaoVendas.Create(Repositorio);
  
  { Usar diretório customizado }
  CaminhoCustomizado := 'C:\Meu_PDV\Vendas_Pendentes';
  Recuperacao.DefinirDiretorio(CaminhoCustomizado);
  
  { Agora os arquivos serão salvos em C:\Meu_PDV\Vendas_Pendentes\ }
  
  { Liberar }
  Recuperacao.Free;
  Repositorio.Free;
end;
```

---

## Tratamento de Erros

### Validações Implementadas

```pascal
{ 1. Validação de venda }
if not Assigned(AVenda) or (AVenda.QuantidadeItens = 0) then
  Exit; { Venda inválida }

{ 2. Validação de arquivo }
if not TFile.Exists(ObterCaminhoArquivo) then
  Exit; { Arquivo não existe }

{ 3. Validação de XML }
if RootNode.NodeName <> 'VendaPendente' then
  Exit; { XML inválido }

{ 4. Validação de campos }
if not Assigned(VendaNode.ChildNodes.FindNode('OperadorID')) then
  Exit; { Campo obrigatório não encontrado }
```

### Tratamento de Exceções

```pascal
try
  { Operação que pode gerar erro }
  XMLDoc := LoadXMLDocument(ObterCaminhoArquivo);
except
  on E: Exception do
  begin
    { Tratamento de erro }
    Result := nil;
    { Pode adicionar log aqui }
  end;
end;
```

---

## Casos de Uso

### Caso 1: Sistema Cai Durante a Venda

```
1. Operador está realizando venda
   ├─ Adicionou 5 produtos
   ├─ Aplicou desconto
   └─ Arquivo de venda pendente é salvo automaticamente

2. Sistema cai (falta de energia)

3. Operador reinicia sistema

4. Sistema detecta venda pendente

5. Pergunta: "Deseja retomar venda?"

6. Operador clica "SIM"

7. Venda é recuperada com todos os itens

8. Operador continua normalmente

9. Finaliza venda

10. Arquivo é deletado
```

### Caso 2: Múltiplas Interrupções

```
1. Venda 1: Criada → Interrupção → Recuperada → Finalizada
2. Venda 2: Criada → Interrupção → Recuperada → Finalizada
3. Venda 3: Criada → Finalizada normalmente
```

### Caso 3: Backup Manual

```
1. Operador realiza venda
2. Antes de finalizar, salva venda pendente manualmente
3. Pode revisar arquivo CSV em Excel
4. Depois recupera e finaliza
```

---

## 🎯 Resumo

A classe `TRecuperacaoVendas` fornece:

✅ **Salvamento automático** de vendas em progresso
✅ **Recuperação automática** após interrupção
✅ **Múltiplos formatos** (XML, CSV, TXT)
✅ **Serialização completa** de todos os dados
✅ **Desserialização precisa** com reconstrução de objetos
✅ **Tratamento robusto** de erros
✅ **Flexibilidade** de armazenamento

O sistema garante que **nenhuma venda seja perdida** em caso de interrupção!
