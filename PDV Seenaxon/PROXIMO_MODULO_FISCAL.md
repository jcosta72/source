# Próximo Módulo Essencial: Conformidade Fiscal e Emissão de NFCe

## 📋 Análise Situacional

### Status Atual do PDV Seenaxon

O sistema possui:
- ✅ Persistência completa de vendas e operadores
- ✅ Autenticação segura com PBKDF2
- ✅ Gerenciamento de caixa com sangria e suprimento
- ✅ Relatórios gerenciais detalhados
- ✅ Suporte a múltiplas formas de pagamento
- ✅ Interface responsiva em FMX

### Lacunas Fiscais Identificadas

| Aspecto | Status | Criticidade |
|--------|--------|-------------|
| **Emissão de NFCe** | ❌ Não existe | 🔴 CRÍTICA |
| **Integração com SEFAZ** | ❌ Não existe | 🔴 CRÍTICA |
| **Conformidade com SEFAZ** | ❌ Não existe | 🔴 CRÍTICA |
| **Certificado Digital** | ❌ Não existe | 🔴 CRÍTICA |
| **Integração com NFe** | ⚠️ Planejada | 🟠 ALTA |
| **Auditoria Fiscal** | ⚠️ Parcial | 🟠 ALTA |
| **Validação de CNPJ/CPF** | ⚠️ Básica | 🟡 MÉDIA |

---

## 🎯 Próximo Módulo Essencial: Sistema de Emissão de NFCe (SENF)

### Propósito

Garantir a conformidade fiscal brasileira através da emissão de Notas Fiscais do Consumidor Eletrônicas (NFCe) integradas com a SEFAZ (Secretaria da Fazenda).

### Por Que NFCe e Não SAT?

**SAT será descontinuado em 2026** conforme determinação da SEFAZ. A solução moderna e obrigatória é a **NFCe** (Nota Fiscal do Consumidor Eletrônica) que oferece:

- ✅ Validade indefinida (não descontinua)
- ✅ Integração direta com SEFAZ
- ✅ Suporte a múltiplos estados
- ✅ Compatibilidade com sistemas futuros
- ✅ Melhor rastreabilidade
- ✅ Conformidade com legislação atual

---

## 🏗️ Componentes do Módulo SENF

### 1. **Módulo de Certificado Digital** (uCertificadoDigital.pas)
- Carregamento de certificado A1 (PFX)
- Validação de certificado
- Renovação automática
- Armazenamento seguro
- Suporte a e-CNPJ

#### Funcionalidades
```pascal
function CarregarCertificado(AArquivo: string; ASenha: string): Boolean;
function ValidarCertificado: Boolean;
function ObterDataValidade: TDateTime;
function EstaVencido: Boolean;
function AssinarXML(AXML: string): string;
function ValidarAssinatura(AXML: string): Boolean;
```

### 2. **Módulo de Validação Fiscal** (uValidacaoFiscal.pas)
- Validação de CNPJ/CPF
- Validação de dados fiscais
- Conformidade com regras da SEFAZ
- Verificação de duplicação
- Validação de ICMS/PIS/COFINS

#### Funcionalidades
```pascal
function ValidarCNPJ(ACNPJ: string): Boolean;
function ValidarCPF(ACPF: string): Boolean;
function ValidarDadosFiscais(AVenda: TVenda): Boolean;
function VerificarDuplicacao(AVenda: TVenda): Boolean;
function ValidarAliquotasImposto(AProduto: TProduto): Boolean;
```

### 3. **Módulo de Emissão de NFCe** (uEmissaoNFCe.pas)
- Geração de XML da NFCe
- Assinatura digital do XML
- Validação de esquema XSD
- Numeração sequencial
- Tratamento de erros

#### Funcionalidades
```pascal
function GerarNFCe(AVenda: TVenda): string;
function AssinarNFCe(AXML: string): string;
function ValidarXSD(AXML: string): Boolean;
function ObterProximoNumero: Integer;
function CalcularDigitoVerificador(AChave: string): Integer;
```

