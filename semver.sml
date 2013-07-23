structure SemVer :> SEMVER =
struct
   type semver = { major : IntInf.int
                 , minor : IntInf.int
                 , patch : IntInf.int
                 , release : string list
                 , build : string list }
   type t = semver
   type semver_data = semver

   exception InvalidSemVer

   fun valid_id_char c = 
      (#"0" <= c andalso c <= #"9") orelse
      (#"A" <= c andalso c <= #"Z") orelse
      (#"a" <= c andalso c <= #"z") orelse
      (c = #"-")

   fun valid_id id = 
      size id > 0 andalso List.all valid_id_char (explode id)
 
   fun valid_version id =
      size id > 0 
      andalso (#"0" <> String.sub (id, 0) orelse id = "0")
      andalso List.all Char.isDigit (explode id)

   (* I don't know why the SML/NJ typechecker must be told semver_data here *)
   fun validate ({major, minor, patch, release, build}: semver_data) =
   let in
    ( if major >= 0 then () else raise InvalidSemVer
    ; if minor >= 0 then () else raise InvalidSemVer
    ; if patch >= 0 then () else raise InvalidSemVer
    ; app (fn id => (if valid_id id then () else raise InvalidSemVer)) release
    ; app (fn id => (if valid_id id then () else raise InvalidSemVer)) build )
   end 

   fun data (x: semver) = x
   fun semver (x: semver_data) = (validate x; x)

   fun toString {major, minor, patch, release, build} = 
   let
      val major_str = IntInf.toString major
      val minor_str = IntInf.toString minor
      val patch_str = IntInf.toString patch

      val release_str = 
         case release of
            [] => ""
          | _ => "-"^String.concatWith "." release

      val build_str = 
         case build of 
            [] => ""
          | _ => "+"^String.concatWith "." build 
   in
      major_str^"."^minor_str^"."^patch_str^release_str^build_str
   end

   fun dotted_ids_from_string str =  
   let val ids = String.fields (fn c => c = #".") str
   in 
    ( app (fn id => (if valid_id id then () else raise InvalidSemVer)) ids
    ; ids)
   end

   fun version_from_string str = 
    ( if valid_version str then () else raise InvalidSemVer
    ; valOf (IntInf.fromString str) )
  

   fun first char str i n = 
      if i = n then NONE
      else if String.sub (str, i) = char then SOME i
      else first char str (i+1) n

   fun fromString str =
   let
      val () = if size str >= 5 then () else raise InvalidSemVer
        
      val (str, build) = 
         case String.fields (fn c => c = #"+") str of
            [str] => (str, [])
          | [str, build] => (str, dotted_ids_from_string build)
          | _ => raise InvalidSemVer

      val (str, release) =
         case first #"-" str 0 (size str) of
            NONE => (str, [])
          | SOME i => (String.extract (str, 0, SOME i),
                       dotted_ids_from_string (String.extract (str, i+1, NONE)))

      val (major, minor, patch) = 
         case map version_from_string (String.fields (fn c => c = #".") str) of
            [major, minor, patch] => (major, minor, patch)
          | _ => raise InvalidSemVer
   in
      { major = major
      , minor = minor
      , patch = patch
      , release = release
      , build = build }
   end

   fun compare_ids (x, y) =
      if List.all Char.isDigit (explode x) 
      then (if List.all Char.isDigit (explode y)
            then IntInf.compare (valOf (IntInf.fromString x), 
                                 valOf (IntInf.fromString y))
            else LESS (* Numeric identifiers have lower precedence *))
      else (if List.all Char.isDigit (explode y)
            then GREATER (* Numeric identifiers have lower precedence *)
            else String.compare (x, y))

   fun compare_releases (xs, ys) =
      case (xs, ys) of
         ([], []) => EQUAL
       | (_, []) => GREATER (* Longer [more specific] releases greater *)
       | ([], _) => LESS
       | (x :: xs, y :: ys) =>
           (case compare_ids (x, y) of
               EQUAL => compare_releases (xs, ys)
             | ord => ord)

   fun compare (sv1: semver, sv2: semver) = 
      case IntInf.compare (#major sv1, #major sv2) of
         LESS => LESS
       | GREATER => GREATER
       | EQUAL => 
           (case IntInf.compare (#minor sv1, #minor sv2) of
               LESS => LESS
             | GREATER => GREATER
             | EQUAL => 
                 (case IntInf.compare (#patch sv1, #patch sv2) of
                     LESS => LESS
                   | GREATER => GREATER
                   | EQUAL =>
                       (case (#release sv1, #release sv2) of
                           ([], []) => EQUAL
                         | ([], _) => GREATER (* Not prerelease is greatest *)
                         | (_, []) => LESS (* Not prerelease is greatest *)
                         | (rel1, rel2) => compare_releases (rel1, rel2))))

   fun major (s: semver) = #major s 
   fun minor (s: semver) = #minor s 
   fun patch (s: semver) = #patch s 
   fun release (s: semver) = #release s 
   fun build (s: semver) = #build s 
end
