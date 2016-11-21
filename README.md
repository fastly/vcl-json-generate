# vcl-json-generate

This is a VCL module that allows you to generate JSON dynamically on the
edge.

It has a small event-driven API much like SAX (Simple API for XML).

It is heavily influenced by [YAJL](http://lloyd.github.io/yajl/).

# Synopsis

```vcl
include "json_generate.vcl";
call json_generate_reset;
set req.http.json_generate_beautify = "1";

call json_generate_begin_object;

set req.http.value = "timestamp";
call json_generate_string;
set req.http.value = now;
call json_generate_string;

set req.http.value = "latitude";
call json_generate_string;
set req.http.value = geoip.latitude;
call json_generate_number;

set req.http.value = "longitude";
call json_generate_string;
set req.http.value = geoip.longitude;
call json_generate_number;

set req.http.value = "city";
call json_generate_string;
set req.http.value = geoip.city.utf8;
call json_generate_string;

set req.http.value = "country";
call json_generate_string;
set req.http.value = geoip.country_name.utf8;
call json_generate_string;

call json_generate_end_object;
```

Now `req.http.json_generate_json` contains something like:

```JSON
{
 "timestamp": "Tue, 01 Nov 2016 13:28:02 GMT",
 "latitude": 51.533,
 "longitude": -0.100,
 "city": "Islington",
 "country": "United Kingdom"
}
```

If you don't set `req.http.json_generate_beautify` then instead you get:

```JSON
{"timestamp":"Tue, 01 Nov 2016 13:28:02 GMT","latitude":51.533,"longitude":-0.100,"city":"Islington","country":"United Kingdom"}
```

You can see this for yourself as the service is currently running at:
http://terraform-fastly-yajl.astray.com.global.prod.fastly.net/

[json_generate.vcl](files/json_generate.vcl) contains the library while
[main.vcl](files/main.vcl) has full examples of how to call it.

In the above we also generate JSON logs, which look something like:

```
{"client.ip":"5.148.132.132","req.request":"GET","req.http.host":"terraform-fastly-yajl.astray.com","req.request":"GET","req.url":"\/secret\/page.html","req.bytes_read":192,"resp.status":200,"resp.bytes_written":881,"resp.http.X-Cache":"HIT","fastly_info.state":"HIT-SYNTH","time.start.usec":1479733291788643,"time.start.iso8601":"2016-11-21 13:01:31","time.end.usec":1479733291793328,"time.elapsed.usec":4684}
```

If we pretty print the above, it is:

```
{
  "client.ip": "5.148.132.132",
  "req.request": "GET",
  "req.http.host": "terraform-fastly-yajl.astray.com",
  "req.url": "/secret/page.html",
  "req.bytes_read": 192,
  "resp.status": 200,
  "resp.bytes_written": 881,
  "resp.http.X-Cache": "HIT",
  "fastly_info.state": "HIT-SYNTH",
  "time.start.usec": 1479733291788643,
  "time.start.iso8601": "2016-11-21 13:01:31",
  "time.end.usec": 1479733291793328,
  "time.elapsed.usec": 4684
}
```

You should be able to pipe these JSON logs into Splunk, Logstash,
BigQuery etc.

# Contributing?

Send a pull request.

# Future

Is this useful? Let me know! Léon Brocard <<lbrocard@fastly.com>>
