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

local function Lexer()
	local XLexer = {
		lexer = function (self, program)
			local makeChars = MakeChars()
			local charGroups = CharGroups()

			local tokens = {}
			makeChars:makechars(program)

			local counter = 0
			local programLength = makeChars:programLength()

			while(counter <= programLength) do
				::CONTINUE::
				local currentChar = makeChars:getChar()
				counter = counter + 1

				if(charGroups:isSpaceNewLine(currentChar)) then goto CONTINUE end
				if((currentChar == "=") and (makeChars:nextChar() == "=")) then
					makeChars:getChar()
					counter = counter + 1

					local token = {type = "Equals", value = "=="}
					push(tokens, token)
					goto CONTINUE
				end
				if(charGroups:isOperator(currentChar)) then
					if(currentChar == "&") then
						local nextChar = makeChars:nextChar()
						if(nextChar == "&") then
							makeChars:getChar()
							counter = counter + 1
							local token = {type = "Operator", value = "&&"}
							push(tokens, token)
							goto CONTINUE
						end
					end
				end
				if(charGroups:isOperator(currentChar)) then
					if(currentChar == "|") then
						local nextChar = makeChars:nextChar()
						if(nextChar == "|") then
							makeChars:getChar()
							counter = counter + 1
							local token = {type = "Operator", value = "||"}
							push(tokens, token)
							goto CONTINUE
						end
					end
				end
				if(charGroups:isOperator(currentChar)) then
					local token = {type = "Operator", value = currentChar}
					push(tokens, token)
					goto CONTINUE
				end
				if(charGroups:isQuote(currentChar)) then
					local string = ""
					local delimiter = currentChar
					currentChar = makeChars:getChar()
					counter = counter + 1
					while(currentChar ~= delimiter) do
						string = string .. currentChar
						currentChar = makeChars:getChar()
						counter = counter + 1
					end
					local token = {type = "String", value = string}
					push(tokens, token)
					goto CONTINUE
				end
				if(charGroups:isSpecialCharachter(currentChar)) then
					local token = {type = "specialCharachter", value = currentChar}
					push(tokens, token)
					goto CONTINUE
				end
				if(charGroups:isAlpha(currentChar))	then
					local symbol = ""
					symbol = symbol .. currentChar
					currentChar = makeChars:getChar()
					counter = counter + 1
					while(charGroups:isAlpha(currentChar)) do
						symbol = symbol .. currentChar
						currentChar = makeChars:getChar()
						counter = counter + 1
					end
					makeChars:putChar(currentChar)
					counter = counter - 1
					local token = {type = "Symbol", value = symbol}
					push(tokens, token)
					goto CONTINUE
				end
				if(charGroups:isDigit(currentChar)) then
					local number = ""
					number = number .. currentChar
					currentChar = makeChars:getChar()
					counter = counter + 1
					while(charGroups:isDigit(currentChar) or (currentChar == ".")) do
						number = number .. currentChar
						currentChar = makeChars:getChar()
						counter = counter + 1
					end
					makeChars:putChar(currentChar)
					counter = counter - 1
					local token = {type = "Number", value = number}
					push(tokens, token)
					goto CONTINUE
				end
			end
			return tokens
		end
	}
	return XLexer
end

local function ParseHelpers()
	local pp = {}
	local XParseHelpers = {
		makeTokens = function (self, tokens)
			pp.tokens = tokens
			pp.tokensLength = #tokens
		end,
		tokensLength = function (self)
			return pp.tokensLength
		end,
		getToken = function (self)
			local tokens = pp.tokens
			local currentToken = shift(tokens)
			pp.tokens = tokens
			pp.tokensLength = #tokens
			return currentToken
		end,
		nextToken = function (self)
			local tokens = pp.tokens
			return tokens[1]
		end,
		putToken = function (self, token)
			local tokens = pp.tokens
			unshift(tokens, token)
			pp.tokens = tokens
			pp.tokensLength = #tokens
		end
	}
	return XParseHelpers
end

