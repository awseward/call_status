import strutils

proc discoverIndent(s: string): int =
  result = 0
  for i in 0..100: # Probably not going to be many things that deep...
    if s[i] != ' ': break
    inc result

assert discoverIndent("  a") == 2

# Very slightly smarter version of strutils' unindent
proc dedent*(s: string): string =
  unindent(s, discoverIndent s)

block:
  let input = """
    a
      b
      c
    d"""
  assert input.dedent() == """
a
  b
  c
d"""
