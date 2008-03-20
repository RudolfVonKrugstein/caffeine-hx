# 20 "lexer.mll"
 
open Lexing
open Ast

type error_msg =
	| Invalid_character of char
	| Unterminated_string
	| Unterminated_regexp
	| Unclosed_comment
	| Invalid_escape
	| Invalid_option

exception Error of error_msg * pos

let error_msg = function
	| Invalid_character c when int_of_char c > 32 && int_of_char c < 128 -> Printf.sprintf "Invalid character '%c'" c
	| Invalid_character c -> Printf.sprintf "Invalid character 0x%.2X" (int_of_char c)
	| Unterminated_string -> "Unterminated string"
	| Unterminated_regexp -> "Unterminated regular expression"
	| Unclosed_comment -> "Unclosed comment"
	| Invalid_escape -> "Invalid escape sequence"
	| Invalid_option -> "Invalid regular expression option"

let cur_file = ref ""
let cur_line = ref 1
let all_lines = Hashtbl.create 0
let lines = ref []
let buf = Buffer.create 100

let error e pos =
	raise (Error (e,{ pmin = pos; pmax = pos; pfile = !cur_file }))

let keywords =
	let h = Hashtbl.create 3 in
	List.iter (fun k -> Hashtbl.add h (s_keyword k) k)
		[Function;Class;Static;Var;If;Else;While;Do;For;
		Break;Return;Continue;Extends;Implements;Import;
		Switch;Case;Default;Public;Private;Try;Untyped;
		Catch;New;This;Throw;Extern;Enum;In;Interface;
		Cast;Override;F9Dynamic;Typedef;Package;Callback;Inline];
	h

let init file =
	cur_file := file;
	cur_line := 1;
	lines := []

let save_lines() =
	Hashtbl.replace all_lines !cur_file !lines

let save() =
	save_lines();
	!cur_file, !cur_line

let restore (file,line) =
	save_lines();
	cur_file := file;
	cur_line := line;
	lines := Hashtbl.find all_lines file

let newline lexbuf =
	lines :=  (lexeme_end lexbuf,!cur_line) :: !lines;
	incr cur_line

let find_line p lines =
	let rec loop line delta = function
		| [] -> line + 1, p - delta
		| (lp,line) :: l when lp > p -> line, p - delta
		| (lp,line) :: l -> loop line lp l
	in
	loop 1 0 lines

let get_error_line p =
	let lines = List.rev (try Hashtbl.find all_lines p.pfile with Not_found -> []) in
	let l, _ = find_line p.pmin lines in
	l

let get_error_pos printer p =
	if p.pmin = -1 then
		"(unknown)"
	else
		let lines = List.rev (try Hashtbl.find all_lines p.pfile with Not_found -> []) in
		let l1, p1 = find_line p.pmin lines in
		let l2, p2 = find_line p.pmax lines in
		if l1 = l2 then begin
			let s = (if p1 = p2 then Printf.sprintf " %d" p1 else Printf.sprintf "s %d-%d" p1 p2) in
			Printf.sprintf "%s character%s" (printer p.pfile l1) s
		end else
			Printf.sprintf "%s lines %d-%d" (printer p.pfile l1) l1 l2

let reset() = Buffer.reset buf
let contents() = Buffer.contents buf
let store lexbuf = Buffer.add_string buf (lexeme lexbuf)
let add c = Buffer.add_string buf c

let mk_tok t pmin pmax =
	t , { pfile = !cur_file; pmin = pmin; pmax = pmax }

let mk lexbuf t =
	mk_tok t (lexeme_start lexbuf) (lexeme_end lexbuf)

let mk_ident lexbuf =
	match lexeme lexbuf with
	| s ->
		mk lexbuf (try Kwd (Hashtbl.find keywords s) with Not_found -> Const (Ident s))

let invalid_char lexbuf =
	error (Invalid_character (lexeme_char lexbuf 0)) (lexeme_start lexbuf)