### 4. **Módulo de Integração com SEFAZ** (uIntegracaoSEFAZ.pas)
- Comunicação com webservice da SEFAZ
- Envio de NFCe para autorização
- Recebimento de resposta
- Tratamento de erros
- Suporte a múltiplos estados

#### Funcionalidades
```pascal
function EnviarNFCe(AXML: string): TRespuestaSEFAZ;
function ConsultarStatusNFCe(AChave: string): TStatusNFCe;
function CancelarNFCe(AChave: string; AMotivo: string): Boolean;
function InutilizarNumero(ANumeroInicio, ANumeroFim: Integer): Boolean;
function ObtenerCertificadoSEFAZ: string;
```

### 5. **Módulo de Integração com NFe** (uIntegracaoNFe.pas)
- Geração de NFe para vendas B2B
- Envio para SEFAZ
- Rastreamento de NFe
- Cancelamento de NFe
- Complementação de NFCe para NFe

#### Funcionalidades
```pascal
function GerarNFe(AVenda: TVenda): string;
function EnviarNFe(AXML: string): TRespostaSEFAZ;
function ConsultarStatusNFe(AChave: string): TStatusNFe;
function CancelarNFe(AChave: string; AMotivo: string): Boolean;
function ComplementarNFCeParaNFe(AChaveNFCe: string): string;
```

### 6. **Módulo de Armazenamento Fiscal** (uArmazenamentoFiscal.pas)
- Armazenamento de NFCe emitidas
- Histórico de emissões
- Backup de NFCe
- Recuperação de NFCe
- Conformidade com legislação

#### Funcionalidades
```pascal
function SalvarNFCe(AChave: string; AXML: string; ARespostaSEFAZ: string): Boolean;
function ObterNFCePorChave(AChave: string): TNFCe;
function ObterNFCesPorPeriodo(ADataInicio, ADataFim: TDateTime): TObjectList<TNFCe>;
function FazerBackupNFCe(AArquivoDestino: string): Boolean;
function RestaurarBackupNFCe(AArquivoOrigem: string): Boolean;
function VerificarIntegridade: Boolean;
```

### 7. **Módulo de Auditoria Fiscal** (uAuditoriaFiscal.pas)
- Registro de todas as operações fiscais
- Rastreabilidade completa
- Conformidade com legislação
- Relatórios para fiscalização
- Conformidade com LGPD

#### Funcionalidades
```pascal
function RegistrarOperacaoFiscal(AOperacao: string; ADetalhes: string): Boolean;
function ObterHistoricoOperacoes(ADataInicio, ADataFim: TDateTime): TStringList;
function GerarRelatoriAuditoria(ADataInicio, ADataFim: TDateTime): string;
function VerificarConformidade: Boolean;
function ExportarParaFiscalizacao(AArquivo: string): Boolean;
```

---

## 📊 Arquitetura do Módulo de Conformidade Fiscal

```
┌─────────────────────────────────────────────────────────────┐
│                    PDV SEENAXON                             │
│              (Tela Principal - Vendas)                      │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│    Sistema de Emissão de NFCe (SENF)                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Validação Fiscal                                    │  │
│  │  - Validar CNPJ/CPF                                  │  │
│  │  - Validar dados da venda                            │  │
│  │  - Verificar duplicação                              │  │
│  │  - Validar alíquotas de imposto                      │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Geração de NFCe                                     │  │
│  │  - Montar XML da NFCe                                │  │
│  │  - Validar contra XSD                                │  │
│  │  - Assinar digitalmente                              │  │
│  │  - Gerar chave de acesso                             │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Integração com SEFAZ                                │  │
│  │  - Enviar NFCe para autorização                      │  │
│  │  - Receber resposta da SEFAZ                         │  │
│  │  - Tratar erros e validações                         │  │
│  │  - Suportar múltiplos estados                        │  │
│  └──────────────────────────────────────────────────────┘  │
│                     │                                        │
│                     ▼                                        │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Armazenamento e Auditoria                           │  │
│  │  - Salvar NFCe autorizada                            │  │
│  │  - Registrar em auditoria                            │  │
│  │  - Gerar backup                                      │  │
│  │  - Manter conformidade legal                         │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│         Banco de Dados SQLite                               │
│  - NFCe Emitidas                                            │
│  - Histórico Fiscal                                         │
│  - Auditoria                                                │
│  - Certificados                                             │
│  - Sequência de Numeração                                   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 Fluxo de Emissão de NFCe

```
1. VENDA FINALIZADA
   ├─ Operador clica em "Finalizar Venda"
   ├─ Sistema valida dados da venda
   └─ Abre tela de emissão fiscal
   
