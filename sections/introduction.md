## Introduzione ad HTTP

HTTP (Hypertext Transfer Protocol) è un protocollo a livello di applicazione
che connette un *client* e un *host* permettendo loro di scambiare dati.
HTTP sfrutta TCP come protocollo a livello di trasporto: è dunque un protocollo
orientato alla connessione.

HTTP è utilizzato per una vasta serie di scopi: web, streaming video,
condivisione di file, connessioni a host remoti. Anche se l'acronimo HTTP si
riferisce ad *Hypertext* (ossia testo contenente hyperlink --- link logici ad
altri documenti di testo), HTTP permette a host e client di scambiare qualsiasi
tipo di dato.

Sul lato server, HTTP viene implementato da un *server HTTP*, ovvero un
programma in ascolto sulla porta 80 (tramite una socket) dell'host che
funge da server. Il lato client viene eseguito, la maggior parte delle volte, da
un browser web, ma può essere eseguito anche da applicazioni per smartphone,
tool da command line, elettrodomestici.

HTTP è un protocollo basato sullo scambio di messaggi; i messaggi HTTP possono
essere **richieste** o **risposte**.

Il client HTTP invia richieste HTTP al server, che risponde con risposte HTTP.
Le richieste che il client invia al server sono sempre inviate a un URI
(*Uniform Resource Identifier*) che coincide con la sezione di un URL
corrispondente al *path* e che identifica univocamente una risorsa; ad esempio
nell'URL `http://youtube.com/v/1`, l'URI è `/v/1`.


### Versioni di HTTP

La prima versione di HTTP ad essere standardizzata fu HTTP/1.0, specificata
nella [RFC 1945][rfc-http-1.0] del 1996.

Nel 1999, con la [RFC 2616][rfc-http-1.1], venne standardizzata la versione
successiva del protocollo HTTP, ovvero HTTP/1.1. Non ci furono cambiamenti
drastici dalla versione 1.0 alla versione 1.1: quelli interessanti verranno
segnalati nelle relative sezioni.

Nonostante HTTP/1.1 non sia molto più giovane di HTTP/1.0, esso è lo standard
utilizzato ancora oggi. HTTP/1.0 [non è "morto"][http-1.0-isnt-dead] tuttavia:
molti proxy lo utilizzano, e anche dei client come [wget][wget].

HTTP 2.0 (su [wikipedia][http-2.0-wikipedia] e [qui][http-2.0-website]) è la
prossima versione del protocollo HTTP: nonostante sia in fase di sviluppo, essa
non è ancora adottata per usi pratici. Nel [Novembre 2014][http-2.0-milestones]
è prevista la sottomissione dello standard HTTP 2.0 alla IESG perché essa
diventi un *Proposed Standard*.

Durante tutto il documento la versione di HTTP di riferimento (a meno che non
specificato diversamente) sarà HTTP/1.1.

Da notare che la semantica delle richieste e delle risposte HTTP/1.1 è stata
recentemente (giugno 2014) rivista e aggiornata nella [RFC 7231][rfc-http-1.1-2014].

Le RFC da 7230 a 7235 (che descrivono HTTP nelle sue diverse parti, come
richieste e risposte, autenticazione, caching) sono diventati lo standard *de
facto* di HTTP/1.1 ([esempio][rfc-2616-is-dead]).  
Spesso durante il documento ci si riferirà esplicitamente a RFC 2616 in quanto
le nuove RFC sono principalmente chiarimenti e precisazioni di quanto descritto
in RFC 2616. Come si può leggere nelle [appendici][rfc-7231-vs-rfc-2616] della
RFC 7231 (e delle altre con codice 7230-7235) non ci sono cambiamenti
sostanziali nella specifica di HTTP.

Il motivo per cui è stato necessario proporre un nuovo standard per HTTP/1.1 è
che lo standard originale definito in RFC 2616 risale al 1999, tempo in cui il
web serviva ad altri scopi rispetto a quelli per cui è utilizzato oggi: non
c'erano le web API (uno dei motori principali che ha fatto nascere la necessità
di un nuovo standard), Ajax o HTML5.


### Tools utilizzati

Nel corso del documento verranno utilizzati degli strumenti per mostrare il lato
"pratico" di HTTP. Si è scelto di utilizzare un tool per l'interfacciamento con
server per mostrare il lato server di HTTP in modo conciso e funzionale, e un
client HTTP da command line per illustrare il lato client di HTTP.

Gli esempi presenti nel documento sono volti a mostrare come sia possibile
interagire con HTTP nella pratica.

##### Tools lato server

Per il lato server di HTTP verrà utilizzato [Rack][rack]. Rack può essere
considerato un web server scritto in Ruby: in realtà esso è un'astrazione che
permette di scrivere codice lato server che poi può essere utilizzato con
diversi server (veri e propri) scritti in Ruby, come ad esempio
[WEBrick][webrick] (incluso nelle librerie standard di Ruby) o [Thin][thin].

Rack è molto semplice da utilizzare ma la sua sintassi può risultare
"misteriosa" a un primo sguardo; per questo motivo, alla fine del documento
(nella [appendice su Rack][appendice-rack]), sarà presente una breve
introduzione a Rack e alla sua sintassi.

##### Tools lato client

Il più famoso tool da command line (incluso di default in UNIX) utilizzato per
eseguire richieste HTTP è sicuramente [*curl*][curl]. *curl* ha una sintassi
abbastanza criptica (basti pensare all'opzione `-X`, che permette di specificare
il metodo di richiesta HTTP) e dunque utilizzeremo un tool equivalente chiamato
[HTTPie][httpie].

HTTPie è un programma scritto in Python che permette di effettuare richieste
HTTP con una sintassi "human-friendly"; la sua sintassi verrà illustrata nel
corso degli esempi. HTTPie può essere installato con [pip][pip] (`pip install
httpie`) e mette a disposizione il comando `http`.

Per illustrare un esempio di utilizzo di HTTPie, segue un esempio di richiesta
`GET` effettuata alla homepage di Google, filtrata in modo da mostrare solo gli
headers della risposta:

``` bash
http GET google.com --headers
```

