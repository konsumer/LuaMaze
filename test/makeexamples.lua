#!/usr/bin/env luajit

-- this generates text-examples used in unit-tests
-- run from parent dir: luajit test/test.lua

-- get all lines from a file
function lines_from(file)
  local lines = {}
  for line in io.lines(file) do 
    lines[#lines + 1] = line
  end
  return lines
end

-- monkey-patch random() to provide known-numbers (that can be used in other languages)
local rndpointer = 0
local numbers = lines_from("test/numbers.txt")
math.random = function (lower, upper)
  rndpointer = rndpointer + 1
  local n = numbers[(rndpointer % #numbers) + 1] / 1000
  if lower == nil and upper == nil then
    return n
  end
  if upper == nil then
    upper = lower
    lower = 0
  end
  return math.ceil((n * (upper-lower)) + lower)
end

package.path = "source/?.lua;" .. package.path
local Maze = require('maze.maze')
local generators = {
  -- these run indefinitely, for some reason
  -- aldous_broder = require("maze.generators.aldous_broder"),
  -- wilson = require("maze.generators.wilson"),

  binary_tree = require("maze.generators.binary_tree"),
  eller = require("maze.generators.eller"),
  growing_tree = require("maze.generators.growing_tree"),
  hunt_and_kill = require("maze.generators.hunt_and_kill"),
  kruskal = require("maze.generators.kruskal"),
  prim = require("maze.generators.prim"),
  recursive_backtracker = require("maze.generators.recursive_backtracker"),
  recursive_division = require("maze.generators.recursive_division"),
  sidewinder = require("maze.generators.sidewinder")
}

for a,g in pairs(generators) do
  local out = io.open("test/examples/" .. a .. ".txt", "w")
  rndpointer = 0
  local maze = Maze:new(20, 20, true)
  generators[a](maze)
  out:write(tostring(maze))
end