## Caching

La cache è una componente delle architetture software che salva copie di dati
richiesti in modo da evitare il ritrasferimento degli stessi dati in richieste
successive.

HTTP fornisce molti meccanismi di caching: ad esempio ETag, GET condizionali, o
`Cache-Control`.

Poiché il caching in HTTP è un argomento di fondamentale importanza (tanto da
essere descritto in un RFC dedicato - [RFC 7234][rfc-http-caching]) la
trattazione che segue è sintetica e concentrata solo sulla tecnica di caching
basata sull'utilizzo di ETag.

La maggior parte delle tecniche di caching HTTP si basa sull'utilizzo di GET
condizionali: una GET condizionale è una normale richiesta GET accompagnata da
specifici header (ad esempio `If-Modified-Since` o `If-None-Match`) che
consentono al server di decidere se rispondere alla richiesta come se fosse una
normale GET o se rispondere con una risposta senza body (con codice 304 Not
Modified) in quanto il client è già in possesso della risorsa richiesta.

### ETag

ETag (*entity tag*) fa parte del protocollo HTTP ed è definita nella [sezione
14.19][rfc-etag] della RFC 2616.

Una ETag è un identificatore univoco che un web server assegna a una **versione**
di una risorsa. Di conseguenza, se il contenuto di una risorsa cambia, cambierà
sicuramente anche il suo ETag. Questo meccanismo a "impronta digitale" permette
ai client che richiedono la risorsa al server di cachare la risorsa con la
certezza che si verrà a conoscenza del momento in cui la risorsa andrà a
cambiare.

Il metodo di generazione delle ETag non è parte della specifica HTTP. Nonostante
ciò la maggior parte delle implementazioni calcola la ETag di una risorsa come
funzione hash (resistente alle collisioni in modo da ridurre quasi a zero le
probabilità di risorse diverse con stesso ETag) del contenuto della risorsa.

Quando è in uso ETag, il server risponde alle richieste includendo un header di
risposta `ETag`:

``` http
ETag: "636efd9378ab49c"
```

Il client, alla ricezione della risposta, mette la risorsa richiesta in cache
insieme al suo ETag. Quando, in seguito, il client effettuerà richieste dello
stesso tipo allo stesso URL, aggiungerà l'header di richiesta `If-None-Match` il
cui valore sarà la ETag che ha memorizzato associata a quell'URL.

``` http
If-None-Match: "636efd9378ab49c"
```

A questo punto il server verificherà se il valore dell'header di richiesta
`If-None-Match` corrisponde alla ETag *corrente* della risorsa richiesta: in
caso affermativo, invierà una risposta 304 Not Modified al client, che possiede
già la risorsa in cache. Altrimenti il server risponderà alla richiesta in modo
convenzionale.

