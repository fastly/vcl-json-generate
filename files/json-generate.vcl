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
    call map_open;
    call map_close;
    call array_open;
    call array_close;
  }
}

#/* check that we're not complete, or in error state.  in a valid state
# * to be generating */
##define ENSURE_VALID_STATE \
#    if (g->state[g->depth] == yajl_gen_error) {   \
#        return yajl_gen_in_error_state;\
#    } else if (g->state[g->depth] == yajl_gen_complete) {   \
#        return yajl_gen_generation_complete;                \
#    }

sub ensure_valid_state {
  if (req.http.yajl_state == "error") {
    #error 999 "ensure_valid_state: error";
  } else if (req.http.yajl_state == "complete") {
    #error 999 "ensure_valid_state: complete";
  }
}

##define INCREMENT_DEPTH \
#    if (++(g->depth) >= YAJL_MAX_DEPTH) return yajl_max_depth_exceeded;

sub increment_depth {
  set req.http.yajl_beautify_spaces = req.http.yajl_beautify_spaces + "_";
  set req.http.yajl_states = req.http.yajl_state + "," + req.http.yajl_states;
  set req.http.yajl_state = req.http.yajl_new_state;
  unset req.http.yajl_new_state;
}

##define DECREMENT_DEPTH \
#  if (--(g->depth) >= YAJL_MAX_DEPTH) return yajl_gen_generation_complete;

sub decrement_depth {
  set req.http.yajl_beautify_spaces = regsub(req.http.yajl_beautify_spaces, "^_", "");
  if (req.http.yajl_states ~ "^([^,]+),") {
    set req.http.yajl_state = re.group.1;
    set req.http.yajl_states = regsub(req.http.yajl_states, "^([^,]+),", "");
  }
}

##define ENSURE_NOT_KEY \
#    if (g->state[g->depth] == yajl_gen_map_key ||       \
#        g->state[g->depth] == yajl_gen_map_start)  {    \
#        return yajl_gen_keys_must_be_strings;           \
#    }
sub ensure_not_key {
  if (req.http.yajl_state == "map_key" || req.http.yajl_state == "map_start" ) {
    #error 999 "ensure_not_key: keys must be strings";
  }
}

##define INSERT_SEP \
#    if (g->state[g->depth] == yajl_gen_map_key ||               \
#        g->state[g->depth] == yajl_gen_in_array) {              \
#        g->print(g->ctx, ",", 1);                               \
#        if ((g->flags & yajl_gen_beautify)) g->print(g->ctx, "\n", 1);               \
#    } else if (g->state[g->depth] == yajl_gen_map_val) {        \
#        g->print(g->ctx, ":", 1);                               \
#        if ((g->flags & yajl_gen_beautify)) g->print(g->ctx, " ", 1);                \
#   }
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

##define INSERT_WHITESPACE                                               \
#    if ((g->flags & yajl_gen_beautify)) {                                                    \
#        if (g->state[g->depth] != yajl_gen_map_val) {                   \
#            unsigned int _i;                                            \
#            for (_i=0;_i<g->depth;_i++)                                 \
#                g->print(g->ctx,                                        \
#                         g->indentString,                               \
#                         (unsigned int)strlen(g->indentString));        \
#        }                                                               \
#    }
sub insert_whitespace {
  if (req.http.yajl_beautify) {
    if (req.http.yajl_state != "map_val") {
      set req.http.yajl = req.http.yajl + regsuball(req.http.yajl_beautify_spaces, "_", " ");
    }
  }
}

##define APPENDED_ATOM \
#    switch (g->state[g->depth]) {                   \
#        case yajl_gen_start:                        \
#            g->state[g->depth] = yajl_gen_complete; \
#            break;                                  \
#        case yajl_gen_map_start:                    \
#        case yajl_gen_map_key:                      \
#            g->state[g->depth] = yajl_gen_map_val;  \
#            break;                                  \
#        case yajl_gen_array_start:                  \
#            g->state[g->depth] = yajl_gen_in_array; \
#            break;                                  \
#        case yajl_gen_map_val:                      \
#            g->state[g->depth] = yajl_gen_map_key;  \
#            break;                                  \
#        default:                                    \
#            break;                                  \
#    }                                               \
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

