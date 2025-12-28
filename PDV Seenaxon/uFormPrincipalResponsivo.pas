unit uFormPrincipalResponsivo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.Edit, FMX.Memo, FMX.StdCtrls, FMX.Controls.Presentation,
  FMX.Objects, System.Generics.Collections,
  uProduto, uItemVenda, uVenda, uOperador, uCaixa, uRepositorioProdutos,
  uRepositorioOperadores, uRepositorioCaixa, uRecuperacaoVendas,
  uImpressoraFiscal;

type
  { Formulário principal responsivo do PDV }
  TFormPrincipalResponsivo = class(TForm)
    { Painéis principais }
    PainelPrincipal: TPanel;
    PainelCabecalho: TPanel;
    PainelCorpo: TPanel;
    PainelRodape: TPanel;

    { Painel de cabeçalho }
    LabelOperador: TLabel;
    LabelCaixa: TLabel;
    LabelHora: TLabel;
    ButtonGerenciarCaixa: TButton;
    ButtonSair: TButton;

    { Painel de corpo - esquerda (produtos) }
    PainelEsquerda: TPanel;
    LabelPesquisa: TLabel;
    EditPesquisa: TEdit;
    LabelProdutos: TLabel;
    ListBoxProdutos: TListBox;

    { Painel de corpo - direita (carrinho) }
    PainelDireita: TPanel;
    LabelCarrinho: TLabel;
    ListBoxCarrinho: TListBox;
    LabelResumo: TLabel;
    MemoResumo: TMemo;

    { Painel de rodapé - botões }
    PainelBotoes: TPanel;
    ButtonAumentar: TButton;
    ButtonDiminuir: TButton;
    ButtonRemover: TButton;
    ButtonDesconto: TButton;
    ButtonAcrescimo: TButton;
    ButtonLimpar: TButton;
    ButtonFinalizar: TButton;

    { Timer para atualizar hora }
    TimerHora: TTimer;

    { Eventos }
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);

    { Eventos de produtos }
    procedure ListBoxProdutosItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);
    procedure EditPesquisaChange(Sender: TObject);

    { Eventos de carrinho }
    procedure ListBoxCarrinhoItemClick(const Sender: TCustomListBox;
      const Item: TListBoxItem);

    { Eventos de botões }
    procedure ButtonAumentarClick(Sender: TObject);
    procedure ButtonDiminuirClick(Sender: TObject);
    procedure ButtonRemoverClick(Sender: TObject);
    procedure ButtonDescontoClick(Sender: TObject);
    procedure ButtonAcrescimoClick(Sender: TObject);
    procedure ButtonLimparClick(Sender: TObject);
    procedure ButtonFinalizarClick(Sender: TObject);
    procedure ButtonGerenciarCaixaClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);

    { Timer }
    procedure TimerHoraTimer(Sender: TObject);

  private
    { Variáveis privadas }
    FRepositorioProdutos: TRepositorioProdutos;
    FRepositorioOperadores: TRepositorioOperadores;
    FRepositorioCaixa: TRepositorioCaixa;
    FRecuperacaoVendas: TRecuperacaoVendas;

    FOperadorAtual: TOperador;
    FCaixaAtual: TCaixa;
    FVendaAtual: TVenda;
    FImpressoraFiscal: TImpressoraFiscal;

    FItemSelecionadoCarrinho: Integer;

    { Métodos privados de inicialização }
    procedure InicializarRepositorios;
    procedure RealizarLogin;
    procedure VerificarVendaPendente;
    procedure CarregarProdutos;
    procedure AbrirCaixa;
    procedure AjustarLayout;

    { Métodos privados de interface }
    procedure AtualizarResumoVenda;
    procedure AtualizarListaCarrinho;
    procedure AtualizarListaProdutos;
    procedure ExibirDetalhesItem(AIndex: Integer);
    procedure LimparVenda;

    { Métodos privados de operação }
    procedure SalvarVendaPendente;
    procedure FinalizarVendaCompleta;

    { Métodos privados auxiliares }
    function BuscarProdutosPorNome(ANome: string): TObjectList<TProduto>;
    procedure AjustarTamanhoPaineis;

  public
    { Métodos públicos }
  end;

