-- ============================================================================
-- SCRIPT DE CRIAÇÃO DE TABELAS PARA PERSISTÊNCIA DE CAIXAS
-- ============================================================================
-- Banco de Dados: SQLite
-- Descrição: Tabelas para gerenciamento de caixas, movimentações e fechamentos
-- Data: 28/12/2025
-- ============================================================================

-- ============================================================================
-- TABELA: Caixas
-- ============================================================================
-- Descrição: Armazena informações de cada caixa aberto/fechado
-- Relacionamentos: Operadores (FK), Vendas (FK), Movimentacoes (FK)

CREATE TABLE IF NOT EXISTS Caixas (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  OperadorID INTEGER NOT NULL,
  DataAbertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  DataFechamento DATETIME,
  SaldoInicial REAL NOT NULL DEFAULT 0.00,
  SaldoFinal REAL,
  TotalVendas REAL DEFAULT 0.00,
  TotalDesconto REAL DEFAULT 0.00,
  TotalAcrescimo REAL DEFAULT 0.00,
  TotalSangria REAL DEFAULT 0.00,
  TotalSuprimento REAL DEFAULT 0.00,
  QuantidadeVendas INTEGER DEFAULT 0,
  QuantidadeProdutos INTEGER DEFAULT 0,
  ValorMedioVenda REAL DEFAULT 0.00,
  MaiorVenda REAL DEFAULT 0.00,
  MenorVenda REAL DEFAULT 0.00,
  TotalDinheiro REAL DEFAULT 0.00,
  TotalCartao REAL DEFAULT 0.00,
  TotalPIX REAL DEFAULT 0.00,
  Diferenca REAL,
  Status TEXT DEFAULT 'Aberto' CHECK(Status IN ('Aberto', 'Fechando', 'Fechado', 'Cancelado')),
  Observacoes TEXT,
  DataCriacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  DataAtualizacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (OperadorID) REFERENCES Operadores(ID) ON DELETE RESTRICT
);

-- Índices para Caixas
CREATE INDEX IF NOT EXISTS idx_caixas_operador ON Caixas(OperadorID);
CREATE INDEX IF NOT EXISTS idx_caixas_data_abertura ON Caixas(DataAbertura);
CREATE INDEX IF NOT EXISTS idx_caixas_status ON Caixas(Status);
CREATE INDEX IF NOT EXISTS idx_caixas_data_fechamento ON Caixas(DataFechamento);
CREATE INDEX IF NOT EXISTS idx_caixas_intervalo_data ON Caixas(DataAbertura, DataFechamento);

-- ============================================================================
-- TABELA: Movimentacoes
-- ============================================================================
-- Descrição: Armazena sangrias e suprimentos de cada caixa
-- Relacionamentos: Caixas (FK), Operadores (FK)

CREATE TABLE IF NOT EXISTS Movimentacoes (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  CaixaID INTEGER NOT NULL,
  OperadorID INTEGER NOT NULL,
  Tipo TEXT NOT NULL CHECK(Tipo IN ('Sangria', 'Suprimento')),
  Valor REAL NOT NULL,
  Data DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Motivo TEXT,
  Observacoes TEXT,
  DataCriacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (CaixaID) REFERENCES Caixas(ID) ON DELETE CASCADE,
  FOREIGN KEY (OperadorID) REFERENCES Operadores(ID) ON DELETE RESTRICT
);

-- Índices para Movimentacoes
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa ON Movimentacoes(CaixaID);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_operador ON Movimentacoes(OperadorID);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_tipo ON Movimentacoes(Tipo);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_data ON Movimentacoes(Data);
CREATE INDEX IF NOT EXISTS idx_movimentacoes_caixa_tipo ON Movimentacoes(CaixaID, Tipo);

-- ============================================================================
-- TABELA: Fechamentos
-- ============================================================================
-- Descrição: Armazena histórico de fechamentos de caixa com resumo completo
-- Relacionamentos: Caixas (FK), Operadores (FK)