# 113 "lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base = 
   "\000\000\190\255\079\000\192\000\250\000\107\000\195\255\196\255\
    \198\255\199\255\200\255\201\255\202\255\203\255\204\255\215\255\
    \216\255\217\255\218\255\003\000\031\000\077\000\035\000\078\000\
    \079\000\192\000\080\000\095\000\189\000\193\000\191\000\071\001\
    \083\001\105\001\251\255\001\000\223\000\044\000\255\255\044\000\
    \254\255\252\255\137\001\159\001\181\001\219\001\097\000\247\001\
    \001\002\093\001\115\001\244\255\147\001\023\002\124\000\033\002\
    \221\255\197\255\232\255\163\001\235\255\242\255\222\255\234\255\
    \241\255\194\255\239\255\225\255\238\255\224\255\237\255\236\255\
    \233\255\226\255\110\000\231\255\111\000\230\255\112\000\229\255\
    \067\002\095\002\123\002\181\002\056\002\083\002\128\000\002\000\
    \253\255\038\003\039\003\250\255\249\000\004\000\040\003\045\003\
    \091\001\005\000\044\003\049\003\128\001\006\000\000\003";
  Lexing.lex_backtrk = 
   "\255\255\255\255\064\000\063\000\063\000\065\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\035\000\050\000\036\000\047\000\045\000\
    \044\000\043\000\042\000\015\000\049\000\046\000\048\000\041\000\
    \006\000\006\000\255\255\004\000\002\000\065\000\255\255\255\255\
    \255\255\255\255\255\255\007\000\255\255\005\000\255\255\255\255\
    \007\000\010\000\255\255\255\255\009\000\255\255\255\255\008\000\
    \255\255\255\255\255\255\012\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\032\000\255\255\027\000\255\255\028\000\255\255\
    \062\000\062\000\255\255\255\255\255\255\004\000\003\000\001\000\
    \255\255\255\255\006\000\255\255\004\000\001\000\255\255\006\000\
    \002\000\001\000\255\255\005\000\003\000\001\000\002\000";
  Lexing.lex_default = 
   "\001\000\000\000\255\255\255\255\255\255\255\255\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\000\000\255\255\255\255\255\255\000\000\255\255\
    \000\000\000\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\000\000\255\255\255\255\255\255\255\255\
    \000\000\000\000\000\000\059\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\255\255\000\000\255\255\000\000\255\255\000\000\
    \255\255\255\255\255\255\255\255\085\000\085\000\255\255\255\255\
    \000\000\090\000\090\000\000\000\255\255\255\255\095\000\095\000\
    \255\255\255\255\099\000\099\000\255\255\255\255\255\255";
  Lexing.lex_trans = 
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\036\000\034\000\041\000\040\000\035\000\040\000\040\000\
    \040\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \036\000\019\000\007\000\005\000\000\000\026\000\025\000\006\000\
    \010\000\009\000\022\000\029\000\015\000\028\000\031\000\030\000\
    \033\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\016\000\017\000\021\000\020\000\018\000\008\000\
    \078\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\014\000\076\000\013\000\023\000\004\000\
    \072\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\012\000\024\000\011\000\027\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\074\000\073\000\071\000\070\000\066\000\065\000\051\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\056\000\075\000\077\000\079\000\002\000\088\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\081\000\069\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\067\000\039\000\
    \036\000\057\000\064\000\040\000\061\000\000\000\059\000\037\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\063\000\062\000\058\000\068\000\060\000\036\000\
    \038\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\088\000\000\000\000\000\000\000\003\000\
    \000\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\041\000\000\000\000\000\
    \000\000\083\000\000\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\054\000\000\000\055\000\
    \055\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \055\000\043\000\034\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\043\000\
    \042\000\032\000\032\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\255\255\042\000\088\000\
    \255\255\000\000\000\000\000\000\053\000\000\000\053\000\041\000\
    \042\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\046\000\042\000\048\000\
    \048\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\000\000\000\000\000\000\041\000\000\000\000\000\000\000\
    \000\000\044\000\000\000\000\000\047\000\045\000\045\000\045\000\
    \045\000\045\000\045\000\045\000\045\000\045\000\045\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\045\000\045\000\
    \045\000\045\000\045\000\045\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\047\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\045\000\045\000\045\000\045\000\045\000\
    \045\000\045\000\045\000\045\000\045\000\000\000\045\000\045\000\
    \045\000\045\000\045\000\045\000\045\000\045\000\045\000\045\000\
    \045\000\045\000\050\000\000\000\050\000\000\000\000\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\049\000\
    \049\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\000\000\045\000\045\000\045\000\045\000\
    \045\000\045\000\040\000\000\000\000\000\087\000\047\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\000\000\000\000\255\255\000\000\000\000\
    \255\255\000\000\086\000\000\000\000\000\000\000\047\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\255\255\000\000\000\000\
    \000\000\000\000\000\000\000\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\000\000\000\000\
    \000\000\000\000\080\000\255\255\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\082\000\000\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\082\000\000\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \000\000\000\000\000\000\000\000\083\000\000\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \040\000\255\255\040\000\093\000\255\255\097\000\040\000\255\255\
    \038\000\101\000\255\255\255\255\000\000\000\000\255\255\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \091\000\255\255\000\000\000\000\000\000\000\000\000\000\091\000\
    \000\000\000\000\000\000\255\255\255\255\000\000\000\000\000\000\
    \000\000\000\000\000\000\034\000\000\000\000\000\000\000\000\000\
    \255\255\040\000\040\000\040\000\040\000\040\000\040\000\038\000\
    \040\000\038\000\040\000\040\000\040\000\038\000\040\000\040\000\
    \040\000\040\000\040\000\038\000\040\000\038\000\040\000\040\000\
    \040\000\040\000\040\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\092\000\255\255\096\000\000\000\000\000\000\000\
    \100\000\255\255\000\000\000\000\000\000\255\255\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\038\000\255\255\
    \038\000\000\000\000\000\000\000\038\000\255\255\000\000\000\000\
    \000\000\255\255";
  Lexing.lex_check = 
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\035\000\087\000\000\000\093\000\097\000\
    \101\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\000\000\000\000\000\000\255\255\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \019\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\020\000\000\000\000\000\000\000\
    \022\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\021\000\021\000\023\000\024\000\026\000\027\000\046\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\054\000\074\000\076\000\078\000\002\000\086\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\002\000\002\000\002\000\002\000\002\000\002\000\
    \002\000\002\000\005\000\024\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\005\000\005\000\025\000\037\000\
    \036\000\030\000\028\000\039\000\029\000\255\255\030\000\000\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\028\000\028\000\030\000\025\000\029\000\036\000\
    \000\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\092\000\255\255\255\255\255\255\003\000\
    \255\255\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\092\000\255\255\255\255\
    \255\255\004\000\255\255\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\031\000\255\255\031\000\
    \031\000\031\000\031\000\031\000\031\000\031\000\031\000\031\000\
    \031\000\032\000\096\000\032\000\032\000\032\000\032\000\032\000\
    \032\000\032\000\032\000\032\000\032\000\049\000\049\000\049\000\
    \049\000\049\000\049\000\049\000\049\000\049\000\049\000\033\000\
    \032\000\033\000\033\000\033\000\033\000\033\000\033\000\033\000\
    \033\000\033\000\033\000\050\000\050\000\050\000\050\000\050\000\
    \050\000\050\000\050\000\050\000\050\000\059\000\033\000\100\000\
    \059\000\255\255\255\255\255\255\042\000\255\255\042\000\096\000\
    \032\000\042\000\042\000\042\000\042\000\042\000\042\000\042\000\
    \042\000\042\000\042\000\052\000\052\000\052\000\052\000\052\000\
    \052\000\052\000\052\000\052\000\052\000\043\000\033\000\043\000\
    \043\000\043\000\043\000\043\000\043\000\043\000\043\000\043\000\
    \043\000\255\255\255\255\255\255\100\000\255\255\255\255\255\255\
    \255\255\033\000\255\255\255\255\043\000\044\000\044\000\044\000\
    \044\000\044\000\044\000\044\000\044\000\044\000\044\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\044\000\044\000\
    \044\000\044\000\044\000\044\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\043\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\045\000\045\000\045\000\045\000\045\000\
    \045\000\045\000\045\000\045\000\045\000\255\255\044\000\044\000\
    \044\000\044\000\044\000\044\000\045\000\045\000\045\000\045\000\
    \045\000\045\000\047\000\255\255\047\000\255\255\255\255\047\000\
    \047\000\047\000\047\000\047\000\047\000\047\000\047\000\047\000\
    \047\000\048\000\048\000\048\000\048\000\048\000\048\000\048\000\
    \048\000\048\000\048\000\255\255\045\000\045\000\045\000\045\000\
    \045\000\045\000\084\000\255\255\255\255\084\000\048\000\053\000\
    \053\000\053\000\053\000\053\000\053\000\053\000\053\000\053\000\
    \053\000\055\000\055\000\055\000\055\000\055\000\055\000\055\000\
    \055\000\055\000\055\000\255\255\255\255\085\000\255\255\255\255\
    \085\000\255\255\084\000\255\255\255\255\255\255\048\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\085\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\255\255\255\255\
    \255\255\255\255\080\000\059\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\080\000\080\000\
    \080\000\080\000\080\000\080\000\080\000\080\000\081\000\255\255\
    \081\000\081\000\081\000\081\000\081\000\081\000\081\000\081\000\
    \081\000\081\000\081\000\081\000\081\000\081\000\081\000\081\000\
    \081\000\081\000\081\000\081\000\081\000\081\000\081\000\081\000\
    \081\000\081\000\082\000\255\255\082\000\082\000\082\000\082\000\
    \082\000\082\000\082\000\082\000\082\000\082\000\082\000\082\000\
    \082\000\082\000\082\000\082\000\082\000\082\000\082\000\082\000\
    \082\000\082\000\082\000\082\000\082\000\082\000\083\000\083\000\
    \083\000\083\000\083\000\083\000\083\000\083\000\083\000\083\000\
    \083\000\083\000\083\000\083\000\083\000\083\000\083\000\083\000\
    \083\000\083\000\083\000\083\000\083\000\083\000\083\000\083\000\
    \255\255\255\255\255\255\255\255\083\000\255\255\083\000\083\000\
    \083\000\083\000\083\000\083\000\083\000\083\000\083\000\083\000\
    \083\000\083\000\083\000\083\000\083\000\083\000\083\000\083\000\
    \083\000\083\000\083\000\083\000\083\000\083\000\083\000\083\000\
    \089\000\090\000\094\000\089\000\090\000\094\000\098\000\095\000\
    \084\000\098\000\095\000\099\000\255\255\255\255\099\000\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \089\000\090\000\255\255\255\255\255\255\255\255\255\255\094\000\
    \255\255\255\255\255\255\085\000\095\000\255\255\255\255\255\255\
    \255\255\255\255\255\255\098\000\255\255\255\255\255\255\255\255\
    \099\000\102\000\102\000\102\000\102\000\102\000\102\000\102\000\
    \102\000\102\000\102\000\102\000\102\000\102\000\102\000\102\000\
    \102\000\102\000\102\000\102\000\102\000\102\000\102\000\102\000\
    \102\000\102\000\102\000\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\089\000\090\000\094\000\255\255\255\255\255\255\
    \098\000\095\000\255\255\255\255\255\255\099\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\089\000\090\000\
    \094\000\255\255\255\255\255\255\098\000\095\000\255\255\255\255\
    \255\255\099\000";
  Lexing.lex_base_code = 
   "";
  Lexing.lex_backtrk_code = 
   "";
  Lexing.lex_default_code = 
   "";
  Lexing.lex_trans_code = 
   "";
  Lexing.lex_check_code = 
   "";
  Lexing.lex_code = 
   "";
}

