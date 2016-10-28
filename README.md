# vcl-json-generate

This is a VCL module that allows you to generate JSON dynamically on the
edge.

It has a small event-driven API much like SAX (Simple API for XML).

It is heavily influenced by [YAJL](http://lloyd.github.io/yajl/).

# Synopsis

```
include "json_generate.vcl";
call json_generate_reset;
set req.http.json_generate_beautify = "1";

call json_generate_begin_object;

set req.http.value = "integer";
call json_generate_string;
set req.http.value = "42";
call json_generate_number;

set req.http.value = "string";
call json_generate_string;
set req.http.value = "The quick brown fox";
call json_generate_string;

call json_generate_end_object;
```

Now `req.http.json_generate_json` contains:

```
{
  "integer": 42,
  "string": "The quick brown fox"
}
```

If you don't set `req.http.json_generate_beautify` then instead you get:
```
{"integer":42,"string":"The quick brown fox"}
```

# Contributing?

Send a pull request.

# Future

Is this useful? Let me know! Léon Brocard <<lbrocard@fastly.com>>
