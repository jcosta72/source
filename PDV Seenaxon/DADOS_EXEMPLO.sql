-- ============================================================================
-- PDV SEENAXON - DADOS DE EXEMPLO PARA TESTES
-- ============================================================================
-- Script para popular as tabelas com dados de teste
-- Versão: 1.0
-- Data: 2025-12-28
-- ============================================================================

-- ============================================================================
-- INSERIR OPERADORES DE TESTE
-- ============================================================================
-- Senhas criptografadas com PBKDF2 (10.000 iterações)
-- Formato: salt:hash
-- 
-- Para gerar novos hashes, use a classe TCriptografiaSenha
-- Exemplo de senhas: 1234, 5678, 9012, 3456

INSERT OR IGNORE INTO Operadores (Nome, Matricula, SenhaHash, Email, Telefone, Ativo)
VALUES 
  (
    'MARCOS SILVA DE MATOS',
    '001',
    'a1b2c3d4e5f6g7h8:hash_pbkdf2_senha_1234',  -- Senha: 1234
    'marcos@pdvseenaxon.com',
    '(11) 98765-4321',
    1
  ),
  (
    'JOÃO SANTOS',
    '002',
    'b2c3d4e5f6g7h8i9:hash_pbkdf2_senha_5678',  -- Senha: 5678
    'joao@pdvseenaxon.com',
    '(11) 98765-4322',
    1
  ),
  (
    'MARIA OLIVEIRA',
    '003',
    'c3d4e5f6g7h8i9j0:hash_pbkdf2_senha_9012',  -- Senha: 9012
    'maria@pdvseenaxon.com',
    '(11) 98765-4323',
    1
  ),
  (
    'PEDRO COSTA',
    '004',
    'd4e5f6g7h8i9j0k1:hash_pbkdf2_senha_3456',  -- Senha: 3456
    'pedro@pdvseenaxon.com',
    '(11) 98765-4324',
    1
  ),
  (
    'ANA FERREIRA',
    '005',
    'e5f6g7h8i9j0k1l2:hash_pbkdf2_senha_7890',  -- Senha: 7890
    'ana@pdvseenaxon.com',
    '(11) 98765-4325',
    1
  );

-- ============================================================================
-- INSERIR PRODUTOS DE TESTE
-- ============================================================================
-- Categoria: BEBIDAS
INSERT OR IGNORE INTO Produtos (CodigoBarras, Nome, Categoria, Preco, PrecoCusto, QuantidadeEstoque, QuantidadeMinima, Ativo)
VALUES 
  ('7891234567890', 'CAFÉ 500G', 'BEBIDAS', 12.50, 8.00, 150, 20, 1),
  ('7891234567891', 'CHÁ PRETO 100 SACHÊS', 'BEBIDAS', 8.90, 5.50, 200, 30, 1),
  ('7891234567892', 'LEITE INTEGRAL 1L', 'BEBIDAS', 4.50, 2.80, 300, 50, 1),
  ('7891234567893', 'LEITE DESNATADO 1L', 'BEBIDAS', 4.30, 2.60, 250, 40, 1),
  ('7891234567894', 'SUCO NATURAL LARANJA 1L', 'BEBIDAS', 6.50, 3.50, 180, 25, 1);

-- Categoria: ALIMENTOS
INSERT OR IGNORE INTO Produtos (CodigoBarras, Nome, Categoria, Preco, PrecoCusto, QuantidadeEstoque, QuantidadeMinima, Ativo)
VALUES 
  ('7891234567895', 'PÃO FRANCÊS', 'ALIMENTOS', 0.50, 0.20, 1000, 100, 1),
  ('7891234567896', 'PÃO DE QUEIJO 400G', 'ALIMENTOS', 8.50, 4.50, 120, 20, 1),
  ('7891234567897', 'BOLO DE CHOCOLATE 500G', 'ALIMENTOS', 15.90, 8.00, 80, 15, 1),
  ('7891234567898', 'BISCOITO ÁGUA E SAL 400G', 'ALIMENTOS', 3.50, 1.80, 250, 40, 1),
  ('7891234567899', 'AÇÚCAR 1KG', 'ALIMENTOS', 4.20, 2.50, 200, 30, 1);

