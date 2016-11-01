include "json_generate.vcl";

sub vcl_recv {
  error 800;
}

sub vcl_error {
  if (obj.status == 800) {

    if (req.url == "/") {

      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";

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
      return (deliver);

    } else {

      set obj.status = 200;
      set obj.response = "OK";
      set obj.http.Content-Type = "application/json";

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
      return (deliver);

    }
  }
}
