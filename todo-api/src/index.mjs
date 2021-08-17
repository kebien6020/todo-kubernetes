import express from 'express'
import knex from 'knex'
import cors from 'cors'

const app = express()
const db = knex({
  client: 'pg',
  connection: process.env.PG_CONNECTION_STRING,
})

app.use(express.json())
app.use(cors())

app.get('/', (_req, res) => {
  res.json({
    endopints: [
      '/v1/todos'
    ],
  })
})

app.get('/v1/todos', async (_req, res) => {
  const todos = await db('todos')
  res.json(todos)
})

app.post('/v1/todos', async (req, res) => {
  const data = req.body
  await db('todos').insert(data)
  res.json({})
})

app.listen(4300)

const setup = async () => {
  const todosCreated = await db.schema.hasTable('todos')
  if (!todosCreated) {
    console.log('Todos table does not exist, creating...')
    await db.schema.createTable('todos', t => {
      t.increments('id').primary()
      t.text('text')
      t.boolean('done')
    })
  }
}

setup()
