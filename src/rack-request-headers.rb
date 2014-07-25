require 'rack'

app = proc do |env|
  # La variabile `env` è un dizionario che contiene headers CGI e di conseguenza
  # gli header della richiesta HTTP sono individuati da chiavi prefissate con
  # `HTTP_`. Questo handler processa una richiesta HTTP stampando tutti gli
  # header HTTP della richiesta.
  headers = env.select { |key, _| key.start_with?('HTTP_') }

  headers = headers.map do |key, val|
    header = key.sub /^HTTP_/, ''
    header = header.split('_').map(&:capitalize).join('-')
    "#{header}: #{val}\n"
  end

  [200, { 'Content-Type' => 'text/plain' }, headers]
end

Rack::Handler::WEBrick.run app
