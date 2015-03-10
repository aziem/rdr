(* little endian *)
let input_n_bytes n ic =
  let res = ref 0 in
  for i = 0 to n - 1 do
    res := !res lor ((input_byte ic) lsl (8 * i))
  done;
  !res
   
let input_i32 = input_n_bytes 4
let input_i64 = input_n_bytes 8

(* big endian *)
let input_n_bytes_be n ic =
  let res = ref 0 in
  for i = n - 1 downto 0 do
    res := !res lor ((input_byte ic) lsl (i * 8));
  done;
  !res

let i32be = input_n_bytes_be 4
let i64be = input_n_bytes_be 8

let read_all ic =
  let byte = ref 0 in
  try
    while (true) do
      byte := input_byte ic;
      Printf.printf "%x " !byte
    done
  with End_of_file ->
    Printf.printf "\n"

let discard_n_bytes n ic =
  seek_in ic ((pos_in ic) + n + 1) (* TODO: +1? *)