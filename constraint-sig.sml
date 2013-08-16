signature SEMVER_CONSTRAINT = 
sig
   type semver_constraint
   type t = semver_constraint

   exception InvalidConstraint

   val fromString : string -> semver_constraint
   val toString : semver_constraint -> string

   (* Valid constraints are prefixes
    * 2
    * 2.4
    * 2.4.9 
    * In other words, if minor = NONE, then patch = NONE as well. *)
   type semver_constraint_data = { major : IntInf.int
                                 , minor : IntInf.int option
                                 , patch : IntInf.int option }

   val construct : semver_constraint_data -> semver_constraint
   val data : semver_constraint -> semver_constraint_data

   val major : semver_constraint -> IntInf.int
   val minor : semver_constraint -> IntInf.int option
   val patch : semver_constraint -> IntInf.int option

   (* A semver satisfies any constraint that it is a prefix of,
    * roughly speaking. So the semvers v2.5.6 and v2.0.0-rc12 both
    * satisfy the constraint v2, but only the first one satisfies v2.5
    * and only the second one satisfies v2.0. *)
   val satisfies : semver_constraint -> SemVer.t -> bool

   (* Picking the best semver for a given constraint. 
    *
    * We prefer a non-prerelease version to any other
    * version. Therefore we either pick the highest-precedence
    * satisfying version that isn't a prerelease. If only prerelease
    * versions exist, use them.
    *
    * The pick function is intended to be used with fold (as in
    * List.foldr (SemVerConstraint.pick sv_constraint) NONE semvers).
    * 
    * Precondition: if the optional semver argument is given, it MUST
    * satisfy the constraint given as an argument. (The mandatory
    * semver argument doesn't need to satisfy the constraint - pick
    * will check this argument for satsfaction.) *)

   val pick : semver_constraint option
              -> SemVer.t * SemVer.t option
              -> SemVer.t option
end
