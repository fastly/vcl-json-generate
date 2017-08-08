include "json_generate.vcl";

sub vcl_recv {
  error 800;
}

sub vcl_log {
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
  log {"syslog 1BSTtz9G2bRixL6KzYQnGI Papertrail :: "} req.http.json_generate_json;
}

sub vcl_error {
  if (obj.status == 800) {

    if (req.url == "/") {

      call json_generate_reset;
      set req.http.json_generate_beautify = "1";
      call json_generate_begin_object;
      set req.http.value = "Hello world";
      call json_generate_string;
      set req.http.value = "/hello-world";
      call json_generate_string;
      set req.http.value = "Hello world pretty";
      call json_generate_string;
      set req.http.value = "/hello-world-pretty";
      call json_generate_string;
      set req.http.value = "Data types";
      call json_generate_string;
      set req.http.value = "/data-types";
      call json_generate_string;
      set req.http.value = "Kitchen sink";
      call json_generate_string;
      set req.http.value = "/kitchen-sink";
      call json_generate_string;
      set req.http.value = "GeoIP";
      call json_generate_string;
      set req.http.value = "/geoip";
      call json_generate_string;
      set req.http.value = "Objects";
      call json_generate_string;
      set req.http.value = "/objects";
      call json_generate_string;
      call json_generate_end_object;
      set req.http.json_generate_json = regsuball(req.http.json_generate_json, {""/(.+?)""}, {"<a href="/\1">"/\1"</a>"});
      synthetic "<pre>" + req.http.json_generate_json + "</pre>";
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "text/html";
      return (deliver);

    } else if (req.url == "/hello-world") {

      call json_generate_reset;
      call json_generate_begin_object;
      set req.http.value = "Hello";
      call json_generate_string;
      set req.http.value = "world";
      call json_generate_string;
      call json_generate_end_object;
      synthetic req.http.json_generate_json;
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";
      return (deliver);

    } else if (req.url == "/hello-world-pretty") {

      call json_generate_reset;
      set req.http.json_generate_beautify = "1";
      call json_generate_begin_object;
      set req.http.value = "Hello";
      call json_generate_string;
      set req.http.value = "world";
      call json_generate_string;
      call json_generate_end_object;
      synthetic req.http.json_generate_json;
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";
      return (deliver);

    } else if (req.url == "/data-types") {

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

      synthetic req.http.json_generate_json;
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";
      return (deliver);

    } else if (req.url == "/geoip") {

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

      synthetic req.http.json_generate_json;
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";
      return (deliver);

    } else if (req.url == "/kitchen-sink") {

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

      set req.http.value = "string with quotation mark";
      call json_generate_string;
      set req.http.value = {"It's "The quick brown fox", he said."};
      call json_generate_string;

      set req.http.value = "string with solidus";
      call json_generate_string;
      set req.http.value = "cat /etc/passwd";
      call json_generate_string;

      set req.http.value = "string with reverse solidus";
      call json_generate_string;
      set req.http.value = "escape\me";
      call json_generate_string;

      set req.http.value = "string with %08 backspace";
      call json_generate_string;
      set req.http.value = "cat%08%08%08dog";
      call json_generate_string;

      set req.http.value = "string with %0C form feed";
      call json_generate_string;
      set req.http.value = "form%0Cfeed";
      call json_generate_string;

      set req.http.value = "string with %0A line feed";
      call json_generate_string;
      set req.http.value = "line%0Afeed";
      call json_generate_string;

      set req.http.value = "string with %0D carriage return";
      call json_generate_string;
      set req.http.value = "carriage%0Dreturn";
      call json_generate_string;

      set req.http.value = "string with %09 tab";
      call json_generate_string;
      set req.http.value = "tab%09tab%09tab";
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

      synthetic req.http.json_generate_json;
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";
      return (deliver);

    } else if (req.url == "/objects") {

      call json_generate_reset;
      set req.http.json_generate_beautify = "1";
      call json_generate_begin_object;

      set req.http.value = "integer";
      call json_generate_string;
      set req.http.value = "42";
      call json_generate_number;

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

      call json_generate_end_array;

      call json_generate_end_object;

      set req.http.value = "map2";
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

      call json_generate_end_array;

      call json_generate_end_object;

      call json_generate_end_object;

      synthetic req.http.json_generate_json;
      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";
      return (deliver);
    }
  }
}
