# Arquitetura do AppVida

## Visão Geral

O AppVida é uma aplicação de microsserviços para cadastro de usuários, construída com Node.js/NestJS e hospedada na AWS.

## Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                         AWS Cloud                            │
│                                                              │
│  ┌────────────────┐                                         │
│  │  API Gateway   │  (AWS API Gateway)                      │
│  │   (entrada)    │                                          │
│  └────────┬───────┘                                          │
│           │                                                  │
│           ▼                                                  │
│  ┌────────────────┐         ┌──────────────────┐           │
│  │  Application   │         │   Load Balancer  │           │
│  │  Load Balancer │◄────────┤   (ALB/NLB)      │           │
│  └────────┬───────┘         └──────────────────┘           │
│           │                                                  │
│  ┌────────┴───────────────────────────┐                     │
│  │        ECS/EKS Cluster              │                     │
│  │                                     │                     │
│  │  ┌─────────────────────────────┐   │                     │
│  │  │   API Gateway Service       │   │                     │
│  │  │   (NestJS - Port 3000)      │   │                     │
│  │  └──────────┬──────────────────┘   │                     │
│  │             │                       │                     │
│  │    ┌────────┴────────┐              │                     │
│  │    │                 │              │                     │
│  │    ▼                 ▼              │                     │
│  │  ┌──────────┐   ┌──────────┐       │                     │
│  │  │  Auth    │   │  User    │       │                     │
│  │  │ Service  │   │ Service  │       │                     │
│  │  │(Port3001)│   │(Port3002)│       │                     │
│  │  └────┬─────┘   └────┬─────┘       │                     │
│  │       │              │              │                     │
│  └───────┼──────────────┼──────────────┘                     │
│          │              │                                    │
│          └──────┬───────┘                                    │
│                 │                                            │
└─────────────────┼────────────────────────────────────────────┘
                  │
                  ▼
         ┌────────────────┐
         │  MongoDB Atlas │
         │  (sa-east-1)   │
         └────────────────┘

         ┌────────────────┐
         │    Frontend    │
         │   (Next.js)    │
         │  S3 + CloudFront│
         └────────────────┘
```

## Componentes

### 1. API Gateway (Microsserviço)
**Responsabilidades:**
- Roteamento de requisições
- Validação de autenticação
- Rate limiting
- Logging centralizado
- Agregação de respostas (se necessário)

**Tecnologias:**
- NestJS
- Express
- JWT validation

**Endpoints:**
- `GET /health` - Health check
- `/auth/*` - Proxy para Auth Service
- `/users/*` - Proxy para User Service

### 2. Auth Service
**Responsabilidades:**
- Registro de novos usuários
- Login e geração de JWT
- Refresh de tokens
- Validação de tokens
- Hash de senhas (bcrypt)

**Tecnologias:**
- NestJS
- JWT (jsonwebtoken)
- bcrypt
- MongoDB (collection: users)

**Endpoints:**
- `POST /auth/register` - Registrar novo usuário
- `POST /auth/login` - Login e obter token
- `POST /auth/refresh` - Atualizar token
- `POST /auth/validate` - Validar token

### 3. User Service
**Responsabilidades:**
- CRUD de usuários
- Validação de dados
- Busca e filtros
- Atualização de perfis

**Tecnologias:**
- NestJS
- MongoDB (collection: profiles)
- class-validator

**Endpoints:**
- `GET /users` - Listar usuários
- `GET /users/:id` - Buscar usuário por ID
- `POST /users` - Criar usuário
- `PUT /users/:id` - Atualizar usuário
- `DELETE /users/:id` - Deletar usuário

### 4. Frontend
**Responsabilidades:**
- Interface web responsiva
- Formulários de cadastro
- Autenticação
- Gerenciamento de estado

**Tecnologias:**
- Next.js 14+
- React
- TypeScript
- TailwindCSS
- React Query

**Deploy:**
- S3 (arquivos estáticos)
- CloudFront (CDN)

## Comunicação Entre Serviços

### REST API
- Protocolo HTTP/HTTPS
- Formato JSON
- Autenticação via JWT (Bearer token)

### Exemplo de Fluxo

```
Cliente → API Gateway → Auth Service
    1. POST /auth/login
    2. Retorna JWT token

Cliente → API Gateway → User Service
    1. GET /users (com JWT no header)
    2. API Gateway valida token
    3. Encaminha para User Service
    4. Retorna lista de usuários
```

## Modelo de Dados

### Users Collection (Auth Service)
```typescript
{
  _id: ObjectId,
  email: string,
  password: string (hashed),
  createdAt: Date,
  updatedAt: Date
}
```

### Profiles Collection (User Service)
```typescript
{
  _id: ObjectId,
  userId: ObjectId (ref to Users),
  nome: string,
  cpf: string,
  dataNascimento: Date,
  telefone: string,
  endereco: {
    rua: string,
    numero: string,
    complemento: string,
    bairro: string,
    cidade: string,
    estado: string,
    cep: string
  },
  createdAt: Date,
  updatedAt: Date
}
```

## Segurança

1. **Autenticação**: JWT tokens com expiração
2. **Autorização**: Role-based access control (RBAC)
3. **Criptografia**: HTTPS em todas as comunicações
4. **Senhas**: Hash com bcrypt (salt rounds: 10)
5. **Rate Limiting**: Proteção contra ataques de força bruta
6. **CORS**: Configurado para domínios específicos
7. **Validação**: Input validation em todos os endpoints

## Escalabilidade

1. **Horizontal Scaling**: ECS/EKS permite adicionar mais containers
2. **Auto Scaling**: Baseado em métricas (CPU, memória, requests)
3. **Database**: MongoDB Atlas com auto-scaling
4. **Cache**: Redis para sessões e dados frequentes (futuro)
5. **CDN**: CloudFront para frontend

## Monitoramento

- **AWS CloudWatch**: Logs e métricas
- **Health Checks**: Endpoints de saúde em cada serviço
- **Alertas**: SNS para notificações
- **Tracing**: AWS X-Ray (opcional)

## Ambientes

1. **Development**: Local com Docker Compose
2. **Staging**: AWS ECS com banco de desenvolvimento
3. **Production**: AWS ECS com MongoDB Atlas production cluster
