# config/config.exs

import Config

config :aoc,
  # The prefix is used when creating solutions and test modules with
  # `mix aoc.create`.
  prefix: Aoc2024.Solutions,

  # Include help comments when generating modules and tests.
  generate_comments: true
