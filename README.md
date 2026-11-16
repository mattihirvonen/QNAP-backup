
# QNAP backup script

This is study what features I need when backup my QNAP NAS to external USB drive
(or other backup destination like an other NAS server). Here we use RSYNC command
line commamand as backend engine. QNAP's own *Hybrid Backup Sync 3* (HBS3) application
use also rsync as backend engine (so this script do not technically offer much new
features to backup or sync process).

## Usage and Command Line Options

```text
Usage: ./qnap-backup.sh [OPTIONS] [SourceDir1] [SourceDir2] ...

Command line options:

  -h             this help
  -s filename    text file for backup source directories list
  -m dirname     backup device mount point directory name (default is '/share/WD30-RED')
  -b dirname     backup directory name in backup mount point (default is 'BACKUP')

```

## What to Exclue From Backup

One big thing is to selective exclude files or directories from backup set.
Many applications generate (huge amount) "hidden internal" work space data.
Data can be much larger than application's original "source data".
This data can many times exclude from backup because application re-generates
this data "on the fly" (save space on backup or large amount annouying "dummy"
temporary files).

Here is some examples which generate hidden or a lot of work space data:

- Photo Galleries (QNAP's Photo Station, Piwigo, TinyWebGallery, outdated Gallery3)
- VisualStudio Code pioarduino and PlatformIO blugin projects
- Other IDE tool project data (CodeBlocks, JetBrains: IntelliJ IDEA, PyCharm)
- CppCheck
- GIT

### Photo Galleries

Photo galleries might generate real huge amount runtime used resized picture files and thumbnails
(tens of giga bytes and tens of thousands files in my case). Typically each original picture is
renderd to many different smaller picture sizes to optimize web page service (from "picture cache").
Rendered pictures together can consume more disk space than original picture !!!

- *QNAP's Photo Station* newer versions are gone so social that there is any more no good method
  handle user access rights (in web service, in praxis every one see everyting or noone see anything).
  I have retired and disabled my Photo Station application and multimedia features,
  but there still popups thumbnail directories.
- *TinyWebGallery* is good light weight photo gallery / presentation software for older less powerfull
  web server (my TS-419P2, 32 bit arm, 1.9 GHz). Smooth service based strong on pre generated
  different sized pictures and thumbnails (which takes huge amount disk space).
- *Piwigo* is good compromise between CPU resource requirements and user access rights management.
  My TS253S is a bit weak to generate 10 "tiles" picture from gallery on the fly to web page
  (original pictures are typically few mgabytes each). My newer Intel N100 CPU based is enough strong
  to render pictures on the fly. Piwigo is designed to use also in large web services.
  Piwigo generates on the fly picture cache to optimize operation to (re)show requested pictures
  or tiles on web pages.

Exclude following items from backup:

- *\.@__thumb .@__cache* directories


### VisualStudio Code pioarduino and PlatformIO Blugin Projects

VScode pioarduino and PlatformIO blugins generates hidden directory tree ".pio" into project.
There are typically tens to hundreds of of mega bytes library and tools data each software project.
This directory tree will regenerate on the fly when change project's configuration file
(platformio.ini) and rebuild project. It is wise to exclude this work space directory tree from backup.

### Other IDE Tool Projects

Other IDE tools generate hidden or temporary build time intermediate directories / files.

> JetBrains (jIDEA and PyCharm) create hidden directory ".idea" whic contains project settings.
  Files in this directory typically take small amount of disk space (no need to exclude).
> CodeBlocks build process can generate much small annoying small temporary work space
  directories and files. These directories and files can safely exclude from backup.
 
### GIT

All data in "hidden" *.git* subdirectory is GIT's local "database" about project's state and history.
If we exclude this data we also lost project's version control data (no good idea to exclude?).

## ToDo:

Fix:
> - Do not produce RSYNC log file to external QNAP NTFS destination
> - PC test run to /tmp FS produce RSYNC log file properly
