mcollective-varnish-agent
=========================

Description 

I was tired of having to write scripts and web interfaces that just do not 
scale to purging tens or hundreds varnish servers. 

So I had decided to use the publisher, subscriber aproach, and found that
one mcollective varnish agent plugin would be THE WAY to do it. 

I had searched for a mcollective varnish agent, without success, 
so I had decided to write mine, this is free software, is in active development, 
not ready yet for production use. 

If you like the idea or have the same need, please join efforts, fork and send a pull
request.

I hope that in near future this mcollective varnish agent will support: 

1 - Varnish url purging, using regex or full url. 

2 - Varnish service start, stop, restart, reload vcl, status

3 - Display the varnish vcl of the servers. 

4 - Collect statistics from varnish servers thru varnishstat 


Example Usage: 

$mco varnish purgeurl http://domainname/url

/* use varnishadm ban req.http.host == 'domainname' && req.url == "url"   */ 

$mco varnish purgeregex "^/images/.*$"

/* use varnishadm ban.url "^/images/.*$" */ 


$mco varnish vcl reload 

/* Reload the varnish vcl from file without restarting varnish */


$mco varnish vcl show 

/* Runs varnishadm vcl.list to grab the active vcl, then run vcl.show active_vcl_name */ 

$mco varnish stats all 

/* Returns all the stats of varnishstat -j */ 

$mco varnish stats cache_hit

/* Parse varnishstat -j and get cache_hit */


