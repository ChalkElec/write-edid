#!/bin/bash
#
# Created by Dr. Ace Jeangle (support@chalk-elec.com) 
# based on script from Tom Kazimiers (https://github.com/tomka/write-edid)
#
# Writes EDID information over a given I2C-Bus to a monitor.
# The scripts expects root permissions.
#
# You can find out the bus number with ic2detect -l. Address 0x50
# should be available as the EDID data goes there.

PROGRAM_STRING=write
 
# i2c bus
BUS=""

# File name
FILE=""

ARGS=$(getopt -o "bh" --longoptions "binary,hexadecimal" -n "$PROGRAM_STRING" -- "$@") || exit
eval set -- $ARGS

binaryMode=1

while true ; do
  case "$1" in
    -b|--binary)
      binaryMode=1 ; shift ;;
    -h|--hexadecimal)
      binaryMode=0 ; shift ;;
    --)
      shift ; break ;;
    "") break ;;
    *) printf "%s: unexpected argument \`%s' while processing args returned from getopt\n" "$PROGRAM_STRING" "$1" >&2 ; shift ;;
  esac
done

if [ "$#" -lt "1" -o "$#" -gt 2 ]; then
  echo "Please specifiy a valid i2c bus as first parameter and the data as second one."
  echo "Use: $0 [ --binary ] <bus> <data_file>"
  exit 1
fi

BUS="$1"

# Make sure we get a file name as command line argument.
# If not, read it from std. input
if [ "$#" -lt 2 ]; then
  FILE="/dev/stdin"
else
  FILE="$2"
  # make sure file exists and is readable
  if [ \! -f "$FILE" ]; then
    echo "$FILE : does not exist" >&2
    exit 1
  elif [ \! -r "$FILE" ]; then
    echo "$FILE : can not be read" >&2
    exit 2
  fi
fi

# Set loop separators to end of line and space
IFSBAK=$IFS
export IFS=$' \n\t\r'
# some field
edidLength=128
count=0
chipAddress="0x50"

if [ "$binaryMode" -eq 0 ] ; then
  cat "$FILE"
else
  xxd -p -g 0 -u -c 1 -l 128 "$FILE"
fi | while read line ; do
  for chunk in $line
  do
    # if we have reached 128 byte, stop
    if [ "$count" -eq "$edidLength" ]; then
      echo "done" >&2
      break
    fi
    # convert counter to hex numbers of lentgh two, padded with zeros
    h=$(printf "%02x" "$count")
    dataAddress="0x$h"
    dataValue="0x$chunk"
    # give some feedback
    echo "Writing byte $dataValue to bus $BUS, chip-adress $chipAddress, data-adress $dataAddress" >&2
    # write date to bus (with interactive mode disabled)
    i2cset -y "$BUS" "$chipAddress" "$dataAddress" "$dataValue"
    # increment counter
    count=$((count+1))
    # sleep a moment
    sleep 0.1s
  done
done

# restore backup IFS
IFS=$IFSBAK

echo "Writing done, here is the output of i2cdump -y $BUS $chipAddress:" >&2
i2cdump -y "$BUS" "$chipAddress"
exit
