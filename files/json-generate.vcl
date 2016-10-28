sub reset {
  set req.http.yajl = "";
  unset req.http.value;
  unset req.http.yajl_new_state;
  set req.http.yajl_state = "start";
  set req.http.yajl_states = "";
  set req.http.yajl_beautify = "0";
  set req.http.yajl_beautify_spaces = "";
  # Avoid "Unused function" error
  if (req.http.xyzzy == "xyzzy") {
    call null;
    call number;
    call string;
    call bool;
    call begin_object;
    call end_object;
    call begin_array;
    call end_array;
  }
}

sub ensure_valid_state {
  if (req.http.yajl_state == "error") {
    # error 999 "ensure_valid_state: error";
  } else if (req.http.yajl_state == "complete") {
    # error 999 "ensure_valid_state: complete";
  }
}

sub increment_depth {
  set req.http.yajl_beautify_spaces = req.http.yajl_beautify_spaces + "_";
  set req.http.yajl_states = req.http.yajl_state + "," + req.http.yajl_states;
  set req.http.yajl_state = req.http.yajl_new_state;
  unset req.http.yajl_new_state;
}

sub decrement_depth {
  set req.http.yajl_beautify_spaces = regsub(req.http.yajl_beautify_spaces, "^_", "");
  if (req.http.yajl_states ~ "^([^,]+),") {
    set req.http.yajl_state = re.group.1;
    set req.http.yajl_states = regsub(req.http.yajl_states, "^([^,]+),", "");
  }
}

sub ensure_not_key {
  if (req.http.yajl_state == "map_key" || req.http.yajl_state == "map_start" ) {
    set req.http.yajl_state = "error";
    # error 999 "ensure_not_key: keys must be strings";
  }
}

sub insert_sep {
  if (req.http.yajl_state == "map_key" || req.http.yajl_state == "in_array") {
    set req.http.yajl = req.http.yajl + ",";
    if (req.http.yajl_beautify) {
      set req.http.yajl = req.http.yajl + LF;
    }
  } else if (req.http.yajl_state == "map_val") {
    set req.http.yajl = req.http.yajl + ":";
    if (req.http.yajl_beautify) {
      set req.http.yajl = req.http.yajl + " ";
    }
  }
}

sub insert_whitespace {
  if (req.http.yajl_beautify) {
    if (req.http.yajl_state != "map_val") {
      set req.http.yajl = req.http.yajl + regsuball(req.http.yajl_beautify_spaces, "_", " ");
    }
  }
}

sub appended_atom {
  if (req.http.yajl_state == "start") {
    set req.http.yajl_state = "complete";
  } else if (req.http.yajl_state == "map_start" || req.http.yajl_state == "map_key") {
    set req.http.yajl_state = "map_val";
  } else if (req.http.yajl_state == "array_start") {
    set req.http.yajl_state = "in_array";
  } else if (req.http.yajl_state == "map_val") {
    set req.http.yajl_state = "map_key";
  }
}

sub final_newline {
    if (req.http.yajl_beautify && req.http.yajl_state == "complete") {
      set req.http.yajl = req.http.yajl + LF;
    }
}

sub number {
  call ensure_valid_state;
  call ensure_not_key;
  call insert_sep;
  call insert_whitespace;
  set req.http.yajl = req.http.yajl + req.http.value;
  call appended_atom;
  call final_newline;
}

#yajl_gen_status
#yajl_gen_string(yajl_gen g, const unsigned char * str,
#                size_t len)
#{
#    // if validation is enabled, check that the string is valid utf8
#    // XXX: This checking could be done a little faster, in the same pass as
#    // the string encoding
#    if (g->flags & yajl_gen_validate_utf8) {
#        if (!yajl_string_validate_utf8(str, len)) {
#            return yajl_gen_invalid_string;
#        }
#    }
#    ENSURE_VALID_STATE; INSERT_SEP; INSERT_WHITESPACE;
#    g->print(g->ctx, "\"", 1);
#    yajl_string_encode(g->print, g->ctx, str, len, g->flags & yajl_gen_escape_solidus);
#    g->print(g->ctx, "\"", 1);
#    APPENDED_ATOM;
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
sub string {
  call ensure_valid_state;
  call insert_sep;
  call insert_whitespace;
  set req.http.yajl = req.http.yajl + {"""} + req.http.value + {"""};
  call appended_atom;
  call final_newline;
}

sub null {
  call ensure_valid_state;
  call ensure_not_key;
  call insert_sep;
  call insert_whitespace;
  set req.http.yajl = req.http.yajl + "null";
  call appended_atom;
  call final_newline;
}

sub bool {
  call ensure_valid_state;
  call ensure_not_key;
  call insert_sep;
  call insert_whitespace;
  if (std.atoi(req.http.value) == 1) {
    set req.http.yajl = req.http.yajl + "true";
  } else {
    set req.http.yajl = req.http.yajl + "false";
  }
  call appended_atom;
  call final_newline;
}

sub begin_object {
  call ensure_valid_state;
  call ensure_not_key;
  call insert_sep;
  call insert_whitespace;
  set req.http.yajl_new_state = "map_start";
  call increment_depth;
  set req.http.yajl = req.http.yajl + "{";
  if (req.http.yajl_beautify) {
    set req.http.yajl = req.http.yajl + LF;
  }
  call final_newline;
}

sub end_object {
  call ensure_valid_state;
  call decrement_depth;
  if (req.http.yajl_beautify) {
    set req.http.yajl = req.http.yajl + LF;
  }
  call appended_atom;
  call insert_whitespace;
  set req.http.yajl = req.http.yajl + "}";
  call final_newline;
}

sub begin_array {
  call ensure_valid_state;
  call ensure_not_key;
  call insert_sep;
  call insert_whitespace;
  set req.http.yajl_new_state = "array_start";
  call increment_depth;
  set req.http.yajl = req.http.yajl + "[";
  if (req.http.yajl_beautify) {
    set req.http.yajl = req.http.yajl + LF;
  }
  call final_newline;
}

sub end_array {
  call ensure_valid_state;
  call decrement_depth;
  if (req.http.yajl_beautify) {
    set req.http.yajl = req.http.yajl + LF;
  }
  call appended_atom;
  call insert_whitespace;
  set req.http.yajl = req.http.yajl + "]";
  call final_newline;
}
