# NOT SUPPORTED ANYMORE

Ubuntu 20.04 has a lot of potential issues, so if at all possible I recommend upgrading to 22.04 or higher as soon as you can.

If you can't upgrade, it seems like there is only one big issue - getting a recent enough `iverilog` with enough modern dependencids that `fst` files work. You should be able to do that by instead installing `iverilog` from source, *after* the correct dependencies are installed. Follow these instructions in order:

```bash
# make sure any older versions are gone 
sudo apt-get remove iverilog

# iverilog dependencies
sudo apt-get install gperf autoconf flex libghc-zlib-dev bison

# get iverilog at the right tag
git clone https://github.com/steveicarus/iverilog.git 
cd iverilog
git checkout --track -b v11-branch origin/v11-branch 

# configure and build iverilog
sh autoconf.sh
./configure 
make -j8
sudo make install

# optional - only if you are desperate for space:
#  remove iverilog source/build
cd ..
rm -rf iverilog
```

No promises if anything else doesn't work. 