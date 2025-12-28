-- ============================================================================
-- PDV SEENAXON - ESTRUTURA DE BANCO DE DADOS COMPLETA
-- ============================================================================
-- Sistema de Ponto de Venda em Delphi FMX com Segurança e Auditoria
-- Versão: 1.0
-- Data: 2025-12-28
-- ============================================================================

-- ============================================================================
-- TABELAS PRINCIPAIS
-- ============================================================================

-- ============================================================================
-- 1. TABELA: Operadores
-- Descrição: Armazena informações dos operadores do PDV
-- ============================================================================
CREATE TABLE IF NOT EXISTS Operadores (
  OperadorID INTEGER PRIMARY KEY AUTOINCREMENT,
  Nome TEXT NOT NULL,
  Matricula TEXT UNIQUE NOT NULL,
  SenhaHash TEXT NOT NULL,           -- Hash PBKDF2 (salt:hash)
  Email TEXT,
  Telefone TEXT,
  Ativo BOOLEAN DEFAULT 1,
  DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataUltimoAcesso DATETIME,
  TentativasLoginFalhadas INTEGER DEFAULT 0,
  BloqueadoAte DATETIME,             -- Para proteção contra força bruta
  
  CONSTRAINT chk_matricula_valida CHECK(LENGTH(Matricula) >= 3),
  CONSTRAINT chk_nome_valido CHECK(LENGTH(Nome) >= 3)
);

-- Índices para Operadores
CREATE INDEX IF NOT EXISTS idx_operadores_matricula ON Operadores(Matricula);
CREATE INDEX IF NOT EXISTS idx_operadores_ativo ON Operadores(Ativo);
CREATE INDEX IF NOT EXISTS idx_operadores_email ON Operadores(Email);

-- ============================================================================
-- 2. TABELA: Produtos
-- Descrição: Catálogo de produtos disponíveis para venda
-- ============================================================================
CREATE TABLE IF NOT EXISTS Produtos (
  ProdutoID INTEGER PRIMARY KEY AUTOINCREMENT,
  CodigoBarras TEXT UNIQUE,
  Nome TEXT NOT NULL,
  Descricao TEXT,
  Categoria TEXT,
  Preco REAL NOT NULL,
  PrecoCusto REAL,
  QuantidadeEstoque INTEGER DEFAULT 0,
  QuantidadeMinima INTEGER DEFAULT 10,
  Ativo BOOLEAN DEFAULT 1,
  ImagemPath TEXT,
  DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataAtualizacao DATETIME,
  
  CONSTRAINT chk_preco_valido CHECK(Preco >= 0),
  CONSTRAINT chk_nome_produto_valido CHECK(LENGTH(Nome) >= 2)
);

-- Índices para Produtos
CREATE INDEX IF NOT EXISTS idx_produtos_nome ON Produtos(Nome);
CREATE INDEX IF NOT EXISTS idx_produtos_categoria ON Produtos(Categoria);
CREATE INDEX IF NOT EXISTS idx_produtos_codigo_barras ON Produtos(CodigoBarras);
CREATE INDEX IF NOT EXISTS idx_produtos_ativo ON Produtos(Ativo);

-- ============================================================================
-- 3. TABELA: Caixas
-- Descrição: Registro de abertura e fechamento de caixas
-- ============================================================================
CREATE TABLE IF NOT EXISTS Caixas (
  CaixaID INTEGER PRIMARY KEY AUTOINCREMENT,
  OperadorID INTEGER NOT NULL,
  NumeroSerie TEXT,
  SaldoInicial REAL NOT NULL DEFAULT 0,
  SaldoFinal REAL,
  DataAbertura DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataFechamento DATETIME,
  Status TEXT DEFAULT 'ABERTO',           -- ABERTO, FECHADO, CANCELADO
  Observacoes TEXT,
  
  FOREIGN KEY (OperadorID) REFERENCES Operadores(OperadorID),
  CONSTRAINT chk_saldo_inicial_valido CHECK(SaldoInicial >= 0),
  CONSTRAINT chk_status_caixa CHECK(Status IN ('ABERTO', 'FECHADO', 'CANCELADO'))
);

