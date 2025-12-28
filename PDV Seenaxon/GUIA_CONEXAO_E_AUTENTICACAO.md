# Guia de Uso: Conexão com Banco de Dados e Autenticação

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Unit de Conexão (uDMConexao)](#unit-de-conexão-udmconexao)
3. [Repositório de Operadores (uRepositorioOperador)](#repositório-de-operadores-urepositorioperador)
4. [Exemplos de Uso](#exemplos-de-uso)
5. [Autenticação com PBKDF2](#autenticação-com-pbkdf2)
6. [Tratamento de Erros](#tratamento-de-erros)
7. [Boas Práticas](#boas-práticas)

---

## Visão Geral

O sistema PDV Seenaxon utiliza:

- **Banco de Dados**: SQLite (arquivo `pdv_seenaxon.db`)
- **Conexão**: FireDAC (TFDConnection)
- **Criptografia**: PBKDF2 com 10.000 iterações
- **Padrão**: Repository Pattern com Data Module

### Arquitetura

```
┌─────────────────────────────────────┐
│   Aplicação (Form/View)             │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│   TRepositorioOperador              │
│   - CRUD                            │
│   - Autenticação                    │
│   - Validação                       │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│   TDMConexao (Data Module)          │
│   - Gerencia conexão SQLite         │
│   - Transações                      │
│   - Backup/Restauração              │
└────────────────┬────────────────────┘
                 │
┌────────────────▼────────────────────┐
│   SQLite Database                   │
│   - pdv_seenaxon.db                 │
└─────────────────────────────────────┘
```

---

## Unit de Conexão (uDMConexao)

### O que é?

`TDMConexao` é um Data Module que gerencia a conexão com o banco de dados SQLite.

### Características

✅ **Singleton**: Única instância global (`DMConexao`)
✅ **Automático**: Cria banco de dados se não existir
✅ **Seguro**: Transações ACID
✅ **Robusto**: Tratamento de erros completo
✅ **Prático**: Métodos auxiliares (backup, restauração, verificação)

### Constantes de Configuração

```pascal
const
  BANCO_DADOS_NOME = 'pdv_seenaxon.db';
  BANCO_DADOS_CAMINHO = '';  // Diretório da aplicação
  TIMEOUT_CONEXAO = 30000;   // 30 segundos
```

### Métodos Principais

#### Conectar ao Banco de Dados

```pascal
function Conectar: Boolean;
```

**Exemplo**:
```pascal
if DMConexao.Conectar then
  ShowMessage('Conectado com sucesso!')
else
  ShowMessage('Erro: ' + DMConexao.UltimoErro);
```

#### Desconectar

```pascal
procedure Desconectar;
```

**Exemplo**:
```pascal
DMConexao.Desconectar;
```

#### Verificar Conexão

```pascal
function EstaConectado: Boolean;
```

**Exemplo**:
```pascal
if DMConexao.EstaConectado then
  ShowMessage('Conectado')
else
  ShowMessage('Desconectado');
```

#### Executar SQL

```pascal
function ExecutarSQL(ASQL: string; AParams: array of const): Boolean;
```

**Exemplo**:
```pascal
if DMConexao.ExecutarSQL(
  'UPDATE Operadores SET Ativo = ? WHERE OperadorID = ?',
  [1, 5]
) then
  ShowMessage('Atualizado!')
else
  ShowMessage('Erro: ' + DMConexao.UltimoErro);
```

#### Transações

```pascal
procedure IniciarTransacao;
procedure ConfirmarTransacao;
procedure ReverterTransacao;
```

**Exemplo**:
```pascal
try
  DMConexao.IniciarTransacao;
  
  // Executar operações
  DMConexao.ExecutarSQL('INSERT INTO ...', []);
  DMConexao.ExecutarSQL('UPDATE ...', []);
  
  DMConexao.ConfirmarTransacao;
except
  DMConexao.ReverterTransacao;
  ShowMessage('Erro: operações revertidas');
end;
```

#### Backup e Restauração

```pascal
function FazerBackup(AArquivoDestino: string): Boolean;
function RestaurarBackup(AArquivoOrigem: string): Boolean;
```

**Exemplo**:
```pascal
// Fazer backup
if DMConexao.FazerBackup('C:\Backups\pdv_backup_2025-12-28.db') then
  ShowMessage('Backup realizado!')
else
  ShowMessage('Erro ao fazer backup');

// Restaurar backup
if DMConexao.RestaurarBackup('C:\Backups\pdv_backup_2025-12-28.db') then
  ShowMessage('Backup restaurado!')
else
  ShowMessage('Erro ao restaurar backup');
```

---

## Repositório de Operadores (uRepositorioOperador)

### O que é?

`TRepositorioOperador` é a classe que gerencia todas as operações com a tabela `Operadores`.

### Características

✅ **CRUD Completo**: Create, Read, Update, Delete
✅ **Autenticação**: Login com validação de senha PBKDF2
✅ **Segurança**: Criptografia de senhas, auditoria de login
✅ **Validação**: Validação de dados antes de inserir/atualizar
✅ **Relatórios**: Consultas úteis (mais vendas, último acesso, etc)

### Métodos CRUD

#### Inserir Operador

```pascal
function Inserir(AOperador: TOperador): TResultadoOperacao;
```

**Exemplo**:
```pascal
var
  Operador: TOperador;
  Resultado: TRepositorioOperador.TResultadoOperacao;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    Operador := TOperador.Create;
    try
      Operador.Nome := 'NOVO OPERADOR';
      Operador.Matricula := '006';
      Operador.Senha := 'senha123';
      Operador.Email := 'novo@example.com';
      Operador.Ativo := True;
      
      Resultado := Repositorio.Inserir(Operador);
      
      if Resultado.Sucesso then
        ShowMessage('Operador inserido com sucesso!')
      else
        ShowMessage('Erro: ' + Resultado.Mensagem);
    finally
      Operador.Free;
    end;
  finally
    Repositorio.Free;
  end;
end;
```

#### Obter Operador por ID

```pascal
function ObterPorID(AOperadorID: Integer): TOperador;
```

**Exemplo**:
```pascal
var
  Operador: TOperador;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    Operador := Repositorio.ObterPorID(1);
    
    if Assigned(Operador) then
    begin
      ShowMessage('Nome: ' + Operador.Nome);
      Operador.Free;
    end
    else
      ShowMessage('Operador não encontrado');
  finally
    Repositorio.Free;
  end;
end;
```

#### Obter Operador por Matrícula

```pascal
function ObterPorMatricula(AMatricula: string): TOperador;
```

**Exemplo**:
```pascal
var
  Operador: TOperador;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    Operador := Repositorio.ObterPorMatricula('001');
    
    if Assigned(Operador) then
    begin
      ShowMessage('Operador: ' + Operador.Nome);
      Operador.Free;
    end;
  finally
    Repositorio.Free;
  end;
end;
```

#### Obter Todos os Operadores

```pascal
function ObterTodos: TObjectList<TOperador>;
```

**Exemplo**:
```pascal
var
  Operadores: TObjectList<TOperador>;
  Operador: TOperador;
  Repositorio: TRepositorioOperador;
  I: Integer;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    Operadores := Repositorio.ObterTodos;
    
    if Assigned(Operadores) then
    begin
      ShowMessage('Total de operadores: ' + IntToStr(Operadores.Count));
      
      for I := 0 to Operadores.Count - 1 do
      begin
        Operador := Operadores[I];
        ShowMessage(Operador.Nome + ' (' + Operador.Matricula + ')');
      end;
      
      Operadores.Free;
    end;
  finally
    Repositorio.Free;
  end;
end;
```

#### Atualizar Operador

```pascal
function Atualizar(AOperador: TOperador; AAtualizarSenha: Boolean = False): TResultadoOperacao;
```

**Exemplo**:
```pascal
var
  Operador: TOperador;
  Resultado: TRepositorioOperador.TResultadoOperacao;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    Operador := Repositorio.ObterPorID(1);
    
    if Assigned(Operador) then
    begin
      Operador.Email := 'novo_email@example.com';
      Operador.Telefone := '(11) 99999-9999';
      
      Resultado := Repositorio.Atualizar(Operador, False);
      
      if Resultado.Sucesso then
        ShowMessage('Operador atualizado!')
      else
        ShowMessage('Erro: ' + Resultado.Mensagem);
      
      Operador.Free;
    end;
  finally
    Repositorio.Free;
  end;
end;
```

#### Deletar Operador

```pascal
function Deletar(AOperadorID: Integer): TResultadoOperacao;
```

**Exemplo**:
```pascal
var
  Resultado: TRepositorioOperador.TResultadoOperacao;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    Resultado := Repositorio.Deletar(5);
    
    if Resultado.Sucesso then
      ShowMessage('Operador deletado!')
    else
      ShowMessage('Erro: ' + Resultado.Mensagem);
  finally
    Repositorio.Free;
  end;
end;
```

---

## Exemplos de Uso

### Exemplo 1: Autenticar Operador

```pascal
procedure AutenticarOperador;
var
  Operador: TOperador;
  Repositorio: TRepositorioOperador;
  Matricula, Senha: string;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    // Obter entrada do usuário
    Matricula := InputBox('Login', 'Matrícula:', '001');
    Senha := InputBox('Login', 'Senha:', '');
    
    // Autenticar
    Operador := Repositorio.Autenticar(Matricula, Senha);
    
    if Assigned(Operador) then
    begin
      ShowMessage('Login bem-sucedido! Bem-vindo, ' + Operador.Nome);
      // Usar Operador para operações subsequentes
      Operador.Free;
    end
    else
      ShowMessage('Erro: ' + Repositorio.UltimoErro);
  finally
    Repositorio.Free;
  end;
end;
```

### Exemplo 2: Alterar Senha

```pascal
procedure AlterarSenha;
var
  SenhaAtual, SenhaNova, SenhaConfirma: string;
  Resultado: TRepositorioOperador.TResultadoOperacao;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    SenhaAtual := InputBox('Alterar Senha', 'Senha Atual:', '');
    SenhaNova := InputBox('Alterar Senha', 'Senha Nova:', '');
    SenhaConfirma := InputBox('Alterar Senha', 'Confirmar Senha:', '');
    
    if SenhaNova <> SenhaConfirma then
    begin
      ShowMessage('Senhas não conferem!');
      Exit;
    end;
    
    Resultado := Repositorio.AlterarSenha(1, SenhaAtual, SenhaNova);
    
    if Resultado.Sucesso then
      ShowMessage('Senha alterada com sucesso!')
    else
      ShowMessage('Erro: ' + Resultado.Mensagem);
  finally
    Repositorio.Free;
  end;
end;
```

### Exemplo 3: Listar Operadores em Grid

```pascal
procedure CarregarOperadoresNoGrid(AStringGrid: TStringGrid);
var
  Operadores: TObjectList<TOperador>;
  Operador: TOperador;
  Repositorio: TRepositorioOperador;
  I: Integer;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    Operadores := Repositorio.ObterTodos;
    
    if Assigned(Operadores) then
    begin
      AStringGrid.RowCount := Operadores.Count + 1;
      
      // Cabeçalho
      AStringGrid.Cells[0, 0] := 'ID';
      AStringGrid.Cells[1, 0] := 'Nome';
      AStringGrid.Cells[2, 0] := 'Matrícula';
      AStringGrid.Cells[3, 0] := 'Email';
      AStringGrid.Cells[4, 0] := 'Status';
      
      // Dados
      for I := 0 to Operadores.Count - 1 do
      begin
        Operador := Operadores[I];
        AStringGrid.Cells[0, I + 1] := IntToStr(Operador.ID);
        AStringGrid.Cells[1, I + 1] := Operador.Nome;
        AStringGrid.Cells[2, I + 1] := Operador.Matricula;
        AStringGrid.Cells[3, I + 1] := Operador.Email;
        AStringGrid.Cells[4, I + 1] := IfThen(Operador.Ativo, 'Ativo', 'Inativo');
      end;
      
      Operadores.Free;
    end;
  finally
    Repositorio.Free;
  end;
end;
```

---

## Autenticação com PBKDF2

### Como Funciona

1. **Criptografia de Senha**: Quando um operador é criado, a senha é criptografada com PBKDF2
2. **Validação**: Ao fazer login, a senha fornecida é validada contra o hash armazenado
3. **Segurança**: Usa comparação timing-safe para evitar timing attacks
4. **Auditoria**: Todas as tentativas de login são registradas em `LogAcessoOperador`

### Fluxo de Autenticação

```
Usuário digita matrícula e senha
         ↓
Repositório.Autenticar(matricula, senha)
         ↓
Obter operador por matrícula
         ↓
Verificar se está ativo
         ↓
Obter hash armazenado
         ↓
Validar senha com TCriptografiaSenha.ValidarSenha()
         ↓
Se válido: Atualizar DataUltimoAcesso
         ↓
Registrar em LogAcessoOperador
         ↓
Retornar Operador ou nil
```

### Exemplo de Autenticação Completa

```pascal
procedure LoginOperador;
var
  Operador: TOperador;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    // Tentar autenticar
    Operador := Repositorio.Autenticar('001', '1234');
    
    if Assigned(Operador) then
    begin
      // Login bem-sucedido
      ShowMessage('Bem-vindo, ' + Operador.Nome + '!');
      
      // Usar operador
      FOperadorAtual := Operador;
      
      // Atualizar interface
      LabelOperador.Text := Operador.Nome;
      LabelMatricula.Text := Operador.Matricula;
    end
    else
    begin
      // Login falhou
      ShowMessage('Erro: ' + Repositorio.UltimoErro);
    end;
  finally
    Repositorio.Free;
  end;
end;
```

---

## Tratamento de Erros

### Verificar Último Erro

```pascal
var
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    // Executar operação
    Repositorio.ObterPorID(999);
    
    // Verificar erro
    if Repositorio.UltimoErro <> '' then
      ShowMessage('Erro: ' + Repositorio.UltimoErro);
  finally
    Repositorio.Free;
  end;
end;
```

### Tratamento com Try-Except

```pascal
var
  Operador: TOperador;
  Repositorio: TRepositorioOperador;
begin
  Repositorio := TRepositorioOperador.Create;
  try
    try
      Operador := Repositorio.ObterPorID(1);
      
      if Assigned(Operador) then
      begin
        ShowMessage('Nome: ' + Operador.Nome);
        Operador.Free;
      end;
    except
      on E: Exception do
        ShowMessage('Erro: ' + E.Message);
    end;
  finally
    Repositorio.Free;
  end;
end;
```

---

## Boas Práticas

### ✅ Faça

1. **Sempre liberar recursos**
   ```pascal
   Repositorio := TRepositorioOperador.Create;
   try
     // Usar repositório
   finally
     Repositorio.Free;
   end;
   ```

2. **Verificar se objeto foi criado**
   ```pascal
   Operador := Repositorio.ObterPorID(1);
   if Assigned(Operador) then
   begin
     // Usar operador
     Operador.Free;
   end;
   ```

3. **Usar transações para operações múltiplas**
   ```pascal
   try
     DMConexao.IniciarTransacao;
     // Múltiplas operações
     DMConexao.ConfirmarTransacao;
   except
     DMConexao.ReverterTransacao;
   end;
   ```

4. **Validar entrada do usuário**
   ```pascal
   if Trim(Matricula) = '' then
   begin
     ShowMessage('Matrícula não pode estar vazia');
     Exit;
   end;
   ```

### ❌ Não Faça

1. **Não esquecer de liberar recursos**
   ```pascal
   Repositorio := TRepositorioOperador.Create;
   // Usar repositório
   // Repositorio.Free;  // ❌ VAZAMENTO DE MEMÓRIA
   ```

2. **Não usar operador sem verificar**
   ```pascal
   Operador := Repositorio.ObterPorID(1);
   ShowMessage(Operador.Nome);  // ❌ PODE SER NIL
   ```

3. **Não armazenar senhas em texto plano**
   ```pascal
   Operador.Senha := '1234';  // ❌ INSEGURO
   ```

4. **Não ignorar erros**
   ```pascal
   Resultado := Repositorio.Inserir(Operador);
   // Não verificar Resultado.Sucesso  // ❌ PODE FALHAR SILENCIOSAMENTE
   ```

---

## Resumo

| Classe | Responsabilidade |
|--------|-----------------|
| **TDMConexao** | Gerenciar conexão com SQLite |
| **TRepositorioOperador** | CRUD de operadores + autenticação |
| **TCriptografiaSenha** | Criptografia PBKDF2 de senhas |
| **TOperador** | Modelo de dados do operador |

Todos os três trabalham juntos para fornecer um sistema seguro e profissional de autenticação!

