# Training a Spanish-to-English model with Marian

This is an example of building a Spansh-to-English sequence-to-sequence
neural translation model using [Marian NMT](https://marian-nmt.github.io/).

This code is based on the 
[`training-basics` example](https://github.com/marian-nmt/marian-examples/tree/master/training-basics) 
included with Marian which is in turn adapted from the Romanian-English
sample at https://github.com/rsennrich/wmt16-scripts. 

This is a great place to start if you want to play around with building
your own Google-Translate-style language translation model.

# How to Train the Model

Instructions for Ubuntu 18.04 with CUDA/cuDNN installed:

```bash
# Install newer CMake via 3rd-party repo
wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | 
sudo apt-key add -
sudo apt-add-repository 'deb https://apt.kitware.com/ubuntu/ bionic main'
sudo apt-get install cmake git build-essential libboost-all-dev

# Download and compile Marian
cd ~
git clone https://github.com/marian-nmt/marian
cd marian
mkdir build
cd build
cmake -DCOMPILE_SERVER=on -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-10.1/ ..
make -j4

# Grab and compile the Marian model examples and helper tools
cd ~/marian/
git clone https://github.com/marian-nmt/marian-examples.git
cd marian-examples/
cd tools/
make

# Download this Repo
cd ~/marian/marian-examples
git clone https://github.com/ageitgey/spanish-to-english-translation

# Install the Python modules
cd spanish-to-english-translation
sudo python3 -m pip install -r requirements.txt

# Train!
./run-me.sh

# (2 days later...) Try trained model
../../build/marian-server --port 8080 -c model/model.npz.best-translation.npz.decoder.yml -d 0 -b 12 -n1 --mini-batch 64 --maxi-batch 10 --maxi-batch-sort src &

python3 translate_sentences_example.py
```
