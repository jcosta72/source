unit uFormPrincipalResponsivo;
interface
uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.Grid, FMX.Edit, FMX.StdCtrls, FMX.Memo, FMX.Controls.Presentation,
  FMX.ScrollBox, System.Generics.Collections,
  uRepositorioProduto, uRepositorioVenda, uRepositorioOperador, uDMConexao,
  uFormLogin, uProduto, uVenda, uItemVenda, uOperador, uCriptografiaSenha,
  System.Rtti, FMX.Grid.Style, FMX.Objects;
type
  TFormPrincipalResponsivo = class(TForm)
    LayoutPrincipal: TLayout;
    LayoutCabecalho: TLayout;
    RectangloCabecalho: TRectangle;
    LabelTitulo: TLabel;
    LabelOperador: TLabel;
    LabelCaixa: TLabel;
    ButtonSair: TButton;
    LayoutMenu: TLayout;
    ButtonVenda: TButton;
    ButtonCaixa: TButton;
    ButtonRelatorios: TButton;
    LayoutCorpo: TLayout;
    LayoutPainelEsquerdo: TLayout;
    LabelProdutos: TLabel;
    EditBuscaProduto: TEdit;
    GridProdutos: TStringGrid;
    LayoutPainelDireito: TLayout;
    LabelCarrinho: TLabel;
    GridCarrinho: TStringGrid;
    LabelResumo: TLabel;
    LabelSubtotal: TLabel;
    LabelDesconto: TLabel;
    LabelAcrescimo: TLabel;
    LabelTotal: TLabel;
    LayoutBotoesAcao: TLayout;
    ButtonAdicionarProduto: TButton;
    ButtonRemoverItem: TButton;
    ButtonAplicarDesconto: TButton;
    ButtonFinalizarVenda: TButton;
    ButtonLimparCarrinho: TButton;
    LayoutRodape: TLayout;
    LabelStatusBar: TLabel;
    LabelHora: TLabel;
    TimerAtualizacao: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditBuscaProdutoChange(Sender: TObject);
    procedure GridProdutosSelectCell(Sender: TObject; const ACol, ARow: Integer);
    procedure ButtonAdicionarProdutoClick(Sender: TObject);
    procedure ButtonRemoverItemClick(Sender: TObject);
    procedure ButtonLimparCarrinhoClick(Sender: TObject);
    procedure ButtonFinalizarVendaClick(Sender: TObject);
    procedure ButtonAplicarDescontoClick(Sender: TObject);
    procedure ButtonSairClick(Sender: TObject);
    procedure TimerAtualizacaoTimer(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButtonVendaClick(Sender: TObject);
  private
    FRepositorioProduto: TRepositorioProduto;
    FRepositorioVenda: TRepositorioVenda;
    FRepositorioOperador: TRepositorioOperador;
    FOperadorAtual: TOperador;
    FProdutoSelecionado: TProduto;
    FItemSelecionado: Integer;
    
    { Métodos Privados }
    procedure InicializarRepositorios;
    procedure RealizarLogin;
    procedure VerificarVendaPendente;
    procedure CarregarDadosIniciais;
    procedure CarregarProdutosNaGrid(AProdutos: TObjectList<TProduto>);
    procedure AtualizarUICarrinho;
    procedure AtualizarResumoVenda;
    procedure ExibirMensagem(AMensagem: string; AErro: Boolean = False);
    procedure AjustarLayoutResponsivo;
    procedure ConfigurarEstilos;
    procedure InicializarComponentes;
  public
    { Public declarations }
  end;
var
  FormPrincipalResponsivo: TFormPrincipalResponsivo;
implementation
{$R *.fmx}
const
  ALTURA_CABECALHO = 80;
  ALTURA_MENU = 60;
  ALTURA_RODAPE = 50;
  LARGURA_PAINEL_DIREITO_PERCENTUAL = 0.40;
  
  COR_CABECALHO = $FF1A1A1A;
  COR_TEXTO_CLARO = $FFFFFFFF;
  COR_DESTAQUE = $FFFF4500;
  COR_SUCESSO = $FF00AA00;
  COR_ERRO = $FFFF0000;
{$REGION 'Inicialização'}
procedure TFormPrincipalResponsivo.FormCreate(Sender: TObject);
begin
  // Inicializar repositórios
  InicializarRepositorios;
  
  // Configurar estilos
  ConfigurarEstilos;
  
  // Inicializar componentes
  InicializarComponentes;
  
  // Iniciar timer de atualização
  TimerAtualizacao.Interval := 1000;
  TimerAtualizacao.Enabled := True;
end;
procedure TFormPrincipalResponsivo.FormShow(Sender: TObject);
begin
  // Conectar ao banco de dados
  if not DMConexao.Conectar then
  begin
    ShowMessage('Erro ao conectar ao banco de dados');
    Close;
    Exit;
  end;
  
  // Realizar login
  RealizarLogin;
  
  // Verificar venda pendente
  VerificarVendaPendente;
  
  // Carregar dados iniciais
  CarregarDadosIniciais;
  
  // Ajustar layout responsivo
  AjustarLayoutResponsivo;
end;
procedure TFormPrincipalResponsivo.FormDestroy(Sender: TObject);
begin
  if Assigned(FRepositorioProduto) then
    FRepositorioProduto.Free;
  if Assigned(FRepositorioVenda) then
    FRepositorioVenda.Free;
  if Assigned(FRepositorioOperador) then
    FRepositorioOperador.Free;
  if Assigned(FOperadorAtual) then
    FOperadorAtual.Free;
end;
procedure TFormPrincipalResponsivo.FormResize(Sender: TObject);
begin
  AjustarLayoutResponsivo;
end;
{$ENDREGION}
{$REGION 'Métodos Privados'}
procedure TFormPrincipalResponsivo.InicializarRepositorios;
begin
  FRepositorioProduto := TRepositorioProduto.Create;
  FRepositorioVenda := TRepositorioVenda.Create;
  FRepositorioOperador := TRepositorioOperador.Create;
  FOperadorAtual := nil;
  FProdutoSelecionado := nil;
  FItemSelecionado := -1;
end;
procedure TFormPrincipalResponsivo.ConfigurarEstilos;
begin
  // Configurar cores do cabeçalho
  RectangloCabecalho.Fill.Color := COR_CABECALHO;
  LabelTitulo.TextSettings.FontColor := COR_DESTAQUE;
  LabelOperador.TextSettings.FontColor := COR_TEXTO_CLARO;
  LabelCaixa.TextSettings.FontColor := COR_TEXTO_CLARO;
  
  // Configurar cores dos botões
  ButtonVenda.TextSettings.FontColor := COR_TEXTO_CLARO;
  ButtonCaixa.TextSettings.FontColor := COR_TEXTO_CLARO;
  ButtonRelatorios.TextSettings.FontColor := COR_TEXTO_CLARO;
  ButtonSair.TextSettings.FontColor := COR_ERRO;
  
  // Configurar cores dos labels
  LabelProdutos.TextSettings.FontColor := COR_DESTAQUE;
  LabelCarrinho.TextSettings.FontColor := COR_DESTAQUE;
  LabelResumo.TextSettings.FontColor := COR_DESTAQUE;
end;
procedure TFormPrincipalResponsivo.InicializarComponentes;
var
  Coluna: TColumn;
  I: Integer;
begin
  // Limpar dados existentes
  GridProdutos.RowCount := 1;
  GridProdutos.ClearColumns;

  // Adicionar 5 colunas
  Coluna := TStringColumn.Create(GridProdutos);
  Coluna.Header := 'ID';
  Coluna.Width := 50;
  GridProdutos.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridProdutos);
  Coluna.Header := 'Nome';
  Coluna.Width := 150;
  GridProdutos.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridProdutos);
  Coluna.Header := 'Categoria';
  Coluna.Width := 100;
  GridProdutos.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridProdutos);
  Coluna.Header := 'Preço';
  Coluna.Width := 80;
  GridProdutos.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridProdutos);
  Coluna.Header := 'Estoque';
  Coluna.Width := 60;
  GridProdutos.AddObject(Coluna);

