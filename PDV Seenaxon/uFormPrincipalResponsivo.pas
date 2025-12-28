unit uFormPrincipalResponsivo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Layouts, FMX.Objects, FMX.ListBox, FMX.Controls.Presentation,
  FMX.ScrollBox, FMX.Grid, FMX.Grid.Style, System.Generics.Collections,
  uOperador, uProduto, uItemVenda, uVenda, uCaixa, uRepositorioProdutos,
  uRepositorioOperador, uRepositorioCaixa, uDMConexao, uFormLogin,
  uRecuperacaoVendas, uImpressoraFiscal;

type
  {$REGION 'Constantes'}
  
  const
    // Dimensões
    ALTURA_CABECALHO = 80;
    ALTURA_MENU = 60;
    ALTURA_RODAPE = 50;
    LARGURA_PAINEL_DIREITO_PERCENTUAL = 0.40;
    
    // Cores
    COR_CABECALHO = $FF1A1A1A;
    COR_TEXTO_CLARO = $FFFFFFFF;
    COR_DESTAQUE = $FFFF4500;
    COR_SUCESSO = $FF00AA00;
    COR_ERRO = $FFFF0000;
  
  {$ENDREGION}

  {$REGION 'Classe TFormPrincipalResponsivo'}
  
  TFormPrincipalResponsivo = class(TForm)
    // Componentes de Layout Principal
    LayoutPrincipal: TLayout;
    LayoutCabecalho: TLayout;
    LayoutCorpo: TLayout;
    LayoutRodape: TLayout;
    
    // Componentes do Cabeçalho
    RectangloCabecalho: TRectangle;
    LabelTitulo: TLabel;
    LabelOperador: TLabel;
    LabelCaixa: TLabel;
    ButtonSair: TButton;
    
    // Componentes do Menu
    LayoutMenu: TLayout;
    ButtonVenda: TButton;
    ButtonCaixa: TButton;
    ButtonRelatorios: TButton;
    
    // Componentes do Corpo
    LayoutPainelEsquerdo: TLayout;
    LayoutPainelDireito: TLayout;
    
    // Painel Esquerdo (Produtos)
    LabelProdutos: TLabel;
    EditBuscaProduto: TEdit;
    GridProdutos: TStringGrid;
    
    // Painel Direito (Carrinho)
    LabelCarrinho: TLabel;
    GridCarrinho: TStringGrid;
    LabelResumo: TLabel;
    LabelSubtotal: TLabel;
    LabelDesconto: TLabel;
    LabelAcrescimo: TLabel;
    LabelTotal: TLabel;
    
    // Botões de Ação
    LayoutBotoesAcao: TLayout;
    ButtonAdicionarProduto: TButton;
    ButtonRemoverItem: TButton;
    ButtonAplicarDesconto: TButton;
    ButtonFinalizarVenda: TButton;
    ButtonLimparCarrinho: TButton;
    
    // Componentes do Rodapé
    LabelStatusBar: TLabel;
    LabelHora: TLabel;
    
    // Eventos
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    
    procedure ButtonSairClick(Sender: TObject);
    procedure ButtonVendaClick(Sender: TObject);
    procedure ButtonCaixaClick(Sender: TObject);
    procedure ButtonRelatoriosClick(Sender: TObject);
    
    procedure EditBuscaProdutoChange(Sender: TObject);
    procedure GridProdutosSelectCell(Sender: TObject; const ACol, ARow: Integer);
    procedure GridCarrinhoSelectCell(Sender: TObject; const ACol, ARow: Integer);
    
    procedure ButtonAdicionarProdutoClick(Sender: TObject);
    procedure ButtonRemoverItemClick(Sender: TObject);
    procedure ButtonAplicarDescontoClick(Sender: TObject);
    procedure ButtonFinalizarVendaClick(Sender: TObject);
    procedure ButtonLimparCarrinhoClick(Sender: TObject);
    
    procedure TimerAtualizarHoraTimer(Sender: TObject);
    
  private
    // Repositórios
    FRepositorioProdutos: TRepositorioProdutos;
    FRepositorioOperador: TRepositorioOperador;
    FRepositorioCaixa: TRepositorioCaixa;
    FRecuperacaoVendas: TRecuperacaoVendas;
    FImpressoraFiscal: TImpressoraFiscal;
    
    // Dados da Sessão
    FOperadorAtual: TOperador;
    FCaixaAtual: TCaixa;
    FVendaAtual: TVenda;
    FProdutosSelecionados: TObjectList<TProduto>;
    
    // Componentes
    FTimerAtualizarHora: TTimer;
    
    /// <summary>Inicializar componentes</summary>
    procedure InicializarComponentes;
    
    /// <summary>Configurar estilos</summary>
    procedure ConfigurarEstilos;
    
    /// <summary>Realizar login</summary>
    function RealizarLogin: Boolean;
    
    /// <summary>Carregar dados iniciais</summary>
    procedure CarregarDadosIniciais;
    
    /// <summary>Verificar venda pendente</summary>
    procedure VerificarVendaPendente;
    
    /// <summary>Carregar produtos na grid</summary>
    procedure CarregarProdutos(ABusca: string = '');
    
    /// <summary>Atualizar UI do carrinho</summary>
    procedure AtualizarUICarrinho;
    
    /// <summary>Atualizar resumo de venda</summary>
    procedure AtualizarResumoVenda;
    
    /// <summary>Ajustar layout responsivo</summary>
    procedure AjustarLayoutResponsivo;
    
    /// <summary>Exibir mensagem de status</summary>
    procedure ExibirMensagem(AMensagem: string; AErro: Boolean = False);
    
    /// <summary>Atualizar hora</summary>
    procedure AtualizarHora;
    
    /// <summary>Salvar venda pendente</summary>
    procedure SalvarVendaPendente;
    
    /// <summary>Limpar sessão</summary>
    procedure LimparSessao;
    
  public
    // Propriedades
    property OperadorAtual: TOperador read FOperadorAtual;
    property CaixaAtual: TCaixa read FCaixaAtual;
    property VendaAtual: TVenda read FVendaAtual;
  end;

