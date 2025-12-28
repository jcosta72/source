program DelphiPDV;

uses
  System.StartUpCopy,
  FMX.Forms,
  uFormPrincipal in 'uFormPrincipal.pas' {FormPrincipal},
  uProduto in 'uProduto.pas',
  uItemVenda in 'uItemVenda.pas',
  uVenda in 'uVenda.pas',
  uOperador in 'uOperador.pas',
  uCaixa in 'uCaixa.pas',
  uRepositorioProdutos in 'uRepositorioProdutos.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormPrincipal, FormPrincipal);
  Application.Run;
end.
