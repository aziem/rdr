open Elf

exception Bad_binary of int * int
exception Unimplemented_binary_analysis of string

type t = | Mach of bytes | Elf of bytes
				    
let get_bytes filename =
  let ic = open_in_bin Sys.argv.(1) in
  let magic = InputUtils.i32be ic in
  Printf.printf "filesize: %d\n" @@ in_channel_length ic;
  (* Printf.printf "magic: 0x%x\n" magic; *)
  if (magic = Elf.kMAGIC_ELF) then
    let len = in_channel_length ic in
    let binary = Bytes.create len in
    seek_in ic 0;
    really_input ic binary 0 len;
    close_in ic;
    Elf binary
  else
    begin
      close_in ic;
      raise @@ Bad_binary (magic, -1)
    end
      
let main =
  if (Array.length Sys.argv <> 2) then
    begin
      Printf.printf "usage: binreader <path_to_binary>";
      exit 1
    end
  else
    let bytes = get_bytes Sys.argv.(1) in
    match bytes with
    | Elf binary ->
       Elf.analyze binary
    | Mach binary ->
       raise @@ Unimplemented_binary_analysis "Mach not implemented"