2. VALIDAÇÃO FISCAL
   ├─ Validar CNPJ/CPF do cliente (obrigatório para NFCe)
   ├─ Validar dados da empresa
   ├─ Validar itens da venda
   ├─ Validar alíquotas de imposto
   ├─ Verificar duplicação
   └─ Se OK → Prosseguir | Se Erro → Alertar operador
   
3. GERAÇÃO DE NFCe
   ├─ Obter próximo número de sequência
   ├─ Montar XML com dados da venda
   ├─ Incluir informações fiscais (ICMS, PIS, COFINS)
   ├─ Incluir dados do operador
   ├─ Incluir dados do caixa
   ├─ Calcular chave de acesso
   ├─ Validar contra XSD
   └─ Assinar digitalmente com certificado
   
4. ENVIO PARA SEFAZ
   ├─ Conectar ao webservice da SEFAZ
   ├─ Enviar NFCe assinada
   ├─ Aguardar resposta
   ├─ Validar resposta
   └─ Se OK → Autorizada | Se Erro → Tratamento de erro
   
5. ARMAZENAMENTO
   ├─ Salvar NFCe autorizada no banco
   ├─ Salvar resposta da SEFAZ
   ├─ Registrar em auditoria
   ├─ Gerar backup
   └─ Imprimir DANFE (Documento Auxiliar da NFCe)
   
6. CONFIRMAÇÃO AO OPERADOR
   ├─ Exibir número da NFCe
   ├─ Exibir chave de acesso
   ├─ Exibir QR code
   ├─ Exibir DANFE
   └─ Oferecer opção de reimpressão
```

---

## 📋 Requisitos Técnicos

### Dependências Externas

1. **Certificado Digital A1 (e-CNPJ)**
   - Arquivo PFX com chave privada
   - Senha de acesso
   - Validade mínima de 1 ano
   - Emitido por AC ICP-Brasil

2. **Acesso à SEFAZ**
   - Credenciais de acesso (CNPJ, senha)
   - Certificado digital
   - Ambiente de teste (SEFAZ-RS)
   - Ambiente de produção (SEFAZ estadual)

3. **Configuração Estadual**
   - Código de estado
   - Código de município
   - Regime tributário
   - Alíquotas de imposto

### Bibliotecas Necessárias

```pascal
uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Xml.XMLDoc,
  Xml.XMLIntf,
  IdHTTP,
  IdSSLOpenSSL,
  uCriptografiaSenha,
  uValidacaoFiscal,
  uCertificadoDigital,
  uEmissaoNFCe,
  uIntegracaoSEFAZ,
  uIntegracaoNFe,
  uArmazenamentoFiscal,
  uAuditoriaFiscal;
```

---

## 🗄️ Estrutura de Tabelas Adicionais

### Tabela: NFCeEmitidas

```sql
CREATE TABLE NFCeEmitidas (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  VendaID INTEGER NOT NULL,
  NumeroNFCe INTEGER NOT NULL,
  ChaveAcesso TEXT UNIQUE NOT NULL,
  XMLNFCe TEXT NOT NULL,
  XMLResposta TEXT,
  StatusAutorizacao INTEGER,
  DataEmissao DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataAutorizacao DATETIME,
  MotivoCancelamento TEXT,
  DataCancelamento DATETIME,
  CNPJCPF TEXT,
  ValorTotal REAL,
  FOREIGN KEY (VendaID) REFERENCES Vendas(ID),
  UNIQUE(NumeroNFCe)
);

