procedure TRepositorioProduto.CarregarProdutosTeste;
var
  Produto: TProduto;
begin
  // Categoria: Bebidas
  Produto := TProduto.Create(GerarProximoID, 'Água Mineral 1.5L', 'Bebidas', 2.50, '7891234567890', ctOutros, 100);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Refrigerante Cola 2L', 'Bebidas', 5.99, '7891234567891', ctOutros, 80);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Suco Natural Laranja 1L', 'Bebidas', 4.50, '7891234567892', ctOutros, 60);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Cerveja Premium 600ml', 'Bebidas', 3.99, '7891234567893', ctOutros, 120);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Vinho Tinto Reserva', 'Bebidas', 25.90, '7891234567894', ctOutros, 40);
  FProdutos.Add(Produto);
  
  // Categoria: Alimentos
  Produto := TProduto.Create(GerarProximoID, 'Pão Francês 500g', 'Alimentos', 3.50, '7891234567895', ctOutros, 150);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Arroz Integral 5kg', 'Alimentos', 18.90, '7891234567896', ctOutros, 50);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Feijão Carioca 1kg', 'Alimentos', 5.99, '7891234567897', ctOutros, 75);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Macarrão Integral 500g', 'Alimentos', 2.99, '7891234567898', ctOutros, 200);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Azeite Extra Virgem 500ml', 'Alimentos', 12.50, '7891234567899', ctOutros, 30);
  FProdutos.Add(Produto);
  
  // Categoria: Laticínios
  Produto := TProduto.Create(GerarProximoID, 'Leite Integral 1L', 'Laticínios', 3.20, '7891234567900', ctOutros, 100);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Queijo Meia Cura 500g', 'Laticínios', 15.90, '7891234567901', ctOutros, 40);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Iogurte Natural 500g', 'Laticínios', 4.50, '7891234567902', ctOutros, 80);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Manteiga com Sal 200g', 'Laticínios', 6.99, '7891234567903', ctOutros, 60);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Requeijão Cremoso 220g', 'Laticínios', 3.99, '7891234567904', ctOutros, 90);
  FProdutos.Add(Produto);
  
  // Categoria: Embutidos
  Produto := TProduto.Create(GerarProximoID, 'Presunto Cozido 500g', 'Embutidos', 12.90, '7891234567905', ctOutros, 50);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Salame Italiano 500g', 'Embutidos', 14.50, '7891234567906', ctOutros, 45);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Mortadela Premium 500g', 'Embutidos', 9.99, '7891234567907', ctOutros, 70);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Linguiça Fresca 500g', 'Embutidos', 11.90, '7891234567908', ctOutros, 55);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Bacon Defumado 200g', 'Embutidos', 8.50, '7891234567909', ctOutros, 65);
  FProdutos.Add(Produto);
  
  // Categoria: Frutas e Verduras
  Produto := TProduto.Create(GerarProximoID, 'Maçã Vermelha 1kg', 'Frutas e Verduras', 4.99, '7891234567910', ctOutros, 100);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Banana Nanica 1kg', 'Frutas e Verduras', 2.99, '7891234567911', ctOutros, 150);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Alface Crespa 1 unidade', 'Frutas e Verduras', 1.99, '7891234567912', ctOutros, 80);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Tomate Caqui 1kg', 'Frutas e Verduras', 3.99, '7891234567913', ctOutros, 120);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Cenoura 1kg', 'Frutas e Verduras', 2.50, '7891234567914', ctOutros, 90);
  FProdutos.Add(Produto);
  
  // Categoria: Congelados
  Produto := TProduto.Create(GerarProximoID, 'Frango Congelado 1kg', 'Congelados', 9.99, '7891234567915', ctOutros, 80);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Peixe Congelado 500g', 'Congelados', 12.50, '7891234567916', ctOutros, 50);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Camarão Congelado 500g', 'Congelados', 18.90, '7891234567917', ctOutros, 40);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Brócolis Congelado 500g', 'Congelados', 3.99, '7891234567918', ctOutros, 100);
  FProdutos.Add(Produto);
  
  Produto := TProduto.Create(GerarProximoID, 'Pizza Congelada 500g', 'Congelados', 6.99, '7891234567919', ctOutros, 120);
  FProdutos.Add(Produto);
end;
