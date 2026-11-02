#!/usr/bin/env bash
set -euo pipefail

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
test_dir="$(mktemp -d)"
trap 'rm -rf "$test_dir"' EXIT

for spec in \
    'alu_tb:tb/alu_test.v' \
    'register_file_tb:register_file_test.v' \
    'control_unit_tb:tb/control_unit_test.v' \
    'instruction_memory_tb:tb/instruction_memory_test.v' \
    'data_memory_tb:tb/data_memory_test.v' \
    'program_counter_tb:tb/program_counter_test.v' \
    'processor_tb:tb/processor_test.v' \
    'board_top_tb:tb/board_top_test.v'; do
    top="${spec%%:*}"
    test_file="${spec#*:}"
    iverilog -g2012 -s "$top" -o "$test_dir/$top" \
        "$source_dir"/rtl/*.v "$source_dir/$test_file"
    vvp "$test_dir/$top"
done