-- Índices para Caixas
CREATE INDEX IF NOT EXISTS idx_caixas_operador ON Caixas(OperadorID);
CREATE INDEX IF NOT EXISTS idx_caixas_data_abertura ON Caixas(DataAbertura);
CREATE INDEX IF NOT EXISTS idx_caixas_status ON Caixas(Status);
CREATE INDEX IF NOT EXISTS idx_caixas_operador_data ON Caixas(OperadorID, DataAbertura);

-- ============================================================================
-- 4. TABELA: Vendas
-- Descrição: Registro de todas as vendas realizadas
-- ============================================================================
CREATE TABLE IF NOT EXISTS Vendas (
  VendaID INTEGER PRIMARY KEY AUTOINCREMENT,
  CaixaID INTEGER NOT NULL,
  OperadorID INTEGER NOT NULL,
  Subtotal REAL NOT NULL,
  Desconto REAL DEFAULT 0,
  DescontoPercentual REAL DEFAULT 0,
  Acrescimo REAL DEFAULT 0,
  AcrescimoPercentual REAL DEFAULT 0,
  Total REAL NOT NULL,
  FormaPagamento TEXT,                    -- DINHEIRO, CARTAO, PIX
  Troco REAL DEFAULT 0,
  ChaveNFe TEXT,                          -- Chave de acesso da NFe
  StatusNFe TEXT DEFAULT 'PENDENTE',      -- PENDENTE, AUTORIZADA, CANCELADA
  DataVenda DATETIME DEFAULT CURRENT_TIMESTAMP,
  Observacoes TEXT,
  
  FOREIGN KEY (CaixaID) REFERENCES Caixas(CaixaID),
  FOREIGN KEY (OperadorID) REFERENCES Operadores(OperadorID),
  CONSTRAINT chk_total_valido CHECK(Total >= 0),
  CONSTRAINT chk_forma_pagamento CHECK(FormaPagamento IN ('DINHEIRO', 'CARTAO', 'PIX')),
  CONSTRAINT chk_status_nfe CHECK(StatusNFe IN ('PENDENTE', 'AUTORIZADA', 'CANCELADA'))
);

-- Índices para Vendas
CREATE INDEX IF NOT EXISTS idx_vendas_caixa ON Vendas(CaixaID);
CREATE INDEX IF NOT EXISTS idx_vendas_operador ON Vendas(OperadorID);
CREATE INDEX IF NOT EXISTS idx_vendas_data ON Vendas(DataVenda);
CREATE INDEX IF NOT EXISTS idx_vendas_forma_pagamento ON Vendas(FormaPagamento);
CREATE INDEX IF NOT EXISTS idx_vendas_chave_nfe ON Vendas(ChaveNFe);
CREATE INDEX IF NOT EXISTS idx_vendas_operador_data ON Vendas(OperadorID, DataVenda);
CREATE INDEX IF NOT EXISTS idx_vendas_caixa_data ON Vendas(CaixaID, DataVenda);

-- ============================================================================
-- 5. TABELA: ItensVenda
-- Descrição: Itens individuais de cada venda
-- ============================================================================
CREATE TABLE IF NOT EXISTS ItensVenda (
  ItemID INTEGER PRIMARY KEY AUTOINCREMENT,
  VendaID INTEGER NOT NULL,
  ProdutoID INTEGER NOT NULL,
  Quantidade REAL NOT NULL,
  ValorUnitario REAL NOT NULL,
  Desconto REAL DEFAULT 0,
  DescontoPercentual REAL DEFAULT 0,
  Acrescimo REAL DEFAULT 0,
  AcrescimoPercentual REAL DEFAULT 0,
  Total REAL NOT NULL,
  
  FOREIGN KEY (VendaID) REFERENCES Vendas(VendaID) ON DELETE CASCADE,
  FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID),
  CONSTRAINT chk_quantidade_valida CHECK(Quantidade > 0),
  CONSTRAINT chk_valor_unitario_valido CHECK(ValorUnitario >= 0),
  CONSTRAINT chk_total_item_valido CHECK(Total >= 0)
);

