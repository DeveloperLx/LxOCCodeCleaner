#!/bin/bash

echo ===========   规范化您的代码（按ctrl+c键可退出）   ===========
echo =================   Develop by DeveloperLx   =================

# 返回 1-文件 0-目录 -1-不存在
judgeFilepath() {
	if [[ -f $1 ]]; then
		return 1
	elif [[ -d $1 ]]; then
		return 0
	else
		return -1
	fi
}

# 返回 1-是 0-否
isOCFile() {
	filepath=$1
	if [[ ${filepath:0-2:2} = '.h' ]]; then
		return 1
	elif [[ ${filepath:0-2:2} = '.m' ]]; then
		return 1
	else
		return 0
	fi
}

#返回1表示匹配
isMatch() {
	string=$1
	regex=$2

	command='echo "'$string'" | grep -c "'$regex'"'
	result=`eval "$command" 2>&1`

	if [[ $result > 0 ]]; then
		return 1
	else
		return 0
	fi
}

codeClean() {
	filepath=$1

	echo Clean文件：$filepath

	style='{Language: Cpp, BasedOnStyle: llvm, BreakBeforeBraces: Attach, ColumnLimit: 0, IndentCaseLabels: true, IndentWidth: 4, MaxEmptyLinesToKeep: 2, ObjCBlockIndentWidth: 4, ObjCSpaceAfterProperty: true, ObjCSpaceBeforeProtocolList: true, PointerAlignment: Right, SpaceBeforeAssignmentOperators: true, SpacesBeforeTrailingComments: 1, TabWidth: 4, UseTab: Never}'
	clang-format -i -style "$style" $filepath

	# clang-format -style .style -i $filepath

	lineNumber=0
	lastLineEndWithLeftBrace=false

	while read line; do
		let lineNumber++

		# 清理@weakify(self)后的;
 		isMatch "$line" "@weakify(self);"
 		if [[ $? == 1 ]]; then
 			command="sed -i '' '${lineNumber}s/@weakify(self);/@weakify(self)/g' $filepath"
 			eval $command
 		fi
 
 		# 清理@strongify(self)后的;
 		isMatch "$line" "@strongify(self);"
 		if [[ $? == 1 ]]; then
 			command="sed -i '' '${lineNumber}s/@strongify(self);/@strongify(self)/g' $filepath"
 			eval $command
 		fi

		# 删除每个大括号内的语句组首行的空行
		if [[ $lastLineEndWithLeftBrace = true ]]; then
			isMatch "$line" "^$" 
			if [[ $? == 1 ]]; then
				# sed 清理空行
				command="sed -i '' '${lineNumber}d' $filepath"
				eval $command
				let lineNumber--
				continue
			fi		
		fi
		isMatch "$line" "{$" 
		if [[ $? == 1 ]]; then
			lastLineEndWithLeftBrace=true
		else
			lastLineEndWithLeftBrace=false
		fi

	done < $filepath

	echo '	'————Clean完毕
	echo ''
}

traverseDir() {
	dirname=$1
	filenameList=`ls $dirname`
	for file in $filenameList; do
		filepath=''
		if [[ ${dirname:-1} = '/' ]]; then
			filepath=$1$file
		else
			filepath=$1/$file
		fi 

		judgeFilepath $filepath
		case $? in
			1) isOCFile $filepath
				if [[ $? = 1 ]]; then
					codeClean $filepath
				fi
			;;
			0) traverseDir $filepath
			;;
			*);;
		esac
	done
}

getFilepath() {
	read -p "👉  输入要清理的文件或目录：" filepath
	judgeFilepath $filepath
	case $? in
		1) echo 【这是一个文件】
			isOCFile $filepath
			if [[ $? = 1 ]]; then
				codeClean $filepath
			fi
			echo 清理完毕，感谢使用 ^_^ DeveloperLx
			echo ""
		;;
		0) echo 【这是一个目录】
			traverseDir $filepath
			echo 清理完毕，感谢使用 ^_^ DeveloperLx
		;;
		*) echo 【您输入错误，或文件不存在，请重新输入！！！】
			getFilepath
		;;
	esac
}

checkAndInstallHomeBrew() {
	if ! type "brew" > /dev/null; then
		echo "检测到您的系统上未安装Homebrew，即将开始为您安装"
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi
}

checkAndInstallClangFormat() {
	check=""
	exec 1>&2

	type "clang-format" >/dev/null 2>&1 && check="clang-format"
	if [ -z "$check" ]; then
		echo "检测到您的系统上未安装clang-format，即将开始为您安装"
		checkAndInstallHomeBrew
		brew install clang-format
	fi
}

checkAndInstallClangFormat
getFilepath
