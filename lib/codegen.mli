type _ outerfn =
    Function : 'a Idl.Param.t * 'b outerfn -> ('a -> 'b) outerfn
  | Returning :
      ('a Idl.Param.t * 'b Idl.Error.t) -> ('a, 'b) Result.result outerfn
module Method :
  sig
    type 'a t = { name : string; description : string list; ty : 'a outerfn; }
    val find_inputs : 'a outerfn -> Idl.Param.boxed list
    val find_output : 'a outerfn -> Idl.Param.boxed
  end
type boxed_fn = BoxedFunction : 'a Method.t -> boxed_fn
module Interface :
  sig
    type description =
      Idl.Interface.description = {
      name : string;
      description : string list;
      version : Rpc.Version.t;
    }
    type t = {
      details : Idl.Interface.description;
      methods : boxed_fn list;
    }
    val prepend_arg : t -> 'a Idl.Param.t -> t
    val all_types : t -> Rpc.Types.boxed_def list
  end
module Interfaces :
  sig
    type t = {
      name : string;
      title : string;
      description : string list;
      type_decls : Rpc.Types.boxed_def list;
      interfaces : Interface.t list;
    }
    val empty : string -> string -> string list -> t
    val add_interface : Interface.t -> t -> t
  end
exception Interface_not_described
module Gen :
  functor () ->
    sig
      type ('a,'b) comp = ('a,'b) Result.result
      type 'a fn = 'a outerfn
      type 'a res = unit
      type description = Interface.t
      val describe : Interface.description -> Interface.t
      val returning :
        'a Idl.Param.t -> 'b Idl.Error.t -> ('a, 'b) Result.result outerfn
      val ( @-> ) : 'a Idl.Param.t -> 'b outerfn -> ('a -> 'b) outerfn
      val declare : string -> string list -> 'a fn -> 'a res
    end
