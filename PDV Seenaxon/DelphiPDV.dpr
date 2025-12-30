program DelphiPDV;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFormPrincipalResponsivo in 'uFormPrincipalResponsivo.pas' {FormPrincipalResponsivo},
  uDMConexao in 'uDMConexao.pas' {DMConexao: TDataModule},
  uFormLogin in 'uFormLogin.pas' {FormLogin},
  uProduto in 'uProduto.pas',
  uItemVenda in 'uItemVenda.pas',
  uVenda in 'uVenda.pas',
  uOperador in 'uOperador.pas',
  uCaixa in 'uCaixa.pas',
  uRepositorioProduto in 'uRepositorioProduto.pas',
  uRepositorioOperador in 'uRepositorioOperador.pas',
  uRepositorioCaixa in 'uRepositorioCaixa.pas',
  uRepositorioVenda in 'uRepositorioVenda.pas',
  uCriptografiaSenha in 'uCriptografiaSenha.pas',
  uPersistenciaProduto in 'uPersistenciaProduto.pas',
  uPersistenciaOperador in 'uPersistenciaOperador.pas',
  uPersistenciaVenda in 'uPersistenciaVenda.pas',
  uPersistenciaCaixa in 'uPersistenciaCaixa.pas',
  uIntegracaoCaixa in 'uIntegracaoCaixa.pas',
  uIntegracaoRelatorios in 'uIntegracaoRelatorios.pas',
  uRecuperacaoVendas in 'uRecuperacaoVendas.pas',
  uRelatorios in 'uRelatorios.pas',
  uFormVendas in 'uFormVendas.pas' {FormVendas},
  uFormGerenciamentoCaixa in 'uFormGerenciamentoCaixa.pas' {FormGerenciamentoCaixa},
  uFormFinalizarVenda in 'uFormFinalizarVenda.pas' {FormFinalizarVenda};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TDMConexao, DMConexao);
  Application.CreateForm(TFormPrincipalResponsivo, FormPrincipalResponsivo);
  Application.Run;
end.
