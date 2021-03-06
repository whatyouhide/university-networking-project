## Richieste HTTP

Una richiesta HTTP è formata da un'intestazione e un corpo opzionale.

L'intestazione è formata da:

- una riga di richiesta formata in ordine da metodo di richiesta, path sul
    server (*Request-URI*) e versione di HTTP, separati da un singolo spazio
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

È chiara la funzionalità della versione di HTTP; il body non fa altro che
trasferire dati al server. Studiamo più a fondo la funzionalità di metodo di
richiesta e di headers di richiesta.

### Headers di richiesta

Gli header vengono utilizzati per comunicare metainformazioni (informazioni che
non riguardano il payload di dati) dal client al server.  
In HTTP/1.0 non ci sono header obbligatori, mentre in HTTP/1.1 l'unico header
obbligatorio è l'header `Host`, che permette allo stesso server HTTP di servire
diversi contenuti in base al dominio nell'header `Host`. Altri header degni di
nota sono:

- `User-Agent`: comunica al server con che client (che browser ad esempio) si
    sta effettuando la richiesta.
- `Content-Length`: lunghezza del contenuto (in byte).
- `Accept`: il tipo di contenuto (*Content Type*) che il client vorrebbe
    ottenere in risposta alla richiesta.
- `Accept-Charset`: il set di caratteri (ad esempio UTF-8) che il client è
    in grado di a ricevere.
- `If-Modified-Since`: è utilizzato dal client (spesso da proxy server in
    realtà) per richiedere una risorsa solo se non è stata modificata
    dall'ultima volta che si è richiesta. La funzione di questo e altri header
    simili è dunque volta all'implementazione di un sistema di caching.

Molti altri header sono standardizzati nella RFC 2616 (nella [sezione
14][rfc-http-headers]).

Da notare che HTTP non impone un limite al numero di header utilizzabili (anche
se molti web server impongono un limite effettivo alla grandezza
dell'intestazione. Ad esempio Apache [limita la
grandezza][apache-headers-limit] dell'intestazione HTTP (riga di richiesta più
header) a 8kb di default.  
HTTP, inoltre, non impone regolazioni su *quali* debbano essere gli header.
L'unica restrizione imposta è che gli headers definiti in RFC 2616 siano
conformi alla RFC stessa.

È comune la convenzione di prefissare gli header non standardizzati con una
`X-`, ad esempio `X-Twitter-Username`, anche se questa pratica è stata deprecata
nel giugno 2012 (come riporta [Wikipedia][x-headers-deprecated]) con la [RFC
6648][rfc-deprecating-x-prefix] in quanto creava problemi quando headers non
standard venivano standardizzati.

Una lista più che comprensiva di headers (sia standard che non, e che comprende
in realtà anche headers di risposta oltre che di richiesta) è mantenuta dalla
IANA ed è disponibile [qui][iana-headers].


##### Headers con Rack (lato server)

Con rack, quando si gestisce una richiesta HTTP, è possibile controllare
direttamente gli header ricevuti nella richiesta. Vediamo un esempio in cui
vengono stampati tutti gli header ricevuti in una richiesta:

<<(src/rack-request-headers.rb)

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
risposta dall'handler Rack scritto poco fa:

```
Host: localhost:8080
User-Agent: fake!
Accept-Encoding: gzip, deflate
Accept: */*
Test-Header: my test value
Version: HTTP/1.1
```

### Metodi di richiesta

HTTP definisce dei metodi (spesso chiamati anche *verbi*) che indicano l'azione
da compiere su una determinata risorsa (identificata dal path della richiesta).

I metodi definiti nello standard HTTP/1.0 sono solo tre:

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
Chiede di ottenere qualsiasi informazione (sotto forma di entità) sia
identificata dal Request-URI.

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
Questo metodo viene in genere associato alla `action` dei form HTML.

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

La maggior parte dei server web (Apache, nginx) supportano metodi custom, così
come la maggior parte dei client (ad esempio è possibile effettuare richieste
con metodi custom tramite Ajax in JavaScript).

Un problema che si pone frequentemente, tuttavia, è il seguente: i form HTML
(anche HTML5) supportano solo i metodi di richiesta GET e POST tramite
l'attributo `action`. Frequentemente, tuttavia, si vogliono usare dei tag
`<form>` per, ad esempio, modificare una risorsa sul server. Per questo si
vorrebbe usare una richiesta PUT.

