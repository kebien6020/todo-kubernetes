import ReactDOM from 'react-dom'
import {ThemeProvider} from './theme'
import {Todo} from './Todo'

const App = () => (
  <ThemeProvider>
    <Todo />
  </ThemeProvider>
)

const root = document.querySelector('#root')
ReactDOM.render(<App />, root)