CREATE TABLE IF NOT EXISTS Fechamentos (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  CaixaID INTEGER NOT NULL UNIQUE,
  OperadorID INTEGER NOT NULL,
  DataFechamento DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  SaldoInicial REAL NOT NULL,
  SaldoFinal REAL NOT NULL,
  Diferenca REAL NOT NULL,
  TotalVendas REAL NOT NULL,
  TotalDesconto REAL NOT NULL,
  TotalAcrescimo REAL NOT NULL,
  TotalSangria REAL NOT NULL,
  TotalSuprimento REAL NOT NULL,
  TotalDinheiro REAL NOT NULL,
  TotalCartao REAL NOT NULL,
  TotalPIX REAL NOT NULL,
  QuantidadeVendas INTEGER NOT NULL,
  QuantidadeProdutos INTEGER NOT NULL,
  QuantidadeSangrias INTEGER NOT NULL,
  QuantidadeSuprimentos INTEGER NOT NULL,
  Observacoes TEXT,
  Assinado BOOLEAN DEFAULT 0,
  DataAssinatura DATETIME,
  OperadorAssinatura INTEGER,
  DataCriacao DATETIME DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (CaixaID) REFERENCES Caixas(ID) ON DELETE RESTRICT,
  FOREIGN KEY (OperadorID) REFERENCES Operadores(ID) ON DELETE RESTRICT,
  FOREIGN KEY (OperadorAssinatura) REFERENCES Operadores(ID) ON DELETE SET NULL
);

-- Índices para Fechamentos
CREATE INDEX IF NOT EXISTS idx_fechamentos_caixa ON Fechamentos(CaixaID);
CREATE INDEX IF NOT EXISTS idx_fechamentos_operador ON Fechamentos(OperadorID);
CREATE INDEX IF NOT EXISTS idx_fechamentos_data ON Fechamentos(DataFechamento);
CREATE INDEX IF NOT EXISTS idx_fechamentos_assinado ON Fechamentos(Assinado);
CREATE INDEX IF NOT EXISTS idx_fechamentos_intervalo_data ON Fechamentos(DataFechamento);

-- ============================================================================
-- TABELA: VendasCaixa (Relação entre Vendas e Caixas)
-- ============================================================================
-- Descrição: Relaciona vendas com o caixa em que foram realizadas
-- Relacionamentos: Vendas (FK), Caixas (FK)

CREATE TABLE IF NOT EXISTS VendasCaixa (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  VendaID INTEGER NOT NULL,
  CaixaID INTEGER NOT NULL,
  DataVenda DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (VendaID) REFERENCES Vendas(ID) ON DELETE CASCADE,
  FOREIGN KEY (CaixaID) REFERENCES Caixas(ID) ON DELETE CASCADE,
  UNIQUE(VendaID, CaixaID)
);

-- Índices para VendasCaixa
CREATE INDEX IF NOT EXISTS idx_vendas_caixa_venda ON VendasCaixa(VendaID);
CREATE INDEX IF NOT EXISTS idx_vendas_caixa_caixa ON VendasCaixa(CaixaID);

-- ============================================================================
-- TRIGGERS PARA AUDITORIA
-- ============================================================================

-- Trigger para atualizar DataAtualizacao em Caixas
CREATE TRIGGER IF NOT EXISTS trg_caixas_update_timestamp
AFTER UPDATE ON Caixas
BEGIN
  UPDATE Caixas SET DataAtualizacao = CURRENT_TIMESTAMP
  WHERE ID = NEW.ID;
END;

-- Trigger para validar Movimentacoes
CREATE TRIGGER IF NOT EXISTS trg_movimentacoes_validar
BEFORE INSERT ON Movimentacoes
BEGIN
  SELECT CASE
    WHEN NEW.Valor <= 0 THEN
      RAISE(ABORT, 'Valor da movimentação deve ser positivo')
    WHEN NEW.Tipo NOT IN ('Sangria', 'Suprimento') THEN
      RAISE(ABORT, 'Tipo de movimentação inválido')
    WHEN (SELECT Status FROM Caixas WHERE ID = NEW.CaixaID) != 'Aberto' THEN
      RAISE(ABORT, 'Caixa não está aberto')
  END;
END;

-- ============================================================================
-- VIEWS PARA CONSULTAS COMUNS
-- ============================================================================

