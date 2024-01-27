# dn-markdown.nvim

An auxiliary filetype plugin for the markdown language.

The plugin author uses the
[vim-pandoc](https://github.com/vim-pandoc/vim-pandoc) plugin and
[pander](https://github.com/dnebauer/pander) for markdown support. This plugin
is intended to address gaps in markdown support provided by those tools.

## Dependencies

Pandoc is used to generate output. It is not provided by this ftplugin. This ftplugin depends on the [vim-pandoc](https://github.com/vim-pandoc/vim-pandoc) plugin and assumes [pander](https://github.com/dnebauer/pander) is installed.

This plugin depends on the [dn-utils.nvim](https://github.com/dnebauer/dn-utils.nvim) plugin.

## Features

A default [pander](https://github.com/dnebauer/pander)- and pandoc-compatible yaml-style metadata block can be added to a markdown file.

A helper function, mapping and command are provided to assist with adding figures. They assume the images are defined using reference links with optional attributes, and that all reference links are added to the end of the document prefixed with three spaces.

This plugin leaves the bulk of output generation to [vim-pandoc](https://github.com/vim-pandoc/vim-pandoc). In addition, this plugin provides a mapping, command and function for deleting output files and temporary output directories. Read the help file carefully before using this feature as it is potentially unsafe. By default, when buffers are deleted or vim exits, the user has an opportunity to delete output files/directories.

## License

This plugin is distributed under the GNU GPL version 3.
