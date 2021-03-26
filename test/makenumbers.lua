#!/usr/bin/env luajit

-- use this file to generate random-numbers used for unit-tests across languages
-- run from parent dir: luajit test/makenumbers.lua

local file = io.open("test/numbers.txt", "w")
io.output(file)

math.randomseed(100)

for i=1,1000 do
  io.write(math.random(1000))
  if i ~= 1000 then
    io.write("\n")
  end
end

io.close(file)