var
  FormPrincipalResponsivo: TFormPrincipalResponsivo;

implementation

{$R *.fmx}

// ============================================================================
// CONSTRUTOR E DESTRUTOR
// ============================================================================

procedure TFormPrincipalResponsivo.FormCreate(Sender: TObject);
begin
  { Inicializar repositórios }
  InicializarRepositorios;

  { Realizar login do operador }
  RealizarLogin;

  { Verificar venda pendente }
  VerificarVendaPendente;

  { Carregar produtos }
  CarregarProdutos;

  { Abrir caixa }
  AbrirCaixa;

  { Ajustar layout responsivo }
  AjustarLayout;

  { Criar venda inicial se não foi recuperada }
  if not Assigned(FVendaAtual) then
  begin
    FVendaAtual := TVenda.Create;
    FVendaAtual.OperadorID := FOperadorAtual.ID;
  end;

  { Atualizar interface }
  AtualizarResumoVenda;
  AtualizarListaCarrinho;

  { Iniciar timer de hora }
  TimerHora.Enabled := True;

  { Inicializar variáveis }
  FItemSelecionadoCarrinho := -1;
end;

procedure TFormPrincipalResponsivo.FormDestroy(Sender: TObject);
begin
  { Parar timer }
  TimerHora.Enabled := False;

  { Liberar objetos }
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;

  if Assigned(FCaixaAtual) then
    FCaixaAtual.Free;

  if Assigned(FOperadorAtual) then
    FOperadorAtual.Free;

  if Assigned(FRepositorioProdutos) then
    FRepositorioProdutos.Free;

  if Assigned(FRepositorioOperadores) then
    FRepositorioOperadores.Free;

  if Assigned(FRepositorioCaixa) then
    FRepositorioCaixa.Free;

  if Assigned(FRecuperacaoVendas) then
    FRecuperacaoVendas.Free;
end;

// ============================================================================
// INICIALIZAÇÃO
// ============================================================================

procedure TFormPrincipalResponsivo.InicializarRepositorios;
begin
  try
    { Criar repositório de produtos }
    FRepositorioProdutos := TRepositorioProdutos.Create;
    FRepositorioProdutos.CarregarProdutosTeste;

    { Criar repositório de operadores }
    FRepositorioOperadores := TRepositorioOperadores.Create;
    FRepositorioOperadores.CarregarOperadoresTeste;

    { Criar repositório de caixas }
    FRepositorioCaixa := TRepositorioCaixa.Create;

    { Criar recuperação de vendas }
    FRecuperacaoVendas := TRecuperacaoVendas.Create(FRepositorioProdutos, faXML);

  except
    on E: Exception do
    begin
      ShowMessage('Erro ao inicializar repositórios: ' + E.Message);
      Application.Terminate;
    end;
  end;
end;

procedure TFormPrincipalResponsivo.RealizarLogin;
var
  Matricula, Senha: string;
  Operador: TOperador;
  Tentativas: Integer;
begin
  Tentativas := 0;

  repeat
    { Solicitar matrícula }
    if not InputQuery('Login', 'Matrícula:', Matricula) then
    begin
      Application.Terminate;
      Exit;
    end;

    { Solicitar senha }
    if not InputQuery('Login', 'Senha:', Senha) then
    begin
      Application.Terminate;
      Exit;
    end;

    { Validar credenciais }
    Operador := FRepositorioOperadores.ValidarCredenciais(Matricula, Senha);

    if Assigned(Operador) then
    begin
      FOperadorAtual := Operador;
      LabelOperador.Text := Format('Operador: %s (%s)', [Operador.Nome, Operador.Matricula]);
      Exit;
    end
    else
    begin
      Inc(Tentativas);
      ShowMessage(Format('Credenciais inválidas. Tentativa %d de 3', [Tentativas]));
    end;

  until Tentativas >= 3;

  { Se falhar 3 vezes, sair }
  ShowMessage('Acesso negado!');
  Application.Terminate;
end;

