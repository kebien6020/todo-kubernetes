import {IconButton, styled, TextField} from '@material-ui/core'
import {Add as AddIcon} from '@material-ui/icons'
import {useState} from 'react'
import {api} from './api'

const initialFormState = {
  text: '',
}

export const TodoForm = ({onAdd = () => {}}) => {
  const [formState, setFormState] = useState(initialFormState)

  const handleSubmit = async (event) => {
    event.preventDefault()

    await api.post('v1/todos', {
      json: {
        text: formState.text,
        done: false,
      },
    }).json()

    onAdd()
    setFormState(initialFormState) // clear the form
  }

  const handleChange = event => {
    const { value, name } = event.target
    setFormState(prev => ({
      ...prev,
      [name]: value
    }))
  }

  return (
    <FormWrapper onSubmit={handleSubmit}>
      <TextField
        name='text'
        value={formState.text}
        onChange={handleChange}
        label='What do you want to do?'
        fullWidth
      />
      <AddButton type='submit' edge='end' />
    </FormWrapper>
  )
}

const FormWrapper = styled('form')({
  display: 'flex',
  alignItems: 'baseline',
  gap: 8,
})

const AddButton = props =>
  <IconButton color='primary' {...props}><AddIcon /></IconButton>
