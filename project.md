# HTTP - richieste, risposte e customizzazione

###### Andrea Leopardi
###### Reti di calcolatori (a.a. 2013/2014)


## Argomento analizzato

In questo documento analizzerò più a fondo le richieste e le risposte HTTP,
concentrandomi principalmente sui metodi di richiesta HTTP e i codici di
risposta HTTP. Tratterò, meno approfonditamente, anche gli *header*
HTTP.

## Introduzione ad HTTP

HTTP (Hypertext Transfer Protocol) è un protocollo a livello di applicazione
che connette un *client* e un *host* permettendo loro di scambiare dati.
HTTP sfrutta TCP come protocollo a livello di trasporto: è dunque un protocollo
orientato alla connessione.

HTTP è utilizzato per una vasta serie di scopi: web, streaming video,
condivisione di file, connessioni a host remoti. Anche se l'acronimo HTTP si
riferisce ad *Hyper Text* (ossia testo contenente hyperlink -- link logici ad
altri documenti di testo), HTTP permette a host e client di scambiare qualsiasi
tipo di dato.

Sul lato server, HTTP viene implementato da un *server HTTP*, ovvero un
programma in ascolto sulla porta 80 (tramite una socket quindi) dello host che
funge da server. Il lato client viene eseguito, la maggior parte delle volte, da
un browser web.

I messaggi HTTP possono essere **richieste** o **risposte**.

TODO spiegare meglio  
HTTP opera su risorse identificate da un URI (Uniform Resource Identifier) che
coincide con la sezione di un indirizzo web corrispondente al *path*.


### Versioni di HTTP

La prima versione di HTTP standardizzata fu HTTP/1.0, specificata nella [RFC
1945][rfc-http-1.0] del 1996.

Nel 1999, con la [RFC 2616][rfc-http-1.1] venne standardizzata la versione
successiva del protocollo HTTP, ovvero HTTP/1.1. Non ci furono molti cambiamenti
dalla versione 1.0 alla versione 1.1: esaminerò quelli interessanti nelle
relative sezioni.

Nonostante HTTP/1.1 non sia molto più giovane di HTTP/1.0, esso è lo standard
utilizzato ancora oggi. HTTP/1.0 [non è "morto"][http-1.0-isnt-dead] tuttavia:
molti proxy lo utilizzano, e anche dei client come [wget][wget].

HTTP 2.0 (su [wikipedia][http-2.0-wikipedia] e [qui][http-2.0-website]) è la
prossima versione del protocollo HTTP: nonostante sia in fase di sviluppo, essa
non è ancora adottata per usi pratici.

Durante tutto il documento la versione di HTTP di riferimento (a meno che non
specificato diversamente) sarà HTTP/1.1.


### Glossario dei concetti

Introduciamo terminologia e concetti che saranno utili durante il corso del
documento.

- Request-URI: è un URI (Uniform Resource Identifier) che identifica una risorsa
    su un server HTTP. Come vedremo in seguito, ogni richiesta HTTP è diretta a
    un URI.


### Tools utilizzati

Nel corso del documento, utilizzerò degli strumenti per mostrare il lato
"pratico" di HTTP. Utilizzerò principalmente un web framework per illustrare il
lato server di HTTP in modo conciso e funzionale, e un client HTTP da command
line per illustrare il lato client di HTTP.

Questi esempi sono volti a mostrare come sia possibile modellare HTTP
nella pratica.

##### Tools lato server

Per il lato server di HTTP utilizzerò due strumenti:

- [Rack][rack]: Rack può essere considerato un web server scritto in Ruby. In
    realtà esso è un'astrazione che permette di scrivere codice lato server che
    poi può essere utilizzato con diversi server (veri e propri) scritti in
    Ruby, come [WEBrick][webrick] (incluso nelle librerie standard di Ruby),
    [Thin][thin] o [Puma][puma].
- [Sinatra][sinatra]: Sinatra è un vero e proprio web framework scritto in Ruby.
    Sinatra permette, con un DSL (*Domain Specific Language*) chiaro e conciso,
    di processare richieste HTTP e generare risposte HTTP.

##### Tools lato client

