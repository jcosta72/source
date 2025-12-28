unit uTestes;

interface

uses
  System.SysUtils,
  uProduto,
  uItemVenda,
  uVenda,
  uOperador,
  uCaixa,
  uRepositorioProdutos;

type
  TTestes = class
  public
    class procedure ExecutarTodos;
    class procedure TestarProduto;
    class procedure TestarItemVenda;
    class procedure TestarVenda;
    class procedure TestarOperador;
    class procedure TestarCaixa;
    class procedure TestarRepositorioProdutos;
  end;

implementation

class procedure TTestes.ExecutarTodos;
begin
  WriteLn('=== INICIANDO TESTES DO PDV ===');
  WriteLn('');
  
  TestarProduto;
  WriteLn('');
  
  TestarItemVenda;
  WriteLn('');
  
  TestarVenda;
  WriteLn('');
  
  TestarOperador;
  WriteLn('');
  
  TestarCaixa;
  WriteLn('');
  
  TestarRepositorioProdutos;
  WriteLn('');
  
  WriteLn('=== TESTES CONCLUÍDOS COM SUCESSO ===');
end;

class procedure TTestes.TestarProduto;
var
  Produto: TProduto;
begin
  WriteLn('--- Testando Classe TProduto ---');
  
  Produto := TProduto.Create(1, 'LIVRO', 'Livro de Ficção Científica', 29.90);
  try
    Assert(Produto.ID = 1, 'ID do produto incorreto');
    Assert(Produto.Nome = 'LIVRO', 'Nome do produto incorreto');
    Assert(Produto.Descricao = 'Livro de Ficção Científica', 'Descrição incorreta');
    Assert(Produto.Preco = 29.90, 'Preço do produto incorreto');
    
    WriteLn('✓ Produto criado corretamente');
    WriteLn('  ID: ' + IntToStr(Produto.ID));
    WriteLn('  Nome: ' + Produto.Nome);
    WriteLn('  Preço: R$ ' + FormatFloat('0.00', Produto.Preco));
  finally
    Produto.Free;
  end;
end;

class procedure TTestes.TestarItemVenda;
var
  Produto: TProduto;
  Item: TItemVenda;
begin
  WriteLn('--- Testando Classe TItemVenda ---');
  
  Produto := TProduto.Create(1, 'CANETA', 'Caneta Azul', 2.50);
  try
    Item := TItemVenda.Create(Produto, 3);
    try
      Assert(Item.Quantidade = 3, 'Quantidade incorreta');
      Assert(Item.ValorUnitario = 2.50, 'Valor unitário incorreto');
      Assert(Item.ValorTotal = 7.50, 'Valor total incorreto');
      
      WriteLn('✓ Item de venda criado corretamente');
      WriteLn('  Produto: ' + Item.Produto.Nome);
      WriteLn('  Quantidade: ' + FormatFloat('0', Item.Quantidade));
      WriteLn('  Valor Unitário: R$ ' + FormatFloat('0.00', Item.ValorUnitario));
      WriteLn('  Valor Total: R$ ' + FormatFloat('0.00', Item.ValorTotal));
      
      // Testa mudança de quantidade
      Item.SetQuantidade(5);
      Assert(Item.Quantidade = 5, 'Quantidade não foi atualizada');
      Assert(Item.ValorTotal = 12.50, 'Valor total não foi recalculado');
      WriteLn('✓ Quantidade atualizada corretamente');
      WriteLn('  Nova Quantidade: ' + FormatFloat('0', Item.Quantidade));
      WriteLn('  Novo Valor Total: R$ ' + FormatFloat('0.00', Item.ValorTotal));
    finally
      Item.Free;
    end;
  finally
    Produto.Free;
  end;
end;

class procedure TTestes.TestarVenda;
var
  Venda: TVenda;
  Produto1, Produto2: TProduto;
begin
  WriteLn('--- Testando Classe TVenda ---');
  
  Venda := TVenda.Create;
  try
    Produto1 := TProduto.Create(1, 'LIVRO', 'Livro', 10.00);
    Produto2 := TProduto.Create(2, 'CANETA', 'Caneta', 2.00);
    
    try
      // Testa adição de itens
      Venda.AdicionarItem(Produto1, 2);
      Venda.AdicionarItem(Produto2, 3);
      
      Assert(Venda.QuantidadeItens = 2, 'Quantidade de itens incorreta');
      Assert(Venda.Subtotal = 26.00, 'Subtotal incorreto');
      
      WriteLn('✓ Itens adicionados corretamente');
      WriteLn('  Quantidade de itens: ' + IntToStr(Venda.QuantidadeItens));
      WriteLn('  Subtotal: R$ ' + FormatFloat('0.00', Venda.Subtotal));
      
      // Testa desconto
      Venda.AplicarDesconto(5.00, False);
      Assert(Venda.Desconto = 5.00, 'Desconto não foi aplicado');
      Assert(Venda.Total = 21.00, 'Total com desconto incorreto');
      
      WriteLn('✓ Desconto aplicado corretamente');
      WriteLn('  Desconto: R$ ' + FormatFloat('0.00', Venda.Desconto));
      WriteLn('  Total com desconto: R$ ' + FormatFloat('0.00', Venda.Total));
      
      // Testa acréscimo
      Venda.AplicarAcrescimo(2.00, False);
      Assert(Venda.Acrescimo = 2.00, 'Acréscimo não foi aplicado');
      Assert(Venda.Total = 23.00, 'Total com acréscimo incorreto');
      
      WriteLn('✓ Acréscimo aplicado corretamente');
      WriteLn('  Acréscimo: R$ ' + FormatFloat('0.00', Venda.Acrescimo));
      WriteLn('  Total final: R$ ' + FormatFloat('0.00', Venda.Total));
      
      // Testa remoção de item
      Venda.RemoverItem(0);
      Assert(Venda.QuantidadeItens = 1, 'Item não foi removido');
      
      WriteLn('✓ Item removido corretamente');
      WriteLn('  Quantidade de itens: ' + IntToStr(Venda.QuantidadeItens));
      
    finally
      Produto1.Free;
      Produto2.Free;
    end;
  finally
    Venda.Free;
  end;
