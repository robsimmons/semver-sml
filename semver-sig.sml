(* Semantic Versioning. Intented to implement semver.org, v2.0.0 *)

signature SEMVER =
sig
   type semver
   type t = semver

   exception InvalidSemVer

   val fromString : string -> semver
   val toString : semver -> string

   type semverData = { major : IntInf.int
                     , minor : IntInf.int
                     , patch : IntInf.int
                     , release : string list
                     , build : string list }
                         
   val semver : semverData -> semver
   val data : semver -> semverData

   val major : semver -> IntInf.int
   val minor : semver -> IntInf.int
   val patch : semver -> IntInf.int
   val release : semver -> string list
   val build : semver -> string list

   val compare : semver * semver -> order
end 
