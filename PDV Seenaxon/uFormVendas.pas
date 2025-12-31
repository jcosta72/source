unit uFormVendas;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox,
  FMX.Memo.Types, FMX.ScrollBox, FMX.Memo, FMX.Objects,
  FMX.Types, FMX.Edit, System.Generics.Collections,
  uIntegracaoCaixa, uPersistenciaProduto, uRepositorioVenda,
  uProduto, uVenda, uItemVenda, uCaixa, uOperador, uDMConexao;

type
  TFormVendas = class(TForm)
    LayoutPrincipal: TLayout;
    LayoutCabecalho: TLayout;
    LabelTitulo: TLabel;
    LabelStatusCaixa: TLabel;
    LayoutCorpo: TLayout;
    LayoutEsquerda: TLayout;
    LayoutProdutos: TLayout;
    LabelProdutos: TLabel;
    EditBuscaProduto: TEdit;
    ListBoxProdutos: TListBox;
    LayoutDireita: TLayout;
    LayoutCarrinho: TLayout;
    LabelCarrinho: TLabel;
    ListBoxCarrinho: TListBox;
    LayoutResumo: TLayout;
    LabelResumo: TLabel;
    MemoResumo: TMemo;
    LayoutBotoes: TLayout;
    ButtonAdicionarProduto: TButton;
    ButtonRemoverItem: TButton;
    ButtonFinalizarVenda: TButton;
    ButtonLimparCarrinho: TButton;
    ButtonSair: TButton;
    EditQuantidade: TEdit;
    LabelQuantidade: TLabel;
    RectangleSeparador: TRectangle;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditBuscaProdutoChange(Sender: TObject);
    procedure ListBoxProdutosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
    procedure ButtonAdicionarProdutoClick(Sender: TObject);
    procedure ButtonRemoverItemClick(Sender: TObject);
    procedure ButtonFinalizarVendaClick(Sender: TObject);
    procedure ButtonLimparCarrinhoClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);
    procedure ListBoxCarrinhoItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
  private
    { Variáveis privadas }
    FIntegracaoCaixa: TIntegracaoCaixa;
    FPersistenciaProduto: TPersistenciaProduto;
    FRepositorioVenda: TRepositorioVenda;
    FVendaAtual: TVenda;
    FOperadorAtual: TOperador;
    FProdutoSelecionado: TProduto;
    FTodosProdutos: TObjectList<TProduto>;
    
    { Métodos privados }
    procedure InicializarComponentes;
    procedure CarregarProdutos;
    procedure AtualizarListaProdutos(ABusca: string = '');
    procedure AtualizarListaCarrinho;
    procedure AtualizarResumoVenda;
    procedure ValidarCaixaAberto;
    procedure FormatarEditQuantidade;
    procedure ExibirMensagem(AMensagem: string; ATipo: string = 'INFO');
  public
    { Métodos públicos }
    procedure SetOperador(AOperador: TOperador);
    procedure SetIntegracaoCaixa(AIntegracao: TIntegracaoCaixa);
  end;

var
  FormVendas: TFormVendas;

implementation

{$R *.fmx}

{ ============================================================================
  INICIALIZAÇÃO
  ============================================================================ }

procedure TFormVendas.FormCreate(Sender: TObject);
begin
  { Configurar formulário }
  Caption := 'PDV Seenaxon - Tela de Vendas';
  Width := 1200;
  Height := 800;
  Position := TFormPosition.ScreenCenter;
  
  { Inicializar componentes }
  InicializarComponentes;
  
  { Carregar produtos }
  CarregarProdutos;
  
  { Validar caixa }
  ValidarCaixaAberto;
end;

procedure TFormVendas.FormDestroy(Sender: TObject);
begin
  { Liberar recursos }
  if Assigned(FTodosProdutos) then
    FTodosProdutos.Free;
  
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;
  
  if Assigned(FPersistenciaProduto) then
    FPersistenciaProduto.Free;
end;

