# Guia de Desenvolvimento

## Pré-requisitos

- Node.js 20+
- Docker e Docker Compose
- MongoDB Atlas account
- Git

## Setup Inicial

### 1. Clonar o Repositório

```bash
git clone https://github.com/arthur03234/appvida.git
cd appvida
```

### 2. Instalar Dependências

```bash
npm install
```

### 3. Configurar Variáveis de Ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env` com suas credenciais:
- MongoDB Atlas connection string
- JWT secret
- AWS credentials (para deploy)

### 4. Executar Localmente

```bash
# Iniciar todos os serviços com Docker Compose
npm run dev

# OU executar serviços individualmente
cd services/api-gateway && npm run dev
cd services/auth-service && npm run dev
cd services/user-service && npm run dev
cd frontend && npm run dev
```

## Estrutura de Cada Serviço

Cada microsserviço segue a estrutura NestJS:

```
service-name/
├── src/
│   ├── main.ts
│   ├── app.module.ts
│   ├── app.controller.ts
│   ├── app.service.ts
│   └── modules/
├── test/
├── Dockerfile
├── package.json
└── tsconfig.json
```

## Comandos Úteis

### Desenvolvimento

```bash
# Executar todos os serviços
npm run dev

# Build de todos os serviços
npm run build

# Testes
npm run test

# Lint
npm run lint

# Format código
npm run format
```

### Docker

```bash
# Build das imagens
docker-compose build

# Iniciar serviços
docker-compose up

# Parar serviços
docker-compose down

# Ver logs
docker-compose logs -f [service-name]
```

## Padrões de Código

### Commits

Usar conventional commits:

```
feat: adiciona nova funcionalidade
fix: corrige bug
docs: atualiza documentação
style: formatação de código
refactor: refatoração de código
test: adiciona/atualiza testes
chore: tarefas de manutenção
```

### TypeScript

- Usar tipos explícitos
- Evitar `any`
- Usar interfaces para objetos
- Usar enums para constantes

### NestJS

- Usar decorators do NestJS
- Seguir arquitetura modular
- Usar DTOs para validação
- Implementar exception filters

## Testes

### Unitários

```bash
npm run test
```

### E2E

```bash
npm run test:e2e
```

### Coverage

```bash
npm run test:cov
```

## Debug

### VS Code

Adicionar ao `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "attach",
      "name": "Debug",
      "port": 9229
    }
  ]
}
```

## Troubleshooting

### MongoDB Connection

Se tiver erro de conexão:
1. Verificar se o IP está na whitelist do Atlas
2. Verificar credenciais no `.env`
3. Testar connection string

### Docker

Se containers não iniciarem:
1. Limpar containers antigos: `docker-compose down -v`
2. Rebuild: `docker-compose build --no-cache`
3. Verificar portas em uso

### Node Modules

Se tiver problemas com dependências:
```bash
rm -rf node_modules package-lock.json
npm install
```
