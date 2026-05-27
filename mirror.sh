#!/bin/bash
# Repo list dispatch 
# set -x
set -e
source repos

git-mirror >& /dev/null
if test $? -ne 0; then
	PATH+=:.
fi
git-mirror >& /dev/null
if test $? -ne 0; then
	echo git-mirror not found in path
	exit 1
fi

# exit

for arg in "$@"; do
	# echo -- $arg
	case "$arg" in
		-t*)
			istype=$(echo $arg|cut -c 3-)
			if ! [[ $istype =~ bzr|cvs|git|hg|svn ]]; then
				echo invalid type $istype
				exit 1
			fi
			;;
	esac
done

args=$@
# set -x

mirror2(){
	i=0
	while IFS= read -r -d $'\n' r <&3; do
		test -z "$r" && continue
		# echo $r

		# echo ${#r[@]}
		# type=${r[1]}
		name=$(echo $r| cut -d" " -f1)
		type=$(echo $r| cut -d" " -f2)

		# echo type $type
		if [ -n "$istype" -a "$istype" != "$type" ]; then
			:
			# echo skipping $name
			# echo skipping $name $type!=$istype
			continue
		fi

		# echo dispatch $r $args
		# printargs $r $args
		# printargs ${r[@]} $args

		# git-mirror ${r[@]} $args
		git-mirror $r $args
		if test $? -eq 9; then
			exit
		fi

		# test $i -gt 1 && exit
		: $((i++))
	done 3<<<"$repos"
	exit
}

mirror(){
	i=1
	j=1
	skip=0
	for r in ${repos[@]}; do
		# echo $i $j

		if test $skip -gt 0; then
			# echo skipping $j
			: $((--skip))
			: $((i++))
			continue
		fi
		s+=($r)

		next=${repos[$(($i))]}
		# echo $i $j $r next=$next
		# echo $i $j $r next=$next i%3=$(($i%3))
		# exit
		if test "$next" = --extra; then
			extra=${repos[$(($i+1))]}
			s+=($extra)
			# echo extra: $extra
			skip=2
			# else
			# : $((i+=2))
			j=3
		fi

		# elif test $i -eq 4; then
		# if test $(($i%5)) -eq 0; then
		if test $j -eq 3; then
			name=${s[0]}
			type=${s[1]}
			if [ -n "$istype" -a "$istype" != "$type" ]; then
				:
				# echo skipping $name
				# echo skipping $name $type!=$istype
			else
				if [ ${#s[@]} -lt 4 ]; then
					s+=("")
				fi
				# echo dispatch $name 
				# echo dispatch: ${s[*]} $args
				# printargs ${s[@]} $args

				git-mirror ${s[@]} $args
				if test $? -eq 9; then
					exit
				fi

			fi
			s=()
			j=0
		fi

		# test $i -gt 10 && exit
		: $((i++))
		: $((j++))

	done
}

# mirror
mirror2 

# function git-mirror() {
# if [ $# -lt 4 ]; then
# 	git-mirror $@ "" $args
# else
# 	git-mirror $@ $args
# fi
# }