let rec token lexbuf =
    __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 135 "lexer.mll"
       ( mk lexbuf Eof )
# 450 "lexer.ml"

  | 1 ->
# 136 "lexer.mll"
                  ( token lexbuf )
# 455 "lexer.ml"

  | 2 ->
# 137 "lexer.mll"
               ( token lexbuf )
# 460 "lexer.ml"

  | 3 ->
# 138 "lexer.mll"
          ( newline lexbuf; token lexbuf )
# 465 "lexer.ml"

  | 4 ->
# 139 "lexer.mll"
               ( newline lexbuf; token lexbuf )
# 470 "lexer.ml"

  | 5 ->
# 140 "lexer.mll"
                                   ( mk lexbuf (Const (Int (lexeme lexbuf))) )
# 475 "lexer.ml"

  | 6 ->
# 141 "lexer.mll"
              ( mk lexbuf (Const (Int (lexeme lexbuf))) )
# 480 "lexer.ml"

  | 7 ->
# 142 "lexer.mll"
                             ( mk lexbuf (Const (Float (lexeme lexbuf))) )
# 485 "lexer.ml"

  | 8 ->
# 143 "lexer.mll"
                  ( mk lexbuf (Const (Float (lexeme lexbuf))) )
# 490 "lexer.ml"

  | 9 ->
