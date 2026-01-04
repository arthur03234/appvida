import axios from 'axios'

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'

const api = axios.create({
  baseURL: API_URL,
})

// Add token to requests
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Auth Service
export const authService = {
  login: async (data: { email: string; password: string }) => {
    const response = await api.post('/auth/login', data)
    return response.data
  },

  register: async (data: {
    email: string
    password: string
    nome: string
    cpf: string
    telefone: string
  }) => {
    const response = await api.post('/auth/register', data)
    return response.data
  },

  validateToken: async (token: string) => {
    const response = await api.post('/auth/validate', { token })
    return response.data
  },
}

// User Service
export const userService = {
  getAll: async () => {
    const response = await api.get('/users')
    return response.data
  },

  getById: async (id: string) => {
    const response = await api.get(`/users/${id}`)
    return response.data
  },

  create: async (data: any) => {
    const response = await api.post('/users', data)
    return response.data
  },

  update: async (id: string, data: any) => {
    const response = await api.put(`/users/${id}`, data)
    return response.data
  },

  delete: async (id: string) => {
    const response = await api.delete(`/users/${id}`)
    return response.data
  },
}

export default api
