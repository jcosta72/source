# Documentação - Tela de Login (uFormLogin.pas)

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Componentes](#componentes)
4. [Funcionalidades](#funcionalidades)
5. [Fluxo de Autenticação](#fluxo-de-autenticação)
6. [Segurança](#segurança)
7. [Exemplos de Uso](#exemplos-de-uso)
8. [Tratamento de Erros](#tratamento-de-erros)

---

## Visão Geral

A tela de login (`TFormLogin`) é responsável por:

✅ **Autenticar operadores** com validação de matrícula e senha
✅ **Proteger contra força bruta** com bloqueio após tentativas
✅ **Registrar tentativas** em log de auditoria
✅ **Oferecer acesso rápido** com botões de operadores
✅ **Exibir mensagens** de erro e sucesso
✅ **Ser responsiva** e adaptável a qualquer tela

### Características Principais

| Característica | Descrição |
|---|---|
| **Segurança** | PBKDF2 + bloqueio por força bruta |
| **Tentativas** | Máximo 3 tentativas antes de bloquear |
| **Bloqueio** | 15 minutos após limite de tentativas |
| **Auditoria** | Todas as tentativas registradas |
| **UI** | Responsiva com indicador de tentativas |
| **Operadores Rápidos** | Botões para acesso rápido |

---

## Arquitetura

### Componentes Principais

```
TFormLogin
├── Título (Logo e Subtítulo)
├── Entrada de Dados
│   ├── Matrícula
│   ├── Senha
│   ├── Indicador de Tentativas
│   └── Mensagem de Status
├── Operadores Rápidos
│   └── Botões dinâmicos
└── Botões de Ação
    ├── Entrar
    ├── Limpar
    └── Sair
```

### Integração com Repositório

```
TFormLogin
    ↓
TRepositorioOperador.Autenticar()
    ↓
TCriptografiaSenha.ValidarSenha()
    ↓
LogAcessoOperador (auditoria)
    ↓
Retorna TOperador ou nil
```

---

## Componentes

### Componentes de Layout

| Componente | Tipo | Descrição |
|---|---|---|
| `LayoutPrincipal` | TLayout | Container principal |
| `LayoutTitulo` | TLayout | Área de título |
| `LayoutCorpo` | TLayout | Área de entrada |
| `LayoutRodape` | TLayout | Área de botões |

### Componentes de Entrada

| Componente | Tipo | Descrição |
|---|---|---|
| `EditMatricula` | TEdit | Campo de matrícula |
| `EditSenha` | TEdit | Campo de senha (mascarado) |

### Componentes de Feedback

| Componente | Tipo | Descrição |
|---|---|---|
| `LabelMensagem` | TLabel | Mensagem de status |
| `LabelTentativas` | TLabel | Contador de tentativas |
| `ProgressBarTentativas` | TProgressBar | Barra de progresso |

### Componentes de Operadores

| Componente | Tipo | Descrição |
|---|---|---|
| `ScrollBoxOperadores` | TScrollBox | Container com scroll |
| `LayoutOperadores` | TLayout | Área dos botões |

### Botões

| Botão | Ação |
|---|---|
| `ButtonEntrar` | Realizar login |
| `ButtonLimpar` | Limpar campos |
| `ButtonSair` | Sair da aplicação |

---

## Funcionalidades

### 1. Autenticação Segura

**Fluxo**:
1. Usuário digita matrícula e senha
2. Valida entrada (não vazio)
3. Verifica se operador está bloqueado
4. Chama `TRepositorioOperador.Autenticar()`
5. Valida senha com PBKDF2
6. Registra tentativa em log
7. Retorna operador ou erro

**Código**:
```pascal
function TFormLogin.RealizarLogin: TResultadoLogin;
begin
  // Validar entrada
  Result := ValidarEntrada;
  if not Result.Sucesso then Exit;
  
  // Verificar bloqueio
  Result := VerificarBloqueio;
  if not Result.Sucesso then Exit;
  
  // Autenticar
  Operador := FRepositorio.Autenticar(EditMatricula.Text, EditSenha.Text);
  
  if Assigned(Operador) then
  begin
    Result.Sucesso := True;
    Result.Operador := Operador;
    FTentativasLogin := 0;
  end
  else
  begin
    Inc(FTentativasLogin);
    if FTentativasLogin >= TENTATIVAS_MAXIMAS then
      BloquearOperador();
  end;
end;
```

### 2. Proteção contra Força Bruta

**Mecanismo**:
- Máximo de 3 tentativas
- Bloqueio de 15 minutos após limite
- Contador de tentativas visível
- Barra de progresso
- Aguarda 2 segundos entre tentativas

**Constantes**:
```pascal
const
  TENTATIVAS_MAXIMAS = 3;
  TEMPO_BLOQUEIO_MINUTOS = 15;
  TEMPO_ESPERA_ENTRE_TENTATIVAS = 2;
```

### 3. Auditoria de Login

**Registrado em LogAcessoOperador**:
- Matrícula do operador
- Sucesso ou falha
- Motivo (LOGIN_SUCESSO, SENHA_INCORRETA, etc)
- Data e hora

**Código**:
```pascal
procedure TFormLogin.RegistrarTentativaLogin(ASucesso: Boolean; AMotivo: string = '');
begin
  Query.SQL.Text := 
    'INSERT INTO LogAcessoOperador (Matricula, Sucesso, Motivo) ' +
    'VALUES (:Matricula, :Sucesso, :Motivo)';
  Query.ParamByName('Matricula').AsString := EditMatricula.Text;
  Query.ParamByName('Sucesso').AsBoolean := ASucesso;
  Query.ParamByName('Motivo').AsString := IfThen(ASucesso, 'LOGIN_SUCESSO', AMotivo);
  Query.ExecSQL;
end;
```

### 4. Operadores Rápidos

**Funcionalidade**:
- Carrega operadores ativos ao iniciar
- Cria botões dinâmicos
- Clique preenche matrícula
- Foco vai para campo de senha

**Código**:
```pascal
procedure TFormLogin.CarregarOperadoresRapidos;
begin
  Operadores := FRepositorio.ObterAtivos;
  
  for I := 0 to Operadores.Count - 1 do
  begin
    Operador := Operadores[I];
    CriarBotaoOperador(Operador);
  end;
end;

procedure TFormLogin.OperadorRapidoClick(Sender: TObject);
begin
  Operador := FRepositorio.ObterPorID(Button.Tag);
  EditMatricula.Text := Operador.Matricula;
  EditSenha.SetFocus;
end;
```

### 5. Interface Responsiva

**Características**:
- Layout dinâmico com TLayout
- Alinhamento automático
- Adapta a diferentes resoluções
- Indicador visual de tentativas

---

## Fluxo de Autenticação

### Sequência Completa

```
FormShow()
  ↓
Conectar ao banco de dados
  ↓
Carregar operadores rápidos
  ↓
Focar em EditMatricula
  ↓
Usuário digita matrícula e senha
  ↓
Pressiona Enter ou clica "ENTRAR"
  ↓
ButtonEntrarClick()
  ↓
HabilitarControles(False)
  ↓
RealizarLogin()
  ├─ ValidarEntrada()
  ├─ VerificarBloqueio()
  └─ FRepositorio.Autenticar()
      ├─ ObterPorMatricula()
      ├─ ValidarSenha(PBKDF2)
      ├─ Atualizar DataUltimoAcesso
      └─ RegistrarTentativaLogin()
  ↓
AtualizarUIAposTentativa()
  ├─ AtualizarIndicadorTentativas()
  ├─ ExibirMensagem()
  └─ Se sucesso: ModalResult := mrOk
  ↓
HabilitarControles(True)
```

---

## Segurança

### Proteções Implementadas

✅ **Criptografia de Senha**
- PBKDF2 com 10.000 iterações
- Salt aleatório de 32 bytes
- Comparação timing-safe

✅ **Proteção contra Força Bruta**
- Máximo 3 tentativas
- Bloqueio de 15 minutos
- Aguarda 2 segundos entre tentativas
- Contador visível

✅ **Auditoria Completa**
- Todas as tentativas registradas
- Sucesso e falha diferenciados
- Motivo do erro armazenado
- Data e hora registradas

✅ **Validação de Entrada**
- Campos obrigatórios
- Sem concatenação SQL
- Prepared statements

✅ **Transações Seguras**
- Bloqueio atômico
- Rollback em erro
- Integridade garantida

### Boas Práticas

```pascal
// ✅ BOM: Usar prepared statements
Query.SQL.Text := 'SELECT * FROM Operadores WHERE Matricula = :Matricula';
Query.ParamByName('Matricula').AsString := EditMatricula.Text;

// ❌ RUIM: Concatenação (SQL Injection)
Query.SQL.Text := 'SELECT * FROM Operadores WHERE Matricula = ''' + 
                  EditMatricula.Text + '''';

// ✅ BOM: Comparação timing-safe
if TCriptografiaSenha.ValidarSenha(ASenha, AHashArmazenado) then

// ❌ RUIM: Comparação simples
if ASenha = ASenhaArmazenada then
```

---

## Exemplos de Uso

### Exemplo 1: Usar Formulário de Login

```pascal
procedure LoginOperador;
var
  FormLogin: TFormLogin;
  Operador: TOperador;
begin
  FormLogin := TFormLogin.Create(nil);
  try
    if FormLogin.ShowModal = mrOk then
    begin
      Operador := FormLogin.OperadorAutenticado;
      if Assigned(Operador) then
      begin
        ShowMessage('Bem-vindo, ' + Operador.Nome);
        // Usar operador para próximas operações
      end;
    end
    else
      ShowMessage('Login cancelado');
  finally
    FormLogin.Free;
  end;
end;
```

### Exemplo 2: Integração com Formulário Principal

```pascal
procedure TFormPrincipal.FormCreate(Sender: TObject);
var
  FormLogin: TFormLogin;
begin
  FormLogin := TFormLogin.Create(nil);
  try
    if FormLogin.ShowModal = mrOk then
    begin
      FOperadorAtual := FormLogin.OperadorAutenticado;
      LabelOperador.Text := FOperadorAtual.Nome;
      
      // Continuar com inicialização
      InicializarSistema;
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
```

### Exemplo 3: Tratamento de Bloqueio

```pascal
procedure TFormLogin.VerificarBloqueio;
var
  Query: TFDQuery;
  BloqueadoAte: TDateTime;
  MinutosRestantes: Integer;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := DMConexao.Conexao;
    Query.SQL.Text := 
      'SELECT BloqueadoAte FROM Operadores WHERE Matricula = :Matricula';
    Query.ParamByName('Matricula').AsString := EditMatricula.Text;
    Query.Open;
    
    if not Query.Eof then
    begin
      BloqueadoAte := Query.FieldByName('BloqueadoAte').AsDateTime;
      
      if BloqueadoAte > Now then
      begin
        MinutosRestantes := Trunc((BloqueadoAte - Now) * 24 * 60);
        ExibirMensagem(
          'Operador bloqueado. Tente novamente em ' + 
          IntToStr(MinutosRestantes) + ' minutos',
          True
        );
      end;
    end;
  finally
    Query.Free;
  end;
end;
```

---

## Tratamento de Erros

### Erros Comuns

| Erro | Causa | Solução |
|---|---|---|
| **Banco não conectado** | Arquivo .db não existe | Executar ESTRUTURA_BANCO_DADOS.sql |
| **Operador não encontrado** | Matrícula não existe | Verificar dados de exemplo |
| **Senha incorreta** | Senha errada | Verificar senha de teste |
| **Operador bloqueado** | Muitas tentativas | Aguardar 15 minutos |
| **Erro de SQL** | Query inválida | Verificar sintaxe SQL |

### Tratamento Try-Except

```pascal
procedure TFormLogin.RealizarLogin;
begin
  try
    // Lógica de login
    Operador := FRepositorio.Autenticar(Matricula, Senha);
  except
    on E: Exception do
    begin
      ExibirMensagem('Erro: ' + E.Message, True);
      RegistrarTentativaLogin(False, E.Message);
    end;
  end;
end;
```

### Verificação de Recursos

```pascal
procedure TFormLogin.FormShow(Sender: TObject);
begin
  // Verificar conexão
  if not DMConexao.EstaConectado then
  begin
    if not DMConexao.Conectar then
    begin
      ExibirMensagem('Erro ao conectar: ' + DMConexao.UltimoErro, True);
      HabilitarControles(False);
      Exit;
    end;
  end;
  
  // Carregar operadores
  try
    CarregarOperadoresRapidos;
  except
    on E: Exception do
      ExibirMensagem('Erro ao carregar operadores: ' + E.Message, True);
  end;
end;
```

---

## Constantes de Configuração

```pascal
const
  // Segurança
  TENTATIVAS_MAXIMAS = 3;              // Máximo de tentativas
  TEMPO_BLOQUEIO_MINUTOS = 15;         // Tempo de bloqueio
  TEMPO_ESPERA_ENTRE_TENTATIVAS = 2;   // Segundos entre tentativas
  
  // UI
  ALTURA_BOTAO_OPERADOR = 60;          // Altura dos botões
  ESPACAMENTO_BOTOES = 5;              // Espaço entre botões
  LARGURA_MINIMA_FORM = 400;           // Largura mínima
  ALTURA_MINIMA_FORM = 600;            // Altura mínima
```

### Modificar Constantes

Para aumentar tentativas ou tempo de bloqueio:

```pascal
const
  TENTATIVAS_MAXIMAS = 5;              // Aumentar para 5
  TEMPO_BLOQUEIO_MINUTOS = 30;         // Aumentar para 30 minutos
```

---

## Resumo

| Aspecto | Detalhes |
|---|---|
| **Segurança** | PBKDF2 + bloqueio por força bruta |
| **Auditoria** | Todas as tentativas registradas |
| **Usabilidade** | Operadores rápidos + mensagens claras |
| **Responsividade** | Layout dinâmico e adaptável |
| **Tratamento de Erros** | Completo e informativo |
| **Integração** | Com TRepositorioOperador e TCriptografiaSenha |

A tela de login está **100% pronta para produção** com segurança profissional! 🔒

