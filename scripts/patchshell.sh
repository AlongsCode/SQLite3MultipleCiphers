#!/bin/sh
# Generate patched shell.c from SQLite3 amalgamation distribution and write it to stdout.
# Usage: ./script/patchshell.sh shell.c >shellpatched.c

INPUT="$([ "$#" -eq 1 ] && echo "$1" || echo "shell.c")"
if ! [ -f "$INPUT" ]; then
  echo "Usage: $0 <SQLITE3_SHELL_AMALGAMATION>" >&2
  echo " e.g.: $0 shell.c" >&2
  exit 1
fi

die() {
    echo "[-]" "$@" >&2
    exit 2
}

sed -e '/int nHistory;/{n;N;N;N;N;d}' "$INPUT" \
    | sed '50i#if SQLITE3MC_USE_MINIZ != 0\n#include "miniz.c"\n#ifdef SQLITE_HAVE_ZLIB\n#undef SQLITE_HAVE_ZLIB\n#endif\n#define SQLITE_HAVE_ZLIB 1\n#endif\n' \
    | sed '/#include <zlib.h>/c #include "zlibwrap.h"' \
    | sed '/int nHistory;/a \      extern char* sqlite3mc_version();\n      printf(\n        "SQLite version \%s \%.19s" \/\*extra-version-info\*\/\n        " (\%s)\\n" \/\*SQLite3-Multiple-Ciphers-version-info\*\/\n        "Enter \\".help\\" for usage hints.\\n\",\n        sqlite3_libversion(), sqlite3_sourceid(), sqlite3mc_version()\n      );'
