#!/bin/bash
#
# Script template backup QNAP directories to external (USB) device
# ToDo:
# - get source directory list file name from command line
# - fix
#     - Do not produce RSYNC log file to external QNAP NTFS destination
#     - PC test run to /tmp FS produce RSYNC file properly

#--------------------------------------------------------------
# Mount point(s) for backup media
# $MOUNT can be also symlink to directory.
# Symlink name is same as NTFS "Volume Label" or Linux "Volume Name"

MOUNT='/tmp/BACKUP-MEDIA'            # Development time:  fake for PC testing
MOUNT='/share/HD-PZU3-black'         # Symlink point to:  external/DEV3902_1/
MOUNT='/share/WD30-RED'              # Symlink point to:  external/DEV3804_1/

#--------------------------------------------------------------
# Parse command line options

VERBOSE=0
DIRFILE=""
HELP=0
LOGS=0

while getopts "hvlf:m:" opt; do
  case "$opt" in
  # ?) HELP=1 ;;
    h) HELP=1 ;;
    l) LOGS=1 ;;
    v) VERBOSE=1 ;;
    f) DIRFILE="$OPTARG" ;;
    m) MOUNT="$OPTARG" ;;
   \?) echo "Unknown option: -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

# Create backup directory into mount point
BACKUP=$MOUNT/'BACKUP'

# echo "HELP=$HELP VERBOSE=$VERBOSE DIRFILE=$DIRFILE BACKUP=$BACKUP"
# echo "Remaining arguments[$#]: $*  -  1=$1  2=$2  3=$3"
# exit

#--------------------------------------------------------------
# Some RSYNC options:
#  --exclude=PATTERN       exclude files matching PATTERN
#  --exclude-from=FILE     read exclude patterns from FILE
#  --include=PATTERN       don't exclude files matching PATTERN
#  --include-from=FILE     read include patterns from FILE
#  --files-from=FILE       read list of source-file names from FILE
#  --log-file=FILE         log what we're doing to the specified FILE

# Capture current date and time
current_date=$(date +"%Y-%m-%d")   # Format: YYYY-MM-DD
current_time=$(date +"%H:%M:%S")   # Format: HH:MM:SS

# Combine date and time into a single timestamp
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")


do_rsync () {
    DST_DIR=$1
    SRC_DIR=$2

    LOGNAME=backup-$TIMESTAMP.log
    LOGFILE=$DST_DIR/$LOGNAME

    if [ ! -f $LOGFILE ]; then
    echo "" > $LOGFILE
    sync -f   $LOGFILE
    sleep 1
    fi

#   Not yet find solution to problem:
#   ---------------------------------
#   ./qnap-backup.sh: line 47: /share/HD-PZU3-black/BACKUP/backup-2026-11-15_11-23-20.log: No such file or directory
#   sync: can't open '/share/HD-PZU3-black/BACKUP/backup-2026-11-15_11-23-20.log': No such file or directory
#   rsync: failed to open log-file /share/HD-PZU3-black/BACKUP/backup-2026-11-15_11-23-20.log: No such file or directory (2)

    # RSYNC might backup overwritten files
    BACKUP_DIR=$DST_DIR/BACKUP-rsync
    # Backup suffix (default ~ w/o --backup-dir)
    SUFFIX='.RSYNC'

    rsync -av \
          --whole-file --update \
          --exclude '.pio' --exclude '.git' --exclude '.idea' --exclude '.vscode' \
          --exclude '*.o'  --exclude '*.obj' \
          --exclude '.@__thumb' --exclude '.@__cache' \
          --backup --backup-dir=$BACKUP_DIR \
          --log-file=$LOGFILE \
          $SRC_DIR \
          $DST_DIR
}


# ToDo: Rclone implementation
do_rclone () {
    rclone --version
}


# Test / select alternative commands
do_backup () {
    do_rsync   $1  $2
#   do_rclone  $1  $2
}


# Check here: Is backup media mounted ???
# If media is not mounted, then print error and exit.
# $MOUNT_POINT can be also symlink to mount directory.
check_backup_media () {
    MOUNT_POINT=$1

    # Check if mount point directory exists
    if [ -d "$MOUNT_POINT" ]; then
    echo "Use backup destination:  $MOUNT_POINT"
    else
    echo "ERROR: Backup destination $MOUNT_POINT is missing."
    exit
    fi
}

#--------------------------------------------------------------

check_backup_media  $MOUNT

if [ $# -gt 0 ]
then
    for source in $*
    do
    #   echo "Process backup: $source"
        do_backup   $BACKUP   $source
    done
else

# do_backup  $BACKUP  'raspi'
# do_backup  $BACKUP  'Multitasking-Esp32-HTTP-FTP-Telnet-servers-for-Arduino'
# do_backup  $BACKUP  '/media/sf_work/hdrcopy'

# do_backup  $BACKUP  '/share/CACHEDEV1_DATA/Multimedia/2016_BensaJaPetrooli'
  do_backup  $BACKUP  '/share/Multimedia/2016_BensaJaPetrooli'

fi