end;

class procedure TTestes.TestarOperador;
var
  Operador: TOperador;
begin
  WriteLn('--- Testando Classe TOperador ---');
  
  Operador := TOperador.Create(1, 'JOÃO SILVA', '001', '1234');
  try
    Assert(Operador.ID = 1, 'ID do operador incorreto');
    Assert(Operador.Nome = 'JOÃO SILVA', 'Nome do operador incorreto');
    Assert(Operador.Matrícula = '001', 'Matrícula incorreta');
    Assert(Operador.Ativo = True, 'Operador deveria estar ativo');
    
    WriteLn('✓ Operador criado corretamente');
    WriteLn('  ID: ' + IntToStr(Operador.ID));
    WriteLn('  Nome: ' + Operador.Nome);
    WriteLn('  Matrícula: ' + Operador.Matrícula);
    WriteLn('  Ativo: ' + BoolToStr(Operador.Ativo, True));
  finally
    Operador.Free;
  end;
end;

class procedure TTestes.TestarCaixa;
var
  Caixa: TCaixa;
  Operador: TOperador;
  Venda: TVenda;
  Produto: TProduto;
begin
  WriteLn('--- Testando Classe TCaixa ---');
  
  Operador := TOperador.Create(1, 'JOÃO SILVA', '001', '1234');
  Caixa := TCaixa.Create(1, Operador, 100.00);
  
  try
    // Testa abertura de caixa
    Assert(Caixa.Aberto = True, 'Caixa deveria estar aberto');
    Assert(Caixa.SaldoInicial = 100.00, 'Saldo inicial incorreto');
    
    WriteLn('✓ Caixa aberto corretamente');
    WriteLn('  Saldo Inicial: R$ ' + FormatFloat('0.00', Caixa.SaldoInicial));
    
    // Testa adição de venda
    Venda := TVenda.Create;
    Produto := TProduto.Create(1, 'LIVRO', 'Livro', 50.00);
    
    try
      Venda.AdicionarItem(Produto, 1);
      Caixa.AdicionarVenda(Venda);
      
      Assert(Caixa.Vendas.Count = 1, 'Venda não foi adicionada');
      Assert(Caixa.TotalVendas = 50.00, 'Total de vendas incorreto');
      
      WriteLn('✓ Venda adicionada ao caixa');
      WriteLn('  Quantidade de vendas: ' + IntToStr(Caixa.Vendas.Count));
      WriteLn('  Total de vendas: R$ ' + FormatFloat('0.00', Caixa.TotalVendas));
      
    finally
      Produto.Free;
    end;
    
    // Testa fechamento de caixa
    Caixa.Fechar;
    Assert(Caixa.Aberto = False, 'Caixa deveria estar fechado');
    Assert(Caixa.SaldoFinal = 150.00, 'Saldo final incorreto');
    
    WriteLn('✓ Caixa fechado corretamente');
    WriteLn('  Saldo Final: R$ ' + FormatFloat('0.00', Caixa.SaldoFinal));
    
  finally
    Caixa.Free;
    Operador.Free;
  end;
end;

class procedure TTestes.TestarRepositorioProdutos;
var
  Repositorio: TRepositorioProdutos;
  Produto: TProduto;
  Resultados: TObjectList<TProduto>;
begin
  WriteLn('--- Testando Classe TRepositorioProdutos ---');
  
  Repositorio := TRepositorioProdutos.Create;
  try
    // Testa obtenção de produto
    Produto := Repositorio.ObterProduto(1);
    Assert(Assigned(Produto), 'Produto não encontrado');
    Assert(Produto.Nome = 'LIVRO', 'Nome do produto incorreto');
    
    WriteLn('✓ Produto obtido corretamente');
    WriteLn('  ID: ' + IntToStr(Produto.ID));
    WriteLn('  Nome: ' + Produto.Nome);
    WriteLn('  Preço: R$ ' + FormatFloat('0.00', Produto.Preco));
    
    // Testa busca por nome
    Resultados := Repositorio.BuscarPorNome('CANETA');
    try
      Assert(Resultados.Count = 1, 'Busca por nome falhou');
      WriteLn('✓ Busca por nome funcionou');
      WriteLn('  Produtos encontrados: ' + IntToStr(Resultados.Count));
    finally
      Resultados.Free;
    end;
    
    // Testa obtenção de todos
    Assert(Repositorio.ObterTodos.Count > 0, 'Nenhum produto encontrado');
    WriteLn('✓ Todos os produtos obtidos');
    WriteLn('  Total de produtos: ' + IntToStr(Repositorio.ObterTodos.Count));
    
  finally
    Repositorio.Free;
  end;
end;

end.
