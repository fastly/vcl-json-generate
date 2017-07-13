# Name: json_generate
# Version: 0.2.0
# Description: Generate JSON
# License: MIT

sub json_generate_reset {
  set req.http.json_generate_json = "";
  unset req.http.value;
  unset req.http.json_generate_new_state;
  set req.http.json_generate_state = "start";
  set req.http.json_generate_states = "";
  unset req.http.json_generate_beautify;
  set req.http.json_generate_beautify_spaces = "";
  # Avoid "Unused function" error
  if (req.http.xyzzy == "xyzzy") {
    call json_generate_null;
    call json_generate_number;
    call json_generate_string;
    call json_generate_bool;
    call json_generate_begin_object;
    call json_generate_end_object;
    call json_generate_begin_array;
    call json_generate_end_array;
  }
}

sub json_generate_ensure_valid_state {
  if (req.http.json_generate_state == "error") {
    # error 999 "ensure_valid_state: error";
  } else if (req.http.json_generate_state == "complete") {
    # error 999 "ensure_valid_state: complete";
  }
}

sub json_generate_increment_depth {
  set req.http.json_generate_beautify_spaces = req.http.json_generate_beautify_spaces + "_";
  set req.http.json_generate_states = req.http.json_generate_state + "," + req.http.json_generate_states;
  set req.http.json_generate_state = req.http.json_generate_new_state;
  unset req.http.json_generate_new_state;
}

sub json_generate_decrement_depth {
  set req.http.json_generate_beautify_spaces = regsub(req.http.json_generate_beautify_spaces, "^_", "");
  if (req.http.json_generate_states ~ "^([^,]+),") {
    set req.http.json_generate_state = re.group.1;
    set req.http.json_generate_states = regsub(req.http.json_generate_states, "^([^,]+),", "");
  }
}

sub json_generate_ensure_not_key {
  if (req.http.json_generate_state == "map_key" || req.http.json_generate_state == "map_start" ) {
    set req.http.json_generate_state = "error";
    # error 999 "ensure_not_key: keys must be strings";
  }
}

sub json_generate_insert_sep {
  if (req.http.json_generate_state == "map_key" || req.http.json_generate_state == "in_array") {
    set req.http.json_generate_json = req.http.json_generate_json + ",";
    if (req.http.json_generate_beautify) {
      set req.http.json_generate_json = req.http.json_generate_json + LF;
    }
  } else if (req.http.json_generate_state == "map_val") {
    set req.http.json_generate_json = req.http.json_generate_json + ":";
    if (req.http.json_generate_beautify) {
      set req.http.json_generate_json = req.http.json_generate_json + " ";
    }
  }
}

sub json_generate_insert_whitespace {
  if (req.http.json_generate_beautify) {
    if (req.http.json_generate_state != "map_val") {
      set req.http.json_generate_json = req.http.json_generate_json + regsuball(req.http.json_generate_beautify_spaces, "_", " ");
    }
  }
}

sub json_generate_appended_atom {
  if (req.http.json_generate_state == "start") {
    set req.http.json_generate_state = "complete";
  } else if (req.http.json_generate_state == "map_start" || req.http.json_generate_state == "map_key") {
    set req.http.json_generate_state = "map_val";
  } else if (req.http.json_generate_state == "array_start") {
    set req.http.json_generate_state = "in_array";
  } else if (req.http.json_generate_state == "map_val") {
    set req.http.json_generate_state = "map_key";
  }
}

sub json_generate_final_newline {
    if (req.http.json_generate_beautify && req.http.json_generate_state == "complete") {
      set req.http.json_generate_json = req.http.json_generate_json + LF;
    }
}

sub json_generate_number {
  call json_generate_ensure_valid_state;
  call json_generate_ensure_not_key;
  call json_generate_insert_sep;
  call json_generate_insert_whitespace;
  set req.http.json_generate_json = req.http.json_generate_json + req.http.value;
  call json_generate_appended_atom;
  call json_generate_final_newline;
}

sub json_generate_string {
  call json_generate_ensure_valid_state;
  call json_generate_insert_sep;
  call json_generate_insert_whitespace;
  set req.http.value = regsuball(req.http.value, "%5C%5C", "%5C%5C%5C%5C");
  set req.http.value = regsuball(req.http.value, "%22", "%5C%5C%22");
  set req.http.value = regsuball(req.http.value, "%08", "%5C%5C%62");
  set req.http.value = regsuball(req.http.value, "%0C", "%5C%5C%66");
  set req.http.value = regsuball(req.http.value, "%0A", "%5C%5C%6E");
  set req.http.value = regsuball(req.http.value, "%0D", "%5C%5C%72");
  set req.http.value = regsuball(req.http.value, "%09", "%5C%5C%74");
  set req.http.json_generate_json = req.http.json_generate_json + {"""} + req.http.value + {"""};
  call json_generate_appended_atom;
  call json_generate_final_newline;
}

sub json_generate_null {
  call json_generate_ensure_valid_state;
  call json_generate_ensure_not_key;
  call json_generate_insert_sep;
  call json_generate_insert_whitespace;
  set req.http.json_generate_json = req.http.json_generate_json + "null";
  call json_generate_appended_atom;
  call json_generate_final_newline;
}

sub json_generate_bool {
  call json_generate_ensure_valid_state;
  call json_generate_ensure_not_key;
  call json_generate_insert_sep;
  call json_generate_insert_whitespace;
  if (std.atoi(req.http.value) == 1) {
    set req.http.json_generate_json = req.http.json_generate_json + "true";
  } else {
    set req.http.json_generate_json = req.http.json_generate_json + "false";
  }
  call json_generate_appended_atom;
  call json_generate_final_newline;
}

sub json_generate_begin_object {
  call json_generate_ensure_valid_state;
  call json_generate_ensure_not_key;
  call json_generate_insert_sep;
  call json_generate_insert_whitespace;
  set req.http.json_generate_new_state = "map_start";
  call json_generate_increment_depth;
  set req.http.json_generate_json = req.http.json_generate_json + "{";
  if (req.http.json_generate_beautify) {
    set req.http.json_generate_json = req.http.json_generate_json + LF;
  }
  call json_generate_final_newline;
}

sub json_generate_end_object {
  call json_generate_ensure_valid_state;
  call json_generate_decrement_depth;
  if (req.http.json_generate_beautify) {
    set req.http.json_generate_json = req.http.json_generate_json + LF;
  }
  call json_generate_appended_atom;
  call json_generate_insert_whitespace;
  set req.http.json_generate_json = req.http.json_generate_json + "}";
  call json_generate_final_newline;
}

sub json_generate_begin_array {
  call json_generate_ensure_valid_state;
  call json_generate_ensure_not_key;
  call json_generate_insert_sep;
  call json_generate_insert_whitespace;
  set req.http.json_generate_new_state = "array_start";
  call json_generate_increment_depth;
  set req.http.json_generate_json = req.http.json_generate_json + "[";
  if (req.http.json_generate_beautify) {
    set req.http.json_generate_json = req.http.json_generate_json + LF;
  }
  call json_generate_final_newline;
}

sub json_generate_end_array {
  call json_generate_ensure_valid_state;
  call json_generate_decrement_depth;
  if (req.http.json_generate_beautify) {
    set req.http.json_generate_json = req.http.json_generate_json + LF;
  }
  call json_generate_appended_atom;
  call json_generate_insert_whitespace;
  set req.http.json_generate_json = req.http.json_generate_json + "]";
  call json_generate_final_newline;
}
