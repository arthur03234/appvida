/**
 * Script para configurar estrutura inicial do MongoDB
 * 
 * Uso:
 * node scripts/setup-mongodb.js
 */

const { MongoClient } = require('mongodb');

// Connection string do MongoDB Atlas
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb+srv://arthurresende_db_user:4aa766v7b77ZYA1w@cluster0.fla9u2a.mongodb.net/?appName=Cluster0';
const DB_NAME = 'appvida';

async function setupDatabase() {
  const client = new MongoClient(MONGODB_URI);

  try {
    console.log('🔌 Conectando ao MongoDB Atlas...');
    await client.connect();
    console.log('✅ Conectado com sucesso!');

    const db = client.db(DB_NAME);

    // Criar collection users
    console.log('\n📦 Criando collection "users"...');
    try {
      await db.createCollection('users', {
        validator: {
          $jsonSchema: {
            bsonType: 'object',
            required: ['email', 'password'],
            properties: {
              email: {
                bsonType: 'string',
                pattern: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
                description: 'Email deve ser válido'
              },
              password: {
                bsonType: 'string',
                minLength: 60,
                maxLength: 60,
                description: 'Password deve ser hash bcrypt'
              },
              isActive: {
                bsonType: 'bool'
              },
              isVerified: {
                bsonType: 'bool'
              }
            }
          }
        }
      });
      console.log('✅ Collection "users" criada');
    } catch (error) {
      if (error.code === 48) {
        console.log('⚠️  Collection "users" já existe');
      } else {
        throw error;
      }
    }

    // Criar collection profiles
    console.log('\n📦 Criando collection "profiles"...');
    try {
      await db.createCollection('profiles', {
        validator: {
          $jsonSchema: {
            bsonType: 'object',
            required: ['userId', 'nome', 'cpf', 'dataNascimento', 'telefone'],
            properties: {
              userId: {
                bsonType: 'objectId'
              },
              nome: {
                bsonType: 'string',
                minLength: 3
              },
              cpf: {
                bsonType: 'string',
                pattern: '^[0-9]{11}$'
              },
              dataNascimento: {
                bsonType: 'date'
              },
              telefone: {
                bsonType: 'string'
              }
            }
          }
        }
      });
      console.log('✅ Collection "profiles" criada');
    } catch (error) {
      if (error.code === 48) {
        console.log('⚠️  Collection "profiles" já existe');
      } else {
        throw error;
      }
    }

    // Criar collection refresh_tokens
    console.log('\n📦 Criando collection "refresh_tokens"...');
    try {
      await db.createCollection('refresh_tokens');
      console.log('✅ Collection "refresh_tokens" criada');
    } catch (error) {
      if (error.code === 48) {
        console.log('⚠️  Collection "refresh_tokens" já existe');
      } else {
        throw error;
      }
    }

    // Criar índices para users
    console.log('\n🔍 Criando índices para "users"...');
    await db.collection('users').createIndex({ email: 1 }, { unique: true });
    await db.collection('users').createIndex({ verificationToken: 1 });
    await db.collection('users').createIndex({ resetPasswordToken: 1 });
    console.log('✅ Índices criados para "users"');

    // Criar índices para profiles
    console.log('\n🔍 Criando índices para "profiles"...');
    await db.collection('profiles').createIndex({ userId: 1 }, { unique: true });
    await db.collection('profiles').createIndex({ cpf: 1 }, { unique: true });
    await db.collection('profiles').createIndex({ nome: 1 });
    await db.collection('profiles').createIndex({ 'endereco.cidade': 1, 'endereco.estado': 1 });
    console.log('✅ Índices criados para "profiles"');

    // Criar índices para refresh_tokens
    console.log('\n🔍 Criando índices para "refresh_tokens"...');
    await db.collection('refresh_tokens').createIndex({ userId: 1 });
    await db.collection('refresh_tokens').createIndex({ token: 1 });
    await db.collection('refresh_tokens').createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });
    console.log('✅ Índices criados para "refresh_tokens"');

    // Listar collections
    console.log('\n📋 Collections criadas:');
    const collections = await db.listCollections().toArray();
    collections.forEach(col => {
      console.log(`   - ${col.name}`);
    });

    // Verificar índices
    console.log('\n📊 Índices criados:');
    console.log('\n  Users:');
    const usersIndexes = await db.collection('users').indexes();
    usersIndexes.forEach(idx => {
      console.log(`   - ${idx.name}: ${JSON.stringify(idx.key)}`);
    });

    console.log('\n  Profiles:');
    const profilesIndexes = await db.collection('profiles').indexes();
    profilesIndexes.forEach(idx => {
      console.log(`   - ${idx.name}: ${JSON.stringify(idx.key)}`);
    });

    console.log('\n  Refresh Tokens:');
    const tokensIndexes = await db.collection('refresh_tokens').indexes();
    tokensIndexes.forEach(idx => {
      console.log(`   - ${idx.name}: ${JSON.stringify(idx.key)}`);
    });

    console.log('\n✅ Setup do MongoDB concluído com sucesso!');
    console.log('\n🎉 Banco de dados "appvida" configurado e pronto para uso!');

  } catch (error) {
    console.error('❌ Erro ao configurar MongoDB:', error);
    process.exit(1);
  } finally {
    await client.close();
    console.log('\n🔌 Conexão fechada.');
  }
}

// Executar setup
setupDatabase();