procedure TFormPrincipalResponsivo.VerificarVendaPendente;
var
  VendaPendente: TVenda;
  Resultado: Integer;
begin
  { Verificar se existe venda pendente }
  if FRecuperacaoVendas.TemVendaPendente then
  begin
    { Perguntar ao usuário }
    Resultado := MessageDlg(
      'Existe uma venda pendente. Deseja retomá-la?' + sLineBreak + sLineBreak +
      'Clique SIM para continuar a venda anterior' + sLineBreak +
      'Clique NÃO para iniciar uma nova venda',
      TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
      0
    );

    if Resultado = mrYes then
    begin
      { Carregar venda pendente }
      VendaPendente := FRecuperacaoVendas.CarregarVendaPendente;

      if Assigned(VendaPendente) then
      begin
        { Liberar venda anterior se existir }
        if Assigned(FVendaAtual) then
          FVendaAtual.Free;

        { Usar venda recuperada }
        FVendaAtual := VendaPendente;
        FVendaAtual.OperadorID := FOperadorAtual.ID;

        { Deletar arquivo de recuperação }
        FRecuperacaoVendas.DeletarVendaPendente;

        { Exibir mensagem de sucesso }
        ShowMessage(
          Format(
            'Venda retomada com sucesso!' + sLineBreak + sLineBreak +
            'Itens: %d' + sLineBreak +
            'Total: R$ %.2f',
            [FVendaAtual.QuantidadeItens, FVendaAtual.Total]
          )
        );
      end;
    end
    else
    begin
      { Deletar arquivo de recuperação }
      FRecuperacaoVendas.DeletarVendaPendente;
    end;
  end;
end;

procedure TFormPrincipalResponsivo.CarregarProdutos;
var
  Produtos: TObjectList<TProduto>;
  i: Integer;
  Item: TListBoxItem;
  Produto: TProduto;
begin
  try
    ListBoxProdutos.Clear;

    { Obter todos os produtos }
    Produtos := FRepositorioProdutos.ObterTodos;

    if Assigned(Produtos) then
    begin
      try
        { Adicionar cada produto à lista }
        for i := 0 to Produtos.Count - 1 do
        begin
          Produto := Produtos[i];

          Item := TListBoxItem.Create(ListBoxProdutos);
          Item.Parent := ListBoxProdutos;
          Item.Text := Format('%s - R$ %.2f', [Produto.Nome, Produto.Preco]);
          Item.Tag := Produto.ID;
          Item.Height := 40;
        end;
      finally
        Produtos.Free;
      end;
    end;

  except
    on E: Exception do
      ShowMessage('Erro ao carregar produtos: ' + E.Message);
  end;
end;

procedure TFormPrincipalResponsivo.AbrirCaixa;
var
  SaldoInicial: string;
  ValorSaldo: Double;
begin
  try
    { Criar novo caixa }
    FCaixaAtual := TCaixa.Create(1, FOperadorAtual, 0);

    { Solicitar saldo inicial }
    if InputQuery('Abertura de Caixa', 'Digite o saldo inicial (R$):', SaldoInicial) then
    begin
      if TryStrToFloat(SaldoInicial, ValorSaldo) and (ValorSaldo >= 0) then
      begin
        FCaixaAtual.Abrir(ValorSaldo);
        LabelCaixa.Text := Format('Caixa: Aberto - Saldo: R$ %.2f', [ValorSaldo]);
        FRepositorioCaixa.AdicionarCaixa(FCaixaAtual);
      end
      else
      begin
        ShowMessage('Valor inválido!');
        AbrirCaixa;
      end;
    end;

  except
    on E: Exception do
      ShowMessage('Erro ao abrir caixa: ' + E.Message);
  end;
end;

