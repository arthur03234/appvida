# AppVida

Solução web de microsserviços para cadastro de usuários, hospedada na AWS com MongoDB Atlas.

## 🏗️ Arquitetura

Este projeto utiliza arquitetura de microsserviços com as seguintes tecnologias:

- **Backend**: Node.js + NestJS
- **Frontend**: React + Next.js
- **Banco de Dados**: MongoDB Atlas
- **Cloud**: AWS (ECS/EKS, API Gateway, ECR)
- **Comunicação**: REST API
- **Containerização**: Docker

## 📦 Estrutura do Projeto

```
appvida/
├── services/
│   ├── api-gateway/       # API Gateway - ponto de entrada único
│   ├── auth-service/      # Serviço de autenticação (JWT)
│   ├── user-service/      # Serviço de cadastro de usuários
│   └── shared/            # Código compartilhado entre serviços
├── frontend/              # Aplicação web (Next.js)
├── infrastructure/        # Configurações AWS (Terraform/CloudFormation)
├── docker-compose.yml     # Ambiente de desenvolvimento local
└── package.json           # Configuração do monorepo
```

## 🚀 Microsserviços

### API Gateway
- Roteamento de requisições
- Rate limiting
- Autenticação centralizada
- Agregação de respostas

### Auth Service
- Registro de usuários
- Login (JWT)
- Refresh tokens
- Validação de tokens

### User Service
- CRUD de usuários
- Gerenciamento de perfis
- Validações de dados
- Busca e filtros

## 🛠️ Tecnologias

- **Node.js 20+**
- **NestJS** - Framework para microsserviços
- **MongoDB** - Banco de dados NoSQL
- **Docker** - Containerização
- **AWS** - Cloud provider
- **GitHub Actions** - CI/CD

## 🚦 Como Executar

### Pré-requisitos
- Node.js 20+
- Docker e Docker Compose
- MongoDB Atlas account
- AWS account

### Desenvolvimento Local

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.example .env

# Iniciar todos os serviços
docker-compose up
```

### Acessar os Serviços

- **API Gateway**: http://localhost:3000
- **Auth Service**: http://localhost:3001
- **User Service**: http://localhost:3002
- **Frontend**: http://localhost:3003

## 📝 Documentação

- [Arquitetura](./docs/ARCHITECTURE.md)
- [Guia de Desenvolvimento](./docs/DEVELOPMENT.md)
- [Deploy na AWS](./docs/DEPLOYMENT.md)
- [API Documentation](./docs/API.md)

## 🤝 Contribuindo

1. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
2. Commit suas mudanças (`git commit -m 'feat: adiciona nova feature'`)
3. Push para a branch (`git push origin feature/nova-feature`)
4. Abra um Pull Request

## 📄 Licença

MIT License
