# AppVida Frontend

Frontend da aplicação AppVida construído com Next.js 14, React e TailwindCSS.

## Tecnologias

- **Next.js 14** - Framework React com App Router
- **React 18** - Biblioteca de UI
- **TypeScript** - Tipagem estática
- **TailwindCSS** - Framework CSS utilitário
- **React Hook Form** - Gerenciamento de formulários
- **Zod** - Validação de schemas
- **Axios** - Cliente HTTP

## Estrutura de Pastas

```
src/
├── app/              # Pages e layouts (App Router)
│   ├── layout.tsx    # Layout principal
│   ├── page.tsx      # Homepage
│   ├── login/        # Página de login
│   ├── register/     # Página de registro
│   └── dashboard/    # Dashboard de usuários
├── components/       # Componentes reutilizáveis
│   ├── ui/          # Componentes de UI (Button, Input, etc)
│   └── UserCard.tsx # Card de usuário
├── contexts/        # React Contexts
│   └── AuthContext.tsx  # Contexto de autenticação
└── services/        # Serviços de API
    └── api.ts       # Cliente Axios e serviços
```

## Executar Localmente

```bash
# Instalar dependências
npm install

# Configurar variáveis de ambiente
cp .env.local.example .env.local

# Executar em modo desenvolvimento
npm run dev
```

Acesse http://localhost:3003

## Build para Produção

```bash
# Build
npm run build

# Iniciar servidor de produção
npm start
```

## Docker

```bash
# Build da imagem
docker build -t appvida-frontend .

# Executar container
docker run -p 3003:3003 -e NEXT_PUBLIC_API_URL=http://api-gateway:3000 appvida-frontend
```

## Funcionalidades

### Autenticação
- Login com email e senha
- Registro de novos usuários
- Validação de token JWT
- Context API para gerenciamento de estado

### Dashboard
- Listagem de usuários cadastrados
- Cards com informações formatadas (CPF, telefone)
- Design responsivo

### UI/UX
- Design moderno com TailwindCSS
- Componentes reutilizáveis
- Validação de formulários em tempo real
- Feedback visual (loading, erros)
- Responsivo para mobile e desktop

## Variáveis de Ambiente

```env
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## Scripts Disponíveis

- `npm run dev` - Inicia servidor de desenvolvimento
- `npm run build` - Build para produção
- `npm start` - Inicia servidor de produção
- `npm run lint` - Executa ESLint
- `npm run type-check` - Verifica tipos TypeScript
