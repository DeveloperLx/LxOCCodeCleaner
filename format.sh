#!/bin/bash

STYLE='{Language: Cpp,
		BasedOnStyle: llvm,
		BreakBeforeBraces: Attach,
		ColumnLimit: 0,
		IndentCaseLabels: true,
		IndentWidth: 4,
		MaxEmptyLinesToKeep: 1,
		ObjCBlockIndentWidth: 4,
		ObjCSpaceAfterProperty: true,
		ObjCSpaceBeforeProtocolList: true,
		PointerAlignment: Right,
		SpaceBeforeAssignmentOperators: true,
		SpacesBeforeTrailingComments: 1,
		TabWidth: 4,
		UseTab: Never}'

# 让用户输入路径
function input_path() {
	read -p "👉  输入要清理的OC源码的文件或目录：" path

	if [[ -d "$path" ]]; then
		format_dir "$path"
	elif [[ -f "$path" ]]; then
		if is_oc_file "$path"; then
			format_oc_file "$path"
		else
			echo "❌  输入错误，或路径不存在，请重新输入！！！" >&2
			input_path
		fi
	else
		echo "❌  输入错误，或路径不存在，请重新输入！！！" >&2
		input_path
	fi
}

# 需传入一个参数为目录的路径
function format_dir() {
	dir=$1
	echo "=> 正在format目录："$dir" 中的OC源码..." >&1

	find "$dir" | while read content; do
		if is_oc_file "$content"; then
			format_oc_file "$content"
		fi
	done
}

# 需传入一个参数为目录的路径
function format_oc_file() {
	filepath=$1
	echo "> format文件："$filepath >&1
	clang-format -i -style "$STYLE" "$filepath"
}

# 需传入一个参数为文件的路径 返回 0-是 1-否
function is_oc_file() {
	filepath=$1
	if [[ ! -f $filepath ]]; then
		return 1
	elif [[ ${filepath##*.} = 'h' ]]; then
		return 0
	elif [[ ${filepath##*.} = 'm' ]]; then
		return 0
	elif [[ ${filepath##*.} = 'mm' ]]; then
		return 0
	else
		return 1
	fi
}

# 检查homebrew是否安装
function check_brew {
	if ! hash brew 1>/dev/null 2>/dev/null; then
		echo "❌  检测到您的系统上未安装Homebrew，即将开始为您安装" >&2
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
}

# 检查clang-format是否安装
function check_clang_format() {
	if ! type clang-format 1>/dev/null 2>/dev/null; then
		echo "❌  检测到您的系统上未安装clang-format" >&2
		check_brew
		echo "=> 即将开始为您安装clang-format" >&1
		brew install clang-format
	fi
}

check_clang_format
input_path
