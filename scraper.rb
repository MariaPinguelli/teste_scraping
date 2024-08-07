require 'selenium-webdriver'

puts "------------------- Iniciando Scraper -------------------"

# Selenium::WebDriver::Chrome::Service.driver_path = 'c:\WebDriver\chromedriver-win64\chromedriver-win64\chromedriver.exe'
options = Selenium::WebDriver::Chrome::Options.new
# options.add_argument('--no-sandbox')
# options.add_argument('--headless')
# options.add_argument('--disable-dev-shm-usage')
# options.add_argument('--disable-software-rasterizer')
# options.add_argument('--disable-gpu') # Tentar manter a flag para desabilitar GPU

# Inicializar o driver com as opções
scraper = Selenium::WebDriver.for(:chrome, options: options)

# Desativar WebDriver flag
# scraper.execute_cdp('Page.addScriptToEvaluateOnNewDocument', source: """
#   Object.defineProperty(navigator, 'webdriver', {
#     get: () => undefined
#   })
# """)

# Definir plataformas
sympla = 'https://www.sympla.com.br/eventos/show-musica-festa/todos-eventos'

# Navegar para a página desejada
scraper.get sympla

# Configurar evento de espera
wait = Selenium::WebDriver::Wait.new(timeout: 10)

# Fechar cookies
# #onetrust-banner-sdk .onetrust-close-btn-ui
wait.until { scraper.find_element(:css, '#onetrust-banner-sdk .onetrust-close-btn-ui') }
close_cookie = scraper.find_element(:css, '#onetrust-banner-sdk .onetrust-close-btn-ui');
close_cookie.click

# Simular ações de usuário real
scraper.action.move_to_location(100, 100).perform
# scraper.execute_script('window.scrollTo(0, document.body.scrollHeight)')

# Esperar até que os elementos estejam presentes
wait.until { scraper.find_elements(class: 'sympla-card').size > 0 }

events_list = scraper.find_elements(class: 'sympla-card')
puts "\n\nEVENT LIST LEN #{events_list.size}\n\n"
events_list.each_with_index do |event, index|
  begin
    # Re-obter o elemento logo antes de interagir com ele
    # event = scraper.find_elements(class: 'sympla-card')[index]

    # Role para o elemento e aguarde até que ele esteja clicável
    wait.until { event.displayed? && event.enabled? }

    # Tente clicar no elemento
    event.click

    # Pegar o título do evento
    title = scraper.find_element(tag_name: 'h1')
    puts "-------------------"
    puts "#{index} - #{title}"

    # Voltar para a página anterior
    scraper.navigate.back
  rescue Selenium::WebDriver::Error::ElementClickInterceptedError
    puts "Elemento no índice #{index} não pode ser clicado."
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    puts "Erro ao processar o elemento no índice #{index}: stale element reference"
  rescue => e
    puts "Erro ao processar o elemento no índice #{index}: #{e.message}"
  end
end

# Encerrar o scraper
scraper.quit

puts "------------------- Encerrando Scraper ------------------"
