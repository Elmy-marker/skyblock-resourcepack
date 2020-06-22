#!/bin/bash

##################
# Read constants #
##################

readonly DESCRIPTION=$(cat description.txt)
echo "Description: $DESCRIPTION"

###############################
# Initialize target directory #
###############################

# Make this script fail in case of failed commands
set -ev

# Create empty directory to store build files
mkdir -p ./target/
find ./target/ -mindepth 1 -delete

############################
# Generate resourcepack V3 #
############################

# Create directory for storing resourcepack files
mkdir ./target/resourcepack_v3/

# Copy resourcepack files to manipulated directory
cp -r ./assets/ ./target/resourcepack_v3/assets/
cp ./pack.png ./target/resourcepack_v3/

# Generate v3 multimodel files
python3 ./scripts/generate_multimodels.py --mappings ./mappings/ \
--target ./target/resourcepack_v3/assets/minecraft/models/item/ --format 3

# Compress JSON models
python3 ./scripts/compress_models.py --models ./target/resourcepack_v3/assets/divinecraft/models/

# Create valid pack.mcmeta
python3 ./scripts/generate_pack_mcmeta.py --path ./target/resourcepack_v3/ --version 3 --description "$DESCRIPTION"

# Generate v3 ZIP-archive
# `cd` is used not to keep full path to files
cd ./target/resourcepack_v3/
zip -r ../resourcepack_v3 .
cd ../../

############################
# Generate resourcepack V4 #
############################

# note: mkdir is *not* needed as it will change copy-semantics
# Copy resourcepack files to manipulated directory
cp -r ./target/resourcepack_v3/ ./target/resourcepack_v4

# Generate v4 multimodel files
rm -r ./target/resourcepack_v4/assets/minecraft/models/item/
python3 ./scripts/generate_multimodels.py --mappings ./mappings/ \
--target ./target/resourcepack_v4/assets/minecraft/models/item/ --format 4

# Fix models
python3 ./scripts/patch_v3_models_to_v4.py --models ./target/resourcepack_v4/assets/divinecraft/models/
python3 ./scripts/patch_v3_models_to_v4.py --models ./target/resourcepack_v4/assets/minecraft/models/

# Create valid pack.mcmeta
python3 ./scripts/generate_pack_mcmeta.py --path ./target/resourcepack_v4/ --version 4 --description "$DESCRIPTION"

# Generate v4 ZIP-archive
# `cd` is used not to keep full path to files
cd ./target/resourcepack_v4/
zip -r ../resourcepack_v4 .
cd ../../