procedure TFormPrincipalResponsivo.AjustarLayout;
begin
  { Configurar painéis principais }
  PainelPrincipal.Align := TAlignLayout.Client;
  PainelPrincipal.Padding.Left := 5;
  PainelPrincipal.Padding.Top := 5;
  PainelPrincipal.Padding.Right := 5;
  PainelPrincipal.Padding.Bottom := 5;

  { Painel de cabeçalho }
  PainelCabecalho.Align := TAlignLayout.Top;
  PainelCabecalho.Height := 60;
  PainelCabecalho.Margins.Bottom := 5;

  { Painel de corpo }
  PainelCorpo.Align := TAlignLayout.Client;
  PainelCorpo.Margins.Bottom := 5;

  { Painel de rodapé }
  PainelRodape.Align := TAlignLayout.Bottom;
  PainelRodape.Height := 50;

  { Ajustar tamanho dos painéis }
  AjustarTamanhoPaineis;
end;

procedure TFormPrincipalResponsivo.AjustarTamanhoPaineis;
var
  LarguraTela: Single;
  LarguraPainelDireita: Single;
begin
  LarguraTela := PainelCorpo.Width;

  { Calcular largura do painel direito baseado na resolução }
  if LarguraTela < 1000 then
    LarguraPainelDireita := LarguraTela * 0.35
  else if LarguraTela < 1400 then
    LarguraPainelDireita := LarguraTela * 0.38
  else
    LarguraPainelDireita := LarguraTela * 0.40;

  { Aplicar tamanhos }
  PainelDireita.Width := LarguraPainelDireita;
  PainelDireita.Align := TAlignLayout.Right;
  PainelDireita.Margins.Left := 5;

  PainelEsquerda.Align := TAlignLayout.Client;
end;

// ============================================================================
// INTERFACE - ATUALIZAÇÃO
// ============================================================================

procedure TFormPrincipalResponsivo.AtualizarResumoVenda;
var
  Resumo: string;
begin
  Resumo := '';
  Resumo := Resumo + Format('Itens: %d' + sLineBreak, [FVendaAtual.QuantidadeItens]);
  Resumo := Resumo + Format('Subtotal: R$ %.2f' + sLineBreak, [FVendaAtual.Subtotal]);

  if FVendaAtual.Desconto > 0 then
    Resumo := Resumo + Format('Desconto: R$ %.2f' + sLineBreak, [FVendaAtual.Desconto]);

  if FVendaAtual.Acrescimo > 0 then
    Resumo := Resumo + Format('Acréscimo: R$ %.2f' + sLineBreak, [FVendaAtual.Acrescimo]);

  Resumo := Resumo + Format('TOTAL: R$ %.2f', [FVendaAtual.Total]);

  MemoResumo.Lines.Text := Resumo;
end;

procedure TFormPrincipalResponsivo.AtualizarListaCarrinho;
var
  i: Integer;
  Item: TItemVenda;
  ListItem: TListBoxItem;
begin
  ListBoxCarrinho.Clear;

  for i := 0 to FVendaAtual.QuantidadeItens - 1 do
  begin
    Item := FVendaAtual.GetItem(i);
    if Assigned(Item) then
    begin
      ListItem := TListBoxItem.Create(ListBoxCarrinho);
      ListItem.Parent := ListBoxCarrinho;
      ListItem.Text := Format(
        '%.0f x %s - R$ %.2f',
        [Item.Quantidade, Item.Produto.Nome, Item.ValorTotal]
      );
      ListItem.Tag := i;
      ListItem.Height := 40;
    end;
  end;

  AtualizarResumoVenda;
end;

procedure TFormPrincipalResponsivo.AtualizarListaProdutos;
var
  Pesquisa: string;
  Produtos: TObjectList<TProduto>;
  i: Integer;
  Item: TListBoxItem;
  Produto: TProduto;
begin
  Pesquisa := EditPesquisa.Text.Trim.ToUpper;

  ListBoxProdutos.Clear;

  if Pesquisa = '' then
  begin
    CarregarProdutos;
  end
  else
  begin
    Produtos := BuscarProdutosPorNome(Pesquisa);
    if Assigned(Produtos) then
    begin
      try
        for i := 0 to Produtos.Count - 1 do
        begin
          Produto := Produtos[i];

          Item := TListBoxItem.Create(ListBoxProdutos);
          Item.Parent := ListBoxProdutos;
          Item.Text := Format('%s - R$ %.2f', [Produto.Nome, Produto.Preco]);
          Item.Tag := Produto.ID;
          Item.Height := 40;
        end;
      finally
        Produtos.Free;
      end;
    end;
  end;
