#!/usr/bin/env bash
## Authur : SALAR MUHAMMADI
## make Bootanimation for android
## Set
declare START_TIME=$SECONDS;
###
declare -i Resize=0;
declare -i WIDTH=1080;
declare -i HEIGHT=2400;
###
declare -i initpicn=0;
declare -i xcount=1;
declare ExT='jpg';
###
declare -i makeGif=0;
declare -i fps=20;
declare delay=`echo "scale=3; 100 / $fps" | bc -l`;
declare -i loop=0;
declare parted=0;
###
declare zipOut=1;
###
declare -a allpics=();
###
echo "We are working in : `pwd`";
echo "Elapsed Time : $(( ( $SECONDS - $START_TIME ) / 60 )) min $(( ( $SECONDS - $START_TIME ) % 60 )) sec."
[[ -d new ]] && rm -r -v -f new && mkdir -v -p new;
###
declare -a items=$( ls -v src );
for item in $items; do
	echo -n "Working for $item : ";
	if [[ -d src/$item ]] && [[ $item == part* ]]; then
		mkdir -v -p new/$item;
		declare -i picn=$initpicn;
		declare -a pics=$( ls -v src/$item );
		for pic in $pics; do
			echo -n "Working for $pic : ";
			if [[ ${pic##*.} == 'jpg' || ${pic##*.} == 'png' ]]; then
				for (( c=0; c<"$xcount"; c++ )); do
					declare newpic="$(printf "%06d" "$picn").$ExT";
					[[ $Resize -eq 1 ]] && echo "Converting Image..." && convert src/$item/$pic -resize "$WIDTH"x"$HEIGHT"! new/$item/$newpic || cp -v src/$item/$pic new/$item/$newpic;
					picn+=1;
					allpics+=("new/$item/$newpic");
				done;
			else
				cp -v src/$item/$pic new/$item/;
			fi;
		done;
		initpicn=$picn;
	elif [[ -f src/$item ]] && [[ ${item##*.} == 'txt' || ${item##*.} == 'wav' || ${item##*.} == 'png' || ${item##*.} == 'jpg' ]]; then
		cp -v src/$item new/;
	fi;
done;
###
echo "Elapsed Time : $(( ( $SECONDS - $START_TIME ) / 60 )) min $(( ( $SECONDS - $START_TIME ) % 60 )) sec."
declare picsC=${#allpics[@]};
declare duration=`echo "scale=2; $picsC / $fps" | bc -l`;
######
if [[ $zipOut -eq 1 ]]; then
	cd new;
	echo "Creating Zip file...";
	zip -0vry -i \*.txt \*.wav \*.png \*.jpg @ ../bootanimation.zip *.txt part*;
	cd ..;
	chmod -v o+r bootanimation.zip;
fi;
###
if [[ $makeGif -eq 1 ]]; then
	if [[ $parted -eq 0 ]]; then
		outname="FullPart-f$picsC-fps$fps-s$duration-loop$loop.gif";
		echo "Start Converting to Gif ( $outname ) at : `date`";
		echo "Please wait ...";
		convert -monitor -delay $delay ${allpics[@]} -deconstruct -loop $loop $outname;
		echo "Elapsed Time : $(( ( $SECONDS - $START_TIME ) / 60 )) min $(( ( $SECONDS - $START_TIME ) % 60 )) sec.";
		sleep 1;
	else
		declare -a outItems=$( ls -v new );
		for outit in $outItems; do
			if [[ -d new/$outit ]] && [[ $outit == part* ]]; then
				outname="$outit-fps$fps-loop$loop.gif";
				convert -monitor -delay $delay new/$outit/*.$ExT -deconstruct -loop $loop $outname; 
				echo "Elapsed Time : $(( ( $SECONDS - $START_TIME ) / 60 )) min $(( ( $SECONDS - $START_TIME ) % 60 )) sec.";
				sleep 1;
			fi;
		done;
	fi;
fi;
######
echo "Animation Frames : $picsC"
echo "Animation Speed : $fps fps";
echo "Animation Duration : $duration s";
######
###