-- View: Caixas Abertos
CREATE VIEW IF NOT EXISTS vw_caixas_abertos AS
SELECT 
  c.ID,
  c.OperadorID,
  o.Nome AS OperadorNome,
  c.DataAbertura,
  c.SaldoInicial,
  c.TotalVendas,
  c.TotalDesconto,
  c.TotalAcrescimo,
  c.TotalSangria,
  c.TotalSuprimento,
  (c.SaldoInicial + c.TotalVendas - c.TotalSangria + c.TotalSuprimento) AS SaldoAtual,
  c.QuantidadeVendas,
  c.Status
FROM Caixas c
LEFT JOIN Operadores o ON c.OperadorID = o.ID
WHERE c.Status = 'Aberto'
ORDER BY c.DataAbertura DESC;

-- View: Caixas Fechados
CREATE VIEW IF NOT EXISTS vw_caixas_fechados AS
SELECT 
  c.ID,
  c.OperadorID,
  o.Nome AS OperadorNome,
  c.DataAbertura,
  c.DataFechamento,
  c.SaldoInicial,
  c.SaldoFinal,
  c.Diferenca,
  c.TotalVendas,
  c.TotalDesconto,
  c.TotalAcrescimo,
  c.TotalSangria,
  c.TotalSuprimento,
  c.QuantidadeVendas,
  c.Status
FROM Caixas c
LEFT JOIN Operadores o ON c.OperadorID = o.ID
WHERE c.Status = 'Fechado'
ORDER BY c.DataFechamento DESC;

-- View: Movimentações por Caixa
CREATE VIEW IF NOT EXISTS vw_movimentacoes_por_caixa AS
SELECT 
  m.ID,
  m.CaixaID,
  m.OperadorID,
  o.Nome AS OperadorNome,
  m.Tipo,
  m.Valor,
  m.Data,
  m.Motivo,
  CASE WHEN m.Tipo = 'Sangria' THEN -m.Valor ELSE m.Valor END AS ValorComSinal
FROM Movimentacoes m
LEFT JOIN Operadores o ON m.OperadorID = o.ID
ORDER BY m.CaixaID, m.Data;

-- View: Resumo de Caixas por Operador
CREATE VIEW IF NOT EXISTS vw_resumo_caixas_operador AS
SELECT 
  c.OperadorID,
  o.Nome AS OperadorNome,
  COUNT(c.ID) AS TotalCaixas,
  SUM(CASE WHEN c.Status = 'Aberto' THEN 1 ELSE 0 END) AS CaixasAbertos,
  SUM(CASE WHEN c.Status = 'Fechado' THEN 1 ELSE 0 END) AS CaixasFechados,
  SUM(c.TotalVendas) AS TotalVendas,
  SUM(c.TotalDesconto) AS TotalDesconto,
  SUM(c.TotalAcrescimo) AS TotalAcrescimo,
  SUM(c.TotalSangria) AS TotalSangria,
  SUM(c.TotalSuprimento) AS TotalSuprimento,
  SUM(c.Diferenca) AS TotalDiferenca,
  AVG(c.Diferenca) AS DiferencaMedia
FROM Caixas c
LEFT JOIN Operadores o ON c.OperadorID = o.ID
GROUP BY c.OperadorID, o.Nome
ORDER BY SUM(c.TotalVendas) DESC;

-- View: Resumo Geral de Caixas
CREATE VIEW IF NOT EXISTS vw_resumo_geral_caixas AS
SELECT 
  COUNT(ID) AS TotalCaixas,
  SUM(CASE WHEN Status = 'Aberto' THEN 1 ELSE 0 END) AS CaixasAbertos,
  SUM(CASE WHEN Status = 'Fechado' THEN 1 ELSE 0 END) AS CaixasFechados,
  SUM(TotalVendas) AS TotalVendas,
  SUM(TotalDesconto) AS TotalDesconto,
  SUM(TotalAcrescimo) AS TotalAcrescimo,
  SUM(TotalSangria) AS TotalSangria,
  SUM(TotalSuprimento) AS TotalSuprimento,
  SUM(Diferenca) AS TotalDiferenca,
  AVG(Diferenca) AS DiferencaMedia,
  MAX(SaldoFinal) AS MaiorSaldo,
  MIN(SaldoFinal) AS MenorSaldo
FROM Caixas
WHERE Status = 'Fechado';

