include "json-generate.vcl";

sub vcl_recv {
  error 800;
}

sub vcl_error {
  if (obj.status == 800) {
    set obj.status = 200;
    set obj.response = "OK";
    set obj.http.Content-Type = "text/html; charset=utf-8";

    call reset;
    set req.http.yajl_beautify = "1";
    call begin_object;

    set req.http.value = "integer";
    call string;
    set req.http.value = "42";
    call number;

    set req.http.value = "pi";
    call string;
    set req.http.value = "3.141592653589793238462643383279";
    call number;

    set req.http.value = "exponent";
    call string;
    set req.http.value = "1E400";
    call number;

    set req.http.value = "string";
    call string;
    set req.http.value = "The quick brown fox";
    call string;

    set req.http.value = "null";
    call string;
    call null;

    set req.http.value = "true";
    call string;
    set req.http.value = "1";
    call bool;

    set req.http.value = "false";
    call string;
    set req.http.value = "0";
    call bool;

    set req.http.value = "map";
    call string;
    call begin_object;

    set req.http.value = "key";
    call string;
    set req.http.value = "value";
    call string;

    set req.http.value = "array";
    call string;
    call begin_array;

    set req.http.value = "1";
    call number;
    set req.http.value = "2";
    call number;
    set req.http.value = "3";
    call number;

    call end_array;

    call end_object;

    call end_object;

    synthetic req.http.yajl;
    return (deliver);
  }
}
