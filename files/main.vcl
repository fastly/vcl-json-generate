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

    set req.http.value = "string with quotation mark";
    call string;
    set req.http.value = {"It's "The quick brown fox", he said."};
    call string;

    set req.http.value = "string with solidus";
    call string;
    set req.http.value = "cat /etc/passwd";
    call string;

    set req.http.value = "string with reverse solidus";
    call string;
    set req.http.value = "escape\me";
    call string;

    set req.http.value = "string with %08 backspace";
    call string;
    set req.http.value = "cat%08%08%08dog";
    call string;

    set req.http.value = "string with %0C form feed";
    call string;
    set req.http.value = "form%0Cfeed";
    call string;

    set req.http.value = "string with %0A line feed";
    call string;
    set req.http.value = "line%0Afeed";
    call string;

    set req.http.value = "string with %0D carriage return";
    call string;
    set req.http.value = "carriage%0Dreturn";
    call string;

    set req.http.value = "string with %09 tab";
    call string;
    set req.http.value = "tab%09tab%09tab";
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