procedure TFormVendas.InicializarComponentes;
begin
  { Inicializar repositório de venda }
  FRepositorioVenda := TRepositorioVenda.Create;
  
  { Inicializar lista de produtos }
  FTodosProdutos := TObjectList<TProduto>.Create;
  
  { Inicializar persistência de produtos }
  FPersistenciaProduto := TPersistenciaProduto.Create(DMConexao.GetConexao);
  
  { Configurar EditQuantidade }
  EditQuantidade.Text := '1';
  EditQuantidade.KeyboardType := TVirtualKeyboardType.NumbersAndPunctuation;

  { Configurar cores }
  LabelStatusCaixa.TextSettings.FontColor := $FFFF0000; { Vermelho }
  
  { Configurar botões }
  ButtonAdicionarProduto.Text := 'Adicionar Produto';
  ButtonRemoverItem.Text := 'Remover Item';
  ButtonFinalizarVenda.Text := 'Finalizar Venda';
  ButtonLimparCarrinho.Text := 'Limpar Carrinho';
  ButtonSair.Text := 'Sair';
end;

{ ============================================================================
  CARREGAMENTO DE DADOS
  ============================================================================ }

procedure TFormVendas.CarregarProdutos;
var
  Produtos: TObjectList<TProduto>;
  i: Integer;
begin
  try
    { Obter produtos ativos do banco }
    Produtos := FPersistenciaProduto.ObterProdutosAtivos;
    
    if Assigned(Produtos) then
    begin
      { Limpar lista anterior }
      FTodosProdutos.Clear;
      
      { Adicionar produtos }
      for i := 0 to Produtos.Count - 1 do
      begin
        FTodosProdutos.Add(TProduto.Create(
          Produtos[i].ID,
          Produtos[i].Nome,
          Produtos[i].Descricao,
          Produtos[i].Preco,
          Produtos[i].CodigoBarras,
          Produtos[i].Categoria,
          Produtos[i].Estoque,
          Produtos[i].ImagemPath,
          Produtos[i].UnidadeMedida
        ));
      end;
      
      Produtos.Free;
      
      { Atualizar lista visual }
      AtualizarListaProdutos;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao carregar produtos: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.AtualizarListaProdutos(ABusca: string = '');
var
  i: Integer;
  Item: TListBoxItem;
  Produto: TProduto;
  Texto: string;
begin
  try
    { Limpar lista }
    ListBoxProdutos.Clear;
    
    { Adicionar produtos }
    for i := 0 to FTodosProdutos.Count - 1 do
    begin
      Produto := FTodosProdutos[i];
      
      { Filtrar por busca }
      if (ABusca = '') or (Pos(UpperCase(ABusca), UpperCase(Produto.Nome)) > 0) then
      begin
        Item := TListBoxItem.Create(ListBoxProdutos);
        Item.Parent := ListBoxProdutos;
        
        { Formatar texto do item }
        Texto := Format('%s | R$ %.2f | %s', [
          Produto.Nome,
          Produto.Preco,
          Produto.UnidadeMedidaNome
        ]);
        
        Item.Text := Texto;
        Item.Tag := Produto.ID;
      end;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao atualizar lista de produtos: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.AtualizarListaCarrinho;
var
  i: Integer;
  Item: TListBoxItem;
  ItemVenda: TItemVenda;
  Texto: string;
begin
  try
    { Limpar lista }
    ListBoxCarrinho.Clear;
    
    { Adicionar itens da venda }
    if Assigned(FVendaAtual) then
    begin
      for i := 0 to FVendaAtual.Itens.Count - 1 do
      begin
        ItemVenda := FVendaAtual.Itens[i];
        
        Item := TListBoxItem.Create(ListBoxCarrinho);
        Item.Parent := ListBoxCarrinho;
        
        { Formatar texto do item }
        Texto := Format('%s | Qtd: %.2f | R$ %.2f', [
          ItemVenda.Produto.Nome,
          ItemVenda.Quantidade,
          ItemVenda.ValorTotal
        ]);
        
        Item.Text := Texto;
        Item.Tag := i;
      end;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao atualizar lista do carrinho: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.AtualizarResumoVenda;
var
  Resumo: string;
begin
  try
    MemoResumo.Lines.Clear;
    
    if Assigned(FVendaAtual) then
    begin
      Resumo := Format(
        'ID: %d' + sLineBreak +
        'Operador: %s' + sLineBreak +
        'Data/Hora: %s' + sLineBreak +
        sLineBreak +
        '--- TOTALIZADORES ---' + sLineBreak +
        'Quantidade de Itens: %d' + sLineBreak +
        'Subtotal: R$ %.2f' + sLineBreak +
        'Desconto: R$ %.2f' + sLineBreak +
        'Acréscimo: R$ %.2f' + sLineBreak +
        'TOTAL: R$ %.2f',
        [
          FVendaAtual.ID,
          FOperadorAtual.Nome,
          FormatDateTime('dd/mm/yyyy hh:mm:ss', FVendaAtual.DataVenda),
          FVendaAtual.Itens.Count,
          FVendaAtual.Subtotal,
          FVendaAtual.Desconto,
          FVendaAtual.Acrescimo,
          FVendaAtual.Total
        ]
      );
      
      MemoResumo.Text := Resumo;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao atualizar resumo: ' + E.Message, 'ERRO');
  end;
