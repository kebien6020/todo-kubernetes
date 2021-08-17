import { createTheme, CssBaseline, MuiThemeProvider, useMediaQuery } from '@material-ui/core'

const lightTheme = createTheme({
  palette: {
    type: 'light',
  },
})

const darkTheme = createTheme({
  palette: {
    type: 'dark',
  },
})

export const ThemeProvider = ({children}) => {
  const prefersDark = useMediaQuery('(prefers-color-scheme: dark)')
  const theme = prefersDark ? darkTheme : lightTheme

  return (
    <MuiThemeProvider theme={theme}>
      <CssBaseline>
        {children}
      </CssBaseline>
    </MuiThemeProvider>
  )
}