# 144 "lexer.mll"
                                              ( mk lexbuf (Const (Float (lexeme lexbuf))) )
# 495 "lexer.ml"

  | 10 ->
# 145 "lexer.mll"
                                                             ( mk lexbuf (Const (Float (lexeme lexbuf))) )
# 500 "lexer.ml"

  | 11 ->
# 146 "lexer.mll"
                    (
			let s = lexeme lexbuf in
			mk lexbuf (IntInterval (String.sub s 0 (String.length s - 3)))
		)
# 508 "lexer.ml"

  | 12 ->
# 150 "lexer.mll"
                       (
			let s = lexeme lexbuf in
			mk lexbuf (CommentLine (String.sub s 2 ((String.length s)-2)))
		)
# 516 "lexer.ml"

  | 13 ->
# 154 "lexer.mll"
        ( mk lexbuf (Unop Increment) )
# 521 "lexer.ml"

  | 14 ->
# 155 "lexer.mll"
        ( mk lexbuf (Unop Decrement) )
# 526 "lexer.ml"

  | 15 ->
# 156 "lexer.mll"
        ( mk lexbuf (Unop NegBits) )
# 531 "lexer.ml"

  | 16 ->
# 157 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpMod)) )
# 536 "lexer.ml"

  | 17 ->
# 158 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpAnd)) )
# 541 "lexer.ml"

  | 18 ->