var
  FormPrincipalResponsivo: TFormPrincipalResponsivo;

implementation

{$R *.fmx}

{$REGION 'Implementação TFormPrincipalResponsivo'}

procedure TFormPrincipalResponsivo.FormCreate(Sender: TObject);
begin
  // Inicializar repositórios
  FRepositorioProdutos := TRepositorioProdutos.Create;
  FRepositorioOperador := TRepositorioOperador.Create;
  FRepositorioCaixa := TRepositorioCaixa.Create;
  FRecuperacaoVendas := TRecuperacaoVendas.Create;
  FImpressoraFiscal := TImpressoraFiscal.Create;
  
  // Inicializar dados
  FOperadorAtual := nil;
  FCaixaAtual := nil;
  FVendaAtual := nil;
  FProdutosSelecionados := TObjectList<TProduto>.Create;
  
  // Configurar formulário
  Caption := 'PDV Seenaxon - Sistema de Ponto de Venda';
  Width := 1200;
  Height := 800;
  Position := TFormPosition.ScreenCenter;
  WindowState := TWindowState.wsMaximized;
  
  // Criar timer
  FTimerAtualizarHora := TTimer.Create(Self);
  FTimerAtualizarHora.Interval := 1000;
  FTimerAtualizarHora.OnTimer := TimerAtualizarHoraTimer;
  FTimerAtualizarHora.Enabled := True;
  
  // Inicializar componentes
  InicializarComponentes;
  ConfigurarEstilos;
end;

procedure TFormPrincipalResponsivo.FormShow(Sender: TObject);
begin
  // Conectar ao banco de dados
  if not DMConexao.EstaConectado then
  begin
    if not DMConexao.Conectar then
    begin
      ShowMessage('Erro ao conectar ao banco de dados: ' + DMConexao.UltimoErro);
      Close;
      Exit;
    end;
  end;
  
  // Realizar login
  if not RealizarLogin then
  begin
    Close;
    Exit;
  end;
  
  // Carregar dados iniciais
  CarregarDadosIniciais;
  
  // Verificar venda pendente
  VerificarVendaPendente;
  
  // Atualizar hora
  AtualizarHora;
end;

