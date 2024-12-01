# Set AOC environment
set dotenv-load

# List available commands
default:
    @just --list

# Open puzzle in browser
open *args='':
    #!/usr/bin/env bash
    HOME=$PWD mix aoc.open {{args}}

# Create new puzzle files
create *args='':
    #!/usr/bin/env bash
    HOME=$PWD mix aoc.create {{args}}

# Run tests for puzzle
test *args='':
    #!/usr/bin/env bash
    HOME=$PWD mix aoc.test {{args}}

# Run solution
run *args='':
    #!/usr/bin/env bash
    HOME=$PWD mix aoc.run {{args}}

# Fetch puzzle input
fetch *args='':
    #!/usr/bin/env bash
    HOME=$PWD mix aoc.fetch {{args}}

# Get puzzle URL
url *args='':
    #!/usr/bin/env bash
    HOME=$PWD mix aoc.url {{args}}

# Set default year/day
set-default *args='':
    #!/usr/bin/env bash
    HOME=$PWD mix aoc.set {{args}}
