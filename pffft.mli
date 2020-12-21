val assumption : (unit -> bool) -> unit

val assertion : (unit -> bool) -> unit

val miracle : unit -> 'a

val failure : unit -> 'a

val forall_bool : unit -> bool

val forsome_bool : unit -> bool

val forall : 'a Flux.t -> 'a

val forsome : 'a Flux.t -> 'a

val foratlest : int -> 'a Flux.t -> 'a

val check : (unit -> unit) -> bool
