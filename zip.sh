#!/usr/bin/env bash

for d in `ls -d lima-*` ; do
  if [ -d $d ] ; then
    f=${d}.zip
    zip -r $f $d/run.sh $d/*yaml
  fi
done
