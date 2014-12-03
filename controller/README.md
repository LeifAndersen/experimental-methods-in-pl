Controller
===

Scripts for running benchmarks and organizing their output.

ben-controller
---

- Accepts a list of filenames as arguments.
  - Each file must print EXACTLY one line of output: the result of calling `time`
- For each combination of:
    - JIT    + contracts
    - JIT    + no contracts
    - no JIT + contracts
    - no JIT + no contracts
- Runs each file `NSAMPLES` times and records the time taken
- Prints results of each trial + the average runtime + 95% confidence interval
