#!/bin/bash

set -e

if sed --version 2>/dev/null | grep -q GNU; then
  SED_INPLACE="sed -i"
else
  SED_INPLACE="sed -i ''"
fi

## How to run
##   `./upgrade.sh`

# https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
# Usage
# $ get_latest_release "duckdb/duckdb"
get_latest_release() {
    curl -fSs "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
      grep '"tag_name":' |                                            # Get tag line
      sed -E 's/.*"v([^"]+)".*/\1/'                                   # Pluck JSON value
}

duckdb_version=$(get_latest_release "duckdb/duckdb")
duckdb_rs_version=$(get_latest_release "duckdb/duckdb-rs")

if [ $duckdb_version = $duckdb_rs_version ]; then
    echo "Already update to date, latest version is $duckdb_version"
    exit 0
fi

echo "Start to upgrade from $duckdb_rs_version to $duckdb_version"

$SED_INPLACE "s/$duckdb_rs_version/$duckdb_version/g" \
    Cargo.toml \
    crates/duckdb/Cargo.toml \
    crates/libduckdb-sys/upgrade.sh \
    crates/libduckdb-sys/Cargo.toml \
    .github/workflows/rust.yaml

exec ./crates/libduckdb-sys/upgrade.sh
