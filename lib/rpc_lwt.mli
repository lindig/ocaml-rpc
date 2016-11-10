module M :
  sig
    type 'a lwt = { lwt : 'a Lwt.t; }
    type ('a, 'b) t = ('a, 'b) Result.result lwt
    val return : 'a -> ('a, 'b) t
    val return_err : 'b -> ('a, 'b) t
    val checked_bind : ('a, 'b) t -> ('a -> ('c, 'd) t) -> ('b -> ('c, 'd) t) -> ('c, 'd) t
    val bind : ('a, 'b) t -> ('a -> ('c, 'b) t) -> ('c, 'b) t
    val ( >>= ) : ('a, 'b) t -> ('a -> ('c, 'b) t) -> ('c, 'b) t
    val lwt : 'a lwt -> 'a Lwt.t
  end

module GenClient :
  sig
    type description = Idl.Interface.description
    val describe : 'a -> 'a
    exception MarshalError of string
    type ('a,'b) comp = ('a,'b) Result.result M.lwt
    type rpcfn = Rpc.call -> Rpc.response Lwt.t
    type 'a res = rpcfn -> 'a
    type _ fn =
        Function : 'a Idl.Param.t * 'b fn -> ('a -> 'b) fn
      | Returning : ('a Idl.Param.t * 'b Idl.Error.t) -> ('a, 'b) M.t fn
    val returning : 'a Idl.Param.t -> 'b Idl.Error.t -> ('a, 'b) M.t fn
    val ( @-> ) : 'a Idl.Param.t -> 'b fn -> ('a -> 'b) fn
    val declare : string -> 'a -> 'b fn -> rpcfn -> 'b
  end

module GenServer :
  sig
    type description = Idl.Interface.description
    val describe : 'a -> 'a
    exception MarshalError of string
    exception UnknownMethod of string
    type ('a,'b) comp = ('a,'b) Result.result M.lwt
    type rpcfn = Rpc.call -> Rpc.response Lwt.t
    type funcs = (string, rpcfn) Hashtbl.t
    type 'a res = 'a -> funcs -> funcs
    type _ fn =
        Function : 'a Idl.Param.t * 'b fn -> ('a -> 'b) fn
      | Returning : ('a Idl.Param.t * 'b Idl.Error.t) -> ('a, 'b) M.t fn
    val returning : 'a Idl.Param.t -> 'b Idl.Error.t -> ('a, 'b) M.t fn
    val ( @-> ) : 'a Idl.Param.t -> 'b fn -> ('a -> 'b) fn
    val empty : unit -> funcs
    val declare : string -> string -> 'a fn -> 'a res
    val server : (string, Rpc.call -> 'a) Hashtbl.t -> Rpc.call -> 'a
  end