-- Índices para ItensVenda
CREATE INDEX IF NOT EXISTS idx_itens_venda ON ItensVenda(VendaID);
CREATE INDEX IF NOT EXISTS idx_itens_produto ON ItensVenda(ProdutoID);

-- ============================================================================
-- 6. TABELA: Clientes (Opcional - para futuro)
-- Descrição: Dados de clientes para programa de fidelidade
-- ============================================================================
CREATE TABLE IF NOT EXISTS Clientes (
  ClienteID INTEGER PRIMARY KEY AUTOINCREMENT,
  Nome TEXT NOT NULL,
  CPF TEXT UNIQUE,                        -- Criptografado em produção
  CNPJ TEXT UNIQUE,                       -- Criptografado em produção
  Email TEXT,                             -- Criptografado em produção
  Telefone TEXT,                          -- Criptografado em produção
  Endereco TEXT,
  Cidade TEXT,
  Estado TEXT,
  CEP TEXT,
  DataNascimento DATE,
  Ativo BOOLEAN DEFAULT 1,
  ConsentimentoLGPD BOOLEAN DEFAULT 0,
  DataConsentimento DATETIME,
  DataCadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataUltimaCompra DATETIME,
  
  CONSTRAINT chk_nome_cliente_valido CHECK(LENGTH(Nome) >= 3)
);

-- Índices para Clientes
CREATE INDEX IF NOT EXISTS idx_clientes_cpf ON Clientes(CPF);
CREATE INDEX IF NOT EXISTS idx_clientes_cnpj ON Clientes(CNPJ);
CREATE INDEX IF NOT EXISTS idx_clientes_email ON Clientes(Email);
CREATE INDEX IF NOT EXISTS idx_clientes_ativo ON Clientes(Ativo);

-- ============================================================================
-- TABELAS DE AUDITORIA E SEGURANÇA
-- ============================================================================

-- ============================================================================
-- 7. TABELA: LogAuditoria
-- Descrição: Registro detalhado de todas as operações críticas
-- Criticidade: ALTA - Essencial para conformidade e segurança
-- ============================================================================
CREATE TABLE IF NOT EXISTS LogAuditoria (
  LogID INTEGER PRIMARY KEY AUTOINCREMENT,
  DataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
  OperadorID INTEGER,
  TipoOperacao TEXT NOT NULL,             -- LOGIN, LOGOUT, VENDA, DESCONTO, etc
  Tabela TEXT,                            -- Tabela afetada (Vendas, Operadores, etc)
  RegistroID INTEGER,                     -- ID do registro afetado
  AcaoRealizada TEXT NOT NULL,            -- Descrição da ação (INSERT, UPDATE, DELETE)
  DadosAntigos TEXT,                      -- JSON com dados anteriores (para UPDATE)
  DadosNovos TEXT,                        -- JSON com dados novos (para INSERT/UPDATE)
  Detalhes TEXT,                          -- Detalhes adicionais
  Sucesso BOOLEAN DEFAULT 1,
  MensagemErro TEXT,                      -- Se Sucesso = 0
  EnderecoIP TEXT,
  UserAgent TEXT,
  
  FOREIGN KEY (OperadorID) REFERENCES Operadores(OperadorID),
  CONSTRAINT chk_tipo_operacao CHECK(TipoOperacao IN (
    'LOGIN', 'LOGOUT', 'ACESSO_NEGADO', 'VENDA', 'DESCONTO', 'ACRESCIMO',
    'ABERTURA_CAIXA', 'FECHAMENTO_CAIXA', 'ALTERACAO_PRODUTO', 'ALTERACAO_OPERADOR',
    'CANCELAMENTO_VENDA', 'ERRO_SISTEMA'
  ))
);