//----------------------------------------------
  GridCarrinho.RowCount := 1;
  GridCarrinho.ClearColumns;

  // Adicionar 5 colunas
  Coluna := TStringColumn.Create(GridCarrinho);
  Coluna.Header := 'ID';
  Coluna.Width := 50;
  GridCarrinho.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridCarrinho);
  Coluna.Header := 'Produto';
  Coluna.Width := 150;
  GridCarrinho.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridCarrinho);
  Coluna.Header := 'Qtd';
  Coluna.Width := 100;
  GridCarrinho.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridCarrinho);
  Coluna.Header := 'Valor Unit.';
  Coluna.Width := 80;
  GridCarrinho.AddObject(Coluna);

  Coluna := TStringColumn.Create(GridCarrinho);
  Coluna.Header := 'Total';
  Coluna.Width := 60;
  GridCarrinho.AddObject(Coluna);
  // Configurar EditBuscaProduto
  EditBuscaProduto.Text := '';
  EditBuscaProduto.Hint := 'Digite para buscar...';
end;
procedure TFormPrincipalResponsivo.RealizarLogin;
var
  FormLogin: TFormLogin;
begin
  FormLogin := TFormLogin.Create(nil);
  try
    if FormLogin.ShowModal = mrOk then
    begin
      FOperadorAtual := FormLogin.OperadorAutenticado;
      LabelOperador.Text := 'Operador: ' + FOperadorAtual.Nome + ' (' + FOperadorAtual.Matricula + ')';
      ExibirMensagem('Login realizado com sucesso!', False);
    end
    else
    begin
      ShowMessage('Acesso negado');
      Close;
    end;
  finally
    FormLogin.Free;
  end;