-- ============================================================================
-- PROCEDIMENTOS ARMAZENADOS (Simulados com Views)
-- ============================================================================

-- Função: Obter Saldo Atual do Caixa
-- SELECT (SaldoInicial + TotalVendas - TotalSangria + TotalSuprimento) AS SaldoAtual
-- FROM Caixas WHERE ID = ?;

-- Função: Obter Diferença do Caixa
-- SELECT (SaldoFinal - SaldoInicial) AS Diferenca
-- FROM Caixas WHERE ID = ?;

-- ============================================================================
-- DADOS DE EXEMPLO
-- ============================================================================

-- Inserir caixa de exemplo (aberto)
INSERT OR IGNORE INTO Caixas (
  ID, OperadorID, DataAbertura, SaldoInicial, TotalVendas, 
  TotalDesconto, TotalAcrescimo, TotalSangria, TotalSuprimento,
  QuantidadeVendas, QuantidadeProdutos, TotalDinheiro, TotalCartao, TotalPIX, Status
) VALUES (
  1, 1, datetime('now', '-2 hours'), 500.00, 1250.00,
  50.00, 10.00, 100.00, 200.00,
  10, 25, 800.00, 300.00, 160.00, 'Aberto'
);

-- Inserir movimentações de exemplo
INSERT OR IGNORE INTO Movimentacoes (
  ID, CaixaID, OperadorID, Tipo, Valor, Data, Motivo
) VALUES 
  (1, 1, 1, 'Sangria', 100.00, datetime('now', '-1.5 hours'), 'Retirada para troco'),
  (2, 1, 1, 'Suprimento', 200.00, datetime('now', '-1 hour'), 'Suprimento do gerente'),
  (3, 1, 1, 'Sangria', 50.00, datetime('now', '-30 minutes'), 'Retirada para caixa pequeno');

-- Inserir caixa fechado de exemplo
INSERT OR IGNORE INTO Caixas (
  ID, OperadorID, DataAbertura, DataFechamento, SaldoInicial, SaldoFinal,
  TotalVendas, TotalDesconto, TotalAcrescimo, TotalSangria, TotalSuprimento,
  QuantidadeVendas, QuantidadeProdutos, Diferenca, Status
) VALUES (
  2, 1, datetime('now', '-1 day', '-2 hours'), datetime('now', '-1 day', '10 hours'),
  500.00, 1810.00, 1500.00, 75.00, 15.00, 200.00, 300.00,
  15, 35, 1310.00, 'Fechado'
);

-- Inserir fechamento de exemplo
INSERT OR IGNORE INTO Fechamentos (
  ID, CaixaID, OperadorID, DataFechamento, SaldoInicial, SaldoFinal,
  Diferenca, TotalVendas, TotalDesconto, TotalAcrescimo, TotalSangria, TotalSuprimento,
  TotalDinheiro, TotalCartao, TotalPIX, QuantidadeVendas, QuantidadeProdutos,
  QuantidadeSangrias, QuantidadeSuprimentos
) VALUES (
  1, 2, 1, datetime('now', '-1 day', '10 hours'), 500.00, 1810.00,
  1310.00, 1500.00, 75.00, 15.00, 200.00, 300.00,
  1000.00, 400.00, 100.00, 15, 35, 2, 1
);

-- ============================================================================
-- QUERIES ÚTEIS
-- ============================================================================

-- Consultar caixa aberto atual
-- SELECT * FROM vw_caixas_abertos LIMIT 1;

-- Consultar movimentações do caixa
-- SELECT * FROM vw_movimentacoes_por_caixa WHERE CaixaID = ?;

-- Consultar resumo de caixas por operador
-- SELECT * FROM vw_resumo_caixas_operador;

-- Consultar resumo geral
-- SELECT * FROM vw_resumo_geral_caixas;

-- Consultar caixas por data
-- SELECT * FROM Caixas WHERE DATE(DataAbertura) = DATE('now');

-- Consultar caixas por operador
-- SELECT * FROM Caixas WHERE OperadorID = ? ORDER BY DataAbertura DESC;

-- Consultar diferença de caixa
-- SELECT ID, SaldoInicial, SaldoFinal, Diferenca FROM Caixas WHERE ID = ?;

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
