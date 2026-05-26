#!/bin/bash
# Repo list
# set -x
set -e

git_mirror >& /dev/null
if test $? -ne 0; then
	PATH+=:.
fi
git_mirror >& /dev/null
if test $? -ne 0; then
	echo git_mirror not found in path
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

		# git_mirror ${r[@]} $args
		git_mirror $r $args
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

				git_mirror ${s[@]} $args
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



# function git_mirror() {
# if [ $# -lt 4 ]; then
# 	git_mirror $@ "" $args
# else
# 	git_mirror $@ $args
# fi
# }

# repos=(
# test git git@abc --extra abc
repos="
test git git@abc abc
astyle svn https://svn.code.sf.net/p/astyle/code/trunk
busybox git git://busybox.net/busybox.git
chere git git://repo.or.cz/chere.git
chromium git https://chromium.googlesource.com/chromium/src.git
comical svn svn://svn.code.sf.net/p/comical/code/trunk
console-devel hg http://hg.code.sf.net/p/console-devel/code
cvs-fast-export git git://gitorious.org/cvs-fast-export/cvs-fast-export.git
cvsps git git://gitorious.org/cvsps/cvsps.git
daphne-emu svn https://www.daphne-emu.com:9443/daphnesvn/branches/v_1_0
darwinbuild svn http://svn.macosforge.org/repository/darwinbuild/trunk
desmume svn https://svn.code.sf.net/p/desmume/code/trunk
dmidecode git http://git.savannah.gnu.org/r/dmidecode.git
env-man git git://env-man.git.sourceforge.net/gitroot/env-man/env-man
equalizerapo svn svn://svn.code.sf.net/p/equalizerapo/code/trunk
firmware-mod-kit svn http://firmware-mod-kit.googlecode.com/svn/trunk
freedownload svn svn://svn.code.sf.net/p/freedownload/code/trunc
hydrairc svn http://svn.hydrairc.com/hydrairc/trunk
jdownloader svn svn://svn.jdownloader.org/jdownloader/trunk
launch4j git git://git.code.sf.net/p/launch4j/git
levelzap git https://git01.codeplex.com/levelzap
libdvdread git git://git.videolan.org/libdvdread.git
libdvdnav git git://git.videolan.org/libdvdnav.git
libosinfo git http://git.fedorahosted.org/git/libosinfo.git
libX11 git git://anongit.freedesktop.org/xorg/lib/libX11
libXi git git://anongit.freedesktop.org/xorg/lib/libXi
listfix svn https://svn.code.sf.net/p/listfix/code/dev
make git git://git.savannah.gnu.org/make
mesa git https://gitlab.freedesktop.org/mesa/mesa
mesa-demos git https://gitlab.freedesktop.org/mesa/demos
mingw-org-wsl git git://git.code.sf.net/p/mingw/mingw-org-wsl
mingw-w64 git git://git.code.sf.net/p/mingw-w64/mingw-w64
model3emu svn https://svn.code.sf.net/p/model3emu/code/trunk
moin-1.9 hg https://bitbucket.org/thomaswaldmann/moin-1.9
moin-2.0 hg https://bitbucket.org/thomaswaldmann/moin-2.0
ncurses git git://ncurses.scripts.mit.edu/ncurses.git
newlib-cygwin git git://sourceware.org/git/newlib-cygwin.git
nulldc svn http://nulldc.googlecode.com/svn/trunk
odin svn https://svn.code.sf.net/p/odin-win/code/trunk
patch git git://git.savannah.gnu.org/patch.git
pcsx2 svn http://pcsx2.googlecode.com/svn/trunk
pcsxr svn https://pcsxr.svn.codeplex.com/svn/pcsxr
pinmame svn svn://svn.code.sf.net/p/pinmame/code/trunk
plainamp svn svn://svn.code.sf.net/p/plainamp/code/trunk
plibc svn https://svn.code.sf.net/p/plibc/code/trunk/plibc
processhacker svn svn://svn.code.sf.net/p/processhacker/code
qemu-android git https://android.googlesource.com/platform/external/qemu
r svn https://svn.r-project.org/R/trunk
rarfilesource git http://www.v12pwr.com/RARFileSource.git
reactos svn svn://svn.reactos.org/reactos/trunk
rtmpdump git git://git.ffmpeg.org/rtmpdump.git
scintilla hg http://hg.code.sf.net/p/scintilla/code
scite hg http://hg.code.sf.net/p/scintilla/scite
sed git git://git.savannah.gnu.org/sed.git
smartmontools svn https://svn.code.sf.net/p/smartmontools/code/trunk/smartmontools
soundtouch svn https://svn.code.sf.net/p/soundtouch/code/trunk
tclap git git://git.code.sf.net/p/tclap/code
tinycc git git://repo.or.cz/tinycc.git
vbam svn https://svn.code.sf.net/p/vbam/code
vbox svn https://www.virtualbox.org/svn/vbox/trunk
virtualjaguar git http://shamusworld.gotdns.org/git/virtualjaguar
VMsvga2 svn svn://svn.code.sf.net/p/vmsvga2/code/VMsvga2/trunk
waver bzr lp:waver
wget git git://git.sv.gnu.org/wget.git
winscp cvs :pserver:anonymous@winscp.cvs.sourceforge.net:/cvsroot/winscp winscp3
x264 git http://git.videolan.org/git/x264.git
xmlrpc-c svn http://svn.code.sf.net/p/xmlrpc-c/code '--ignore-paths=^(release_number|super_stable|userguide)'
xmlstar git git://git.code.sf.net/p/xmlstar/code
xserver git git://anongit.freedesktop.org/xorg/xserver
# )
"

# The following projects are dead:
# vba-rerecording svn http://vba-rerecording.googlecode.com/svn/trunk

# already at https://github.com/DD-WRT-CN/ddwrt
# dd-wrt svn svn://svn.dd-wrt.com/DD-WRT
# https://github.com/Wiimm/wiimms-iso-tools
# wiimms-iso-tools svn http://opensvn.wiimm.de/wii/branches/public/wiimms-iso-tools

# mirror
mirror2 
