open Printf

type reg =
  | EAX
  | ESP
  | EBP


type size =
  | DWORD_PTR
  | WORD_PTR
  | BYTE_PTR

type arg =
  | Const of int
  | HexConst of int
  | Reg of reg
  | RegOffset of int * reg
  | Sized of size * arg

type instruction =
  | IMov of arg * arg

  | IAdd of arg * arg
  | ISub of arg * arg
  | IMul of arg * arg

  | IShr of arg * arg
  | IShl of arg * arg

  | IAnd of arg * arg
  | IOr of arg * arg
  | IXor of arg * arg

  | ILabel of string
  | IPush of arg
  | IPop of arg
  | ICall of string
  | IRet

  | ICmp of arg * arg
  | IJne of string
  | IJe of string
  | IJmp of string
  | IJno of string
  | IJo of string


type prim1 =
  | Add1
  | Sub1
  | Print
  | IsNum
  | IsBool

type prim2 =
  | Plus
  | Minus
  | Times
  | Less
  | Greater
  | Equal

type expr =
  | ELet of (string * expr) list * expr
  | EPrim1 of prim1 * expr
  | EPrim2 of prim2 * expr * expr
  | EIf of expr * expr * expr
  | ENumber of int
  | EBool of bool
  | EId of string

let count = ref 0
let gen_temp base =
  count := !count + 1;
  sprintf "temp_%s_%d" base !count

let r_to_asm (r : reg) : string =
  match r with
    | EAX -> "eax"
    | ESP -> "esp"
    | EBP -> "ebp"

let s_to_asm (s : size) : string =
  match s with
    | DWORD_PTR -> "DWORD"
    | WORD_PTR -> "WORD"
    | BYTE_PTR -> "BYTE"

let rec arg_to_asm (a : arg) : string =
  match a with
    | Const(n) -> sprintf "%d" n
    | HexConst(n) -> failwith "TODO: HexConst"
    | Reg(r) -> r_to_asm r
    | RegOffset(n, r) -> failwith "TODO: RegOffset"
    | Sized(s, a) ->
      failwith "TODO: Sized"

let i_to_asm (i : instruction) : string =
  match i with
    | IMov(dest, value) ->
      sprintf "  mov %s, %s" (arg_to_asm dest) (arg_to_asm value)
    | IAdd(dest, to_add) ->
      sprintf "  add %s, %s" (arg_to_asm dest) (arg_to_asm to_add)
    | ISub(dest, to_sub) ->
      sprintf "  sub %s, %s" (arg_to_asm dest) (arg_to_asm to_sub)
    | IMul(dest, to_mul) ->
      sprintf "  imul %s, %s" (arg_to_asm dest) (arg_to_asm to_mul)
    | IAnd(dest, mask) ->
      failwith "TODO: IAnd"
    | IOr(dest, mask) ->
      failwith "TODO: IOr"
    | IXor(dest, mask) ->
      failwith "TODO: IXor"
    | IShr(dest, to_shift) ->
      failwith "TODO: IShr"
    | IShl(dest, to_shift) ->
      failwith "TODO: IShl"
    | ICmp(left, right) ->
      failwith "TODO: ICmp"
    | IPush(arg) ->
      failwith "TODO: IPush"
    | IPop(arg) ->
      failwith "TODO: IPop"
    | ICall(str) ->
      failwith "TODO: ICall"
    | ILabel(name) ->
      failwith "TODO: ILabel"
    | IJne(label) ->
      failwith "TODO: IJne"
    | IJe(label) ->
      failwith "TODO: IJe"
    | IJno(label) ->
      failwith "TODO: IJno"
    | IJo(label) ->
      failwith "TODO: IJo"
    | IJmp(label) ->
      failwith "TODO: IJmp"
    | IRet ->
      " ret"

let to_asm (is : instruction list) : string =
  List.fold_left (fun s i -> sprintf "%s\n%s" s (i_to_asm i)) "" is

let rec find ls x =
  match ls with
    | [] -> None
    | (y,v)::rest ->
      if y = x then Some(v) else find rest x

let const_true = HexConst(0xffffffff)
let const_false = HexConst(0x7fffffff)

(* You want to be using C functions to deal with error output here. *)
let throw_err code = failwith "TODO: throw_err"

let check_overflow = IJo("overflow_check")
let error_non_int = "error_non_int"
let error_non_bool = "error_non_bool"

let check_num = failwith "TODO: check_num"

let max n m = if n > m then n else m

let check_nums arg1 arg2 = failwith "TODO: check_nums"

let check (e : expr) : string list =
  match well_formed_e e [] with
    | [] -> []
    | errs -> failwith String.concat "\n" errs

let rec well_formed_e (e : expr) (env : (string * int) list) : string list =
  match e with
    | ENumber(_)
    | EBool(_) -> []
    | EId(x) ->
      begin match find env x with
        | None -> ["Unbound identifier: " ^ x]
        | Some(_) -> []
      end
    | EPrim1(op, e) ->
      failwith "TODO: well_formed_e EPrim1"
    | EPrim2(op, left, right) ->
      failwith "TODO: well_formed_e EPrim2"
    | EIf(cond, thn, els) ->
      failwith "TODO: well_formed_e EIf"
    | ELet(binds, body) ->
      failwith "TODO: well_formed_e ELet"

let rec compile_expr (e : expr) (si : int) (env : (string * int) list) : instruction list =
  match e with
    | ENumber(n) ->
      failwith "TODO: compile_expr ENumber"
    | EBool(b) ->
      let c = if b then const_true else const_false in
      [ IMov(Reg(EAX), c) ]
    | EId(name) ->
      failwith "TODO: compile_expr EId"
    | EPrim1(op, e) ->
      failwith "TODO: compile_expr EPrim1"
    | EPrim2(op, el, er) ->
      failwith "TODO: compile_expr EPrim2"
    | EIf(cond, thn, els) ->
      failwith "TODO: compile_expr EIf"
    | ELet([], body) ->
      failwith "TODO: compile_expr ELet1"
    | ELet((x, ex)::binds, body) ->
      failwith "TODO: compile_expr ELet2"

let compile_to_string prog =
  let static_errors = check prog in
  let stackjump = 0 in
  let prelude = "section .text
extern error
extern print
global our_code_starts_here
our_code_starts_here:
  push ebp
  mov ebp, esp
  sub esp, " ^ (string_of_int stackjump) ^ "\n" in
  let postlude = [
    IMov(Reg(ESP), Reg(EBP));
    IPop(Reg(EBP));
    IRet;
    ILabel("overflow_check")
  ]
  @ (throw_err 3)
  @ [ILabel(error_non_int)] @ (throw_err 1)
  @ [ILabel(error_non_bool)] @ (throw_err 2) in
  let compiled = (compile_expr prog 1 []) in
  let as_assembly_string = (to_asm (compiled @ postlude)) in
  sprintf "%s%s\n" prelude as_assembly_string