-- Índices para LogAuditoria (CRÍTICOS para performance)
CREATE INDEX IF NOT EXISTS idx_log_data_hora ON LogAuditoria(DataHora);
CREATE INDEX IF NOT EXISTS idx_log_operador ON LogAuditoria(OperadorID);
CREATE INDEX IF NOT EXISTS idx_log_tipo_operacao ON LogAuditoria(TipoOperacao);
CREATE INDEX IF NOT EXISTS idx_log_tabela ON LogAuditoria(Tabela);
CREATE INDEX IF NOT EXISTS idx_log_operador_data ON LogAuditoria(OperadorID, DataHora);
CREATE INDEX IF NOT EXISTS idx_log_tipo_data ON LogAuditoria(TipoOperacao, DataHora);

-- ============================================================================
-- 8. TABELA: LogAcessoOperador
-- Descrição: Registro de tentativas de login (sucesso e falha)
-- ============================================================================
CREATE TABLE IF NOT EXISTS LogAcessoOperador (
  AcessoID INTEGER PRIMARY KEY AUTOINCREMENT,
  OperadorID INTEGER,
  Matricula TEXT,
  DataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
  Sucesso BOOLEAN,
  Motivo TEXT,                           -- SENHA_INCORRETA, OPERADOR_INATIVO, etc
  EnderecoIP TEXT,
  UserAgent TEXT,
  
  FOREIGN KEY (OperadorID) REFERENCES Operadores(OperadorID),
  CONSTRAINT chk_acesso_sucesso CHECK(Sucesso IN (0, 1))
);

-- Índices para LogAcessoOperador
CREATE INDEX IF NOT EXISTS idx_acesso_operador ON LogAcessoOperador(OperadorID);
CREATE INDEX IF NOT EXISTS idx_acesso_data_hora ON LogAcessoOperador(DataHora);
CREATE INDEX IF NOT EXISTS idx_acesso_sucesso ON LogAcessoOperador(Sucesso);
CREATE INDEX IF NOT EXISTS idx_acesso_matricula ON LogAcessoOperador(Matricula);

-- ============================================================================
-- 9. TABELA: LogErroSistema
-- Descrição: Registro de erros e exceções do sistema
-- ============================================================================
CREATE TABLE IF NOT EXISTS LogErroSistema (
  ErroID INTEGER PRIMARY KEY AUTOINCREMENT,
  DataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
  OperadorID INTEGER,
  Modulo TEXT,                           -- Módulo onde ocorreu o erro
  Funcao TEXT,                           -- Função onde ocorreu o erro
  Mensagem TEXT NOT NULL,
  StackTrace TEXT,                       -- Rastreamento de pilha
  Severidade TEXT DEFAULT 'ERRO',        -- INFO, AVISO, ERRO, CRITICO
  Resolvido BOOLEAN DEFAULT 0,
  DataResolucao DATETIME,
  Observacoes TEXT,
  
  FOREIGN KEY (OperadorID) REFERENCES Operadores(OperadorID),
  CONSTRAINT chk_severidade CHECK(Severidade IN ('INFO', 'AVISO', 'ERRO', 'CRITICO'))
);

-- Índices para LogErroSistema
CREATE INDEX IF NOT EXISTS idx_erro_data_hora ON LogErroSistema(DataHora);
CREATE INDEX IF NOT EXISTS idx_erro_severidade ON LogErroSistema(Severidade);
CREATE INDEX IF NOT EXISTS idx_erro_resolvido ON LogErroSistema(Resolvido);
CREATE INDEX IF NOT EXISTS idx_erro_modulo ON LogErroSistema(Modulo);

