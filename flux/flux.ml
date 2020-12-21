type 'a t = Tick of ('a * 'a t) option Lazy.t

let vide = Tick (lazy None)

let cons t q = Tick (lazy (Some (t, q)))

let uncons (Tick flux) = Lazy.force flux

let rec apply f x =
  Tick
    ( lazy
      ( match (uncons f, uncons x) with
      | None, _ -> None
      | _, None -> None
      | Some (tf, qf), Some (tx, qx) -> Some (tf tx, apply qf qx) ) )

let rec unfold f e =
  Tick
    ( lazy
      (match f e with None -> None | Some (t, e') -> Some (t, unfold f e')) )

let rec filter p flux =
  Tick
    ( lazy
      ( match uncons flux with
      | None -> None
      | Some (t, q) -> if p t then Some (t, filter p q) else uncons (filter p q)
      ) )

let rec append flux1 flux2 =
  Tick
    ( lazy
      ( match uncons flux1 with
      | None -> uncons flux2
      | Some (t1, q1) -> Some (t1, append q1 flux2) ) )

let constant c = unfold (fun () -> Some (c, ())) ()

let map f i = apply (constant f) i

let map2 f i1 i2 = apply (apply (constant f) i1) i2
