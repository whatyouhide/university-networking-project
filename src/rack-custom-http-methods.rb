require 'rack'

class CustomRequestMethods
  def initialize(app); @app = app; end

  def call(env)
    # "Wrappiamo" la richiesta in un oggetto Rack::Request in modo da poter
    # utilizzare diverse funzioni utili come il parsing dei parametri.
    req = Rack::Request.new(env)

    # Sostituiamo `env['REQUEST_METHOD']` se è presente un parametro `__method`.
    if req.params['__method']
      env['REQUEST_METHOD'] = req.params['__method']
    end

    @app.call(env)
  end
end

# Il server principale risponderà con un body in cui stampa il metodo di
# richiesta della richiesta che ha ricevuto (in realtà della richiesta
# possibilmente alterata dal middleware CustomRequestMethods che riceve).
server = proc do |env|
  body = "<body>I received a #{env['REQUEST_METHOD']} request.</body>"
  [200, { 'Content-Type' => 'text/html' }, [body]]
end

Rack::Handler::WEBrick.run(
  Rack::Builder.new { use CustomRequestMethods; run server }
)
