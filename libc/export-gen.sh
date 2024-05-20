#!/bin/bash

# SPDX-License-Identifier: GPL-2.0-only
# SPDX-FileCopyrightText: 2024 KolibriOS-NG Team

in_file=libc.def
out_file=src/export.c

echo "ksys_dll_t EXPORTS[] = {" > "$out_file"

sed '1,3d' "$in_file" | while IFS= read -r sym; do
  if [ -z "$sym" ]; then
    continue
  fi
  echo "    {\"$sym\", &$sym}," >> "$out_file"
done 

cat << EOF >> "$out_file"
    {NULL, NULL}
};
EOF