end;

{ ============================================================================
  VALIDAÇÕES
  ============================================================================ }

procedure TFormVendas.ValidarCaixaAberto;
begin
  if Assigned(FIntegracaoCaixa) then
  begin
    if FIntegracaoCaixa.TemCaixaAbertoOperador(FOperadorAtual.ID) then
    begin
      LabelStatusCaixa.Text := 'CAIXA: ABERTO';
      LabelStatusCaixa.TextSettings.FontColor := $FF00AA00; { Verde }
      
      { Iniciar nova venda }
      FVendaAtual := FRepositorioVenda.IniciarVenda(FOperadorAtual.ID);
      AtualizarResumoVenda;
    end
    else
    begin
      LabelStatusCaixa.Text := 'CAIXA: FECHADO - Abra o caixa para iniciar vendas';
      LabelStatusCaixa.TextSettings.FontColor := $FFFF0000; { Vermelho }
      
      ButtonAdicionarProduto.Enabled := False;
      ButtonFinalizarVenda.Enabled := False;
      
      ExibirMensagem('Caixa não está aberto. Abra o caixa antes de iniciar vendas.', 'AVISO');
    end;
  end;
end;

procedure TFormVendas.FormatarEditQuantidade;
var
  Quantidade: Double;
  Produto: TProduto;
begin
  try
    if Assigned(FProdutoSelecionado) then
    begin
      { Validar quantidade }
      if not TryStrToFloat(EditQuantidade.Text, Quantidade) then
      begin
        EditQuantidade.Text := '1';
        Exit;
      end;
      
      { Validar conforme unidade de medida }
      if not FProdutoSelecionado.ValidarQuantidade(Quantidade) then
      begin
        ExibirMensagem('Quantidade inválida para a unidade: ' + FProdutoSelecionado.UnidadeMedidaNome, 'ERRO');
        EditQuantidade.Text := '1';
        Exit;
      end;
      
      { Ajustar quantidade }
      Quantidade := FProdutoSelecionado.AjustarQuantidade(Quantidade);
      EditQuantidade.Text := FProdutoSelecionado.FormatarQuantidade(Quantidade);
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao formatar quantidade: ' + E.Message, 'ERRO');
  end;
end;

{ ============================================================================
  EVENTOS DE BUSCA E SELEÇÃO
  ============================================================================ }

procedure TFormVendas.EditBuscaProdutoChange(Sender: TObject);
begin
  { Atualizar lista conforme busca }
  AtualizarListaProdutos(EditBuscaProduto.Text);
end;

procedure TFormVendas.ListBoxProdutosItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
var
  i: Integer;
