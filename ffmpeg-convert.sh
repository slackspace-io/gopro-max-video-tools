#!/bin/sh

USAGE="$(cat <<EOF
$(basename "$0") -i <input_file> [-o <out_dir>] [-t]
    -i: input file path
    -o: output directory, create if not exist. default to current directory.
    -t: use this flag if the input file is a timelapse video.

EOF
)"
timelapse=false
while getopts 'hi:o:t' opt; do
    case "$opt" in
        i)    input_file="$OPTARG" ;;
        o)    out_dir="$OPTARG" ;;
        t)    timelapse=true ;;
        h)    echo "$USAGE" >&2; exit 0 ;;
        \?)   echo "Invalid option: -"$OPTARG"" >&2; echo "$USAGE" >&2; exit 1 ;;
    esac
done

if [[ -z "$input_file" ]]; then
    echo "ERROR: The -i option is a required option." >&2
    echo "$USAGE" >&2
    exit 1
fi
if [[ -z "$out_dir" ]]; then
    out_dir="."
fi

shift $((OPTIND-1))

: "${div:=65}"
: "${input_file:?}"
: "${out_dir:=.}"

base_name=$(basename "$input_file")
mkdir -p "$out_dir"
echo "Created output directory: $out_dir"
outfile=$out_dir/${base_name}.mp4;

# Define the two different filtergraphs
full_video_filter_chain="[0:0]crop=128:1344:x=624:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=b,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[crop],[0:0]crop=624:1344:x=0:y=0,format=yuvj420p[left], [0:0]crop=624:1344:x=752:y=0,format=yuvj420p[right], [left][crop]hstack[leftAll], [leftAll][right]hstack[leftDone],[0:0]crop=1344:1344:1376:0[middle],[0:0]crop=128:1344:x=3344:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=b,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[cropRightBottom],[0:0]crop=624:1344:x=2720:y=0,format=yuvj420p[leftRightBottom], [0:0]crop=624:1344:x=3472:y=0,format=yuvj420p[rightRightBottom], [leftRightBottom][cropRightBottom]hstack[rightAll], [rightAll][rightRightBottom]hstack[rightBottomDone],[leftDone][middle]hstack[leftMiddle], [leftMiddle][rightBottomDone]hstack[bottomComplete],[0:5]crop=128:1344:x=624:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=n,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[leftTopCrop],[0:5]crop=624:1344:x=0:y=0,format=yuvj420p[firstLeftTop], [0:5]crop=624:1344:x=752:y=0,format=yuvj420p[firstRightTop], [firstLeftTop][leftTopCrop]hstack[topLeftHalf], [topLeftHalf][firstRightTop]hstack[topLeftDone],[0:5]crop=1344:1344:1376:0[TopMiddle],[0:5]crop=128:1344:x=3344:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=n,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[TopcropRightBottom],[0:5]crop=624:1344:x=2720:y=0,format=yuvj420p[TopleftRightBottom], [0:5]crop=624:1344:x=3472:y=0,format=yuvj420p[ToprightRightBottom], [TopleftRightBottom][TopcropRightBottom]hstack[ToprightAll], [ToprightAll][ToprightRightBottom]hstack[ToprightBottomDone],[topLeftDone][TopMiddle]hstack[TopleftMiddle],[TopleftMiddle][ToprightBottomDone]hstack[topComplete],[bottomComplete][topComplete]vstack[complete], [complete]v360=eac:e:interp=cubic,crop=4032:2388:x=0:y=0[v]"

timelapse_filter_chain="[0:0]crop=128:1344:x=624:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=b,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[crop],[0:0]crop=624:1344:x=0:y=0,format=yuvj420p[left], [0:0]crop=624:1344:x=752:y=0,format=yuvj420p[right], [left][crop]hstack[leftAll], [leftAll][right]hstack[leftDone],[0:0]crop=1344:1344:1376:0[middle],[0:0]crop=128:1344:x=3344:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=b,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[cropRightBottom],[0:0]crop=624:1344:x=2720:y=0,format=yuvj420p[leftRightBottom], [0:0]crop=624:1344:x=3472:y=0,format=yuvj420p[rightRightBottom], [leftRightBottom][cropRightBottom]hstack[rightAll], [rightAll][rightRightBottom]hstack[rightBottomDone],[leftDone][middle]hstack[leftMiddle], [leftMiddle][rightBottomDone]hstack[bottomComplete],[0:4]crop=128:1344:x=624:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=n,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[leftTopCrop],[0:4]crop=624:1344:x=0:y=0,format=yuvj420p[firstLeftTop], [0:4]crop=624:1344:x=752:y=0,format=yuvj420p[firstRightTop], [firstLeftTop][leftTopCrop]hstack[topLeftHalf], [topLeftHalf][firstRightTop]hstack[topLeftDone],[0:4]crop=1344:1344:1376:0[TopMiddle],[0:4]crop=128:1344:x=3344:y=0,format=yuvj420p,geq=lum='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cb='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':cr='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':a='if(between(X, 0, 64), (p((X+64),Y)*(((X+1))/$div))+(p(X,Y)*(($div-((X+1)))/$div)), p(X,Y))':interpolation=n,crop=64:1344:x=0:y=0,format=yuvj420p,scale=96:1344[TopcropRightBottom],[0:4]crop=624:1344:x=2720:y=0,format=yuvj420p[TopleftRightBottom], [0:4]crop=624:1344:x=3472:y=0,format=yuvj420p[ToprightRightBottom], [TopleftRightBottom][TopcropRightBottom]hstack[ToprightAll], [ToprightAll][ToprightRightBottom]hstack[ToprightBottomDone],[topLeftDone][TopMiddle]hstack[TopleftMiddle],[TopleftMiddle][ToprightBottomDone]hstack[topComplete],[bottomComplete][topComplete]vstack[complete], [complete]v360=eac:e:interp=cubic,crop=4032:2388:x=0:y=0[v]"

# Select the appropriate filter based on the presence of the -t flag
if [ "$timelapse" = true ]; then
    filter_chain="$timelapse_filter_chain"
else
    filter_chain="$full_video_filter_chain"
fi

# Construct the full ffmpeg command
ffmpeg -i "$input_file" -y -filter_complex "$filter_chain" -map "[v]" -map "0:a:0?"  -c:v h264 -c:a aac -f mp4 "$outfile"

exiftool -api LargeFileSupport=1  -overwrite_original -XMP-GSpherical:Spherical="true" -XMP-GSpherical:Stitched="true" -XMP-GSpherical:StitchingSoftware=dummy -XMP-GSpherical:ProjectionType=equirectangular "$outfile"

echo "Location of File: $outfile"
