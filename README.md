# FPGA Labs
A collection of FPGA labs, most recently for Olin's ENGR3410: Computer Architecture course in Fall '22. 

# Hardware

## Supported Boards
Xilinx Boards:
  - [*] [Cmod A7](https://digilent.com/reference/programmable-logic/cmod-a7/start)

## Electronics Tools
*my preferred options are linked, but many of them are "buy it for life" quality (and price). Feel free to use any compatible tool.*

Required:

- Solderless Breadboard(s)
- [Solid core wire/jumper kit]()
- [Wire Strippers]()
- [Flush Cutters]()
- Multimeter
  - [Fluke 287](https://www.fluke.com/en-us/product/electrical-testing/digital-multimeters/fluke-287)
- Logic Analyzer
  - [Saleae Logic 8](https://www.saleae.com/). If you can afford it get the Pro 8. One of the nicest tools I've ever purchased, hardware and software are both just very well designed. Easy to write your own analysis software for it to, unlike pretty much every other tool on this list.

Recommended:
- Bench Power Supply
  - something with a programmable current limit, ideally 2 channels
  - [BK Precision 9132B](https://www.bkprecision.com/products/power-supplies/9132B-triple-output-programmable-dc-power-supply-2-0-60v-3a-1-0-5v-3a.html)
- Oscilloscope
  - any 2-4 channel with at least 100MHz bandwidth is fine
  - [Rigol](https://www.rigolna.com/products/digital-oscilloscopes/1000z/) makes some decent budget options, their DS1102Z-E is a solid 2 channel scope, and the DS1104Z Plus has 4 channels and can be expanded to include a logic probe which would replace a stand alone logic analyzer.
  - [Digilent Analog Discovery Pro](https://digilent.com/reference/test-and-measurement/analog-discovery-pro-3x50/specifications) - it doesn't have a screen, but it is portable, has some great specifications, and has a built in logic analyzer. I haven't tested it yet but it could be a good "buy it for life" option.

# Software
This is only tested and maintained on Linux, students have gotten [Windows Subsystem for Linux aka WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to work. Everything except the Xilinx part should run okay on macos, but is unsupported (VMs can work, but some older macs have issues with USB pass through).

Contact the [maintainer](mailto:avinash+fpga@nonholonomy.com) if you find any issues with with the install process.

Supported Linux Distros:
- [*] Ubuntu 22.04
  - Explicitly not supported on Ubuntu 20.04, but if needs must, this [guide](docs/install/ubuntu2004.md) shows you how to get the right version of `iverilog`. You might still have other issues.
- [*] Gentoo
- [*] ArchLinux
- Probably works fine on other flavors, especially since we're building most of this from source. The following instructions are for ubuntu, you can check out intructions for other distros [here](docs/install/other_distros.md)

Last, a note on philosophy - there are a lot of techniques to batch together the install of all of these tools (virtual machines, Docker/containers, build scripts, etc.), but a large part of being a good embedded engineer is know how to maintain and install a large set of tools with low to minimal documentation. If you are new to Linux command line/bash installation I recommend you work through the following tutorials before proceeding:
  - [Command Line for Beginners](https://ubuntu.com/tutorials/command-line-for-beginners#1-overview).
  - Get used to [Tab Completion](https://www.howtogeek.com/195207/use-tab-completion-to-type-commands-faster-on-any-operating-system/) - it saves you time and typos!
  - [Reverse Search](https://codeburst.io/use-reverse-i-search-to-quickly-navigate-through-your-history-917f4d7ffd37) - a very powerful tool for when you're rapidly iterating - let's you search your history and quickly re-run commands you've run before.
  - [A guide to bashrc](https://www.routerhosting.com/knowledge-base/what-is-linux-bashrc-and-how-to-use-it-full-guide/) - how you customize your command line (aka shell).
  - Last but not least, you can get information on most commands by typing `man command` or `command --help`.

*Strong Recommendation* - don't just copy and paste the instructions below - try to run each command one by one to get more familiarity and practice.

Installation checklist:
- [ ] have 25GB (minimum) or 100GB (all bells and whistles) free on your computer
- [ ] build tools
- [ ] icarus verilog
- [ ] verilator
- [ ] gtkwave
- [ ] Digilent Adept
- [ ] Xilinx Vivado
- [ ] Digilent Board Files
- [ ] a good graphical text editor (supported: [vscode](https://code.visualstudio.com/)) 
  - If you are using vscode, the mshr-h.veriloghdl extension is the best I've found. Edit the `verilog.linting.linter` to `verilator` (`ctrl+,` to open settings, then search for `verilog.linting...`, or just type `code --install-extension mshr-h.veriloghdl` from the command line). Once you have this enabled you'll get very handy warnings as you describe your hardware that will save you a ton of time.
- [ ] a good command line text editor (recommended: [nano](https://www.nano-editor.org/)). Not necessarily required for this class, but it's good to know how to edit a file from the command line so that you can do it when working over ssh (remote connection) or as root (gui programs and root don't mix well).
  
The install process is split between open source and propriety tools.

## Install: Ubuntu 22.04

```bash
# Build Tools
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install \
    # good for general development
    build-essential nano python3 libusb-1.0.0 git \
    # cafe specific
    python3-bitstring iverilog gtkwave verilator \
    # required for vivado specifically
    libtinfo5 libxtst6 \

sudo adduser $USER dialout
```

Digilent:

Go to the [runtime](https://digilent.com/reference/lib/exe/fetch.php?tok=f5f244&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-runtime-download) and [utilities](https://digilent.com/reference/lib/exe/fetch.php?tok=358c01&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-utilities-download) sites and download the "Linux 64-bit.deb" options. Then, from where you downloaded it, run:
```bash
sudo dpkg -i digilent.adept.runtime_2.4.1-amd64.deb
sudo dpkg -i digilent.adept.utilities_2.4.1-amd64.deb
```
(your exact version numbers may be different).

Then you can flash FPGAs without Xilinx tools using:
```
djtgcfg enum # Will show you the string to put for the -d arg
djtgcfg prog -d CmodA7 -i 0 -f main.bit
```

### Xilinx Install
Xilinx makes the most cutting edge FPGA hardware, but their software leaves a lot to be desired. You have two options:
1. Official Install (_for masochists_)
  - Takes >4 hrs, most of that download time.
  - Requires ~125GB to install (~75GB final, it's a very bad installer).
  - Only recommended if you are interested in doing FPGA work later in life. Installing these tools and getting things working is a bit of a rite of passage (unfortunately.)
  - You've been warned, instructions [here](docs/install/xilinx/xilinx.md) if you want to go this route. The exact images might be slightly different from year to year.
2. Copy from USB Method (_recommended method_)
  - Takes 5-30 min. (depending on how fast your USB ports/hard drive are)
  - Pick an install path for Xilinx *Xilinx needs its install location to have no spaces!!!*
  - Plug in the external drive, navigate to the xilinx folder, get a terminal open (you can right-click and pick open terminal in most distros). Below is how to do this from the command line:
```bash
sudo mkdir /mnt/tmp
sudo mount /dev/disk/by-label/cafe_install /mnt/tmp
cd /mnt/tmp
# This step will copy the files to your computer, takes 20-30min
sudo ./custom_install.sh /path/to/destination
sudo chown -R $USER /path/to/destination # make sure you own the files once they're copied.
```
There's a bug in my script, so you might end up with an extra "full_install" folder, e.g. `/path/to/destination/full_install/Vivado/...`. If that's the case you can do:
```bash
cd /path/to/destination
mv full_install/* ./
rmdir full_instll
```
to fix that issue.

```bash
cd /path/to/destination/Vivado/2021.1/
nano settings64.sh # replace all paths with the /path/to/destination you used above
nano .settings64-Vivado.sh # ditto
# Check that it works:
source /path/to/destination/Vivado/2022.1/settings64.sh
vivado &
# after a wait the gui should pop up!
```

If you want the full install, but don't have the ridiculous 120GB plus Xilinx needs for temporary files, you can follow the above steps, but do `./custom_install.sh /path/to/destination full` instead. 

3. Note that you will need to run `source /path/to/destination/Vivado/2022.1/settings64.sh` in every terminal you plan to run Vivado in! You can save time by editing your `~/.bashrc` file and adding this to the end:
```
function setup_xilinx(){
    # Make a variable with the install path.
    export XILINX_INSTALL_PATH="/mnt/bulk/avinash/embedded/xilinx/"
    VERSION="2022.1"
    export VIVADO_PATH=${XILINX_INSTALL_PATH}/Vivado/${VERSION}
    
    # Calls the Xilinx setup scripts so that you can run the tools.
    source ${VIVADO_PATH}/settings64.sh
}
# setup_xilinx() # Uncomment this if you are only using this linux partition for this class. 
```

Aside: Xilinx clutters your path with a lot of copies of things that are probably better on your main system, so I prefer to call `setup_xilinx` manually in every terminal I'm using it in (instead of running it all the time by calling it from `.bashrc`).


### Digilent Board Files install
From the digilent [docs](https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis#install_digilent_s_board_files)
Replace `XILINX_INSTALL_PATH` and `VIVADO_PATH` as appropriate below.
```bash
cd $XILINX_INSTALL_PATH 
git clone https://github.com/Digilent/vivado-boards
mkdir -p ${VIVADO_PATH}/data/boards/board_files/
cp -r vivado-boards/new/board_files/* ${VIVADO_PATH}/data/boards/board_files/
```

## Checking the install.

You can check to see that all the tools were installed by running the `tools/check_install` script. 