-- ============================================================================
-- 10. TABELA: LogAlteracaoDados
-- Descrição: Rastreamento detalhado de alterações em dados sensíveis
-- ============================================================================
CREATE TABLE IF NOT EXISTS LogAlteracaoDados (
  AlteracaoID INTEGER PRIMARY KEY AUTOINCREMENT,
  DataHora DATETIME DEFAULT CURRENT_TIMESTAMP,
  OperadorID INTEGER NOT NULL,
  Tabela TEXT NOT NULL,                  -- Tabela alterada
  RegistroID INTEGER NOT NULL,           -- ID do registro alterado
  Campo TEXT NOT NULL,                   -- Campo alterado
  ValorAntigo TEXT,                      -- Valor anterior
  ValorNovo TEXT,                        -- Valor novo
  Motivo TEXT,                           -- Motivo da alteração
  
  FOREIGN KEY (OperadorID) REFERENCES Operadores(OperadorID),
  CONSTRAINT chk_tabela_alteracao CHECK(Tabela IN (
    'Operadores', 'Produtos', 'Vendas', 'Clientes', 'Caixas'
  ))
);

-- Índices para LogAlteracaoDados
CREATE INDEX IF NOT EXISTS idx_alteracao_data_hora ON LogAlteracaoDados(DataHora);
CREATE INDEX IF NOT EXISTS idx_alteracao_operador ON LogAlteracaoDados(OperadorID);
CREATE INDEX IF NOT EXISTS idx_alteracao_tabela ON LogAlteracaoDados(Tabela);
CREATE INDEX IF NOT EXISTS idx_alteracao_registro ON LogAlteracaoDados(Tabela, RegistroID);

-- ============================================================================
-- TABELAS DE CONFORMIDADE E PRIVACIDADE
-- ============================================================================

-- ============================================================================
-- 11. TABELA: ConsentimentoLGPD
-- Descrição: Registro de consentimento de clientes conforme LGPD
-- ============================================================================
CREATE TABLE IF NOT EXISTS ConsentimentoLGPD (
  ConsentimentoID INTEGER PRIMARY KEY AUTOINCREMENT,
  ClienteID INTEGER,
  DataConsentimento DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataRevogacao DATETIME,
  Consentimento BOOLEAN NOT NULL,
  TipoConsentimento TEXT,                -- MARKETING, DADOS_PESSOAIS, etc
  Versao TEXT,                           -- Versão da política de privacidade
  
  FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

-- Índices para ConsentimentoLGPD
CREATE INDEX IF NOT EXISTS idx_consentimento_cliente ON ConsentimentoLGPD(ClienteID);
CREATE INDEX IF NOT EXISTS idx_consentimento_data ON ConsentimentoLGPD(DataConsentimento);

-- ============================================================================
-- 12. TABELA: SolicitacaoLGPD
-- Descrição: Registro de solicitações de acesso/exclusão de dados (LGPD)
-- ============================================================================
CREATE TABLE IF NOT EXISTS SolicitacaoLGPD (
  SolicitacaoID INTEGER PRIMARY KEY AUTOINCREMENT,
  ClienteID INTEGER,
  DataSolicitacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  TipoSolicitacao TEXT NOT NULL,         -- ACESSO, EXCLUSAO, PORTABILIDADE, CORRECAO
  Status TEXT DEFAULT 'PENDENTE',        -- PENDENTE, PROCESSANDO, CONCLUIDA, RECUSADA
  DataProcessamento DATETIME,
  Resposta TEXT,                         -- Resposta ou motivo da recusa
  
  FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID),
  CONSTRAINT chk_tipo_solicitacao CHECK(TipoSolicitacao IN (
    'ACESSO', 'EXCLUSAO', 'PORTABILIDADE', 'CORRECAO'
  )),
  CONSTRAINT chk_status_solicitacao CHECK(Status IN (
    'PENDENTE', 'PROCESSANDO', 'CONCLUIDA', 'RECUSADA'
  ))
);