##define FINAL_NEWLINE                                        \
#    if ((g->flags & yajl_gen_beautify) && g->state[g->depth] == yajl_gen_complete) \
#        g->print(g->ctx, "\n", 1);
sub final_newline {
    if (req.http.yajl_beautify && req.http.yajl_state == "complete") {
      set req.http.yajl = req.http.yajl + LF;
    }
}

#yajl_gen_status
#yajl_gen_integer(yajl_gen g, long long int number)
#{
#    char i[32];
#    ENSURE_VALID_STATE; ENSURE_NOT_KEY; INSERT_SEP; INSERT_WHITESPACE;
#    sprintf(i, "%lld", number);
#    g->print(g->ctx, i, (unsigned int)strlen(i));
#    APPENDED_ATOM;
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
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

#yajl_gen_status
#yajl_gen_null(yajl_gen g)
#{
#    ENSURE_VALID_STATE; ENSURE_NOT_KEY; INSERT_SEP; INSERT_WHITESPACE;
#    g->print(g->ctx, "null", strlen("null"));
#    APPENDED_ATOM;
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
sub null {
  call ensure_valid_state;
  call ensure_not_key;
  call insert_sep;
  call insert_whitespace;
  set req.http.yajl = req.http.yajl + "null";
  call appended_atom;
  call final_newline;
}

#yajl_gen_status
#yajl_gen_bool(yajl_gen g, int boolean)
#{
#    const char * val = boolean ? "true" : "false";

#  ENSURE_VALID_STATE; ENSURE_NOT_KEY; INSERT_SEP; INSERT_WHITESPACE;
#    g->print(g->ctx, val, (unsigned int)strlen(val));
#    APPENDED_ATOM;
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
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

#yajl_gen_status
#yajl_gen_map_open(yajl_gen g)
#{
#    ENSURE_VALID_STATE; ENSURE_NOT_KEY; INSERT_SEP; INSERT_WHITESPACE;
#    INCREMENT_DEPTH;

#    g->state[g->depth] = yajl_gen_map_start;
#    g->print(g->ctx, "{", 1);
#    if ((g->flags & yajl_gen_beautify)) g->print(g->ctx, "\n", 1);
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
sub map_open {
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

#yajl_gen_status
#yajl_gen_map_close(yajl_gen g)
#{
#    ENSURE_VALID_STATE;
#    DECREMENT_DEPTH;

#    if ((g->flags & yajl_gen_beautify)) g->print(g->ctx, "\n", 1);
#    APPENDED_ATOM;
#    INSERT_WHITESPACE;
#    g->print(g->ctx, "}", 1);
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
sub map_close {
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

#yajl_gen_status
#yajl_gen_array_open(yajl_gen g)
#{
#    ENSURE_VALID_STATE; ENSURE_NOT_KEY; INSERT_SEP; INSERT_WHITESPACE;
#    INCREMENT_DEPTH;
#    g->state[g->depth] = yajl_gen_array_start;
#    g->print(g->ctx, "[", 1);
#    if ((g->flags & yajl_gen_beautify)) g->print(g->ctx, "\n", 1);
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
sub array_open {
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

#yajl_gen_status
#yajl_gen_array_close(yajl_gen g)
#{
#    ENSURE_VALID_STATE;
#    DECREMENT_DEPTH;
#    if ((g->flags & yajl_gen_beautify)) g->print(g->ctx, "\n", 1);
#    APPENDED_ATOM;
#    INSERT_WHITESPACE;
#    g->print(g->ctx, "]", 1);
#    FINAL_NEWLINE;
#    return yajl_gen_status_ok;
#}
sub array_close {
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
