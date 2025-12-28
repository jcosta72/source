# Guia de Uso - PDV Seenaxon em Delphi

## Iniciando o Sistema

1. Compile e execute o projeto `DelphiPDV.dpr`
2. A tela principal será exibida com:
   - **Cabeçalho**: Informações do operador e status do caixa
   - **Painel Esquerdo**: Lista de produtos disponíveis
   - **Painel Direito**: Resumo da venda e botões de ação

## Operações Básicas

### 1. Adicionar Produtos ao Carrinho

**Método 1: Clicando na Lista**
```
1. Visualize a lista de produtos no painel esquerdo
2. Clique no produto desejado
3. O produto será adicionado ao carrinho
4. Se o produto já existe, a quantidade será aumentada
5. O resumo será atualizado automaticamente
```

**Método 2: Pesquisando**
```
1. Digite o nome ou código do produto na barra de pesquisa
2. A lista será filtrada em tempo real
3. Clique no produto desejado
4. O produto será adicionado ao carrinho
```

### 2. Visualizar Resumo da Venda

O painel direito exibe em tempo real:
```
RESUMO DA VENDA

Produtos:
1. LIVRO - Qtd: 2 - R$ 3,00
2. CANETA - Qtd: 1 - R$ 10,00

Subtotal: R$ 13,00
Desconto: -R$ 2,00
Acréscimo: +R$ 1,00

TOTAL: R$ 12,00
```

### 3. Aplicar Desconto

```
1. Clique no botão "Desconto"
2. Uma caixa de diálogo será exibida
3. Digite o valor do desconto (ex: 2.50)
4. Pressione OK
5. O desconto será aplicado e o total será recalculado
```

**Exemplo**: Se o subtotal é R$ 13,00 e você aplica desconto de R$ 2,00, o novo subtotal será R$ 11,00.

### 4. Aplicar Acréscimo

```
1. Clique no botão "Acréscimo"
2. Uma caixa de diálogo será exibida
3. Digite o valor do acréscimo (ex: 1.50)
4. Pressione OK
5. O acréscimo será adicionado e o total será recalculado
```

**Exemplo**: Se o subtotal é R$ 13,00 (com desconto de R$ 2,00), e você aplica acréscimo de R$ 1,00, o total será R$ 12,00.

### 5. Ajustar Quantidade de Itens

**Aumentar Quantidade**:
```
1. Clique no item na lista de resumo
2. Clique no botão "Aumentar"
3. A quantidade será aumentada em 1
4. O total será recalculado
```

**Diminuir Quantidade**:
```
1. Clique no item na lista de resumo
2. Clique no botão "Diminuir"
3. A quantidade será diminuída em 1
4. Se a quantidade chegar a 0, o item será removido
5. O total será recalculado
```

### 6. Remover Item do Carrinho

```
1. Clique no item na lista de resumo
2. Clique no botão "Remover"
3. O item será removido do carrinho
4. O total será recalculado
```

### 7. Finalizar Venda

```
1. Verifique se todos os itens estão corretos
2. Aplique desconto ou acréscimo se necessário
3. Clique no botão "Finalizar Venda"
4. A venda será registrada no caixa
5. Um novo carrinho vazio será criado
6. Uma mensagem de sucesso será exibida
```

### 8. Limpar Carrinho

```
1. Clique no botão "Limpar Carrinho"
2. Uma confirmação será solicitada
3. Se confirmar, todos os itens serão removidos
4. O carrinho voltará ao estado inicial (TOTAL: R$ 0,00)
```

## Fluxo Completo de Venda

### Exemplo Prático

**Cenário**: Cliente deseja comprar 2 livros, 1 caneta e 1 borracha, com desconto de R$ 2,00 e taxa de R$ 1,00.

**Passo 1**: Adicionar primeiro produto
```
→ Clique em "LIVRO" na lista
→ Resumo mostra: LIVRO - Qtd: 1 - R$ 1,50
→ TOTAL: R$ 1,50
```

