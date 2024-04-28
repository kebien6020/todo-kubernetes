import express, {Router} from 'express'
import cors from 'cors'
import { DynamoDBClient, PutItemCommand, QueryCommand, ScanCommand } from '@aws-sdk/client-dynamodb'
import * as uuid from 'uuid'

const app = express()
const db = new DynamoDBClient({})

app.use(express.json())
app.use(cors())

const api = Router()
app.use('/api', api)

api.get('/', (_req, res) => {
  res.json({
    endopints: [
      '/v1/users',
      '/v1/todos/:username',
    ],
  })
})

const cleanItem = it => {
  const entries = Object.entries(it)
  const mod = entries.map(([k, o]) => [k, Object.values(o)?.[0]])
  return Object.fromEntries(mod)
}

api.get('/v1/users', async (_req, res) => {
  const { Items } = await db.send(new ScanCommand({
    TableName: 'todo-kubernetes_users',
  }))

  const users = Items.map(cleanItem)

  res.json(users)
})

api.get('/v1/todos/:username', async (req, res) => {
  const username = req.params.username
  const done = req.query.done

  const { Items } = await db.send(new QueryCommand({
    TableName: 'todo-kubernetes_todos',
    KeyConditionExpression: 'username = :username',
    ...(done === undefined ? {} : {FilterExpression: 'done = :done'}),
    ExpressionAttributeValues: {
      ':username': {S: username},
      ...(done === undefined ? {} : {':done': {BOOL: done === 'true'}}),
    },
  }))

  const todos = Items.map(cleanItem)

  res.json(todos)
})

api.post('/v1/todos/:username', async (req, res) => {
  const username = req.params.username
  const {text, done = false} = req.body

  await db.send(new PutItemCommand({
    TableName: 'todo-kubernetes_todos',
    Item: {
      username: {S: username},
      id: {S: uuid.v4()},
      done: {BOOL: done},
      text: {S: text},
    },
  }))

  res.json({})
})

app.listen(4300)