CREATE INDEX idx_nfce_chave ON NFCeEmitidas(ChaveAcesso);
CREATE INDEX idx_nfce_numero ON NFCeEmitidas(NumeroNFCe);
CREATE INDEX idx_nfce_data ON NFCeEmitidas(DataEmissao);
CREATE INDEX idx_nfce_status ON NFCeEmitidas(StatusAutorizacao);
```

### Tabela: HistoricoFiscal

```sql
CREATE TABLE HistoricoFiscal (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  NFCeID INTEGER NOT NULL,
  Operacao TEXT NOT NULL,
  Resultado TEXT NOT NULL,
  CodigoErro TEXT,
  MensagemErro TEXT,
  Detalhes TEXT,
  DataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (NFCeID) REFERENCES NFCeEmitidas(ID)
);

CREATE INDEX idx_historico_nfce ON HistoricoFiscal(NFCeID);
CREATE INDEX idx_historico_data ON HistoricoFiscal(DataHora);
```

### Tabela: CertificadosDigitais

```sql
CREATE TABLE CertificadosDigitais (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  NomeCertificado TEXT NOT NULL,
  CaminhoArquivo TEXT NOT NULL,
  Senha TEXT NOT NULL,
  DataValidade DATETIME NOT NULL,
  DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  Ativo BOOLEAN DEFAULT 1,
  CNPJ TEXT,
  Thumbprint TEXT UNIQUE
);

CREATE INDEX idx_cert_ativo ON CertificadosDigitais(Ativo);
CREATE INDEX idx_cert_validade ON CertificadosDigitais(DataValidade);
```

### Tabela: SequenciaNFCe

```sql
CREATE TABLE SequenciaNFCe (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  Estado TEXT NOT NULL,
  UltimoNumero INTEGER DEFAULT 0,
  DataUltimaAtualizacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(Estado)
);
```

### Tabela: ConfiguracaoFiscal

```sql
CREATE TABLE ConfiguracaoFiscal (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  CNPJ TEXT NOT NULL,
  RazaoSocial TEXT NOT NULL,
  NomeFantasia TEXT,
  Estado TEXT NOT NULL,
  Municipio TEXT NOT NULL,
  RegimeTributario INTEGER,
  AmbienteSEFAZ INTEGER,
  CertificadoID INTEGER,
  DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataAtualizacao DATETIME,
  FOREIGN KEY (CertificadoID) REFERENCES CertificadosDigitais(ID)
);
```

---

## 📈 Benefícios da Implementação

| Benefício | Descrição |
|-----------|-----------|
| **Conformidade Legal** | Atende legislação fiscal brasileira |
| **Futuro Garantido** | NFCe não será descontinuada (SAT descontinua em 2026) |
| **Rastreabilidade** | Todas as operações registradas na SEFAZ |
| **Segurança** | Assinatura digital de NFCe |
| **Auditoria** | Histórico completo para fiscalização |
| **Integração** | Funciona com SEFAZ de todos os estados |
| **Confiabilidade** | Tratamento robusto de erros |
| **Performance** | Emissão rápida de NFCe |
| **Escalabilidade** | Suporta múltiplos caixas |
| **Modernidade** | Compatível com sistemas futuros |

---

## 🚀 Cronograma de Implementação

### Fase 1: Fundação (Semana 1-2)
- [ ] Criar módulo de certificado digital
- [ ] Criar módulo de validação fiscal
- [ ] Criar estrutura de banco de dados
- [ ] Implementar auditoria fiscal

### Fase 2: Emissão (Semana 3-4)
- [ ] Criar módulo de geração de NFCe
- [ ] Implementar assinatura digital
- [ ] Validar contra XSD
- [ ] Criar testes unitários

### Fase 3: Integração (Semana 5-6)
- [ ] Integrar com SEFAZ
- [ ] Implementar tratamento de erros
- [ ] Suportar múltiplos estados
- [ ] Criar testes de integração

### Fase 4: Interface (Semana 7)
- [ ] Criar tela de configuração fiscal
- [ ] Criar tela de emissão de NFCe
- [ ] Criar tela de reimpressão
- [ ] Criar tela de cancelamento

### Fase 5: Testes e Produção (Semana 8)
- [ ] Testes em ambiente de teste (SEFAZ-RS)
- [ ] Testes em ambiente de produção
- [ ] Documentação final
- [ ] Treinamento de operadores

---

## 📚 Referências Normativas

1. **Lei nº 12.865/2013** - Institui a NFCe
2. **Decreto nº 8.820/2016** - Regulamenta a NFCe
3. **Manual de Orientação do Contribuinte** - SEFAZ
4. **Especificação Técnica da NFCe** - SEFAZ
5. **Documentação ACBr** - Biblioteca de integração fiscal brasileira

---

## 💡 Recomendações

### Biblioteca Recomendada: ACBr

Usar a biblioteca **ACBr** (Automação Comercial Brasileira) que é:
- ✅ Open source
- ✅ Mantida pela comunidade brasileira
- ✅ Suporta NFCe, NFe, SEFAZ
- ✅ Compatível com Delphi
- ✅ Bem documentada
- ✅ Amplamente testada em produção

### Integração com ACBr

```pascal
uses
  ACBrNFCe,
  ACBrValidador,
  ACBrCertificados;

