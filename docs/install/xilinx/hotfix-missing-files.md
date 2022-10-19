# Hotfix for fixing a Xilinx Vivado Synthesis Error.

If you did the small install you may see a long set of warnings then a DRC (design rule check) error like this after running `make main.bit`
```
WARNING: [DRC PDCN-1569] LUT equation term check: Used physical LUT pin 'A1' of cell cells_x[4].cells_y[8].CELL/rows_OBUF[7]_inst_i_3 (pin cells_x[4].cells_y[8].CELL/rows_OBUF[7]_inst_i_3/I0) is not included in the LUT equation: '64'h505F3030505F3F3F'. If this cell is a user instantiated LUT in the design, please remove connectivity to the pin or change the equation and/or INIT string of the LUT to prevent this issue. If the cell is inferred or IP created LUT, please regenerate the IP and/or resynthesize the design to attempt to correct the issue.
INFO: [Common 17-14] Message 'DRC PDCN-1569' appears 100 times and further instances of the messages will be disabled. Use the Tcl command set_msg_config to change the current settings.
INFO: [Vivado 12-3199] DRC finished with 31 Errors, 1185 Warnings
INFO: [Vivado 12-3200] Please refer to the DRC report (report_drc) for more information.
ERROR: [Vivado 12-1345] Error(s) found during DRC. Bitgen not run.
```

To fix, download this set of [extra files](https://drive.google.com/file/d/11ytM1JGgfL2beZwjEPduMD0sSurAErIZ/view?usp=sharing), move it your install location, and extract it. You should (hopefully) get a working synthesis after this!

Example:
```bash
mv ~/Downloads/extra-files.tgz /path/to/install/Vivado/2022.1/
cd /path/to/install/Vivado/2022.1/
tar -xzvf extra-files.tgz
rm extra-files.tgz
```

Long story short, Vivado is even more messed up than I thought, and they fixed an issue with long-register initialization (the initial state of the conway cells in this case) only in the folder for the `virtex` series of parts, not the `artix` series that we are using. Best thing, the error message is completely unrelated (DRC just fails) to the root cause (some files missing).