# 159 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpOr)) )
# 546 "lexer.ml"

  | 19 ->
# 160 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpXor)) )
# 551 "lexer.ml"

  | 20 ->
# 161 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpAdd)) )
# 556 "lexer.ml"

  | 21 ->
# 162 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpSub)) )
# 561 "lexer.ml"

  | 22 ->
# 163 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpMult)) )
# 566 "lexer.ml"

  | 23 ->
# 164 "lexer.mll"
        ( mk lexbuf (Binop (OpAssignOp OpDiv)) )
# 571 "lexer.ml"

  | 24 ->
# 165 "lexer.mll"
         ( mk lexbuf (Binop (OpAssignOp OpShl)) )
# 576 "lexer.ml"

  | 25 ->
# 168 "lexer.mll"
         ( mk lexbuf (Binop OpPhysEq) )
# 581 "lexer.ml"

  | 26 ->
# 169 "lexer.mll"
         ( mk lexbuf (Binop OpPhysNotEq) )
# 586 "lexer.ml"

  | 27 ->
# 170 "lexer.mll"
        ( mk lexbuf (Binop OpEq) )
# 591 "lexer.ml"

  | 28 ->
# 171 "lexer.mll"
        ( mk lexbuf (Binop OpNotEq) )
# 596 "lexer.ml"

  | 29 ->
# 172 "lexer.mll"
        ( mk lexbuf (Binop OpLte) )
# 601 "lexer.ml"

  | 30 ->
# 174 "lexer.mll"
        ( mk lexbuf (Binop OpBoolAnd) )
# 606 "lexer.ml"

  | 31 ->
# 175 "lexer.mll"
        ( mk lexbuf (Binop OpBoolOr) )
# 611 "lexer.ml"

  | 32 ->
# 176 "lexer.mll"
        ( mk lexbuf (Binop OpShl) )
# 616 "lexer.ml"

  | 33 ->
# 177 "lexer.mll"
        ( mk lexbuf Arrow )
# 621 "lexer.ml"

  | 34 ->
# 178 "lexer.mll"
         ( mk lexbuf (Binop OpInterval) )
# 626 "lexer.ml"

  | 35 ->
# 179 "lexer.mll"
       ( mk lexbuf (Unop Not) )
# 631 "lexer.ml"

  | 36 ->
# 180 "lexer.mll"
       ( mk lexbuf (Binop OpLt) )
# 636 "lexer.ml"

  | 37 ->
# 181 "lexer.mll"
       ( mk lexbuf (Binop OpGt) )
# 641 "lexer.ml"

  | 38 ->
# 182 "lexer.mll"
       ( mk lexbuf Semicolon )
# 646 "lexer.ml"

  | 39 ->
# 183 "lexer.mll"
       ( mk lexbuf DblDot )
# 651 "lexer.ml"

  | 40 ->
# 184 "lexer.mll"
       ( mk lexbuf Comma )
# 656 "lexer.ml"

  | 41 ->
# 185 "lexer.mll"
       ( mk lexbuf Dot )
# 661 "lexer.ml"

  | 42 ->