procedure TFormPrincipalResponsivo.FormDestroy(Sender: TObject);
begin
  // Salvar venda pendente
  if Assigned(FVendaAtual) and (FVendaAtual.Itens.Count > 0) then
    SalvarVendaPendente;
  
  // Limpar sessão
  LimparSessao;
  
  // Liberar repositórios
  if Assigned(FRepositorioProdutos) then
    FRepositorioProdutos.Free;
  if Assigned(FRepositorioOperador) then
    FRepositorioOperador.Free;
  if Assigned(FRepositorioCaixa) then
    FRepositorioCaixa.Free;
  if Assigned(FRecuperacaoVendas) then
    FRecuperacaoVendas.Free;
  if Assigned(FImpressoraFiscal) then
    FImpressoraFiscal.Free;
  if Assigned(FProdutosSelecionados) then
    FProdutosSelecionados.Free;
end;

procedure TFormPrincipalResponsivo.FormResize(Sender: TObject);
begin
  AjustarLayoutResponsivo;
end;

procedure TFormPrincipalResponsivo.FormKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  // Pressionar Escape para sair
  if Key = vkEscape then
  begin
    Key := 0;
    ButtonSairClick(nil);
  end;
end;

procedure TFormPrincipalResponsivo.InicializarComponentes;
begin
  // Layout Principal
  LayoutPrincipal := TLayout.Create(Self);
  LayoutPrincipal.Parent := Self;
  LayoutPrincipal.Align := TAlignLayout.Client;
  LayoutPrincipal.Padding.Left := 0;
  LayoutPrincipal.Padding.Top := 0;
  LayoutPrincipal.Padding.Right := 0;
  LayoutPrincipal.Padding.Bottom := 0;
  
  // Layout Cabeçalho
  LayoutCabecalho := TLayout.Create(Self);
  LayoutCabecalho.Parent := LayoutPrincipal;
  LayoutCabecalho.Align := TAlignLayout.Top;
  LayoutCabecalho.Height := ALTURA_CABECALHO;
  
  RectangloCabecalho := TRectangle.Create(Self);
  RectangloCabecalho.Parent := LayoutCabecalho;
  RectangloCabecalho.Align := TAlignLayout.Client;
  RectangloCabecalho.Fill.Color := TAlphaColorRec.Create(COR_CABECALHO);
  RectangloCabecalho.Stroke.Kind := TBrushKind.None;
  
  LabelTitulo := TLabel.Create(Self);
  LabelTitulo.Parent := LayoutCabecalho;
  LabelTitulo.Text := 'PDV SEENAXON';
  LabelTitulo.TextSettings.FontColor := TAlphaColorRec.Create(COR_TEXTO_CLARO);
  LabelTitulo.TextSettings.Font.Size := 24;
  LabelTitulo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LabelTitulo.Align := TAlignLayout.Left;
  LabelTitulo.Margins.Left := 20;
  LabelTitulo.Margins.Top := 10;
  LabelTitulo.Width := 300;
  
  LabelOperador := TLabel.Create(Self);
  LabelOperador.Parent := LayoutCabecalho;
  LabelOperador.Text := 'Operador: -';
  LabelOperador.TextSettings.FontColor := TAlphaColorRec.Create(COR_TEXTO_CLARO);
  LabelOperador.TextSettings.Font.Size := 12;
  LabelOperador.Align := TAlignLayout.Left;
  LabelOperador.Margins.Left := 20;
  LabelOperador.Margins.Top := 45;
  LabelOperador.Width := 300;
  
  LabelCaixa := TLabel.Create(Self);
  LabelCaixa.Parent := LayoutCabecalho;
  LabelCaixa.Text := 'Caixa: Fechado';
  LabelCaixa.TextSettings.FontColor := TAlphaColorRec.Create(COR_ERRO);
  LabelCaixa.TextSettings.Font.Size := 12;
  LabelCaixa.Align := TAlignLayout.Left;
  LabelCaixa.Margins.Left := 320;
  LabelCaixa.Margins.Top := 45;
  LabelCaixa.Width := 300;
  
  ButtonSair := TButton.Create(Self);
  ButtonSair.Parent := LayoutCabecalho;
  ButtonSair.Text := 'SAIR';
  ButtonSair.Align := TAlignLayout.Right;
  ButtonSair.Width := 100;
  ButtonSair.Margins.Right := 20;
  ButtonSair.Margins.Top := 15;
  ButtonSair.OnClick := ButtonSairClick;
  
  // Layout Menu
  LayoutMenu := TLayout.Create(Self);
  LayoutMenu.Parent := LayoutPrincipal;
  LayoutMenu.Align := TAlignLayout.Top;
  LayoutMenu.Height := ALTURA_MENU;
  
  ButtonVenda := TButton.Create(Self);
  ButtonVenda.Parent := LayoutMenu;
  ButtonVenda.Text := 'VENDA';
  ButtonVenda.Align := TAlignLayout.Left;
  ButtonVenda.Width := 150;
  ButtonVenda.OnClick := ButtonVendaClick;
  
  ButtonCaixa := TButton.Create(Self);
  ButtonCaixa.Parent := LayoutMenu;
  ButtonCaixa.Text := 'CAIXA';
  ButtonCaixa.Align := TAlignLayout.Left;
  ButtonCaixa.Width := 150;
  ButtonCaixa.Margins.Left := 5;
  ButtonCaixa.OnClick := ButtonCaixaClick;
  
  ButtonRelatorios := TButton.Create(Self);
  ButtonRelatorios.Parent := LayoutMenu;
  ButtonRelatorios.Text := 'RELATÓRIOS';
  ButtonRelatorios.Align := TAlignLayout.Left;
  ButtonRelatorios.Width := 150;
  ButtonRelatorios.Margins.Left := 5;
  ButtonRelatorios.OnClick := ButtonRelatoriosClick;
  
  // Layout Corpo
  LayoutCorpo := TLayout.Create(Self);
  LayoutCorpo.Parent := LayoutPrincipal;
  LayoutCorpo.Align := TAlignLayout.Client;
  
  // Painel Esquerdo (Produtos)
  LayoutPainelEsquerdo := TLayout.Create(Self);
  LayoutPainelEsquerdo.Parent := LayoutCorpo;
  LayoutPainelEsquerdo.Align := TAlignLayout.Left;
  LayoutPainelEsquerdo.Width := Trunc(Self.Width * (1 - LARGURA_PAINEL_DIREITO_PERCENTUAL));
  LayoutPainelEsquerdo.Padding.Left := 10;
  LayoutPainelEsquerdo.Padding.Top := 10;
  LayoutPainelEsquerdo.Padding.Right := 5;
  LayoutPainelEsquerdo.Padding.Bottom := 10;
  
  LabelProdutos := TLabel.Create(Self);
  LabelProdutos.Parent := LayoutPainelEsquerdo;
  LabelProdutos.Text := 'PRODUTOS';
  LabelProdutos.TextSettings.Font.Size := 14;
  LabelProdutos.TextSettings.Font.Style := [TFontStyle.fsBold];
  LabelProdutos.Align := TAlignLayout.Top;
  LabelProdutos.Height := 25;
  
  EditBuscaProduto := TEdit.Create(Self);
  EditBuscaProduto.Parent := LayoutPainelEsquerdo;
  EditBuscaProduto.Hint := 'Buscar produto...';
  EditBuscaProduto.Align := TAlignLayout.Top;
  EditBuscaProduto.Height := 35;
  EditBuscaProduto.Margins.Top := 5;
  EditBuscaProduto.Margins.Bottom := 10;
  EditBuscaProduto.OnChange := EditBuscaProdutoChange;
  
  GridProdutos := TStringGrid.Create(Self);
  GridProdutos.Parent := LayoutPainelEsquerdo;
  GridProdutos.Align := TAlignLayout.Client;
  GridProdutos.OnSelectCell := GridProdutosSelectCell;
  
  // Painel Direito (Carrinho)
  LayoutPainelDireito := TLayout.Create(Self);
  LayoutPainelDireito.Parent := LayoutCorpo;
  LayoutPainelDireito.Align := TAlignLayout.Right;
  LayoutPainelDireito.Width := Trunc(Self.Width * LARGURA_PAINEL_DIREITO_PERCENTUAL);
  LayoutPainelDireito.Padding.Left := 5;
  LayoutPainelDireito.Padding.Top := 10;
  LayoutPainelDireito.Padding.Right := 10;
  LayoutPainelDireito.Padding.Bottom := 10;
  
  LabelCarrinho := TLabel.Create(Self);
  LabelCarrinho.Parent := LayoutPainelDireito;
  LabelCarrinho.Text := 'CARRINHO';
  LabelCarrinho.TextSettings.Font.Size := 14;
  LabelCarrinho.TextSettings.Font.Style := [TFontStyle.fsBold];
  LabelCarrinho.Align := TAlignLayout.Top;
  LabelCarrinho.Height := 25;
  
  GridCarrinho := TStringGrid.Create(Self);
  GridCarrinho.Parent := LayoutPainelDireito;
  GridCarrinho.Align := TAlignLayout.Top;
  GridCarrinho.Height := 200;
  GridCarrinho.Margins.Top := 5;
  GridCarrinho.Margins.Bottom := 10;
  GridCarrinho.OnSelectCell := GridCarrinhoSelectCell;
  
  // Resumo
  LabelResumo := TLabel.Create(Self);
  LabelResumo.Parent := LayoutPainelDireito;
  LabelResumo.Text := 'RESUMO';
  LabelResumo.TextSettings.Font.Size := 12;
  LabelResumo.TextSettings.Font.Style := [TFontStyle.fsBold];
  LabelResumo.Align := TAlignLayout.Top;
  LabelResumo.Height := 20;
  LabelResumo.Margins.Top := 5;
  
  LabelSubtotal := TLabel.Create(Self);
  LabelSubtotal.Parent := LayoutPainelDireito;
  LabelSubtotal.Text := 'Subtotal: R$ 0,00';
  LabelSubtotal.Align := TAlignLayout.Top;
  LabelSubtotal.Height := 20;
  LabelSubtotal.Margins.Top := 3;
  
  LabelDesconto := TLabel.Create(Self);
  LabelDesconto.Parent := LayoutPainelDireito;
  LabelDesconto.Text := 'Desconto: R$ 0,00';
  LabelDesconto.Align := TAlignLayout.Top;
  LabelDesconto.Height := 20;
  LabelDesconto.Margins.Top := 3;
  
  LabelAcrescimo := TLabel.Create(Self);
  LabelAcrescimo.Parent := LayoutPainelDireito;
  LabelAcrescimo.Text := 'Acréscimo: R$ 0,00';
  LabelAcrescimo.Align := TAlignLayout.Top;
  LabelAcrescimo.Height := 20;
  LabelAcrescimo.Margins.Top := 3;
  
  LabelTotal := TLabel.Create(Self);
  LabelTotal.Parent := LayoutPainelDireito;
  LabelTotal.Text := 'Total: R$ 0,00';
  LabelTotal.TextSettings.Font.Size := 14;
  LabelTotal.TextSettings.Font.Style := [TFontStyle.fsBold];
  LabelTotal.TextSettings.FontColor := TAlphaColorRec.Create(COR_DESTAQUE);
  LabelTotal.Align := TAlignLayout.Top;
  LabelTotal.Height := 25;
  LabelTotal.Margins.Top := 10;
  
  // Botões de Ação
  LayoutBotoesAcao := TLayout.Create(Self);
  LayoutBotoesAcao.Parent := LayoutPainelDireito;
  LayoutBotoesAcao.Align := TAlignLayout.Client;
  LayoutBotoesAcao.Margins.Top := 10;
  
  ButtonAdicionarProduto := TButton.Create(Self);
  ButtonAdicionarProduto.Parent := LayoutBotoesAcao;
  ButtonAdicionarProduto.Text := 'ADICIONAR';
  ButtonAdicionarProduto.Align := TAlignLayout.Top;
  ButtonAdicionarProduto.Height := 40;
  ButtonAdicionarProduto.Margins.Bottom := 5;
  ButtonAdicionarProduto.OnClick := ButtonAdicionarProdutoClick;
  
  ButtonRemoverItem := TButton.Create(Self);
  ButtonRemoverItem.Parent := LayoutBotoesAcao;
  ButtonRemoverItem.Text := 'REMOVER';
  ButtonRemoverItem.Align := TAlignLayout.Top;
  ButtonRemoverItem.Height := 40;
  ButtonRemoverItem.Margins.Bottom := 5;
  ButtonRemoverItem.OnClick := ButtonRemoverItemClick;
  
  ButtonAplicarDesconto := TButton.Create(Self);
  ButtonAplicarDesconto.Parent := LayoutBotoesAcao;
  ButtonAplicarDesconto.Text := 'DESCONTO';
  ButtonAplicarDesconto.Align := TAlignLayout.Top;
  ButtonAplicarDesconto.Height := 40;
  ButtonAplicarDesconto.Margins.Bottom := 5;
  ButtonAplicarDesconto.OnClick := ButtonAplicarDescontoClick;
  
  ButtonFinalizarVenda := TButton.Create(Self);
  ButtonFinalizarVenda.Parent := LayoutBotoesAcao;
  ButtonFinalizarVenda.Text := 'FINALIZAR';
  ButtonFinalizarVenda.Align := TAlignLayout.Top;
  ButtonFinalizarVenda.Height := 40;
  ButtonFinalizarVenda.Margins.Bottom := 5;
  ButtonFinalizarVenda.OnClick := ButtonFinalizarVendaClick;
  
  ButtonLimparCarrinho := TButton.Create(Self);
  ButtonLimparCarrinho.Parent := LayoutBotoesAcao;
  ButtonLimparCarrinho.Text := 'LIMPAR';
  ButtonLimparCarrinho.Align := TAlignLayout.Top;
  ButtonLimparCarrinho.Height := 40;
  ButtonLimparCarrinho.OnClick := ButtonLimparCarrinhoClick;
  
  // Layout Rodapé
  LayoutRodape := TLayout.Create(Self);
  LayoutRodape.Parent := LayoutPrincipal;
  LayoutRodape.Align := TAlignLayout.Bottom;
  LayoutRodape.Height := ALTURA_RODAPE;
  
  LabelStatusBar := TLabel.Create(Self);
  LabelStatusBar.Parent := LayoutRodape;
  LabelStatusBar.Text := 'Pronto';
  LabelStatusBar.Align := TAlignLayout.Left;
  LabelStatusBar.Margins.Left := 10;
  LabelStatusBar.Margins.Top := 15;
  
  LabelHora := TLabel.Create(Self);
  LabelHora.Parent := LayoutRodape;
  LabelHora.Text := '';
  LabelHora.Align := TAlignLayout.Right;
  LabelHora.Margins.Right := 10;
  LabelHora.Margins.Top := 15;
