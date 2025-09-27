local function split(Xstring)
	local arr = {}
	for i = 1, string.len(Xstring) do
		table.insert(arr, string.sub(Xstring, i, i))
	end
	return arr
end

local function join(array)
	local Xstring = ""
	for index, char in ipairs(array) do
		Xstring = Xstring .. char
	end
	return Xstring
end

local function push(xtable, elem)
	table.insert(xtable, elem)
end

local function pop(xtable)
	local removedElement = table.remove(xtable)
	return removedElement
end

local function unshift(xtable, elem)
	table.insert(xtable, 1, elem)
end

local function shift(xtable)
	local removedElement = table.remove(xtable, 1)
	return removedElement
end

local function exists(tbl, elem)
    for _, v in pairs(tbl) do
        if v == elem then
            return true
        end
    end
    return false
end

local function MakeChars() 
	local pp = {}
	local XMakeChars = {
		makechars = function (self, program)
			local chars = split(program)
			pp.chars = chars
			pp.charsLength = #chars
		end,
		programLength = function (self)
			return pp.charsLength
		end,
		getChar = function (self)
			local chars = pp.chars
			local char = shift(chars)
			pp.chars = chars
			pp.charsLength = #chars
			return char
		end,
		nextChar = function (self)
			local chars = pp.chars
			return chars[1]
		end,
		putChar = function (self, char)
			local chars = pp.chars
			unshift(chars, char)
			pp.chars = chars
			pp.charsLength = chars
		end
	}
	return XMakeChars
end

local function CharGroups()
	local XCharGroups = {
		isSpaceNewLine = function (self, char)
			local spaceNewLine = {" ", '\n', "\t", "\r"}
			if(exists(spaceNewLine, char)) then
				return 1
			end 
			return 0
		end,
		isDigit = function (self, char)
			local digits = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
			for index, value in ipairs(digits) do
				if(char == value) then
					return 1
				end
			end
			return 0
		end,
		isAlpha = function (self, char)
			local alpha = {}
			local al = {'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'}
			if(exists(al, char)) then
				return 1
			end			
			return 0
		end,
		isQuote = function (self, char)
			if(char == '"') then
				return 1
			end
			return 0
		end,
		isSpecialCharachter = function (self, char) 
			local specialCharachters = {"{", "}", "[", "]", ",", ":", "(", ")", ";", "=", "."}
			if(exists(specialCharachters, char)) then
				return 1
			end
			return 0
		end,
		isOperator = function (self, char)
			local operators = {"+", "-", "|", "*", "/", ">", "<", "!", "&", "%"}
			if(exists(operators, char)) then
				return 1
			end
			return 0
		end
	}
	return XCharGroups
end

local mc = MakeChars()

mc:makechars("HELLO WORLD")
print(mc:programLength())

