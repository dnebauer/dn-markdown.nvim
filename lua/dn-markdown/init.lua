-- DOCUMENTATION

---@brief [[
---*dn-markdown-nvim.txt*  For Neovim version 0.9  Last change: 2024 January 15
---@brief ]]

---@toc dn_markdown.contents

---@mod dn_markdown.intro Introduction
---@brief [[
---An auxiliary filetype plugin for the markdown language.
---
---The plugin author uses the |vim-pandoc| plugin and pander
---(https://github.com/dnebauer/pander) for markdown support. This ftplugin
---is intended to address gaps in markdown support provided by those tools.
---@brief ]]

---@mod dn_markdown.depend Dependencies
---@brief [[
---Pandoc is used to generate output. It is not provided by this ftplugin,
---which depends on the |vim-pandoc| plugin and assumes pander
---(https://github.com/dnebauer/pander) is installed.
---
---This ftplugin also depends on the dn-utils plugin
---(https://github.com/dnebauer/dn-utils.nvim).
---@brief ]]

---@mod dn_markdown.features Features
---@brief [[
---The major features of this ftplugin are support for yaml metadata blocks,
---adding figures, cleaning up output file and directories, and altering the
---pandoc command line arguments.
---
---Metadata ~
---
---Pandoc-flavoured markdown uses a yaml-style metadata block at the top of
---the file to specify values used by pandoc for document processing. With
---pander (https://github.com/dnebauer/pander) installed the metadata block
---can also specify pander style keywords which, in turn, specify metadata
---values and command-line options used by pandoc for document processing.
---
---This ftplugin assumes the following default yaml-metadata block is used
---at the top of documents:
--->
---    ---
---    title:  "[][source]"
---    author: "[][author]"
---    date:   ""
---    style:  [Standard, Latex14pt]
---            # Latex8-12|14|17|20pt; SectNewpage; PageBreak; Include
---    ---
---<
---The reference-style links are defined at the end of the document. The
---default boilerplate for this is:
--->
---    [comment]: # (URLs)
---
---       [author]:
---
---       [source]:
---<
---The default metadata block and reference link definitions are added to a
---document by the function |dn_markdown.add_boilerplate|, which can be
---called using the command |dn_markdown.MUAddBoilerplate| and mappings
---|dn_markdown.<Leader>ab|.
---
---Images ~
---
---A helper function, mapping and command are provided to assist with adding
---figures. They assume the images are defined using reference links with
---optional attributes, and that all reference links are added to the end of
---the document prefixed with three spaces. For example:
--->
---    [@Fig:display] and [@fig:packed] display the tuck boxes.
---
---    ![Tuck boxes displayed][display]
---
---    ![Tuck boxes packed away][packed]
---
---    [comment]: # (URLs)
---
---       [display]: resources/displayed.png "Tuck boxes displayed"
---       {#fig:display .class width="50%"}
---
---       [packed]: resources/packed.png "Tuck boxes packed away"
---       {#fig:packed .class width="50%"}
---<
---The syntax used is that expected by the pandoc-crossref filter
---(https://github.com/lierdakil/pandoc-crossref). A figure is inserted on
---the following line using the markdown.insert_figure| function, which can
---be called using the command |dn_markdown.MUInsertFigure| and mapping
---|dn_markdown.<Leader>fig|.
---
---Tables ~
---
---A helper function, mapping and command are provided to assist with adding
---tables. More specifically, they aid with adding the caption and id
---definition following the table. The syntax used is that expected by the
---pandoc-crossref filter (https://github.com/lierdakil/pandoc-crossref). In
---this example:
--->
---    [@Tbl:simple] is a simple table.
---
---    A B
---    - -
---    0 1
---
---    Table: A simple table. {#tbl:simple}
---<
---the definition is "Table: A simple table. {#tbl:simple}". (Strictly
---speaking, the filter expects the caption line to start with a colon, but
---it is possible to precede the colon with the word "Table" and this better
---conveys the line's meaning to the reader.)
---
---The definition is inserted on the following line using the
---|dn_markdown.insert_table_definition| function, which can be called using
---the command |dn_markdown.MUInsertTable| and mapping
---|dn_markdown.<Leader>tbl|.
---
---Include Files ~
---
---A helper function, mapping and command are provided to assist with
---including external markdown files, or subdocuments, in the current
---document. More specifically, an "include" directive is inserted. The
---markdown file specified in the directive is included in the output file.
---
---The include directive is processed by the "include-files" lua filter which
---is available from the pandoc/lua-filters github repository
---(https://github.com/pandoc/lua-filters).
---
---The include directive has the format:
--->
---    ```{.include}
---    file_1.md
---    ```
---<
---or:
--->
---    ```{.include shift-heading-level-by=X}
---    file_1.md
---    ```
---<
---depending on whether a heading shift value is specified.
---
---The default behaviour of the "include-files" lua filter is to include
---subdocuments unchanged. If a "shift-heading-level-by" value is specified,
---all headings in subdocuments are "shifted" to lesser heading levels by the
---number of steps specified. For example, a value of 2 would result in
---top-level headers in subdocuments becoming third-level headers, with other
---header levels shifted accordingly.
---
---If the "automatic shifting" feature of the plugin is enabled (by using the
---metadata flag "include-auto") the "shift-heading-level-by" option behaves
---differently. See
---https://github.com/pandoc/lua-filters/tree/master/include-files for more
---details.
---
---The "include" directive is inserted on the following line using the
---|dn_markdown.insert_files| function, which can be called using the command
---|dn_markdown.MUInsertFiles| and mapping |dn_markdown.<Leader>fil|.
---
---Output ~
---
---This ftplugin leaves the bulk of output generation to the |vim-pandoc|
---plugin.
---
---This ftplugin provides a mapping, command and function for deleting
---output files and temporary output directories. The term "clean" is used,
---as in the makefile keyword that deletes all working and output files.
---
---Cleaning of output only occurs if the specified buffers are associated
---with a file and have a markdown filetype - either "markdown", "pandoc",
---and "markdown.pandoc". For a given buffer the directory searched for
---items to delete is the directory in which the file in the current buffer
---is located.
---
---If the file being edited is "FILE.ext", the files that will be deleted
---have names like "FILE.html" and "FILE.pdf" (see function
---|dn_markdown.clean_buffer| for a complete list). The temporary output
---subdirectory ".tmp" will also be recursively force-deleted.
---
---Warning: this ftplugin does not check that it is safe to delete files and
---directories identified for deletion. For example, it does not check
---whether any of them are symlinks to other locations. Also be aware that
---directories are forcibly and recursively deleted, as with the *nix shell
---command "rm -fr".
---
---When a markdown buffer is closed (actually when the |BufDelete| event
---occurs), this ftplugin checks for output files/directories and, if any
---are found, asks the user whether to delete them. If the user confirms
---deletion they are removed. When vim exits (actually, when the
---|VimLeavePre| event occurs) this ftplugin looks for any markdown buffers
---and looks in their respective directories for output files/directories
---and, if any are found, asks the user whether to delete them. See
---|dn_markdown.autocmds| for further details.
---
---Output files and directories associated with the current buffer can be
---deleted at any time by using the funmarkdown.clean_buffer|
---function, which can be called using the command
---|dn_markdown.MUCleanOutput| and mapping |dn_markdown.<Leader>co|.
---
---Altering pandoc compiler arguments ~
---
---The |vim-pandoc| plugin provides the string variable
---|g:pandoc#compiler#arguments| for users to configure. Any arguments it
---contains are automatically passed to pandoc when the `:Pandoc` command is
---invoked. This ftplugin enables the user to make changes to the arguments
---configured by this variable. The parser used by this ftplugin is very
---simple, so all arguments in the value for |g:pandoc#compiler#arguments|
---must be separated by one or more spaces and have one of the following
---forms:
---• --arg-with-no-value
---• --arg="value"
---
---The number of leading dashes can be from one to three.
---
---To add an argument and value such as "-Vlang:spanish", treat it as though
---it were an argument such as "--arg-with-no-value".
---
---This is only one method of specifying compiler arguments. For example,
---another method is using the document yaml metadata block. If highlight
---style is specified by multiple methods, the method that "wins" may depend
---on a number of factors. Trial and error may be necessary to determine how
---different methods of setting compiler arguments interact on a particular
---system.
---@brief ]]

local dn_markdown = {}

-- PRIVATE VARIABLES

-- only load module once
if vim.g.dn_markdown_loaded then
	return
end
vim.g.dn_markdown_loaded = true

-- MODULES

-- dkjson
local json = {}
do
	--[==[

  David Kolf's JSON module for Lua 5.1 - 5.4

  Version 2.7

  For the documentation see the corresponding readme.txt or visit
  <http://dkolf.de/src/dkjson-lua.fsl/>.

  You can contact the author by sending an e-mail to 'david' at the
  domain 'dkolf.de'.

  Copyright (C) 2010-2024 David Heiko Kolf

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

  --]==]

	-- global dependencies:
	local pairs, type, tostring, tonumber, getmetatable, setmetatable =
		pairs, type, tostring, tonumber, getmetatable, setmetatable
	local error, require, pcall, select = error, require, pcall, select
	local floor, huge = math.floor, math.huge
	local strrep, gsub, strsub, strbyte, strchar, strfind, strlen, strformat =
		string.rep, string.gsub, string.sub, string.byte, string.char, string.find, string.len, string.format
	local strmatch = string.match
	local concat = table.concat

	json.version = "dkjson 2.7"

	---@diagnostic disable-next-line: unused-local
	local _ENV = nil -- blocking globals in Lua 5.2 and later

	pcall(function()
		-- Enable access to blocked metatables.
		-- Don't worry, this module doesn't change anything in them.
		local debmeta = require("debug").getmetatable
		if debmeta then
			getmetatable = debmeta
		end
	end)

	json.null = setmetatable({}, {
		__tojson = function()
			return "null"
		end,
	})

	local function isarray(tbl)
		local max, n, arraylen = 0, 0, 0
		for k, v in pairs(tbl) do
			if k == "n" and type(v) == "number" then
				arraylen = v
				if v > max then
					max = v
				end
			else
				if type(k) ~= "number" or k < 1 or floor(k) ~= k then
					return false
				end
				if k > max then
					max = k
				end
				n = n + 1
			end
		end
		if max > 10 and max > arraylen and max > n * 2 then
			return false -- don't create an array with too many holes
		end
		return true, max
	end

	local escapecodes = {
		['"'] = '\\"',
		["\\"] = "\\\\",
		["\b"] = "\\b",
		["\f"] = "\\f",
		["\n"] = "\\n",
		["\r"] = "\\r",
		["\t"] = "\\t",
	}

	local function escapeutf8(uchar)
		---@diagnostic disable:cast-local-type
		local value = escapecodes[uchar]
		if value then
			return value
		end
		local a, b, c, d = strbyte(uchar, 1, 4)
		a, b, c, d = a or 0, b or 0, c or 0, d or 0
		if a <= 0x7f then
			value = a
		elseif 0xc0 <= a and a <= 0xdf and b >= 0x80 then
			value = (a - 0xc0) * 0x40 + b - 0x80
		elseif 0xe0 <= a and a <= 0xef and b >= 0x80 and c >= 0x80 then
			value = ((a - 0xe0) * 0x40 + b - 0x80) * 0x40 + c - 0x80
		elseif 0xf0 <= a and a <= 0xf7 and b >= 0x80 and c >= 0x80 and d >= 0x80 then
			value = (((a - 0xf0) * 0x40 + b - 0x80) * 0x40 + c - 0x80) * 0x40 + d - 0x80
		else
			return ""
		end
		if value <= 0xffff then
			return strformat("\\u%.4x", value)
		elseif value <= 0x10ffff then
			-- encode as UTF-16 surrogate pair
			value = value - 0x10000
			local highsur, lowsur = 0xD800 + floor(value / 0x400), 0xDC00 + (value % 0x400)
			return strformat("\\u%.4x\\u%.4x", highsur, lowsur)
		else
			return ""
		end
		---@diagnostic enable:cast-local-type
	end

	local function fsub(str, pattern, repl)
		-- gsub always builds a new string in a buffer, even when no match
		-- exists. First using find should be more efficient when most strings
		-- don't contain the pattern.
		if strfind(str, pattern) then
			return gsub(str, pattern, repl)
		else
			return str
		end
	end

	local function quotestring(value)
		-- based on the regexp "escapable" in https://github.com/douglascrockford/JSON-js
		value = fsub(value, '[%z\1-\31"\\\127]', escapeutf8)
		if strfind(value, "[\194\216\220\225\226\239]") then
			value = fsub(value, "\194[\128-\159\173]", escapeutf8)
			value = fsub(value, "\216[\128-\132]", escapeutf8)
			value = fsub(value, "\220\143", escapeutf8)
			value = fsub(value, "\225\158[\180\181]", escapeutf8)
			value = fsub(value, "\226\128[\140-\143\168-\175]", escapeutf8)
			value = fsub(value, "\226\129[\160-\175]", escapeutf8)
			value = fsub(value, "\239\187\191", escapeutf8)
			value = fsub(value, "\239\191[\176-\191]", escapeutf8)
		end
		return '"' .. value .. '"'
	end
	json.quotestring = quotestring

	local function replace(str, o, n)
		local i, j = strfind(str, o, 1, true)
		if i then
			return strsub(str, 1, i - 1) .. n .. strsub(str, j + 1, -1)
		else
			return str
		end
	end

	-- locale independent num2str and str2num functions
	local decpoint, numfilter

	local function updatedecpoint()
		decpoint = strmatch(tostring(0.5), "([^05+])")
		-- build a filter that can be used to remove group separators
		numfilter = "[^0-9%-%+eE" .. gsub(decpoint, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0") .. "]+"
	end

	updatedecpoint()

	local function num2str(num)
		return replace(fsub(tostring(num), numfilter, ""), decpoint, ".")
	end

	local function str2num(str)
		local num = tonumber(replace(str, ".", decpoint))
		if not num then
			updatedecpoint()
			num = tonumber(replace(str, ".", decpoint))
		end
		return num
	end

	local function addnewline2(level, buffer, buflen)
		buffer[buflen + 1] = "\n"
		buffer[buflen + 2] = strrep("  ", level)
		buflen = buflen + 2
		return buflen
	end

	function json.addnewline(state)
		if state.indent then
			state.bufferlen = addnewline2(state.level or 0, state.buffer, state.bufferlen or #state.buffer)
		end
	end

	local encode2 -- forward declaration

	local function addpair(key, value, prev, indent, level, buffer, buflen, tables, globalorder, state)
		local kt = type(key)
		if kt ~= "string" and kt ~= "number" then
			return nil, "type '" .. kt .. "' is not supported as a key by JSON."
		end
		if prev then
			buflen = buflen + 1
			buffer[buflen] = ","
		end
		if indent then
			buflen = addnewline2(level, buffer, buflen)
		end
		buffer[buflen + 1] = quotestring(key)
		buffer[buflen + 2] = ":"
		return encode2(value, indent, level, buffer, buflen + 2, tables, globalorder, state)
	end

	local function appendcustom(res, buffer, state)
		local buflen = state.bufferlen
		if type(res) == "string" then
			buflen = buflen + 1
			buffer[buflen] = res
		end
		return buflen
	end

	local function exception(reason, value, state, buffer, buflen, defaultmessage)
		defaultmessage = defaultmessage or reason
		local handler = state.exception
		if not handler then
			return nil, defaultmessage
		else
			state.bufferlen = buflen
			local ret, msg = handler(reason, value, state, defaultmessage)
			if not ret then
				return nil, msg or defaultmessage
			end
			return appendcustom(ret, buffer, state)
		end
	end

	function json.encodeexception(...)
		-- args are: reason, value, state, defaultmessage
		-- only use: defaultmessage
		return quotestring("<" .. select(4, ...) .. ">")
	end

	encode2 = function(value, indent, level, buffer, buflen, tables, globalorder, state)
		local valtype = type(value)
		local valmeta = getmetatable(value)
		---@diagnostic disable-next-line:cast-local-type
		valmeta = type(valmeta) == "table" and valmeta -- only tables
		local valtojson = valmeta and valmeta.__tojson
		if valtojson then
			if tables[value] then
				return exception("reference cycle", value, state, buffer, buflen)
			end
			tables[value] = true
			state.bufferlen = buflen
			local ret, msg = valtojson(value, state)
			if not ret then
				return exception("custom encoder failed", value, state, buffer, buflen, msg)
			end
			tables[value] = nil
			buflen = appendcustom(ret, buffer, state)
		elseif value == nil then
			buflen = buflen + 1
			buffer[buflen] = "null"
		elseif valtype == "number" then
			local s
			if value ~= value or value >= huge or -value >= huge then
				-- This is the behaviour of the original JSON implementation.
				s = "null"
			else
				s = num2str(value)
			end
			buflen = buflen + 1
			buffer[buflen] = s
		elseif valtype == "boolean" then
			buflen = buflen + 1
			buffer[buflen] = value and "true" or "false"
		elseif valtype == "string" then
			buflen = buflen + 1
			buffer[buflen] = quotestring(value)
		elseif valtype == "table" then
			if tables[value] then
				return exception("reference cycle", value, state, buffer, buflen)
			end
			tables[value] = true
			level = level + 1
			local isa, n = isarray(value)
			if n == 0 and valmeta and valmeta.__jsontype == "object" then
				isa = false
			end
			local msg
			if isa then -- JSON array
				buflen = buflen + 1
				buffer[buflen] = "["
				for i = 1, n do
					buflen, msg = encode2(value[i], indent, level, buffer, buflen, tables, globalorder, state)
					if not buflen then
						return nil, msg
					end
					if i < n then
						buflen = buflen + 1
						buffer[buflen] = ","
					end
				end
				buflen = buflen + 1
				buffer[buflen] = "]"
			else -- JSON object
				local prev = false
				buflen = buflen + 1
				buffer[buflen] = "{"
				local order = valmeta and valmeta.__jsonorder or globalorder
				if order then
					local used = {}
					n = #order
					for i = 1, n do
						local k = order[i]
						local v = value[k]
						if v ~= nil then
							used[k] = true
							buflen, msg = addpair(k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
							if not buflen then
								return nil, msg
							end
							prev = true -- add a seperator before the next element
						end
					end
					for k, v in pairs(value) do
						if not used[k] then
							buflen, msg = addpair(k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
							if not buflen then
								return nil, msg
							end
							prev = true -- add a seperator before the next element
						end
					end
				else -- unordered
					for k, v in pairs(value) do
						buflen, msg = addpair(k, v, prev, indent, level, buffer, buflen, tables, globalorder, state)
						if not buflen then
							return nil, msg
						end
						prev = true -- add a seperator before the next element
					end
				end
				if indent then
					buflen = addnewline2(level - 1, buffer, buflen)
				end
				buflen = buflen + 1
				buffer[buflen] = "}"
			end
			tables[value] = nil
		else
			return exception(
				"unsupported type",
				value,
				state,
				buffer,
				buflen,
				"type '" .. valtype .. "' is not supported by JSON."
			)
		end
		return buflen
	end

	function json.encode(value, state)
		state = state or {}
		local oldbuffer = state.buffer
		local buffer = oldbuffer or {}
		state.buffer = buffer
		updatedecpoint()
		local ret, msg = encode2(
			value,
			state.indent,
			state.level or 0,
			buffer,
			state.bufferlen or 0,
			state.tables or {},
			state.keyorder,
			state
		)
		if not ret then
			error(msg, 2)
		elseif oldbuffer == buffer then
			state.bufferlen = ret
			return true
		else
			state.bufferlen = nil
			state.buffer = nil
			return concat(buffer)
		end
	end

	local function loc(str, where)
		local line, pos, linepos = 1, 1, 0
		while true do
			---@diagnostic disable-next-line:cast-local-type
			pos = strfind(str, "\n", pos, true)
			if pos and pos < where then
				line = line + 1
				linepos = pos
				pos = pos + 1
			else
				break
			end
		end
		return "line " .. line .. ", column " .. (where - linepos)
	end

	local function unterminated(str, what, where)
		return nil, strlen(str) + 1, "unterminated " .. what .. " at " .. loc(str, where)
	end

	local function scanwhite(str, pos)
		while true do
			pos = strfind(str, "%S", pos)
			if not pos then
				return nil
			end
			local sub2 = strsub(str, pos, pos + 1)
			if sub2 == "\239\187" and strsub(str, pos + 2, pos + 2) == "\191" then
				-- UTF-8 Byte Order Mark
				pos = pos + 3
			elseif sub2 == "//" then
				pos = strfind(str, "[\n\r]", pos + 2)
				if not pos then
					return nil
				end
			elseif sub2 == "/*" then
				pos = strfind(str, "*/", pos + 2)
				if not pos then
					return nil
				end
				pos = pos + 2
			else
				return pos
			end
		end
	end

	local escapechars = {
		['"'] = '"',
		["\\"] = "\\",
		["/"] = "/",
		["b"] = "\b",
		["f"] = "\f",
		["n"] = "\n",
		["r"] = "\r",
		["t"] = "\t",
	}

	local function unichar(value)
		if value < 0 then
			return nil
		elseif value <= 0x007f then
			return strchar(value)
		elseif value <= 0x07ff then
			return strchar(0xc0 + floor(value / 0x40), 0x80 + (floor(value) % 0x40))
		elseif value <= 0xffff then
			return strchar(
				0xe0 + floor(value / 0x1000),
				0x80 + (floor(value / 0x40) % 0x40),
				0x80 + (floor(value) % 0x40)
			)
		elseif value <= 0x10ffff then
			return strchar(
				0xf0 + floor(value / 0x40000),
				0x80 + (floor(value / 0x1000) % 0x40),
				0x80 + (floor(value / 0x40) % 0x40),
				0x80 + (floor(value) % 0x40)
			)
		else
			return nil
		end
	end

	local function scanstring(str, pos)
		local lastpos = pos + 1
		local buffer, n = {}, 0
		while true do
			local nextpos = strfind(str, '["\\]', lastpos)
			if not nextpos then
				return unterminated(str, "string", pos)
			end
			if nextpos > lastpos then
				n = n + 1
				buffer[n] = strsub(str, lastpos, nextpos - 1)
			end
			if strsub(str, nextpos, nextpos) == '"' then
				lastpos = nextpos + 1
				break
			else
				local escchar = strsub(str, nextpos + 1, nextpos + 1)
				local value
				if escchar == "u" then
					value = tonumber(strsub(str, nextpos + 2, nextpos + 5), 16)
					if value then
						local value2
						if 0xD800 <= value and value <= 0xDBff then
							-- we have the high surrogate of UTF-16. Check if there is a
							-- low surrogate escaped nearby to combine them.
							if strsub(str, nextpos + 6, nextpos + 7) == "\\u" then
								value2 = tonumber(strsub(str, nextpos + 8, nextpos + 11), 16)
								if value2 and 0xDC00 <= value2 and value2 <= 0xDFFF then
									value = (value - 0xD800) * 0x400 + (value2 - 0xDC00) + 0x10000
								else
									value2 = nil -- in case it was out of range for a low surrogate
								end
							end
						end
						value = value and unichar(value)
						if value then
							if value2 then
								lastpos = nextpos + 12
							else
								lastpos = nextpos + 6
							end
						end
					end
				end
				if not value then
					value = escapechars[escchar] or escchar
					lastpos = nextpos + 2
				end
				n = n + 1
				buffer[n] = value
			end
		end
		if n == 1 then
			return buffer[1], lastpos
		elseif n > 1 then
			return concat(buffer), lastpos
		else
			return "", lastpos
		end
	end

	local scanvalue -- forward declaration

	local function scantable(what, closechar, str, startpos, nullval, objectmeta, arraymeta)
		local tbl, n = {}, 0
		local pos = startpos + 1
		if what == "object" then
			setmetatable(tbl, objectmeta)
		else
			setmetatable(tbl, arraymeta)
		end
		while true do
			pos = scanwhite(str, pos)
			if not pos then
				return unterminated(str, what, startpos)
			end
			local char = strsub(str, pos, pos)
			if char == closechar then
				return tbl, pos + 1
			end
			local val1, err
			val1, pos, err = scanvalue(str, pos, nullval, objectmeta, arraymeta)
			if err then
				return nil, pos, err
			end
			pos = scanwhite(str, pos)
			if not pos then
				return unterminated(str, what, startpos)
			end
			char = strsub(str, pos, pos)
			if char == ":" then
				if val1 == nil then
					return nil, pos, "cannot use nil as table index (at " .. loc(str, pos) .. ")"
				end
				pos = scanwhite(str, pos + 1)
				if not pos then
					return unterminated(str, what, startpos)
				end
				local val2
				val2, pos, err = scanvalue(str, pos, nullval, objectmeta, arraymeta)
				if err then
					return nil, pos, err
				end
				tbl[val1] = val2 ---@diagnostic disable-line:need-check-nil
				pos = scanwhite(str, pos)
				if not pos then
					return unterminated(str, what, startpos)
				end
				char = strsub(str, pos, pos)
			else
				n = n + 1
				tbl[n] = val1
			end
			if char == "," then
				pos = pos + 1
			end
		end
	end

	scanvalue = function(str, pos, nullval, objectmeta, arraymeta)
		pos = pos or 1
		pos = scanwhite(str, pos)
		if not pos then
			return nil, strlen(str) + 1, "no valid JSON value (reached the end)"
		end
		local char = strsub(str, pos, pos)
		if char == "{" then
			return scantable("object", "}", str, pos, nullval, objectmeta, arraymeta)
		elseif char == "[" then
			return scantable("array", "]", str, pos, nullval, objectmeta, arraymeta)
		elseif char == '"' then
			return scanstring(str, pos)
		else
			local pstart, pend = strfind(str, "^%-?[%d%.]+[eE]?[%+%-]?%d*", pos)
			if pstart then
				local number = str2num(strsub(str, pstart, pend))
				if number then
					return number, pend + 1
				end
			end
			pstart, pend = strfind(str, "^%a%w*", pos)
			if pstart then
				local name = strsub(str, pstart, pend)
				if name == "true" then
					return true, pend + 1
				elseif name == "false" then
					return false, pend + 1
				elseif name == "null" then
					return nullval, pend + 1
				end
			end
			return nil, pos, "no valid JSON value at " .. loc(str, pos)
		end
	end

	local function optionalmetatables(...)
		if select("#", ...) > 0 then
			return ...
		else
			return { __jsontype = "object" }, { __jsontype = "array" }
		end
	end

	function json.decode(str, pos, nullval, ...)
		local objectmeta, arraymeta = optionalmetatables(...)
		return scanvalue(str, pos, nullval, objectmeta, arraymeta)
	end
end

-- dn-utils
local util = require("dn-utils")

-- localise standard library functions
local sf = string.format

-- PRIVATE FUNCTIONS

-- forward declarations
local _clean_output

-- _clean_output(opts)

---@private
---Deletes common output artefacts: output files with extensions like "html"
---and "pdf", and temporary directories like ".tmp". (See function
---|dn_markdown.clean_buffer| for a complete list.)
---
---Obtains file path associated with the provided buffer number. This file
---path is used to obtain the file directory and basename of output files.
---It is up to the calling function to ensure the buffer is not hidden,
---associated with a file, and of filetype markdown -- specifying a buffer
---that does not meet these criteria will likely cause a cryptic error.
---@param opts table|nil Configuration options:
---• {bufnr} {number} Integer number of buffer
---  whose associated file's output artefacts are
---  to be cleaned. Required.
---• {confirm} {boolean} Whether to confirm with
---  user before anything is deleted.
---  Optional. Default=false.
---• {pause_end} {boolean} Whether to pause after
---  action is taken. Optional. Default=false.
---• {say_none} {bool} Whether to display a
---  message if no output artefacts are detected.
---  Optional. Default=false.
---@return boolean _ Whether any output artefacts were deleted
function _clean_output(opts)
	-- get associated file
	opts = opts or {}
	assert(opts.bufnr ~= nil, "Expected non-nil bufnr, got nil")
	assert(
		util.valid_non_negative_int(opts.bufnr),
		sf("Expected non-negative integer, got %s (%s)", type(opts.bufnr), tostring(opts.bufnr))
	)
	local md_fp = vim.api.nvim_buf_get_name(opts.bufnr)
	assert(md_fp:len() > 0, "No associated filename")
	-- vars
	local msg
	-- identify deletion candidates
	local md_fp_parts = util.parse_filepath(md_fp)
	-- • get directory contents
	local contents = util.dir_contents(md_fp_parts.dir)
	local files, dirs = contents.files, contents.dirs
	-- • get candidate output artefacts
	local clean_suffixes = { "htm", "html", "pdf", "epub", "mobi" }
	local clean_subdirs = { ".tmp" }
	local candidate = {}
	candidate.files = vim.tbl_map(function(suffix)
		return sf("%s.%s", md_fp_parts.base, suffix)
	end, clean_suffixes)
	candidate.subdirs = vim.tbl_map(function(subdir)
		return sf("%s", subdir)
	end, clean_subdirs)
	-- • get candidate output artefacts that are present
	local artefacts = { files = {}, dirs = {} }
	for _, file in ipairs(candidate.files) do
		if util.is_table_value(files, file) then
			table.insert(artefacts.files, file)
		end
	end
	for _, dir in ipairs(candidate.subdirs) do
		if util.is_table_value(dirs, dir) then
			table.insert(artefacts.dirs, dir)
		end
	end
	if #artefacts.files == 0 and #artefacts.dirs == 0 then
		if opts.say_none then
			util.info("No output to clean up")
		end
		return false
	end
	-- confirm deletions if necessary
	if opts.confirm then
		local output_list = {}
		for _, file in ipairs(artefacts.files) do
			table.insert(output_list, file)
		end
		for _, dir in ipairs(artefacts.dirs) do
			table.insert(output_list, dir)
		end
		local question = {}
		table.insert(question, { sf(" \n%s output artefacts:\n", md_fp_parts.file), "Question" })
		for _, output_item in ipairs(output_list) do
			table.insert(question, { sf("- %s\n", output_item), "Question" })
		end
		table.insert(question, { "Delete output [y/N]", "Question" })
		vim.api.nvim_echo(question, true, {})
		local answer = string.lower(vim.fn.nr2char(vim.fn.getchar()))
		vim.api.nvim_out_write(answer)
		if answer ~= "y" then
			return false
		end
	end
	-- delete output artefacts
	local deleted, failed = {}, {}
	for _, file in ipairs(artefacts.files) do
		if os.remove(file) then
			table.insert(deleted, file)
		else
			table.insert(failed, file)
		end
	end
	for _, dir in ipairs(artefacts.dirs) do
		if util.remove_dir(dir) then
			table.insert(deleted, dir)
		else
			table.insert(failed, dir)
		end
	end
	-- report outcome
	local retval
	local ui_output = {}
	if #deleted > 0 then
		retval = true
		msg = "Deleted:"
		for _, file in ipairs(deleted) do
			msg = msg .. "\n- " .. file
		end
		msg = msg .. "\n"
		table.insert(ui_output, { msg })
	end
	if #failed > 0 then
		retval = false
		msg = "Errors occurred trying to delete:"
		for _, file in ipairs(failed) do
			msg = msg .. "\n- " .. file
		end
		msg = msg .. "\n"
		table.insert(ui_output, { msg, "ErrorMsg" })
	end
	if opts.pause_end then
		local prompt = "Press any key to continue"
		table.insert(ui_output, { prompt, "MoreMsg" })
	end
	vim.api.nvim_echo(ui_output, true, {})
	if opts.pause_end then
		local _ = string.lower(vim.fn.nr2char(vim.fn.getchar()))
		vim.cmd.echo("\n")
	end
	return retval
end

-- PUBLIC FUNCTIONS

---@mod dn_markdown.functions Functions

-- add_boilerplate()

---Adds pander/markdown boilerplate to the top and bottom of the document.
---@return nil _ No return value
function dn_markdown.add_boilerplate()
	-- remember where we parked
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	-- metadata to be inserted at top of file
	local metadata = {
		"---",
		'title: "[][source]"',
		'author: "[][author]"',
		'date: ""',
		"style: [Standard, Latex14pt]",
		"       # Latex8-12|14|17|20pt, SectNewPage, PageBreak, Include",
		"---",
		"",
	}
	-- comment block to be inserted at bottom of file
	local comment_block = { "", "[command]: # (URLs)", "", "   [author]: ", "", "   [source]: " }
	-- insert content
	vim.api.nvim_win_set_cursor(0, { 1, 1 })
	vim.api.nvim_put(metadata, "l", false, false)
	local last_line = vim.fn.line("$")
	vim.api.nvim_win_set_cursor(0, { last_line, 1 })
	vim.api.nvim_put(comment_block, "l", true, false)
	-- return to where we parked
	line = line + #metadata
	vim.api.nvim_win_set_cursor(0, { line, col })
end

-- clean_all_buffers([opts])

---Deletes common output artefacts: output files with extensions "htm",
---"html", "pdf", "epub", and "mobi"; and temporary directories named
---".tmp".
---
---Searches sequentially through all buffers that are both associated with a
---file name and have a markdown file type.
---@param opts table|nil Optional configuration options:
---• {confirm} (boolean) Whether to confirm with
---  user before anything is deleted.
---  Default=false.
---• {pause_end} (boolean) Whether to pause after
---  action is taken. Default=false.
---• {say_none} (boolean) Whether to display a
---  message if no output artefacts are detected.
---  Default=false.
---@return nil _ No return value
function dn_markdown.clean_all_buffers(opts)
	-- disable Noice
	vim.api.nvim_cmd({ cmd = "NoiceDisable" }, {})
	-- process options
	opts = opts or {}
	assert(type(opts) == "table", "Expected table, got " .. type(opts))
	local valid_options = { "confirm", "pause_end", "say_none" }
	local invalid_options = {}
	for option, _ in pairs(opts) do
		if not util.is_table_value(valid_options, option) then
			table.insert(invalid_options, option)
		end
	end
	if #invalid_options > 0 then
		util.error("Invalid option(s): " .. table.concat(invalid_options, ","))
		return
	end
	opts.confirm = opts.confirm or false
	assert(type(opts.confirm) == "boolean", "Expected boolean 'confirm' option, got " .. type(opts.confirm))
	opts.pause_end = opts.pause_end or false
	assert(type(opts.pause_end) == "boolean", "Expected boolean 'pause_end' option, got " .. type(opts.pause_end))
	opts.say_none = opts.say_none or false
	assert(type(opts.say_none) == "boolean", "Expected boolean 'say_none' option, got " .. type(opts.say_none))
	opts.caller = opts.caller or "clean_all_buffers"
	-- find buffers associated with markdown files
	local md_bufnrs = {}
	local md_filetypes = { "markdown", "pandoc", "markdown.pandoc" }
	for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
		-- must be loaded
		if vim.api.nvim_buf_is_loaded(bufnr) then
			-- must have associated file
			local filename = vim.api.nvim_buf_get_name(bufnr)
			if filename:len() ~= 0 then
				-- must be markdown filetype
				local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
				if util.is_table_value(md_filetypes, filetype) then
					table.insert(md_bufnrs, bufnr)
				end
			end
		end
	end
	-- clean each markdown file buffer in turn
	for _, md_bufnr in ipairs(md_bufnrs) do
		opts.bufnr = md_bufnr
		-- ignore return value from _clean_output
		_clean_output(opts)
	end
end

-- clean_buffer([opts])

---Deletes common output artefacts: output files with extensions "htm",
---"html", "pdf", "epub", and "mobi"; and temporary directories named
---".tmp".
---@param opts table|nil Optional configuration options:
---• {bufnr} (number) Number of buffer to process.
---  Default=0.
---• {confirm} (boolean) Whether to confirm with
---  user before anything is deleted.
---  Default=false.
---• {pause_end} (boolean) Whether to pause after
---  action is taken. Default=false.
---• {say_none} (boolean) Whether to display a
---  message if no output artefacts are detected.
---  Default=false.
---@return nil _ No return value
function dn_markdown.clean_buffer(opts)
	-- disable Noice
	vim.api.nvim_cmd({ cmd = "NoiceDisable" }, {})
	-- process options
	opts = opts or {}
	assert(type(opts) == "table", "Expected table, got " .. type(opts))
	local valid_options = { "bufnr", "confirm", "pause_end", "say_none" }
	local invalid_options = {}
	for option, _ in pairs(opts) do
		if not util.is_table_value(valid_options, option) then
			table.insert(invalid_options, option)
		end
	end
	if #invalid_options > 0 then
		util.error("Invalid option(s): " .. table.concat(invalid_options, ","))
		return
	end
	opts.bufnr = opts.bufnr or 0
	assert(util.valid_pos_int(opts.bufnr), "Expected integer 'bufnr' option, got " .. tostring(opts.bufnr))
	opts.confirm = opts.confirm or false
	assert(type(opts.confirm) == "boolean", "Expected boolean 'confirm' option, got " .. type(opts.confirm))
	opts.pause_end = opts.pause_end or false
	assert(type(opts.pause_end) == "boolean", "Expected boolean 'pause_end' option, got " .. type(opts.pause_end))
	opts.say_none = opts.say_none or false
	assert(type(opts.say_none) == "boolean", "Expected boolean 'say_none' option, got " .. type(opts.say_none))
	opts.caller = opts.caller or "clean_buffer"
	-- clean if buffer is associated with markdown file
	local md_filetypes = { "markdown", "pandoc", "markdown.pandoc" }
	local filename = vim.api.nvim_buf_get_name(opts.bufnr)
	if filename:len() ~= 0 then
		local filetype = vim.api.nvim_get_option_value("filetype", { buf = opts.bufnr })
		if util.is_table_value(md_filetypes, filetype) then
			-- ignore return value from _clean_output
			_clean_output(opts)
		end
	end
	-- enable Noice
	--vim.api.nvim_cmd({ cmd = "NoiceEnable" }, {})
end

-- insert_figure()

---Inserts a figure link on a new line.
---A reference link definition is added to the end of the file in its own
---line.
---@return nil _ No return value
function dn_markdown.insert_figure()
	-- WARNING: if editing this function note that it consists of a chain of
	--          local functions called in turn through callbacks in
	--          |vim.ui.input()| calls; this makes the function inherently
	--          fragile and easy to break

	-- pre-declare local functions
	local _fig_get_caption
	local _fig_get_id_label
	local _fig_get_width
	local _fig_insert

	-- variables used in multiple local functions
	local prompt, default

	-- get image filepath
	prompt = "Enter image filepath (empty to abort)"
	vim.ui.input({ prompt = prompt, completion = "file" }, function(input)
		if input and input:len() ~= 0 then
			if not util.file_readable(input) then
				util.warning(sf("File '%s' is not readable", input))
			end
			local user_input = {}
			user_input.path = input
			_fig_get_caption(user_input)
		end
	end)

	-- get image caption
	_fig_get_caption = function(user_input)
		prompt = "Enter image caption (empty to abort)"
		vim.ui.input({ prompt = prompt }, function(input)
			if input and input:len() ~= 0 then
				user_input.caption = input
				_fig_get_id_label(user_input)
			end
		end)
	end

	-- get_id/label
	_fig_get_id_label = function(user_input)
		-- derive default id from caption
		-- • make lowercase
		default = string.lower(user_input.caption)
		-- • remove illegal characters (%w = alphanumeric)
		default = default:gsub("[^%w_]", "-")
		-- • remove leading and trailing dashes
		default = util.trim_char(default, "-")
		-- • collapse multiple sequential dashes
		default = default:gsub("%-+", "%-")
		-- get id
		prompt = "Enter figure id (empty to abort "
		vim.ui.input({ prompt = prompt, default = default }, function(input)
			if input and input:len() ~= 0 then
				if not input:match("^[a-z_-]+$") then
					util.error("Figure ids can contain only a-z, 0-9, _ and -")
					return
				end
				user_input.id = input
				_fig_get_width(user_input)
			end
		end)
	end

	-- get width class (optional)
	_fig_get_width = function(user_input)
		prompt = "Enter image width (optional)"
		default = "80%"
		vim.ui.input({ prompt = prompt, default = default }, function(input)
			if input and input:len() ~= 0 then
				user_input.width = input
			end
			_fig_insert(user_input)
		end)
	end

	-- insert figure link and link definition
	_fig_insert = function(user_input)
		-- assemble link
		local link = sf("![%s][%s]", user_input.caption, user_input.id)
		-- assemble link definition
		local width = ""
		if user_input.width and user_input.width:len() ~= 0 then
			width = sf(" .class %s", user_input.width)
		end
		local id, path, caption = user_input.id, user_input.path, user_input.caption
		local definition = sf('   [%s]: %s "%s" {#fig:%s%s}', id, path, caption, id, width)
		-- insert link
		local link_lines = { link, "" }
		vim.api.nvim_put(link_lines, "l", true, true)
		-- insert definition
		local definition_lines = { "", definition }
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		local last_line = vim.fn.line("$")
		vim.api.nvim_win_set_cursor(0, { last_line, 1 })
		vim.api.nvim_put(definition_lines, "l", true, false)
		vim.api.nvim_win_set_cursor(0, { line, col })
	end
end

-- insert_figure_reference()

---Select an existing figure reference and insert it after the cursor.
---
---The inserted reference uses the format of the "pandoc.crossref" filter,
---e.g., "[@fig:REF]".
---
---Since the user selection function is asynchronous, other processes, such
---as linters, can redraw the screen and reposition the cursor before the
---figure reference is inserted. One of the commonest issues is processes
---that remove trailing spaces removing the space intended to precede the
---figure reference. Two things are done to try and mitigate these issues:
---• repositioning the cursor to its original location immediately before
---  pasting
---• inserting a space before the figure reference.
---@return nil _ No return value
function dn_markdown.insert_figure_reference()
	-- get cursor location as soon as possible
	-- • the selection is asynchronous, so various processes can redraw the
	--   screen and reposition the cursor while the user selects the figure
	--   label to insert
	local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
	-- can only operate on a file
	local fp = vim.api.nvim_buf_get_name(0)
	if fp == "" then
		util.error("Buffer is not associated with a file")
		return
	end
	vim.cmd.update({ args = {}, bang = true })
	-- obtain pandoc abstract syntax tree
	local cmd = { "pandoc", "-f", "markdown", "-t", "json", fp }
	local ret = util.execute_shell_command(unpack(cmd))
	if ret.exit_status ~= 0 then
		util.error(ret.stderr)
		return
	end
	-- • pandoc warnings may be captured in output, so trim outside curly braces
	local json_output = string.match(ret.stdout, "^.-(%{.*%}).-$")
	-- • decode output
	local ast, err_pos, err_msg = json.decode(json_output, 1, nil)
	if err_msg ~= nil then
		util.error(sf("ast data extraction error at position %s: %s", err_pos, err_msg))
		return
	end
	if type(ast) ~= "table" then
		util.error(sf("expected AST as table, got: %s", type(ast)))
		return
	end
	-- search AST for defined figures
	-- • this example figure definition:
	--   >
	--     ![Origami paper ready to fold][ready-to-fold]
	--     ...
	--     [ready-to-fold]: resources/base_01.png "Origami paper ready to fold" {#fig:ready-to-fold}
	--   <
	--   is represented deep in the ast output table as something like:
	--   >
	--     {
	--       ["t"]  =  "Figure",
	--       ["c"] = {
	--         [1] = {
	--           [1]  =  "fig:ready-to-fold",
	--           [2] = {},
	--           [3] = {},
	--         },
	--         [2] = { ... },
	--         [3] = { ... },
	--       },
	--     },
	--   <
	local fig_labels = {}
	local _examine_table
	_examine_table = function(subtable)
		assert(type(subtable) == "table", "Expected table to examine, got " .. type(subtable))
		-- extract figure label if have found a 'Figure' subtable
		if subtable["t"] ~= nil and subtable["t"] == "Figure" then
			if subtable["c"] ~= nil and subtable["c"][1] ~= nil and subtable["c"][1][1] ~= nil then
				local subvalue = subtable["c"][1][1]
				local fig_label = subvalue:match("^fig:(%S+)$")
				if fig_label ~= nil then
					table.insert(fig_labels, fig_label)
				end
			end
		end
		-- now examine contents of table
		for _, v in pairs(subtable) do
			if type(v) == "table" then
				_examine_table(v)
			end
		end
	end
	_examine_table(ast)
	table.sort(fig_labels)
	-- warn if duplicate labels present
	local lookup_fig_labels = {}
	local uniq_fig_labels = {}
	local lookup_duplicate_fig_labels = {}
	for _, fig_label in ipairs(fig_labels) do
		if lookup_fig_labels[fig_label] ~= nil then
			lookup_duplicate_fig_labels[fig_label] = true
		else
			lookup_fig_labels[fig_label] = true
			table.insert(uniq_fig_labels, fig_label)
		end
	end
	local duplicate_fig_labels = {}
	for fig_label, _ in pairs(lookup_duplicate_fig_labels) do
		table.insert(duplicate_fig_labels, fig_label)
	end
	table.sort(duplicate_fig_labels)
	local duplicate_fig_label_count = util.table_size(duplicate_fig_labels)
	if duplicate_fig_label_count > 0 then
		local warning = "Duplicate figure label"
		if duplicate_fig_label_count == 1 then
			warning = warning .. ": " .. duplicate_fig_labels[1]
		else
			warning = warning .. "s: " .. table.concat(duplicate_fig_labels, ", ")
		end
		util.warning(warning)
	end
	-- select figure reference and insert it
	vim.ui.select(uniq_fig_labels, { prompt = "Select figure label to insert" }, function(fig_label)
		if fig_label == nil then
			return
		end
		local fig_reference = sf(" [@fig:%s]", fig_label)
		-- reposition cursor in case it moved
		vim.api.nvim_win_set_cursor(0, { cursor_line, cursor_col })
		vim.api.nvim_paste(fig_reference, false, -1)
	end)
end

-- insert_file()

---Inserts an include directive on a new line.
---@return nil _ No return value
function dn_markdown.insert_file()
	-- WARNING: if editing this function note that it consists of a chain of
	--          local functions called in turn through callbacks in
	--          |vim.ui.input()| calls; this makes the function inherently
	--          fragile and easy to break

	-- pre-declare local functions
	local _fil_get_shift
	local _fil_insert

	-- variable used in multiple local functions
	local prompt

	-- get filepath
	prompt = "Enter filepath (empty to abort)"
	vim.ui.input({ prompt = prompt, completion = "file" }, function(input)
		if input and input:len() ~= 0 then
			if not util.file_readable(input) then
				util.warning(sf("File '%s' is not readable", input))
			end
			local user_input = {}
			user_input.path = input
			_fil_get_shift(user_input)
		end
	end)

	-- get header shift value (optional)
	_fil_get_shift = function(user_input)
		prompt = "Enter header shift value (optional)"
		vim.ui.input({ prompt = prompt }, function(input)
			if input and input:len() ~= 0 then
				input = tonumber(input)
				if (not input) or (not util.valid_pos_int(input)) then
					util.error("Header shift value must be a non-zero integer")
					return
				end
				user_input.shift = input
			end
			_fil_insert(user_input)
		end)
	end

	-- insert directive
	_fil_insert = function(user_input)
		-- assemble directive
		local path, shift = user_input.path, user_input.shift
		local directive = {}
		local opening = "```{.include"
		if shift then
			opening = opening .. " shift-heading-level-by=" .. tostring(shift)
		end
		opening = opening .. "}"
		table.insert(directive, opening)
		table.insert(directive, path)
		table.insert(directive, "```")
		table.insert(directive, "")
		table.insert(directive, "")
		-- insert directive
		vim.api.nvim_put(directive, "l", true, true)
	end
end

-- insert_table_definition()

---Inserts a table caption and id line as expected by pandoc-tablenos to
---follow a table.
---@return nil _ No return value
function dn_markdown.insert_table_definition()
	-- WARNING: if editing this function note that it consists of a chain of
	--          local functions called in turn through callbacks in
	--          |vim.ui.input()| calls; this makes the function inherently
	--          fragile and easy to break

	-- pre-declare local functions
	local _tbl_get_id_label
	local _tbl_definition_insert

	-- variables used in multiple local functions
	local prompt, default

	-- get table caption
	prompt = "Enter table caption (empty to abort)"
	vim.ui.input({ prompt = prompt }, function(input)
		if input and input:len() ~= 0 then
			local user_input = {}
			user_input.caption = input
			-- remove trailing periods as terminal period added later
			user_input.caption = user_input.caption:gsub("%.+$", "")
			_tbl_get_id_label(user_input)
		end
	end)

	-- get_id/label
	_tbl_get_id_label = function(user_input)
		-- derive default id from caption
		-- • make lowercase
		default = string.lower(user_input.caption)
		-- • remove illegal characters (%w = alphanumeric)
		default = default:gsub("[^%w_]", "-")
		-- • remove leading and trailing dashes
		default = util.trim_char(default, "-")
		-- • collapse multiple sequential dashes
		default = default:gsub("%-+", "%-")
		-- get id
		prompt = "Enter table id (empty to abort "
		vim.ui.input({ prompt = prompt, default = default }, function(input)
			if input and input:len() ~= 0 then
				if not input:match("^[a-z_-]+$") then
					util.error("Table ids can contain only a-z, 0-9, _ and -")
					return
				end
				user_input.id = input
				_tbl_definition_insert(user_input)
			end
		end)
	end

	-- insert table definition
	_tbl_definition_insert = function(user_input)
		-- assemble table definition
		local caption, id = user_input.caption, user_input.id
		local definition = sf("Table: %s. {#tbl:%s}", caption, id)
		-- insert table definition
		local definition_lines = { definition }
		vim.api.nvim_put(definition_lines, "l", true, true)
	end
end

-- insert_table_reference()

---Select an existing table reference and insert it after the cursor.
---
---The inserted reference uses the format of the "pandoc.crossref" filter,
---e.g., "[@tbl:REF]".
---
---Since the user selection function is asynchronous, other processes, such
---as linters, can redraw the screen and reposition the cursor before the
---table reference is inserted. One of the commonest issues is processes
---that remove trailing spaces removing the space intended to precede the
---table reference. Two things are done to try and mitigate these issues:
---• repositioning the cursor to its original location immediately before
---  pasting
---• inserting a space before the table reference.
---@return nil _ No return value
function dn_markdown.insert_table_reference()
	-- get cursor location as soon as possible
	-- • the selection is asynchronous, so various processes can redraw the
	--   screen and reposition the cursor while the user selects the table
	--   label to insert
	local cursor_line, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
	-- can only operate on a file
	local fp = vim.api.nvim_buf_get_name(0)
	if fp == "" then
		util.error("Buffer is not associated with a file")
		return
	end
	vim.cmd.update({ args = {}, bang = true })
	-- obtain pandoc abstract syntax tree
	local cmd = { "pandoc", "-f", "markdown", "-t", "json", fp }
	local ret = util.execute_shell_command(unpack(cmd))
	if ret.exit_status ~= 0 then
		util.error(ret.stderr)
		return
	end
	-- • pandoc warnings may be captured in output, so trim outside curly braces
	local json_output = string.match(ret.stdout, "^.-(%{.*%}).-$")
	-- • decode output
	local ast, err_pos, err_msg = json.decode(json_output, 1, nil)
	if err_msg ~= nil then
		util.error(sf("ast data extraction error at position %s: %s", err_pos, err_msg))
		return
	end
	if type(ast) ~= "table" then
		util.error(sf("expected AST as table, got: %s", type(ast)))
		return
	end
	-- search AST for defined tables
	-- • this example table definition:
	--   >
	--     Table: The Forgotten Age cycle. [#tbl:forgotten]
	--   <
	--   is represented deep in the ast output table as something like:
	--   >
	--     {
	--       "t": "Table",
	--       "c": [
	--         ["", [], []],
	--         [
	--           null,
	--           [
	--             {
	--               "t": "Plain",
	--               "c": [
	--                 { "t": "Str", "c": "The" },
	--                 { "t": "Space" },
	--                 { "t": "Str", "c": "Forgotten" },
	--                 { "t": "Space" },
	--                 { "t": "Str", "c": "Age" },
	--                 { "t": "Space" },
	--                 { "t": "Str", "c": "cycle." },
	--                 { "t": "Space" },
	--                 { "t": "Str", "c": "[#tbl:forgotten]" }
	--               ]
	--             }
	--           ]
	--         ],
	--         ...,
	--       ],
	--     }
	--   <
	local tbl_labels = {}
	local _examine_table
	_examine_table = function(subtable)
		assert(type(subtable) == "table", "Expected table to examine, got " .. type(subtable))
		-- extract table label if have found a 'Table' subtable
		-- • this algorithm is more complex than for figures because:
		--   - the label is buried 5 tables deep rather than 2
		--   - one step requires extracting the last item in a list table
		if subtable["t"] ~= nil and subtable["t"] == "Table" then
			if
				subtable["c"] ~= nil
				and subtable["c"][2] ~= nil
				and subtable["c"][2][2] ~= nil
				and subtable["c"][2][2][1] ~= nil
				and subtable["c"][2][2][1]["c"] ~= nil
			then
				local deep_subtable = subtable["c"][2][2][1]["c"]
				local last_item = deep_subtable[#deep_subtable]
				if last_item["c"] ~= nil then
					local subvalue = last_item["c"]
					local tbl_label = subvalue:match("^%[#tbl:(%S+)%]$")
					if tbl_label ~= nil then
						table.insert(tbl_labels, tbl_label)
					end
				end
			end
		end
		-- now examine contents of table
		for _, v in pairs(subtable) do
			if type(v) == "table" then
				_examine_table(v)
			end
		end
	end
	_examine_table(ast)
	table.sort(tbl_labels)
	-- warn if duplicate labels present
	local lookup_tbl_labels = {}
	local uniq_tbl_labels = {}
	local lookup_duplicate_tbl_labels = {}
	for _, tbl_label in ipairs(tbl_labels) do
		if lookup_tbl_labels[tbl_label] ~= nil then
			lookup_duplicate_tbl_labels[tbl_label] = true
		else
			lookup_tbl_labels[tbl_label] = true
			table.insert(uniq_tbl_labels, tbl_label)
		end
	end
	local duplicate_tbl_labels = {}
	for tbl_label, _ in pairs(lookup_duplicate_tbl_labels) do
		table.insert(duplicate_tbl_labels, tbl_label)
	end
	table.sort(duplicate_tbl_labels)
	local duplicate_tbl_label_count = util.table_size(duplicate_tbl_labels)
	if duplicate_tbl_label_count > 0 then
		local warning = "Duplicate table label"
		if duplicate_tbl_label_count == 1 then
			warning = warning .. ": " .. duplicate_tbl_labels[1]
		else
			warning = warning .. "s: " .. table.concat(duplicate_tbl_labels, ", ")
		end
		util.warning(warning)
	end
	-- select table reference and insert it
	vim.ui.select(uniq_tbl_labels, { prompt = "Select table label to insert" }, function(tbl_label)
		if tbl_label == nil then
			return
		end
		local tbl_reference = sf(" [@tbl:%s]", tbl_label)
		-- reposition cursor in case it moved
		vim.api.nvim_win_set_cursor(0, { cursor_line, cursor_col })
		vim.api.nvim_paste(tbl_reference, false, -1)
	end)
end

-- MAPPINGS

---@mod dn_markdown.mappings Mappings

-- \ab [n,i]

---@tag dn_markdown.<Leader>ab
---@brief [[
---This mapping calls the function |dn_markdown.add_boilerplate| in modes
---"n" and "i".
---@brief ]]
vim.keymap.set({ "n", "i" }, "<Leader>ab", dn_markdown.add_boilerplate, { desc = "Insert pander/markdown boilerplate" })

-- \fig [n,i]

---@tag dn_markdown.<Leader>fig
---@brief [[
---This mapping calls the function |dn_markdown.insert_figure| in modes "n"
---and "i".
---@brief ]]
vim.keymap.set({ "n", "i" }, "<Leader>fig", dn_markdown.insert_figure, { desc = "Insert figure link and definition" })

-- \fil [n,i]

---@tag dn_markdown.<Leader>fil
---@brief [[
---This mapping calls the function |dn_markdown.insert_file| in modes "n"
---and "i".
---@brief ]]
vim.keymap.set({ "n", "i" }, "<Leader>fil", dn_markdown.insert_file, { desc = "Insert an include directive" })

-- \rfig [n,i]

---@tag dn_markdown.<Leader>rfig
---@brief [[
---This mapping calls the function |dn_markdown.insert_figure_reference| in modes
---"n" and "i".
---@brief ]]
vim.keymap.set(
	{ "n", "i" },
	"<Leader>rfig",
	dn_markdown.insert_figure_reference,
	{ desc = "Insert a figure reference" }
)

-- \rtbl [n,i]

---@tag dn_markdown.<Leader>rtbl
---@brief [[
---This mapping calls the function |dn_markdown.insert_table_reference| in modes
---"n" and "i".
---@brief ]]
vim.keymap.set({ "n", "i" }, "<Leader>rtbl", dn_markdown.insert_table_reference, { desc = "Insert a table reference" })

-- \tbl [n,i]

---@tag dn_markdown.<Leader>tbl
---@brief [[
---This mapping calls the function |dn_markdown.insert_table_definition| in
---modes "n" and "i".
---@brief ]]
vim.keymap.set({ "n", "i" }, "<Leader>tbl", dn_markdown.insert_table_definition, { desc = "Insert table definition" })

-- COMMANDS

---@mod dn_markdown.commands Commands

-- MUAddBoilerplate

---@tag dn_markdown.MUAddBoilerplate
---@brief [[
---Calls function |dn_markdown.add_boilerplate| to add a metadata header
---template, including title, author, date, and (pander) styles, and a
---footer template for url reference links.
---@brief ]]
vim.api.nvim_create_user_command("MUAddBoilerplate", function()
	dn_markdown.add_boilerplate()
end, { desc = "Insert pander/markdown boilerplate" })

-- MUInsertFigure

---@tag dn_markdown.MUInsertFigure
---@brief [[
---Calls function |dn_markdown.insert_figure| to insert a figure link on the
---following line and a corresponding link definition is added to the bottom
---of the document.
---@brief ]]
vim.api.nvim_create_user_command("MUInsertFigure", function()
	dn_markdown.insert_figure()
end, { desc = "Insert figure link and definition" })

-- MUInsertFigureReference

---@tag dn_markdown.MUInsertFigureReference
---@brief [[
---Calls function |dn_markdown.insert_figure_reference| to select a figure
---reference and insert it after the cursor.
---@brief ]]
vim.api.nvim_create_user_command("MUInsertFigureReference", function()
	dn_markdown.insert_figure_reference()
end, { desc = "Insert a figure reference" })

-- MUInsertFile

---@tag dn_markdown.MUInsertFile
---@brief [[
---Calls function |dn_markdown.insert_file| to insert an include directive
---on the following line.
---@brief ]]
vim.api.nvim_create_user_command("MUInsertFile", function()
	dn_markdown.insert_file()
end, { desc = "Insert an include directive" })

-- MUInsertTable

---@tag dn_markdown.MUInsertTable
---@brief [[
---Calls function |dn_markdown.insert_table_definition| to insert a table
---caption and id on the following line.
---@brief ]]
vim.api.nvim_create_user_command("MUInsertTable", function()
	dn_markdown.insert_table_definition()()
end, { desc = "Insert table definition" })

-- MUInsertTableReference

---@tag dn_markdown.MUInsertTableReference
---@brief [[
---Calls function |dn_markdown.insert_table_reference| to select a table
---reference and insert it after the cursor.
---@brief ]]
vim.api.nvim_create_user_command("MUInsertTableReference", function()
	dn_markdown.insert_table_reference()
end, { desc = "Insert a table reference" })

-- AUTOCOMMANDS

---@mod dn_markdown.autocmds Autocommands

-- if run DisableNoice command in autocmd-called function it does not take
-- effect until *after* function runs, so run from its own autocmd that is
-- called *before* the autocmd that calls the function

local dn_markdown_augroup = vim.api.nvim_create_augroup("dn_markdown", { clear = true })
local dn_disablenoice_augroup = vim.api.nvim_create_augroup("dn_disablenoice", { clear = true })

---@tag dn_markdown.autocmd_BufDelete
---@brief [[
---At buffer deletion the |dn_markdown.clean_buffer| function is run to
---optionally delete output artefacts (file and directories) if the buffer
---has a markdown filetype and is associated with a file. This autocmd is
---part of the "dn_markdown" augroup.
---
---Noice has to be disabled before running this function because if it is
---running during the BufDelete event it will prevent display of the
---function's user feedback. This autocmd is part of the "dn_disablenoice"
---augroup.
---@brief ]]

vim.api.nvim_create_autocmd("BufDelete", {
	group = dn_disablenoice_augroup,
	pattern = "*.md",
	callback = function()
		vim.api.nvim_cmd({ cmd = "NoiceDisable" }, {})
	end,
	desc = "Disable Noice when buffer deleted",
})

vim.api.nvim_create_autocmd("BufDelete", {
	group = dn_markdown_augroup,
	pattern = "*.md",
	callback = function(args)
		require("dn-markdown").clean_buffer({ bufnr = args.buf, confirm = true })
	end,
	desc = "Delete markdown output artefacts when buffer deleted",
})

---@tag dn_markdown.autocmd_VimLeavePre
---@brief [[
---During vim exit the |dn_markdown.clean_all_buffers| function is run to
---optionally delete output artefacts (file and directories) from all
---markdown buffers associated with files. This autocmd is part of the "
---dn_markdown" augroup.
---
---Noice has to be disabled before running this function because if it is
---running during the VimLeavePre event it will prevent display of the
---function's user feedback. This autocmd is part of the "dn_disablenoice"
---augroup.
---@brief ]]

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = dn_disablenoice_augroup,
	callback = function()
		vim.api.nvim_cmd({ cmd = "NoiceDisable" }, {})
	end,
	desc = "Disable Noice when exiting vim",
})

vim.api.nvim_create_autocmd("VimLeavePre", {
	group = dn_markdown_augroup,
	callback = function()
		require("dn-markdown").clean_all_buffers({ confirm = true, pause_end = true })
	end,
	desc = "Delete markdown output artefacts when exiting vim",
})

return dn_markdown
