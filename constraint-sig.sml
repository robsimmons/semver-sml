signature SEMVER_CONSTRAINT = 
sig
   type semver_constraint
   type t = semver_constraint

   exception InvalidConstraint

   val fromString : string -> semver_constraint
   val toString : semver_constraint -> string

   (* Valid constraints are only prefixes:
    * 2
    * 2.4
    * 2.4.9
    * 2.4.9-x
    * 2.4.9-x.y.z.w ... *)
   type semver_constraint_data = { major : IntInf.int
                                 , minor : IntInf.int option
                                 , patch : IntInf.int option
                                 , release : string list }

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
    * List.foldr (SemVerConstraint.pick sv_constraint) NONE semvers) *)
   val pick : semver_constraint option
              -> SemVer.t * SemVer.t option
              -> SemVer.t option
end
