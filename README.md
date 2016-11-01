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
{"timestamp":"Tue, 01 Nov 2016 13:28:02 GMT","latitude": 51.533,"longitude":-0.100,"city":"Islington","country":"United Kingdom"}
```

You can see this for yourself as the service is currently running at:
http://terraform-fastly-yajl.astray.com.global.prod.fastly.net/

# Contributing?

Send a pull request.

# Future

Is this useful? Let me know! Léon Brocard <<lbrocard@fastly.com>>
