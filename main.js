import './style.css'

document.querySelector('#app').innerHTML = `
  <h1>Projeto da ONG</h1>
  <p id="status">Status da API: carregando...</p>
  <p id="hora"></p>
`

async function verificarApi() {
  const status = document.querySelector('#status')
  const hora = document.querySelector('#hora')

  try {
    const resposta = await fetch('/api/health')
    if (!resposta.ok) throw new Error(`HTTP ${resposta.status}`)
    const dados = await resposta.json()

    status.textContent = `Status da API: ${dados.status}`
    hora.textContent = `Data e hora: ${new Date(dados.timestamp).toLocaleString('pt-BR')}`
  } catch (erro) {
    status.textContent = 'Status da API: indisponível'
    hora.textContent = 'Inicie a API com "npm run api".'
  }
}

verificarApi()
