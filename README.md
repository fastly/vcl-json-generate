# vcl-json-generate

## Description

`vcl-json-generate` is a module that allows you to generate JSON dynamically on
Fastly cache nodes using VCL.

[JSON](http://www.json.org/) is a popular common interchange format for web
services. While it is possible to create strings which are JSON-like in VCL,
generating valid JSON while escaping appropriately is quite tricky.

The module has a small event-driven API much like SAX (Simple API for XML) and
is heavily influenced by [YAJL](http://lloyd.github.io/yajl/). As VCL currently
does not support data structures, it is a little verbose.

The module consists of a library, [json_generate.vcl](files/json_generate.vcl)
which you can include in your Fastly service.

## Synopsis

To use this module you should upload
[json_generate.vcl](files/json_generate.vcl) as custome VCL into your Fastly
service as `json_generate.vcl`. In your main VCL you should include it as:

```vcl
include "json_generate.vcl";
```

You can follow the examples at https://vcl-json-generate.global.ssl.fastly.net/

## Hello world

The most common JSON data type is the object, a collection of name value pairs:

```vcl
call json_generate_reset;
call json_generate_begin_object;
set req.http.value = "Hello";
call json_generate_string;
set req.http.value = "world";
call json_generate_string;
call json_generate_end_object;
```

`req.http.json_generate_json` contains:

```json
{"Hello":"world"}
```

## Beauty

JSON can occasionally be quite hard for humans to scan. Setting
`req.http.json_generate_beautify` adds whitespace and newlines to make it
clearer. You should only enable this during debugging.

```vcl
call json_generate_reset;
set req.http.json_generate_beautify = "1";
call json_generate_begin_object;
set req.http.value = "Hello";
call json_generate_string;
set req.http.value = "world";
call json_generate_string;
call json_generate_end_object;
```

`req.http.json_generate_json` contains:

```json
{
 "Hello": "world"
}
```

## Data types

This example demonstrates numbers, strings, null, booleans and arrays:

```vcl
call json_generate_reset;
set req.http.json_generate_beautify = "1";
call json_generate_begin_object;

set req.http.value = "integer";
call json_generate_string;
set req.http.value = "42";
call json_generate_number;

set req.http.value = "pi";
call json_generate_string;
set req.http.value = "3.141592653589793238462643383279";
call json_generate_number;

set req.http.value = "exponent";
call json_generate_string;
set req.http.value = "1E400";
call json_generate_number;

set req.http.value = "string";
call json_generate_string;
set req.http.value = "The quick brown fox";
call json_generate_string;

set req.http.value = "null";
call json_generate_string;
call json_generate_null;

set req.http.value = "true";
call json_generate_string;
set req.http.value = "1";
call json_generate_bool;

set req.http.value = "false";
call json_generate_string;
set req.http.value = "0";
call json_generate_bool;

set req.http.value = "map";
call json_generate_string;
call json_generate_begin_object;

set req.http.value = "key";
call json_generate_string;
set req.http.value = "value";
call json_generate_string;

set req.http.value = "array";
call json_generate_string;
call json_generate_begin_array;

set req.http.value = "1";
call json_generate_number;
set req.http.value = "2";
call json_generate_number;
set req.http.value = "3";
call json_generate_number;

call json_generate_end_array;

call json_generate_end_object;

call json_generate_end_object;
return (deliver);
```

`req.http.json_generate_json` contains:

```json
{
 "integer": 42,
 "pi": 3.141592653589793238462643383279,
 "exponent": 1E400,
 "string": "The quick brown fox",
 "null": null,
 "true": true,
 "false": false,
 "map": {
  "key": "value",
  "array": [
   1,
   2,
   3
  ]
 }
}
```

## GeoIP

This example returns JSON which contains GeoIP information:

```vcl
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

`req.http.json_generate_json` contains something like:

```json
{
 "timestamp": "Tue, 01 Nov 2016 13:28:02 GMT",
 "latitude": 51.533,
 "longitude": -0.100,
 "city": "Islington",
 "country": "United Kingdom"
}
```

## Logging

Another great use is logging JSON objects. If you use [version 2 log format](https://docs.fastly.com/guides/streaming-logs/custom-log-formats) then the following VCL:

```vcl
  call json_generate_reset;
  call json_generate_begin_object;

  set req.http.value = "client.ip";
  call json_generate_string;
  set req.http.value = client.ip;
  call json_generate_string;

  set req.http.value = "req.request";
  call json_generate_string;
  set req.http.value = req.request;
  call json_generate_string;

  set req.http.value = "req.http.host";
  call json_generate_string;
  set req.http.value = req.http.host;
  call json_generate_string;

  set req.http.value = "req.request";
  call json_generate_string;
  set req.http.value = req.request;
  call json_generate_string;

  set req.http.value = "req.url";
  call json_generate_string;
  set req.http.value = req.url;
  call json_generate_string;

  set req.http.value = "req.bytes_read";
  call json_generate_string;
  set req.http.value = req.bytes_read;
  call json_generate_number;

  set req.http.value = "resp.status";
  call json_generate_string;
  set req.http.value = resp.status;
  call json_generate_number;

  set req.http.value = "resp.bytes_written";
  call json_generate_string;
  set req.http.value = resp.bytes_written;
  call json_generate_number;

  set req.http.value = "resp.http.X-Cache";
  call json_generate_string;
  set req.http.value = resp.http.X-Cache;
  call json_generate_string;

  set req.http.value = "fastly_info.state";
  call json_generate_string;
  set req.http.value = fastly_info.state;
  call json_generate_string;

  set req.http.value = "time.start.usec";
  call json_generate_string;
  set req.http.value = time.start.usec;
  call json_generate_number;

  set req.http.value = "time.start.iso8601";
  call json_generate_string;
  set req.http.value = strftime("%25F %25T", time.start);
  call json_generate_string;

  set req.http.value = "time.end.usec";
  call json_generate_string;
  set req.http.value = time.end.usec;
  call json_generate_number;

  set req.http.value = "time.elapsed.usec";
  call json_generate_string;
  set req.http.value = time.elapsed.usec;
  call json_generate_number;

  call json_generate_end_object;
  log {"syslog YOURLOGGINGENDPOINT NAME :: "} req.http.json_generate_json;
```

... will log the following to your logging endpoint:

```json
{"client.ip":"5.148.300.300","req.request":"GET","req.http.host":"vcl-json-generate.global.ssl.fastly.net","req.request":"GET","req.url":"\/hello-world-pretty","req.bytes_read":524,"resp.status":200,"resp.bytes_written":285,"resp.http.X-Cache":"HIT","fastly_info.state":"HIT-SYNTH","time.start.usec":1488810945469257,"time.start.iso8601":"2017-03-06 14:35:45","time.end.usec":1488810945469498,"time.elapsed.usec":240}
```

If we pretty print the above, it is:

```json
{
  "client.ip": "5.148.300.300",
  "req.request": "GET",
  "req.http.host": "vcl-json-generate.global.ssl.fastly.net",
  "req.request": "GET",
  "req.url": "\/hello-world-pretty",
  "req.bytes_read": 524,
  "resp.status": 200,
  "resp.bytes_written": 285,
  "resp.http.X-Cache": "HIT",
  "fastly_info.state": "HIT-SYNTH",
  "time.start.usec": 1488810945469257,
  "time.start.iso8601": "2017-03-06 14:35:45",
  "time.end.usec": 1488810945469498,
  "time.elapsed.usec": 240
}
```

You should be able to pipe these JSON logs into Splunk, Logstash,
BigQuery etc.

## Terraform

This directory includes a Terraform example.

## Contributing?

Send a pull request.

## Future

Is this useful? Let me know! Léon Brocard <<lbrocard@fastly.com>>
