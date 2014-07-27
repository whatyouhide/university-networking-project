## Appendice su Rack [appendice-rack]

Rack è un'interfaccia Ruby per comunicare con web server scritti in Ruby.
Le applicazioni Rack possono essere considerate, tuttavia, dei web server a
tutti gli effetti: con esse si specificano i comportamenti che il server deve
adottare quando riceve una richiesta, e le risposte che deve inviare al client
richiedente.

Vediamo di descrivere brevemente la sintassi di Rack senza entrare nel dettaglio
della sintassi di Ruby.

Un server Rack non è altro che un oggetto Ruby in grado di rispondere al metodo
`call`, che deve prendere in input un parametro `env` rappresentante
l'environment della richiesta ricevuta; è dunque possibile utilizzare sia un
blocco (che in Ruby mette a disposizione il metodo `call` di default) che una
classe convenzionale che implementi il metodo di istanza `call`.

``` ruby
# Esempio di server Rack costruito con un blocco che prende il parametro `env`
# in input:
server = proc do |env|
  ...
end

# Esempio di server Rack implementato con classe convenzionale:
class Server
  def call(env)
    ...
  end
end
```

La specifica della struttura di `env` è disponibile
[online][rack-env-specification]. `env` è un dizionario chiave-valore 
che contiene headers CGI. Alcuni headers riguardano informazioni relative alla
richiesta e al server (come `env['REQUEST_METHOD']` che contiene il metodo di
richiesta); gli headers di richiesta HTTP sono contenuti negli headers
prefissati con `HTTP_`: ad esempio, l'header `Content-Length` viene trasformato
in `HTTP_CONTENT_LENGTH`.

Il metodo `call` che un server Rack deve implementare deve ritornare una tripla
di valori (sotto forma di array di valori) contenente:

- lo status code della risposta HTTP;
- un dizionario di headers di risposta HTTP (in cui le chiavi sono esattamente i
    nomi degli headers e i valori sono i valori degli headers)
- un body di risposta che deve essere un oggetto che risponde al metodo `each`
    (in genere si utilizza un array di stringhe, che risponde al metodo `each`)

Ad esempio:

``` ruby
server = proc do |env|
  [200, { 'Content-Type' => 'text/plain' }, ['hola', 'mundo']]
end
```

È possibile avviare un server Rack utilizzando il metodo `run` di uno degli
handler (ovvero le componenti di Rack dedicate a interfacciarsi con i web server
Ruby):

``` ruby
# Per avviare il server creato poco sopra utilizzando il web server WEBrick:
Rack::Handler::WEBrick.run(server)
```

#### Middlewares

In Rack è fondamentale il concetto di middleware. Un middleware Rack è
un'applicazione Rack (dunque un oggetto che risponde al metodo `call`) che viene
utilizzato per intercettare richieste e modificare environment e risposte.  
Durante il corso di questo documento i middleware Rack sono utilizzati per
diversi scopi, sia per modificare l'environment e poi passare il controllo al
server principale, sia per intercettare la richiesta e rispondere al posto del
server principale sotto determinate condizioni.