[Ruby on Rails][rails] (come molti altri) usa un *workaround* per ovviare a
questo problema: usare un campo `<input>` con l'attributo `type="hidden"` (in
modo che non compaia nel DOM e non venga mostrato dal browser) che specifichi il
tipo di richiesta. Il client può, a questo punto, utilizzare qualsiasi metodo di
richiesta HTTP (anche custom) con form HTML.

Nella sezione contenente esempi pratici con Rack vedremo anche un esempio
riguardante questo argomento.

###### WebDAV

[WebDAV][webdav] (Web Distributed Authoring and Versioning) è un set di
estensioni ad HTTP che permette a utenti di modificare documenti online in
collaborazione con altri utenti. WebDAV aggiunge diversi metodi di richiesta
custom (come COPY e MOVE) ad HTTP.

Anche WebDAV è soggetto alle stesse critiche esposte precedentemente; l'unico
pregio in più di questo "protocollo" è che è ben documentato e standardizzato.

###### Esempi pratici

Con HTTPie è possibile effettuare richieste con qualsiasi metodo tramite la
sintassi `http [REQUEST_METHOD] [URL]`. Ad esempio è possibile effettuare una
richiesta di tipo COPY a `example.com/doc/1` nel seguente modo:

``` bash
http COPY example.com/doc/1
```

Per completezza, vediamo come è possibile effettuare richieste con metodi custom
tramite curl:

``` bash
curl -X COPY example.com/doc/1
```

Anche nel browser (ad esempio in Google Chrome) è possibile vedere le richieste
HTTP che il browser ha effettuato. In Google Chrome, c'è una sezione dei
DevTools (gli strumenti del browser dedicati agli sviluppatori) dedicata a
questo scopo:

![DevTools](images/dev-tools-requests.png)

#### Casi di studio con Rack

##### Supporto automatico a TRACE

Vediamo un piccolo caso di studio che ci aiuti a comprendere come potrebbe
essere possibile raffinare un'applicazione web migliorando il supporto al
protocollo HTTP.

Costruiremo un **middleware** Rack che ci permetterà di intercettare le
richieste di tipo TRACE per supportare questo metodo automaticamente. Un
middleware Rack è semplicemente un pezzo di software in grado di intercettare
richieste e modificarle o rispondervi preventivamente prima che la richiesta
arrivi al server vero e proprio.

<<(src/rack-trace-support.rb)

Facendo dei test con HTTPie vediamo che tutto funziona a dovere. Mandando una
richiesta di tipo (ad esempio) GET, otteniamo in risposta il body predefinito.

``` bash
http GET localhost:8080
```

``` bash
<body>Regular GET request</body>
```

Effettuando una richiesta TRACE, invece, il server risponde con un *mirror*
della richiesta effettuata:

``` bash
# L'opzione '-p HBhb' mostra sulla console sia gli header che il body di
# richiesta e risposta.
http TRACE localhost:8080 -p HBhb
```

```
TRACE / HTTP/1.1
Host: localhost:8080
Accept-Encoding: gzip, deflate
Accept: */*
User-Agent: HTTPie/0.8.0
Version: HTTP/1.1
```

##### Metodi di richiesta e form HTML

Come illustrato precedentemente, i form HTML possono inviare solo richieste GET
e POST. Vediamo un piccolo middleware Rack in grado di intercettare le richieste
dirette al server principale e trasformare richieste che nell'URL hanno un
parametro `__method` in richieste custom che come metodo hanno il metodo
descritto dall'attributo `__method`.

<<(src/rack-custom-http-methods.rb)

Il server invierà, in risposta alle richieste, un messaggio in cui comunica con
quale metodo è stata effettuata la richiesta.

Effettuando una semplice richiesta POST al server otteniamo il risultato
aspettato, ossia il server risponde comunicando che ha ricevuto una richiesta
POST.

``` bash
# La sintassi HTTPie name==value indica una coppia nome-valore da inviare nel
# body della richiesta.
http POST localhost:8080 foo==bar
```

Lato server:

```
<body>I received a POST request.</body>
```

Se vogliamo inviare, tramite un form, una richiesta di tipo CUSTOM_REQUEST,
possiamo semplicemente inviare il parametro `__method=CUSTOM_REQUEST`:

``` bash
http POST localhost:8080 foo==bar __method==CUSTOM_REQUEST
```

Il server risponderà correttamente mostrando che la richiesta da lui "percepita"
è effettivamente una richiesta di tipo CUSTOM_REQUEST:

```
<body>I received a CUSTOM_REQUEST request.</body>
```

