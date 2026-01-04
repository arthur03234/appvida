# API Gateway - AppVida

API Gateway para roteamento e autenticação centralizada dos microsserviços AppVida.

## Tecnologias

- **NestJS** - Framework Node.js
- **Passport + JWT** - Autenticação
- **Axios** - Proxy HTTP
- **Helmet** - Segurança HTTP
- **Throttler** - Rate limiting
- **TypeScript** - Tipagem estática

## Funcionalidades

### Proxy de Rotas

- **Auth Routes** (`/api/auth/*`) - Proxy para Auth Service
  - `POST /api/auth/register` - Registro (público)
  - `POST /api/auth/login` - Login (público)
  - `POST /api/auth/refresh` - Refresh token
  - `POST /api/auth/validate` - Validar token

- **User Routes** (`/api/users/*`) - Proxy para User Service (protegido)
  - `GET /api/users` - Listar usuários
  - `GET /api/users/:id` - Buscar usuário
  - `POST /api/users` - Criar usuário
  - `PUT /api/users/:id` - Atualizar usuário
  - `DELETE /api/users/:id` - Deletar usuário

### Segurança

- ✅ JWT Authentication
- ✅ Rate Limiting (100 requests/minuto por padrão)
- ✅ Helmet (security headers)
- ✅ CORS configurado
- ✅ Validação de entrada
- ✅ Compressão de resposta

### Health Checks

- `GET /api/health` - Health check completo
- `GET /api/health/liveness` - Liveness probe
- `GET /api/health/readiness` - Readiness probe

## Instalação

```bash
npm install
```

## Configuração

Crie um arquivo `.env`:

```env
NODE_ENV=development
PORT=3000

# JWT
JWT_SECRET=your-super-secret-jwt-key

# Services
AUTH_SERVICE_URL=http://localhost:3001
USER_SERVICE_URL=http://localhost:3002

# Rate Limiting
THROTTLE_TTL=60
THROTTLE_LIMIT=100
```

## Executar

```bash
# Desenvolvimento
npm run dev

# Produção
npm run build
npm run start:prod
```

## Docker

```bash
# Build
docker build -t appvida-api-gateway .

# Run
docker run -p 3000:3000 \
  -e JWT_SECRET=secret \
  -e AUTH_SERVICE_URL=http://auth-service:3001 \
  -e USER_SERVICE_URL=http://user-service:3002 \
  appvida-api-gateway
```

## Arquitetura

```
API Gateway (Port 3000)
├── /api/auth/*  → Auth Service (3001)
├── /api/users/* → User Service (3002)
└── /api/health  → Health checks
```

## Guards

### JwtAuthGuard

Proteção automática de rotas. Rotas públicas usam decorator `@Public()`.

```typescript
// Rota protegida (padrão)
@Get('protected')
getProtected() {
  return 'Protected route';
}

// Rota pública
@Public()
@Get('public')
getPublic() {
  return 'Public route';
}
```

### ThrottlerGuard

Rate limiting aplicado em todas as rotas de proxy.

## Logging

O gateway registra:
- Requisições de proxy
- Erros de serviços
- Status de saúde

## Testes

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Coverage
npm run test:cov
```

## Estrutura de Código

```
src/
├── auth/
│   ├── decorators/
│   │   └── public.decorator.ts
│   ├── guards/
│   │   └── jwt-auth.guard.ts
│   ├── strategies/
│   │   └── jwt.strategy.ts
│   └── auth.module.ts
├── proxy/
│   ├── controllers/
│   │   ├── auth-proxy.controller.ts
│   │   └── user-proxy.controller.ts
│   ├── services/
│   │   └── proxy.service.ts
│   └── proxy.module.ts
├── health/
│   ├── health.controller.ts
│   └── health.module.ts
├── app.module.ts
└── main.ts
```

## Próximos Passos

- [ ] Implementar Auth Service
- [ ] Implementar User Service
- [ ] Adicionar observabilidade (Prometheus/Grafana)
- [ ] Implementar circuit breaker
- [ ] Adicionar cache (Redis)
