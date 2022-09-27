For all distros you should follow the standard Xilinx install instructions.

# Gentoo
These instructions will be the least documented and most "kitchen-sink" since it is my primary development platform. If you 
use Gentoo I'm assuming you know what you are doing.

We need packages in the [guru](https://wiki.gentoo.org/wiki/Project:GURU/Information_for_End_Users) repo, make sure to enable that first. 

```bash
emerge sci-electronics/{iverilog,verilator,gtkwave} dev-python/bitstring
```

Digilent:

Go to the [utilities](https://digilent.com/reference/lib/exe/fetch.php?tok=358c01&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-utilities-download) site and download the "Linux 64-bit Zip" option. Then, from where you downloaded it, extract it, then run the `install.sh` script as root (after skimming the script, never run downloaded code as root without reading it).  Then do the same for the [runtime](https://digilent.com/reference/lib/exe/fetch.php?tok=f5f244&media=https%3A%2F%2Fmautic.digilentinc.com%2Fadept-runtime-download).


# Arch 

I use `yay` in arch instead of just pacman, there's support for everything we need in the AUR:
```bash
yay gtkwave iverilog verilator python-bitstring digilent.adept.utilities digilent.adept.runtime
```

You might be able to skip the cable drivers part of the xilinx install process by installing `xilinx-usb-drivers`, but I haven't tested that yet.



