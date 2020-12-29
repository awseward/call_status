import strutils

proc discoverIndent(s: string): int =
  result = 0
  for i in 0..100: # Probably not going to be many things that deep...
    if s[i] != ' ': break
    inc result

proc dedent*(s: string): string =
  ## Similar to strutils' unindent, but this proc only unindents as far as the
  ## first line is indented.
  unindent(s, discoverIndent s)

runnableExamples:
  let query = dedent """

    CREATE TABLE things (
      id        SERIAL PRIMARY KEY,
      name      TEXT NOT NULL,
      is_active BOOLEAN NOT NULL
    );
  """
  doAssert query == """
CREATE TABLE things (
  id        SERIAL PRIMARY KEY,
  name      TEXT NOT NULL,
  is_active BOOLEAN NOT NULL
);
"""

# TESTME
when isMainModule:
  doAssert discoverIndent("  a") == 2
  doAssert discoverIndent("a") == 0

  doAssert dedent("    a") == "a"
  doAssert dedent("a") == "a"