# 186 "lexer.mll"
       ( mk lexbuf (Binop OpMod) )
# 666 "lexer.ml"

  | 43 ->
# 187 "lexer.mll"
       ( mk lexbuf (Binop OpAnd) )
# 671 "lexer.ml"

  | 44 ->
# 188 "lexer.mll"
       ( mk lexbuf (Binop OpOr) )
# 676 "lexer.ml"

  | 45 ->
# 189 "lexer.mll"
       ( mk lexbuf (Binop OpXor) )
# 681 "lexer.ml"

  | 46 ->
# 190 "lexer.mll"
       ( mk lexbuf (Binop OpAdd) )
# 686 "lexer.ml"

  | 47 ->
# 191 "lexer.mll"
       ( mk lexbuf (Binop OpMult) )
# 691 "lexer.ml"

  | 48 ->
# 192 "lexer.mll"
       ( mk lexbuf (Binop OpDiv) )
# 696 "lexer.ml"

  | 49 ->
# 193 "lexer.mll"
       ( mk lexbuf (Binop OpSub) )
# 701 "lexer.ml"

  | 50 ->
# 194 "lexer.mll"
       ( mk lexbuf (Binop OpAssign) )
# 706 "lexer.ml"

  | 51 ->
# 195 "lexer.mll"
       ( mk lexbuf BkOpen )
# 711 "lexer.ml"

  | 52 ->
# 196 "lexer.mll"
       ( mk lexbuf BkClose )
# 716 "lexer.ml"

  | 53 ->
# 197 "lexer.mll"
       ( mk lexbuf BrOpen )
# 721 "lexer.ml"

  | 54 ->
# 198 "lexer.mll"
       ( mk lexbuf BrClose )
# 726 "lexer.ml"

  | 55 ->
# 199 "lexer.mll"
       ( mk lexbuf POpen )
# 731 "lexer.ml"

  | 56 ->
# 200 "lexer.mll"
       ( mk lexbuf PClose )
# 736 "lexer.ml"

  | 57 ->
# 201 "lexer.mll"
       ( mk lexbuf Question )
# 741 "lexer.ml"

  | 58 ->
# 202 "lexer.mll"
        (
			reset();
			let pmin = lexeme_start lexbuf in
			let pmax = (try comment lexbuf with Exit -> error Unclosed_comment pmin) in
			mk_tok (Comment (contents())) pmin pmax;
		)
# 751 "lexer.ml"

  | 59 ->
# 208 "lexer.mll"
       (
			reset();
			let pmin = lexeme_start lexbuf in
			let pmax = (try string lexbuf with Exit -> error Unterminated_string pmin) in
			let str = (try unescape (contents()) with Exit -> error Invalid_escape pmin) in
			mk_tok (Const (String str)) pmin pmax;
		)
# 762 "lexer.ml"

  | 60 ->
# 215 "lexer.mll"
       (
			reset();
			let pmin = lexeme_start lexbuf in
			let pmax = (try string2 lexbuf with Exit -> error Unterminated_string pmin) in
			let str = (try unescape (contents()) with Exit -> error Invalid_escape pmin) in
			mk_tok (Const (String str)) pmin pmax;
		)
# 773 "lexer.ml"

  | 61 ->
# 222 "lexer.mll"
        (
			reset();
			let pmin = lexeme_start lexbuf in
			let options, pmax = (try regexp lexbuf with Exit -> error Unterminated_regexp pmin) in
			let str = contents() in
			mk_tok (Const (Regexp (str,options))) pmin pmax;
		)
# 784 "lexer.ml"

  | 62 ->
# 229 "lexer.mll"
             (
			let v = lexeme lexbuf in
			let v = String.sub v 1 (String.length v - 1) in
			mk lexbuf (Macro v)
		)
# 793 "lexer.ml"

  | 63 ->
# 234 "lexer.mll"
         ( mk_ident lexbuf )
# 798 "lexer.ml"

  | 64 ->
# 235 "lexer.mll"
          ( mk lexbuf (Const (Type (lexeme lexbuf))) )
# 803 "lexer.ml"

  | 65 ->
# 236 "lexer.mll"
     ( invalid_char lexbuf )
# 808 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_token_rec lexbuf __ocaml_lex_state

and comment lexbuf =
    __ocaml_lex_comment_rec lexbuf 84
and __ocaml_lex_comment_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 239 "lexer.mll"
       ( raise Exit )
