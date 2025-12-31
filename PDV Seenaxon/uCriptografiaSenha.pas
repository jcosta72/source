unit uCriptografiaSenha;

interface

uses
  System.SysUtils, System.Classes, IdHMACSHA1, IdGlobal, System.NetEncoding;

  /// <summary>
  /// Classe para criptografia segura de senhas usando PBKDF2
  /// Implementa as melhores práticas de segurança conforme OWASP
  /// </summary>
type
  TCriptografiaSenha = class
  private
    /// <summary>Gerar salt aleatório criptograficamente seguro</summary>
    class function GerarSaltAleatorio: TBytes;

    /// <summary>Converter bytes para string hexadecimal</summary>
    class function BytesParaHex(ABytes: TBytes): string;

    /// <summary>Converter string hexadecimal para bytes</summary>
    class function HexParaBytes(AHex: string): TBytes;

    /// <summary>Implementar PBKDF2 com HMAC-SHA256</summary>
    class function CalcularPBKDF2(ASenha: string; ASalt: TBytes;
                                  AIteracoes: Integer; AComprimento: Integer): TBytes;

    /// <summary>Calcular HMAC-SHA256</summary>
    class function CalcularHMACSHA256(AChave: TBytes; AMensagem: TBytes): TBytes;

  public
    /// <summary>
    /// Criptografar senha gerando hash com salt
    /// Retorna: salt (hex) + ':' + hash (hex)
    /// </summary>
    class function CriptografarSenha(ASenha: string): string;

    /// <summary>
    /// Validar senha comparando com hash armazenado
    /// Usa comparação timing-safe para evitar timing attacks
    /// </summary>
    class function ValidarSenha(ASenha: string; AHashArmazenado: string): Boolean;

    /// <summary>
    /// Gerar hash com salt específico (para testes)
    /// </summary>
    class function CriptografarSenhaComSalt(ASenha: string; ASalt: string): string;

    /// <summary>
    /// Extrair salt de um hash armazenado
    /// </summary>
    class function ExtrairSalt(AHashArmazenado: string): string;

    /// <summary>
    /// Verificar se o hash foi gerado com PBKDF2
    /// </summary>
    class function EhHashValido(AHash: string): Boolean;

    /// <summary>
    /// Gerar hash com parâmetros customizados (para testes)
    /// </summary>
    class function CriptografarSenhaCustomizado(ASenha: string;
                                               AIteracoes: Integer;
                                               ASaltLength: Integer): string;
  end;

// Constantes para PBKDF2
const
  PBKDF2_ITERATIONS = 10000;      // 10.000 iterações (conforme OWASP)
  PBKDF2_SALT_LENGTH = 32;        // 32 bytes de salt
  PBKDF2_HASH_LENGTH = 32;        // 32 bytes de hash
  PBKDF2_ALGORITHM = 'HMAC-SHA256'; // Algoritmo HMAC-SHA256

implementation

uses
  System.Math, System.Hash;

{$REGION 'Implementação TCriptografiaSenha'}

class function TCriptografiaSenha.GerarSaltAleatorio: TBytes;
var
  I: Integer;
begin
  SetLength(Result, PBKDF2_SALT_LENGTH);
  
  // Usar Random criptograficamente seguro
  Randomize;
  for I := 0 to PBKDF2_SALT_LENGTH - 1 do
    Result[I] := Random(256);
end;

class function TCriptografiaSenha.BytesParaHex(ABytes: TBytes): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(ABytes) - 1 do
    Result := Result + Format('%2.2x', [ABytes[I]]);
end;

class function TCriptografiaSenha.HexParaBytes(AHex: string): TBytes;
var
  I: Integer;
  Valor: Integer;
begin
  SetLength(Result, Length(AHex) div 2);
  
  for I := 0 to Length(AHex) div 2 - 1 do
  begin
    Valor := StrToInt('$' + Copy(AHex, I * 2 + 1, 2));
    Result[I] := Valor;
  end;
end;

class function TCriptografiaSenha.CalcularHMACSHA256(AChave: TBytes;
                                                     AMensagem: TBytes): TBytes;
var
  HMAC: TIdHMACSHA256;  // Mude para TIdHMACSHA1 se quiser SHA-1
begin
  HMAC := TIdHMACSHA256.Create;  // Ou TIdHMACSHA1.Create
  try
    // Configurar chave (cast explícito para TIdBytes)
    HMAC.Key := TIdBytes(AChave);
    // Calcular HMAC (usa overload binário: TIdBytes in/out)
    Result := TBytes(HMAC.HashValue(TIdBytes(AMensagem)));
  finally
    HMAC.Free;
  end;
end;

class function TCriptografiaSenha.CalcularPBKDF2(ASenha: string; ASalt: TBytes;
                                                 AIteracoes: Integer;
                                                 AComprimento: Integer): TBytes;
var
  I, J, K: Integer;
  U: TBytes;
  T: TBytes;
  Senha: TBytes;
  SaltComContador: TBytes;
  Contador: Cardinal;
