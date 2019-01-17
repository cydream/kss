#! /bin/bash

if [ -z "$1" ]
  then
    echo "usage: ./train.sh [datasets/mv01] [son400|kss400] [410000]"
    exit 1
fi

echo "Training started" > log.txt
date >> log.txt

rm hyperparams.py
rm ko
rm *.pyc

PWD=$(pwd)/$1
escaped=${PWD//\//\\/}
sed "s/change_here/$escaped/g" hyperparams.py.template > hyperparams.py
if [ -z "$3" ]
  then
    echo "use default 410000 iteration"
  else
    sed -i -e "s/410000/$3/g" hyperparams.py
fi

KO_DIR=$1/ko
if [ -d "$KO_DIR" ]; then
  ln -s $KO_DIR ko
  echo "Data exists, start phase 1" >> log.txt
else
  python prepo.py
  mv ko $1/
  ln -s $KO_DIR ko
  echo "Data prepared, start phase 1" >> log.txt
  date >> log.txt
fi

rm -rf logdir
if [ -z "$2" ]
  then
    echo "use default base model kss400"
    tar xzvf kss400.tar.gz
  else
    tar xzvf $2.tar.gz
fi

python ttt.py 1
echo "start phase 2" >> log.txt
date >> log.txt

python ttt.py 2
echo "Training ended" >> log.txt
date >> log.txt

python synthesize.py
echo "Samples generated" >> log.txt
date >> log.txt

mv logdir $1/
mv samples $1/
mv log.txt $1/