-- Categoria: LATICÍNIOS
INSERT OR IGNORE INTO Produtos (CodigoBarras, Nome, Categoria, Preco, PrecoCusto, QuantidadeEstoque, QuantidadeMinima, Ativo)
VALUES 
  ('7891234567900', 'QUEIJO MEIA CURA 500G', 'LATICÍNIOS', 25.00, 14.00, 80, 15, 1),
  ('7891234567901', 'QUEIJO PRATO 500G', 'LATICÍNIOS', 22.50, 12.50, 90, 15, 1),
  ('7891234567902', 'MANTEIGA 200G', 'LATICÍNIOS', 12.80, 7.50, 120, 20, 1),
  ('7891234567903', 'IOGURTE NATURAL 500G', 'LATICÍNIOS', 6.50, 3.50, 200, 30, 1),
  ('7891234567904', 'REQUEIJÃO 220G', 'LATICÍNIOS', 8.90, 4.80, 150, 25, 1);

-- Categoria: EMBUTIDOS
INSERT OR IGNORE INTO Produtos (CodigoBarras, Nome, Categoria, Preco, PrecoCusto, QuantidadeEstoque, QuantidadeMinima, Ativo)
VALUES 
  ('7891234567905', 'PRESUNTO 500G', 'EMBUTIDOS', 18.00, 9.50, 100, 15, 1),
  ('7891234567906', 'MORTADELA 500G', 'EMBUTIDOS', 16.50, 8.50, 120, 20, 1),
  ('7891234567907', 'SALSICHA 500G', 'EMBUTIDOS', 12.90, 6.50, 150, 25, 1),
  ('7891234567908', 'BACON 250G', 'EMBUTIDOS', 22.50, 12.00, 80, 15, 1),
  ('7891234567909', 'LINGUIÇA FRESCA 500G', 'EMBUTIDOS', 24.00, 13.00, 70, 12, 1);

-- Categoria: FRUTAS E VERDURAS
INSERT OR IGNORE INTO Produtos (CodigoBarras, Nome, Categoria, Preco, PrecoCusto, QuantidadeEstoque, QuantidadeMinima, Ativo)
VALUES 
  ('7891234567910', 'MAÇÃ FUJI 1KG', 'FRUTAS E VERDURAS', 8.50, 4.50, 200, 30, 1),
  ('7891234567911', 'BANANA PRATA 1KG', 'FRUTAS E VERDURAS', 4.50, 2.00, 300, 50, 1),
  ('7891234567912', 'TOMATE 1KG', 'FRUTAS E VERDURAS', 6.90, 3.50, 180, 25, 1),
  ('7891234567913', 'ALFACE 1 UNIDADE', 'FRUTAS E VERDURAS', 2.50, 1.00, 250, 40, 1),
  ('7891234567914', 'CEBOLA 1KG', 'FRUTAS E VERDURAS', 3.50, 1.50, 220, 35, 1);

-- Categoria: CONGELADOS
INSERT OR IGNORE INTO Produtos (CodigoBarras, Nome, Categoria, Preco, PrecoCusto, QuantidadeEstoque, QuantidadeMinima, Ativo)
VALUES 
  ('7891234567915', 'FRANGO CONGELADO 1KG', 'CONGELADOS', 18.50, 10.00, 150, 25, 1),
  ('7891234567916', 'CARNE MOÍDA 500G', 'CONGELADOS', 22.00, 12.00, 120, 20, 1),
  ('7891234567917', 'PEIXE CONGELADO 500G', 'CONGELADOS', 28.50, 15.00, 80, 15, 1),
  ('7891234567918', 'PIZZA CONGELADA 400G', 'CONGELADOS', 12.90, 6.50, 200, 30, 1),
  ('7891234567919', 'BATATA FRITA CONGELADA 500G', 'CONGELADOS', 8.90, 4.50, 180, 25, 1);

-- ============================================================================
-- INSERIR CLIENTES DE TESTE
-- ============================================================================
INSERT OR IGNORE INTO Clientes (Nome, CPF, Email, Telefone, Endereco, Cidade, Estado, CEP, Ativo, ConsentimentoLGPD)
VALUES 
  ('CLIENTE TESTE 1', '12345678901', 'cliente1@example.com', '(11) 98765-4321', 'Rua A, 123', 'São Paulo', 'SP', '01234-567', 1, 1),
  ('CLIENTE TESTE 2', '12345678902', 'cliente2@example.com', '(11) 98765-4322', 'Rua B, 456', 'São Paulo', 'SP', '01234-568', 1, 1),
  ('CLIENTE TESTE 3', '12345678903', 'cliente3@example.com', '(11) 98765-4323', 'Rua C, 789', 'São Paulo', 'SP', '01234-569', 1, 1);