-- Índices para SolicitacaoLGPD
CREATE INDEX IF NOT EXISTS idx_solicitacao_cliente ON SolicitacaoLGPD(ClienteID);
CREATE INDEX IF NOT EXISTS idx_solicitacao_tipo ON SolicitacaoLGPD(TipoSolicitacao);
CREATE INDEX IF NOT EXISTS idx_solicitacao_status ON SolicitacaoLGPD(Status);

-- ============================================================================
-- TABELAS DE SINCRONIZAÇÃO E BACKUP
-- ============================================================================

-- ============================================================================
-- 13. TABELA: SincronizacaoServidor
-- Descrição: Registro de sincronizações com servidor central
-- ============================================================================
CREATE TABLE IF NOT EXISTS SincronizacaoServidor (
  SincronizacaoID INTEGER PRIMARY KEY AUTOINCREMENT,
  DataSincronizacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  TipoSincronizacao TEXT,                -- VENDAS, PRODUTOS, OPERADORES
  RegistrosEnviados INTEGER DEFAULT 0,
  RegistrosRecebidos INTEGER DEFAULT 0,
  Status TEXT DEFAULT 'SUCESSO',         -- SUCESSO, FALHA, PARCIAL
  MensagemErro TEXT,
  TempoExecucao INTEGER,                 -- Em segundos
  
  CONSTRAINT chk_status_sincronizacao CHECK(Status IN ('SUCESSO', 'FALHA', 'PARCIAL'))
);

-- Índices para SincronizacaoServidor
CREATE INDEX IF NOT EXISTS idx_sincronizacao_data ON SincronizacaoServidor(DataSincronizacao);
CREATE INDEX IF NOT EXISTS idx_sincronizacao_tipo ON SincronizacaoServidor(TipoSincronizacao);
CREATE INDEX IF NOT EXISTS idx_sincronizacao_status ON SincronizacaoServidor(Status);

-- ============================================================================
-- 14. TABELA: VendasPendentes
-- Descrição: Vendas não sincronizadas com servidor
-- ============================================================================
CREATE TABLE IF NOT EXISTS VendasPendentes (
  VendaPendenteID INTEGER PRIMARY KEY AUTOINCREMENT,
  VendaID INTEGER NOT NULL,
  DataVenda DATETIME,
  Sincronizada BOOLEAN DEFAULT 0,
  DataSincronizacao DATETIME,
  TentativasSincronizacao INTEGER DEFAULT 0,
  UltimaTentativa DATETIME,
  
  FOREIGN KEY (VendaID) REFERENCES Vendas(VendaID)
);

-- Índices para VendasPendentes
CREATE INDEX IF NOT EXISTS idx_vendas_pendentes_sincronizada ON VendasPendentes(Sincronizada);
CREATE INDEX IF NOT EXISTS idx_vendas_pendentes_data ON VendasPendentes(DataVenda);

-- ============================================================================
-- 15. TABELA: HistoricoBackup
-- Descrição: Registro de backups realizados
-- ============================================================================
CREATE TABLE IF NOT EXISTS HistoricoBackup (
  BackupID INTEGER PRIMARY KEY AUTOINCREMENT,
  DataBackup DATETIME DEFAULT CURRENT_TIMESTAMP,
  TipoBackup TEXT,                       -- COMPLETO, INCREMENTAL
  Localizacao TEXT,                      -- Caminho ou URL do backup
  Tamanho INTEGER,                       -- Tamanho em bytes
  Status TEXT DEFAULT 'SUCESSO',         -- SUCESSO, FALHA
  MensagemErro TEXT,
  TempoExecucao INTEGER,                 -- Em segundos
  Verificado BOOLEAN DEFAULT 0,
  
  CONSTRAINT chk_tipo_backup CHECK(TipoBackup IN ('COMPLETO', 'INCREMENTAL')),
  CONSTRAINT chk_status_backup CHECK(Status IN ('SUCESSO', 'FALHA'))
);

