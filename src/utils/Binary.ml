let input_n_bytes n binary offset =
  let res = ref 0 in
  for i = 0 to n - 1 do
    res := !res lor ((Char.code @@ Bytes.get binary (offset + i)) lsl (8 * i))
  done;
  !res

let i8 binary offset = (Bytes.get binary offset) |> Char.code

let i16 = input_n_bytes 2
let i32 = input_n_bytes 4
let i64 = input_n_bytes 8

let istring binary offset =
  let null_index = Bytes.index_from binary offset '\000' in
   Bytes.sub_string binary offset (null_index - offset)

let stringo binary offset =
  let null_index = Bytes.index_from binary offset '\000' in
   (Bytes.sub_string binary offset (null_index - offset)), (null_index + 1)
			
(* testing *)
let l1 = ['\x7f';'\x45';'\x4c';'\x46';'\x02';'\x01';'\x01';'\x00';]
let e1 = Bytes.init (List.length l1) (fun i -> List.nth l1 i)
let e2 = 0x7f454c
let e3 = (i16 e1 0) = 17791

			