-- ============================================================================
-- INSERIR CAIXA DE TESTE
-- ============================================================================
INSERT OR IGNORE INTO Caixas (OperadorID, NumeroSerie, SaldoInicial, Status)
VALUES 
  (1, 'ECF001', 500.00, 'ABERTO');

-- ============================================================================
-- INSERIR VENDAS DE TESTE
-- ============================================================================
-- Venda 1: Múltiplos produtos
INSERT OR IGNORE INTO Vendas (CaixaID, OperadorID, Subtotal, Desconto, Total, FormaPagamento, DataVenda)
VALUES 
  (1, 1, 150.00, 15.00, 135.00, 'DINHEIRO', datetime('now', '-1 day'));

-- Itens da Venda 1
INSERT OR IGNORE INTO ItensVenda (VendaID, ProdutoID, Quantidade, ValorUnitario, Total)
VALUES 
  (1, 1, 2, 12.50, 25.00),  -- CAFÉ 500G
  (1, 3, 3, 4.50, 13.50),   -- LEITE INTEGRAL 1L
  (1, 11, 1, 25.00, 25.00); -- QUEIJO MEIA CURA 500G

-- Venda 2: Pagamento em cartão
INSERT OR IGNORE INTO Vendas (CaixaID, OperadorID, Subtotal, Acrescimo, Total, FormaPagamento, DataVenda)
VALUES 
  (1, 2, 200.00, 10.00, 210.00, 'CARTAO', datetime('now', '-1 day'));

-- Itens da Venda 2
INSERT OR IGNORE INTO ItensVenda (VendaID, ProdutoID, Quantidade, ValorUnitario, Total)
VALUES 
  (2, 16, 1, 18.50, 18.50),  -- FRANGO CONGELADO 1KG
  (2, 12, 1, 22.50, 22.50),  -- QUEIJO PRATO 500G
  (2, 9, 5, 3.50, 17.50);    -- BISCOITO ÁGUA E SAL 400G

-- Venda 3: Pagamento em PIX
INSERT OR IGNORE INTO Vendas (CaixaID, OperadorID, Subtotal, Total, FormaPagamento, DataVenda)
VALUES 
  (1, 3, 85.00, 85.00, 'PIX', datetime('now'));

-- Itens da Venda 3
INSERT OR IGNORE INTO ItensVenda (VendaID, ProdutoID, Quantidade, ValorUnitario, Total)
VALUES 
  (3, 6, 10, 0.50, 5.00),    -- PÃO FRANCÊS
  (3, 7, 2, 8.50, 17.00),    -- PÃO DE QUEIJO 400G
  (3, 8, 1, 15.90, 15.90);   -- BOLO DE CHOCOLATE 500G

-- ============================================================================
-- INSERIR LOGS DE TESTE
-- ============================================================================
-- Log de auditoria
INSERT OR IGNORE INTO LogAuditoria (OperadorID, TipoOperacao, Tabela, RegistroID, AcaoRealizada, Detalhes, Sucesso)
VALUES 
  (1, 'LOGIN', 'Operadores', 1, 'LOGIN', 'Login bem-sucedido', 1),
  (1, 'VENDA', 'Vendas', 1, 'INSERT', 'Venda registrada', 1),
  (2, 'LOGIN', 'Operadores', 2, 'LOGIN', 'Login bem-sucedido', 1),
  (2, 'VENDA', 'Vendas', 2, 'INSERT', 'Venda registrada', 1);

-- Log de acesso
INSERT OR IGNORE INTO LogAcessoOperador (OperadorID, Matricula, Sucesso, Motivo)
VALUES 
  (1, '001', 1, 'LOGIN_SUCESSO'),
  (2, '002', 1, 'LOGIN_SUCESSO'),
  (3, '003', 1, 'LOGIN_SUCESSO');

-- ============================================================================
-- VERIFICAR DADOS INSERIDOS
-- ============================================================================
-- Descomente as queries abaixo para verificar os dados

-- SELECT COUNT(*) as TotalOperadores FROM Operadores;
-- SELECT COUNT(*) as TotalProdutos FROM Produtos;
-- SELECT COUNT(*) as TotalVendas FROM Vendas;
-- SELECT COUNT(*) as TotalItensVenda FROM ItensVenda;

-- SELECT * FROM Operadores;
-- SELECT * FROM Produtos WHERE Categoria = 'BEBIDAS';
-- SELECT * FROM Vendas;
-- SELECT * FROM ItensVenda;

-- ============================================================================
-- FIM DO SCRIPT DE DADOS DE EXEMPLO
-- ============================================================================
