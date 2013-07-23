semver-sml
==========

A Semantic Versioning library for Standard ML, currently based on
[SemVer 2.0.0](http://semver.org/spec/v2.0.0.html). 

This implementation aims to be a strict and straightforward
implementation of the standard (so no messing around with
maybe-allowing the leading 'v'). The files
[semver.tests](semver.tests) and [semver-big.tests](semver-big.tests)
aim to capture some general-purpose tests for semantic versioning
implementations.

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
<possible-semver-char> ::= any non-whitespace chararcter except "#"
<possible-semver> ::= <possible-semver-char>
                      <possible-semver-char> <possible-semver>

<test> ::= "Y" <whitespace> <possible-semver>
           "N" <whitespace> <possible-semver>
           "<" <whitespace> <possible-semver> <whitespace> <possible-semver>
           ">" <whitespace> <possible-semver> <whitespace> <possible-semver>
           "=" <whitespace> <possible-semver> <whitespace> <possible-semver>
```
