#!/usr/bin/env lua

-- This is a CLI-example of generating mazes in utf8 braille characters
-- run with lua 5.3

-- lua doesn't have a built-in way to require a rtelative file...
local requireRel
if arg and arg[0] then
    package.path = arg[0]:match("(.-)[^\\/]+$") .. "?.lua;" .. package.path
    requireRel = require
elseif ... then
    local d = (...):match("(.-)[^%.]+$")
    function requireRel(module) return require(d .. module) end
end

-- output a maze as braille characters
-- based on ideas from drawille: https://github.com/asciimoo/drawille

--[[
http://www.alanwood.net/unicode/braille_patterns.html
dots:
   ,___,
   |1 4|
   |2 5|
   |3 6|
   |7 8|
   '''''

or in binary-flags:

{0x01, 0x08},
{0x02, 0x10},
{0x04, 0x20},
{0x40, 0x80}

so in order to get walls, it's 2 chars per grid-square

N + S:
   ,___,   ,___,
   |1 4|   |1 4|
   |   |   |   |
   |   |   |   |
   |7 8|   |7 8|
   '''''   '''''

add 0x2800 (braille base) like this:

NE is
0x2800 + 0x01 + 0x08
0x2800 + 0x01 + 0x08 + 0x10 + 0x20 + 0x80

⠉⢹

]]

function setbits(x, pa)
  for _,p in pairs(pa) do
    local hasbit = x % (p + p) >= p
    x = hasbit and x or x + p
  end
  return x
end

-- convert maze into braille string
function braille(maze)
  local out = ""
  for yi = 1, #maze do
    for xi = 1, #maze[1] do
      local block = { 0, 0 }
      if maze[yi][xi].north:IsClosed() then
        block[1] = setbits(block[1], {0x01, 0x08})
        block[2] = setbits(block[2], {0x01, 0x08})
      end
      if  maze[yi][xi].south:IsClosed() then
        block[1] = setbits(block[1], {0x40, 0x80})
        block[2] = setbits(block[2], {0x40, 0x80})
      end
      if maze[yi][xi].east:IsClosed() then
        block[2] = setbits(block[2], { 0x08, 0x10, 0x20, 0x80})
      end
      if maze[yi][xi].west:IsClosed() then
        block[1] = setbits(block[1], { 0x01, 0x02, 0x04, 0x40})
      end
      -- requires lua 5.3
      out = out .. utf8.char(block[1]+0x2800, block[2]+0x2800)
    end
    out = out .. "\n"
  end
  return out
end

-- get CLI args
local width = arg[1] or 10
local height = arg[2] or 10
local algo = arg[3] or "recursive_backtracker"

-- this loads the whole thing, but you could load just the generator you want
-- and maze with maze.maze and maze.generators.ALGO
local Maze = requireRel('maze.init')

local maze = Maze:new(width, height, true)

-- maek sure random is more random
math.randomseed(os.time())

-- call the selected generator on the maze
Maze.generators[algo](maze)

print(braille(maze))

