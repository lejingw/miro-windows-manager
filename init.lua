-- Copyright (c) 2018 Miro Mannino
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge,
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.

-- === MiroWindowsManager ===
-- With this script you will be able to move the window in halves and in corners using your keyboard and mainly using arrows. You would also be able to resize them by thirds, quarters, or halves.
-- Official homepage for more info and documentation: [https://github.com/miromannino/miro-windows-manager](https://github.com/miromannino/miro-windows-manager)
-- Download: [https://github.com/miromannino/miro-windows-manager/raw/master/MiroWindowsManager.spoon.zip](https://github.com/miromannino/miro-windows-manager/raw/master/MiroWindowsManager.spoon.zip)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "MiroWindowsManager"
obj.version = "1.1"
obj.author = "Miro Mannino <miro.mannino@gmail.com>"
obj.homepage = "https://github.com/miromannino/miro-windows-management"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- Size:`{2, 3, 3/2}` means that it can be 1/2, 1/3 and 2/3 of the total screen's size
obj.withSizes = {3, 2, 3/2, 4}
obj.hightSizes = {2, 1}
obj.centerScreenSizes = {3, 2, 4/3}

-- The screen's size using `hs.grid.setGrid()`, which is used at the spoon's `:init()`
obj.GRID = {w = 12, h = 12}

obj._pressed = {
  up = false,
  down = false,
  left = false,
  right = false
}

function obj:_nextStep(dim, offs, cb)
  if hs.window.focusedWindow() then
    local dimSizes = dim == 'w' and self.withSizes or self.hightSizes
    local axis = dim == 'w' and 'x' or 'y'
    local win = hs.window.frontmostWindow()
    local screen = win:screen()
    local cell = hs.grid.get(win, screen)

    local nextSize = -1
    for i=1,#dimSizes do
      if cell[dim] == self.GRID[dim] / dimSizes[i] and (cell[axis] + (offs and cell[dim] or 0)) == (offs and self.GRID[dim] or 0) then
          nextSize = dimSizes[(i % #dimSizes) + 1]
        break
      end
    end

    if nextSize == -1 and (cell[axis] + (offs and cell[dim] or 0)) == (offs and self.GRID[dim] or 0) then 
      print('reset size when exceeded edge')
      nextSize = dimSizes[1]
    end

    if nextSize ~= -1 then
      print("current grid geo x:" .. cell.x .. " y:" .. cell.y .. " w:" .. cell.w .. " h:" .. cell.h .. " nextSize:" .. nextSize)
      cb(cell, nextSize)
    else
      local direct = dim == 'w' and (offs and 'right' or 'left') or (offs and 'down' or 'up')
      print("current grid geo x:" .. cell.x .. " y:" .. cell.y .. " w:" .. cell.w .. " h:" .. cell.h .. " move " .. direct .. "(without change size)");
      cell[axis] = cell[axis] + cell[dim] * (offs and 1 or -1)
    end

    -- local oppDim = dim == 'w' and 'h' or 'w'
    -- local oppAxis = dim == 'w' and 'y' or 'x'
    -- if cell[oppAxis] ~= 0 and cell[oppAxis] + cell[oppDim] ~= self.GRID[oppDim] then
    --   cell[oppDim] = self.GRID[oppDim]
    --   cell[oppAxis] = 0
    -- end

    hs.grid.set(win, cell, screen)
  end
end

function obj:_nextCenterScreenStep()
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local screen = win:screen()

    cell = hs.grid.get(win, screen)

    local nextSize = self.centerScreenSizes[1]
    for i=1,#self.centerScreenSizes do
      if cell.w == self.GRID.w / self.centerScreenSizes[i] and cell.x == (self.GRID.w - self.GRID.w / self.centerScreenSizes[i]) / 2 then
        nextSize = self.centerScreenSizes[(i % #self.centerScreenSizes) + 1]
        break
      end
    end

    cell.w = self.GRID.w / nextSize
    cell.h = self.GRID.h
    cell.x = (self.GRID.w - self.GRID.w / nextSize) / 2
    cell.y = 0

    hs.grid.set(win, cell, screen)
  end
end

function obj:_fullDimension(dim)
  if hs.window.focusedWindow() then
    local win = hs.window.frontmostWindow()
    local screen = win:screen()
    cell = hs.grid.get(win, screen)

    if (dim == 'x') then
      cell = '0,0 ' .. self.GRID.w .. 'x' .. self.GRID.h
    else  
      cell[dim] = self.GRID[dim]
      cell[dim == 'w' and 'x' or 'y'] = 0
    end

    hs.grid.set(win, cell, screen)
  end
end

-- Binds hotkeys for Miro's Windows Manager, keys:
-- f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19, f20,
-- pad, pad*, pad+, pad/, pad-, pad=, pad0, pad1, pad2, pad3, pad4, pad5, pad6, pad7, pad8, pad9, padclear, padenter,
-- return, tab, space, delete, escape, help, home, pageup, forwarddelete, end, pagedown, left, right, down, up,
-- shift, rightshift, cmd, rightcmd, alt, rightalt, ctrl, rightctrl, capslock, fn
--
-- local hyper = {"ctrl", "alt", "cmd"}
-- spoon.MiroWindowsManager:bindHotkeys({
--   up = {hyper, "up"},
--   right = {hyper, "right"},
--   down = {hyper, "down"},
--   left = {hyper, "left"},
--   center = {hyper, "pad5"}
-- })
-- ```
function obj:bindHotkeys(mapping)
  hs.inspect(mapping)
  print("Bind Hotkeys for Miro's Windows Manager")

  hs.hotkey.bind(mapping.down[1], mapping.down[2], function ()
    self._pressed.down = true
    if self._pressed.up then 
      self:_fullDimension('h')
    else
      self:_nextStep('h', true, function (cell, nextSize)
        cell.y = self.GRID.h - self.GRID.h / nextSize
        cell.h = self.GRID.h / nextSize
      end)
    end
  end, function () 
    self._pressed.down = false
  end)

  hs.hotkey.bind(mapping.right[1], mapping.right[2], function ()
    self._pressed.right = true
    if self._pressed.left then 
      self:_fullDimension('w')
    else
      self:_nextStep('w', true, function (cell, nextSize)
        cell.x = self.GRID.w - self.GRID.w / nextSize
        cell.w = self.GRID.w / nextSize
      end)
    end
  end, function () 
    self._pressed.right = false
  end)

  hs.hotkey.bind(mapping.left[1], mapping.left[2], function ()
    self._pressed.left = true
    if self._pressed.right then 
      self:_fullDimension('w')
    else
      self:_nextStep('w', false, function (cell, nextSize)
        cell.x = 0
        cell.w = self.GRID.w / nextSize
      end)
    end
  end, function () 
    self._pressed.left = false
  end)

  hs.hotkey.bind(mapping.up[1], mapping.up[2], function ()
    self._pressed.up = true
    if self._pressed.down then 
        self:_fullDimension('h')
    else
      self:_nextStep('h', false, function (cell, nextSize)
        cell.y = 0
        cell.h = self.GRID.h / nextSize
      end)
    end
  end, function () 
    self._pressed.up = false
  end)

  hs.hotkey.bind(mapping.center[1], mapping.center[2], function ()
    self:_nextCenterScreenStep()
  end)

end

function obj:init()
  print("Initializing Miro's Windows Manager")
  hs.grid.setGrid(obj.GRID.w .. 'x' .. obj.GRID.h)
  hs.grid.MARGINX = 0
  hs.grid.MARGINY = 0
end

return obj
