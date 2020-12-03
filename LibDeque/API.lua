local LibDeque = LibDeque

local TYPE_MIX = LibDeque.TYPE_MIX -- mix allows to use every type
local TYPE_STRING = LibDeque.TYPE_STRING
local TYPE_NUMBER = LibDeque.TYPE_NUMBER
local TYPE_BOOLEAN = LibDeque.TYPE_BOOLEAN
local TYPE_TABLE = LibDeque.TYPE_TABLE
local TYPE_FUNCTION = LibDeque.TYPE_FUNCTION
local TYPE_USERDATA = LibDeque.TYPE_USERDATA
local TYPE_NIL = LibDeque.TYPE_NIL

local DEFAULT_FIRST = 0
local DEFAULT_LAST = -1

-- Creates a new instance of LibDeque.
-- @param addOnName - string
-- @param luaType - string (TYPE_MIX to TYPE_NIL). Choosing any luaType besides TYPE_MIX, will only allows you to use that specfic type. - (optional)
function LibDeque:New(luaType)
	if luaType then
		assert(LibDeque.TYPES[luaType], "invalid luaType")
	end

	local object = ZO_Object.New(self)
	object.first = DEFAULT_FIRST
	object.last = DEFAULT_LAST
	object.timeLastAccess = 0
	object.type = luaType or TYPE_MIX

	-- for tracking the last access time
	object.elements = { } -- create orig elements table
	local _elements = object.elements -- keep a private access to orig table
	object.elements = { } -- create proxy
	setmetatable(object.elements, -- create metatable
	{
		__index = function(t, k)
			return _elements[k]
		end,
		__newindex = function(t, k, v)
			object.timeLastAccess = GetFrameTimeMilliseconds()
			_elements[k] = v
		end,
	})

	return object
end

-- Pass LibDeque call to LibDeque:New()
-- Example: LibDeque["MyAddon"] instead of LibDeque:New["MyAddon"]
setmetatable(LibDeque, { __call = function(_, ...) return LibDeque:New(...) end } )


-- Utility functions
local function IsValidElement(self, element)
	if element == nil then
		return false
	end
	if self.type ~= TYPE_MIX and self.type ~= type(element) then
		return false
	end
	return true
end

local function IsValidType(self, luaType)
	if self.TYPES[luaType] then
		return true
	end
	return false
end

local function IsElementsEmpty(first, last)
	if first > last then
		return true
	end
	return false
end

local function IsElementInRange(self, element)
	return element >= self.first and element <= self.last
end


-----------------------------------------------------------------------------------------------
-- Try to use only these two functions for adding (PushLast) and removing (PopFirst) elements.
-----------------------------------------------------------------------------------------------

-- Adds an element to the last
function LibDeque:PushLast(element)
	if not IsValidElement(self, element) then
		return nil
	end
	local last = self.last + 1
	self.last = last
	self.elements[last] = element
end

-- Pops the first element
-- @return string|number|boolean|table|function|userdata|nil
function LibDeque:PopFirst()
	local first = self.first
	if IsElementsEmpty(first, self.last) then
		return nil
	end
	local element = self.elements[first]
	self.elements[first] = nil
	self.first = first + 1
	return element
end


-----------------------
-- Additional functions
-----------------------

-- Adds an element to the first
function LibDeque:PushFirst(element)
	if not IsValidElement(self, element) then
		return nil
	end
	local first = self.first - 1
	self.first = first
	self.elements[first] = element
end

-- Pops the last element
-- @return string|number|boolean|table|function|userdata|nil
function LibDeque:PopLast()
	local last = self.last
	if IsElementsEmpty(self.first, last) then
		return nil
	end
	local element = self.elements[last]
	self.elements[last] = nil
	self.last = last - 1
	return element
end

-- Peek the first element, without Pop it
-- @return element - string|number|boolean|table|function|userdata|nil
function LibDeque:PeekFirst()
	return self.elements[self.first]
end

-- Peek the last element, without Pop it
-- @return element - string|number|boolean|table|function|userdata|nil
function LibDeque:PeekLast()
	return self.elements[self.last]
end

-- Peek the n element, without Pop it
-- @param n - number
-- @return element - string|number|boolean|table|function|userdata|nil
function LibDeque:PeekN(n)
	n = self.first + n - 1
	return IsElementInRange(self, n) and self.elements[n] or nil
end

-- Count the existing elements
-- @return number
function LibDeque:Count()
	return self.last - self.first + 1
end

-- Check if elements are empty
-- @return boolean
function LibDeque:IsEmpty()
	return self:Count() == 0
end

-- Get the time, when Pop or Push where used the last
-- @return timeLastAccess - number in milliseconds
function LibDeque:GetTimeLastAccess()
	return self.timeLastAccess
end

-- Iterates through the elements from first-side. (First In - First Out)
-- @return element - string|number|boolean|table|function|userdata|nil
function LibDeque:Iterate()
	return function()
		return self:PopFirst()
	end
end

-- Iterates through the elements from last-side. (Last In - First Out)
-- @return element - string|number|boolean|table|function|userdata|nil
function LibDeque:IterateReverse()
	return function()
		return self:PopLast()
	end
end

-- Pop all elements from first to last (reverse == false|nil) or last to first (reverse == true).
-- @param callback - function
-- @param reverse - boolean:nilable
function LibDeque:Run(callback, reverse)
	if type(callback) == "function" then
		local iterFunc = reverse ~= nil and self.IterateReverse or self.Iterate
		for element in iterFunc(self) do
			callback(element)
		end
	end
end

-- Clears all elements and reset to default.
-- Attention: Be aware, collectGarbage can cause frame drops. Use it wisely!
-- @param collectGarbage - boolean:nilable
function LibDeque:Clear(collectGarbage)
	ZO_ClearTable(self.elements)
	self.first = DEFAULT_FIRST
	self.last = DEFAULT_LAST
	if collectGarbage then
		collectgarbage()
	end
end

-- Defines the types for the queue. Valid types are LibDeque.TYPES
-- @param state - boolean
function LibDeque:SetType(luaType)
	if IsValidType(self, luaType) then
		self.type = luaType
	end
end