end;

procedure TFormPrincipalResponsivo.ConfigurarEstilos;
begin
  // Configurar cores
  Self.Fill.Color := TAlphaColorRec.White;
end;

function TFormPrincipalResponsivo.RealizarLogin: Boolean;
var
  FormLogin: TFormLogin;
begin
  Result := False;
  
  FormLogin := TFormLogin.Create(nil);
  try
    if FormLogin.ShowModal = mrOk then
    begin
      FOperadorAtual := FormLogin.OperadorAutenticado;
      if Assigned(FOperadorAtual) then
      begin
        LabelOperador.Text := 'Operador: ' + FOperadorAtual.Nome + ' (' + FOperadorAtual.Matricula + ')';
        Result := True;
      end;
    end;
  finally
    FormLogin.Free;
  end;
end;

procedure TFormPrincipalResponsivo.CarregarDadosIniciais;
begin
  // Criar venda inicial
  FVendaAtual := TVenda.Create;
  FVendaAtual.OperadorID := FOperadorAtual.ID;
  
  // Carregar produtos
  CarregarProdutos;
  
  // Atualizar UI
  AtualizarUICarrinho;
  AtualizarResumoVenda;
end;

procedure TFormPrincipalResponsivo.VerificarVendaPendente;
var
  VendaPendente: TVenda;
