# rex-ai-suggest

Plugin Zsh reutilizavel para trazer sugestoes proativas e sob demanda estilo Warp dentro do **Rex**, combinando `rex capture` + **Gemini Flash-Lite** de forma assincrona (sem travar o prompt) e sem expor segredos no repositorio.

## Como funciona

1. **Modo proativo (`precmd` assincrono):** quando um comando termina dentro do Rex (`REX_BLOCK` definido), o plugin dispara uma consulta em background sem travar o terminal:
   - Se o comando **falhou (`exit_code != 0`)**, le o final da tela com `rex capture` e sugere a correcao ou diagnostico como *ghost text* cinza.
   - No modo padrao (`smart`), tambem sugere o proximo passo apos comandos de dev (como `git`, `npm`, `docker`, `pytest`, `cargo`, etc.), ignorando comandos triviais (`cd`, `ls`, `clear`, `vim`, ...) e comandos sensiveis (`env`, `.env`, `veracrypt`, `ssh-add`, ...).
2. **Modo sob demanda (`Ctrl+G`):** funciona no prompt vazio (sugere proximo passo), completando comandos parciais ou traduzindo linguagem natural (portugues/ingles) direto para comando Zsh.
3. **Aceitar sugestao:** use os mesmos atalhos do `zsh-autosuggestions` (`→` aceita inteiro, `Option+→` aceita palavra por palavra, ou apenas comece a digitar para descartar).

---

## Configurando a chave do Gemini sem expor segredos

### Opcao 1: Arquivo local fora do Git (`~/.zshrc.local`) — mais simples

Crie `~/.zshrc.local` (ignorado pelo `.gitignore` e carregado automaticamente pelo `zsh/.zshrc`):

```zsh
cat <<'EOF' > ~/.zshrc.local
export GEMINI_API_KEY="SUA_CHAVE_DO_AI_STUDIO"
EOF
chmod 600 ~/.zshrc.local
```

### Opcao 2: macOS Keychain — sem chave em texto puro no disco

Salve a chave no Keychain do macOS:

```zsh
security add-generic-password -a "$USER" -s "rex-ai-gemini" -w "SUA_CHAVE_DO_AI_STUDIO" -U
```

E ative a leitura do Keychain no `~/.zshrc.local`:

```zsh
export REX_AI_USE_KEYCHAIN=1
```

> Nunca coloque chaves em `zsh/.zshrc` ou em qualquer arquivo versionado nos dotfiles.

---

## Variaveis de configuracao

Voce pode sobrescrever qualquer uma dessas variaveis no `~/.zshrc.local`:

| Variavel | Padrao | Descricao |
| :--- | :--- | :--- |
| `REX_AI_ENABLED` | `1` | `1` ativa o plugin, `0` desativa |
| `REX_AI_PROACTIVE_MODE` | `smart` | `smart` (erros + comandos dev), `errors` (so falhas), `all` (quase tudo), `off` (so `Ctrl+G`) |
| `REX_AI_MODEL` | `gemini-3.5-flash-lite` | Modelo Gemini usado na API (`gemini-3.1-flash-lite`, `gemini-2.5-flash-lite`, etc.) |
| `REX_AI_KEYBIND` | `^G` | Atalho ZLE para sugestao manual (`Ctrl+G`) |
| `REX_AI_TIMEOUT` | `4.0` / `8.0` | Timeout HTTP em segundos (proativo / manual) |
| `REX_AI_CAPTURE_LINES` | `60` | Quantidade maxima de linhas do `rex capture` |
| `REX_AI_CAPTURE_CHARS` | `4000` | Limite de caracteres do `rex capture` |
| `REX_AI_IGNORE_PATTERN` | *(vazio)* | Regex extra de comandos ignorados no modo proativo |
| `REX_AI_USE_KEYCHAIN` | `0` | `1` para buscar a chave no macOS Keychain se nao houver env var |
| `REX_AI_KEYCHAIN_SERVICE` | `rex-ai-gemini` | Nome do servico no macOS Keychain |

### Opt-out por diretorio (`.no-rex-ai`)

Crie um arquivo `.no-rex-ai` em qualquer pasta sensivel (ou na pasta raiz de um projeto): o plugin desativa o `rex capture` e as sugestoes proativas nessa arvore de diretorios.

---

## Comandos uteis no terminal

- `rex-ai-status` — mostra estado, modelo, modo proativo, binario `rex` e se a chave esta configurada (nunca imprime a chave).
- `rex-ai-toggle` — ativa/desativa rapidamente na sessao atual.
- `rex-ai-test` — executa um `--dry-run` local exibindo exatamente o payload JSON ja sanitizado/redatado que seria enviado ao Gemini (sem fazer chamada HTTP).
- `rex-ai-test "npm test" 1` — simula o `--dry-run` para um comando e exit code especificos.
- `rex-ai-test --live "git status" 0` — faz uma chamada real ao Gemini para validar a resposta.

---

## Opcional: combinar com Atuin

Este plugin foca nas sugestoes inteligentes via IA e ja se integra com seu `zsh-autosuggestions`. Caso queira adicionar historico por diretorio e exit code estilo Warp para buscas (`Ctrl+R`) e *ghost text* instantaneo offline:

```zsh
brew install atuin
# Depois adicione no ~/.zshrc.local:
eval "$(atuin init zsh --disable-ai)"
```
