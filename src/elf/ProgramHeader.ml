open Printf
       open Binary

(*
            typedef struct {
               uint32_t   p_type;
               uint32_t   p_flags;
               Elf64_Off  p_offset;
               Elf64_Addr p_vaddr;
               Elf64_Addr p_paddr;
               uint64_t   p_filesz;
               uint64_t   p_memsz;
               uint64_t   p_align;
           } Elf64_Phdr;
 *)
type program_header64 =
  {
    p_type: int;   (* 4 *)
    p_flags: int;  (* 4 *)
    p_offset: int; (* 8 *)
    p_vaddr: int;  (* 8 *)
    p_paddr: int;  (* 8 *)
    p_filesz: int; (* 8 *)
    p_memsz: int;  (* 8 *)
    p_align: int;  (* 8 *)
  }

(* p type *)
let kPT_NULL =		0		(* Program header table entry unused *)
let kPT_LOAD =		1		(* Loadable program segment *)
let kPT_DYNAMIC =	2		(* Dynamic linking information *)
let kPT_INTERP =	3		(* Program interpreter *)
let kPT_NOTE =		4		(* Auxiliary information *)
let kPT_SHLIB =	        5		(* Reserved *)
let kPT_PHDR =		6		(* Entry for header table itself *)
let kPT_TLS =		7		(* Thread-local storage segment *)
let kPT_NUM =		8		(* Number of defined types *)
let kPT_LOOS =		0x60000000	(* Start of OS-specific *)
let kPT_GNU_EH_FRAME =	0x6474e550	(* GCC .eh_frame_hdr segment *)
let kPT_GNU_STACK    =  0x6474e551	(* Indicates stack executability *)
let kPT_GNU_RELRO    =	0x6474e552	(* Read-only after relocation *)
let kPT_LOSUNW	= 0x6ffffffa
let kPT_SUNWBSS	 = 0x6ffffffa	(* Sun Specific segment *)
let kPT_SUNWSTACK = 0x6ffffffb	(* Stack segment *)
let kPT_HISUNW	= 0x6fffffff
let kPT_HIOS	= 0x6fffffff	(* End of OS-specific *)
let kPT_LOPROC	= 0x70000000	(* Start of processor-specific *)
let kPT_HIPROC	= 0x7fffffff	(* End of processor-specific *)

let sizeof_program_header = 56 	(* bytes *)
		    
let get_program_header binary offset =
  let p_type = Binary.i32 binary offset in (* &i *)
  let p_flags = Binary.i32 binary (offset + 4) in
  let p_offset = Binary.i64 binary (offset + 8) in
  let p_vaddr = Binary.i64 binary (offset + 16) in
  let p_paddr = Binary.i64 binary (offset + 24) in
  let p_filesz = Binary.i64 binary (offset + 32) in
  let p_memsz = Binary.i64 binary (offset + 40) in
  let p_align = Binary.i64 binary (offset + 48) in
  {
    p_type;
    p_flags; (* 1=x 2=w 4=r *)
    p_offset;
    p_vaddr;
    p_paddr;
    p_filesz;
    p_memsz;
    p_align;
  }

let ptype_to_string ptype =
  match ptype with
  | 0 -> "NULL"
  | 1 -> "LOAD"
  | 2 -> "DYNAMIC"
  | 3 -> "INTERP"
  | 4 -> "NOTE"
  | 5 -> "SHLIB"
  | 6 -> "PHDR"
  | 7 -> "TLS"
  | 8 -> "NUM"
  | 0x60000000 -> "LOOS"
  | 0x6474e550 -> "GNU_EH_FRAME"
  | 0x6474e551 -> "GNU_STACK"
  | 0x6474e552 -> "GNU_RELRO"
  | 0x6ffffffa -> "LOSUNW"
  | 0x6ffffffa -> "SUNWBSS"
  | 0x6ffffffb -> "SUNWSTACK"
  | 0x6fffffff -> "HISUNW"
  | 0x6fffffff -> "HIOS"
  | 0x70000000 -> "LOPROC"
  | 0x7fffffff -> "HIPROC"
  | _ -> "UNKNOWN"

let flags_to_string flags =
  match flags with
  | 1 -> "X"
  | 2 -> "W"
  | 3 -> "W+X"
  | 4 -> "R"
  | 5 -> "R+X"
  | 6 -> "RW"
  | 7 -> "RW+X"
  | _ -> "UNKNOWN FLAG"
	   
let program_header_to_string ph =
  Printf.sprintf "%-12s %-4s offset: 0x%04x vaddr: 0x%08x paddr: 0x%08x filesz: 0x%04x memsz: 0x%04x align: %d"
		 (ptype_to_string ph.p_type)
		 (flags_to_string ph.p_flags) (* 6 r/w 5 r/x *)
		 ph.p_offset
		 ph.p_vaddr
		 ph.p_paddr
		 ph.p_filesz
		 ph.p_memsz
		 ph.p_align
    
let print_program_headers phs =
  Printf.printf "Program Headers (%d):\n" @@ List.length phs;
  List.iter (fun ph -> Printf.printf "%s\n" @@ program_header_to_string ph) phs
    
let get_program_headers binary phoff phentsize phnum =
  let rec loop count offset acc =
    if (count >= phnum) then
      List.rev acc
    else
      let ph = get_program_header binary offset in
      loop (count + 1) (offset + phentsize) (ph::acc)
  in loop 0 phoff []
  
(*		    
let get_p_type p_type =
  match p_type with
  | 0 -> PT_NULL		
  | 1 -> PT_LOAD		
  | 2 -> PT_DYNAMIC	
  | 3 -> PT_INTERP	
  | 4 -> PT_NOTE		
  | 5 -> PT_SHLIB	
  | 6 -> PT_PHDR		
  | 7 -> PT_TLS		
  | 8 -> PT_NUM		
  | 0x60000000 -> PT_LOOS		
  | 0x6474e550 -> PT_GNU_EH_FRAME	
  | 0x6474e551 -> PT_GNU_STACK	
  | 0x6474e552 -> PT_GNU_RELRO	
  | 0x6ffffffa -> PT_LOSUNW
  | 0x6ffffffa -> PT_SUNWBSS
  | 0x6ffffffb -> PT_SUNWSTACK
  | 0x6fffffff -> PT_HISUNW
  | 0x6fffffff -> PT_HIOS
  | 0x70000000 -> PT_LOPROC
  | 0x7fffffff -> PT_HIPROC
 *)