# 819 "lexer.ml"

  | 1 ->
# 240 "lexer.mll"
                        ( newline lexbuf; store lexbuf; comment lexbuf )
# 824 "lexer.ml"

  | 2 ->
# 241 "lexer.mll"
        ( lexeme_end lexbuf )
# 829 "lexer.ml"

  | 3 ->
# 242 "lexer.mll"
       ( store lexbuf; comment lexbuf )
# 834 "lexer.ml"

  | 4 ->
# 243 "lexer.mll"
                     ( store lexbuf; comment lexbuf )
# 839 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_comment_rec lexbuf __ocaml_lex_state

and string lexbuf =
    __ocaml_lex_string_rec lexbuf 89
and __ocaml_lex_string_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 246 "lexer.mll"
       ( raise Exit )
# 850 "lexer.ml"

  | 1 ->
# 247 "lexer.mll"
                        ( newline lexbuf; store lexbuf; string lexbuf )
# 855 "lexer.ml"

  | 2 ->
# 248 "lexer.mll"
          ( store lexbuf; string lexbuf )
# 860 "lexer.ml"

  | 3 ->
# 249 "lexer.mll"
          ( store lexbuf; string lexbuf )
# 865 "lexer.ml"

  | 4 ->
# 250 "lexer.mll"
        ( store lexbuf; string lexbuf )
# 870 "lexer.ml"

  | 5 ->
# 251 "lexer.mll"
       ( lexeme_end lexbuf )
# 875 "lexer.ml"

  | 6 ->
# 252 "lexer.mll"
                          ( store lexbuf; string lexbuf )
# 880 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_string_rec lexbuf __ocaml_lex_state

and string2 lexbuf =
    __ocaml_lex_string2_rec lexbuf 94
and __ocaml_lex_string2_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 255 "lexer.mll"
       ( raise Exit )
# 891 "lexer.ml"

  | 1 ->
# 256 "lexer.mll"
                        ( newline lexbuf; store lexbuf; string2 lexbuf )
# 896 "lexer.ml"

  | 2 ->
# 257 "lexer.mll"
        ( store lexbuf; string2 lexbuf )
# 901 "lexer.ml"

  | 3 ->
# 258 "lexer.mll"
          ( store lexbuf; string2 lexbuf )
# 906 "lexer.ml"

  | 4 ->
# 259 "lexer.mll"
         ( store lexbuf; string2 lexbuf )
# 911 "lexer.ml"

  | 5 ->
# 260 "lexer.mll"
       ( lexeme_end lexbuf )
# 916 "lexer.ml"

  | 6 ->
# 261 "lexer.mll"
                           ( store lexbuf; string2 lexbuf )
# 921 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_string2_rec lexbuf __ocaml_lex_state

and regexp lexbuf =
    __ocaml_lex_regexp_rec lexbuf 98
and __ocaml_lex_regexp_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 264 "lexer.mll"
       ( raise Exit )
# 932 "lexer.ml"

  | 1 ->
# 265 "lexer.mll"
                        ( newline lexbuf; store lexbuf; regexp lexbuf )
# 937 "lexer.ml"

  | 2 ->
# 266 "lexer.mll"
         ( add "/"; regexp lexbuf )
# 942 "lexer.ml"

  | 3 ->
# 267 "lexer.mll"
                 ( store lexbuf; regexp lexbuf )
# 947 "lexer.ml"

  | 4 ->
# 268 "lexer.mll"
       ( regexp_options lexbuf, lexeme_end lexbuf )
# 952 "lexer.ml"

  | 5 ->
# 269 "lexer.mll"
                           ( store lexbuf; regexp lexbuf )
# 957 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_regexp_rec lexbuf __ocaml_lex_state

and regexp_options lexbuf =
    __ocaml_lex_regexp_options_rec lexbuf 102
and __ocaml_lex_regexp_options_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 272 "lexer.mll"
                               (
			let l = lexeme lexbuf in
			l ^ regexp_options lexbuf
		)
# 971 "lexer.ml"

  | 1 ->
# 276 "lexer.mll"
               ( error Invalid_option (lexeme_start lexbuf) )
# 976 "lexer.ml"

  | 2 ->
# 277 "lexer.mll"
      ( "" )
# 981 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf; __ocaml_lex_regexp_options_rec lexbuf __ocaml_lex_state

;;
