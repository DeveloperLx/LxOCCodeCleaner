#!/bin/bash

echo ============   规范化您的代码，请按ctrl+c键退出   ============
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

codeClean() {
	filepath=$1

	echo ''
	echo Clean文件：$filepath

	while read line
	do
		# 忽略单行注释
		if [[ $line =~ '//' ]]; then
			echo $line
			continue
		fi

		# 忽略import pragma warning 等
		if [[ $line =~ '#' ]]; then
			# echo $line
			continue
		fi


	done < $filepath

	# sed -i "" 's/}else/} else/g' $filepath
	# sed -i "" 's/if(/if (/g' $filepath
	# sed -i "" 's/){/) {/g' $filepath

	echo 【清理完毕】
}

traverseDir() {
	dirname=$1
	filenameList=`ls $dirname`
	for file in $filenameList
	do 
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
			echo ""
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

getFilepath










