# HTTP - richieste, risposte e customizzazione

#### Andrea Leopardi (<an.leopardi@gmail.com>)
###### Reti di Calcolatori (a.a. 2013/2014)


## Argomento analizzato
In questo documento si analizzeranno più a fondo le richieste e le risposte
HTTP, concentrandosi principalmente sui metodi di richiesta HTTP e i codici di
risposta HTTP. Verranno trattati meno approfonditamente anche gli header HTTP e,
alla fine del documento, verrà introdotto brevemente il caching in HTTP.


<<[sections/introduction.md]

<!-- BREAK -->
<<[sections/requests.md]

<!-- BREAK -->
<<[sections/responses.md]

<!-- BREAK -->
<<[sections/caching.md]

<<[sections/conclusion.md]

<!-- BREAK -->
<<[sections/rack-appendix.md]


[rfc-http-1.0]: http://tools.ietf.org/html/rfc1945
[rfc-http-1.1]: http://www.ietf.org/rfc/rfc2616.txt
[rfc-http-1.1-2014]: http://tools.ietf.org/html/rfc7231
[rfc-http-headers]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
[rfc-patch-method]: http://tools.ietf.org/html/rfc5789
[rfc-htcpcp]: http://tools.ietf.org/html/rfc2324
[rfc-deprecating-x-prefix]: http://tools.ietf.org/html/rfc6648
[rfc-http-caching]: http://tools.ietf.org/html/rfc7234
[rfc-etag]: http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.19
[rfc-7231-vs-rfc-2616]: http://tools.ietf.org/html/rfc7231#page-91
[iana-headers]: http://www.iana.org/assignments/message-headers/message-headers.xhtml
[wget]: https://www.gnu.org/software/wget/
[curl]: http://curl.haxx.se/
[httpie]: https://github.com/jakubroztocil/httpie
[http-2.0-wikipedia]: http://en.wikipedia.org/wiki/HTTP_2.0
[http-2.0-website]: http://http2.github.io/
[http-2.0-milestones]: http://en.wikipedia.org/wiki/HTTP_2.0#Development_Milestones
[rack]: http://rack.github.io/
[webrick]: http://ruby-doc.org/stdlib-2.1.2/libdoc/webrick/rdoc/WEBrick.html
[thin]: http://code.macournoyer.com/thin/
[sinatra]: http://www.sinatrarb.com/
[pip]: http://pip.readthedocs.org/en/latest/
[rails]: http://rubyonrails.org/
[web-api]: http://en.wikipedia.org/wiki/Web_API
[webdav]: http://www.webdav.org/
[twitter-api]: https://dev.twitter.com/
[twitter-api-error-codes]: https://dev.twitter.com/docs/error-codes-responses
[programmers-stackexchange]: http://programmers.stackexchange.com/
[rfc-2616-is-dead]: https://www.mnot.net/blog/2014/06/07/rfc2616_is_dead
[rack-env-specification]: http://rubydoc.info/github/rack/rack/master/file/SPEC
[x-headers-deprecated]: http://en.wikipedia.org/wiki/List_of_HTTP_header_fields
[stackoverflow-custom-codes]: http://stackoverflow.com/questions/7996569/can-we-create-custom-http-status-codes
[apache-headers-limit]: http://httpd.apache.org/docs/2.2/mod/core.html#limitrequestfieldsize
[stackexchange-custom-methods]: http://programmers.stackexchange.com/questions/193821/are-there-any-problems-with-implementing-custom-http-methods
[http-1.0-isnt-dead]: http://erlang.2086793.n4.nabble.com/Any-HTTP-1-0-clients-out-there-td2116037.html
