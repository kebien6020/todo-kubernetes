import {CircularProgress, Container, List, ListItem, Paper, styled} from '@material-ui/core'
import {useEffect, useReducer, useState} from 'react'
import {VSpace} from './layout'
import {TodoForm} from './TodoForm'
import {api} from './api'

const useTodos = () => {
  const [loading, setLoading] = useState(true)
  const [data, setData] = useState(undefined)
  const [nonce, refresh] = useReducer(prev => prev + 1, 1)
  useEffect(() => {
    (async () => {
      try {
        const data = await api.get('v1/todos').json()
        setData(data)
      } finally {
        setLoading(false)
      }
    })()
  }, [nonce])

  return [data, {loading, refresh, error: null}]
}

export const Todo = () => {
  const [todos, {loading, refresh}] = useTodos()

  return (
    <Wrapper>
      <TodoForm onAdd={refresh}/>
      <VSpace />
      {loading ? <CircularProgress /> :
        <TodoList todos={todos} />
      }
    </Wrapper>
  )
}

const Wrapper = styled(
  props => <Container maxWidth='sm' {...props} />
)({
  paddingTop: 16,
})

const TodoList = ({todos}) => (
  <Paper>
    <List>
      {todos?.map(todo => <TodoItem key={todo.id} todo={todo} />)}
    </List>
  </Paper>
)

const TodoItem = ({todo}) => (
  <ListItem>
    {todo.text} - {todo.done ? 'done' : 'not done'}
  </ListItem>
)
