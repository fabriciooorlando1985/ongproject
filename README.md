# Projeto da ONG

Esqueleto do projeto da ONG para o Projeto Integrador Extensionista II (Atividade 1).
Front-end criado com Vite+ (Vanilla JavaScript) e API em Express com a rota `GET /api/health`.

## Requisitos

- Node.js 20.6 ou superior
- npm

## Como rodar

1. Clone o repositório e entre na pasta:

   ```bash
   git clone https://github.com/fabriciooorlando1985/ongproject.git
   cd ongproject
   ```

2. Instale as dependências:

   ```bash
   npm install
   ```

3. Crie o arquivo `.env` a partir do exemplo:

   ```bash
   cp .env.example .env
   ```

4. Em um terminal, inicie a API (porta 3001):

   ```bash
   npm run api
   ```

5. Em outro terminal, inicie o front-end (porta 5173):

   ```bash
   npm run dev
   ```

6. Abra http://localhost:5173 no navegador. A página deve mostrar **Status da API: ok** com data e hora.

## Testar a API diretamente

```bash
curl http://localhost:3001/api/health
```

Resposta esperada:

```json
{ "status": "ok", "timestamp": "2026-11-07T12:00:00.000Z" }
```

## Estrutura

- `server/index.js`: API Express com a rota `GET /api/health`
- `main.js`, `index.html`, `style.css`: página inicial
- `vite.config.ts`: configuração do Vite com proxy de `/api` para a API
- `.env.example`: modelo das variáveis de ambiente (o `.env` não é versionado)