-- Índices para HistoricoBackup
CREATE INDEX IF NOT EXISTS idx_backup_data ON HistoricoBackup(DataBackup);
CREATE INDEX IF NOT EXISTS idx_backup_tipo ON HistoricoBackup(TipoBackup);
CREATE INDEX IF NOT EXISTS idx_backup_status ON HistoricoBackup(Status);

-- ============================================================================
-- TABELAS DE CONFIGURAÇÃO
-- ============================================================================

-- ============================================================================
-- 16. TABELA: Configuracoes
-- Descrição: Configurações do sistema
-- ============================================================================
CREATE TABLE IF NOT EXISTS Configuracoes (
  ConfiguracaoID INTEGER PRIMARY KEY AUTOINCREMENT,
  Chave TEXT UNIQUE NOT NULL,
  Valor TEXT,
  Tipo TEXT,                             -- STRING, INTEGER, BOOLEAN, JSON
  Descricao TEXT,
  DataAtualizacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  CONSTRAINT chk_tipo_config CHECK(Tipo IN ('STRING', 'INTEGER', 'BOOLEAN', 'JSON'))
);

-- Índices para Configuracoes
CREATE INDEX IF NOT EXISTS idx_configuracoes_chave ON Configuracoes(Chave);

-- ============================================================================
-- VIEWS ÚTEIS PARA CONSULTAS
-- ============================================================================

-- ============================================================================
-- VIEW: VendasPorOperador
-- Descrição: Resumo de vendas por operador
-- ============================================================================
CREATE VIEW IF NOT EXISTS VendasPorOperador AS
SELECT 
  o.OperadorID,
  o.Nome,
  o.Matricula,
  COUNT(v.VendaID) as QuantidadeVendas,
  SUM(v.Total) as TotalVendas,
  AVG(v.Total) as TicketMedio,
  MIN(v.DataVenda) as PrimeiraVenda,
  MAX(v.DataVenda) as UltimaVenda
FROM Operadores o
LEFT JOIN Vendas v ON o.OperadorID = v.OperadorID
WHERE o.Ativo = 1
GROUP BY o.OperadorID, o.Nome, o.Matricula;

-- ============================================================================
-- VIEW: VendasPorFormaPagamento
-- Descrição: Resumo de vendas por forma de pagamento
-- ============================================================================
CREATE VIEW IF NOT EXISTS VendasPorFormaPagamento AS
SELECT 
  FormaPagamento,
  COUNT(VendaID) as QuantidadeVendas,
  SUM(Total) as TotalVendas,
  AVG(Total) as TicketMedio,
  MIN(DataVenda) as PrimeiraVenda,
  MAX(DataVenda) as UltimaVenda
FROM Vendas
GROUP BY FormaPagamento;

-- ============================================================================
-- VIEW: ProdutosComBaixoEstoque
-- Descrição: Produtos com estoque abaixo do mínimo
-- ============================================================================
CREATE VIEW IF NOT EXISTS ProdutosComBaixoEstoque AS
SELECT 
  ProdutoID,
  Nome,
  QuantidadeEstoque,
  QuantidadeMinima,
  (QuantidadeMinima - QuantidadeEstoque) as Diferenca
FROM Produtos
WHERE QuantidadeEstoque < QuantidadeMinima
AND Ativo = 1
ORDER BY Diferenca DESC;

-- ============================================================================
-- VIEW: RelatorioAuditoria
-- Descrição: Resumo de operações auditadas
-- ============================================================================
CREATE VIEW IF NOT EXISTS RelatorioAuditoria AS
SELECT 
  DATE(DataHora) as Data,
  TipoOperacao,
  COUNT(*) as Quantidade,
  SUM(CASE WHEN Sucesso = 1 THEN 1 ELSE 0 END) as Sucesso,
  SUM(CASE WHEN Sucesso = 0 THEN 1 ELSE 0 END) as Falha
