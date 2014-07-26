require 'rack'

class CustomRequestMethods
  def initialize(app); @app = app; end

  def call(env)
    # "Wrappiamo" la richiesta in un oggetto Rack::Request in modo da poter
    # utilizzare diverse funzioni utili come il parsing dei parametri.
    req = Rack::Request.new(env)

    # Sostituiamo `env['REQUEST_METHOD']` se è presente un parametro `__type`.
    if req.params['__type']
      env['REQUEST_METHOD'] = req.params['__type']
    end

    @app.call(env)
  end
end

# Il server principale risponderà con un body in cui stampa il metodo di
# richiesta della richiesta che ha ricevuto (in realtà della richiesta
# possibilmente alterata dal middleware CustomRequestMethods che riceve).
server = proc do |env|
  body = "I received a #{env['REQUEST_METHOD']} request."
  [200, { 'Content-Type' => 'text/plain' }, [body]]
end

Rack::Handler::WEBrick.run(Rack::Builder.new { use CustomRequestMethods; run server })
