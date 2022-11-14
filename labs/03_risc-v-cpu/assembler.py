#!/usr/bin/env python3

# Heavily based on this [reference card](http://csci206sp2020.courses.bucknell.edu/files/2020/01/riscv-card.pdf)
# and the official [spec](https://github.com/riscv/riscv-isa-manual/releases/download/Ratified-IMAFDQC/riscv-spec-20191213.pdf)

"""
Psuedo-instructions to eventually support:
    - j label -> jal x0, label    
"""

import argparse
import os
import os.path as path
import re
import sys

import rv32i


class AssemblyProgram:
    def __init__(self, start_address=0, labels=None):
        self.address = start_address
        self.line_number = 0
        self.labels = {}
        if labels:
            for k in labels:
                self.labels[k] = labels[k]
        self.parsed_lines = []

    def parse_line(self, line):
        self.line_number += 1
        parsed = {}
        line = line.strip()
        parsed["original"] = line
        line = re.sub("\s*#.*", "", line)  # Remove comments.
        match = re.search("^(\w+):", line)
        if match:
            self.labels[match.group(1)] = self.address
            line = re.sub("^(\w+):\s*", "", line)
            parsed["label"] = match.group(1)
        match = re.search("^(\w+)\s*(.*)", line)
        if not match:
            return -1
        parsed["line_number"] = self.line_number
        parsed["instruction"] = match.group(1)
        parsed["args"] = [x.strip() for x in match.group(2).split(",")]
        self.address += 4
        self.parsed_lines.append(parsed)
        return 0

    def write_mem(self, fn, hex_notbin=True):
        output = []
        address = 0
        for line in self.parsed_lines:
            if line["instruction"] == "nop":
                # Psuedo-instruction. nop is add 0 to 0 into 0 by spec:
                line["instruction"] = "addi"
                line["args"] = ["x0", "x0", "0"]
            if line["instruction"] == "j":
                # Psuedo-instruction. equivalent to: jal x0, label
                line["instruction"] = "jal"
                line["args"].insert(0, "x0")
            try:
                bits = rv32i.line_to_bits(
                    line, labels=self.labels, address=address
                )
            except rv32i.LineException as e:
                print(
                    f"Error on line {line['line_number']} ({line['instruction']})"
                )
                print(f"  {e}")
                print(f"  original line: {line['original']}")
                return -1
            except Exception as e:
                print(f"Unhandled error, possible bug in assembler!!!")
                print(
                    f"Error on line {line['line_number']} ({line['instruction']})"
                )
                print(f"  {e}")
                print(f"  original line: {line['original']}")
                raise e
            address += 4
            output.append(bits)
        # Only write the file if the above completes without errors
        with open(fn, "w") as f:
            for bits in output:
                if hex_notbin:
                    f.write(bits.hex + "\n")
                else:
                    f.write(bits.bin + "\n")
        return 0


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "input", help="input file name of human readable assembly"
    )
    parser.add_argument(
        "-o",
        "--output",
        help="output file name of hex values in text that can be read from SystemVerilog's readmemh",
    )
    parser.add_argument(
        "-v",
        "--verbose",
        action="store_true",
        help="increases verbosity of the script",
    )
    args = parser.parse_args()
    if not path.exists(args.input):
        raise Exception(f"input file {args.input} does not exist.")
    ap = AssemblyProgram()
    with open(args.input, "r") as f:
        for line in f:
            ap.parse_line(line)
    if args.verbose:
        print(f"Parsed {len(ap.parsed_lines)} instructions. Label table:")
        print(
            "  " + ",\n  ".join([f"{k} -> {ap.labels[k]}" for k in ap.labels])
        )
    if args.output:
        sys.exit(
            ap.write_mem(args.output, hex_notbin=not "memb" in args.output)
        )
    sys.exit(0)


if __name__ == "__main__":
    main()