begin
  try
    { Obter produto selecionado }
    if Item.Tag >= 0 then
    begin
      for i := 0 to FTodosProdutos.Count - 1 do
      begin
        if FTodosProdutos[i].ID = Item.Tag then
        begin
          FProdutoSelecionado := FTodosProdutos[i];
          
          { Atualizar campo de quantidade }
          EditQuantidade.Text := '1';
          
          { Exibir informações do produto }
          ExibirMensagem(
            'Produto selecionado: ' + FProdutoSelecionado.Nome + sLineBreak +
            'Preço: R$ ' + FormatFloat('0.00', FProdutoSelecionado.Preco) + sLineBreak +
            'Unidade: ' + FProdutoSelecionado.UnidadeMedidaNome + sLineBreak +
            'Estoque: ' + IntToStr(FProdutoSelecionado.Estoque),
            'INFO'
          );
          
          Break;
        end;
      end;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao selecionar produto: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.ListBoxCarrinhoItemClick(const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  { Item do carrinho selecionado }
  { Pode ser usado para editar quantidade ou remover item }
end;

{ ============================================================================
  OPERAÇÕES DE CARRINHO
  ============================================================================ }

procedure TFormVendas.ButtonAdicionarProdutoClick(Sender: TObject);
var
  Quantidade: Double;
begin
  try
    { Validar se produto está selecionado }
    if not Assigned(FProdutoSelecionado) then
    begin
      ExibirMensagem('Selecione um produto primeiro', 'AVISO');
      Exit;
    end;
    
    { Validar se venda está ativa }
    if not Assigned(FVendaAtual) then
    begin
      ExibirMensagem('Nenhuma venda ativa. Abra o caixa primeiro.', 'ERRO');
      Exit;
    end;
    
    { Obter quantidade }
    if not TryStrToFloat(EditQuantidade.Text, Quantidade) then
    begin
      ExibirMensagem('Quantidade inválida', 'ERRO');
      Exit;
    end;
    
    { Validar quantidade }
    if Quantidade <= 0 then
    begin
      ExibirMensagem('Quantidade deve ser maior que zero', 'ERRO');
      Exit;
    end;
    
    { Validar conforme unidade de medida }
    if not FProdutoSelecionado.ValidarQuantidade(Quantidade) then
    begin
      ExibirMensagem('Quantidade inválida para a unidade: ' + FProdutoSelecionado.UnidadeMedidaNome, 'ERRO');
      Exit;
    end;
    
    { Adicionar item à venda }
    FVendaAtual.AdicionarItem(FProdutoSelecionado, Quantidade);
    
    { Atualizar interface }
    AtualizarListaCarrinho;
    AtualizarResumoVenda;
    
    { Limpar seleção }
    EditQuantidade.Text := '1';
    FProdutoSelecionado := nil;
    
    ExibirMensagem('Produto adicionado ao carrinho', 'SUCESSO');
  except
    on E: Exception do
      ExibirMensagem('Erro ao adicionar produto: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.ButtonRemoverItemClick(Sender: TObject);
var
  Index: Integer;
begin
  try
    { Validar se item está selecionado }
    if ListBoxCarrinho.ItemIndex < 0 then
    begin
      ExibirMensagem('Selecione um item para remover', 'AVISO');
      Exit;
    end;
    
    { Remover item }
    Index := ListBoxCarrinho.ItemIndex;
    FVendaAtual.RemoverItem(Index);
    
    { Atualizar interface }
    AtualizarListaCarrinho;
    AtualizarResumoVenda;
    
    ExibirMensagem('Item removido do carrinho', 'SUCESSO');
  except
    on E: Exception do
      ExibirMensagem('Erro ao remover item: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.ButtonLimparCarrinhoClick(Sender: TObject);
begin
  try
    if Assigned(FVendaAtual) then
    begin
      FVendaAtual.LimparVenda;
      AtualizarListaCarrinho;
      AtualizarResumoVenda;
      ExibirMensagem('Carrinho limpo', 'SUCESSO');
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao limpar carrinho: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.ButtonFinalizarVendaClick(Sender: TObject);
begin
  try
    { Validar se venda tem itens }
    if not Assigned(FVendaAtual) or (FVendaAtual.Itens.Count = 0) then
    begin
      ExibirMensagem('Carrinho vazio. Adicione produtos antes de finalizar.', 'AVISO');
      Exit;
    end;
    
    { Aqui seria chamada a tela de pagamento }
    ExibirMensagem('Venda finalizada com sucesso!', 'SUCESSO');
    
    { Iniciar nova venda }
    FVendaAtual := FRepositorioVenda.IniciarVenda(FOperadorAtual.ID);
    AtualizarListaCarrinho;
    AtualizarResumoVenda;
  except
    on E: Exception do
      ExibirMensagem('Erro ao finalizar venda: ' + E.Message, 'ERRO');
  end;
end;

procedure TFormVendas.ButtonSairClick(Sender: TObject);
begin
  Close;
end;

{ ============================================================================
  MÉTODOS PÚBLICOS
  ============================================================================ }

procedure TFormVendas.SetOperador(AOperador: TOperador);
begin
  FOperadorAtual := AOperador;
  LabelTitulo.Text := 'PDV Seenaxon - Operador: ' + AOperador.Nome;
end;

procedure TFormVendas.SetIntegracaoCaixa(AIntegracao: TIntegracaoCaixa);
begin
  FIntegracaoCaixa := AIntegracao;
end;

{ ============================================================================
  MÉTODOS AUXILIARES
  ============================================================================ }

procedure TFormVendas.ExibirMensagem(AMensagem: string; ATipo: string = 'INFO');
begin
  ShowMessage(AMensagem);
end;

end.