end;

procedure TFormPrincipalResponsivo.ExibirDetalhesItem(AIndex: Integer);
var
  Item: TItemVenda;
  Detalhes: string;
begin
  if (AIndex >= 0) and (AIndex < FVendaAtual.QuantidadeItens) then
  begin
    Item := FVendaAtual.GetItem(AIndex);
    if Assigned(Item) then
    begin
      Detalhes := '';
      Detalhes := Detalhes + Format('Produto: %s' + sLineBreak, [Item.Produto.Nome]);
      Detalhes := Detalhes + Format('Quantidade: %.0f' + sLineBreak, [Item.Quantidade]);
      Detalhes := Detalhes + Format('Preço Unitário: R$ %.2f' + sLineBreak, [Item.ValorUnitario]);
      Detalhes := Detalhes + Format('Valor Total: R$ %.2f' + sLineBreak, [Item.ValorTotal]);

      if Item.Desconto > 0 then
        Detalhes := Detalhes + Format('Desconto: R$ %.2f (%.2f%%)' + sLineBreak,
          [Item.Desconto, Item.PercentualDesconto]);

      MemoResumo.Lines.Text := Detalhes;
    end;
  end;
end;

procedure TFormPrincipalResponsivo.LimparVenda;
begin
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;

  FVendaAtual := TVenda.Create;
  FVendaAtual.OperadorID := FOperadorAtual.ID;

  FItemSelecionadoCarrinho := -1;

  AtualizarListaCarrinho;
  AtualizarResumoVenda;

  FRecuperacaoVendas.DeletarVendaPendente;
end;

// ============================================================================
// EVENTOS - PRODUTOS
// ============================================================================

procedure TFormPrincipalResponsivo.ListBoxProdutosItemClick(
  const Sender: TCustomListBox; const Item: TListBoxItem);
var
  Produto: TProduto;
  NovoItem: TItemVenda;
begin
  try
    Produto := FRepositorioProdutos.BuscarPorID(Item.Tag);

    if Assigned(Produto) then
    begin
      NovoItem := TItemVenda.Create(Produto, 1);
      FVendaAtual.AdicionarItem(NovoItem);

      AtualizarListaCarrinho;
      SalvarVendaPendente;

      ShowMessage(Format('%s adicionado ao carrinho', [Produto.Nome]));
    end;

  except
    on E: Exception do
      ShowMessage('Erro ao adicionar produto: ' + E.Message);
  end;
end;

procedure TFormPrincipalResponsivo.EditPesquisaChange(Sender: TObject);
begin
  AtualizarListaProdutos;
end;

// ============================================================================
// EVENTOS - CARRINHO
// ============================================================================

procedure TFormPrincipalResponsivo.ListBoxCarrinhoItemClick(
  const Sender: TCustomListBox; const Item: TListBoxItem);
begin
  FItemSelecionadoCarrinho := Item.Tag;
  ExibirDetalhesItem(FItemSelecionadoCarrinho);
end;

// ============================================================================
// EVENTOS - BOTÕES
// ============================================================================

procedure TFormPrincipalResponsivo.ButtonAumentarClick(Sender: TObject);
var
  ItemVenda: TItemVenda;
begin
  if FItemSelecionadoCarrinho >= 0 then
  begin
    ItemVenda := FVendaAtual.GetItem(FItemSelecionadoCarrinho);
    if Assigned(ItemVenda) then
    begin
      ItemVenda.Aumentar(1);
      AtualizarListaCarrinho;
      ExibirDetalhesItem(FItemSelecionadoCarrinho);
      SalvarVendaPendente;
    end;
  end
  else
    ShowMessage('Selecione um item no carrinho');
end;

procedure TFormPrincipalResponsivo.ButtonDiminuirClick(Sender: TObject);
var
  ItemVenda: TItemVenda;
