#!/usr/bin/env bash
cp ./redbean.com ./redbean.run.com

cd src
zip -r ../redbean.run.com .
cd ..

./redbean.run.com
