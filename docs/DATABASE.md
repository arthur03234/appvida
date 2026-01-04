# Estrutura do Banco de Dados MongoDB

## Cluster MongoDB Atlas

**Cluster**: cluster0.fla9u2a.mongodb.net
**Usuário**: arthurresende_db_user

## Databases

O projeto AppVida utiliza um único cluster com databases separados por contexto:

### 1. Database: `appvida`

Database principal para a aplicação.

## Collections

### Collection: `users`

**Responsável**: Auth Service

**Descrição**: Armazena credenciais de autenticação dos usuários.

**Schema**:

```typescript
{
  _id: ObjectId,
  email: string,           // Único, obrigatório
  password: string,        // Hash bcrypt, obrigatório
  isActive: boolean,       // Default: true
  isVerified: boolean,     // Default: false
  verificationToken?: string,
  resetPasswordToken?: string,
  resetPasswordExpires?: Date,
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes**:
```javascript
// Índice único no email
db.users.createIndex({ "email": 1 }, { unique: true })

// Índice para busca por tokens
db.users.createIndex({ "verificationToken": 1 })
db.users.createIndex({ "resetPasswordToken": 1 })
```

**Exemplo de documento**:
```json
{
  "_id": "507f1f77bcf86cd799439011",
  "email": "usuario@exemplo.com",
  "password": "$2b$10$EixZaYVK1fsbw1ZfbX3OXePaWxn96p36WQoeG6Lruj3vjPGga31lW",
  "isActive": true,
  "isVerified": true,
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

---

### Collection: `profiles`

**Responsável**: User Service

**Descrição**: Armazena informações de perfil dos usuários.

**Schema**:

```typescript
{
  _id: ObjectId,
  userId: ObjectId,        // Referência para users._id, obrigatório, único
  nome: string,            // Obrigatório
  cpf: string,             // Único, obrigatório
  dataNascimento: Date,    // Obrigatório
  telefone: string,        // Obrigatório
  foto?: string,           // URL da foto
  endereco: {
    rua: string,
    numero: string,
    complemento?: string,
    bairro: string,
    cidade: string,
    estado: string,        // Sigla: SP, RJ, MG, etc
    cep: string
  },
  metadata: {
    lastLogin?: Date,
    loginCount: number,    // Default: 0
  },
  createdAt: Date,
  updatedAt: Date
}
```

**Indexes**:
```javascript
// Índice único no userId
db.profiles.createIndex({ "userId": 1 }, { unique: true })

// Índice único no CPF
db.profiles.createIndex({ "cpf": 1 }, { unique: true })

// Índice para busca por nome
db.profiles.createIndex({ "nome": 1 })

// Índice composto para busca por localização
db.profiles.createIndex({ "endereco.cidade": 1, "endereco.estado": 1 })
```

**Exemplo de documento**:
```json
{
  "_id": "507f1f77bcf86cd799439012",
  "userId": "507f1f77bcf86cd799439011",
  "nome": "João da Silva",
  "cpf": "12345678900",
  "dataNascimento": "1990-05-20T00:00:00.000Z",
  "telefone": "11987654321",
  "foto": "https://appvida.s3.amazonaws.com/profiles/507f1f77bcf86cd799439011.jpg",
  "endereco": {
    "rua": "Av. Paulista",
    "numero": "1000",
    "complemento": "Apto 101",
    "bairro": "Bela Vista",
    "cidade": "São Paulo",
    "estado": "SP",
    "cep": "01310-100"
  },
  "metadata": {
    "lastLogin": "2024-01-15T14:30:00.000Z",
    "loginCount": 42
  },
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T14:30:00.000Z"
}
```

---

### Collection: `refresh_tokens`

**Responsável**: Auth Service

**Descrição**: Armazena refresh tokens para renovação de JWT.

**Schema**:

```typescript
{
  _id: ObjectId,
  userId: ObjectId,        // Referência para users._id
  token: string,           // Refresh token hash
  expiresAt: Date,         // Data de expiração
  createdAt: Date
}
```

**Indexes**:
```javascript
// Índice no userId
db.refresh_tokens.createIndex({ "userId": 1 })

// Índice no token
db.refresh_tokens.createIndex({ "token": 1 })

// TTL index - remove automaticamente tokens expirados
db.refresh_tokens.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 })
```

**Exemplo de documento**:
```json
{
  "_id": "507f1f77bcf86cd799439013",
  "userId": "507f1f77bcf86cd799439011",
  "token": "a3f8b2c1d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1",
  "expiresAt": "2024-01-22T10:30:00.000Z",
  "createdAt": "2024-01-15T10:30:00.000Z"
}
```

---

## Setup Inicial

### 1. Criar Collections

Execute os comandos abaixo no MongoDB Shell ou Compass:

```javascript
// Selecionar database
use appvida

// Criar collection users com validação
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "password"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
          description: "Email deve ser válido"
        },
        password: {
          bsonType: "string",
          minLength: 60,
          maxLength: 60,
          description: "Password deve ser hash bcrypt"
        },
        isActive: {
          bsonType: "bool"
        },
        isVerified: {
          bsonType: "bool"
        }
      }
    }
  }
})

// Criar collection profiles
db.createCollection("profiles", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "nome", "cpf", "dataNascimento", "telefone"],
      properties: {
        userId: {
          bsonType: "objectId"
        },
        nome: {
          bsonType: "string",
          minLength: 3
        },
        cpf: {
          bsonType: "string",
          pattern: "^[0-9]{11}$"
        },
        dataNascimento: {
          bsonType: "date"
        },
        telefone: {
          bsonType: "string"
        }
      }
    }
  }
})

// Criar collection refresh_tokens
db.createCollection("refresh_tokens")
```

### 2. Criar Índices

```javascript
// Users indexes
db.users.createIndex({ "email": 1 }, { unique: true })
db.users.createIndex({ "verificationToken": 1 })
db.users.createIndex({ "resetPasswordToken": 1 })

// Profiles indexes
db.profiles.createIndex({ "userId": 1 }, { unique: true })
db.profiles.createIndex({ "cpf": 1 }, { unique: true })
db.profiles.createIndex({ "nome": 1 })
db.profiles.createIndex({ "endereco.cidade": 1, "endereco.estado": 1 })

// Refresh tokens indexes
db.refresh_tokens.createIndex({ "userId": 1 })
db.refresh_tokens.createIndex({ "token": 1 })
db.refresh_tokens.createIndex({ "expiresAt": 1 }, { expireAfterSeconds: 0 })
```

### 3. Verificar Collections

```javascript
// Listar collections
show collections

// Verificar índices de cada collection
db.users.getIndexes()
db.profiles.getIndexes()
db.refresh_tokens.getIndexes()
```

## Conexão nos Serviços

### Auth Service

```typescript
// .env
MONGODB_URI=mongodb+srv://arthurresende_db_user:4aa766v7b77ZYA1w@cluster0.fla9u2a.mongodb.net/appvida?retryWrites=true&w=majority
```

Utiliza collections: `users`, `refresh_tokens`

### User Service

```typescript
// .env
MONGODB_URI=mongodb+srv://arthurresende_db_user:4aa766v7b77ZYA1w@cluster0.fla9u2a.mongodb.net/appvida?retryWrites=true&w=majority
```

Utiliza collection: `profiles`

## Backup e Segurança

### Recomendações

1. **Backup Automático**: Configurar backup diário no MongoDB Atlas
2. **Point-in-Time Recovery**: Ativar para restauração precisa
3. **IP Whitelist**: Adicionar IPs da AWS onde os serviços rodarão
4. **Usuários**: Criar usuários específicos por serviço com permissões limitadas
5. **Encryption**: Atlas usa encryption at rest por padrão

### Criar Usuário Específico para Produção

```javascript
// Usuário read-only para relatórios
db.createUser({
  user: "appvida_readonly",
  pwd: "senha_segura",
  roles: [
    { role: "read", db: "appvida" }
  ]
})

// Usuário para auth service
db.createUser({
  user: "appvida_auth",
  pwd: "senha_segura",
  roles: [
    { role: "readWrite", db: "appvida", collection: "users" },
    { role: "readWrite", db: "appvida", collection: "refresh_tokens" }
  ]
})

// Usuário para user service
db.createUser({
  user: "appvida_users",
  pwd: "senha_segura",
  roles: [
    { role: "readWrite", db: "appvida", collection: "profiles" },
    { role: "read", db: "appvida", collection: "users" }
  ]
})
```

## Monitoramento

### Métricas Importantes

1. **Query Performance**: Monitorar queries lentas (>100ms)
2. **Connection Pool**: Acompanhar conexões abertas
3. **Disk Usage**: Alertar quando > 80%
4. **Index Usage**: Verificar índices não utilizados

### MongoDB Atlas Charts

Criar dashboards para:
- Crescimento de usuários
- Distribuição geográfica (por cidade/estado)
- Atividade de login
- Novos registros por dia