Il più famoso tool (incluso di default in UNIX) utilizzato per eseguire
richieste HTTP è sicuramente [*curl*][curl]. *curl* ha una sintassi abbastanza
criptica (basti pensare all'opzione `-X`, che permette di specificare il metodo
di richiesta HTTP) e dunque utilizzeremo un tool equivalente chiamato
[HTTPie][httpie].

HTTPie è un programma scritto in Python che permette di effettuare richieste
HTTP con una sintassi "human-friendly": per questa ragione ogni volta che
verrà utilizzato HTTPie sarà subito chiaro cosa si sta facendo. HTTPie può
essere installato con [pip][pip] (`pip install httpie`) e mette a disposizione
il comando `http`.

Ecco un esempio di richiesta `GET` effettuata con HTTPie alla homepage di
Google, filtrata in modo da mostrare solo gli header della risposta:

    $ http GET google.com --headers


## Richieste HTTP

Una richiesta HTTP è formata da un'intestazione e un corpo opzionale.

L'intestazione è formata da:

- una riga di richiesta formata in ordine da metodo di richiesta, path sul
    server e versione di HTTP, separati da un singolo spazio
- zero o più *headers* nella forma `HEADER-NAME: value`
- una riga vuota
- un "corpo" opzionale contenente una quantità arbitraria di dati

La riga di richiesta e le righe contenenti gli headers (un header per riga)
devono terminare con un carattere di *carriage return* seguito da un carattere
di *line feed*. La riga vuota deve contenere solo un carattere di *carriage
return* seguito da uno di *line feed*.

È importante notare che in HTTP/1.1 (rispetto ad HTTP/1.0) diventa obbligatorio
l'header `Host`.

Vediamo un esempio di richiesta HTTP *well-formed* che un form su un sito web
potrebbe inviare all'indirizzo `http://flickr.com/images`:

``` http
POST /images HTTP/1.1
Host: flickr.com
User-Agent: Mozilla Firefox

image_name=foo
```

È chiara la funzionalità della versione di HTTP. Il body non fa altro che
trasferire dati al server. Vediamo più a fondo metodo di richiesta e headers.

### Headers

Gli header vengono utilizzati per comunicare metainformazioni (informazioni che
non riguardano il payload di dati) dal client al server.  
L'unico header obbligatorio (e solo in HTTP/1.1) è l'header `Host`, che permette
allo stesso server HTTP di servire diversi contenuti in base al dominio nello
header `Host`. Altri header degni di nota sono:

- `User-Agent`: comunica al server con che client (che browser ad esempio) si
    sta effettuando la richiesta.
- `Content-Length`: lunghezza del contenuto (in byte).
- `Accept`: il tipo di contenuto (*Content Type*) che il client vorrebbe
    ottenere in risposta alla richiesta.
- `Accept-Charset`: il set di caratteri (ad esempio UTF-8) che il client è
    in grado di a ricevere.

Molti altri header sono standardizzati nella RFC 2616 (nella [sezione
14][rfc-http-headers]).

Da notare che HTTP non impone un limite al numero di header utilizzabili (anche
se molti web server impongono un limite effettivo alla grandezza
dell'intestazione, ad esempio Apache che [limita la grandezza a
8kb][apache-headers-limit]) né impone regolazioni su *quali* debbano essere gli
header. L'unica restrizione che HTTP impone è che gli headers definiti in RFC
2616 siano conformi alla RFC stessa.  
È comune la convenzione di prefissare gli header custom con una `X`, ad esempio
`X-Twitter-Username`.


##### Headers con Rack (lato server)

Con rack, quando gestiamo una richiesta HTTP, è possibile controllare
direttamente gli header ricevuti nella richiesta. Vediamo un esempio in cui
stampiamo tutti gli header ricevuti in una richiesta:

``` ruby
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
```

Facendo una richiesta GET a `localhost:8080` con HTTPie, verrà ritornato in
risposta il plaintext contenente gli header della richiesta effettuata:

```
Host: localhost:8080
Accept-Encoding: gzip, deflate
Accept: */*
User-Agent: HTTPie/0.8.0
Version: HTTP/1.1
```