end;
procedure TFormPrincipalResponsivo.VerificarVendaPendente;
begin
  // TODO: Implementar lógica de recuperação de venda pendente
  // Usar TRecuperacaoVendas para verificar se existe venda pendente
end;
procedure TFormPrincipalResponsivo.CarregarDadosIniciais;
begin
  // Iniciar nova venda
  FRepositorioVenda.IniciarVenda(FOperadorAtual.ID);
  
  // Carregar todos os produtos
  CarregarProdutosNaGrid(FRepositorioProduto.ObterTodos);
  
  // Atualizar UI
  AtualizarResumoVenda;
end;
procedure TFormPrincipalResponsivo.CarregarProdutosNaGrid(AProdutos: TObjectList<TProduto>);
var
  Produto: TProduto;
  I: Integer;
begin
  try
    // Limpar grid
    GridProdutos.RowCount := 1;
    
    if not Assigned(AProdutos) then
      Exit;
    
    // Definir número de linhas
    GridProdutos.RowCount := AProdutos.Count + 1;
    
    // Carregar dados
    for I := 0 to AProdutos.Count - 1 do
    begin
      Produto := AProdutos[I];
      GridProdutos.Cells[0, I + 1] := IntToStr(Produto.ID);
      GridProdutos.Cells[1, I + 1] := Produto.Nome;
      GridProdutos.Cells[2, I + 1] := Produto.CategoriaNome;
      GridProdutos.Cells[3, I + 1] := FormatFloat('0.00', Produto.Preco);
      GridProdutos.Cells[4, I + 1] := IntToStr(Produto.Estoque);
    end;
    
    AProdutos.Free;
  except
    on E: Exception do
      ExibirMensagem('Erro ao carregar produtos: ' + E.Message, True);
  end;
end;
procedure TFormPrincipalResponsivo.AtualizarUICarrinho;
var
  Item: TItemVenda;
  I: Integer;
begin
  try
    // Limpar grid
    GridCarrinho.RowCount := 1;
    
    if not Assigned(FRepositorioVenda.VendaAtual) then
      Exit;
    
    // Definir número de linhas
    GridCarrinho.RowCount := FRepositorioVenda.VendaAtual.Itens.Count + 1;
    
    // Carregar dados
    for I := 0 to FRepositorioVenda.VendaAtual.Itens.Count - 1 do
    begin
      Item := FRepositorioVenda.VendaAtual.Itens[I];
      GridCarrinho.Cells[0, I + 1] := IntToStr(Item.Produto.ID);
      GridCarrinho.Cells[1, I + 1] := Item.Produto.Nome;
      GridCarrinho.Cells[2, I + 1] := FormatFloat('0.00', Item.Quantidade);
      GridCarrinho.Cells[3, I + 1] := FormatFloat('0.00', Item.Produto.Preco);
      GridCarrinho.Cells[4, I + 1] := FormatFloat('0.00', Item.ValorTotal);
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao atualizar carrinho: ' + E.Message, True);
  end;
end;
procedure TFormPrincipalResponsivo.AtualizarResumoVenda;
var
  Venda: TVenda;
begin
  try
    Venda := FRepositorioVenda.VendaAtual;
    
    if not Assigned(Venda) then
      Exit;
    
    LabelSubtotal.Text := 'Subtotal: R$ ' + FormatFloat('0.00', Venda.Subtotal);
    LabelDesconto.Text := 'Desconto: R$ ' + FormatFloat('0.00', Venda.Desconto);
    LabelAcrescimo.Text := 'Acréscimo: R$ ' + FormatFloat('0.00', Venda.Acrescimo);
    LabelTotal.Text := 'TOTAL: R$ ' + FormatFloat('0.00', Venda.Total);
  except
    on E: Exception do
      ExibirMensagem('Erro ao atualizar resumo: ' + E.Message, True);
  end;
end;
procedure TFormPrincipalResponsivo.ExibirMensagem(AMensagem: string; AErro: Boolean = False);
begin
  LabelStatusBar.Text := AMensagem;
  
  if AErro then
    LabelStatusBar.TextSettings.FontColor := COR_ERRO
  else
    LabelStatusBar.TextSettings.FontColor := COR_SUCESSO;
end;
procedure TFormPrincipalResponsivo.AjustarLayoutResponsivo;
var
  LarguraPainelDireito: Single;
