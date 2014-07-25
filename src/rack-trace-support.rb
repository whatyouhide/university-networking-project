require 'rack'

class TraceSupport
  def initialize(app); @app = app; end

  def call(env)
    # Lasciamo che il normale server rack gestisca la richiesta se essa non è
    # una TRACE.
    return @app.call(env) if env['REQUEST_METHOD'] != 'TRACE'

    # Costruiamo il body della risposta pezzo per pezzo.
    mirror_request = ["TRACE #{env['PATH_INFO']} #{env['HTTP_VERSION']}\n"]
    env.each do |header, value|
      next unless header.start_with?('HTTP_')
      h = header.sub('HTTP_', '').split('_').map(&:capitalize).join('-')
      mirror_request << "#{h}: #{value}\n"
    end
    mirror_request << "\n" + env['rack.input'].string

    # Rispondiamo con il body appena costruito.
    [200, {}, mirror_request]
  end
end

app = proc do |env|
  body = ["Regular #{env['REQUEST_METHOD']} request"]
  [200, { 'Content-Type' => 'text/plain' }, body]
end

handler = Rack::Builder.new do
  # Utilizziamo il middleware TraceSupport.
  use TraceSupport
  run app
end

Rack::Handler::WEBrick.run handler
