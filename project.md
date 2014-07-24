# Custom HTTP request methods and response codes

##### Andrea Leopardi
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


### Tools utilizzati

Nel corso del documento, utilizzerò degli strumenti per mostrare il lato
"pratico" di HTTP. Utilizzerò principalmente un web framework per illustrare il
lato server di HTTP in modo conciso e funzionale, e un client HTTP da command
line per illustrare il lato client di HTTP.

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
richieste HTTP è sicuramente [*curl*]. *curl* ha una sintassi abbastanza
criptica (basti pensare all'opzione `-X`, che permette di specificare il metodo
di richiesta HTTP) e dunque utilizzeremo un tool equivalente chiamato
[HTTPie][httpie].

HTTPie è un programma scritto in Python che permette di effettuare richieste
HTTP con una sintassi "human-friendly": per questa ragione ogni volta che
verrà utilizzato HTTPie sarà subito chiaro cosa si sta facendo.


[json]: http://json.org/
[programmers-stackexchange]: http://programmers.stackexchange.com
[rfc-http-1.0]: http://www.isi.edu/in-notes/rfc1945.txt
[rfc-http-1.1]: http://www.ietf.org/rfc/rfc2616.txt
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
[stackexchange-problems-custom-methods]: http://programmers.stackexchange.com/questions/193821/are-there-any-problems-with-implementing-custom-http-methods
[http-1.0-isnt-dead]: http://erlang.2086793.n4.nabble.com/Any-HTTP-1-0-clients-out-there-td2116037.html
