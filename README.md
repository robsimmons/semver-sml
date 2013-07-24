semver-sml
==========

A Semantic Versioning library for Standard ML, currently based on
[SemVer 2.0.0](http://semver.org/spec/v2.0.0.html). 

This implementation aims to be a strict and straightforward
implementation of the standard (so no messing around with
maybe-allowing the leading 'v'). The files
[semver.tests](semver.tests) and [semver-big.tests](semver-big.tests)
aim to capture some general-purpose tests for semantic versioning
implementations. (The test file format is described below.)

The structure `SemVer` implements the signature
[`SEMVER`](semver-sig.sml), and the structure `SemVerConstraint`
implements the signature [`SEMVER_CONSTRAINT`](constraint-sig.sml).

Constraints
-----------

This package currently doesn't contain the traditional 'range'
notation used in a lot of versioning libraries (see
[node-semver](https://github.com/isaacs/node-semver) for an
example). There's no reason someone couldn't implement it, but
currently the package implements a variant of this idea that is aimed
at the way the Smackage utility uses semantic versioning.

The Smackage utility uses constraints that are reflected in code
paths: if you say that you need (some implementation of) version 2 of
the `widgets` package, you can look for it on your hard drive at
`$SMACKAGE/widgets/v2`. (This gets you out of dependency hell: you can
actually have two incompatible versions of a utility at the same
time.)

The constraints `2` or `2.3` are basically the same as `~2` or `~2.3`
from [node-semver](https://github.com/isaacs/node-semver). These
constraints match the range `<= 2.0.0-0 < 3.0.0-0`, and `<= 2.3.0-0 <
2.4.0-0`, respectively. However, given a list of possible versions, a
fold using the `SemVerConstraint.pick` will prefer version `2.3.1` to
`2.4.0-alpha`.

The constraint `2.3.4` is not like `~2.3.4` in node-semver. It is
equivalent to the range `<= 2.3.4-0 < 2.3.5-0`; it will only be
satisfied a particular version (or its prereleases). This allows a
specific release, and only a specific release, to be targeted.

Test file format
----------------

The test cases are in a zero-or-one-test-per-line format, where the
`#` character acts like a line comment. The first character indicates
the sort of test.

* `Y` - expect a valid semver
* `N` - expect an invalid semver
* `<` - expect two valid semvers, the second with higher precedence
* `>` - expect two valid semvers, the first with higher precedence
* `=` - expect two valid semvers with equal precedence

```
<possible-semver-char> ::= any non-whitespace ASCII chararcter except "#"
<possible-semver> ::= <possible-semver-char>
                      <possible-semver-char> <possible-semver>

<test> ::= "Y" <whitespace> <possible-semver>
           "N" <whitespace> <possible-semver>
           "<" <whitespace> <possible-semver> <whitespace> <possible-semver>
           ">" <whitespace> <possible-semver> <whitespace> <possible-semver>
           "=" <whitespace> <possible-semver> <whitespace> <possible-semver>
```

