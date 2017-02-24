#!/usr/bin/env bash

ORIGIN=https://hubbed:$GITHUB_TOKEN@github.com/williamkapke/node-compat-table.git

echo
echo 'downloading latest...'
rm -rf ./.temp
git clone $ORIGIN .temp

mkdir -p ./.temp/results
cd ./.temp
git config user.email "hubbed@kap.co"
git config user.name "Imma Bot"
curl https://raw.githubusercontent.com/kangax/compat-table/gh-pages/data-es6.js > data-es6.js
curl https://raw.githubusercontent.com/kangax/compat-table/gh-pages/data-es2016plus.js > data-es2016plus.js

echo
echo 'extracting testers...'
node extract.js ./data-es6.js > ./testers-es6.json
node extract.js ./data-es2016plus.js > ./testers-es2016plus.json
node testers.js > testers.json


echo
echo 'running the tests on each version of node...'

bash versions.sh > v8.versions
while read v; do
  n $v
  node test.js
  node --es_staging test.js
  node --harmony test.js
done < v8.versions


LATEST=$(curl -sL https://nodejs.org/download/nightly/index.tab |   awk '{ if (!f && NR > 1) { print $1; f = 1 } }')
PROJECT_NAME="node" PROJECT_URL="https://nodejs.org/download/nightly/" n project $LATEST
node test.js
node --es_staging test.js
node --harmony test.js

LATEST=$(curl -sL https://nodejs.org/download/chakracore-nightly/index.tab |   awk '{ if (!f && NR > 1) { print $1; f = 1 } }')
PROJECT_NAME="node" PROJECT_URL="https://nodejs.org/download/chakracore-nightly/" n project $LATEST
node test.js

n use 6.10.0
git add ./results/**/*.json
git add v8.versions

if [[ `git status -s` == '' ]]; then
  echo 'No changes';
  exit 1;
fi

echo
echo 'building webpage...'
node build.js > index.html

echo
echo 'saving the results...'
git commit -am 'Auto Update'
git push $ORIGIN gh-pages

