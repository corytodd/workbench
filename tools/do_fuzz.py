#!/usr/bin/env python3
import argparse
import os
import subprocess
import sys
import time
from datetime import datetime
import glob


def do_remove_old_crashes():
    # Use glob to find crash files
    crash_files = glob.glob("crash-*")
    if not crash_files:
        return
    print(f"Removing {len(crash_files)} old crash files...")
    for crash_file in crash_files:
        try:
            os.remove(crash_file)
        except Exception as e:
            print(f"Warning: Could not remove {crash_file}: {e}")


def main():
    parser = argparse.ArgumentParser(
        description="Run libFuzzer binary repeatedly and log output."
    )

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
    parser.add_argument(
        "-q",
        "--quiet",
        action="store_true",
        help="Suppress console output (only log to file)",
    )
    parser.add_argument(
        "-d",
        "--delay",
        type=int,
        default=1,
        help="Delay in seconds between iterations (default: 1)",
    )
    parser.add_argument(
        "-l",
        "--limit",
        type=int,
        help="Limit the number of iterations (default: unlimited)",
    )
    parser.add_argument(
        "--clean",
        action="store_true",
        help="Remove old crashes before starting",
    )

    args = parser.parse_args()

    if not os.path.isfile(args.fuzz_target):
        print(f"Error: Fuzz target not found: {args.fuzz_target}")
        sys.exit(1)

    fuzz_args = [args.fuzz_target]

    if args.clean:
        do_remove_old_crashes()

    if not args.no_corpus:
        fuzz_args.append(args.corpus_dir)

    if args.dict:
        fuzz_args.append(f"-dict={args.dict}")

    if not args.no_print_final_stats:
        fuzz_args.append("-print_final_stats=1")

    if args.print_full_coverage:
        fuzz_args.append("-print_full_coverage=1")

    def stop_if_limited(i):
        if args.limit is not None and i >= args.limit:
            if not args.quiet:
                print(f"\nReached iteration limit of {args.limit}. Stopping.")
            return True
        return False

    iteration = 0
    # Open log file in line-buffered mode to get real-time updates
    with open(args.log, "w", encoding="utf-8", buffering=1) as log_file:
        log_file.write(f"\n=== Fuzzing started: {datetime.now().isoformat()} ===\n")
        while not stop_if_limited(iteration):
            iteration += 1
            header = f"\n==== Fuzz Iteration {iteration} ({datetime.now().isoformat()}) ====\n"
            if not args.quiet:
                print(header.strip())
            log_file.write(header)

            try:
                _ = subprocess.run(
                    fuzz_args,
                    stdout=log_file,
                    stderr=subprocess.STDOUT,
                    text=True,
                )
            except KeyboardInterrupt:
                if not args.quiet:
                    print("\nStopped by user.")
                log_file.write("\n=== Fuzzing stopped by user ===\n")
                break
            except Exception as e:
                error_msg = f"Error running fuzzer: {e}\n"
                if not args.quiet:
                    print(error_msg.strip())
                log_file.write(error_msg)
            time.sleep(args.delay)


if __name__ == "__main__":
    main()