**Passo 2**: Adicionar segundo livro
```
→ Clique em "LIVRO" novamente
→ Resumo mostra: LIVRO - Qtd: 2 - R$ 3,00
→ TOTAL: R$ 3,00
```

**Passo 3**: Adicionar caneta
```
→ Clique em "CANETA" na lista
→ Resumo mostra:
  1. LIVRO - Qtd: 2 - R$ 3,00
  2. CANETA - Qtd: 1 - R$ 10,00
→ TOTAL: R$ 13,00
```

**Passo 4**: Adicionar borracha
```
→ Clique em "BORRACHA" na lista
→ Resumo mostra:
  1. LIVRO - Qtd: 2 - R$ 3,00
  2. CANETA - Qtd: 1 - R$ 10,00
  3. BORRACHA - Qtd: 1 - R$ 2,00
→ TOTAL: R$ 15,00
```

**Passo 5**: Aplicar desconto
```
→ Clique em "Desconto"
→ Digite: 2
→ Resumo mostra:
  Subtotal: R$ 15,00
  Desconto: -R$ 2,00
→ TOTAL: R$ 13,00
```

**Passo 6**: Aplicar acréscimo
```
→ Clique em "Acréscimo"
→ Digite: 1
→ Resumo mostra:
  Subtotal: R$ 15,00
  Desconto: -R$ 2,00
  Acréscimo: +R$ 1,00
→ TOTAL: R$ 14,00
```

**Passo 7**: Finalizar venda
```
→ Clique em "Finalizar Venda"
→ Mensagem: "Venda finalizada com sucesso!"
→ Carrinho é zerado
→ Novo resumo mostra: TOTAL: R$ 0,00
```

## Dicas e Truques

### 1. Pesquisa Rápida
- Digite parte do nome do produto para filtrar
- Exemplo: Digite "CA" para encontrar CANETA e CADERNO

### 2. Múltiplas Unidades
- Clique várias vezes no mesmo produto para aumentar a quantidade
- Ou use o botão "Aumentar" após adicionar

### 3. Correção de Erros
- Use "Remover" para tirar um item errado
- Use "Diminuir" para ajustar quantidade
- Use "Limpar Carrinho" para começar do zero

### 4. Cálculos Automáticos
- Todos os cálculos são feitos automaticamente
- Não é necessário fazer contas manualmente
- O sistema sempre exibe o total atualizado

## Validações do Sistema

O sistema valida automaticamente:

1. **Quantidade**: Não permite quantidade menor ou igual a zero
2. **Desconto**: Aceita qualquer valor (validar se não ultrapassa o subtotal)
3. **Acréscimo**: Aceita qualquer valor
4. **Finalização**: Não permite finalizar venda sem itens

## Informações Exibidas

### Cabeçalho
- **Operador**: MARCOS SILVA DE MATOS - Operador sem Identificação
- **Status**: Caixa Aberto (em verde)

### Resumo da Venda
- **Produtos**: Lista com quantidade e valor de cada item
- **Subtotal**: Soma de todos os itens
- **Desconto**: Valor descontado (se houver)
- **Acréscimo**: Valor adicionado (se houver)
- **Total**: Valor final a pagar

## Resolução de Problemas

### Problema: Produto não aparece na lista
**Solução**: Limpe a pesquisa ou clique em outro produto para atualizar

### Problema: Desconto não foi aplicado
**Solução**: Verifique se digitou um número válido (ex: 2.50, não 2,50)

### Problema: Não consigo remover um item
**Solução**: Clique no item no resumo e depois clique em "Remover"

### Problema: Total não está correto
**Solução**: Verifique se aplicou desconto ou acréscimo corretamente

## Próximas Versões

Funcionalidades planejadas:
- Descontos percentuais
- Múltiplos operadores
- Integração com NFe
- Relatórios de vendas
- Persistência em banco de dados
- Teclado numérico customizado
- Imagens de produtos
- Histórico de vendas
