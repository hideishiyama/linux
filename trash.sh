#!/bin/bash

# 関数の読み込み
. function

# 引数の確認

# オプションの確認
while getopts ":e" OPT; do
	case $OPT in
		e) _FLAG=erase ;;
		\?) ;;
	esac
done
shift $(( $OPTIND - 1 ))

# 変数の定義
_FILES=$@
_TRASH=".trash"
_SUFIX=$(date +%Y%m%d_%H%M%S)

# ゴミ箱の確認
[ -d "$_TRASH" ] || mkdir "$_TRASH"
[ $? != 0 ] && { err_msg "$0" "Making trash was faild."; exit 1; }
[ -d "$_TRASH" -a -r "$_TRASH" -a -w "$_TRASH" -a -x "$_TRASH" ] ||\
	{ err_msg "$0" "Trash does not exits or permission denied."; exit 1; }

# ゴミ箱を空にする
if [ "$_FLAG" = "erase" ]; then
	# ゴミ箱を空にする
	echo -n "May I empty the trash? (y/n): "
	read _ANS
	if [ "$_ANS" = "Y" -o "$_ANS" = "y" ]; then
		rm -rf "$_TRASH"/*
		echo "I emptied the trash."
	else
		exit
	fi
fi

# ゴミ箱を表示する
if [ "$#" = 0 ]; then
	ls -l "$_TRASH"
	exit
fi

# ゴミ箱に移動する
for _FILE in $_FILES; do
	[ -f "$_FILE" -a -w "$_FILE" ] ||\
		{ err_msg "$0" "$_FILE does not exits or permission denied."; exit 1; }
	mv "$_FILE" "${_TRASH}/${_FILE}.${_SUFIX}" &>/dev/null ||\
		{ err_msg "$0"  "Failed to move $_FILE."; exit 1; }
done
