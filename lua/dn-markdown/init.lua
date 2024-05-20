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

local sf = string.format
local util = require("dn-utils")

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
		msg = sf("Delete %s output (%s) [y/N]", md_fp_parts.file, table.concat(output_list, ", "))
		vim.api.nvim_echo({ { msg, "Question" } }, true, {})
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
		msg = "Deleted " .. table.concat(deleted, ", ") .. "\n"
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