begin
  if FRecuperacaoVendas.TemVendaPendente then
  begin
    if MessageDlg('Existe uma venda pendente. Deseja retomá-la?', 
      TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    begin
      VendaPendente := FRecuperacaoVendas.CarregarVendaPendente;
      if Assigned(VendaPendente) then
      begin
        FVendaAtual.Free;
        FVendaAtual := VendaPendente;
        FRecuperacaoVendas.DeletarVendaPendente;
        
        AtualizarUICarrinho;
        AtualizarResumoVenda;
        ExibirMensagem('Venda retomada com sucesso!');
      end;
    end;
  end;
end;

procedure TFormPrincipalResponsivo.CarregarProdutos(ABusca: string = '');
var
  Produtos: TObjectList<TProduto>;
  Produto: TProduto;
  I: Integer;
begin
  try
    // Limpar grid
    GridProdutos.RowCount := 1;
    
    // Obter produtos
    if ABusca = '' then
      Produtos := FRepositorioProdutos.ObterTodos
    else
      Produtos := FRepositorioProdutos.BuscarPorNome(ABusca);
    
    if Assigned(Produtos) then
    begin
      GridProdutos.RowCount := Produtos.Count + 1;
      
      // Cabeçalho
      GridProdutos.Cells[0, 0] := 'ID';
      GridProdutos.Cells[1, 0] := 'Nome';
      GridProdutos.Cells[2, 0] := 'Categoria';
      GridProdutos.Cells[3, 0] := 'Preço';
      GridProdutos.Cells[4, 0] := 'Estoque';
      
      // Dados
      for I := 0 to Produtos.Count - 1 do
      begin
        Produto := Produtos[I];
        GridProdutos.Cells[0, I + 1] := IntToStr(Produto.ID);
        GridProdutos.Cells[1, I + 1] := Produto.Nome;
        GridProdutos.Cells[2, I + 1] := Produto.Categoria;
        GridProdutos.Cells[3, I + 1] := FormatFloat('0.00', Produto.Preco);
        GridProdutos.Cells[4, I + 1] := IntToStr(Produto.QuantidadeEstoque);
      end;
      
      Produtos.Free;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao carregar produtos: ' + E.Message, True);
  end;
end;

procedure TFormPrincipalResponsivo.AtualizarUICarrinho;
var
  I: Integer;
  Item: TItemVenda;
begin
  try
    // Limpar grid
    GridCarrinho.RowCount := 1;
    
    if Assigned(FVendaAtual) then
    begin
      GridCarrinho.RowCount := FVendaAtual.Itens.Count + 1;
      
      // Cabeçalho
      GridCarrinho.Cells[0, 0] := 'Produto';
      GridCarrinho.Cells[1, 0] := 'Qtd';
      GridCarrinho.Cells[2, 0] := 'Valor';
      GridCarrinho.Cells[3, 0] := 'Total';
      
      // Dados
      for I := 0 to FVendaAtual.Itens.Count - 1 do
      begin
        Item := FVendaAtual.Itens[I];
        GridCarrinho.Cells[0, I + 1] := Item.Produto.Nome;
        GridCarrinho.Cells[1, I + 1] := FormatFloat('0.00', Item.Quantidade);
        GridCarrinho.Cells[2, I + 1] := FormatFloat('0.00', Item.ValorUnitario);
        GridCarrinho.Cells[3, I + 1] := FormatFloat('0.00', Item.Total);
      end;
    end;
  except
    on E: Exception do
      ExibirMensagem('Erro ao atualizar carrinho: ' + E.Message, True);
  end;
end;

procedure TFormPrincipalResponsivo.AtualizarResumoVenda;
begin
  if Assigned(FVendaAtual) then
  begin
    LabelSubtotal.Text := 'Subtotal: R$ ' + FormatFloat('0.00', FVendaAtual.Subtotal);
    LabelDesconto.Text := 'Desconto: R$ ' + FormatFloat('0.00', FVendaAtual.Desconto);
    LabelAcrescimo.Text := 'Acréscimo: R$ ' + FormatFloat('0.00', FVendaAtual.Acrescimo);
    LabelTotal.Text := 'Total: R$ ' + FormatFloat('0.00', FVendaAtual.Total);
  end;
end;

procedure TFormPrincipalResponsivo.AjustarLayoutResponsivo;
begin
  if Assigned(LayoutPainelEsquerdo) then
    LayoutPainelEsquerdo.Width := Trunc(Self.Width * (1 - LARGURA_PAINEL_DIREITO_PERCENTUAL));
  
  if Assigned(LayoutPainelDireito) then
    LayoutPainelDireito.Width := Trunc(Self.Width * LARGURA_PAINEL_DIREITO_PERCENTUAL);
end;

procedure TFormPrincipalResponsivo.ExibirMensagem(AMensagem: string; AErro: Boolean = False);
begin
  LabelStatusBar.Text := AMensagem;
  
  if AErro then
    LabelStatusBar.TextSettings.FontColor := TAlphaColorRec.Create(COR_ERRO)
  else
    LabelStatusBar.TextSettings.FontColor := TAlphaColorRec.Create(COR_SUCESSO);
end;

procedure TFormPrincipalResponsivo.AtualizarHora;
begin
  LabelHora.Text := FormatDateTime('hh:mm:ss', Now);
end;

procedure TFormPrincipalResponsivo.SalvarVendaPendente;
begin
  try
    FRecuperacaoVendas.SalvarVendaPendente(FVendaAtual);
  except
    // Ignorar erros de salvamento
  end;
end;

procedure TFormPrincipalResponsivo.LimparSessao;
begin
  if Assigned(FOperadorAtual) then
    FOperadorAtual.Free;
  
  if Assigned(FCaixaAtual) then
    FCaixaAtual.Free;
  
  if Assigned(FVendaAtual) then
    FVendaAtual.Free;
end;

// Eventos de Botões do Menu
procedure TFormPrincipalResponsivo.ButtonVendaClick(Sender: TObject);
begin
  ExibirMensagem('Modo Venda ativado');
end;

procedure TFormPrincipalResponsivo.ButtonCaixaClick(Sender: TObject);
begin
  ExibirMensagem('Gerenciamento de Caixa');
end;

procedure TFormPrincipalResponsivo.ButtonRelatoriosClick(Sender: TObject);
begin
  ExibirMensagem('Relatórios');
end;

procedure TFormPrincipalResponsivo.ButtonSairClick(Sender: TObject);
begin
  if MessageDlg('Deseja sair do sistema?', TMsgDlgType.mtConfirmation, 
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    Close;
  end;
end;

// Eventos de Busca e Seleção
procedure TFormPrincipalResponsivo.EditBuscaProdutoChange(Sender: TObject);
begin
  CarregarProdutos(EditBuscaProduto.Text);
end;

procedure TFormPrincipalResponsivo.GridProdutosSelectCell(Sender: TObject; const ACol, ARow: Integer);
begin
  if ARow > 0 then
    ExibirMensagem('Produto selecionado: ' + GridProdutos.Cells[1, ARow]);
end;

procedure TFormPrincipalResponsivo.GridCarrinhoSelectCell(Sender: TObject; const ACol, ARow: Integer);
begin
  if ARow > 0 then
    ExibirMensagem('Item selecionado: ' + GridCarrinho.Cells[0, ARow]);
end;

// Eventos de Ação
procedure TFormPrincipalResponsivo.ButtonAdicionarProdutoClick(Sender: TObject);
begin
  ExibirMensagem('Adicionar produto ao carrinho');
end;

procedure TFormPrincipalResponsivo.ButtonRemoverItemClick(Sender: TObject);
begin
  ExibirMensagem('Remover item do carrinho');
end;

procedure TFormPrincipalResponsivo.ButtonAplicarDescontoClick(Sender: TObject);
begin
  ExibirMensagem('Aplicar desconto');
end;

procedure TFormPrincipalResponsivo.ButtonFinalizarVendaClick(Sender: TObject);
begin
  ExibirMensagem('Finalizando venda...');
end;

procedure TFormPrincipalResponsivo.ButtonLimparCarrinhoClick(Sender: TObject);
begin
  if MessageDlg('Deseja limpar o carrinho?', TMsgDlgType.mtConfirmation, 
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
  begin
    FVendaAtual.Itens.Clear;
    AtualizarUICarrinho;
    AtualizarResumoVenda;
    ExibirMensagem('Carrinho limpo');
  end;
end;

procedure TFormPrincipalResponsivo.TimerAtualizarHoraTimer(Sender: TObject);
begin
  AtualizarHora;
end;

{$ENDREGION}

end.