FROM LogAuditoria
GROUP BY DATE(DataHora), TipoOperacao
ORDER BY Data DESC, TipoOperacao;

-- ============================================================================
-- DADOS INICIAIS
-- ============================================================================

-- Inserir operador padrão (senha: 1234 com PBKDF2)
INSERT OR IGNORE INTO Operadores (Nome, Matricula, SenhaHash, Email, Ativo)
VALUES (
  'ADMINISTRADOR',
  '001',
  'a1b2c3d4e5f6g7h8:hash_pbkdf2_aqui',  -- Substituir com hash real
  'admin@pdvseenaxon.com',
  1
);

-- Inserir produtos de teste
INSERT OR IGNORE INTO Produtos (CodigoBarras, Nome, Categoria, Preco, QuantidadeEstoque, Ativo)
VALUES 
  ('7891234567890', 'CAFÉ 500G', 'BEBIDAS', 12.50, 100, 1),
  ('7891234567891', 'PÃO FRANCÊS', 'ALIMENTOS', 0.50, 500, 1),
  ('7891234567892', 'LEITE 1L', 'LATICÍNIOS', 4.50, 200, 1),
  ('7891234567893', 'QUEIJO MEIA CURA', 'LATICÍNIOS', 25.00, 50, 1),
  ('7891234567894', 'PRESUNTO', 'EMBUTIDOS', 18.00, 75, 1);

-- ============================================================================
-- PROCEDIMENTOS ARMAZENADOS (Se suportado pelo banco)
-- ============================================================================

-- Nota: SQLite tem suporte limitado a procedimentos armazenados
-- Para funcionalidades mais avançadas, usar triggers

-- ============================================================================
-- TRIGGERS PARA AUDITORIA
-- ============================================================================

-- Trigger para registrar alterações em Vendas
CREATE TRIGGER IF NOT EXISTS trg_auditoria_vendas_insert
AFTER INSERT ON Vendas
BEGIN
  INSERT INTO LogAuditoria (
    OperadorID, TipoOperacao, Tabela, RegistroID, AcaoRealizada, DadosNovos, Sucesso
  ) VALUES (
    NEW.OperadorID,
    'VENDA',
    'Vendas',
    NEW.VendaID,
    'INSERT',
    json_object('Total', NEW.Total, 'FormaPagamento', NEW.FormaPagamento),
    1
  );
END;

-- Trigger para registrar alterações em Operadores
CREATE TRIGGER IF NOT EXISTS trg_auditoria_operadores_update
AFTER UPDATE ON Operadores
BEGIN
  INSERT INTO LogAuditoria (
    OperadorID, TipoOperacao, Tabela, RegistroID, AcaoRealizada, DadosAntigos, DadosNovos, Sucesso
  ) VALUES (
    NEW.OperadorID,
    'ALTERACAO_OPERADOR',
    'Operadores',
    NEW.OperadorID,
    'UPDATE',
    json_object('Nome', OLD.Nome, 'Email', OLD.Email),
    json_object('Nome', NEW.Nome, 'Email', NEW.Email),
    1
  );
END;

-- Trigger para registrar alterações em Produtos
CREATE TRIGGER IF NOT EXISTS trg_auditoria_produtos_update
AFTER UPDATE ON Produtos
BEGIN
  INSERT INTO LogAuditoria (
    TipoOperacao, Tabela, RegistroID, AcaoRealizada, DadosAntigos, DadosNovos, Sucesso
  ) VALUES (
    'ALTERACAO_PRODUTO',
    'Produtos',
    NEW.ProdutoID,
    'UPDATE',
    json_object('Nome', OLD.Nome, 'Preco', OLD.Preco),
    json_object('Nome', NEW.Nome, 'Preco', NEW.Preco),
    1
  );
END;

-- ============================================================================
-- FIM DA ESTRUTURA DE BANCO DE DADOS
-- ============================================================================
