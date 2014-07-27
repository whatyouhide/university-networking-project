## Risposte HTTP

Una risposta HTTP *well-formed* è composta da:

- Una **riga di stato** dalla forma `[HTTP_VERSION] [STATUS_CODE] [MESSAGE]`;
    analizzeremo a fondo gli *status codes* a breve.
- Header di risposta (dalla forma identica agli header di richiesta: uno per
    linea, separati da *carriage return* e *line feed*).
- Una riga vuota (con solo un *carriage return* seguito da un *line feed*),
    analogamente a una richiesta HTTP.
- Un body di risposta *opzionale* (che costituisce il contenuto che il server
    risponde al client, ad esempio un'immagine o una pagina web).


Vediamo un esempio di risposta HTTP inviata da un server Apache a un client che
ha inviato una GET (ad esempio all'indirizzo `/welcome.html`):

```
HTTP/1.1 200 OK
Server: Apache/1.3.3.7
Content-Type: text/html
Connection: close

<html><body>Welcome!</body></html>
```


Esaminiamo più a fondo header di risposta e *status codes*.

### Headers di risposta

Nella forma, gli headers di risposta sono identici a gli header di richiesta:
`[HEADER_NAME]: [HEADER_VALUE]`.

Vediamo alcuni degli header di risposta più noti:

- `Connection`: ha stessa semantica dello header di richiesta `Connection`, ovvero
    decide se la connessione sia permanente o se debba essere chiusa appena la
    risposta è stata inviata.
- `Content-Length`: lunghezza del body di risposta in bytes.
- `Content-Type`: rappresenta il *MIME type* del body della risposta. È
    utilizzato, ad esempio, per istruire il browser se interpretare un documento
    di testo come HTML o come plaintext.
- `Last-Modified`: l'ultima data di modifica per la risorsa richiesta. Questo
    header è spesso utilizzato per implementare delle cache (ad esempio da proxy
    server).
- `Server`: il nome del server che sta rispondendo alla richiesta. Non è
    obbligatorio che il nome del server sia effettivamente corrispondente al
    server che si sta utilizzando.

Molti altri headers sono standardizzati in RFC 7231, e sono utilizzati
frequentemente anche se la suddetta RFC è ancora un *proposed standard*.


### Status codes

Gli *status codes* sono codici di 3 cifre che vanno da 100 a 599 e servono a
comunicare al client lo stato della richiesta che esso ha effettuato.

Gli status codes sono accompagnati, nella riga di stato di una risposta HTTP,
da una breve descrizione testuale (ad esempio "ok" o "Not found"). Questa
descrizione è rivolta all'umano che legge la risposta HTTP, mentre lo status
code è rivolto alle macchine (agli *automata*, citando RFC 2616 sezione 6.1.1).

Gli status codes sono divisi in cinque gruppi in base alla prima cifra del
codice; a breve analizzeremo tutti i gruppi e i più usati codici che ne fanno
parte.

Gli status codes HTTP sono estensibili. Molti status code standardizzati non
sono definiti in RFC 2616 ma in RFC successive. Esaminiamo questo aspetto di
estensibilità prima di addentrarci negli status code veri e propri.

#### Estensione degli status code

RFC 2616 spiega come usare status code custom in modo conciso ma dettagliato.
Citiamo la sezione 6.1.1:

> HTTP status codes are extensible. HTTP applications are not required
to understand the meaning of all registered status codes, though such
understanding is obviously desirable. However, applications MUST
understand the class of any status code, as indicated by the first
digit, and treat any unrecognized response as being equivalent to the
`x00` status code of that class, with the exception that an
unrecognized response MUST NOT be cached.

È dunque possibile utilizzare status code custom a patto di rispettare la
categoria a quale appartengono (prima cifra) e a patto che il client non metta
in cache la risposta.

Un esempio *in the wild* (ovvero usato in pratica nella rete) di status code
custom è presente nella [API di Twitter][twitter-api] (nella
[sezione][twitter-api-error-codes] riguardante gli error codes).  
Il codice HTTP custom presente è `420 Enhance Your Calm`: il codice è ironico
(anche se utilizzato dalla API) e indica a un client che sta oltrepassando il
limite di richieste concesso al suo tipo di account. È diverso dal codice `429
Too Many Requests` in quando quest'ultimo è generico e si riferisce
all'impossibilità di gestire la quantità di richieste.

Anche WebDAV definisce alcuni status code custom (oltre a metodi di richiesta
HTTP custom).

Come i metodi di richiesta custom, tuttavia, molti si schierano contro la
customizzazione degli status codes: basti vedere le opinioni espresse nei
commenti [qui][stackoverflow-custom-codes].


#### Status codes in dettaglio

Vediamo in dettaglio le cinque categorie di codici e i codici che ne fanno
parte (i più utilizzati).

##### 1xx Informational
Indicano che la richiesta del client è stata ricevuta e che sta essendo
processata. Si noti che codici del tipo 1xx sono definiti solo in HTTP/1.1,
dunque un server che risponde con HTTP/1.0 non può rispondere con un codice di
questo tipo.

##### 2xx Success
Indicano al client che l'azione da esso richiesta è stata ricevuta, compresa,
accettata e processata con successo.

- **200 OK**: risposta standard di successo.
- **201 Created**: la richiesta è andata a buon fine e la nuova risorsa è stata
    creata (può essere usato in risposta a richieste PUT e POST).
- **202 Accepted**: la richiesta è stata accettata e iniziata a processare, ma il
    suo completamento non è ancora terminato.
- **204 No Content**: la richiesta è andata a buon fine ed è stata processata
    con successo, ma il server non inserisce nessun contenuto nel body della
    risposta (utilizzato spesso come conferma a una richiesta DELETE).

##### 3xx Redirection
Indicano al client che esso deve compiere ulteriori azioni per di completare
la richiesta; la maggior parte delle volte il client (browser ad esempio) è in
grado di seguire le azioni indicate automaticamente e in modo trasparente
all'utente. RFC 2616 specifica che lo user agent può compiere le azioni
successive indicate solo se i metodi nelle richieste usate per completarle sono
GET o HEAD, e che può effettuare al massimo cinque richieste per completare le
azioni (onde evitare loop infiniti).

- **301 Moved Permanently**: la risorsa si trova definitivamente a un altro URL,
    dunque la richiesta effettuata e tutte le successive dovranno essere inviate
    al nuovo URL.
- **302 Found**: il codice 302 è "controversiale" in quanto l'industria lo utilizza
    in modo diverso dalla specifica. Originariamente (in HTTP/1.0) 302, con
    messaggio "Moved Temporarily", indicava che era possibile ottenere la
    risorsa richiesta a un nuovo URL (ma non definitivamente come in 301). Molti
    browser tuttavia interpretarono 302 come quello che poi diventò 303 in
    HTTP/1.1, in cui venne aggiunto al proposito anche 307.
- **303 See other**: la risposta alla richiesta effettuata può essere ottenuta con
    una richiesta GET a un altro URI.
- **304 Not Modified**: indica che la risorsa richiesta non è stata modificata
    rispetto alla versione della risorsa specificata in header di richiesta come
    `If-Modified-Since`, e dunque non c'è bisogno di ritrasmettere la richiesta.
- **307 Temporary Redirect**: indica al client che la richiesta dovrebbe essere
    ripetuta in modo identico ma a un altro URL (al contrario di 303 che obbliga
    una GET a un altro URI), ma che le richieste successive dovrebbero essere
    fatte all'URL originale.

##### 4xx Client Error
Indicano che il client ha commesso un errore (come una richiesta malformata o un
URL non esistente). Il body di una risposta con codice 4xx può contenere una
spiegazione dettagliata dell'errore --- basti pensare alle note pagine 404 in cui
viene comunque inviato in risposta un documento HTML che spiega al client
l'errore avvenuto.

- **400 Bad Request**: indica che la richiesta è malformata (errore di sintassi).
- **401 Unauthorized**: indica che la risorsa è accessibili solo previa
    autenticazione, e che il client non è autorizzato.
- **403 Forbidden**: il server ha compreso la richiesta ma non è disposto a portarla
    a termine.
- **404 Not Found**: indica che il server non ha trovato nulla corrispondente
    all'URL della richiesta. Con 404 il server sceglie deliberatamente di non
    dare indicazioni al client sullo stato della risorsa (ad esempio rimossa
    definitivamente o mai esistita).
- **405 Not Allowed**: indica che il metodo di richiesta utilizzato non è supportato
    per l'URI richiesto.
- **406 Not Acceptable**: la risorsa all'URI richiesto non è in grado di generare
    contenuto con MIME type specificato dall'header di richiesta `Accept`.
- (immancabile) **418 I'm a teapot**: questo codice è stato definito come pesce
    d'Aprile nel 1998 nella [RFC 2324][rfc-htcpcp], che descrive la versione 1.0
    dello Hyper Text Coffee Pot Control Protocol.

##### 5xx Server Error
Indicano al client che il server non è stato in grado di completare con successo
una richiesta (apparentemente) valida.

- **500 Internal Server Error**: indica un generico errore lato server. In pratica è
    quello usato più comunemente in modo da non fornire informazioni sensibili
    sull'errore causato sul server al client.
- **503 Service Unavailable**: il servizio richiesto è temporaneamente non
    disponibile per guasti o manutenzione.
- **505 HTTP Version Not Supported**: indica che il server non supporta la versione
    di HTTP specificata nella riga di richiesta.