procedure EmitirNFCe;
var
  ACBrNFCe: TACBrNFCe;
  Certificado: TACBrCertificado;
begin
  ACBrNFCe := TACBrNFCe.Create(nil);
  try
    { Configurar certificado }
    Certificado := TACBrCertificado.Create;
    Certificado.ArquivoPFX := 'certificado.pfx';
    Certificado.Senha := 'senha123';
    ACBrNFCe.Certificado := Certificado;
    
    { Configurar ambiente }
    ACBrNFCe.ConfiguracaoWebServices.Ambiente := taHomologacao; // ou taProducao
    ACBrNFCe.ConfiguracaoWebServices.UF := 'SP';
    
    { Montar NFCe }
    ACBrNFCe.NotasFiscais.Clear;
    with ACBrNFCe.NotasFiscais.Add.NFCe do
    begin
      Infra.ID := 'NFCe35240101234567000123550010000000011234567890';
      Infra.Versao := '4.00';
      { ... adicionar itens ... }
    end;
    
    { Enviar }
    ACBrNFCe.Enviar;
    
    if ACBrNFCe.WebServices.Autorizacao.Resposta.cStat = 100 then
      ShowMessage('NFCe autorizada: ' + ACBrNFCe.WebServices.Autorizacao.Resposta.chNFe)
    else
      ShowMessage('Erro: ' + ACBrNFCe.WebServices.Autorizacao.Resposta.xMotivo);
  finally
    Certificado.Free;
    ACBrNFCe.Free;
  end;
end;
```

---

## ✅ Conclusão

O próximo módulo essencial é o **Sistema de Emissão de NFCe (SENF)** que garante:

1. ✅ Conformidade com legislação fiscal brasileira
2. ✅ Emissão de Notas Fiscais do Consumidor Eletrônicas (NFCe)
3. ✅ Integração com SEFAZ
4. ✅ Rastreabilidade completa
5. ✅ Auditoria profissional
6. ✅ Segurança através de assinatura digital
7. ✅ Futuro garantido (NFCe não será descontinuada)

**Estimativa de Implementação**: 8 semanas com equipe de 2 desenvolvedores

**Prioridade**: 🔴 **CRÍTICA** - Sem este módulo, o PDV não pode ser usado em produção no Brasil

**Diferencial**: Ao implementar NFCe agora, o PDV Seenaxon estará preparado para o futuro, enquanto sistemas baseados em SAT precisarão ser refeitos em 2026.
