#!/usr/bin/env luajit

-- unit-tests for luamaze
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
local intpointer = 0
local numbers = lines_from("test/numbers.txt")
math.random = function (lower, upper)
  intpointer = intpointer + 1
  local n = numbers[(intpointer % #numbers) + 1] / 1000
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
  aldous_broder = require("maze.generators.aldous_broder"),
  binary_tree = require("maze.generators.binary_tree"),
  eller = require("maze.generators.eller"),
  growing_tree = require("maze.generators.growing_tree"),
  hunt_and_kill = require("maze.generators.hunt_and_kill"),
  kruskal = require("maze.generators.kruskal"),
  prim = require("maze.generators.prim"),
  recursive_backtracker = require("maze.generators.recursive_backtracker"),
  recursive_division = require("maze.generators.recursive_division"),
  sidewinder = require("maze.generators.sidewinder"),
  wilson = require("maze.generators.wilson")
}

-- this should be the same every time
intpointer = 0
local maze = Maze:new(20, 20, true)
generators.prim(maze)
print(maze)