begin
  // Calcular largura do painel direito
  LarguraPainelDireito := LayoutCorpo.Width * LARGURA_PAINEL_DIREITO_PERCENTUAL;
  
  // Ajustar layouts
  LayoutPainelEsquerdo.Width := LayoutCorpo.Width - LarguraPainelDireito;
  LayoutPainelDireito.Width := LarguraPainelDireito;
  LayoutPainelDireito.Position.X := LayoutPainelEsquerdo.Width;
end;
{$ENDREGION}
{$REGION 'Eventos de Busca e Seleção'}
procedure TFormPrincipalResponsivo.EditBuscaProdutoChange(Sender: TObject);
var
  Termo: string;
  Produtos: TObjectList<TProduto>;
begin
  Termo := EditBuscaProduto.Text;
  
  if Termo = '' then
    Produtos := FRepositorioProduto.ObterTodos
  else
    Produtos := FRepositorioProduto.BuscarPorNome(Termo);
  
  CarregarProdutosNaGrid(Produtos);
end;
procedure TFormPrincipalResponsivo.GridProdutosSelectCell(Sender: TObject; const ACol, ARow: Integer);
var
  ProdutoID: Integer;
begin
  if ARow > 0 then
  begin
    if TryStrToInt(GridProdutos.Cells[0, ARow], ProdutoID) then
    begin
      FProdutoSelecionado := FRepositorioProduto.ObterPorID(ProdutoID);
      if Assigned(FProdutoSelecionado) then
        ExibirMensagem('Produto selecionado: ' + FProdutoSelecionado.Nome, False);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'Eventos de Ação'}
procedure TFormPrincipalResponsivo.ButtonAdicionarProdutoClick(Sender: TObject);
begin
  if not Assigned(FProdutoSelecionado) then
  begin
    ExibirMensagem('Selecione um produto primeiro!', True);
    Exit;
  end;
  
  if FRepositorioVenda.AdicionarItem(FProdutoSelecionado, 1) then
  begin
    AtualizarUICarrinho;
    AtualizarResumoVenda;
    ExibirMensagem('Produto adicionado ao carrinho!', False);
  end
  else
  begin
    ExibirMensagem('Erro: ' + FRepositorioVenda.UltimoErro, True);
  end;
end;
procedure TFormPrincipalResponsivo.ButtonRemoverItemClick(Sender: TObject);
begin
  if FItemSelecionado < 0 then
  begin
    ExibirMensagem('Selecione um item do carrinho!', True);
    Exit;
  end;
  
  if FRepositorioVenda.RemoverItem(FItemSelecionado) then
  begin
    AtualizarUICarrinho;
    AtualizarResumoVenda;
    ExibirMensagem('Item removido do carrinho!', False);
  end
  else
  begin
    ExibirMensagem('Erro: ' + FRepositorioVenda.UltimoErro, True);
  end;
end;
procedure TFormPrincipalResponsivo.ButtonLimparCarrinhoClick(Sender: TObject);
begin
  if MessageDlg('Deseja limpar o carrinho?', TMsgDlgType.mtConfirmation, 
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    FRepositorioVenda.LimparVendaAtual;
    FRepositorioVenda.IniciarVenda(FOperadorAtual.ID);
    AtualizarUICarrinho;
    AtualizarResumoVenda;
    ExibirMensagem('Carrinho limpo!', False);
  end;
end;
procedure TFormPrincipalResponsivo.ButtonAplicarDescontoClick(Sender: TObject);
var
  Desconto: string;
  Valor: Double;
begin
  if InputQuery('Desconto', 'Digite o valor do desconto:', Desconto) then
  begin
    if TryStrToFloat(Desconto, Valor) then
    begin
      if FRepositorioVenda.AplicarDesconto(Valor, False) then
      begin
        AtualizarResumoVenda;
        ExibirMensagem('Desconto aplicado: R$ ' + FormatFloat('0.00', Valor), False);
      end
      else
      begin
        ExibirMensagem('Erro: ' + FRepositorioVenda.UltimoErro, True);
      end;
    end
    else
    begin
      ExibirMensagem('Valor inválido!', True);
    end;
  end;
end;
procedure TFormPrincipalResponsivo.ButtonFinalizarVendaClick(Sender: TObject);
begin
  // TODO: Abrir tela de finalização de venda (TFormFinalizacao)
  ExibirMensagem('Tela de finalização em desenvolvimento...', False);
end;

procedure TFormPrincipalResponsivo.ButtonSairClick(Sender: TObject);
begin
  if MessageDlg('Deseja sair do sistema?', TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    Close;
  end;
end;

procedure TFormPrincipalResponsivo.ButtonVendaClick(Sender: TObject);
begin

end;

{$ENDREGION}
{$REGION 'Timer'}
procedure TFormPrincipalResponsivo.TimerAtualizacaoTimer(Sender: TObject);
begin
  LabelHora.Text := FormatDateTime('HH:mm:ss', Now);
end;
{$ENDREGION}
end.
