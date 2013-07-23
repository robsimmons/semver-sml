structure SemVerTest =
struct

   (* Basic test options *)

   fun test_success str = 
   let
      val sv = SemVer.fromString str
      val str' = SemVer.toString sv
   in
      EQUAL = SemVer.compare (sv, sv) (* For good measure... *)
      andalso str = str'
   end handle _ => false

   fun test_failure str =
   let 
      val sv = SemVer.fromString str
   in 
      false
   end handle SemVer.InvalidSemVer => true 

   fun test_inequiv (str1, str2) = 
   let
      val sv1 = SemVer.fromString str1
      val sv2 = SemVer.fromString str2
   in
      LESS = SemVer.compare (sv1, sv2)
      andalso GREATER = SemVer.compare (sv2, sv1)
   end handle _ => false

   fun test_equiv (str1, str2) = 
   let
      val sv1 = SemVer.fromString str1
      val sv2 = SemVer.fromString str2
   in
      EQUAL = SemVer.compare (sv1, sv2)
      andalso EQUAL = SemVer.compare (sv2, sv1)
   end handle _ => false

   (* Turn parsed lines into calls to the testing framework *)

   fun testline line = 
      case String.tokens Char.isSpace line of
         [] => ()
       | ["Y", str] => Testing.expect str test_success line
       | ["N", str] => Testing.expect str test_failure line
       | ["<", str1, str2] => Testing.expect (str1, str2) test_inequiv line
       | [">", str1, str2] => Testing.expect (str2, str1) test_inequiv line
       | ["=", str1, str2] => Testing.expect (str1, str2) test_equiv line
       | _ => Testing.expect () (fn () => false) ("Cannot parse: "^line)
  
   (* Read files *)
   
   fun uncomment line = 
      case String.fields (fn c => c = #"#") line of
         [] => ""
       | (line :: _) => line

   fun testfile filename = 
   let
      val file = TextIO.openIn filename
      fun loop () = 
         case TextIO.inputLine file of 
            NONE => ()
          | SOME line => (testline (uncomment line); loop ())
   in
      loop ()
   end

   val () = testfile "semver.tests"
   val () = Testing.report ()
   val () = Testing.reset ()

end