begin
  if FItemSelecionadoCarrinho >= 0 then
  begin
    ItemVenda := FVendaAtual.GetItem(FItemSelecionadoCarrinho);
    if Assigned(ItemVenda) then
    begin
      if ItemVenda.Quantidade > 1 then
      begin
        ItemVenda.Diminuir(1);
        AtualizarListaCarrinho;
        ExibirDetalhesItem(FItemSelecionadoCarrinho);
        SalvarVendaPendente;
      end
      else
        ShowMessage('Quantidade mínima é 1');
    end;
  end
  else
    ShowMessage('Selecione um item no carrinho');
end;

procedure TFormPrincipalResponsivo.ButtonRemoverClick(Sender: TObject);
begin
  if FItemSelecionadoCarrinho >= 0 then
  begin
    FVendaAtual.RemoverItem(FItemSelecionadoCarrinho);
    FItemSelecionadoCarrinho := -1;
    AtualizarListaCarrinho;
    SalvarVendaPendente;
    ShowMessage('Item removido do carrinho');
  end
  else
    ShowMessage('Selecione um item no carrinho');
end;

procedure TFormPrincipalResponsivo.ButtonDescontoClick(Sender: TObject);
var
  Desconto: string;
  ValorDesconto: Double;
begin
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;

  if InputQuery('Desconto', 'Digite o valor do desconto (R$):', Desconto) then
  begin
    if TryStrToFloat(Desconto, ValorDesconto) and (ValorDesconto >= 0) then
    begin
      FVendaAtual.AplicarDesconto(ValorDesconto, False);
      AtualizarListaCarrinho;
      SalvarVendaPendente;
      ShowMessage(Format('Desconto de R$ %.2f aplicado', [ValorDesconto]));
    end
    else
      ShowMessage('Valor inválido!');
  end;
end;

procedure TFormPrincipalResponsivo.ButtonAcrescimoClick(Sender: TObject);
var
  Acrescimo: string;
  ValorAcrescimo: Double;
begin
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;

  if InputQuery('Acréscimo', 'Digite o valor do acréscimo (R$):', Acrescimo) then
  begin
    if TryStrToFloat(Acrescimo, ValorAcrescimo) and (ValorAcrescimo >= 0) then
    begin
      FVendaAtual.AplicarAcrescimo(ValorAcrescimo, False);
      AtualizarListaCarrinho;
      SalvarVendaPendente;
      ShowMessage(Format('Acréscimo de R$ %.2f aplicado', [ValorAcrescimo]));
    end
    else
      ShowMessage('Valor inválido!');
  end;
end;

