#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
import time
from datetime import datetime


def main():
    parser = argparse.ArgumentParser(description="Run libFuzzer binary repeatedly and log output.")

    parser.add_argument(
        "fuzz_target",
        help="Path to the fuzzing executable (e.g., ./fuzz_target or fuzz_target.exe)",
    )
    parser.add_argument(
        "--no-corpus",
        action="store_true",
        help="Disable passing the corpus directory",
    )
    parser.add_argument(
        "--corpus-dir",
        default="corpus",
        help="Path to the corpus directory (default: ./corpus)",
    )
    parser.add_argument(
        "--dict",
        help="Optional path to a dictionary file",
    )
    parser.add_argument(
        "--no-print-final-stats",
        action="store_true",
        help="Do not pass -print_final_stats=1",
    )
    parser.add_argument(
        "--print-full-coverage",
        action="store_true",
        help="Pass -print_full_coverage=1",
    )
    parser.add_argument(
        "--log",
        default="fuzz_log.txt",
        help="Path to a file to write all output (default: fuzz_log.txt)",
    )

    args = parser.parse_args()

    if not os.path.isfile(args.fuzz_target):
        print(f"Error: Fuzz target not found: {args.fuzz_target}")
        sys.exit(1)

    fuzz_args = [args.fuzz_target]

    if not args.no_corpus:
        fuzz_args.append(args.corpus_dir)

    if args.dict:
        fuzz_args.append(f"-dict={args.dict}")

    if not args.no_print_final_stats:
        fuzz_args.append("-print_final_stats=1")

    if args.print_full_coverage:
        fuzz_args.append("-print_full_coverage=1")

    iteration = 0
    with open(args.log, "a", encoding="utf-8") as log_file:
        log_file.write(f"\n=== Fuzzing started: {datetime.now().isoformat()} ===\n")
        while True:
            iteration += 1
            header = f"\n==== Fuzz Iteration {iteration} ({datetime.now().isoformat()}) ====\n"
            print(header.strip())
            log_file.write(header)
            log_file.flush()

            try:
                _ = subprocess.run(
                    fuzz_args,
                    stdout=log_file,
                    stderr=subprocess.STDOUT,
                    text=True,
                )
            except KeyboardInterrupt:
                print("\nStopped by user.")
                log_file.write("\n=== Fuzzing stopped by user ===\n")
                break
            except Exception as e:
                error_msg = f"Error running fuzzer: {e}\n"
                print(error_msg.strip())
                log_file.write(error_msg)
                log_file.flush()
            time.sleep(1)


if __name__ == "__main__":
    main()
