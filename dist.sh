#! /bin/bash

### This script is used to build and serve the app

# Install json-server, http-server if needed and elm-land if needed
# npm i -g json-server
# npm i -g http-server
# npm i -g elm-land

# Build
pushd viet_dict
elm-land build
popd

# Prepare for serving
cp -r viet_dict/dist .

# Serve
json-server data/data.json &
http-server dist -p 8080 &