local function FunctionBody(fields)
	local pp = {}
	local XFunctionBody = {
		tokens = fields.tokens,
		makeBlockTokens = function (self, tokens)
			pp.blockTokens = tokens
			pp.blockTokensLength = #tokens
		end,
		blockTokensLength = function (self)
			return pp.blockTokensLength
		end,
		getBlockToken = function (self)
			local tokens = pp.blockTokens
			local currentToken = shift(tokens)
			pp.blockTokens = tokens
			pp.blockTokensLength = #tokens
			return currentToken
		end,
		nextBlockToken = function (self)
			local tokens = pp.blockTokens
			return tokens[1]
		end,
		putBlockToken = function (self, token)
			local tokens = pp.blockTokens
			unshift(tokens, token)
			pp.blockTokens = tokens
			pp.blockTokensLength = #tokens
		end,
		functionBody = function (self)
			self.makeBlockTokens(self.tokens)
			local blockTokensLength = self.blockTokensLength()
			local counter = 0
			while(counter <= blockTokensLength) do
				local token = self.getBlockToken()
				counter = counter + 1
				if(token.value == "if") then
					token = self.getBlockToken()
					counter = counter + 1
					local expr = {}
					local exprToken = {value = "_"}
					while(exprToken.value ~= ")") do
						exprToken = self.getBlockToken()
						counter = counter + 1
						if(exprToken.value ~= ")") then
							push(expr, exprToken.value)
						end
					end
					local IfExpr = expr
					local ifBody = {}
					local ifBeginToken = self.getBlockToken()
					counter = counter + 1
					local ifBraceCounter = 1
					while(ifBraceCounter > 0) do
						local tok = self.getBlockToken()
						counter = counter + 1
						if(tok.value == "{") then
							ifBraceCounter = ifBraceCounter + 1
						elseif (tok.value == "}") then
							ifBraceCounter = ifBraceCounter - 1
						elseif ifBraceCounter > 0 then
							push(ifBody, tok)
						else 
							ifBraceCounter = ifBraceCounter - 1
						end
					end
				end
				if(token.value == "while") then
					token = self.getBlockToken()
					counter = counter + 1
					local expr
					local exprToken = {value = "_"}
					while(exprToken.value == ")") do
						exprToken = self.getBlockToken()
						counter = counter + 1
						if(exprToken.value ~= ")") then
							push(expr, exprToken.value)
						end
					end
					local WhileExpr = expr
					local whileBody = {}
					local whileBeginToken = self.getBlockToken()
					counter = counter + 1
					local whileBraceCounter = 0
					if(whileBeginToken.value == "{") then
						whileBraceCounter = whileBraceCounter + 1
						local tok = self.getBlockToken()
						counter = counter + 1
						if(tok.value == "{") then
							whileBraceCounter = whileBraceCounter + 1
						elseif(tok.value == "}") then
							whileBraceCounter = whileBraceCounter - 1
						elseif (whileBraceCounter > 0) then
							push(whileBody, tok)
						else
						end
					end
				end
			end
			return {body = "FunctionBody"}
		end
	}
	return XFunctionBody
end

local function Main(fields)
	local parseTree = {}
	local XMain = {
		main = function (self, program)
			local parseHelpers = ParseHelpers()
			local lexer = Lexer()
			local tokens = lexer:lexer(program)
			parseHelpers:makeTokens(tokens)
			local tokensLength = parseHelpers:tokensLength()
			local counter = 0
			local xfunction = {}	-- funciton hash is changed to xfunction
			while(counter <= tokensLength) do
				local token = parseHelpers:getToken()
				counter = counter + 1
				if(token.value == "func") then
					token = parseHelpers:getToken()
					counter = counter + 1
					local functionName = token.value
					parseHelpers:getToken()
					counter = counter + 1
					local args
					local argToken = {value = "_"}
					while(argToken.value ~= ")") do
						argToken = parseHelpers:getToken()
						counter = counter + 1
						if( (argToken.value ~= ")") and (argToken.value ~= ",")) then
							push(args, argToken.value)
						end
					end
					local functionArgs = args
					local functionBody = {}

					local bodyBeginToken = parseHelpers:getToken()
					counter = counter + 1
					if(bodyBeginToken.value == "{") then
						local untilCounter = 0
						while(untilCounter ~= 1) do
							local bodyToken = parseHelpers:getToken()
							counter = counter + 1
							local bodyNextToken = parseHelpers:nextToken()
							if(bodyToken.value == "}" or (bodyNextToken.value == "func" or counter == tokensLength + 1)) then
								untilCounter = 1
							else
								push(functionBody, bodyToken)
							end
						end
					end
					local functionBodyObject = FunctionBody({tokens = functionBody})
					xfunction = {
						xfunctionName = functionName,
						xfunctionArgs = functionArgs,
						xfunctionBody = functionBodyObject:functionBody()
					}
					self.parseTree.functionName = xfunction
					xfunction = {}
				end
 			end
		end
	}
	return XMain
end

local program = [[
func anotherPrint(arg){
	if(x > 23){
		print(arg, "\n");
	}
}
func main(){
	var sum = 12 + 14;
	while(sum < 23){
		print("Sum is ", sum);
	}
}
]]

local mainObject = Main()
mainObject:main(program)

--local mc = MakeChars()
--mc:makechars("HELLO WORLD")
--print(mc:programLength())

