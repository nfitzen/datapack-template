#!/usr/bin/env bash
# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2020, 2022 nfitzen <https://github.com/nfitzen>

# Replace PACK_NAME with the file-safe name of the pack
PACK_NAME="datapack-template"

# Optionally replace version, or let Git do it for you.
version=$(git describe --tags --dirty --always)

if command -v zip; then
    ZIP="zip -r";
else
    ZIP="7z a";
fi

rm -r .build/
mkdir .build releases .build/files

cp -r data/ .build/files/

# handle mcmeta specifically for version replacement
<pack.mcmeta version=$version envsubst > .build/files/pack.mcmeta

cp -r .reuse/ LICENSE LICENSES/ README.md .build/files

# Currently only implemented for AESTD
# I plan to make this work with any datapack lib in the future and merge JSON

mkdir .build/libs
cp -r libs/AESTD/ .build/libs/

cd .build/

cp -rn libs/AESTD/data/aestd*/ files/data/
rm -rf files/data/aestd.tools/ # kinda inefficient but whatever
cp -rn libs/AESTD/data/load/ files/data/
cp -r libs/AESTD/data/minecraft/loot_tables/ files/data/minecraft/

cd files/

# a hacky workaround since `>` overwrites the file before it's read
(<pack.mcmeta envsubst) > ./pack.mcmeta

rm ../../releases/$PACK_NAME-$version.zip

$ZIP ../../releases/$PACK_NAME-$version.zip ** .reuse/