##### Headers con HTTPie (lato client)

Possiamo controllare gli header da inviare con la richiesta HTTP tramite HTTPie
semplicemente passando ad HTTPie argomenti della forma `HEADER:VALUE`. Con il
comando che segue possiamo aggiungere l'header `Test-Header` e modificare
l'header `User-Agent`.

    http GET localhost:8080 'Test-Header:my test value' 'User-Agent:fake!'

Confermiamo la modifica degli header ispezionando il plaintext ritornato in
risposta dall'handler rack scritto poco fa:

```
Host: localhost:8080
User-Agent: fake!
Accept-Encoding: gzip, deflate
Accept: */*
Test-Header: my test value
Version: HTTP/1.1
```

### Metodo di richiesta

HTTP definisce dei metodi (spesso chiamati anche *verbi*) che indicano l'azione
da compiere su una determinata risorsa (identificata dal path della richiesta).

I metodi definiti nello standard HTTP/1.0 erano solo tre:

- GET
- POST
- HEAD

HTTP/1.1 aggiunge altri cinque metodi:

- PUT
- DELETE
- TRACE
- OPTIONS
- CONNECT


##### GET
Chiede di ottenere qualsiasi informazione (sotto forma di entità sia
identificata dallo Request-URI.

La semantica della richiesta GET cambia se il messaggio di richiesta include
anche alcuni header particolari come ad esempio `If-Modified-Since`: in questo
caso la GET diventa una *GET condizionale*, che chiede al server di ottenere la
risorsa solo sotto determinate condizioni (utilizzato ad esempio per caching,
dove la condizione è che la risorsa sia stata modificata dall'ultima volta che
si è richiesta).

Le richieste inviate dal browser quando si visita un sito web a un certo URL
sono sempre richieste di tipo GET.

##### HEAD
Il metodo HEAD è identico al metodo GET ma il server non deve ritornare un
*body* con la risposta. Gli header in risposta devono essere esattamente gli
stessi di quelli che sarebbero stati inviati in risposta a una GET.

Spesso questo metodo viene usato per ottenere metainformazioni sull'entità
identificata dall'URI senza trasferire il corpo della risposta (più veloce) o
per testare la validità e l'accessibilità di link.

##### POST
Una richiesta POST ha (in genere) associato un body contenente informazioni.
Questo metodo serve a creare una risorsa sul server o sostituire quella
identificata dall'URI se già presente.  
Questo metodo viene in genere associato alla *action* dei form HTML.

##### PUT
Il metodo PUT è simile al metodo POST. Differisce da esso in quanto con una
richiesta PUT (il cui body contiene dati) si chiede al server di creare una
risorsa (se questa operazione è possibile) o aggiornare una risorsa già
esistente.

##### DELETE
Il metodo DELETE serve a chiedere al server di eliminare la risorsa identificata
dal Request-URI.

##### TRACE
Quando riceve una richiesta TRACE, il server HTTP dovrebbe inviare
in risposta esattamente la richiesta che esso ha ricevuto dal client. La
richiesta ricevuta dovrebbe essere inserita nel body della risposta che si invia
al client.  
Questo metodo è utile al client in quanto gli permette di vedere esattamente
cosa viene inviato al server.

##### OPTIONS
Il metodo OPTIONS è utilizzato per chiedere al server quali metodi HTTP sono
disponibili per un dato Request-URI. Il server deve includere una lista di
metodi HTTP disponibili nel body della risposta.  
Da notare che se l'URI è `*`, la richiesta è intesa come una generica richiesta
di conoscere quali metodi il server supporta (non per uno specifico URI, ma in
generale).

##### CONNECT
Il metodo CONNECT non è esattamente specificato insieme agli altri metodi (nella
sezione 9 della RFC 2616): lo standard HTTP/1.1 si riserva di usare il nome di
metodo CONNECT per funzionalità di proxy e tunneling (viene principalmente usato
per SSL).


#### Un ulteriore metodo: PATCH

Nel marzo 2010 è stato proposto un nuovo metodo HTTP ([RFC
5789][rfc-patch-method]): il metodo PATCH.

La giustificazione per l'introduzione di questo metodo che si può leggere nelle
prime righe della RFC 5789 è che molte applicazioni web vogliono modificare
*parti* di risorse piuttosto che aggiornare intere risorse.  
Per questo scopo si è sempre usato il metodo PUT, ma (come descritto
precedentemente) lo standard impone che una richiesta PUT sia utilizzata per
creare o aggiornare una risorsa nella sua interezza.

Lo standard non è ancora stato approvato (e dunque PATCH non è un metodo
ufficiale di HTTP/1.1) ma molti web framework (come ad esempio [Ruby on
Rails][rails]) già supportano il metodo PATCH da diversi anni.

#### Metodi *safe* e *idempotent*

HTTP definisce anche due proprietà che questi alcuni di questi metodi devono
avere: alcuni di questi metodi devono essere *safe* e/o *idempotent*.

I metodi GET e HEAD devono essere *safe*, ovvero non possono modificare le
risorse che identificano. Questo assicura al client la possibilità di eseguire
richieste GET e HEAD senza preoccuparsi delle conseguenze. Si noti che solo le
entità rappresentate dagli URL non devono essere modificate: una GET può ad
esempio registrare la visita dell'utente su un database.

I metodi *idempotent* sono metodi tali che gli effetti collaterali di N > 0
richieste **identiche** siano gli stessi di quelli per una singola richiesta. I
metodi GET, HEAD, PUT e DELETE devono soddisfare questa proprietà.

#### Customizzazione dei metodi di richiesta

I metodi di richiesta HTTP non sono pochi e coprono bene la maggior parte di
quelle che sono le funzionalità di cui si ha bisogno.

Tuttavia, con la nascita e crescita delle [API web][web-api] e di servizi web
sempre più complessi che sfruttano richieste e risposte HTTP per manipolare
dati, alcuni si sono chiesti se fosse possibile implementare dei metodi di
richiesta HTTP **custom**.

Vediamo un breve use case pratico: supponiamo di avere un sito web che rende
disponibili una serie di documenti importanti (come RFC ad esempio). Un'azione
che la API di questo sito vuole mettere a disposizione degli utenti è
la funzionalità di cancellare un documento sul sito. Essendo i documenti di
estrema importanza, ci si vuole assicurare che essi non vengano distrutti con
leggerezza. Per fare questo si implementa il metodo DELETE (su una risorsa documento
identificata ad esempio dall'URI `/documents/1`, dove `1` è l'id del documento)
in modo da non distruggere i documenti, ma solo da "nasconderli" e archiviarli.  
Per mettere a disposizione un metodo che distrugga effettivamente un documento
si potrebbe pensare di utilizzare un metodo custom: DELETEFOREVER.  
In questo modo si potrebbero effettuare richieste del tipo:

    DELETEFOREVER /documents/1 HTTP/1.1


###### Opinioni

Alcuni sono in favore dell'implementazione di metodi custom; la maggior parte
delle risorse trovate in rete, tuttavia, sono contrarie alla pratica.

È interessante [questa][stackexchange-custom-methods] domanda sul sito di Q&A
[programmers.stackexchange.com][programmers-stackexchange]. In essa l'utente che
pone la domanda chiede se ci sono problemi nell'utilizzare metodi di richiesta
HTTP custom: la maggior parte delle risposte sono contrarie a questa pratica.  
Un utente commenta:

> Nothing wrong, as long as you realize that you're now using a custom protocol and not HTTP.

Riguardo questo aspetto, l'utente si sbaglia. Citando la RFC 2616 alla lettera:

> The set of common methods for HTTP/1.1 is defined below. Although this set can
be expanded, additional methods cannot be assumed to share the same semantics
for separately extended clients and servers.

Lo standard HTTP impone solo che i metodi standardizzati (definiti sopra) si
comportino come specificato, ma non impone restrizioni su quali metodi rendere
disponibili.

Nonostante ciò, molte delle argomentazioni presenti nelle risposte alla domanda
sono molto valide: il problema principale è che, essendo i metodi custom non
standardizzati, non si hanno "regole" su come implementarli. Essi ad esempio non
possono essere compresi/debuggati a primo impatto da sviluppatori esterni a chi
li implementa.

###### Supporto

La maggior parte dei server web (Apache, Nginx) supportano metodi custom, così
come la maggior parte dei client (ad esempio è possibile effettuare richieste
cone metodi custom tramite Ajax in JavaScript).

###### WebDAV

[WebDAV][webdav] (Web Distributed Authoring and Versioning) è un set di
estensioni ad HTTP che permette a utenti di modificare documenti online in
collaborazione con altri utenti. WebDAV aggiunge diversi metodi di richiesta
custom (come COPY, MOVE, MKCOL) ad HTTP.

Anche WebDAV è soggetto alle stesse critiche esposte precedentemente; l'unico
pregio in più di questo "protocollo" è che è ben documentato e standardizzato.

###### Esempi pratici

Con HTTPie è possibile effettuare richieste con qualsiasi metodo tramite la
sintassi `http [REQUEST_METHOD] [URL]`. Ad esempio è possibile effettuare una
richiesta di tipo COPY a `example.com/doc/1` nel seguente modo:

    http COPY example.com/doc/1

Per completezza, vediamo come è possibile effettuare richieste con metodi custom
tramite curl:

    curl -X COPY example.com/doc/1

#### Caso di studio con Rack

Vediamo un piccolo caso di studio che ci aiuta a comprendere come potrebbe
essere possibile raffinare un'applicazione web migliorando il supporto al
protocollo HTTP.

Costruiremo un **middleware** Rack che ci permetterà di intercettare le
richieste di tipo TRACE per supportare questo metodo automaticamente. Un
middleware Rack è semplicemente un pezzo di software in grado di intercettare
richieste e modificarle o rispondervi preventivamente prima che la richiesta
arrivi al server vero e proprio.

``` ruby
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
```

Facendo dei test con HTTPie vediamo che tutto funziona a dovere. Mandando una
richiesta di tipo (ad esempio) GET, otteniamo in risposta il body predefinito:

    http GET localhost:8080

risponde con:

``` bash
Regular GET request
```

mentre effettuare una richiesta TRACE:

``` bash
# L'opzione '-p HBhb' mostra sulla console sia gli header che il body di
# richiesta e risposta.
http TRACE localhost:8080 -p HBhb
```

risponde come previsto con la richiesta effettuata:

```
TRACE / HTTP/1.1
Host: localhost:8080
Accept-Encoding: gzip, deflate
Accept: */*
User-Agent: HTTPie/0.8.0
Version: HTTP/1.1
```




[rfc-http-1.0]: http://www.isi.edu/in-notes/rfc1945.txt
[rfc-http-1.1]: http://www.ietf.org/rfc/rfc2616.txt
[rfc-http-headers]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
[rfc-patch-method]: http://tools.ietf.org/html/rfc5789
[wget]: https://www.gnu.org/software/wget/
[curl]: http://curl.haxx.se/
[httpie]: https://github.com/jakubroztocil/httpie
[http-2.0-wikipedia]: http://en.wikipedia.org/wiki/HTTP_2.0
[http-2.0-website]: http://http2.github.io/
[rack]: http://rack.github.io/
[webrick]: http://ruby-doc.org/stdlib-2.1.2/libdoc/webrick/rdoc/WEBrick.html
[thin]: http://code.macournoyer.com/thin/
[puma]: http://puma.io/
[sinatra]: http://www.sinatrarb.com/
[pip]: http://pip.readthedocs.org/en/latest/
[rails]: http://rubyonrails.org/
[web-api]: http://en.wikipedia.org/wiki/Web_API
[webdav]: http://www.webdav.org/
[programmers-stackexchange]: http://programmers.stackexchange.com/
[apache-headers-limit]: http://httpd.apache.org/docs/2.2/mod/core.html#limitrequestfieldsize
[stackexchange-custom-methods]: http://programmers.stackexchange.com/questions/193821/are-there-any-problems-with-implementing-custom-http-methods
[http-1.0-isnt-dead]: http://erlang.2086793.n4.nabble.com/Any-HTTP-1-0-clients-out-there-td2116037.html