procedure TFormPrincipalResponsivo.ButtonLimparClick(Sender: TObject);
begin
  if FVendaAtual.QuantidadeItens > 0 then
  begin
    if MessageDlg('Deseja limpar o carrinho?', TMsgDlgType.mtConfirmation,
      [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    begin
      LimparVenda;
      ShowMessage('Carrinho limpo');
    end;
  end
  else
    ShowMessage('Carrinho já está vazio');
end;

procedure TFormPrincipalResponsivo.ButtonFinalizarClick(Sender: TObject);
var
  FormaPagamento: Integer;
  Valor: string;
  ValorPagamento: Double;
begin
  if FVendaAtual.QuantidadeItens = 0 then
  begin
    ShowMessage('Adicione itens ao carrinho');
    Exit;
  end;

  if not FCaixaAtual.Aberto then
  begin
    ShowMessage('Abra o caixa primeiro');
    Exit;
  end;

  { Solicitar forma de pagamento }
  FormaPagamento := MessageDlg(
    'Escolha a forma de pagamento:' + sLineBreak + sLineBreak +
    'SIM = Dinheiro' + sLineBreak +
    'NÃO = Cartão' + sLineBreak +
    'CANCELAR = PIX',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo, TMsgDlgBtn.mbCancel],
    0
  );

  case FormaPagamento of
    mrYes: { Dinheiro }
    begin
      if InputQuery('Pagamento', 'Digite o valor recebido (R$):', Valor) then
      begin
        if TryStrToFloat(Valor, ValorPagamento) then
        begin
          FVendaAtual.Finalizar(fpDinheiro, ValorPagamento);
          FinalizarVendaCompleta;
        end
        else
          ShowMessage('Valor inválido!');
      end;
    end;

    mrNo: { Cartão }
    begin
      FVendaAtual.Finalizar(fpCartao, FVendaAtual.Total);
      FinalizarVendaCompleta;
    end;

    mrCancel: { PIX }
    begin
      FVendaAtual.Finalizar(fpPIX, FVendaAtual.Total);
      FinalizarVendaCompleta;
    end;
  end;
end;

procedure TFormPrincipalResponsivo.ButtonGerenciarCaixaClick(Sender: TObject);
begin
  ShowMessage('Funcionalidade de gerenciamento de caixa será implementada');
end;

procedure TFormPrincipalResponsivo.ButtonSairClick(Sender: TObject);
begin
  if MessageDlg('Deseja sair do sistema?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    Close;
  end;
end;

// ============================================================================
// TIMER
// ============================================================================

procedure TFormPrincipalResponsivo.TimerHoraTimer(Sender: TObject);
begin
  LabelHora.Text := FormatDateTime('hh:mm:ss', Now);
end;

// ============================================================================
// EVENTOS DE FORMULÁRIO
// ============================================================================

procedure TFormPrincipalResponsivo.FormResize(Sender: TObject);
begin
  AjustarTamanhoPaineis;
end;

procedure TFormPrincipalResponsivo.FormShow(Sender: TObject);
begin
  { Atualizar hora inicial }
  LabelHora.Text := FormatDateTime('hh:mm:ss', Now);
end;

// ============================================================================
// MÉTODOS PRIVADOS
// ============================================================================

procedure TFormPrincipalResponsivo.SalvarVendaPendente;
begin
  if Assigned(FVendaAtual) and (FVendaAtual.QuantidadeItens > 0) then
  begin
    FRecuperacaoVendas.SalvarVendaPendente(FVendaAtual);
  end;
end;

procedure TFormPrincipalResponsivo.FinalizarVendaCompleta;
begin
  try
    { Adicionar venda ao caixa }
    if Assigned(FCaixaAtual) then
    begin
      FCaixaAtual.AdicionarVenda(FVendaAtual);
    end;

    { Criar impressora fiscal }
    FImpressoraFiscal := TImpressoraFiscal.Create(FCaixaAtual, FOperadorAtual);
    try
      FImpressoraFiscal.ConfigurarEmpresa(
        'PDV SEENAXON',
        '00.000.000/0000-00',
        '00.000.000.000.000',
        'Rua Exemplo, 123 - São Paulo - SP',
        '(11) 3000-0000',
        'www.seenaxon.com.br'
      );

      FImpressoraFiscal.ConfigurarECF(FCaixaAtual.Vendas.Count, '001');

      { Imprimir cupom }
      FImpressoraFiscal.ImprimirCupomVenda(FVendaAtual);

    finally
      FImpressoraFiscal.Free;
    end;

    { Deletar arquivo de venda pendente }
    FRecuperacaoVendas.DeletarVendaPendente;

    { Limpar venda }
    LimparVenda;

    { Exibir mensagem de sucesso }
    ShowMessage('Venda finalizada com sucesso!');

  except
    on E: Exception do
      ShowMessage('Erro ao finalizar venda: ' + E.Message);
  end;
end;

function TFormPrincipalResponsivo.BuscarProdutosPorNome(ANome: string): TObjectList<TProduto>;
var
  Produtos: TObjectList<TProduto>;
  Resultado: TObjectList<TProduto>;
  i: Integer;
  Produto: TProduto;
begin
  Resultado := TObjectList<TProduto>.Create(False);

  Produtos := FRepositorioProdutos.ObterTodos;
  if Assigned(Produtos) then
  begin
    try
      for i := 0 to Produtos.Count - 1 do
      begin
        Produto := Produtos[i];
        if Pos(ANome, Produto.Nome.ToUpper) > 0 then
        begin
          Resultado.Add(Produto);
        end;
      end;
    finally
      Produtos.Free;
    end;
  end;

  Result := Resultado;
end;

end.
