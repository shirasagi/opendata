#!/bin/bash

#
# install mecab
#
pushd .

echo "wget -O mecab-0.996.tar.gz \"https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE\""
wget -O mecab-0.996.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7cENtOXlicTFaRUE"
if [ $? -ne 0 ]; then
  exit 1
fi

echo "tar xzf mecab-0.996.tar.gz"
tar xzf mecab-0.996.tar.gz
if [ $? -ne 0 ]; then
  exit 1
fi

cd mecab-0.996
echo "./configure --enable-utf8-only"
./configure --enable-utf8-only

echo "make"
make
if [ $? -ne 0 ]; then
  exit 1
fi

echo "make install"
sudo make install

echo "/usr/local/lib" | sudo tee -a /etc/ld.so.conf.d/user-local.conf
echo "ldconfig"
sudo ldconfig
popd

#
# install ipadic
#

pushd .

echo "wget -O mecab-ipadic-2.7.0-20070801.tar.gz \"https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM\""
wget -O mecab-ipadic-2.7.0-20070801.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7MWVlSDBCSXZMTXM"
if [ $? -ne 0 ]; then
  exit 2
fi

echo "tar xzf mecab-ipadic-2.7.0-20070801.tar.gz"
tar xzf mecab-ipadic-2.7.0-20070801.tar.gz
if [ $? -ne 0 ]; then
  exit 2
fi

cd mecab-ipadic-2.7.0-20070801
echo "./configure --with-charset=utf8"
./configure --with-charset=utf8

echo "make"
make
if [ $? -ne 0 ]; then
  exit 2
fi

echo "make install"
sudo make install
popd

#
# install mecab-ruby
#

pushd .

echo "wget -O mecab-ruby-0.996.tar.gz \"https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7VUNlczBWVDZJbE0\""
wget -O mecab-ruby-0.996.tar.gz "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7VUNlczBWVDZJbE0"
if [ $? -ne 0 ]; then
  exit 3
fi

echo "tar xzf mecab-ruby-0.996.tar.gz"
tar xzf mecab-ruby-0.996.tar.gz
if [ $? -ne 0 ]; then
  exit 3
fi

cd mecab-ruby-0.996

echo "ruby extconf.rb"
ruby extconf.rb

echo "make"
make
if [ $? -ne 0 ]; then
  exit 3
fi

echo "make install"
make install
popd
