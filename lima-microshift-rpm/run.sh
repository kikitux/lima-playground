#!/usr/bin/env bash

shopt -s nullglob
YAML=(*yaml)

for y in ${YAML[@]}; do

  i=${y/.yaml}

  if [ "$1" == "delete" ] ; then
      limactl delete $i -f
      exit
  fi

  limactl list $i 2>/dev/null || {
    limactl start --name=$i $y
  }
done