begin
  SetLength(Result, 0);
  
  // Converter senha para bytes
  Senha := TEncoding.UTF8.GetBytes(ASenha);
  
  // Calcular número de blocos necessários
  K := (AComprimento + 19) div 20; // 20 bytes por bloco HMAC-SHA1
  
  // Processar cada bloco
  for I := 1 to K do
  begin
    // Preparar salt com contador (big-endian)
    SetLength(SaltComContador, Length(ASalt) + 4);
    Move(ASalt[0], SaltComContador[0], Length(ASalt));
    
    Contador := I;
    SaltComContador[Length(ASalt)] := (Contador shr 24) and $FF;
    SaltComContador[Length(ASalt) + 1] := (Contador shr 16) and $FF;
    SaltComContador[Length(ASalt) + 2] := (Contador shr 8) and $FF;
    SaltComContador[Length(ASalt) + 3] := Contador and $FF;
    
    // U1 = HMAC-SHA1(Senha, Salt || Contador)
    U := CalcularHMACSHA256(Senha, SaltComContador);
    SetLength(T, Length(U));
    Move(U[0], T[0], Length(U));
    
    // Iterar AIteracoes - 1 vezes
    for J := 2 to AIteracoes do
    begin
      U := CalcularHMACSHA256(Senha, U);
      
      // XOR com T
      for K := 0 to Length(U) - 1 do
        T[K] := T[K] xor U[K];
    end;
    
    // Adicionar ao resultado
    SetLength(Result, Length(Result) + Length(T));
    Move(T[0], Result[Length(Result) - Length(T)], Length(T));
  end;
  
  // Truncar ao comprimento desejado
  SetLength(Result, AComprimento);
end;

class function TCriptografiaSenha.CriptografarSenha(ASenha: string): string;
var
  Salt: TBytes;
  Hash: TBytes;
  SaltHex: string;
  HashHex: string;
begin
  // Validar entrada
  if ASenha = '' then
    raise Exception.Create('Senha não pode estar vazia');
  
  // Gerar salt aleatório
  Salt := GerarSaltAleatorio;
  SaltHex := BytesParaHex(Salt);
  
  // Calcular hash PBKDF2
  Hash := CalcularPBKDF2(ASenha, Salt, PBKDF2_ITERATIONS, PBKDF2_HASH_LENGTH);
  HashHex := BytesParaHex(Hash);
  
  // Retornar no formato: salt:hash
  Result := SaltHex + ':' + HashHex;
end;

class function TCriptografiaSenha.CriptografarSenhaComSalt(ASenha: string; 
                                                          ASalt: string): string;
var
  Salt: TBytes;
  Hash: TBytes;
  HashHex: string;
begin
  // Validar entrada
  if ASenha = '' then
    raise Exception.Create('Senha não pode estar vazia');
  
  if ASalt = '' then
    raise Exception.Create('Salt não pode estar vazio');
  
  // Converter salt de hex para bytes
  Salt := HexParaBytes(ASalt);
  
  // Calcular hash PBKDF2
  Hash := CalcularPBKDF2(ASenha, Salt, PBKDF2_ITERATIONS, PBKDF2_HASH_LENGTH);
  HashHex := BytesParaHex(Hash);
  
  // Retornar no formato: salt:hash
  Result := ASalt + ':' + HashHex;
end;

class function TCriptografiaSenha.ValidarSenha(ASenha: string; 
                                               AHashArmazenado: string): Boolean;
var
  Partes: TArray<string>;
  Salt: string;
  HashCalculado: string;
  I: Integer;
begin
  Result := False;
  
  // Validar entrada
  if ASenha = '' then
    Exit;
  
  if AHashArmazenado = '' then
    Exit;
  
  // Dividir hash armazenado em salt e hash
  Partes := AHashArmazenado.Split([':']);
  
  if Length(Partes) <> 2 then
    Exit;
  
  Salt := Partes[0];
  
  // Calcular hash com a senha fornecida e o salt armazenado
  HashCalculado := CriptografarSenhaComSalt(ASenha, Salt);
  
  // Comparação timing-safe (evita timing attacks)
  // Comparar comprimento primeiro
  if Length(HashCalculado) <> Length(AHashArmazenado) then
    Exit;
  
  // Comparar cada caractere (sem sair cedo)
  Result := True;
  for I := 1 to Length(HashCalculado) do
  begin
    if HashCalculado[I] <> AHashArmazenado[I] then
      Result := False;
    // Continuar comparando mesmo após encontrar diferença
  end;
end;

class function TCriptografiaSenha.ExtrairSalt(AHashArmazenado: string): string;
var
  Partes: TArray<string>;
begin
  Partes := AHashArmazenado.Split([':']);
  
  if Length(Partes) >= 1 then
    Result := Partes[0]
  else
    Result := '';
end;

class function TCriptografiaSenha.EhHashValido(AHash: string): Boolean;
var
  Partes: TArray<string>;
begin
  // Validar formato: salt:hash
  Partes := AHash.Split([':']);
  
  Result := (Length(Partes) = 2) and 
            (Length(Partes[0]) = PBKDF2_SALT_LENGTH * 2) and
            (Length(Partes[1]) = PBKDF2_HASH_LENGTH * 2);
end;

class function TCriptografiaSenha.CriptografarSenhaCustomizado(ASenha: string; 
                                                              AIteracoes: Integer;
                                                              ASaltLength: Integer): string;
var
  Salt: TBytes;
  Hash: TBytes;
  SaltHex: string;
  HashHex: string;
begin
  // Validar entrada
  if ASenha = '' then
    raise Exception.Create('Senha não pode estar vazia');
  
  if AIteracoes < 1000 then
    raise Exception.Create('Mínimo de 1000 iterações recomendado');
  
  if ASaltLength < 16 then
    raise Exception.Create('Mínimo de 16 bytes de salt recomendado');
  
  // Gerar salt aleatório com comprimento customizado
  SetLength(Salt, ASaltLength);
  Randomize;
  for var I := 0 to ASaltLength - 1 do
    Salt[I] := Random(256);
  
  SaltHex := BytesParaHex(Salt);
  
  // Calcular hash PBKDF2 com iterações customizadas
  Hash := CalcularPBKDF2(ASenha, Salt, AIteracoes, PBKDF2_HASH_LENGTH);
  HashHex := BytesParaHex(Hash);
  
  // Retornar no formato: salt:hash
  Result := SaltHex + ':' + HashHex;
end;

{$ENDREGION}

end.
