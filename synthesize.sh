#! /bin/bash

if [ -z "$1" ]
  then
    echo "usage: ./synthesize.sh [datasets/mv01] [001.txt]"
    exit 1
fi

rm hyperparams.py
rm logdir
rm -rf samples
ln -s $1/logdir logdir

PWD=$(pwd)/$1
escaped=${PWD//\//\\/}
sed "s/change_here/$escaped/g" hyperparams.py.template > hyperparams.py
sed -i -e "s/rats.txt/$2/g" hyperparams.py

python synthesize.py

mv samples/0/* samples/
cd samples
rmdir 0
for a in *.wav; do
  b=$(printf %04d.wav ${a%.wav})
  mv $a $b
done
cd ..
tar xzvf ${2%.txt}.tar.gz -C samples/
mv samples $1/${2%.txt}
rm logdir
