#!/bin/sh
Capture_Script_Version=101221
###########################################################################################################################
export Capture_Script_Version
###########################################################################################################################
#
# File:  lsigetlunix.sh (Don't change this line, used in Solaris grep test)
#
# 
# See Readme.txt (Embedded further down)
#
#  How to run it:
#    1) Copy the included files to a file system with available space. 
#       In general, the size of the data collected is at least as big as the total size of
#       all log files.
#    3) Run it:   ./lsigetlunix.sh -H <enter> for help screen
#
# 
#  What to do when the script ends:
#    1) Send the .tgz file to Technical Support or to the FAE that you are in contact with.
# 
#  What to do when receiving the .tgz file:
#    1) Extract
#    3) Verify files are not empty & Controller_Cx.txt and/or Adapter_Ax.txt files are present.
#    4) Analyze the collected data 
#
#
#
# 02/20/10 - To many major changes have occurred to document them all. Revamped capture script that supports 3ware, MegaRAID
#	     & HBA's. All changes from here on out to be documented. 
# 02/21/10 - Grep'ed disk specific parameters together for easier troubleshooting for 3ware, already on MegaRAID. Added modpgctl.
# 02/22/10 - Fixed HBA version reporting.
# 02/24/10 - Changing export to x=y for FreeBSD, may break MacOS or Solaris, need to verify. Changed -? to -H for Help, 
#            reserved on FreeBSD. Grep MegaRAID specific info in FreeBSD messages file. 
# 02/25/10 - Fixed grepped disk specific parameters for multiple controllers on 3ware. Added FreeBSD Support for MegaRAID & HBA.
# 	     Cleaned up CLI naming/arch. Excluded all MegaRAID/HBA sections if MacOS. Changed to gunzip instead of tar -zxvf for 
#            Solaris. Added MegaRAID specific logging for Solaris. Added additional files to cleanup. 
# 04/10/10 - Added check for "OS_LSI"="" (Ubuntu others?), added check for iuCRC on MegaRAID. 
# 06/19/10 - Rearranged data for easier troubleshooting, less use of MegaCli, more grepping of master file for better performance.
#	     Created separate files for pdlist/adpalilog/adpallinfo/fwtermlog & added master file name to all as well as 
#	     adapter_ax.txt file (fwtermlog and all relevant data still in adapter_ax.txt file. Created separate files for grepped
#            fwtermlog errors to make it easier to read fwtermlog (instead of appending to end).
#
# 06/20/10 - GCA Release - Updated MegaCli to 10M05, updated help, fwtermlog errors in separate subdir.
#
# 09/14/10 - Added workaround for customer distribution. Updated MegaCli to 10M08. Updated tw_cli to 10.2 (esx35/40 still at 9.5.3)
# 09/15/10 - Replaced bad tw_cli images, readme update.
# 10/11/10 - Added beta 64bit MegaCli for FreeBSD
# 10/13/10 - Added 10M10/8.00.39 32/64bit MegaCli for FreeBSD, updated obsolete 3ware links to lsi.
# 10/25/10 - Changed uname -i to uname -s on custom OS check. Added 10M09/8.00.40 32bit MegaCli as 32/64bit for FreeBSD
# 11/24/10 - Added RC 10M09 8.00.36/8.00.39 32/64bit FreeBSD MegaCli's
# 02/16/11 - Added vars to internal util. Grabbing contents of /boot and menu.lst, updated cversions for 3w & MR.
# 03/11/11 - Updated MegaCli to 10M09P3/8.00.046 (10M10), Internal util to 1.66
# 03/17/11 - Added mrmonitor and vivaldiframeworkd status check.
# 03/25/11 - Fixed "mrmonitord: error while loading shared libraries: libxerces-c.so.28: cannot open shared object file: No such 
#            file or directory" error, now check "/etc/init.d/mrmonitor -v" instead of "mrmonitord -v". Updating ELF query, DS 3,
#            misc command additions and formatting changes. Updated MegaCli to 10M12/8.01.06 for all OSs but FreeBSD. Updated 
#            HBA section to better support Warp, still need separate cli. Added  tip for Solaris script issue.
#	     Started to use new adpalilog driver version feature, doesn't rely on modinfo which can provide false info as to whats 
#	     loaded.	
# 03/28/11 - Replaced bad copy of tw_cli for Solaris. Solaris old default shell workaround.		
# 03/28/11 - Additional hostname variable support.		
# 03/31/11 - GCA Release - Added -i for OSTYPE grep for all OSs, FreeBSD 6.1 uses lowercase. Replaced bad copy of tw_cli for FreeBSD.
# 06/17/11 - Added BETA MegaCli(64) from 11M06
# 09/28/11 - Added tw_cli from 10.2.1 code set, fixed issue with show diag not working with older fw.
# 09/30/11 - Moved /conf create and some file copies to main subdir creation section, cleaned up file cleanup logic on close/continue.
# 10/06/11 - Upgraded internal util to 1.67.
# 10/07/11 - Cleaned up grep of messages, for drivers, i.e. "kernel: driver" not valid in all distributions/versions.
# 10/09/11 - Added check for MR LD consistency, MR PCI Info, lsipci -t and grep for only 1st driver instance in Adpalilog.
# 01/27/12 - Updated MegaCli(64) to 8.02.21-1/11M08P3, added lsscsi support, perfmode.
# 02/02/12 - Added option 17 to internal util.
# 03/14/12 - Updated Linux MegaCli(64) to 8.03.07(Beta) to support the Linux 3.x Kernel.
# 05/24/12 - Added collection of WarpDrive info and ddoemcli exec files to 
#            support collection.  Added collection of Nytro XD info.
#            Updated MegaCli and MegaCli64 to 8.04.07 for Linux, FreeBSD, and
#            Solaris.
# 09/21/12 - Update collection of WarpDrive info to use lsi_diag.sh script if
#            available.  Added collection of Nytro MegaRAID info. 
#            Updated internal util to 1.69 and dd*cli to 01.250.41.10.
#            Updated MegaCli to 8.04.52 for Linux to pull in new commands for
#            Nytro MegaRAID.
# 11/15/12 - Added filtering for additional error messages. Updated 3ware errorcodes/aens to 9.5.5.1. 
#
# 01/23/13 - Cleaned up some old KB references. Changed clean up list/create script, got rid of old dependencies. Deleted all versions 
#            of MegaCli except for Solaris, still a dependency issue and replaced with Phase 3/1.02.08 storcli, still keeping MegaCli 
#            syntax for now and will add storcli syntax overtime. Updated 3ware & MR AEN grep list to 10.2.2.1 & 5.5 respectively.
#
# 02/16/13 - AEC and DPMSTAT added for MegaRAID. Added /MegaRAID/storcli, MegaCli and AENs/Info, Warning, Critical & Fatal subdirs. 
#            Added storcli output. Fixed indentation for if/for statements until end of storcli section. General cleanup and house keeping.
#
# 02/27/13 - Additionally separated AENs controller/type, compared pds by all variables, started to compare MR controllers by all variables.
#	     Pulled Sco cli's/build. Partial update of cversions_MR. Added driver build scripts and notes. Added vall show all for storcli.	
#	     Display all available temperature info. Support for udevadm & udevinfo. Fixed file clean up. Check if MR adapter exists before 
#	     capturing data with storcli.
#
# 03/02/13 - Added missing cx/vd/pd status/state checks with storcli.	
#
# 03/06/13 - Pulled out udevadm support - Hung OpenSuse 12.2 32bit and Centos 6.3 64bit. Fixed AEN separation, mrmonitord and MSM have different formatting of output.
#	
# 03/08/13 - Added /cx/eall show status, fixed comment when using lower case for variables, updated storcli to 1.03.11 (5.6).
#
# 04/26/13 - Added /cx show bios for storcli, Updated storcli to 1.04.07 (beta) except for Solaris. Issue with Solaris build currently. Beta drop of storcli adds NMR support.
#
# 05/29/13 - Added /cx/cv as /cx/bbu doesn't get cv info anymore with storcli. 1.04.07 storcli is now GCA and part of the 5.7 release.
#
# 08/02/13 - Added grep for "PCIE Link Status/Ctrl" in termlog for PCI-E link speed, in 2208 only. Need PR to include in "show pci" fro storcli.
#
# 11/26/13 - Added 25-2-0-0 dump on HBA. Updated storcli to 1.06.03 (5.9) for FreeBSD/Linux/Solaris, libstorelibir-2.so.14.07-0 included for Linux to support /XD.
#	     Updated internal util to 1.70. Updated dcli to 111.00.01.00. Added all /XD show commands. Added -power, -dump & -getpowerval to dcli output fro WD.
#
# 12/04/13 - Fixed solaris support, added "export LD_LIBRARY_PATH=/usr/sfw/lib" for libstdc++.so.6 & libgcc_s.so.1 for storcli. Solaris 10 does not have 
#            /usr/gnu/bin/grep  that supports the -A option so some comparisons of storcli output are not done. Fixed > null to >> ./misc_output.txt in two locations. 
#	     Fixed some exports for Solaris. Replaced all "if [ -e" options with -f. 2>&1 for whoami and groups output. 
#
# 01/07/14 - Replaced "if [ -f" with "if [ -e" on all checks for /sys/block/sdx. Increased 3ware smartctl support to 128 disks IF smartctl supports it. Moved creation of
# 	     sd_letter.txt before controller specific section to avoid duplication of sd entries. Fix smartctl capture on new 5.43 smartmontools, requires "sat+" for SATA disks.
#            Changed Readme to reflect MacOS is no longer being tested with this script but support was not explicitly removed.	
#
# 01/12/14 - Changed test for autobgi check to "No VDs have been configured". Fixed indentation formatting on "Solaris Work Around". Eliminated 2 "Solaris Work Around's"
#	     on the Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt file. Added show eghs and removed old syntax. Fixed MR DPM output file comments.
#
# 01/26/14 - Added Progress & Obsolete as AEN severity's to manage. Updated AENs to MR 6.2/storelib 4.14.
#
# 02/06/14 - Added lvm info capture, vgs, lvs, pvs, lvdisplay, pvdisplay & lvm.conf to /lvm
#
# 02/22/14 - Fixed Call_Eall_Sall_show_all-Compare-All-Parms.txt output, inquiry string going to Call_Eall_Sall_show_all-Compare-All-Parms_Cx.txt
#	     Added test to only do /cx/cv or bbu show/all if the device is present, storcli bug workaround. Removed duplicate file name in /call/eall show status output.
#	     Took PD wrcache out of /call/eall/sall output, set per VD, not PD.	Fixed Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt output, drives line had typo.
#            Added status to Call_show_all-Compare-All-Parms.txt
#
# 03/02/14 - Adding VMWare support, removed all tr commands on in common OS commands. Updated all storcli images to 6.2/1.07.07 except Solaris, need Solaris system to extract pkg file.
#            Updated all tw_cli images to 10.2.2.1/2.00.11.022. Updated all internal util images except 32bit Linux to 1.71, not available. Only including 32bit storcli/LSI WarpDrive Management Utility/internal util
#            binaries, tw_cli requires 32/64 bit versions. Don't do tw_cli /cx/px show smart/all in vmware, segfault, open defect, do each unique attribute - smart.
#	     Made date '+%H:%M:%S.%N' conditional on OS, vmware is date '+%H:%M:%S. Copying $MCLI_LOCATION$MCLI_NAME/* & /var/log/*. Replacing vmware tw_cli with  2.00.11.016esxi due to segfaults.
#	     Redirect stderr for internal util to "2>>./$fileName/script_workspace/lsiget_errorlog.txt" as its a linux util and produces the following errors on vmware "sh: /sbin/modprobe: not found"
#            and "mknod: /dev/mptctl: Function not implemented". Rearranged initial variables. Added esxcli output, combined common binaries under common OS section. Put all lsi product data
#            under /LSI_Products. Have only tested vmware 5.1.0, allow script to run on 5.x, 4.x & 3.x, BETA ONLY!
#            
# 03/11/14 - Added support for VMWare 5.5.0 & 4.1.0. Added back all 64bit binaries that I removed. If 64bit OS, try 64bit utils, if it doesn't work try the 32bit versions.
#            Changed some of the cli logic. 
#
# 03/17/14 - Made dmesg collection conditional. Added capture of /var/log/vmware conditionally. Piped standard out on a number of cli commands to ./$fileName/script_workspace/lsiget_errorlog.txt in 
#            order to avoid "/bin/sh: /usr/libexec/pci-info: not found" errors on VMWare 4.1. Segregated esxcli 4.x and 5.x commands.
#
# 03/21/14 - Added dmidecode/biosdecode & dvpdecode commands.
#
# 04/04/14 - Removed Linux only test for smartctl, should work in FreeBSD as well. Added EID 252 for Nytro pddffdiag  dump.
#
# 04/23/14 - Got rid of _all output for internal tool.
#
# 06/23/14 - Changed grep string for CV detection from SuperCaP to Cachevault_Info. Released version only includes Linux/FreeBSD/VmWare, Solaris cli's need to be added, script tested.
#
# 06/25/14 - Added "fdisk -lu" collection, updated storcli to (6.3) 1.09.08 on for linux/freebsd/vmware. Added SKIP_XD variable as storcli 1.08.09 segfaults on /xd show with Invader.
#
# 07/16/14 - Added LSI expander data collection, xu 16.00.00.00 and g3xu 5.00.00.00.
#
# 07/18/14 - Changed grep to account for G3 expander format.
#
# 07/24/14 - Modified xu/g3xu output.
#
# 07/28/14 - Added Perf_Summary_File.txt file, duplicate info from other files all in one.
#
# 07/29/14 - Fixed formatting. i.e. lined up if/fi's, while/done's, etc.
#
# 07/30/14 - Increased grepping of messages.x files from 20 to 200, changed Perf_Summary_File.txt file to Summary.txt
#
# 08/01/14 - Fixed e_dpmstat, output was being piped to non existent subdir.
#
# 08/28/14 - Added get attach to xu/g3xu capture.
#
# 08/29/14 - Fixed bug where Solaris X86 OS check was after exit of script for OS_LSI not being set.
#
# 09/02/14 - Commented out cleanup with re_execute_variable_shell.txt section. Added grepA=grep as default and grepA for g3xu/xu execution.
#
# 09/08/14 - Changed to grepA variable for -m parameter support in Solaris.
#
# 09/09/14 - Removed support for Nytro WD/XD due to sale of division to Seagate. Updated all storcli versions to 6.4/1.12.13.
#
# 09/26/14 - Added collection of ManPages 16-31 on HBAs. Updated internal util to 1.72. 
#
# 10/24/14 - Added additional data collection for LSI expanders and changed sub dir structure from /12Gb to /6-12Gb
#
# 10/27/14 - Added show output for MR/3W/HBA CLIs into script_workspace subdir. Updated Readme to reflect new code sets and VMWare support.
#
# 11/19/14 - Added collection of Region 0 on LSI expanders.
#
# 11/26/14 - Added checks if HBA's exist before running internal tool. Broke expander data collection into SAS 1/2/3, need to fine tune detection criteria.
#            
# 12/19/14 - Added check for LDBBM support, dump the bbmt for each VD, dump the enclosure phyerror counters, grep for persistent nvdata version.
#
# 02/25/15 - Added "2>>./$fileName/script_workspace/lsiget_errorlog.txt" to a few locations where it was missed on 3/2/14. Fixed create script to add internal util to vmware script.
#
# 03/17/15 - Added option 66 for internal util.
#
# 03/22/15 - Capturing additional expander info, cleaned up existing presentation. Added new data to Summary.txt file.
#
# 04/08/15 - Added objdump -ld for all mpt3 drivers.
#
# 04/10/15 - Added additional files to the exclude list for /etc.
#
# 05/18/15 - Added ls -latrR of /boot, /proc, /sys and /dev. Removed duplicate var/log/messages* collection.
#
# 05/19/15 - Added dump of LSI Expander enclLogicalId
#
# 06/06/15 - Added the ability to enable/disable linux HBA driver logging, register a Ring Buffer and to automatically read/release/unregister the RB is enabled.
#	     Updated the help for DPMSTAT/AEC to include MR as well as the new features.
#
# 06/07/15 - Added sas2ircu and sas3ircu output for linux/solaris and freebsd, vmware binaries are included but execution support not added yet.
#
# 06/08/15 - Allowing the script to run on VMWare 6.x for testing.
#
# 06/09/15 - Enabled VMWare 6x to run the same esxcli commands as 5x.
#
# 06/10/15 - Saved smartctl -h output to the script_workspace subdir for debugging.
#
# 06/11/15 - Added lsblk output, included set_logging_level_sas2/3.sh scripts, included info to allow HBA driver logging without losing /var/log/messages entries
#            as well as other info in /HBA/Notes_Scripts.
#
# 06/15/15 - Added cat /proc/cmdline capture.
#
# 06/16/15 - Added journalctl output and grab all .conf files in all primary child subdirs of /etc. Fixed RB enable message. 
#
# 07/08/15 - Added udev ata_id and scsi_id output. Fixed ls of /dev/disk/by-* data collection. Replaced all a-z sdX references with actual existing sdXYZ device nodes.
#	     Moved output of hba util to when the check takes place and tee the output of the command to a working subdir file.	
#
# 07/09/15 - Added strace to internal util output. Hard coded for linux, this  needs to be fixed for general distribution.
#
# 07/13/15 - Added ssptdebug and showlogs detail to expander data collection
#
# 07/14/15 - Commented out scsi_host capture, needs to be fixed. Also commented out g3xutil and xutil for debugging.
#
# 07/17/15 - Removed check for Readme.txt
#
# 07/18/15 - Added -SX/-sx command line switch to not run xutil and g3xutil for debugging SG driver related issues.
#
# 07/19/15 - Fixed check for print of /sys/block info to verify the device exists, i.e. not a sdX1 partition. Removed 3ware perf tuning section,
#            made generic perf section more generic.	
#
# 07/22/15 - Added cat of /sys and /proc/scsi, added ipmi lan print for local debugging that goes with ifconfig, can be disabled with -SN switch. 
#            Added switches for 3f8 driver logging.
#
# 08/04/15 - Added "grep -r . /proc/sys/kernel/" data collection, added avago in lspci grep for Controller_Disk_Association.txt. Replaced 1_8_16_17_25-2-0-0_42_47_21-1-2_HBA$i.txt
#	     with properties_hba$i.txt. Fixed some typo's. 
#
# 08/07/15 - Send stderror of udevadm --version to .txt file. Capture expander coredump region if [ -fs. Moved Generic_Perf_Tuning* into its own subdir.  
#
# 08/09/15 - Changed all expander output files to start with the SAS Address, moved all individual output files to the appropriate Exp dir under Details.
#	     Changed order of hba output to follow util option #'s numerically.
#
# 08/10/15 - Updated Sense-Key_ASC-ASCQ_Opcodes_SBC4R16.txt to include ATA Command/Set Features codes and changed the name to Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code.txt
#	     Updated HBA_Debug_Notes_Linux.txt
#
# 08/10/15 - Removed capture of showlogs for the expander, left "showlogs detail". Capture Gen3 expander coredump only if generated, removed download of region.
#
# 08/11/15 - Removed strace of internal util, added TWSETONLY variable to clean up logic and added CPU affinity capture, get_cpu_affinity.txt.
#
# 08/12/15 - Changed time in RB filename to reflect time when RB finished.	
#
# 08/17/15 - Updated syntax recommendation for irqbalance.
#
# 08/18/15 - Added trigger_ext.sh, trigger_test.sh, ssl2.sh and ssl3.sh to aid in automated data collection. Got rid of set_logging_level_sas2.sh
#      	     and set_logging_level_sas3.sh scripts in /HBA/Notes_Scripts subdir. Removed support for pathed MR cli and forced prompt for comment.
#
# 08/19/15 - Added HBA debugger output data collection.	
#
# 08/24/15 - Cleaned up /proc data collection section, added scsi_logging_level -g collection. Fixed bug in IOC/HBA iop/pl data collection logic.
#	     If a Ring Buffer (RB) exists in the Working Directory, mv it to the /HBA subdir and prefix it with In-WD_. Looking for RBs in the 
#            format of "IOC2_082415.122855.105962044.rb" as created in the trigger_ext.sh among other scripts.
#
# 08/27/15 - Added internal debug scripts, automatic collection of trigger output files and new -PT switch for lsiget output naming when used in a trigger script.
#
# 09/24/15 - Took out version test for smartmontools to run with MR.
#
# 12/04/15 - Took out erroneous OS_LSI=linux variable that was left over from debug.
#
# 12/20/15 - Generic housekeeping, fixed typo in external debug scripts readme, upgraded utility versions to latest. Added a number of new cx vx px show commands.
#
# 12/21/15 - Missed a utility update.
#
# 01/13/16 - Fixed -B switch, script exited if no Avago LSI products.
#
# 01/25/16 - Took out deletion of create.sh for internal use.
#
# 01/28/16 - Spell checked script. Put in -f check of /sys/block/sdX/queue data collection. Added additional lspci cmd line options.
#
# 02/12/16 - Uncommented coredump save for expander
#
# 02/25/16 - Added storcli /cx show termlog type=config
#
# 03/02/16 - Fixed error on Expander/12Gb/Details subdir create, introduced in 022516 version.
#
# 04/21/16 - Fixed MegaRAID smartctl output, worked at one point in time, not sure when the bug was introduced. Need to redo logic to make cleaner.
#
# 04/21/16 - Changed all " >> ./misc_output.txt 2>&1" instances to " >> ./misc_output.txt 2>&1". Changed all "2>>./$fileName/script_workspace/lsiget_errorlog.txt" instances
#	     to "2>> ./misc_output.txt". Changed all variations of piping to /dev/null to ./misc_output.txt.	
#
# 04/23/16 - Created seperate Internal and Internal with Scrutiny capture scripts. Deleted cversions_xxxx files and stopped separate version checking. 
#
# 04/25/16 - No longer sort MRMON AENs, now sort all controller AENs by type/controller. Added -UMS/-SMR/-S3W/-SHBA/-SEXP/-SC/-SRC/-SRS/-SDS/-F1/-F2/-F3/-F4/-EXT switches.
#            Still need -SCDA (Need to add CDA). Updated AEN list to 6.12.
#
# 05/18/16 - Delete lastlog from capture prior to compression.
#
# 05/19/16 - Dont copy /var/log/lastlog.
#
# 05/23/16 - Added PRERELEASE g3xu and scl for Cub support in the INTERNAL builds. Scrutiny GUI is bundled in the -IS build, doesnt currently work as is, need to investigate.
#
# 06/06/16 - Made check for arch before running g3xu.
#
# 06/07/16 - Added scli check for devices before exiting.
#
# 06/08/16 - Added if exist check for cub scli, only in internal version.
#
# 06/27/16 - Added additional serdes info to output file as well as ioc cli commands.
#
# 07/01/16 - Added back in a ls -latrR of /sys, it was commented out for some reason.
#
# 07/06/16 - Rebuilt on Centos, issues with building on OpenSuse
#
# 08/03/16 - Added 32bit version of lsut.
#
# 08/04/16 - Fixed -PT option, if -PT only get journalctl -a from time of test start. Added check for journalctl_time.txt file for only dumping the journal from the start of a test for triggered captured.
#
# 08/10/16 - Added Alpha scli for expander virtual cli support for -I version, works with MR/3rd part HBA's/RAID Cards.
#
# 10/04/16 - Replaced all grep instances with $grep for Solaris compatability
#
# 02/01/17 - Updated/Added the following files for the Internal Versions - flashoem=4.00.00.01/scli=14.00.00.00/sas2parser=09.00.00.00/lsipage/lsirbd. ALL Builds - Added sas3flash 14.00.00.00, updated sas3ircu to 14.00.00.00
#
# 02/04/17 - Cleaned up some issues with the new utilities, added some more debug prints.
#
# 02/07/17 - Added support for LSIGET_Overview_Internal-Partner-OEM.txt file for Internal releases. Got rid of precreate.bat script duriong build, merged into create.bat.
#	     Removed lsiget version string in the create.sh file, now greps lsigetlunix.sh for it. Added sg_scan/sg_inq -vvv for all sg devices if sg3_utils is installed.	
#	     Removed BRCM driver save, just get versions and md5sums (new) of the binaries now.	Commented out Nytro MegaRAID data collection section, EOL.
#	     Removed old AENs subdir, replaced by Event_Logs. Took out automatic MegaCli/SMARTCTL subdir creation.	
#
# 02/09/17 - Added export of variable ARCH32or64, sent lspci errors to misc_out.txt. Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code.txt moved from script_workspace to ./$fileName/Notes/, added linux_run.sh to Internal Scripts.
#
# 02/11/17 - Changed tw_cli vmware name to conform with new naming convention. Added missing BRCM vmware utils.
#
# 02/17/17 - Adding in additional VMWare support for storcli,sas2/3flash, sas2/3ircu. Added linux sparc/ppc-BigEndian/ppc-LittleEndian storcli binaries, evibs.sh, fake.sh.
#
# 02/25/17 - New build with vmware binaries extracted with evibs.sh. Got rid of NO_LSI_HBAs variable, all per utility now.
#
# 09/11/18 - Removed AEC, DPMSTAT, most /etc/ files, compress messages instead of copy, comment out ls -latrR of /sys, remove no longer used cli args, remove all 3w code
# 10/24/18 - Commented out lsiutil $42 as that was taking severalminutes on large systesm, added support for 6G expanders that was removed last release, made fix for SAS35 boards to be detected
#
# 02/22/19 - Added support for snapdump, pl stats all,  added sg_readcap, removed any cases where storcli is using legacy syntax, removed SDS section
  
# 3/08/19 - Fixed incorrect variable used for Storcli
# 3/21/19 - misc. bug fixes
# 
# 07/15/19 Added some collection of some performance data previously removed, updated Scrutiny, disabled MR event capture/sort, 
# Added support for automatic HTB collection with 94xx and >=ph11 FW/Driver.  Removed RB support with any of the -E_RB types of flags
# 08/09/19 - Made batch mode the default
# 05/20/20 - Added support for coredumps with with IT HBAs if a dump exists
# 10/12/21 - Changed scrutinyCLI to v32

todayDate=`date '+DATE:%m%d%y' | cut -d: -f2`
currentTime=`date '+TIME:%H%M%S' | cut -d: -f2`
currentYear=`date | cut -d' ' -f 6`
currentDayMonth=`date '+DATE:%m%d' | cut -d: -f 2`
currentDate=${currentYear}${currentDayMonth}${currentTime}

if [ -f ./misc_output.txt ] ; then mv -f ./misc_output.txt misc_output_${todayDate}.${currentTime}.txt > /dev/null 2>&1 ; fi

echo "Start of lsiget script" > ./misc_output.txt 2>&1

###########################################################################################################################
# Initialize Variables
###########################################################################################################################
echo Capture_Script_Version_$Capture_Script_Version
TWGETLUNIXSTARTutc=`date -u`
TWGETLUNIXSTART=`date`
BASECMD=$0
OS_LSI=
grep=grep
CLEANED_UP=NO
VMWARE_SUPPORTED=NO
VMWARE_4x=
VMWARE_5x=
VMWARE_55=
VMWARE_6x=
TWSKIPNETWORK=NO
TWGETSKIPCOMPRESSION=NO
TWGETSKIPCDA=NO

TWPRINTFILENAME=
TWPRINTFILENAMETRIGGER=
TWGETDIRECTORYKEEP=
TWGETBATCHMODE=
TWGETPARTIALMODE=STANDARD
TWSETONLY=NO
TWGETMONITORMODE=
TW_Help_Screen=
TWPROMPTFORCOMMENT=NO
TWcomment=
tw_hostname=
tw_host=
OLD_EVT_CAP_EXIST=NO
NEW_EVT_CAP_EXIST=NO

ex_enclosurenums=
TWPARTIALCAP=

NO_3Ware_Ctrls=YES

#MegaRAID
MCLI_NAME=
MCLI_LOCATION=./
num_mraid_adapters=
LimitMegaCliCMDs=
MR_ECHO_AEC=
MR_ECHO_PMSTAT=
MEGARAID_SASLOADED=NO
USEMEGACLISYNTAX=NO
TWGETSKIPMEGARAID=NO
TWGETSKIPRECORDCAPTURE=NO
TWGETSKIPRECORDSORT=NO
USINGSDSCLI=NO
SDSSTORCLI=NO
NO_MR_Adps=YES

#HBA
LSUT_NAME=
lsut_Bundled_work=NO
NO_scl_EXP_or_IOC=YES
NO_scl_EXP=YES
NO_scl_IOC=YES
TWSKIPXUTILS=NO
MPT2SASLOADED=NO
MPT3SASLOADED=NO
rbcurrentTime=
TWGETSKIPHBA=NO
NO_lsut_LSI_HBAs=YES
NO_2ircu_HBAs=YES
NO_3ircu_HBAs=YES
NO_flash_HBAs=YES
NO_2flash_HBAs=YES
NO_3flash_HBAs=YES
NO_flashoem_GEN2_HBAs=YES
NO_flashoem_GEN3_HBAs=YES
NO_flashoem_GEN2_or_3_HBAs=YES

#Expander
EXPANDER_INFO=NO
grepA=grep
TWGETSKIPEXPANDER=NO
NO_xu_GEN1_or_2_EXPs=YES
NO_g3xu_GEN3_EXPs=YES

#Make batch the default
TWGETBATCHMODE=BATCH

###########################################################################################################################
# Set OS type - Need first, initially for correct grep version.
###########################################################################################################################

if [ `echo $OSTYPE | $grep -i linux` ] ; then
	OS_LSI=linux
fi


if [ "$OS_LSI" = "" ] ; then
	echo "OS_LSI is not set, either not a valid OS for this script or try running;"
	echo "sudo bash $BASECMD -D -Q"
	rm -f cleanup.txt
	exit 1
fi


###########################################################################################################################
export OS_LSI
export grep
###########################################################################################################################


#Cleanup
echo re_execute_variable_shell.txt > cleanup.txt
echo CtDbg.log >> cleanup.txt
echo MegaSAS.log >> cleanup.txt
echo CmdTool.log >> cleanup.txt
echo lsut >> cleanup.txt
echo MegaRAID_Terminology >> cleanup.txt
echo Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code >> cleanup.txt
echo lsut32 >> cleanup.txt
echo lsut64 >> cleanup.txt

echo sas3flash >> cleanup.txt
echo sas3ircu >> cleanup.txt

echo linux_lsut.32 >> cleanup.txt
echo linux_lsut.64 >> cleanup.txt
echo solaris_lsut.i386 >> cleanup.txt
echo solaris_storcli >> cleanup.txt
echo linux_storcli64 >> cleanup.txt
echo linux_storcli >> cleanup.txt
echo linux_sparc_storcli64 >> cleanup.txt
echo linux_ppc-be_storcli64 >> cleanup.txt
echo linux_ppc-le_storcli64 >> cleanup.txt
echo linux_libstorelibir-2.so.14.07-0 >> cleanup.txt
echo linux_xu >> cleanup.txt
echo linux_g3xu >> cleanup.txt
echo cub_linux_g3xu >> cleanup.txt
echo xu >> cleanup.txt
echo g3xu >> cleanup.txt
echo linux_mpt2sas_debug.h >> cleanup.txt
echo linux_mpt3sas_debug.h >> cleanup.txt
echo linux_sas2ircu.32 >> cleanup.txt
echo linux_sas3ircu.32 >> cleanup.txt
echo evibs.sh >> cleanup.txt
echo evibs_out.txt >> cleanup.txt
echo fake.sh >> cleanup.txt
echo create.sh >> cleanup.txt
echo Debug_Readme_int.txt >> cleanup.txt
echo Scrutiny.tar.gz >> cleanup.txt
echo linux_scl.64 >> cleanup.txt
echo linux_scl.32 >> cleanup.txt
echo cub_linux_scl >> cleanup.txt
echo cub_linux_scl.64 >> cleanup.txt
echo cub_linux_scl.32 >> cleanup.txt
echo scl >> cleanup.txt
echo linux_flashoem.32 >> cleanup.txt
echo linux_flashoem.64 >> cleanup.txt
echo linux_check.sh >> cleanup.txt
echo linux_inbandcli.sh >> cleanup.txt
echo linux_kill_jobs.sh >> cleanup.txt
echo linux_run.sh >> cleanup.txt
echo linux_reboot_loop_int.sh >> cleanup.txt
echo linux_reboot_loop_ext.sh >> cleanup.txt
echo linux_r.sh >> cleanup.txt
echo linux_rru.sh >> cleanup.txt
echo linux_trigger_int.sh >> cleanup.txt
echo linux_trigger_ext.sh >> cleanup.txt
echo linux_trigger_test.sh >> cleanup.txt
echo linux_s2sll.sh >> cleanup.txt
echo linux_s3sll.sh >> cleanup.txt
echo linux_Build_all_MR_driver_source.sh >> cleanup.txt
echo uart_login.ttl >> cleanup.txt
echo linux_HBA_Debug_Notes_int.txt >> cleanup.txt
echo linux_HBA_Debug_Notes_ext.txt >> cleanup.txt
echo tempfiles >> cleanup.txt
echo aens_mr.txt >> cleanup.txt
echo linux_sas2parser >> cleanup.txt
echo linux_sas2flash.32 >> cleanup.txt
echo linux_sas3flash.32 >> cleanup.txt
echo linux_sas3flash.64 >> cleanup.txt
echo linux_ppc64_sas3flash >> cleanup.txt
echo LSIRBD.msi >> cleanup.txt
echo LSIPage.exe >> cleanup.txt
echo misc_output* >> cleanup.txt


###################################################
#Time Stamp
###################################################

if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
	date '+%H:%M:%S.%N'
fi
if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	date '+%H:%M:%S'
fi

###################################################

GetKeystroke () { 
# no read -r in sh
trap "" 2 3 
oldSttySettings=`stty -g` 
stty -echo raw 
# BFS echo "`dd count=1 2>> ./misc_output.txt`" 
echo "`dd count=1 2>> /dev/null`" 
stty $oldSttySettings 
trap 2 3 
} 

WaitContinueOrQuit () { 
# no read -r in sh
keyStroke="" 
while [ "$keyStroke" != "C" ] && [ "$keyStroke" != "c" ]
do 
if [ "$keyStroke" = "Q" ] || [ "$keyStroke" = "q" ] ; then
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N'
	fi
 
	rm -f cleanup.txt
	rm misc_output.txt
	exit 1
fi

echo "Type C to continue or Q to Quit." 
echo "...................................................................................................."
keyStroke=`GetKeystroke` 
done
}

WaitQuit () { 
# no read -r in sh
keyStroke="" 
while [ 1 ]
do 
if [ "$keyStroke" = "Q" ] || [ "$keyStroke" = "q" ] ; then
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N'
	fi
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S'
	fi
rm -f cleanup.txt
exit 1
fi

echo "Type Q to Quit." 
echo "...................................................................................................."
keyStroke=`GetKeystroke` 
done
}

###########################################################################################################################
# Set all_cli variable
###########################################################################################################################

all_cli=Missing

if [ -f all_cli ] ; then all_cli=all_cli ; fi

###########################################################################################################################
#Verify user is root
###########################################################################################################################

if [[ $EUID != 0 ]]; then
	echo "This script must be run as root"
	exit 2
fi


 
###########################################################################################################################
# Verify all capture script files exist or exit.
###########################################################################################################################


if [ "$all_cli" = "Missing" ] ; then 

	echo "all_cli is missing"
	echo "\"$BASECMD -H\" provides a help screen."
	echo "" 
	echo "This is not a valid lsigetlunix.sh installation. This script is available at;"
	echo "" 
	echo "http://mycusthelp.info/LSI/_cs/AnswerDetail.aspx?inc=8264"
	echo "" 
	echo "All files included in the original lsigetlunix_xxx_xxxxxx.tgz file MUST be kept"
	echo "in the same subdir as lsigetlunix.sh."
	echo "" 
	echo "" 
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N'
	fi
	rm -f cleanup.txt
	exit 1
fi


###########################################################################################################################
# Command Line Options
# Looking for comments that are not command line options.
# Only 1 comment allowed, lowest variable # wins.
###########################################################################################################################

#-e vs -xe may not make a difference but need to verify on all other OS's, will verify eventually.
#Don't remember why I switched from -e to -xe, may be a corner case.

if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
	if [ "$6" != "" ] ; then 
		echo $6 | $grep -i -xe -EXT -xe -M -xe -P -xe -PT -xe -D -xe -B -xe -Q -xe -F1 -xe -F2 -xe -F3 -xe -F4 -xe -UMS -xe -SRC -xe -SRS -xe -SCDA -xe -SMR -xe -S3W -xe -SHBA -xe -SEXP -xe -SC -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -E_SAS2LOG -xe -E_SAS2LOG1 -xe -D_SAS2LOG -xe -E_SAS2LOG_RB -xe -E_SAS2LOG1_RB -xe -E_SAS3LOG -xe -E_SAS3LOG1 -xe -D_SAS3LOG -xe -E_SAS3LOG_RB -xe -E_SAS3LOG1_RB -xe -E_RB -xe -SX -xe -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$6"
			fi
	fi
	if [ "$5" != "" ] ; then 
		echo $5 | $grep -i -xe -EXT -xe -M -xe -P -xe -PT -xe -D -xe -B -xe -Q -xe -F1 -xe -F2 -xe -F3 -xe -F4 -xe -UMS -xe -SRC -xe -SRS -xe -SCDA -xe -SMR -xe -S3W -xe -SHBA -xe -SEXP -xe -SC -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -E_SAS2LOG -xe -E_SAS2LOG1 -xe -D_SAS2LOG -xe -E_SAS2LOG_RB -xe -E_SAS2LOG1_RB -xe -E_SAS3LOG -xe -E_SAS3LOG1 -xe -D_SAS3LOG -xe -E_SAS3LOG_RB -xe -E_SAS3LOG1_RB -xe -E_RB -xe -SX -xe -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$5"
			fi
	fi
	if [ "$4" != "" ] ; then 
		echo $4 | $grep -i -xe -EXT -xe -M -xe -P -xe -PT -xe -D -xe -B -xe -Q -xe -F1 -xe -F2 -xe -F3 -xe -F4 -xe -UMS -xe -SRC -xe -SRS -xe -SCDA -xe -SMR -xe -S3W -xe -SHBA -xe -SEXP -xe -SC -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -E_SAS2LOG -xe -E_SAS2LOG1 -xe -D_SAS2LOG -xe -E_SAS2LOG_RB -xe -E_SAS2LOG1_RB -xe -E_SAS3LOG -xe -E_SAS3LOG1 -xe -D_SAS3LOG -xe -E_SAS3LOG_RB -xe -E_SAS3LOG1_RB -xe -E_RB -xe -SX -xe -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$4"
			fi
	fi
	if [ "$3" != "" ] ; then 
		echo $3 | $grep -i -xe -EXT -xe -M -xe -P -xe -PT -xe -D -xe -B -xe -Q -xe -F1 -xe -F2 -xe -F3 -xe -F4 -xe -UMS -xe -SRC -xe -SRS -xe -SCDA -xe -SMR -xe -S3W -xe -SHBA -xe -SEXP -xe -SC -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -E_SAS2LOG -xe -E_SAS2LOG1 -xe -D_SAS2LOG -xe -E_SAS2LOG_RB -xe -E_SAS2LOG1_RB -xe -E_SAS3LOG -xe -E_SAS3LOG1 -xe -D_SAS3LOG -xe -E_SAS3LOG_RB -xe -E_SAS3LOG1_RB -xe -E_RB -xe -SX -xe -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$3"
			fi
	fi
	if [ "$2" != "" ] ; then 
		echo $2 | $grep -i -xe -EXT -xe -M -xe -P -xe -PT -xe -D -xe -B -xe -Q -xe -F1 -xe -F2 -xe -F3 -xe -F4 -xe -UMS -xe -SRC -xe -SRS -xe -SCDA -xe -SMR -xe -S3W -xe -SHBA -xe -SEXP -xe -SC -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -E_SAS2LOG -xe -E_SAS2LOG1 -xe -D_SAS2LOG -xe -E_SAS2LOG_RB -xe -E_SAS2LOG1_RB -xe -E_SAS3LOG -xe -E_SAS3LOG1 -xe -D_SAS3LOG -xe -E_SAS3LOG_RB -xe -E_SAS3LOG1_RB -xe -E_RB -xe -SX -xe -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$2"
			fi
	fi
	if [ "$1" != "" ] ; then 
		echo $1 | $grep -i -xe -EXT -xe -M -xe -P -xe -PT -xe -D -xe -B -xe -Q -xe -F1 -xe -F2 -xe -F3 -xe -F4 -xe -UMS -xe -SRC -xe -SRS -xe -SCDA -xe -SMR -xe -S3W -xe -SHBA -xe -SEXP -xe -SC -xe -E_AEC -xe -E_DPMSTAT -xe -E_AEC_DPMSTAT -xe -G_AEC -xe -G_DPMSTAT -xe -G_AEC_DPMSTAT -xe -MRWA -xe -H -xe -E_SAS2LOG -xe -E_SAS2LOG1 -xe -D_SAS2LOG -xe -E_SAS2LOG_RB -xe -E_SAS2LOG1_RB -xe -E_SAS3LOG -xe -E_SAS3LOG1 -xe -D_SAS3LOG -xe -E_SAS3LOG_RB -xe -E_SAS3LOG1_RB -xe -E_RB -xe -SX -xe -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$1"
			fi
	fi
fi


if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	if [ "$6" != "" ] ; then 
		echo $6 | $grep -i -e -EXT -e -M -e -P -e -PT -e -D -e -B -e -Q -e -F1 -e -F2 -e -F3 -e -F4 -e -UMS -e -SRC -e -SRS -e -SCDA -e -SMR -e -S3W -e -SHBA -e -SEXP -e -SC -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -E_SAS2LOG -e -E_SAS2LOG1 -e -D_SAS2LOG -e -E_SAS2LOG_RB -e -E_SAS2LOG1_RB -e -E_SAS3LOG -e -E_SAS3LOG1 -e -D_SAS3LOG -e -E_SAS3LOG_RB -e -E_SAS3LOG1_RB -e -E_RB -e -SX -e -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$6"
			fi
	fi
	if [ "$5" != "" ] ; then 
		echo $5 | $grep -i -e -EXT -e -M -e -P -e -PT -e -D -e -B -e -Q -e -F1 -e -F2 -e -F3 -e -F4 -e -UMS -e -SRC -e -SRS -e -SCDA -e -SMR -e -S3W -e -SHBA -e -SEXP -e -SC -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -E_SAS2LOG -e -E_SAS2LOG1 -e -D_SAS2LOG -e -E_SAS2LOG_RB -e -E_SAS2LOG1_RB -e -E_SAS3LOG -e -E_SAS3LOG1 -e -D_SAS3LOG -e -E_SAS3LOG_RB -e -E_SAS3LOG1_RB -e -E_RB -e -SX -e -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$5"
			fi
	fi
	if [ "$4" != "" ] ; then 
		echo $4 | $grep -i -e -EXT -e -M -e -P -e -PT -e -D -e -B -e -Q -e -F1 -e -F2 -e -F3 -e -F4 -e -UMS -e -SRC -e -SRS -e -SCDA -e -SMR -e -S3W -e -SHBA -e -SEXP -e -SC -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -E_SAS2LOG -e -E_SAS2LOG1 -e -D_SAS2LOG -e -E_SAS2LOG_RB -e -E_SAS2LOG1_RB -e -E_SAS3LOG -e -E_SAS3LOG1 -e -D_SAS3LOG -e -E_SAS3LOG_RB -e -E_SAS3LOG1_RB -e -E_RB -e -SX -e -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$4"
			fi
	fi
	if [ "$3" != "" ] ; then 
		echo $3 | $grep -i -e -EXT -e -M -e -P -e -PT -e -D -e -B -e -Q -e -F1 -e -F2 -e -F3 -e -F4 -e -UMS -e -SRC -e -SRS -e -SCDA -e -SMR -e -S3W -e -SHBA -e -SEXP -e -SC -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -E_SAS2LOG -e -E_SAS2LOG1 -e -D_SAS2LOG -e -E_SAS2LOG_RB -e -E_SAS2LOG1_RB -e -E_SAS3LOG -e -E_SAS3LOG1 -e -D_SAS3LOG -e -E_SAS3LOG_RB -e -E_SAS3LOG1_RB -e -E_RB -e -SX -e -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$3"
			fi
	fi
	if [ "$2" != "" ] ; then 
		echo $2 | $grep -i -e -EXT -e -M -e -P -e -PT -e -D -e -B -e -Q -e -F1 -e -F2 -e -F3 -e -F4 -e -UMS -e -SRC -e -SRS -e -SCDA -e -SMR -e -S3W -e -SHBA -e -SEXP -e -SC -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -E_SAS2LOG -e -E_SAS2LOG1 -e -D_SAS2LOG -e -E_SAS2LOG_RB -e -E_SAS2LOG1_RB -e -E_SAS3LOG -e -E_SAS3LOG1 -e -D_SAS3LOG -e -E_SAS3LOG_RB -e -E_SAS3LOG1_RB -e -E_RB -e -SX -e -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$2"
			fi
	fi
	if [ "$1" != "" ] ; then 
		echo $1 | $grep -i -e -EXT -e -M -e -P -e -PT -e -D -e -B -e -Q -e -F1 -e -F2 -e -F3 -e -F4 -e -UMS -e -SRC -e -SRS -e -SCDA -e -SMR -e -S3W -e -SHBA -e -SEXP -e -SC -e -E_AEC -e -E_DPMSTAT -e -E_AEC_DPMSTAT -e -G_AEC -e -G_DPMSTAT -e -G_AEC_DPMSTAT -e -MRWA -e -H -e -E_SAS2LOG -e -E_SAS2LOG1 -e -D_SAS2LOG -e -E_SAS2LOG_RB -e -E_SAS2LOG1_RB -e -E_SAS3LOG -e -E_SAS3LOG1 -e -D_SAS3LOG -e -E_SAS3LOG_RB -e -E_SAS3LOG1_RB -e -E_RB -e -SX -e -SN >> ./misc_output.txt 2>&1
			if [ $? -ne 0 ] ; then TWcomment="$1"
			fi
	fi
fi


# Checking command line variables for options.
   # Competing options are not allowed.

#Pulled out TWGETPARTIALMODE for x_SASxLOGx

for i in $* ; do
	  if [ "$i" = "-P" ] || [ "$i" = "-p" ] ; then TWPRINTFILENAME=YES ; fi
	  if [ "$i" = "-PT" ] || [ "$i" = "-pt" ] ; then TWPRINTFILENAMETRIGGER=YES ; fi
	  if [ "$i" = "-D" ] || [ "$i" = "-d" ] ; then TWGETDIRECTORYKEEP=YES ; fi
	  if [ "$i" = "-Q" ] || [ "$i" = "-q" ] ; then TWGETBATCHMODE=QUIET ; fi
	  if [ "$i" = "-B" ] || [ "$i" = "-b" ] ; then TWGETBATCHMODE=BATCH ; fi
	  if [ "$i" = "-SMR" ] || [ "$i" = "-smr" ] ; then TWGETSKIPMEGARAID=YES ; fi
	  if [ "$i" = "-SHBA" ] || [ "$i" = "-shba" ] ; then TWGETSKIPHBA=YES ; fi
	  if [ "$i" = "-SEXP" ] || [ "$i" = "-sexp" ] ; then TWGETSKIPEXPANDER=YES ; fi
	  if [ "$i" = "-SCDA" ] || [ "$i" = "-scda" ] ; then TWGETSKIPCDA=YES ; fi
	  if [ "$i" = "-SC" ] || [ "$i" = "-sc" ] ; then TWGETSKIPCOMPRESSION=YES ; fi
	  if [ "$i" = "-SRC" ] || [ "$i" = "-src" ] ; then TWGETSKIPRECORDCAPTURE=YES TWGETSKIPRECORDSORT=YES ; fi
	  if [ "$i" = "-SRS" ] || [ "$i" = "-srs" ] ; then TWGETSKIPRECORDSORT=YES ; fi
	  if [ "$i" = "-F1" ] || [ "$i" = "-f1" ] ; then TWGETSKIPRECORDCAPTURE=YES TWGETSKIPRECORDSORT=YES ; fi
	  if [ "$i" = "-F2" ] || [ "$i" = "-f2" ] ; then TWGETSKIPRECORDCAPTURE=YES TWGETSKIPRECORDSORT=YES TWGETSKIPCDA=YES ; fi
	  if [ "$i" = "-F3" ] || [ "$i" = "-f3" ] ; then TWGETSKIPRECORDCAPTURE=YES TWGETSKIPRECORDSORT=YES TWGETSKIPCDA=YES ; fi
	  if [ "$i" = "-F4" ] || [ "$i" = "-f4" ] ; then TWGETSKIPRECORDCAPTURE=YES TWGETSKIPRECORDSORT=YES TWGETSKIPCDA=YES TWGETSKIPCOMPRESSION=YES ; fi
	  if [ "$i" = "-EXT" ] || [ "$i" = "-ext" ] ; then TWSETONLY=YES TWGETPARTIALMODE=EXTRACT EXTRACTUTILS=YES ; fi
	  if [ "$i" = "-E_SAS2LOG" ] || [ "$i" = "-e_sas2log" ] ; then TWSETONLY=YES TWGETPARTIALMODE=E_SAS2LOG ; fi
	  if [ "$i" = "-E_SAS2LOG1" ] || [ "$i" = "-e_sas2log1" ] ; then TWSETONLY=YES TWGETPARTIALMODE=E_SAS2LOG1 ; fi
	  if [ "$i" = "-D_SAS2LOG" ] || [ "$i" = "-d_sas2log" ] ; then TWSETONLY=YES TWGETPARTIALMODE=D_SAS2LOG ; fi
	  if [ "$i" = "-E_SAS3LOG" ] || [ "$i" = "-e_sas3log" ] ; then TWSETONLY=YES TWGETPARTIALMODE=E_SAS3LOG ; fi
	  if [ "$i" = "-E_SAS3LOG1" ] || [ "$i" = "-e_sas3log1" ] ; then TWSETONLY=YES TWGETPARTIALMODE=E_SAS3LOG1 ; fi
	  if [ "$i" = "-D_SAS3LOG" ] || [ "$i" = "-d_sas3log" ] ; then TWSETONLY=YES TWGETPARTIALMODE=D_SAS3LOG ; fi
	  if [ "$i" = "-M" ] || [ "$i" = "-m" ] ; then TWGETMONITORMODE=MONITOR ; fi
	  if [ "$i" = "-MRWA" ] || [ "$i" = "-mrwa" ] ; then LimitMegaCliCMDs=YES ; fi
	  if [ "$i" = "-SX" ] || [ "$i" = "-sx" ] ; then TWSKIPXUTILS=YES ; fi
	  if [ "$i" = "-SN" ] || [ "$i" = "-sn" ] ; then TWSKIPNETWORK=YES ; fi
	  if [ "$i" = "-H" ] || [ "$i" = "-h" ] ; then TW_Help_Screen=YES ; fi
done

###########################################################################################################################
export EXTRACTUTILS
###########################################################################################################################


###########################################################################################################################
# Option Override
###########################################################################################################################

if [ "$TWGETMONITORMODE" = "MONITOR" ] ; then TWGETPARTIALMODE=STANDARD ; fi

###########################################################################################################################
# Bypass Comment prompt
###########################################################################################################################

if [ "$TWGETPARTIALMODE" = "EXTRACT" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS2LOG" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS2LOG1" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "D_SAS2LOG" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS2LOG_RB" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS2LOG1_RB" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS3LOG" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS3LOG1" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "D_SAS3LOG" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS3LOG_RB" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_SAS3LOG1_RB" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "E_RB" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETBATCHMODE" = "BATCH" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETBATCHMODE" = "QUIET" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWcomment" != "" ] ; then TWPROMPTFORCOMMENT=NO ; fi
if [ "$TWGETPARTIALMODE" = "G_AEC_DPMSTAT" ] ; then TWPARTIALCAP=YES ; fi
if [ "$TWGETPARTIALMODE" = "G_AEC" ] ; then TWPARTIALCAP=YES ; fi
if [ "$TWGETPARTIALMODE" = "G_DPMSTAT" ] ; then TWPARTIALCAP=YES ; fi

if [ "$TWGETDIRECTORYKEEP" != "YES" ] ; then
	if [ "$TWGETSKIPCOMPRESSION" = "YES" ] ; then
		echo .
		echo "You can't skip compression without keeping the directory..."
		echo "The -D parameter has been enabled..."
		TWGETDIRECTORYKEEP=YES
	fi
fi
		

###########################################################################################################################
# Help Screen
###########################################################################################################################

if [ "$TW_Help_Screen" = "YES" ] ; then

	#cho ".................................................||................................................."
	echo "" 
	echo "LSI HBA/MegaRAID/Expander/3ware Data collection script for Linux, FreeBSD, Solaris X86 and VMWare." 
	echo "This script will collect system logs and info as well as controller, disk and"
	echo "enclosure info for debugging purposes. All files included in the original" 
	echo "lsigetlunix_xxxxxx.tgz file MUST be kept in the same subdir as lsigetlunix.sh."
	echo "You MUST have root access rights to run this script, su/sudo/root$MCLI_LOCATION$MCLI_NAME. The"
	echo "latest version of this script as well as information on what data can be collected manually"
	echo "can be found at;"
	echo ""
	echo "http://www.avagotech.com/support/knowledgebase/1211161499563/lsiget-data-capture-script"
	echo ""
	echo "OR"
	echo ""
	echo "ftp0.lsil.com"
	echo "User:tsupport"
	echo "Password:tsupport"
	echo "/outgoing_perm/CaptureScripts  (Sometimes newer scripts than KB article)"
	echo "/outgoing_perm/CaptureScripts/BETA  (Latest and greatest)"
	echo ""
	echo "To automatically get the latest script you can download the following file & grep for the current"
	echo "latest file. This ensures support will always have access to the latest data to speed up the support"
	echo "process." 
	echo ""
	echo "Example;"
	echo ""
	echo "/outgoing_perm/CaptureScripts/Latest_Script_Versions.txt"
	echo "#Used for automated remote script updates"
	echo "LatestFreebsd#lsigetfreebsd_062012.tgz"
	echo "LatestLinux#lsigetlinux_062012.tgz"
	echo "LatestLunix#lsigetlunix_062012.tgz"
	echo "LatestMacOS#lsigetmacos_062012.tgz"
	echo "LatestSolaris#lsigetsolaris_062012.tgz"
	echo "LatestWin#lsigetwin_062012.tgz"
	echo ""
	echo "This script is being packaged for all supported linux/Unix based OS's"
	echo "together as well as individually for each OS with different bundled" 
	echo "utilities. The exact same script is used in all cases, this is being done" 
	echo "to cut down on the size of the full .tgz file."
	echo ""
	echo "	lsigetlunix_xxxxxx.tgz   - Linux/Unix - FreeBSD/Linux/Solaris/VMWare"
	echo "	lsigetfreebsd_xxxxxx.tgz - FreeBSD"
	echo "	lsigetlinux_xxxxxx.tgz   - Linux"   
	echo "	lsigetsolaris_xxxxxx.tgz - Solaris"
	echo "	lsigetvmware_xxxxxx.tgz  - VMWare"
	echo ""
	echo "Command Line Options:"
	echo "lsigetwin [Comment] [Option(s)]"		
	echo "Comment: Enclose noncontiguous strings in double quotes "My Comments"" 
	echo "Option:" 
	echo "-EXT		= EXTRACT - Extracts all available utilities for use."
	echo "-P		= PRINT filename in .\LSICAPTUREFILES.TXT for scripting."
	echo "-PT            	= Append the PRINTED filename of the lsiget output file with TRIGGERED, used to differentiate automated captures."
	echo "-D		= Working DIRECTORY is not deleted."
	echo "-Q		= QUIET Mode - No keystrokes required unless error."
	echo "-B		= BATCH Mode - No keystrokes required."
	echo "-E_SAS2LOG     	= ENABLE ALL SAS2 HBA Driver Logging, Option ffffffh. HUGE /var/log/messages file size! (Linux Only)"
	echo "-E_SAS2LOG1    	= ENABLE some SAS2 HBA Driver Logging, Option 3f8h. Very Large /var/log/messages file size! (Linux Only)"
	echo "-E_SAS3LOG     	= ENABLE ALL SAS3 HBA Driver Logging, Option ffffffh. HUGE /var/log/messages file size! (Linux Only)"
	echo "-E_SAS3LOG1    	= ENABLE some SAS3 HBA Driver Logging, Option 3f8h. Very Large /var/log/messages file size! (Linux Only)"
	echo "-D_SAS2LOG     	= Disables ALL SAS2 HBA Driver Logging, Option 000000h (Default). (Linux Only)"
	echo "-D_SAS3LOG     	= Disables ALL SAS3 HBA Driver Logging, Option 000000h (Default). (Linux Only)"

	echo "-M		= MONITOR Mode - Standard capture, daily/targeted logging."
	echo "-MRWA          	= MegaRAID Work Around - Limit commands for compatibility issues with old code"
	echo "-H		= This Help Screen."
	echo ""
	echo "The following command line options are NOT standard and may be detrimental" 
	echo "to a root cause analysis of your issue. Used for repetitive data collection"
	echo "and script debugging, these are fluid and may change."
	echo ""
	echo "-SCDA (CDA not enabled yet) = Skip Controller Disk Association, NOT standard."
	echo "-SMR		= Skip MegaRAID DATA Capture, NOT standard."
	echo "-SHBA		= Skip HBA DATA Capture, NOT standard."
	echo "-SEXP		= Skip Expander DATA Capture, NOT standard."
	echo "-SC		= Skip Compression of output subdirectory, NOT standard."
	echo "-SX            	= Skip xutil and g3xutil for debugging purposes, dependent on the SG driver in linux." 	
	echo "-SN            	= Skip ifconfig and ipmitool lan print data capture, used for on site and MSM debugging but can be omitted." 
     	echo ""
	echo "Example $BASECMD -D -Q \"This is my comment\""
	echo "Runs the standard script leaving the working directory, without prompts" 
	echo "and leaves a comment."
	echo ""
	echo "Example $BASECMD -Q \"This is my comment\" -D -M"
	echo "Runs the standard script leaving the working directory, without prompts" 
	echo "and leaves a comment, once done the script stays resident in Monitor Mode."
	echo ""
	echo "Notes:" 
	echo "Send just the created .tar.gz file as is to your support rep."
	echo ""
	echo "-E_SASxLOG = This sets the HBA Driver logging level, -E_SAS2LOG is for all"
	echo "SAS2 HBAs and -E_SAS3LOG is for all SAS3 HBAs. This is VERY VERBOSE!"
	echo ""
	echo "All of the -E/D/G options can only be used alone."
	echo ""
	echo "All of the -G_* "GET" Options are done automatically if AEC or DPMSTAT was"
	echo 'enabled previously with the -E_* "ENABLE" options by default. The -G_*' 
	echo "options are meant for quick repetitive results without getting other system"
	echo "information. Normally you should run the standard $BASECMD file without"
	echo "a -G_* option to provide as much info as possible."
	echo ""
	echo "If there are competing comments the lowest variable number wins."
	echo "If there are contradictory options the lowest variable number with the"
	echo "option order listed in the help wins. Valid combinations would be;"
	echo "-D or -D with -B or -Q any -E_* or -G_* option by itself or in conjunction"
	echo "with a -D and -B/-Q option. -E_* is allowed with -D but has no effect as" 
	echo "there is no working directory created."
	echo ""
	echo "Monitor Mode = Runs the standard capture script and then remains resident"
	echo 'logging "show diag" approx. every 24 hours and also monitors for three' 
	echo "specific AEN's (Controller Reset/Degraded Array/Rebuild Started). If any"
	echo 'of these are encountered a final "show diag" will be done and the script' 
	echo "will finish normally. Use to capture the internal printlog/buf prior to"
	echo "the buffer being overwritten. Run a standard capture after Monitor Mode completes. (3ware Only)"
	echo ""
	echo "MRWA = MegaRAID Work Around - Limits the MegaCli(64) commands that are run."
	echo "MegaCli has been seen to hang in some cases when running the 92xx controllers with"
	echo "pre 4.1.1 FW and/or driver versions. Currently this switch bypasses the encinfo & adplilog"
	echo "parameters. Instead of using this switch it is recommended to upgrade your code as this"
	echo "work around is not always 100% effective. See the troubleshooting section for more information."
	echo ""
	echo "Trouble Shooting Script Issues -"
	echo ""
	echo "I. Ubuntu 9.04"
	echo "sudo $BASECMD -D -Q"
	echo "Tue Sep 22 17:06:32 PDT 2009"
	echo "export: 3: 22: bad variable name"
	echo ""
	echo "Run;"
	echo "sudo bash $BASECMD -D -Q"
	echo ""
	echo "II. Script hangs with MegaRAID Controller"
	echo ""
	echo "If you are positive the script is hung, CTRL-C the process, wait 3 minutes."
	echo "If the prompt doesn't come back kill the term window, do a ps -ea, note the"
	echo "# of any lsigetlunix.sh or MegaCli(64) processes. Do a kill -9 process-number"
	echo "for each process. If any can't be killed, wait 3 minutes, there is a 180 second"
	echo "timeout on MegaCli. Upgrade your driver/fw/capture script to the latest version and"
	echo "try again. If you cant upgrade or if you still have problems try the -MRWA switch."
	echo "If you still have problems manually zip the subdirectory structure and "
	echo "email it to your support rep."
	echo ""
	echo "III. Fails to run on Solaris - Error is "$BASECMD: test: argument expected""
	echo "Old version of Bourne shell is loaded by default, the following two shells were tried automatically"
	echo "/bin/sh was changed to /usr/xpg4/bin/sh and then /bin/bash"
	echo "depending on what is installed on the system, you can try others, i.e. csh/ksh or install a" 
	echo "supported shell..."
	echo ""
	echo "Recommended Code Set/Release Versions"
	echo ""
	echo 
	echo "MegaRAID -"
	echo ""
	echo "This script should run with any release after 3.1 on the 82xx, 83xx, 84xx, 87xx," 
	echo "88xx, 92xx 93xx and 94xx family of controllers." 
	echo ""
	echo "HBA -"
	echo ""
	echo "This script should run with any LSI HBA using an mpt based driver."
	echo ""
	echo "Capture Script Version: $Capture_Script_Version"
	echo ""
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N'
	fi
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S'
	fi
	rm -f cleanup.txt
	exit 0
fi
	

###########################################################################################################################
# Comment check
###########################################################################################################################

if [ "$TWPROMPTFORCOMMENT" != "NO" ] ; then

	#Update on Code Set Change
	#cho ".................................................||................................................."
	echo ""
	echo "\"$BASECMD -H\" provides a help screen."
	echo ""
	echo "To associate a user comment with this data capture session pass the comment as a variable."
	#echo "comment as a variable." 
	echo ""						  
	echo "Example;"
	echo "$BASECMD \"Case 123456-123456789 – performance problems after upgrade\""
	echo ""
	echo 'NOTE: Noncontiguous strings must be in double quotes "My Comments".' 	  
	echo ""
	echo ""
	 
	WaitContinueOrQuit

fi

###########################################################################################################################
# Set architecture, i.e. check to see if 64-bit or 32 bit
###########################################################################################################################

if [ `uname -m | $grep 64` ] ; then
	Arch32or64=64
	else
	Arch32or64=32
fi

###########################################################################################################################
export Arch32or64
###########################################################################################################################


###########################################################################################################################
# Clean up
###########################################################################################################################


for i in $( cat cleanup.txt ); do

	if [ -f ./$i ] ; then
		rm -f ./$i
	fi
done


CLEANED_UP=YES

###########################################################################################################################
# Unpack files - Gunzip used as tar -zxvf not supported on Solaris
###########################################################################################################################

echo "File Size Check - 1" > ./misc_output.txt 2>&1
ls -latr >> ./misc_output.txt 2>&1

if [ -f ./$all_cli ] ; then
	echo "gunzip < $all_cli | tar xvf -" >> ./misc_output.txt 2>&1
	gunzip < $all_cli | tar xvf - >> ./misc_output.txt 2>&1

	echo "File Size Check - 2" >> ./misc_output.txt 2>&1
	ls -latr >> ./misc_output.txt 2>&1
fi

echo "File Size Check - 3" >> ./misc_output.txt 2>&1
ls -latr >> ./misc_output.txt 2>&1


CLEANED_UP=NO

###########################################################################################################################
# Rename appropriate MegaRAID cli based on OS type
###########################################################################################################################


if [ "$USINGSDSCLI" != "YES" ] ; then
	if [ "$OS_LSI" = "linux" ] ; then
		if [ -f linux_libstorelibir-2.so.14.07-0 ] ; then  mv -f linux_libstorelibir-2.so.14.07-0 libstorelibir-2.so.14.07-0 ; fi
		if [ "$Arch32or64" = "64" ] ; then
			MCLI_NAME64=linux_storcli64
			MCLI_NAME32=linux_storcli 
			./$MCLI_NAME64 show ctrlcount | $grep "Controller Count" >> ./misc_output.txt 2>&1
			if [ "$?" = "0" ] ; then
				mv -f linux_storcli64 storcli
				MCLI_NAME=storcli
				#Bundled cli executed
				mcli_Bundled_work=YES
				else

				./$MCLI_NAME32 show ctrlcount | $grep "Controller Count" >> ./misc_output.txt 2>&1
				if [ "$?" = "0" ] ; then
					mv -f linux_storcli storcli
					MCLI_NAME=storcli
					#Bundled cli executed
					mcli_Bundled_work=YES
				fi
			fi
			if [ "$MCLI_NAME" = " " ] ; then 
				#Bundled cli did not execute
				mcli_Bundled_work=NO
			fi			
		fi
		if [ "$Arch32or64" = "32" ] ; then
			MCLI_NAME32=linux_storcli 
			#./$MCLI_NAME32 adpcount nolog | $grep "Controller Count:" >> ./misc_output.txt 2>&1
			# Remove legacy syntax - adpcount
			./$MCLI_NAME32 show ctrlcount | $grep "Controller Count" >> ./misc_output.txt 2>&1
			if [ "$?" = "0" ] ; then
				mv -f linux_storcli storcli
				MCLI_NAME=storcli
				#Bundled cli executed
				mcli_Bundled_work=YES
			fi
			if [ "$MCLI_NAME" = " " ] ; then 
				#Bundled cli did not execute
				mcli_Bundled_work=NO
			fi			
		fi
	fi
fi



   


###########################################################################################################################
# Extract appropriate lsut util based on OS type
###########################################################################################################################

if [ "$OS_LSI" = "linux" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		LSUT_NAME64=linux_lsut.64
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME64 0 2>> ./misc_output.txt | $grep "Chip Vendor" 1>> ./misc_output.txt 
		if [ "$?" = "0" ] ; then
			mv -f linux_lsut.64 lsut64
			LSUT_NAME=lsut64
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_lsut_LSI_HBAs=NO
			else
			./$LSUT_NAME32 0 2>> ./misc_output.txt | $grep "Chip Vendor" 1>> ./misc_output.txt 
			if [ "$?" = "0" ] ; then
				mv -f linux_lsut.32 lsut32
				LSUT_NAME=lsut32
				#Bundled cli executed
				lsut_Bundled_work=YES
				NO_lsut_LSI_HBAs=NO
			fi
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_lsut_LSI_HBAs=YES
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME32 0 2>> ./misc_output.txt | $grep "Chip Vendor" 1>> ./misc_output.txt 
		if [ "$?" = "0" ] ; then
			mv -f linux_lsut.32 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_lsut_LSI_HBAs=NO
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_lsut_LSI_HBAs=YES
		fi			
	fi
fi

#Using 32bit linux lsut
if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		LSUT_NAME64=linux_lsut.32
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME64 0 2>> ./misc_output.txt | $grep "Chip Vendor" 1>> ./misc_output.txt 
		if [ "$?" = "0" ] ; then
			mv -f linux_lsut.32 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_lsut_LSI_HBAs=NO
			else
			./$LSUT_NAME32 0 2>> ./misc_output.txt | $grep "Chip Vendor" 1>> ./misc_output.txt 
			if [ "$?" = "0" ] ; then
				mv -f linux_lsut.32 lsut32
				LSUT_NAME=lsut32
				#Bundled cli executed
				lsut_Bundled_work=YES
				NO_lsut_LSI_HBAs=NO
			fi
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_lsut_LSI_HBAs=YES
		fi			
	fi
	if [ "$Arch32or64" = "32" ] ; then
		LSUT_NAME32=linux_lsut.32
		./$LSUT_NAME32 0 2>> ./misc_output.txt | $grep "Chip Vendor" 1>> ./misc_output.txt 
		if [ "$?" = "0" ] ; then
			mv -f linux_lsut.32 lsut32
			LSUT_NAME=lsut32
			#Bundled cli executed
			lsut_Bundled_work=YES
			NO_lsut_LSI_HBAs=NO
		fi
		if [ "$LSUT_NAME" = " " ] ; then 
			#Bundled cli did not execute
			lsut_Bundled_work=NO
			NO_lsut_LSI_HBAs=YES
		fi			
	fi
fi

###########################################################################################################################
# Extract appropriate scl util based on OS type
###########################################################################################################################

if [ "$OS_LSI" = "linux" ] ; then
	if [ "$Arch32or64" = "64" ] ; then
		mv -f linux_scl.64 scl
		./scl --list >> ./misc_output.txt 2>&1
		if [ "$?" = "0" ] ; then
			#Bundled cli executed
			NO_scl_EXP_or_IOC=NO
		fi
	fi
	if [ "$Arch32or64" = "32" ] ; then
		mv -f linux_scl.32 scl
		./scl --list >> ./misc_output.txt 2>&1
		if [ "$?" = "0" ] ; then
			#Bundled cli executed
			NO_scl_EXP_or_IOC=NO
		fi
	fi
fi



###########################################################################################################################
# Cub Support - Extract appropriate xu/g3xu based on OS type
###########################################################################################################################

if [ "$OS_LSI" = "linux" ] ; then
	mv -f linux_xu xu
	if [ "$Arch32or64" = "64" ] ; then
		if [ -f cub_linux_g3xu ] ;  then 
			./cub_linux_g3xu -i get avail | $grep SAS_35X >> ./misc_output.txt 2>&1
			if [ "$?" = "0" ] ; then
				cp -f cub_linux_g3xu linux_g3xu >> ./misc_output.txt 2>&1
				echo .
				echo "Beta Cub g3xutil is being used..."
				echo "Beta Cub g3xutil is being used..." >> ./misc_output.txt 2>&1 
			fi
		fi
	fi
cp -f linux_g3xu g3xu >> ./misc_output.txt 2>&1 
fi




if [ "$TWGETSKIPHBA" != "YES" ] ; then
	###########################################################################################################################
	# Rename appropriate sas2ircu and sas3ircu based on OS type
	###########################################################################################################################
	
	if [ "$OS_LSI" = "linux" ] ; then
		if [ "$Arch32or64" = "64" ] ; then
			mv -f linux_sas2ircu.32 sas2ircu
			mv -f linux_sas3ircu.32 sas3ircu
		fi
		if [ "$Arch32or64" = "32" ] ; then
			mv -f linux_sas2ircu.32 sas2ircu
			mv -f linux_sas3ircu.32 sas3ircu
		fi
	fi
	

	
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then mv -f vmware_esx50_sas2ircu sas2ircu ; fi
	if [ "$OS_LSI" = "vmware_6.X_Not_Tested" ] || [ "$OS_LSI" = "vmware_6.0.0" ] || [ "$OS_LSI" = "vmware_5.5.0" ] ; then mv -f vmware_esx55_sas3ircu sas3ircu ; fi
	if [ "$OS_LSI" = "vmware_5.1.0" ] || [ "$OS_LSI" = "vmware_5.X_Not_Tested" ] || [ "$OS_LSI" = "vmware_4.X_Not_Tested" ] || [ "$OS_LSI" = "vmware_3.X_Not_Tested" ] ; then mv -f vmware_esx50_sas3ircu sas3ircu ; fi

fi


if [ "$TWGETSKIPHBA" != "YES" ] ; then
	###########################################################################################################################
	# Rename appropriate sas2flash and sas3flash based on OS type
	###########################################################################################################################
	
	if [ "$OS_LSI" = "linux" ] ; then
		if [ "$Arch32or64" = "64" ] ; then
			mv -f linux_sas3flash.64 sas3flash
		fi
		if [ "$Arch32or64" = "32" ] ; then
			mv -f linux_sas2flash.32 sas2flash
			mv -f linux_sas3flash.32 sas3flash
		fi
		if [ "$PPC64" = "YES" ] ; then	
			if [ -f sas3flash ] ; then rm -f sas3flash ; fi
			mv -f linux_ppc64_sas3flash sas3flash
		fi
	fi
fi

###########################################################################################################################
# IF lsut, tw_cli and MegaCli not functional but NOT batchmode
###########################################################################################################################

if [ "$TWGETBATCHMODE" != "BATCH" ] ; then	
	if [ "$tw_cli_Functional" = "NO" ] ; then
		if [ "$mcli_Functional" = "NO" ] ; then
			if [ "$NO_scl_EXP_or_IOC" = "YES" ] ; then				
				### 
				#cho ".................................................||................................................."
				echo "...................................................................................................."
				echo "################## CLI incompatible or No 3ware/MegaRAID or HBAs in the system #####################"
				echo "################################################ OR ################################################"
				echo "################# You do not have root privileges which are required to run the CLI ################"
				echo ""
				echo "\"$BASECMD -H\" provides a help screen."
				echo ""
	
				###########################################################################################################################
				# Clean up
				###########################################################################################################################
	
				for i in $( cat cleanup.txt ); do
	
					if [ -f ./$i ] ; then
						rm -f ./$i
					fi
				done
				CLEANED_UP=YES
				rm -f cleanup.txt
				exit 1
			fi
		fi
	fi
fi


###########################################################################################################################
# Unpack Debug scripts - OS Dependent
###########################################################################################################################

if [ ! -f tempfiles ] ; then 
	if [ "$EXTRACTUTILS" = "YES" ]	; then 
		echo ""
		echo "Utilities extracted..."
		echo ""
	fi
fi	

if [ -f tempfiles ] ; then 
	mv -f tempfiles tempfiles.sh >> ./misc_output.txt 2>&1
	./tempfiles.sh
	rm -rf tempfiles.sh >> ./misc_output.txt 2>&1
fi	
	





if [ "$EXTRACTUTILS" = "YES" ] ; then
	if [ -f all_cli ] ; then
		echo ""
		echo "All Utilities extracted..."
		echo ""
	fi
###########################################################################################################################
# Clean up
###########################################################################################################################


	for i in $( cat cleanup.txt ); do

		if [ -f ./$i ] ; then
			rm -f ./$i
		fi
	done
	
	CLEANED_UP=YES
	rm -f cleanup.txt	
	exit 0
fi

echo "File Size Check - 3A" >> ./misc_output.txt 2>&1
ls -latr >> ./misc_output.txt 2>&1

###########################################################################################################################
# Create unique file/subdirectory name
###########################################################################################################################


if [ "$OS_LSI" = "linux" ] ; then tw_host=$HOSTNAME; fi
if [ "$VMWARE_SUPPORTED" = "YES" ] ; then tw_host=`hostname`; fi


if [ "$TWGETPARTIALMODE" = "STANDARD" ] ; then TWdescriptor=lsi; fi
if [ "$TWGETMONITORMODE" = "MONITOR" ] ; then TWdescriptor=MONITOR; fi
if [ "$TWPRINTFILENAMETRIGGER" = "YES" ] ; then TWdescriptor=TRIGGERED; fi

tw_hostname=`echo $tw_host | cut -d. -f1`

fileName=$TWdescriptor.$OS_LSI.$tw_hostname.$todayDate.$currentTime

###########################################
# 3W/MR/HBA - Not required for Enable Feature switches
###########################################
if [ "$TWSETONLY" = "NO" ] ; then
	mkdir $fileName
	mkdir $fileName/script_workspace
	mkdir $fileName/LSI_Products
	mkdir $fileName/LSI_Products/MegaRAID
	mkdir $fileName/LSI_Products/MegaRAID/Notes
	mkdir $fileName/LSI_Products/MegaRAID/storcli
	mkdir $fileName/LSI_Products/HBA
	mkdir $fileName/LSI_Products/HBA/Notes

	# Used in AEN Sort
	echo Info > $fileName/script_workspace/mr_aen_types.txt
	echo Warning >> $fileName/script_workspace/mr_aen_types.txt
	echo Critical >> $fileName/script_workspace/mr_aen_types.txt
	echo Fatal >> $fileName/script_workspace/mr_aen_types.txt
	echo Progress >> $fileName/script_workspace/mr_aen_types.txt
	echo Obsolete >> $fileName/script_workspace/mr_aen_types.txt
	
	
	#For output files
	if [ "$CLEANED_UP" = "NO" ] ; then
		cp $BASECMD ./$fileName/script_workspace
		cp Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code ./$fileName/Notes/Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code.txt >> ./misc_output.txt 2>&1
		if [ "$TWGETSKIPHBA" != "YES" ] ; then
			cp Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code ./$fileName/LSI_Products/HBA/Notes/Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code.txt >> ./misc_output.txt 2>&1
		fi
		if [ "$TWGETSKIPMEGARAID" != "YES" ] ; then
			cp Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code ./$fileName/LSI_Products/MegaRAID/Notes/Sense-Key_ASC-ASCQ_Opcodes_ATA-Command_Codes-Set_Features_Code.txt >> ./misc_output.txt 2>&1
			cp MegaRAID_Terminology ./$fileName/LSI_Products/MegaRAID/Notes/MegaRAID_Terminology.txt >> ./misc_output.txt 2>&1
		fi
		mv -f aens_mr.txt ./$fileName/script_workspace/aens_mr.txt >> ./misc_output.txt 2>&1

		if [ "$OS_LSI" = "linux" ] ; then
			#External		
			if [ "$all_cli" = "all_cli" ] ; then
				if [ "$TWGETSKIPHBA" != "YES" ] ; then
					cp ./linux_HBA_Debug_Notes_ext.txt ./$fileName/LSI_Products/HBA/Notes/HBA_Debug_Notes_ext.txt >> ./misc_output.txt 2>&1
					cp ./linux_mpt2sas_debug.h ./$fileName/LSI_Products/HBA/Notes/mpt2sas_debug.h >> ./misc_output.txt 2>&1
					cp ./linux_mpt3sas_debug.h ./$fileName/LSI_Products/HBA/Notes/mpt3sas_debug.h >> ./misc_output.txt 2>&1
				fi
			fi
			#Internal
			if [ "$all_cli" != "all_cli" ] ; then
				if [ "$TWGETSKIPHBA" != "YES" ] ; then
					cp ./linux_HBA_Debug_Notes_int.txt ./$fileName/LSI_Products/HBA/Notes/HBA_Debug_Notes_int.txt >> ./misc_output.txt 2>&1
					cp ./linux_mpt2sas_debug.h ./$fileName/LSI_Products/HBA/Notes/mpt2sas_debug.h >> ./misc_output.txt 2>&1
					cp ./linux_mpt3sas_debug.h ./$fileName/LSI_Products/HBA/Notes/mpt3sas_debug.h >> ./misc_output.txt 2>&1
				fi
			fi
		fi
	fi


	if [ "$TWPRINTFILENAME" = "YES" ] ; then echo $fileName.tar.gz >> LSICAPTUREFILES.TXT; fi
	
	if [ "$TWGETPARTIALMODE" != "G_AEC" ] ; then
		if [ "$TWGETPARTIALMODE" != "G_AEC_DPMSTAT" ] ; then
			if [ "$TWGETPARTIALMODE" != "G_DPMSTAT" ] ; then
				if [ "$TWGETSKIPHBA" != "YES" ] ; then
					echo ""
					
					
					###########################################################################################################################
					# HBA - Standard
					# Disabling and Getting HBA Ring Buffer IF Enabled 
					#
					# ***********No longer supported with -E_RB
					# Only automatic HTB read with 94xx HBA and => ph 11 driver and FW is supported***********
					###########################################################################################################################
					
					
					# Use Scrutiny to automatically get HTB if one exists
					# Also collect core dump here if one exists
					
					NUMITEMS=`./scl --list | sed  -e 1,/DeviceId/d | wc -l` >> ./misc_output.txt 2>&1
					for ((instance=1; instance<=$NUMITEMS; instance++))
					do
					 
						./scl -i $instance db -query -trace >> ./misc_output.txt 2>&1
						if [ $? -ne 0 ]
						then
							: #in case we want to do something here
						else
							./scl -i $instance db -read -trace -file $fileName/LSI_Products/HBA/$todayDate.$currentTime.HTB_device_$instance.rb >> ./misc_output.txt 2>&1
							echo HTB saved as $fileName/LSI_Products/HBA/$todayDate.$currentTime.HTB_device_$instance.rb
							echo ""
							echo ""
						fi

						if [ ! -d $fileName/LSI_Products ] ; then mkdir $fileName/LSI_Products ; fi
						if [ ! -d $fileName/LSI_Products/HBA ] ; then mkdir $fileName/LSI_Products/HBA ; fi
						if [ ! -d $fileName/LSI_Products/HBA/12Gb ] ; then mkdir $fileName/LSI_Products/HBA/12Gb ; fi
						if [ ! -d $fileName/LSI_Products/HBA/12Gb/Cores ] ; then mkdir $fileName/LSI_Products/HBA/12Gb/Cores ; fi
						
						#Try to save coredump
						./scl -i $instance coredump -ul -f $fileName/LSI_Products/HBA/12Gb/Cores/core_info_controller$instance.txt >> ./misc_output.txt 2>&1
						if [ -f $fileName/LSI_Products/HBA/12Gb/Cores/core_info_controller$instance.txt ] ; then
							grep coredump_id $fileName/LSI_Products/HBA/12Gb/Cores/core_info_controller$instance.txt 
							if [ $? -eq 0 ] ;  then
								mv ./coredump_id*.zip $fileName/LSI_Products/HBA/12Gb/Cores
				
								echo "Coredump(s) from controller $instance moved to $fileName/LSI_Products/HBA/12Gb/Cores/"
							fi
						fi
					done
				fi
			fi 
		fi
	fi 
fi


if [ "$TWGETSKIPHBA" != "YES" ] ; then
	###########################################
	# Enabling/Disabling HBA Linux Driver Logging, need to check other OS driver logging options.
	###########################################
	
	if [ "$OS_LSI" = "linux" ] ; then
		if [ "$TWGETPARTIALMODE" = "E_SAS2LOG" ]||[ "$TWGETPARTIALMODE" = "E_SAS2LOG_RB" ] ; then
			for i in $(ls /sys/class/scsi_host -1);  do
				if [ `cat /sys/class/scsi_host/$i/proc_name` = "mpt2sas" ] ; then
					echo 00ffffff > /sys/class/scsi_host/$i/logging_level
					logging_level=`cat /sys/class/scsi_host/$i/logging_level`
					echo "Setting the Driver Logging level to $logging_level for all SAS2 HBAs..."
				fi
			done
		fi
		if [ "$TWGETPARTIALMODE" = "E_SAS2LOG1" ]||[ "$TWGETPARTIALMODE" = "E_SAS2LOG1_RB" ] ; then
			for i in $(ls /sys/class/scsi_host -1);  do
				if [ `cat /sys/class/scsi_host/$i/proc_name` = "mpt2sas" ] ; then
					echo 000003f8 > /sys/class/scsi_host/$i/logging_level
					logging_level=`cat /sys/class/scsi_host/$i/logging_level`
					echo "Setting the Driver Logging level to $logging_level for all SAS2 HBAs..."
				fi
			done
		fi
		
		if [ "$TWGETPARTIALMODE" = "E_SAS3LOG" ]||[ "$TWGETPARTIALMODE" = "E_SAS3LOG_RB" ] ; then
			for i in $(ls /sys/class/scsi_host -1);  do
				if [ `cat /sys/class/scsi_host/$i/proc_name` = "mpt3sas" ] ; then
					echo 00ffffff > /sys/class/scsi_host/$i/logging_level
					logging_level=`cat /sys/class/scsi_host/$i/logging_level`
					echo "Setting the Driver Logging level to $logging_level for all SAS3 HBAs..."
				fi
			done
		fi
		if [ "$TWGETPARTIALMODE" = "E_SAS3LOG1" ]||[ "$TWGETPARTIALMODE" = "E_SAS3LOG1_RB" ] ; then
			for i in $(ls /sys/class/scsi_host -1);  do
				if [ `cat /sys/class/scsi_host/$i/proc_name` = "mpt3sas" ] ; then
					echo 000003f8 > /sys/class/scsi_host/$i/logging_level
					logging_level=`cat /sys/class/scsi_host/$i/logging_level`
					echo "Setting the Driver Logging level to $logging_level for all SAS3 HBAs..."
				fi
			done
		fi
	
		if [ "$TWGETPARTIALMODE" = "D_SAS2LOG" ] ; then
			for i in $(ls /sys/class/scsi_host -1);  do
				if [ `cat /sys/class/scsi_host/$i/proc_name` = "mpt2sas" ] ; then
					echo 0 > /sys/class/scsi_host/$i/logging_level
					logging_level=`cat /sys/class/scsi_host/$i/logging_level`
					echo "Setting the Driver Logging level to $logging_level for all SAS2 HBAs..."
				fi
			done
		fi
		if [ "$TWGETPARTIALMODE" = "D_SAS3LOG" ] ; then
			for i in $(ls /sys/class/scsi_host -1);  do
				if [ `cat /sys/class/scsi_host/$i/proc_name` = "mpt3sas" ] ; then
					echo 0 > /sys/class/scsi_host/$i/logging_level
					logging_level=`cat /sys/class/scsi_host/$i/logging_level`
					echo "Setting the Driver Logging level to $logging_level for all SAS3 HBAs..."
				fi
			done
		fi
	###########################################
	# If E_SAS2LOG or E_SAS3LOG exit
	###########################################
	
	
		if [ "$TWGETPARTIALMODE" = "E_SAS2LOG" ]||[ "$TWGETPARTIALMODE" = "E_SAS2LOG1" ]||[ "$TWGETPARTIALMODE" = "E_SAS3LOG" ]||[ "$TWGETPARTIALMODE" = "E_SAS3LOG1" ]||[ "$TWGETPARTIALMODE" = "D_SAS2LOG" ]||[ "$TWGETPARTIALMODE" = "D_SAS3LOG" ] ; then
			if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
				date '+%H:%M:%S.%N'
			fi
			if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
				date '+%H:%M:%S'
			fi
	
	###########################################################################################################################
	# Clean up
	###########################################################################################################################
	
	
			for i in $( cat cleanup.txt ); do
	
				if [ -f ./$i ] ; then
				rm -f ./$i
				fi
			done
		
			CLEANED_UP=YES
			rm -f cleanup.txt
			exit 0
		fi
	fi	
fi	
				
if [ "$TWGETSKIPHBA" != "YES" ] ; then
	###########################################
	# Enabling HBA Ring Buffer.
	###########################################
	
	
	if [ "$NO_lsut_LSI_HBAs" != "YES" ] ; then
		if [ "$TWGETPARTIALMODE" = "E_RB" ]||[ "$TWGETPARTIALMODE" = "E_SAS2LOG_RB" ]||[ "$TWGETPARTIALMODE" = "E_SAS2LOG1_RB" ]||[ "$TWGETPARTIALMODE" = "E_SAS3LOG_RB" ]||[ "$TWGETPARTIALMODE" = "E_SAS3LOG1_RB" ] ; then
			
						echo "********************************************************************"
						echo ""
						echo " Manually getting the RB with LSIGet is no longer supported"
						echo " Automatic Ring Buffer is collected with 9400 and phase 11 or later"
						echo " Please work with your FAE or support person for instructions"
						echo " on getting the Ring Buffer manually."
						echo ""
						echo "*******************************************************************"

	###########################################################################################################################
	# Clean up
	###########################################################################################################################
	
	
			for i in $( cat cleanup.txt ); do
	
				if [ -f ./$i ] ; then
				rm -f ./$i
				fi
			done
		
			CLEANED_UP=YES
			rm -f cleanup.txt
			exit 0
							
		fi
	fi
fi

if [ "$TWGETSKIPMEGARAID" != "YES" ] ; then
	###########################################
	# If G_* Grab MR show/show all equivalent
	###########################################
	if [ "$TWPARTIALCAP" = "YES" ] ; then
	
		for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
			#cho ".................................................||................................................."
			echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
			echo "........................................./$MCLI_NAME show............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
			$MCLI_LOCATION$MCLI_NAME show 2>> ./misc_output.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
			echo "................................../$MCLI_NAME /c$i show all.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
			$MCLI_LOCATION$MCLI_NAME /c$i show all 2>> ./misc_output.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
			echo "Collecting Controller Information for MegaRAID Controller C$i..." >> ./misc_output.txt 2>&1
		done
	fi
fi



	


###########################################################################################################################
# LSI HBA & LSI Expander Info
###########################################################################################################################

if [ "$TWGETSKIPHBA" != "YES" ] ; then
	smartctl -h > ./$fileName/script_workspace/smartctl-h.txt 2>&1
	if [ "$?" = "0" ] ; then
		echo "Starting Generic Smartctl Data Collection..."
		if [ ! -d ./$fileName/LSI_Products/HBA ] ;then mkdir ./$fileName/LSI_Products/HBA ; fi
		if [ ! -d ./$fileName/LSI_Products/HBA/SMARTCTL ] ; then mkdir ./$fileName/LSI_Products/HBA/SMARTCTL ; fi

		echo "Supports all devices, doesn't currently distinguish between IOC/HBA and NON LSI/Avago/BRCM controlled devices" > ./$fileName/LSI_Products/HBA/SMARTCTL/Generic_NOT_necessarily_BRCM_IOC_or_HBA.txt

		for i in $( ls /dev/sd* 2>> ./misc_output.txt ) ; do 
			dev=$(basename $i)
			#cho ".................................................||................................................."
			echo ".....................................smartctl --all /dev/${dev}....................................." > ./$fileName/LSI_Products/HBA/SMARTCTL/smartctl_${dev}.txt 2>&1
			smartctl --all /dev/${dev} >> ./$fileName/LSI_Products/HBA/SMARTCTL/smartctl_${dev}.txt 2>&1

			echo ".............................smartctl -g wcache /dev/${dev} - Write Cache:.........................." >> ./$fileName/LSI_Products/HBA/SMARTCTL/smartctl_${dev}.txt 2>&1
			smartctl -g wcache /dev/${dev} | $grep "Write cache is:" >> ./$fileName/LSI_Products/HBA/SMARTCTL/smartctl_${dev}.txt 2>&1

			echo ".............................smartctl -g wcache /dev/${dev} - Write Cache:.........................." >> ./$fileName/LSI_Products/HBA/SMARTCTL/smartctl_WC.txt 2>&1
			smartctl -g wcache /dev/${dev} | $grep "Write cache is:" >> ./$fileName/LSI_Products/HBA/SMARTCTL/smartctl_WC.txt 2>&1
		done
	fi
fi


#############################################################################
### Run sg_inq
#############################################################################

if [ "$?" = "0" ] ; then
	sg_scan -V  > ./$fileName/script_workspace/sg_scan-V.txt 2>&1
	sg_inq -V >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		sg_inq -V  > ./$fileName/script_workspace/sg_inq-V.txt 2>&1
		echo $fileName > ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
		#cho ".................................................||................................................."
		echo ".............................................sg_scan -V............................................." >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
		sg_scan -V >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
		#cho ".................................................||................................................."
		echo ".............................................sg_inq -V.............................................." >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
		sg_inq -V >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
		#cho ".................................................||................................................."
		echo "..............................................sg_scan..............................................." >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
		sg_scan >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
		for i in $(sg_scan | cut -d/ -f 3 | cut -d: -f 1) ; do
			#cho ".................................................||................................................."
			echo "........................................sg_inq -vvv /dev/$i........................................." >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
			sg_inq -vvv /dev/$i >> ./$fileName/sg_scan-sg_inq-vvv_dev-sgX.txt 2>&1
			echo "...........................................sg_readcap -v /dev/$i................" >> ./$fileName/sg_readcap_sgX.txt
			sg_readcap	-v /dev/$i >> ./$fileName/sg_readcap_sgX.txt 2>&1

		done
	fi
fi
		




#Grab all scsi_host info, need to see if functional prior to lsut
if [ -d /sys/class/scsi_host ] ; then
	mkdir ./$fileName/scsi_host
	for i in $( ls /sys/class/scsi_host ); do
		if [ -d /sys/class/scsi_host/${i} ] ; then
			$grep -i -e mpt2sas -e mpt3sas -e megaraid -e 3ware -e avago /sys/class/scsi_host/${i}/proc_name>> ./misc_output.txt 2>&1
			if [ "$?" = "0" ] ; then 				
				mkdir ./$fileName/scsi_host/$i
				for j in $( ls /sys/class/scsi_host/${i} ); do
					if [ -f /sys/class/scsi_host/${i}/"${j}" ] ; then
						#First Level
						cat /sys/class/scsi_host/${i}/"${j}" > ./$fileName/scsi_host/${i}/"${j}".txt 2>> ./$fileName/script_workspace/lsiget_errorlog.txt
					fi
				done
			fi
		fi
	done
fi




#Grab all /proc/scsi/sg, need to see if functional prior to lsut, consolidated all /proc data collection here.

if [ -d /proc ] ; then
	if [ ! -d ./$fileName/proc ] ; then mkdir ./$fileName/proc ; fi
	for i in pci interrupts cmdline cpuinfo buddyinfo devices diskstats dma filesystems iomem ioports kallsyms mdstat meminfo misc modules mounts mtrr partitions pci slabinfo stat uptime version vmstat zoneinfo scsi ; do 
		if [ -f /proc/$i ] ; then
			cat /proc/$i > ./$fileName/proc/${i} 2>> ./misc_output.txt				
		fi
	done
	ls -latrR /proc > ./$fileName/proc/proc-latrR.txt 2>&1 ./$fileName/script_workspace/lsiget_errorlog.txt
fi

if [ -d /proc/scsi ] ; then
	if [ ! -d ./$fileName/proc/scsi ] ; then mkdir ./$fileName/proc/scsi; fi
	for i in $( ls /proc/scsi ) ; do
		if [ -f /proc/scsi/${i} ] ; then
			cat /proc/scsi/${i} > ./$fileName/proc/scsi/${i} 2>> ./$fileName/script_workspace/lsiget_errorlog.txt
		fi
	done
fi
for i in sg  megaraid_sas ; do
	if [ -d /proc/scsi/${i} ] ; then
		if [ ! -d ./$fileName/proc/scsi/${i} ] ; then mkdir ./$fileName/proc/scsi/${i}; fi
		for j in $( ls /proc/scsi/${i} ); do
			if [ -f /proc/scsi/${i}/${j} ] ; then
				cat /proc/scsi/${i}/${j} > ./$fileName/proc/scsi/${i}/${j} 2>> ./$fileName/script_workspace/lsiget_errorlog.txt
			fi
		done
	fi		
done
if [ -f /proc/scsi/scsi ] ; then 
	cat /proc/scsi/scsi > ./$fileName/proc/scsi/scsi 2>> ./misc_output.txt
fi
if [ -d /proc/sys/kernel ] ; then
	if [ ! -d ./$fileName/proc/sys ] ; then mkdir ./$fileName/proc/sys; fi
	if [ ! -d ./$fileName/proc/sys/kernel ] ; then mkdir ./$fileName/proc/sys/kernel ; fi
	$grep -r . /proc/sys/kernel/ > ./$fileName/proc/sys/kernel/grep-r_._proc_sys_kernel.txt 2>> ./misc_output.txt
	for i in $( ls /proc/sys/kernel ); do
		if [ -f /proc/sys/kernel/${i} ] ; then
			cat /proc/scsi/kernel/${i} > ./$fileName/proc/sys/kernel/${i} 2>> ./$fileName/script_workspace/lsiget_errorlog.txt
		fi
	done
fi
if [ -d /proc/sys/vm ] ; then 
	if [ ! -d ./$fileName/proc/sys ] ; then mkdir ./$fileName/proc/sys; fi
	if [ ! -d ./$fileName/proc/sys/vm ] ; then mkdir ./$fileName/proc/sys/vm ; fi
	for i in $( ls /proc/sys/vm ); do
		if [ -f /proc/sys/vm/${i} ] ; then 
			cat /proc/sys/vm/${i} > ./$fileName/proc/sys/vm/${i}.txt 2>> ./misc_output.txt
		fi
	done
fi


scsi_logging_level -g >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then 
	scsi_logging_level -g > ./$fileName/proc/scsi_logging_level-g.txt 
fi
	

if [ -f /proc/bus/pci/devices ] ; then cat /proc/bus/pci/devices > ./$fileName/proc/bus-pci-devices ; fi 2>> ./misc_output.txt
if [ -f /proc/net/dev ] ; then cat /proc/net/dev > ./$fileName/proc/net-dev ; fi 2>> ./misc_output.txt



if [ "$TWGETSKIPHBA" != "YES" ] ; then
	if [ "$NO_lsut_LSI_HBAs" != "YES" ] ; then 
		echo "Starting the LSI HBA Data Collection..."
	
		for i in $(./$LSUT_NAME 0 2>> ./misc_output.txt | awk 'BEGIN{prt=0}{if (prt==1) print $0; else if ($3=="Chip") prt=1}' | $grep LSI | cut -d. -f1); do # Support for unlimited HBAs
		
			#cho ".................................................||................................................."
			echo $fileName >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo "..............................................LSITool..............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME 0 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo "" >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo ".............................................LSITool 1.............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i 1 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo ".............................................LSITool 8.............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i 8 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo ".............................................LSITool 16............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i 16 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo ".............................................LSITool 17............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i 17 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo "...........................................LSITool 21-1-2..........................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i -a 21,1,2,0,0 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo "..........................................LSITool 25-2-0-0.........................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i -a 25,2,0,0 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			#echo ".............................................LSITool 42............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			#./$LSUT_NAME -p $i 42 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			#BFS - commented out 42 as it takes too long on large systems

			echo ".............................................LSITool 47............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i 47 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo ".............................................LSITool 66............................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i 66 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			echo "...........................................LSITool 64-0-0..........................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
			./$LSUT_NAME -p $i -a 64,,,0,0, 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
	
			#misc pl cli commands
			for j in dbg info param mids dev iocount status phy cphy port smp encl expconn exp cmdbuf eminfo inittbl hwftrs stallnf txinfo temp mreq bt1680 port ; do
				./$LSUT_NAME -p $i -a 65,pl_${j}_hba${i}.txt,"pl ${j}",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
				if [ ! -d ./$fileName/LSI_Products/HBA/Details ] ; then mkdir ./$fileName/LSI_Products/HBA/Details ; fi
				if [ -f ./pl_${j}_hba${i}.txt ] ; then
					$grep -e "pl --   PL Commands" -e "pl -- PL Commands" ./pl_${j}_hba${i}.txt >> ./misc_output.txt 2>&1
					if [ "$?" != "0" ] ; then
						#cho ".................................................||................................................."
						echo "......................................pl_${j}_hba${i}.txt..........................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
						cat ./pl_${j}_hba${i}.txt >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
						mv ./pl_${j}_hba${i}.txt ./$fileName/LSI_Products/HBA/Details
						else
						mv ./pl_${j}_hba${i}.txt ./$fileName/script_workspace
					fi
				fi
			done		
			
			./$LSUT_NAME -p $i -a 65,pl_int_0_hba${i}.txt,"pl int 0",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
			./$LSUT_NAME -p $i -a 65,pl_int_1_hba${i}.txt,"pl int 1",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
			./$LSUT_NAME -p $i -a 65,pl_fpe_stats_hba${i}.txt,"pl fpe stats",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
			./$LSUT_NAME -p $i -a 65,pl_fpe_iopcq_hba${i}.txt,"pl fpe iopcq",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
			./$LSUT_NAME -p $i -a 65,pl_tm_outstanding_hba${i}.txt,"pl tm outstanding",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
			./$LSUT_NAME -p $i -a 65,pl_tm_task_hba${i}.txt,"pl tm task",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
			./$LSUT_NAME -p $i -a 65,pl_tbm_reg_all_hba${i}.txt,"pl tbm reg all",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
	
			for j in pl_int_0_hba${i}.txt pl_int_1_hba${i}.txt pl_fpe_stats_hba${i}.txt pl_fpe_iopcq_hba${i}.txt pl_tm_outstanding_hba${i}.txt pl_tm_task_hba${i}.txt pl_tbm_reg_all_hba${i}.txt ; do
				if [ ! -d ./$fileName/LSI_Products/HBA/Details ] ; then mkdir ./$fileName/LSI_Products/HBA/Details ; fi
				if [ -f ./${j} ] ; then
					$grep -e "pl --   PL Commands" -e "pl -- PL Commands" ./pl_${j}_hba${i}.txt >> ./misc_output.txt 2>&1
					if [ "$?" != "0" ] ; then 
						#cho ".................................................||................................................."
						echo ".............................................${j}..........................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
						cat ./${j} >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
						mv ./${j} ./$fileName/LSI_Products/HBA/Details
						else
						mv ./${j} ./$fileName/script_workspace
					fi
				fi
			done	
	

	
			./$LSUT_NAME -p $i -a 65,iop_mreq_m_hba${i}.txt,"iop mreq m",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt	
			./$LSUT_NAME -p $i -a 65,iop_mreq_s_hba${i}.txt,"iop mreq s",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt	
			./$LSUT_NAME -p $i -a 65,iop_mreq_r_hba${i}.txt,"iop mreq r",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt	
			./$LSUT_NAME -p $i -a 65,iop_pm_getgmode_hba${i}.txt,"iop pm getgmode",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt	
			./$LSUT_NAME -p $i -a 65,iop_fpe_maxex_hba${i}.txt,"iop fpe maxex",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt	
			./$LSUT_NAME -p $i -a 65,iop_fpe_maxev_hba${i}.txt,"iop fpe maxev",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt	
			./$LSUT_NAME -p $i -a 65,iop_perfmon_show_hba${i}.txt,"iop perfmon show",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt	
		
	
			for j in iop_gpio_hba${i}.txt iop_mreq_m_hba${i}.txt iop_mreq_s_hba${i}.txt iop_mreq_r_hba${i}.txt iop_pm_getgmode_hba${i}.txt iop_fpe_maxex_hba${i}.txt iop_fpe_maxev_hba${i}.txt iop_perfmon_show_hba${i}.txt; do
				if [ ! -d ./$fileName/LSI_Products/HBA/Details ] ; then mkdir ./$fileName/LSI_Products/HBA/Details ; fi
				if [ -f ./${j} ] ; then 
					$grep -e "iop --  IOP commands" -e "iop -- IOP Commands" ./${j} >> ./misc_output.txt 2>&1
					if [ "$?" != "0" ] ; then 
						#cho ".................................................||................................................."
						echo ".............................................${j}..........................................." >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
						cat ./${j} >> ./$fileName/LSI_Products/HBA/properties_hba$i.txt
						mv ./${j} ./$fileName/LSI_Products/HBA/Details/.
						else
						mv ./${j} ./$fileName/script_workspace
					fi
				fi
			done	
	
		
			#echo "............................................LSITool 100............................................." >> ./$fileName/LSI_Products/HBA/100_hba$i.txt
			./$LSUT_NAME -p $i 100 2>> ./misc_output.txt >> ./$fileName/LSI_Products/HBA/100_hba$i.txt >> ./$fileName/LSI_Products/HBA/100_hba$i.txt
			
			echo "REM lsipage is an LSI internal utility" > ./$fileName/LSI_Products/HBA/100_hba$i.bat
			echo "copy 100_hba$i.txt 100_hba$i" >> ./$fileName/LSI_Products/HBA/100_hba$i.bat
			echo "lsipage -h -i 100_hba$i" >> ./$fileName/LSI_Products/HBA/100_hba$i.bat
			echo "del 100_hba$i" >> ./$fileName/LSI_Products/HBA/100_hba$i.bat
	
			#cho ".................................................||................................................."
			echo ".................ManPages 17-31, option 100 does not capture these currently........................" >> ./$fileName/LSI_Products/HBA/ManPages_16-31_hba$i.txt
			echo ".............ManPages 30 Offset 0x8 shows Databolt, 00200000 Enabled, 00200001 Disabled............." >> ./$fileName/LSI_Products/HBA/ManPages_16-31_hba$i.txt		
			echo ".......................00200002 DataBOLT and Fast Context Switching Disabled........................" >> ./$fileName/LSI_Products/HBA/ManPages_16-31_hba$i.txt		
			for j in 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31; do 
				#cho ".................................................||................................................."
				echo ".............................................ManPage $j............................................." >> ./$fileName/LSI_Products/HBA/ManPages_16-31_hba$i.txt
				./$LSUT_NAME -p $i -a 9,9,$j,0,,,0 2>> ./misc_output.txt | $grep " : " >> ./$fileName/LSI_Products/HBA/ManPages_16-31_hba$i.txt
			done
		done
	fi

	###########################################################################################################################
	#Starting scl HBA Data Collection
	############################################################################################################################
	echo "Before scli HBA section initial test"  >> ./misc_output.txt 2>&1

	if [ "$NO_scl_EXP_or_IOC" = "NO" ] ; then
 
		echo "After scli HBA section initial test"  >> ./misc_output.txt 2>&1
		./scl --list | $grep DeviceId -A 100 | $grep ")" | $grep -v -e SAS3x -e SAS35x | $grep -v -e SAS35 >> ./$fileName/script_workspace/sc_gen3_hbas_raw.txt 2>&1 
		if [ ! -s ./$fileName/script_workspace/sc_gen3_hbas_raw.txt ] ; then mv ./$fileName/script_workspace/sc_gen3_hbas_raw.txt ./$fileName/script_workspace/0Byte_sc_gen3_hbas_raw.txt >> ./misc_output.txt 2>&1 ; fi
		if [ -f ./$fileName/script_workspace/sc_gen3_hbas_raw.txt ] ; then	
		 	NO_scl_IOC=NO
		 				echo IN__scl_IOC_Branch_1 >> ./misc_output.txt 2>&1
			if [ ! -d $fileName/LSI_Products ] ; then mkdir $fileName/LSI_Products ; fi
			if [ ! -d $fileName/LSI_Products/HBA ] ; then mkdir $fileName/LSI_Products/HBA ; fi
			if [ ! -d $fileName/LSI_Products/HBA/12Gb ] ; then mkdir $fileName/LSI_Products/HBA/12Gb ; fi
			if [ ! -d $fileName/LSI_Products/HBA/12Gb/Details ] ; then mkdir $fileName/LSI_Products/HBA/12Gb/Details ; fi
			./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x -e SAS35x | $grep -v -e SAS35 > $fileName/LSI_Products/HBA/12Gb/Details/sc_gen3_hbas.txt
			./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x -e SAS35x | $grep -v -e SAS35 | $grep -v DeviceId | cut -d')' -f1 > ./$fileName/script_workspace/sc_gen3_hba_nums.txt
			echo IN__scl_IOC_Branch_2 >> ./misc_output.txt 2>&1
			for i in $( cat ./$fileName/script_workspace/sc_gen3_hba_nums.txt); do
				echo IN__scl_IOC_Branch_3 >> ./misc_output.txt 2>&1
				./scl -i $i ioc -wwid | $grep "Current WWID" | cut -d: -f2 | cut -d' ' -f2 > ./$fileName/script_workspace/sc_hba_${i}_sasaddr.txt
				for j in $( cat ./$fileName/script_workspace/sc_hba_${i}_sasaddr.txt); do 
					echo IN__scl_IOC_Branch_4_HBA${i} >> ./misc_output.txt 2>&1
					#cho "......................................::......................................."
					echo .................................scli HBAs-IOCs................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...................................show -all.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i show -all >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ......................................scan...................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i scan >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ....................................phy -da..................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i phy -da >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...................................phy -port.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i phy -port >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ....................................phy -err.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i phy -err >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					#echo ...................................phy -evnt.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#./scl -i $i phy -evnt >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					# Commented out phy events due to not being configured on most controlers
					#cho "......................................::......................................."
					echo ..............................ioc -facts -decode................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i ioc -facts -decode >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..................................ioc -diserr................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i ioc -diserr >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................ioc -displaysas.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i ioc -displaysas >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop pci status............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci status >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop pci lnkspdr.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci lnkspdr >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop pci lnkwdr............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci lnkwdr >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli iop pci reg................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci reg >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop show stack............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop show stack >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop show diag................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop show diag >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli pl status.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl status >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...................................cli pl dev................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl dev >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ................................cli pl iocount.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl iocount >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..................................cli pl mids................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl mids >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli pl reg link................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg link >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli pl tm task................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl tm task >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .............................cli pl tm outstanding.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl tm outstanding >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..............................cli pl reg hwcontext.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg hwcontext >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..............................cli pl reg hwdevtab............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg hwdevtab >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..............................cli pl reg hwsatatab.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg hwsatatab >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..................................cfg -dumpall.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cfg -dumpall >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ......................................logs...................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i logs >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
				done
			done
		fi
		echo "After scli HBA section initial test-35"  >> ./misc_output.txt 2>&1
		sleep 2
		echo "BFS added pause due to next command not working on some systems" >> ./misc_output.txt 2>&1
		./scl --list | $grep DeviceId -A 100 | $grep ")" | $grep -v -e SAS3x -e SAS35x | $grep SAS32  >> ./$fileName/script_workspace/sc_gen35_hbas_raw.txt 2>&1
		if [ ! -s ./$fileName/script_workspace/sc_gen35_hbas_raw.txt ] ; then mv ./$fileName/script_workspace/sc_gen35_hbas_raw.txt ./$fileName/script_workspace/0Byte_sc_gen35_hbas_raw.txt >> ./misc_output.txt 2>&1 ; fi
	#	BFS - change ./scl --list | $grep DeviceId -A 100 | $grep ")" | $grep -v -e SAS3x -e SAS35x | $grep -e SAS35 >> ./$fileName/script_workspace/sc_gen35_hbas_raw.txt 2>&1 
		if [ ! -s ./$fileName/script_workspace/sc_gen35_hbas_raw.txt ] ; then mv ./$fileName/script_workspace/sc_gen35_hbas_raw.txt ./$fileName/script_workspace/0Byte_sc_gen35_hbas_raw.txt >> ./misc_output.txt 2>&1 ; fi
		if [ -f ./$fileName/script_workspace/sc_gen35_hbas_raw.txt ] ; then	
		 	NO_scl_IOC=NO
			echo IN__scl_IOC_Branch_1-35 >> ./misc_output.txt 2>&1
			if [ ! -d $fileName/LSI_Products ] ; then mkdir $fileName/LSI_Products ; fi
			if [ ! -d $fileName/LSI_Products/HBA ] ; then mkdir $fileName/LSI_Products/HBA ; fi
			if [ ! -d $fileName/LSI_Products/HBA/12Gb ] ; then mkdir $fileName/LSI_Products/HBA/12Gb ; fi
			if [ ! -d $fileName/LSI_Products/HBA/12Gb/Details ] ; then mkdir $fileName/LSI_Products/HBA/12Gb/Details ; fi
			#./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x -e SAS35x | $grep -e SAS35 > $fileName/LSI_Products/HBA/12Gb/Details/sc_gen35_hbas.txt
			./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x -e SAS35x | $grep 32 > $fileName/LSI_Products/HBA/12Gb/Details/sc_gen35_hbas.txt
			#./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x -e SAS35x | $grep -e SAS35  | $grep -v DeviceId | cut -d')' -f1 > ./$fileName/script_workspace/sc_gen35_hba_nums.txt
			./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x -e SAS35x | $grep SAS32  | $grep -v DeviceId | cut -d')' -f1 > ./$fileName/script_workspace/sc_gen35_hba_nums.txt
			echo IN__scl_IOC_Branch_2 >> ./misc_output.txt 2>&1
			for i in $( cat ./$fileName/script_workspace/sc_gen35_hba_nums.txt); do
				echo IN__scl_IOC_Branch_3-35 >> ./misc_output.txt 2>&1
				./scl -i $i ioc -wwid | $grep "Current WWID" | cut -d: -f2 | cut -d' ' -f2 > ./$fileName/script_workspace/sc_hba_${i}_sasaddr.txt
				for j in $( cat ./$fileName/script_workspace/sc_hba_${i}_sasaddr.txt); do 
					echo IN__scl_IOC_Branch_4_HBA${i}-35 >> ./misc_output.txt 2>&1
					#cho "......................................::......................................."
					echo .................................scli HBAs-IOCs................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl --list | $grep DeviceId -A 100 | $grep -v -e SAS3x >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...................................show -all.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i show -all >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ......................................scan...................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i scan >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ....................................phy -da..................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i phy -da >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...................................phy -port.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i phy -port >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ....................................phy -err.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i phy -err >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...................................phy -evnt.................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i phy -evnt >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..............................ioc -facts -decode................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i ioc -facts -decode >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..................................ioc -diserr................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i ioc -diserr >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................ioc -displaysas.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i ioc -displaysas >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................ioc -displaypcie.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i ioc -displaysas >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop pci status............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci status >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop pci lnkspdr.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci lnkspdr >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop pci lnkwdr............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci lnkwdr >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli iop pci reg................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci reg >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop pci resize............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci resize >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ................................cli iop pci msix................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop pci msix >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop show mem............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop show mem >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...............................cli iop show diag................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli iop show diag >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli pl status.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl status >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ...................................cli pl dev................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl dev >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ................................cli pl iocount.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl iocount >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..................................cli pl mids................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl mids >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli pl reg link................................ >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg link >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .................................cli pl tm task................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl tm task >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo .............................cli pl tm outstanding.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl tm outstanding >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..............................cli pl reg hwcontext.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg hwcontext >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..............................cli pl reg hwdevtab............................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg hwdevtab >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..............................cli pl reg hwsatatab.............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl reg hwsatatab >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					echo ..............................cli pl stats all .............................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cli pl stats all >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ..................................cfg -dumpall.................................. >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i cfg -dumpall >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					#cho "......................................::......................................."
					echo ......................................logs...................................... >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
					./scl -i $i logs >> $fileName/LSI_Products/HBA/12Gb/${j}_scli_hba${i}.txt 2>&1
				done
			done
		fi
	fi
fi




#Expander Data Collection


ls -latr >> ./misc_output.txt
if [ "$NO_lsut_LSI_HBAs" != "YES" ] ; then 
	ls -latr >> ./misc_output.txt
	if [ "$TWGETSKIPEXPANDER" != "YES" ] ; then
		ls -latr >> ./misc_output.txt
		for i in $(./$LSUT_NAME 0 2>> ./misc_output.txt | awk 'BEGIN{prt=0}{if (prt==1) print $0; else if ($3=="Chip") prt=1}' | $grep LSI | cut -d. -f1); do # Support for unlimited HBAs
			ls -latr >> ./misc_output.txt
		        for j in $(./$LSUT_NAME -p $i -a 64,,,0,0, 2>> ./misc_output.txt | $grep EnclServ | $grep LSI | cut -d. -f1); do
				ls -latr >> ./misc_output.txt
		
				./$LSUT_NAME -p $i -a 64,$j,temp_hba${i}exp${j}.txt,"adcread 1 1 1000",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
	
				./$LSUT_NAME -p $i -a 64,$j,showlogs_detail_hba${i}exp${j}.txt,"showlogs detail",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
	
				./$LSUT_NAME -p $i -a 64,$j,enclLogicalId_hba${i}exp${j}.txt,"rdcfg 0xfe01 0",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
	
				for k in date sasaddr showmfg showpost rev phyinfo serdesinfo counters rtr scedebug flashtblinfo sgpioinfo edfbinfo thread memstat coredump showtrace ssptdebug rreg ipconfig; do
					./$LSUT_NAME -p $i -a 64,$j,${k}_hba${i}exp${j}.txt,$k,exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
				done
		
				for k in starfish edfb link connection config; do
					./$LSUT_NAME -p $i -a 64,$j,debuginfo_${k}_hba${i}exp${j}.txt,"debuginfo $k",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
				done

				for k in tx rx; do
					./$LSUT_NAME -p $i -a 64,$j,serdesinfo_${k}_hba${i}exp${j}.txt,"serdesinfo $k",exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
				done
			
				echo $fileName > debuginfo_manual_hba${i}exp${j}.txt
		
				for k in date sasaddr enclLogicalId showmfg showpost temp rev phyinfo serdesinfo serdesinfo_tx serdesinfo_rx counters rtr scedebug flashtblinfo sgpioinfo edfbinfo thread memstat coredump showtrace showlogs_detail ssptdebug debuginfo_starfish debuginfo_edfb debuginfo_link debuginfo_connection debuginfo_config rreg ipconfig; do
					if [ -e ./${k}_hba${i}exp${j}.txt ] ; then
						#cho ".................................................||................................................."
						echo "...........................................$k............................................" >> debuginfo_manual_hba${i}exp${j}.txt
						cat ./${k}_hba${i}exp${j}.txt >> debuginfo_manual_hba${i}exp${j}.txt
						echo >> debuginfo_manual_hba${i}exp${j}.txt
	
						if [ -e ./${k}_hba${i}exp${j}.txt ] ; then 
							mv ${k}_hba${i}exp${j}.txt ./$fileName/script_workspace
						fi
					fi
				done
	
				if [ -e ./debuginfo_manual_hba${i}exp${j}.txt ] ; then $grep -e SAS3x -e SAS35x debuginfo_manual_hba${i}exp${j}.txt >> ./misc_output.txt
					if [ "$?" -eq "0" ] ; then 
						if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/12Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/12Gb; fi
						mv debuginfo_manual_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/12Gb
						if [ -e ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt ] ; then
							for k in $($grep "SxP Port 1 SAS Address:" ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt | cut -d: -f2 | cut -dx -f2 | tr -d '\r') ; do
								mv ./$fileName/LSI_Products/Expander/12Gb/debuginfo_manual_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/12Gb/${k}_debuginfo_manual_hba${i}exp${j}.txt
	
								$grep COREDUMP ./$fileName/script_workspace/flashtblinfo_hba${i}exp${j}.txt | tr -s ' ' | cut -d' ' -f3 | $grep -c COREDUMP | $grep 1 >> ./misc_output.txt
								if [ "$?" = "0" ] ; then
									$grep COREDUMP ./$fileName/script_workspace/flashtblinfo_hba${i}exp${j}.txt | tr -s ' ' | cut -d' ' -f2 > ./$fileName/script_workspace/${k}_coredump_region.txt
								fi
							done
						fi
					fi
				fi
	
	
				if [ -e ./debuginfo_manual_hba${i}exp${j}.txt ] ; then $grep SAS2x debuginfo_manual_hba${i}exp${j}.txt >> ./misc_output.txt
					if [ "$?" -eq "0" ] ; then 
						if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/6Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/6Gb; fi
						mv debuginfo_manual_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/6Gb
						if [ -e ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt ] ; then
							for k in $($grep "SxP Port 1 SAS Address:" ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt | cut -d: -f2 | cut -dx -f2 | tr -d '\r') ; do
								mv ./$fileName/LSI_Products/Expander/6Gb/debuginfo_manual_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/6Gb/${k}_debuginfo_manual_hba${i}exp${j}.txt
							done
						fi
					fi
				fi
				if [ -e ./debuginfo_manual_hba${i}exp${j}.txt ] ; then $grep SASx debuginfo_manual_hba${i}exp${j}.txt >> ./misc_output.txt
					if [ "$?" -eq "0" ] ; then 
						if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/3Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/3Gb; fi
						mv debuginfo_manual_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/3Gb
						if [ -e ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt ] ; then
							for k in $($grep "SxP Port 1 SAS Address:" ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt | cut -d: -f2 | cut -dx -f2 | tr -d '\r') ; do
								mv ./$fileName/LSI_Products/Expander/3Gb/debuginfo_manual_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/3Gb/${k}_debuginfo_manual_hba${i}exp${j}.txt
							done
						fi
					fi
				fi
	
	
				if [ -e ./debuginfo_manual_hba${i}exp${j}.txt ] ; then mv debuginfo_manual_hba${i}exp${j}.txt ./$fileName/script_workspace; fi
	
	
				echo $fileName > debuginfo_hba${i}exp${j}.txt	
				#cho ".................................................||................................................."
				echo ".............................................debuginfo.............................................." >> debuginfo_hba${i}exp${j}.txt	
	
	        	        ./$LSUT_NAME -p $i -a 64,$j,debuginfo_hba${i}exp${j}.txt,debuginfo,exit,0, 2>> ./misc_output.txt >> ./misc_output.txt
	
	
	
				if [ -e ./debuginfo_hba${i}exp${j}.txt ] ; then	grep -e SAS3x -e SAS35x debuginfo_hba${i}exp${j}.txt >> ./misc_output.txt
					if [ "$?" -eq "0" ] ; then 
						if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/12Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/12Gb; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/12Gb/Details ] ; then mkdir ./$fileName/LSI_Products/Expander/12Gb/Details; fi
						mv debuginfo_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/12Gb
						if [ -e ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt ] ; then
							for k in $($grep "SxP Port 1 SAS Address:" ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt | cut -d: -f2 | cut -dx -f2 | tr -d '\r') ; do
								mv ./$fileName/LSI_Products/Expander/12Gb/debuginfo_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/12Gb/${k}_debuginfo_hba${i}exp${j}.txt
								for l in date sasaddr enclLogicalId showmfg showpost temp rev phyinfo serdesinfo serdesinfo_tx serdesinfo_rx counters rtr scedebug flashtblinfo sgpioinfo edfbinfo thread memstat coredump showtrace showlogs_detail ssptdebug debuginfo_starfish debuginfo_edfb debuginfo_link debuginfo_connection debuginfo_config rreg ipconfig; do
									if [ -e ./$fileName/script_workspace/${l}_hba${i}exp${j}.txt ] ; then mv ./$fileName/script_workspace/${l}_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/12Gb/Details/${k}_${l}_hba${i}exp${j}.txt ; fi
								done
								if [ -e ./$fileName/LSI_Products/Expander/12Gb/Details/${k}_coredump_hba${i}exp${j}.txt ] ; then 
									$grep "Checking for valid coredump image...SUCCESS." ./$fileName/LSI_Products/Expander/12Gb/Details/${k}_coredump_hba${i}exp${j}.txt >> ./misc_output.txt 2>&1
									if [ "$?" = "0" ] ; then
										mv ./$fileName/LSI_Products/Expander/12Gb/Details/${k}_coredump_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/12Gb/Details/COREDUMP_${k}_hba${i}exp${j}.txt
										if [ -e ./$fileName/LSI_Products/Expander/12Gb/Details/COREDUMP_${k}_hba${i}exp${j}.txt ] ; then cp ./$fileName/LSI_Products/Expander/12Gb/Details/COREDUMP_${k}_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/12Gb/COREDUMP_${k}_hba${i}exp${j}.txt ; fi
									fi
								fi
							done
						fi
					fi
	
		
	
	
				fi
	
	
	
	
				if [ -e ./debuginfo_hba${i}exp${j}.txt ] ; then	grep SAS2x debuginfo_hba${i}exp${j}.txt >> ./misc_output.txt
					if [ "$?" -eq "0" ] ; then 
						if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/6Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/6Gb; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/6Gb/Details ] ; then mkdir ./$fileName/LSI_Products/Expander/6Gb/Details; fi
						mv debuginfo_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/6Gb
						if [ -e ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt ] ; then
							for k in $($grep "SxP Port 1 SAS Address:" ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt | cut -d: -f2 | cut -dx -f2 | tr -d '\r') ; do
								mv ./$fileName/LSI_Products/Expander/6Gb/debuginfo_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/6Gb/${k}_debuginfo_hba${i}exp${j}.txt
								for l in date sasaddr enclLogicalId showmfg showpost temp rev phyinfo serdesinfo serdesinfo_tx serdesinfo_rx counters rtr scedebug flashtblinfo sgpioinfo edfbinfo thread memstat coredump showtrace showlogs_detail ssptdebug debuginfo_starfish debuginfo_edfb debuginfo_link debuginfo_connection debuginfo_config rreg ipconfig; do
									if [ -e ./$fileName/script_workspace/${l}_hba${i}exp${j}.txt ] ; then mv ./$fileName/script_workspace/${l}_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/6Gb/Details/${k}_${l}_hba${i}exp${j}.txt ; fi
								done
							done
						fi
					fi
				fi
	
				if [ -e ./debuginfo_hba${i}exp${j}.txt ] ; then	grep SASx debuginfo_hba${i}exp${j}.txt >> ./misc_output.txt
					if [ "$?" -eq "0" ] ; then 
						if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/3Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/3Gb; fi
						if [ ! -d ./$fileName/LSI_Products/Expander/3Gb/Details ] ; then mkdir ./$fileName/LSI_Products/Expander/3Gb/Details; fi
						mv debuginfo_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/3Gb
						if [ -e ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt ] ; then
							for k in $($grep "SxP Port 1 SAS Address:" ./$fileName/script_workspace/sasaddr_hba${i}exp${j}.txt | cut -d: -f2 | cut -dx -f2 | tr -d '\r') ; do
								mv ./$fileName/LSI_Products/Expander/3Gb/debuginfo_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/3Gb/${k}_debuginfo_hba${i}exp${j}.txt
								for l in date sasaddr enclLogicalId showmfg showpost temp rev phyinfo serdesinfo serdesinfo_tx serdesinfo_rx counters rtr scedebug flashtblinfo sgpioinfo edfbinfo thread memstat coredump showtrace showlogs_detail ssptdebug debuginfo_starfish debuginfo_edfb debuginfo_link debuginfo_connection debuginfo_config rreg ipconfig; do
									if [ -e ./$fileName/script_workspace/${l}_hba${i}exp${j}.txt ] ; then mv ./$fileName/script_workspace/${l}_hba${i}exp${j}.txt ./$fileName/LSI_Products/Expander/3Gb/Details/${k}_${l}_hba${i}exp${j}.txt ; fi
								done
							done
						fi
					fi
				fi
	
				if [ -e ./debuginfo_hba${i}exp${j}.txt ] ; then	mv debuginfo_hba${i}exp${j}.txt ./$fileName/script_workspace; fi
	
	
	
	
		        done
		done



		###########################################################################################################################
		#Starting scl Expander Data Collection
		############################################################################################################################
		echo "Before scli expander section initial test"  >> ./misc_output.txt 2>&1
		echo NO_scl_EXP_or_IOC >> ./misc_output.txt 2>&1
		echo $NO_scl_EXP_or_IOC >> ./misc_output.txt 2>&1
		if [ "$NO_scl_EXP_or_IOC" = "NO" ] ; then
			echo "After scli expander section initial test"  >> ./misc_output.txt 2>&1
			echo NO_scl_EXP_or_IOC >> ./misc_output.txt 2>&1
			echo $NO_scl_EXP_or_IOC >> ./misc_output.txt 2>&1
			echo "./scl --list" >> ./misc_output.txt 2>&1
			./scl --list >> ./misc_output.txt 2>&1
			./scl --list | $grep DeviceId -A 100 | $grep ")" | $grep -e SAS3x -e SAS35x >> ./$fileName/script_workspace/sc_gen3_exps_raw.txt 2>&1 
			if [ ! -s ./$fileName/script_workspace/sc_gen3_exps_raw.txt ] ; then mv ./$fileName/script_workspace/sc_gen3_exps_raw.txt ./$fileName/script_workspace/0Byte_sc_gen3_exps_raw.txt >> ./misc_output.txt 2>&1 ; fi
			if [ -f ./$fileName/script_workspace/sc_gen3_exps_raw.txt ] ; then	
			 	NO_scl_EXP=NO
				echo IN__scl_EXP_Branch_1 >> ./misc_output.txt 2>&1
				if [ ! -d $fileName/LSI_Products ] ; then mkdir $fileName/LSI_Products ; fi
				if [ ! -d $fileName/LSI_Products/Expander ] ; then mkdir $fileName/LSI_Products/Expander ; fi
				if [ ! -d $fileName/LSI_Products/Expander/12Gb ] ; then mkdir $fileName/LSI_Products/Expander/12Gb ; fi
				if [ ! -d $fileName/LSI_Products/Expander/12Gb/Details ] ; then mkdir $fileName/LSI_Products/Expander/12Gb/Details ; fi
				./scl --list | $grep DeviceId -A 100 | $grep -e SAS3x -e SAS35x > $fileName/LSI_Products/Expander/12Gb/Details/sc_expanders.txt
				./scl --list | $grep DeviceId -A 100 | $grep -e SAS3x -e SAS35x | $grep -v DeviceId | cut -d')' -f1 > ./$fileName/script_workspace/sc_gen3_exp_nums.txt
				echo IN__scl_EXP_Branch_2 >> ./misc_output.txt 2>&1
				for i in $( cat ./$fileName/script_workspace/sc_gen3_exp_nums.txt); do
					echo IN__scl_EXP_Branch_3 >> ./misc_output.txt 2>&1
					./scl -i $i show | $grep "SAS Address" | cut -d: -f2 | tr -d ' ' | tr -d '-' > ./$fileName/script_workspace/sc_exp_${i}_sasaddr.txt
					for j in $( cat ./$fileName/script_workspace/sc_exp_${i}_sasaddr.txt); do 
						echo IN__scl_EXP_Branch_4_Expander${i} >> ./misc_output.txt 2>&1
						#cho "......................................::......................................."
						echo "................................scli Expanders................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl --list | $grep DeviceId >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl --list | $grep DeviceId -A 100 | $grep -e SAS3x -e SAS35x >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo "..................................show -all...................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i show -all >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo "...................................phy -da....................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i phy -da >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo "...................................phy -edfb..................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i phy -edfb >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo "...................................phy -err...................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i phy -err >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo "..................................phy -speed..................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i phy -speed >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo ".....................................trace....................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						echo "Commented out, hanging intermittantly" >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#./scl -i $i trace >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo "...............................healthlogs -decode.............................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i healthlogs -decode >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo ".............................cli adcread 1 1 1000.............................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i cli adcread 1 1 1000 >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						#cho "......................................::......................................."
						echo "..............................cli rdcfg 0xfe01 0..............................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i cli rdcfg 0xfe01 0 >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1

						for k in date sasaddr showmfg showpost rev phyinfo serdesinfo counters rtr scedebug flashtblinfo sgpioinfo edfbinfo thread memstat coredump showtrace ssptdebug rreg ipconfig; do
							#cho "......................................::......................................."
							echo ".................................cli $k.................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
							./scl -i $i cli $k >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						done

						for k in starfish edfb link connection config; do
							#cho "......................................::......................................."
							echo "...........................cli debuginfo $k.............................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
							./scl -i $i cli debuginfo $k >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						done

						for k in tx rx; do
							#cho "......................................::......................................."
							echo "..........................cli serdesinfo $k.............................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
							./scl -i $i cli serdesinfo $k >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						done

						#cho "......................................::......................................."
						echo "................................cli debuginfo.................................." >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1
						./scl -i $i cli debuginfo >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}.txt 2>&1

						./scl -i $i ul -fw >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}_up_fw.bin 2>&1
						./scl -i $i ul -mfg >> $fileName/LSI_Products/Expander/12Gb/${j}_scli_exp${i}_up_mfg.bin 2>&1
					done
				done
			fi
		fi
	fi
	
	ls -latr >> ./misc_output.txt
	./sas2ircu list >> ./misc_output.txt 
	if [ "$TWGETSKIPHBA" != "YES" ] ; then
		ls -latr >> ./misc_output.txt
		./sas2ircu list >> ./misc_output.txt 
		###########################################################################################################################
		# Starting sas2ircu & sas3ircu Controller Data Collection
		###########################################################################################################################
		ls -latr >> ./misc_output.txt
		./sas2ircu list >> ./misc_output.txt 
		for i in $(./sas2ircu list 2>> ./misc_output.txt | $grep h: | cut -b 4-5); do # Support for 100 HBAs
			ls -latr >> ./misc_output.txt
			./sas2ircu list >> ./misc_output.txt 
			NO_2ircu_HBAs=NO
			#cho ".................................................||................................................."
			echo $fileName >> ./$fileName/LSI_Products/HBA/sas2ircu_hba$i.txt
			#cho ".................................................||................................................."
			echo "...........................................sas2ircu list............................................" >> ./$fileName/LSI_Products/HBA/sas2ircu_hba$i.txt
			./sas2ircu list >> ./$fileName/LSI_Products/HBA/sas2ircu_hba$i.txt
			echo "........................................sas2ircu $i display........................................." >> ./$fileName/LSI_Products/HBA/sas2ircu_hba$i.txt
			./sas2ircu $i display >> ./$fileName/LSI_Products/HBA/sas2ircu_hba$i.txt
		done
	
		for i in $(./sas3ircu list 2>> ./misc_output.txt | $grep h: | cut -b 4-5); do # Support for 100 HBAs
			NO_3ircu_HBAs=NO
			#cho ".................................................||................................................."
			echo $fileName >> ./$fileName/LSI_Products/HBA/sas3ircu_hba$i.txt
			#cho ".................................................||................................................."
			echo "...........................................sas3ircu list............................................" >> ./$fileName/LSI_Products/HBA/sas3ircu_hba$i.txt
			./sas3ircu list >> ./$fileName/LSI_Products/HBA/sas3ircu_hba$i.txt
			echo "........................................sas3ircu $i display........................................." >> ./$fileName/LSI_Products/HBA/sas3ircu_hba$i.txt
			./sas3ircu $i display >> ./$fileName/LSI_Products/HBA/sas3ircu_hba$i.txt
		done

		###########################################################################################################################
		# Starting sasflash/sas2flash and sas3flash Controller Data Collection
		###########################################################################################################################

		if [ -f sasflash ] ; then
			for i in $( ./sasflash -listall 2>> ./misc_output.txt | grep -e "------------" -A 100 | grep -v -e "------------" | grep -e "Finished" -B 100 | grep -v -e "Finished" | cut -c 1-2 ) ; do # Support for 100 HBAs
				NO_flash_HBAs=NO
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/HBA/sasflash_hba$i.txt
				#cho ".................................................||................................................."
				echo "........................................sasflash -listall.........................................." >> ./$fileName/LSI_Products/HBA/sasflash_hba$i.txt
				./sasflash list >> ./$fileName/LSI_Products/HBA/sasflash_hba$i.txt
				echo "......................................sasflash -c $i -list........................................." >> ./$fileName/LSI_Products/HBA/sasflash_hba$i.txt
				./sasflash $i display >> ./$fileName/LSI_Products/HBA/sasflash_hba$i.txt
			done
		fi
		if [ -f sas2flash ] ; then
			for i in $( ./sas2flash -listall 2>> ./misc_output.txt | grep -e "------------" -A 100 | grep -v -e "------------" | grep -e "Finished" -B 100 | grep -v -e "Finished" | cut -c 1-2 ) ; do # Support for 100 HBAs
				NO_2flash_HBAs=NO
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/HBA/sas2flash_hba$i.txt
				#cho ".................................................||................................................."
				echo "........................................sas2flash -listall.........................................." >> ./$fileName/LSI_Products/HBA/sas2flash_hba$i.txt
				./sas2flash -listall >> ./$fileName/LSI_Products/HBA/sas2flash_hba$i.txt
				echo "......................................sas2flash -c $i -list........................................." >> ./$fileName/LSI_Products/HBA/sas2flash_hba$i.txt
				./sas2flash -c $i -list >> ./$fileName/LSI_Products/HBA/sas2flash_hba$i.txt
			done
		fi
		if [ -f sas3flash ] ; then
			for i in $( ./sas3flash -listall 2>> ./misc_output.txt | grep -e "------------" -A 100 | grep -v -e "------------" | grep -e "Finished" -B 100 | grep -v -e "Finished" | cut -c 1-2 ) ; do # Support for 100 HBAs
				NO_3flash_HBAs=NO
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/HBA/sas3flash_hba$i.txt
				#cho ".................................................||................................................."
				echo "........................................sas3flash -listall.........................................." >> ./$fileName/LSI_Products/HBA/sas3flash_hba$i.txt
				./sas3flash -listall >> ./$fileName/LSI_Products/HBA/sas3flash_hba$i.txt
				echo "......................................sas3flash -c $i -list........................................." >> ./$fileName/LSI_Products/HBA/sas3flash_hba$i.txt
				./sas3flash -c $i -list >> ./$fileName/LSI_Products/HBA/sas3flash_hba$i.txt
			done
		fi
		###########################################################################################################################
		# Starting flashoem SAS2 and SAS3 Controller Data Collection on Internal Only
		###########################################################################################################################

		if [ -f flashoem ] ; then
			for i in $( ./flashoem -listall 2>> ./misc_output.txt | grep -e "------------" -A 100 | grep -v -e "------------" | grep -e "Finished" -B 100 | grep -v -e "Finished" | cut -c 1-2 ) ; do # Support for 100 HBAs
				NO_flashoem_GEN2_HBAs=NO
				echo "NO_flashoem_GEN2_HBAs=NO" >> ./misc_output.txt 2>&1
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/HBA/flashoem-SAS2_hba$i.txt
				#cho ".................................................||................................................."
				echo "........................................flashoem -listall.........................................." >> ./$fileName/LSI_Products/HBA/flashoem-SAS2_hba$i.txt
				./flashoem -listall >> ./$fileName/LSI_Products/HBA/flashoem-SAS2_hba$i.txt
				echo "......................................flashoem -c $i -list........................................." >> ./$fileName/LSI_Products/HBA/flashoem-SAS2_hba$i.txt
				./flashoem -c 0 $i -list >> ./$fileName/LSI_Products/HBA/flashoem-SAS2_hba$i.txt
			done
		fi
		if [ -f flashoem ] ; then
			for i in $( ./flashoem -ctype sas3 -listall 2>> ./misc_output.txt | grep -e "------------" -A 100 | grep -v -e "------------" | grep -e "Finished" -B 100 | grep -v -e "Finished" | cut -c 1-2 ) ; do # Support for 100 HBAs
				NO_flashoem_GEN3_HBAs=NO
				NO_flashoem_GEN2_or_3_HBAs=NO
				echo "NO_flashoem_GEN3_HBAs=NO" >> ./misc_output.txt 2>&1
				echo "NO_flashoem_GEN2_or_3_HBAs=NO" >> ./misc_output.txt 2>&1
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/HBA/flashoem-SAS3_hba$i.txt
				#cho ".................................................||................................................."
				echo ".....................................flashoem -ctype sas3 -listall..................................." >> ./$fileName/LSI_Products/HBA/flashoem-SAS3_hba$i.txt
				./flashoem -ctype sas3 -listall >> ./$fileName/LSI_Products/HBA/flashoem-SAS3_hba$i.txt
				echo "......................................flashoem -ctype sas3 -c $i -list..............................." >> ./$fileName/LSI_Products/HBA/flashoem-SAS3_hba$i.txt
				./flashoem -ctype sas3 -c $i -list >> ./$fileName/LSI_Products/HBA/flashoem-SAS3_hba$i.txt
			done
		fi
		
		if [ "$NO_flashoem_GEN2_HBAs" = "NO" ] ; then
			if [ "$NO_flashoem_GEN3_HBAs" = "NO" ] ; then
				NO_flashoem_GEN2_or_3_HBAs=YES
				echo "NO_flashoem_GEN2_or_3_HBAs=YES" >> ./misc_output.txt 2>&1
			fi
		fi
	fi
fi



ls -latr >> ./misc_output.txt

if [ "$TWGETSKIPMEGARAID" != "YES" ] ; then
	if [ "$USEMEGACLISYNTAX" = "YES" ] ; then

		###########################################################################################################################
		# Starting MegaCli MegaRAID Controller Data Collection
		###########################################################################################################################
		if [ "$OS_LSI" != "macos" ] ; then
	echo $OS_LSI
	echo $OS_LSI
	
			#MegaRAID Adapter #'s
			#Changed to storcli syntax 
			$MCLI_LOCATION$MCLI_NAME show > ./$fileName/script_workspace/storcli_show.txt
			$MCLI_LOCATION$MCLI_NAME show ctrlcount | $grep "Controller Count" | cut -d" " -f 4 > ./$fileName/script_workspace/num_mraid_adapters.txt
			if [ -n `cat ./$fileName/script_workspace/num_mraid_adapters.txt` ] ; then
				for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do
					if [ "$i" -lt "`cat ./$fileName/script_workspace/num_mraid_adapters.txt`" ] ; then echo $i >> ./$fileName/script_workspace/adapter_numbers.txt ; fi
				done
			fi
		
			# Make sure at least 1 MegaRAID Adapter is identified
			if [ -f ./$fileName/script_workspace/adapter_numbers.txt ] ; then

				if [ ! -d ./$fileName/LSI_Products ] ; then mkdir ./$fileName/LSI_Products ; fi
				if [ ! -d ./$fileName/LSI_Products/MegaRAID ] ; then mkdir ./$fileName/LSI_Products/MegaRAID ; fi
				if [ ! -d ./$fileName/LSI_Products/MegaRAID/MegaCli ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/MegaCli ; fi

				echo "Start of the Optional MegaRAID Adapter Data Collection with MegaCli syntax..."
		
				for i in `cat ./$fileName/script_workspace/adapter_numbers.txt` ; do #Support for all adapter IDs 
	
					# MegaRAID Logical Disk #'s
					#Changed to storcli syntax to avoid using tr
					$MCLI_LOCATION$MCLI_NAME /c$i/vall show j | $grep "DG/VD" | wc -l > ./$fileName/script_workspace/num_lds_A$i.txt
					if [ -n `cat ./$fileName/script_workspace/num_lds_A$i.txt` ] ; then
						for j in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 160 161 162 163 164 165 166 167 168 169 170 171 172 173 174 175 176 177 178 179 180 181 182 183 184 185 186 187 188 189 190 191 192 193 194 195 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 223 224 225 226 227 228 229 230 231 232 233 234 235 236 237 238 239 240 241 242 243 244 245 246 247 248 249 250 251 252 253 254 255; do #Supports up to 256 LDs
							if [ "$j" -lt "`cat ./$fileName/script_workspace/num_lds_A$i.txt`" ] ; then
						 		echo $j >> ./$fileName/script_workspace/ld_numbers_A$i.txt
								else
						  		break
							fi
						done
					fi
	
	
		
					if [ "$LimitMegaCliCMDs" != "YES" ] ; then 
					#MegaRAID Enclosure #'s
						$MCLI_LOCATION$MCLI_NAME encinfo a$i | $grep "Device ID" | awk  '{ print $4 }' >> ./$fileName/script_workspace/enclosure_numbers_A$i.txt
					fi
		
					#MegaRAID phy #'s
					$MCLI_LOCATION$MCLI_NAME phyerrorcounters a$i | $grep "Phy No:" | awk '{ print $3 }' >> ./$fileName/script_workspace/phy_numbers_A$i.txt
		
					#MegaRAID PCI data, used for grepping.
					$MCLI_LOCATION$MCLI_NAME adpgetpciinfo a$i nolog 2>> ./misc_output.txt >> ./$fileName/script_workspace/pci_info_A$i.txt
		
					#MegaRAID PDList data, used for grepping.
					echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME pdlist a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt 2>&1
		
					#MegaRAID Disk Device ID #'s
					$grep -e "Device Id:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt | cut -d" " -f3 >> ./$fileName/script_workspace/disk_dev_id_numbers_A$i.txt
		
					#MegaRAID adpallinfo data, used for grepping.
					echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME adpallinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt 2>&1
		
					#MegaRAID adpalilog data, used for grepping.
					if [ "$LimitMegaCliCMDs" != "YES" ] ; then
						echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpalilog a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt 2>&1
					fi
		
		

					
					#cho ".................................................||................................................."
					echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					echo "......................................./$MCLI_NAME adpcount.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME adpcount nolog | $grep Count: >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "............................................Adapter a$i.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt ] ; then
						$grep -e "Product Name    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Memory Size     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Host Interface  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Serial No       :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "SAS Address     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "FW Package Build:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "FW Version         :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Mfg. Date       :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "BBU             :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Battery FRU     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Serial Debugger :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "On board Expander:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "On board Expander FW version :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Driver Name:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grepA -m 1 -e "Driver Version:" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAliLog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "..............................................PCI Info.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Bus Number      :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Device Number   :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Function Number :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						echo "..........................................MegaRAID PCI Info........................................." >> ./$fileName/Controller_Disk_Association.txt
						$grep -e "PCI information for Controller" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
						$grep -e "Bus Number      :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
						$grep -e "Device Number   :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
						$grep -e "Function Number :" ./$fileName/script_workspace/pci_info_A$i.txt >> ./$fileName/Controller_Disk_Association.txt 2>&1
						echo "...............................................Errors..............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Memory Correctable Errors   :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Memory Uncorrectable Errors :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Any Offline VD Cache Preserved   :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#	$grep -e "ECC Bucket Count                 :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "...........................................Rate Settings............................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					#	$grep -e "Ecc Bucket Size                  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#	$grep -e "Ecc Bucket Leak Rate             :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Predictive Fail Poll Interval    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#	$grep -e "Interrupt Throttle Active Count  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#	$grep -e "Interrupt Throttle Completion    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Rebuild Rate                     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "PR Rate                          :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#	echo "Note: Resynch Rate is BgiRate" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "BGI Rate                         :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Check Consistency Rate           :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Reconstruction Rate              :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Physical Drive Coercion Mode     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo ".............................................Performance............................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Cache Flush Interval             :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Host Request Reordering          :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Load Balance Mode                :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop NCQDsply a$i nolog | $grep "NCQ" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop WBSupport a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop perfmode a$i nolog | $grep "Perf Tuned Mode :" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "................................Enclosures/Backplanes and Connectors................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Auto Detect BackPlane Enabled    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop ExposeEnclDevicesEnbl a$i nolog | $grep "Expose" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetconnectormode connectorall a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "........................................Alarms and Warnings........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Alarm                            :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Battery Warning                  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "........................................Rebuild and Hotspare........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Auto Rebuild                     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Restore HotSpare on Insertion    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop AutoEnhancedImportDsply a$i nolog | $grep "Auto" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop MaintainPdFailHistoryEnbl a$i nolog | $grep "Maintain" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo ".............................................Copy Back.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$MCLI_LOCATION$MCLI_NAME adpgetprop CopyBackDsbl a$i nolog | $grep "Copyback" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop SMARTCpyBkEnbl a$i nolog | $grep "Copyback" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop SSDSMARTCpyBkEnbl a$i nolog | $grep "Copyback" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo ".............................................PR and CC.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Enable SSD Patrol Read                  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop PrCorrectUncfgdAreas a$i nolog | $grep "Unconfigured" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop AbortCCOnError a$i nolog | $grep "Abort" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "..........................................ELF/Advanced SW..........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$MCLI_LOCATION$MCLI_NAME elf getsafeid a$i nolog | $grep "Safe" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME elf rehostinfo a$i nolog | $grep "Needs"  >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME elf ControllerFeatures a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo ".............................................Encryption............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Security Key Assigned            :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Security Key Failed              :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Security Key Not Backedup        :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop UseFDEOnlyEncrypt a$i nolog | $grep "FDE Only Encryption:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "..........................................Power Management.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Max Drives to Spinup at One Time :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Delay Among Spinup Groups        :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						echo "#### Dimmer Switch 1" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$MCLI_LOCATION$MCLI_NAME adpgetprop EnblSpinDownUnConfigDrvs a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						echo "#### Dimmer Switch 2" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$MCLI_LOCATION$MCLI_NAME adpgetprop DsblSpinDownHSP a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						echo "#### Dimmer Switch 3" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$MCLI_LOCATION$MCLI_NAME adpgetprop DefaultLdPSPolicy a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop DisableLdPsInterval a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop DisableLdPsTime a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop SpinDownTime a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop SpinUpEncDrvCnt a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpgetprop SpinUpEncDelay a$i nolog | $grep "Adapter" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo ".............................................BIOS/Boot.............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$MCLI_LOCATION$MCLI_NAME adpbios dsply a$i nolog | $grep "BIOS" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$MCLI_LOCATION$MCLI_NAME adpbootdrive get a$i nolog | $grep "boot" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#	$grep -e "Cluster Mode                     :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						#cho ".................................................||................................................."
						echo "...............................................Drives..............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						$grep -e "Virtual Drives    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Degraded        :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Offline         :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Physical Devices  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Disks           :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Critical Disks  :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						$grep -e "Failed Disks    :" ./$fileName/LSI_Products/MegaRAID/MegaCli/AdpAllInfo_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					
					fi
					
					#cho ".................................................||................................................."
					echo "....................................Adapter/System Time Sync A$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					echo "Adapter Date/Time:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$MCLI_LOCATION$MCLI_NAME adpgettime a$i nolog | $grep -e "Date:" -e "Time:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					echo "System Date/Time:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					date >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					echo "System Date/Time UTC:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					date -u >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					
					#cho ".................................................||................................................."
					echo ".............................../$MCLI_NAME getpreservedcachelist a$i.................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME getpreservedcachelist a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					
					if [ -f ./$fileName/script_workspace/ld_numbers_A$i.txt ] ; then
						for j in `cat ./$fileName/script_workspace/ld_numbers_A$i.txt` ; do #Support for up to 256 LDs
							#cho ".................................................||................................................."
							echo "...................................../$MCLI_NAME ldinfo l$j a$i........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
								date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							fi
							if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
								date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							fi
							$MCLI_LOCATION$MCLI_NAME ldinfo l$j a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
							#cho ".................................................||................................................."
							echo ".........................../$MCLI_NAME ldgetprop consistency l$j a$i..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
								date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							fi
							if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
								date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							fi
							$MCLI_LOCATION$MCLI_NAME ldgetprop consistency l$j a$i nolog | $grep "Virtual" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
							#cho ".................................................||................................................."
							echo "............................./$MCLI_NAME ldgetprop pspolicy l$j a$i...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
								date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							fi
							if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
								date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							fi
							$MCLI_LOCATION$MCLI_NAME ldgetprop pspolicy l$j a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
							#cho ".................................................||................................................."
							echo ".....................................Init/CC/Recon Status l$j a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
							$MCLI_LOCATION$MCLI_NAME ldinit showprog l$j a$i nolog | $grep "Initialization" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
							$MCLI_LOCATION$MCLI_NAME ldbi showprog l$j a$i nolog | $grep "Background" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
							$MCLI_LOCATION$MCLI_NAME ldcc showprog l$j a$i nolog | $grep "Check" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
							$MCLI_LOCATION$MCLI_NAME ldrecon showprog l$j a$i nolog | $grep "Reconstruction" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
						done
					fi
					
					echo "..................................../$MCLI_NAME adppr info a$i........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME adppr info a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
				
					echo "................................../$MCLI_NAME adpccsched info a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
	
					$MCLI_LOCATION$MCLI_NAME adpccsched info a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
				
					echo ".................................../$MCLI_NAME pdgetmissing a$i......................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
	
					$MCLI_LOCATION$MCLI_NAME pdgetmissing a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "...................................Logical Disks & Physical Disks..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
	
					$MCLI_LOCATION$MCLI_NAME ldpdinfo a$i nolog | $grep -e "Virtual Disk:" -e "RAID Level:" -e "Number Of Drives:" -e "PD:" -e "Enclosure Device ID:" -e "Slot Number:" -e "Device Id:" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo ".....................................Physical Disk - Slot Number...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Slot Number:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "......................................Physical Disk - Device Id....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Device Id:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo ".....................................Physical Disk - Inquiry Data..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Inquiry Data:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo ".....................................Physical Disk - SAS Address...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "SAS Address" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "....................................Physical Disk - Firmware state.................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Firmware state:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "....................................Physical Disk - Foreign State..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e  "Foreign State:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "...............................Physical Disk - Predictive Failure Count............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Predictive Failure Count:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo ".....................................Physical Disk - Link Speed....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Link Speed:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo ".......................................Physical Disk - Type........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "PD Type:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "......................................Physical Disk - Common........................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					$grep -e "Slot Number:" -e "Enclosure Device ID:" -e "Device Id:" -e "Inquiry Data:" -e "Firmware state:" -e "Predictive Failure Count:" -e "Link Speed:" -e "PD Type:" ./$fileName/LSI_Products/MegaRAID/MegaCli/PDList_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
				
					
					
					if [ "$LimitMegaCliCMDs" != "YES" ] ; then 
						echo "Collecting Enclosure Information for Adapter A$i with MegaCli syntax..." >> ./misc_output.txt 2>&1
						#cho ".................................................||................................................."
						echo "....................................../$MCLI_NAME encinfo a$i........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
							date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
	
						$MCLI_LOCATION$MCLI_NAME encinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					fi
					
					echo "Collecting Information for Adapter A$i with MegaCli syntax..." >> ./misc_output.txt 2>&1
					
					#cho ".................................................||................................................."
	
		
	
					#cho ".................................................||................................................."
					echo "................................../$MCLI_NAME cfgforeign scan a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME cfgforeign scan a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "................................./$MCLI_NAME cfgforeign dsply a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME cfgforeign dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "................................/$MCLI_NAME cfgforeign preview a$i...................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME cfgforeign preview a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					
					echo "................................./$MCLI_NAME cfgfreespaceinfo a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME cfgfreespaceinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "............................/$MCLI_NAME cfgsave -f cfgsave_A$i.cfg a$i................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME cfgsave -f ./$fileName/LSI_Products/MegaRAID/MegaCli/cfgsave_A$i.cfg a$i nolog >> ./misc_output.txt 2>&1
				
					#cho ".................................................||................................................."
					echo "............................/$MCLI_NAME adpeventlog geteventloginfo a$i..............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME adpeventlog geteventloginfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1


					
					#cho ".................................................||................................................."
					echo "...................................../$MCLI_NAME cfgdsply a$i.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME cfgdsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					
					echo "Collecting Logical Disk Information for Adapter A$i with MegaCli syntax..." >> ./misc_output.txt 2>&1
					#cho ".................................................||................................................."
					echo "...................................../$MCLI_NAME ldpdinfo a$i........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME ldpdinfo a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "................................/$MCLI_NAME phyerrorcounters a$i......................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME phyerrorcounters a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					
					for j in `cat ./$fileName/script_workspace/phy_numbers_A$i.txt` ; do
						#cho ".................................................||................................................."
						echo ".................................../$MCLI_NAME phyinfo phy$j a$i......................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						$MCLI_LOCATION$MCLI_NAME phyinfo phy$j a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					done
					#cho ".................................................||................................................."
					echo "............................../$MCLI_NAME directpdmapping dsply a$i..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME directpdmapping dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					echo "Collecting Physical Disk Information for Adapter A$i with MegaCli syntax..." >> ./misc_output.txt 2>&1
					echo "....................................../$MCLI_NAME pdlist a$i.........................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME pdlist a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					#cho ".................................................||................................................."
					
			

					###########################################################################################################################
					# MegaOEM INI dump if installed
					###########################################################################################################################
	
					if [ -f /opt/MegaRAID/MegaOEM/MegaOEM ] ; then 
						#cho ".................................................||................................................."
						echo "................................./opt/MegaRAID/MegaOEM/MegaOEM -v..................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						/opt/MegaRAID/MegaOEM/MegaOEM -v >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						echo "...........................MegaOEM adpsettings write -f MFC_Settings_opt_A$i.ini a$i......................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						fi
						/opt/MegaRAID/MegaOEM/MegaOEM adpsettings write -f ./$fileName/LSI_Products/MegaRAID/MFC_Settings_opt_A$i.ini a$i >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
	
	
					if [ -f ./MegaOEM ] ; then 
						#cho ".................................................||................................................."
						echo ".............................................MegaOEM -v............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						./MegaOEM -v >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
			
						echo "...........................MegaOEM adpsettings write -f MFC_Settings_A$i.ini a$i......................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
						./MegaOEM adpsettings write -f ./$fileName/LSI_Products/MegaRAID/MFC_Settings_A$i.ini a$i >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
					fi
	
					MegaOEM -v >> ./misc_output.txt 2>&1
					if [ "$?" -eq "0" ] ; then 
						#cho ".................................................||................................................."
						echo ".............................................MegaOEM -v............................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						MegaOEM -v >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
			
						echo "...........................MegaOEM adpsettings write -f MFC_Settings_path_A$i.ini a$i......................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
						MegaOEM adpsettings write -f ./$fileName/LSI_Products/MegaRAID/MFC_Settings_path_A$i.ini a$i >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
					fi
	
	
					echo "Collecting Internal Logs for Adapter A$i..." >> ./misc_output.txt 2>&1
					#cho ".................................................||................................................."
					echo "................................../$MCLI_NAME fwtermlog dsply a$i....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S' >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt
					fi
					$MCLI_LOCATION$MCLI_NAME fwtermlog dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Adapter_A$i.txt 2>&1
					echo $fileName >> ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME fwtermlog dsply a$i nolog >> ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt 2>&1
	
	
	
					###########################################################################################################################
					# MegaCli fwtermlog dsply Ax - fwtermlog error screening
					# 
					# Words to look out for... "Fatal firmware error: Line" Fault Panic BAIL_OUT Paused REC CRC Unrecoverable Sense "Battery Put to Sleep" 
					###########################################################################################################################
	
	
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep "Fatal firmware error: Line" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...............$MCLI_NAME fwtermlog dsply a$i - contains Fatal firmware error: Line...................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Fatal_FW_Error_FWTermLog_A$i.txt
							echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Fatal_FW_Error_FWTermLog_A$i.txt
							$grep "Fatal firmware error: Line" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Fatal_FW_Error_FWTermLog_A$i.txt
						fi
					fi
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep " Fault " ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Fault............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Fault_FWTermLog_A$i.txt
							echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Fault_FWTermLog_A$i.txt
							$grep " Fault " ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Fault_FWTermLog_A$i.txt
						fi
					fi
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep "Panic" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Panic............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Panic_FWTermLog_A$i.txt
							echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Panic_FWTermLog_A$i.txt
							$grep "Panic" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Panic_FWTermLog_A$i.txt
						fi
					fi
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep "BAIL_OUT" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains BAIL_OUT.........................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/BAIL_OUT_FWTermLog_A$i.txt
							echo "........This indicates that a SERIOUS FW Issue has occurred, contact Tech. Support or your FAE......." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/BAIL_OUT_FWTermLog_A$i.txt
							$grep "BAIL_OUT" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/BAIL_OUT_FWTermLog_A$i.txt
						fi
					fi
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep "Paused" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Paused............................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Paused_FWTermLog_A$i.txt
							echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Paused_FWTermLog_A$i.txt
							$grep "Paused" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Paused_FWTermLog_A$i.txt
						fi
					fi
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep -e "MPI2_EVENT_SAS_QUIESCE_RC_STARTED" -e "MPI2_EVENT_SAS_QUIESCE_RC_COMPLETED" -e "Test event: An unexpected data IO error occurred on PD" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "..........................$MCLI_NAME fwtermlog dsply a$i - contains Test_Event............................" >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
							echo "....................................The controller should be RMAed.................................." >> ./$fileName/LSI_Products/MegaRAID/Adapter_A$i.txt
							echo "..........................$MCLI_NAME fwtermlog dsply a$i - contains Test_Event............................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Test_Event_FWTermLog_A$i.txt
							echo "....................................The controller should be RMAed.................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Test_Event_FWTermLog_A$i.txt
							$grep -e "MPI2_EVENT_SAS_QUIESCE_RC_STARTED" -e "MPI2_EVENT_SAS_QUIESCE_RC_COMPLETED" -e "Test event: An unexpected data IO error occurred on PD" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Test_Event_FWTermLog_A$i.txt
						fi
					fi
			
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep "REC" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains REC..............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/REC_FWTermLog_A$i.txt
							echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/REC_FWTermLog_A$i.txt
							$grep "REC" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/REC_FWTermLog_A$i.txt
						fi
					fi
			
					
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep "Unrecoverable" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...................$MCLI_NAME fwtermlog dsply a$i - contains Unrecoverable............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Unrecoverable_FWTermLog_A$i.txt
							echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Unrecoverable_FWTermLog_A$i.txt
							$grep "Unrecoverable" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Unrecoverable_FWTermLog_A$i.txt
						fi
					fi
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep "CRC" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains CRC..............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/CRC_FWTermLog_A$i.txt
							echo "....................................This should be investigated....................................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/CRC_FWTermLog_A$i.txt
							$grep "CRC" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/CRC_FWTermLog_A$i.txt
						fi
					fi
					
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep -i "Sense" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "...........................$MCLI_NAME fwtermlog dsply a$i - contains Sense............................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Sense_FWTermLog_A$i.txt
							echo "...........................................Informational............................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Sense_FWTermLog_A$i.txt
							$grep -i "Sense" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/Sense_FWTermLog_A$i.txt
						fi
					fi
			
					if [ -f ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt ] ; then 
					$grep -i "Battery Put to Sleep" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./misc_output.txt
						if [ "$?" -eq "0" ] ; then
							#cho ".................................................||................................................."
							echo "..................$MCLI_NAME fwtermlog dsply a$i - contains Battery Put to Sleep......................." >> ./$fileName/LSI_Products/MegaRAID/MegaCli/BatterySleep_FWTermLog_A$i.txt
							echo "...........................................Informational............................................" >> ./$fileName/LSI_Products/MegaRAID/MegaCli/BatterySleep_FWTermLog_A$i.txt
							$grep -i "Battery Put to Sleep" ./$fileName/LSI_Products/MegaRAID/MegaCli/fwtermlog_A$i.txt >> ./$fileName/LSI_Products/MegaRAID/MegaCli/BatterySleep_FWTermLog_A$i.txt
						fi
					fi
	
				# Adapter number
				done
			fi
		fi
	fi			


	echo "File Size Check - 3B" >> ./misc_output.txt 2>&1
	ls -latr >> ./misc_output.txt 2>&1
	
	###########################################################################################################################
	# Starting storcli MegaRAID Controller Data Collection
	###########################################################################################################################
				
	if [ "$OS_LSI" != "macos" ] ; then
 
		#MegaRAID Adapter #'s
		$MCLI_LOCATION$MCLI_NAME show > ./$fileName/script_workspace/storcli_show.txt
		$MCLI_LOCATION$MCLI_NAME show ctrlcount | $grep "Controller Count" | cut -d" " -f 4 > ./$fileName/script_workspace/num_mraid_adapters.txt
		if [ -n `cat ./$fileName/script_workspace/num_mraid_adapters.txt` ] ; then
			for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 ; do
				if [ "$i" -lt "`cat ./$fileName/script_workspace/num_mraid_adapters.txt`" ] ; then echo $i >> ./$fileName/script_workspace/adapter_numbers.txt ; fi
			done
		fi
	
		# Make sure at least 1 MegaRAID Adapter is identified
		if [ -f ./$fileName/script_workspace/adapter_numbers.txt ] ; then
						
			
			echo "Starting MegaRAID Controller Data Collection with storcli..."
		
		
			echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			
		
		
		
			#cho ".................................................||................................................."
			echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt
			echo ".............................../$MCLI_NAME /call/eall/sall show all...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt
			$MCLI_LOCATION$MCLI_NAME /call/eall/sall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt
		
			if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt ] ; then 
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...............................................Drives..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$MCLI_LOCATION$MCLI_NAME /call/eall/sall show | $grep -e SATA -e SAS >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Shield Counter.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Shield Counter =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Media Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Media Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Other Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Other Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Drive Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Drive Temperature =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "......................................Predictive Failure Count......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Predictive Failure Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...................................S.M.A.R.T alert flagged by drive................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "S.M.A.R.T alert flagged by drive =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".................................................SN................................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "SN =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".................................................WWN................................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "WWN =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Firmware Revision.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Firmware Revision =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".............................................Raw size..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Raw size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Coerced size............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt | $grep -v "Non" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "..........................................Non Coerced size.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Non Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Device Speed............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Device Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".............................................Link Speed............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Link Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				#Per VD not PD
				#echo "..........................................Drive write cache............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#$grep "Drive write cache =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Logical Sector Size........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Logical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Physical Sector Size......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Physical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...........................................Drive position..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Drive position =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Enclosure position........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Enclosure position =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "........................................Connected Port Number......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Connected Port Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...........................................Sequence Number.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt | $grep -v "Predictive" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Commissioned Spare........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Commissioned Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...........................................Emergency Spare.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Emergency Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".............................Last Predictive Failure Event Sequence Number.........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Last Predictive Failure Event Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".................................Successful diagnostics completion on..............................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Successful diagnostics completion on =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................SED Capable............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "SED Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................SED Enabled..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "SED Enabled =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "..............................................Secured..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Secured =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "...............................................Locked..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Locked =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo ".........................................Needs EKM Attention..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Needs EKM Attention =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................PI Eligible..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "PI Eligible =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "..........................................Wide Port Capable..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Wide Port Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "................................Port # - Status - Linkspeed - SAS Address..........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$grep "Gb/s   0x" ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				#cho ".................................................||................................................."
				echo "............................................Inquiry Data............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				$MCLI_LOCATION$MCLI_NAME /call/eall/sall show all j | $grep "Inquiry Data" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_Eall_Sall_show_all-Compare-All-Parms.txt
				
			fi	
		
		
			
			for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
		
		
				#Work around for storcli bug
		
				$MCLI_LOCATION$MCLI_NAME /c$i show 2>> ./misc_output.txt | $grep "iBBU" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					echo "iBBU is on Controller" > ./$fileName/script_workspace/BBU_PRESENT_C$i.txt
				fi
				$MCLI_LOCATION$MCLI_NAME /c$i show 2>> ./misc_output.txt | $grep "Cachevault_Info" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					echo "SuperCaP is on Controller" > ./$fileName/script_workspace/SuperCaP_PRESENT_C$i.txt
				fi
				
			
				echo "Collecting Information for Controller C$i with storcli..." >> ./misc_output.txt 2>&1	
				
				# Add support for snapdump for MR.
				if [ ! -d ./$fileName/LSI_Products/MegaRAID/snapdump ] ; then
					mkdir ./$fileName/LSI_Products/MegaRAID/snapdump
				fi
				$MCLI_LOCATION$MCLI_NAME /c$i show snapdump >> ./$fileName/LSI_Products/MegaRAID/snapdump/snap.txt 2>&1
				$MCLI_LOCATION$MCLI_NAME /c$i get snapdump id=all >> ./$fileName/LSI_Products/MegaRAID/snapdump/snap.txt 2>&1
			 	
					mv snapdump* ./$fileName/LSI_Products/MegaRAID/snapdump >>./$fileName/LSI_Products/MegaRAID/snapdump/snap.txt  2>&1
								
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt
				echo "..................................../$MCLI_NAME /c$i show all........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show all 2>> ./misc_output.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt

				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_alilog_C$i.txt
				echo "..................................../$MCLI_NAME /c$i show alilog........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_alilog_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show alilog 2>> ./misc_output.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_alilog_C$i.txt

			
				echo "Collecting Enclosure Information for Controller C$i with storcli..." >> ./misc_output.txt 2>&1
			
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt
				echo "................................../$MCLI_NAME /c$i/eall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/eall show status......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_show_all-status_C$i.txt
		
		
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt
				echo ".............................../$MCLI_NAME /c$i/eall/sall show all...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show all >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt
		
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_phyerrorcounters_C$i.txt
				echo "........................../$MCLI_NAME /c$i/eall/sall show phyerrorcounters............................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_phyerrorcounters_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show phyerrorcounters >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_phyerrorcounters_C$i.txt
			
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_initialization_C$i.txt
				echo "............................/$MCLI_NAME /c$i/eall/sall show initialization............................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_initialization_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show initialization >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_initialization_C$i.txt
		
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_smart_C$i.txt
				echo ".............................../$MCLI_NAME /c$i/eall/sall show smart.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_smart_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show smart >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_smart_C$i.txt
		
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_erase_C$i.txt
				echo ".............................../$MCLI_NAME /c$i/eall/sall show erase.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_erase_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show erase >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_erase_C$i.txt
		
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_copyback_C$i.txt
				echo "............................./$MCLI_NAME /c$i/eall/sall show copyback................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_copyback_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show copyback >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_copyback_C$i.txt
		
		
		
		
				# Not really "/call show all" - need to get rid of duplicate "Controller =" entries.
			
				$MCLI_LOCATION$MCLI_NAME /c$i show all 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt		
			
			
			
				#cho ".................................................||................................................."
				echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				echo "......................................./$MCLI_NAME show all.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt ] ; then 
					#cho ".................................................||................................................."
					echo "................................................Time................................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Current Controller Date/Time" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Current System Date/time" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi	
			
				echo "Collecting Information for Controller C$i with storcli..." >> ./misc_output.txt 2>&1
				echo "Collecting Logical Disk Information for Controller C$i with storcli..." >> ./misc_output.txt 2>&1
			
				#cho ".................................................||................................................."
				echo "......................................./$MCLI_NAME /c$i show.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				$MCLI_LOCATION$MCLI_NAME /c$i show personality | $grep -i "Adapter does not support personality" >> ./misc_output.txt
				if [ "$?" != "0" ] ; then 
					#cho ".................................................||................................................."
					echo "................................/$MCLI_NAME /c$i show personality....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i show personality 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
		
				$MCLI_LOCATION$MCLI_NAME /c$i show sesmonitoring | $grep -i "Adapter does not support sesMonitoring" >> ./misc_output.txt
				if [ "$?" != "0" ] ; then 
					#cho ".................................................||................................................."
					echo "................................/$MCLI_NAME /c$i show sesmonitoring....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i show sesmonitoring 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
		
				#cho ".................................................||................................................."
				echo "............................./$MCLI_NAME /c$i show failpdonsmarterror................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show failpdonsmarterror 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#$MCLI_LOCATION$MCLI_NAME /c$i show fshinting | $grep -i "Show FSHinting failed" >> ./misc_output.txt
				#if [ "$?" != "0" ] ; then 
					##cho ".................................................||................................................."
					#echo "................................../$MCLI_NAME /c$i show fshinting....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#$MCLI_LOCATION$MCLI_NAME /c$i show fshinting 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				#fi
		
		
				#cho ".................................................||................................................."
				echo ".....................................Persistent Nvdata version......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show termlog 2>> ./misc_output.txt | $grep "Persistent Nvdata version =" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "..........................................PCI-E Link Speed.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show termlog 2>> ./misc_output.txt | $grep "PCIE Link Status/Ctrl" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
		
				#cho ".................................................||................................................."
				echo "..................................../$MCLI_NAME /c$i show bios........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show bios 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "...........................................LDBBM Settings..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show all | $grep -e "Supported VD Operations :" -e "Enable LDBBM =" -e "Defaults :" -e "EnableLDBBM =" 2>> ./misc_output.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/vall show bbmt....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show bbmt |2>> ./misc_output.txt  sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
		
				#$MCLI_LOCATION$MCLI_NAME /c$i/vall show trim | $grep -i "command invalid" >> ./misc_output.txt
				#if [ "$?" != "0" ] ; then 
					##cho ".................................................||................................................."
					#echo "................................../$MCLI_NAME /c$i/vall show trim....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#$MCLI_LOCATION$MCLI_NAME /c$i/vall show trim 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				#fi
		
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/vall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show all |2>> ./misc_output.txt  sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
		
		
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show autobgi 2>> ./misc_output.txt | $grep "No VDs have been configured" >> ./misc_output.txt 2>&1
				if [ "$?" -ne "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................VD Auto BGI Status.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall show autobgi 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
		
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show rebuild 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................Drive Rebuild Status........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show rebuild 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
					 
				$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show copyback 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................Drive CopyBack Status......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show copyback 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show initialization 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".....................................Drive Initialization Status...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show initialization 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show erase 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".........................................Drive Erase Status........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall/sall show erase 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
		
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show init 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".......................................VD Initialization Status....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall show init 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show bgi 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo ".................................VD Background Initialization Status................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall show bgi 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show cc 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "....................................VD Consistency Check Status....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall show cc 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show migrate 2>> ./misc_output.txt | $grep "In progress" >> ./misc_output.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................VD Migration Status........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall show migrate 2>> ./misc_output.txt | sed '1,/Description/d' | $grep -v "Not in progress" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
		
		
				$MCLI_LOCATION$MCLI_NAME /c$i/vall show expansion 2>> ./misc_output.txt | $grep "Controller has no VD" >> ./misc_output.txt 2>&1
				if [ "$?" -ne "0" ] ; then
					#cho ".................................................||................................................."
					echo "........................................VD Expansion Status........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/vall show expansion 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi
		
		
		
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i show freespace..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show freespace 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME /c$i show cc......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show cc 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME /c$i show pr......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show pr 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show copyback....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show copyback 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "...................................../$MCLI_NAME /c$i show eghs....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show enableesmarter 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................/$MCLI_NAME /c$i show perfmode......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show perfmode 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "............................./$MCLI_NAME /c$i show perfmodevalues....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show perfmodevalues 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "..................................../$MCLI_NAME /c$i show ncq........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show ncq 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo ".............................../$MCLI_NAME /c$i show largeiosupport..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show largeiosupport 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo ".............................../$MCLI_NAME /c$i show largeqd..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show largeqd 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo ".................................../$MCLI_NAME /c$i show ds........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show ds 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo ".................................../$MCLI_NAME /c$i show aso........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show aso 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show bootdrive...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show bootdrive 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "............................./$MCLI_NAME /c$i show bootwithpinnedcache................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show bootwithpinnedcache 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
		
				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show cachebypass.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show cachebypass 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
		
				$MCLI_LOCATION$MCLI_NAME /c$i show preservedcache 2>> ./misc_output.txt | $grep "No Virtual" >> ./misc_output.txt 2>&1
				if [ "$?" -ne "0" ] ; then
					#cho ".................................................||................................................."
					echo ".............................../$MCLI_NAME /c$i show preservedcache................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i show preservedcache 2>> ./misc_output.txt | sed '1,/===/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
		
		
		
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/pall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/pall show all 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo ".........................../$MCLI_NAME /c$i/eall show phyerrorcounters................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall show phyerrorcounters 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/eall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall show all 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i/eall show status...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/eall show status 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
			
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt ] ; then 
					#cho ".................................................||................................................."
					echo "............................................Temperatures............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Temperature Sensor for" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "ROC temperature" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				fi	
		
				#$MCLI_LOCATION$MCLI_NAME /c$i show health | $grep Unsupported >> ./misc_output.txt
				#if [ "$?" != "0" ] ; then 
					##cho ".................................................||................................................."
					#echo ".................................../$MCLI_NAME /c$i show health......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#$MCLI_LOCATION$MCLI_NAME /c$i show health 2>> ./misc_output.txt | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				#fi
				
				if [ -f ./$fileName/script_workspace/BBU_PRESENT_C$i.txt ] ; then
					#cho ".................................................||................................................."
					echo "..........................................iBBU Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/bbu show all 2>> ./misc_output.txt | $grepA -m 1 Temperature >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME /c$i/bbu show all 2>> ./misc_output.txt | $grep "Over Temperature" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
				
				if [ -f ./$fileName/script_workspace/SuperCaP_PRESENT_C$i.txt ] ; then
					#cho ".................................................||................................................."
					echo "..........................................CV Temperature............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/cv show all 2>> ./misc_output.txt | $grepA -m 1 Temperature >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
					$MCLI_LOCATION$MCLI_NAME /c$i/cv show all 2>> ./misc_output.txt | $grep "Over Temperature" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
		
		
		
				## MegaCli syntax - PR to add output to storcli
		
				##cho ".................................................||................................................."
				#echo ".......................................Enclosure Temperature........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				#$MCLI_LOCATION$MCLI_NAME encinfo a$i 2>> ./misc_output.txt | $grep -e "Temp Sensor                  :" -e "Temperature                  :" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
							
		
				echo "Collecting Physical Disk Information for Controller C$i with storcli..." >> ./misc_output.txt 2>&1
			
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt ] ; then 
					#cho ".................................................||................................................."
					echo ".........................................Drive Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Drive Temperature =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................    ................Media Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Media Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo "......................................Predictive Failure Count......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Predictive Failure Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................Device Speed............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Device Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#cho ".................................................||................................................."
					echo "................................Port # - Status - Linkspeed - SAS Address..........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					#echo "...................................Port #/Status/Linkspeed/SAS Address.............................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$grep "Gb/s   0x" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
			
				fi	
		
		
				if [ -f ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt ] ; then 
					echo $fileName >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
		
					echo "...............................................Drives..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /call/eall/sall show | $grep -e SATA -e SAS >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
		
					#cho ".................................................||................................................."
					echo "............................................Shield Counter.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Shield Counter =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Media Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Media Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Other Error Count.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Other Error Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Drive Temperature.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Drive Temperature =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "......................................Predictive Failure Count......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Predictive Failure Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...................................S.M.A.R.T alert flagged by drive................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "S.M.A.R.T alert flagged by drive =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".................................................SN................................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "SN =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".................................................WWN................................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "WWN =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Firmware Revision.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Firmware Revision =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".............................................Raw size..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Raw size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................Coerced size............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt | $grep -v "Non" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..........................................Non Coerced size.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Non Coerced size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................Device Speed............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Device Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".............................................Link Speed............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Link Speed =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..........................................Drive write cache............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Drive write cache =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Logical Sector Size........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Logical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Physical Sector Size......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Physical Sector Size =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...........................................Drive position..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Drive position =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Enclosure position........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Enclosure position =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "........................................Connected Port Number......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Connected Port Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...........................................Sequence Number.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt | $grep -v "Predictive" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Commissioned Spare........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Commissioned Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...........................................Emergency Spare.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Emergency Spare =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".............................Last Predictive Failure Event Sequence Number.........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Last Predictive Failure Event Sequence Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".................................Successful diagnostics completion on..............................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Successful diagnostics completion on =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................SED Capable............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "SED Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................SED Enabled..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "SED Enabled =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..............................................Secured..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Secured =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "...............................................Locked..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Locked =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo ".........................................Needs EKM Attention..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Needs EKM Attention =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "............................................PI Eligible..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "PI Eligible =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "..........................................Wide Port Capable..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Wide Port Capable =" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
					echo "................................Port # - Status - Linkspeed - SAS Address..........................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$grep "Gb/s   0x" ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all_C$i.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					#cho ".................................................||................................................."
		
					echo "............................................Inquiry Data............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show all j | $grep "Inquiry Data" >> ./$fileName/LSI_Products/MegaRAID/storcli/Cx_Eall_Sall_show_all-Compare-All-Parms_C$i.txt
				
		
			
				fi	
			
				if [ -f ./$fileName/script_workspace/BBU_PRESENT_C$i.txt ] ; then			
					#cho ".................................................||................................................."
					echo "................................../$MCLI_NAME /c$i/bbu show all......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/bbu show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
		
				if [ -f ./$fileName/script_workspace/SuperCaP_PRESENT_C$i.txt ] ; then
					#cho ".................................................||................................................."
					echo "................................../$MCLI_NAME /c$i/cv show all........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /c$i/cv show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
				fi
		
				#cho ".................................................||................................................."
				echo "................................../$MCLI_NAME /c$i/fall show all......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/fall show all | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo ".............................../$MCLI_NAME /c$i/fall import preview..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i/fall import preview | sed '1,/Description/d' >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "............................../$MCLI_NAME /c$i show termlog type=config..............................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show termlog type=config >> ./$fileName/LSI_Products/MegaRAID/storcli/fwtermlog_C$i.txt 2>&1
				$MCLI_LOCATION$MCLI_NAME /c$i show termlog type=config >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1
		
				#cho ".................................................||................................................."
				echo "................................./$MCLI_NAME /c$i show termlog........................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt
				$MCLI_LOCATION$MCLI_NAME /c$i show termlog  >> ./$fileName/LSI_Products/MegaRAID/storcli/fwtermlog_C$i.txt 2>&1
				$MCLI_LOCATION$MCLI_NAME /c$i show termlog  >> ./$fileName/LSI_Products/MegaRAID/storcli/Controller_C$i.txt 2>&1		

				###########################################################################################################################
				# MegaRAID Smartctl Data Collection if Smartctl is installed
				# Start Linux Only Section for now
				# Must test on other OS's
				###########################################################################################################################
			
					
				smartctl -h > ./$fileName/script_workspace/smartctl-h.txt 2>&1
				if [ "$?" -eq "0" ] ; then
					# Smartctl added support for MegaRAID in 5.39
				
					# Only have one sd letter associated per 
					# controller to eliminate duplicate
					# entries.
					
					# Used with smartctl, Don't want duplicates with multiple controllers.
						
					for k in $( ls /dev/sd* 2>> ./misc_output.txt ) ; do 
					dev=$(basename $k)
						if [ -e /sys/block/${dev} ] ; then echo ${dev} >> ./$fileName/script_workspace/sd_letters.txt ; fi
					done
				
					$MCLI_LOCATION$MCLI_NAME /c$i/eall/sall show j | $grep DID | cut -d: -f 2 | cut -d, -f 1 >> ./$fileName/script_workspace/disk_dev_id_numbers_C$i.txt
				
					if [ -f ./$fileName/script_workspace/sd_letters.txt ] ; then
						for j in `cat ./$fileName/script_workspace/sd_letters.txt` ; do #Supports up to 26 character device node entries
							for k in `cat ./$fileName/script_workspace/disk_dev_id_numbers_C$i.txt` ; do #Limit?
								smartctl -T permissive -i -d megaraid,$k /dev/$j | egrep "INQUIRY failed|No such device" >> ./misc_output.txt 2>&1
									if [ "$?" -ne "0" ] ; then
										echo $j > ./$fileName/script_workspace/sd_letter_C$i.txt
									fi
							done
						done
					fi	
				
					# Differentiate SATA from SAS				
					if [ -f ./$fileName/script_workspace/sd_letter_C$i.txt ] ; then
						for j in `cat ./$fileName/script_workspace/sd_letter_C$i.txt` ; do #Supports up to 26 character device node entries
							for k in `cat ./$fileName/script_workspace/disk_dev_id_numbers_C$i.txt` ; do #Limit?
								smartctl -T permissive -i -d megaraid,$k /dev/$j | $grep "SATA device detected" >> ./misc_output.txt 2>&1
									if [ "$?" -ne "0" ] ; then
										echo $k >> ./$fileName/script_workspace/sas_disk_dev_id_numbers_C$i.txt
										else	
										echo $k >> ./$fileName/script_workspace/sata_disk_dev_id_numbers_C$i.txt
									fi
							done
						done
					fi		
										
				

					# SAS Disks		
					
					if [ -f ./$fileName/script_workspace/sd_letter_C$i.txt ] ; then
						if [ -f ./$fileName/script_workspace/sas_disk_dev_id_numbers_C$i.txt ] ; then
							echo "Starting MegaRAID Smartctl Data Collection for Controller C$i..."
							if [ ! -d ./$fileName/LSI_Products/MegaRAID/SMARTCTL ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/SMARTCTL ; fi
							#cho ".................................................||................................................."
							echo "...................All SAS disks are listed first and then any SATA disks follow...................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
							echo "...................................................................................................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
							for j in `cat ./$fileName/script_workspace/sd_letter_C$i.txt` ; do #Supports up to 26 character device node entries
								for k in `cat ./$fileName/script_workspace/sas_disk_dev_id_numbers_C$i.txt` ; do #Limit?
									#cho ".................................................||................................................."
									echo ".................................megaraid,$k is the Disk Device ID #................................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
									echo ".......................smartctl -T permissive -a -d megaraid,$k /dev/$j............................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
									smartctl -T permissive -a -d megaraid,$k /dev/$j >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
								done
							done
						fi
					fi
				
					# SATA Disks
				
					if [ -f ./$fileName/script_workspace/sd_letter_C$i.txt ] ; then
						if [ -f ./$fileName/script_workspace/sata_disk_dev_id_numbers_C$i.txt ] ; then
							echo "Starting MegaRAID Smartctl Data Collection for Controller C$i..."
							if [ ! -d ./$fileName/LSI_Products/MegaRAID/SMARTCTL ] ; then 
								mkdir ./$fileName/LSI_Products/MegaRAID/SMARTCTL 
								#cho ".................................................||................................................."
								echo "...........................There are no SAS Disks, only SATA disks follow..........................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
								echo "...................................................................................................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
							fi
							for j in `cat ./$fileName/script_workspace/sd_letter_C$i.txt` ; do #Supports up to 26 character device node entries
								for k in `cat ./$fileName/script_workspace/sata_disk_dev_id_numbers_C$i.txt` ; do #Limit?
									#cho ".................................................||................................................."
									echo ".................................megaraid,$k is the Disk Device ID #................................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
									echo ".......................smartctl -T permissive -a -d sat+megaraid,$k /dev/$j............................." >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
									smartctl -T permissive -a -d sat+megaraid,$k /dev/$j >> ./$fileName/LSI_Products/MegaRAID/SMARTCTL/megaraid_C$i.txt 2>&1
								done
							done
						fi
					fi
				
				# return for smartctl -h
				fi
	
			
			#done for controller #ing i.e. $i
			done

	
			#cho ".................................................||................................................."
			echo "..............................................Basics :.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
							
			#cho ".................................................||................................................."
			echo "............................................Controller #............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "Temperature" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...............................................Model #.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Model =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "Support Config Page Model" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Serial Number #.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Serial Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "....................................Current Controller Date/Time...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Current Controller Date/Time =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "......................................Current System Date/time......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Current System Date/time =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..............................................Mfg Date.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Mfg Date =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Rework Date............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Rework Date =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Revision No............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Revision No =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
		
			#cho ".................................................||................................................."
			echo "..............................................Version :............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
		
			echo ".......................................Firmware Package Build......................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Firmware Package Build =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Bios Version............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bios Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................NVDATA Version..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "NVDATA Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................Boot Block Version........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Boot Block Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................Bootloader Version........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bootloader Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Driver Name............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Driver Name =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Driver Version..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Driver Version =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
		
			#cho ".................................................||................................................."
			echo "................................................Bus :..............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
		
			echo ".............................................Vendor Id.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Vendor Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "SubVendor" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".............................................Device Id.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Device Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt | $grep -v "SubDevice" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................SubVendor Id............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "SubVendor Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................SubDevice Id............................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "SubDevice Id =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Host Interface..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Host Interface =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..........................................Device Interface.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Device Interface =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".............................................Bus Number............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bus Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "............................................Device Number..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Device Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...........................................Function Number.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Function Number =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
		
			#cho ".................................................||................................................."
			echo "......................................Pending Images in Flash :....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
		
			#cho ".................................................||................................................."
			echo ".............................................Image name............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Image name =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
		
			#cho ".................................................||................................................."
			echo "..............................................Status :.............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
		
			#cho ".................................................||................................................."
			echo ".........................................Controller Status.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller Status =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".....................................Memory Correctable Errors......................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Memory Correctable Errors =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "....................................Memory Uncorrectable Errors....................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Memory Uncorrectable Errors =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................ECC Bucket Count..........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "ECC Bucket Count =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...................................Any Offline VD Cache Preserved..................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Any Offline VD Cache Preserved =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".............................................BBU Status............................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "BBU Status =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "....................................Support PD Firmware Download...................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Support PD Firmware Download =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo ".........................................Lock Key Assigned.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Lock Key Assigned =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...................................Failed to get lock key on bootup................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Failed to get lock key on bootup =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "...................................Lock key has not been backed up.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Lock key has not been backed up =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..................................Bios was not detected during boot................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Bios was not detected during boot =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "......................Controller must be rebooted to complete security operation...................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller must be rebooted to complete security operation =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "................................A rollback operation is in progress................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "A rollback operation is in progress =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..................................At least one PFK exists in NVRAM.................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "At least one PFK exists in NVRAM =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "..........................................SSC Policy is WB.........................................." >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "SSC Policy is WB =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			#cho ".................................................||................................................."
			echo "................................Controller has booted into safe mode................................" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
			$grep "Controller has booted into safe mode =" ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all.txt >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt
		
		
			echo "##################################Supported Adapter Operations :####################################" >> ./$fileName/LSI_Products/MegaRAID/storcli/Call_show_all-Compare-All-Parms.txt

			if [ "$TWGETSKIPRECORDCAPTURE" != "NO" ] ; then #disabling event capture by default 

				echo .
				echo "Start of the MegaRAID Event Record Capture..."
				echo "Start of the MegaRAID Event Record Capture..."  >> ./misc_output.txt 2>&1
				if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
					date '+%H:%M:%S.%N'
				fi
				if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
					date '+%H:%M:%S'
				fi
				echo "This will take approx. 1 minute per 78K/0x130B0 Event Records per Controller..."
				echo "Start of the MegaRAID Event Record Capture..."  >> ./misc_output.txt 2>&1
				echo "This will take approx. 1 minute per 78K/0x130B0 Event Records per Controller..." >> ./misc_output.txt 2>&1
				
				for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
				
					echo .
					echo Start on Controller $i...
					$MCLI_LOCATION$MCLI_NAME /C$i show eventloginfo | $grep -e "Newest" -e "Oldest"
					
					if [ ! -d ./$fileName/LSI_Products/MegaRAID/Event_Logs ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/Event_Logs ; fi
					echo $fileName > ./$fileName/LSI_Products/MegaRAID/Event_Logs/evtlog_ID_C$i.txt 2>&1							
					echo "..................storcli /C$i show events type=includedeleted.................." >> ./$fileName/LSI_Products/MegaRAID/Event_Logs/evtlog_ID_C$i.txt
					$MCLI_LOCATION$MCLI_NAME /C$i show events type=includedeleted file=./$fileName/LSI_Products/MegaRAID/Event_Logs/evtlog_ID_C$i.txt >> ./misc_output.txt 2>&1

					echo "End on Controller $i..." >> ./misc_output.txt 2>&1
					if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
						date '+%H:%M:%S.%N'
					fi
					if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
						date '+%H:%M:%S'
					fi
											
				done					
				
				echo "End of the MegaRAID Event Record Capture..." >> ./misc_output.txt 2>&1
			fi

			if [ "$TWGETSKIPMEGARAID" != "YES" ] ; then	
				if [ "$OS_LSI" != "macos" ] ; then
					if [ "$TWGETSKIPRECORDSORT" != "NO" ] ; then # disabling sort by default = change NO to YES to enable it.
		
						###########################################################################################################################
						#MegaRAID Adapter Event log sorting - Deleted MegaCli syntax version
						###########################################################################################################################
		
							
						if [ ! -d ./$fileName/script_workspace/mr_aen_sort ] ; then mkdir ./$fileName/script_workspace/mr_aen_sort ; fi >> ./misc_output.txt 2>&1
						if [ -f ./$fileName/script_workspace/aens_mr.txt ] ; then mv -f  ./$fileName/script_workspace/aens_mr.txt ./$fileName/script_workspace/mr_aen_sort/aens_mr.txt ; fi >> ./misc_output.txt 2>&1
		
						echo .
						echo "Start of the MegaRAID Event Record Sort..."
						echo "Start of the MegaRAID Event Record Sort..." >> ./misc_output.txt 2>&1
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
							date '+%H:%M:%S.%N'
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S'
						fi
						echo This will take approx. 1 minute per 78,000 Event Records per Controller...
						echo Start of the MegaRAID Event Record Sort... >> ./misc_output.txt 2>&1
						echo This will take approx. 1 minute per 78,000 Event Records per Controller... >> ./misc_output.txt 2>&1
		
						for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199	
							echo "Start on Controller $i..."
							echo "Start on Controller $i..." >> ./misc_output.txt 2>&1
							$grep "Code: 0x" ./$fileName/LSI_Products/MegaRAID/Event_Logs/evtlog_ID_C$i.txt > ./$fileName/script_workspace/mr_aen_sort/all_aen_iterations_C$i.txt 2>/dev/null #BFS
#						done

#						for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199	
							while IFS=' ' read j k ; do
								echo $j $k > ./$fileName/script_workspace/mr_aen_sort/"$k"_used_aens_C$i.txt
							done < ./$fileName/script_workspace/mr_aen_sort/all_aen_iterations_C$i.txt
#						done

#						for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199									
							ls ./$fileName/script_workspace/mr_aen_sort/ | $grep 0x | $grep _used_aens_C$i.txt > ./$fileName/script_workspace/mr_aen_sort/all_used_aens_C$i.txt
#						done


#						for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199
			
							while IFS=_ read j k; do
								echo "Number of Events :" > ./$fileName/script_workspace/mr_aen_sort/"$j"_AEN_"C$i".txt
								$grep "Code: ${j}" ./$fileName/LSI_Products/MegaRAID/Event_Logs/evtlog_ID_C$i.txt -c >> ./$fileName/script_workspace/mr_aen_sort/"$j"_AEN_"C$i".txt
								echo .................................................................................................... >> ./$fileName/script_workspace/mr_aen_sort/"$j"_AEN_"C$i".txt
								$grep -B 3 -A 5 "Code: ${j}" ./$fileName/LSI_Products/MegaRAID/Event_Logs/evtlog_ID_C$i.txt >> ./$fileName/script_workspace/mr_aen_sort/"$j"_AEN_"C$i".txt
								$grep "Code: ${j}" ./$fileName/script_workspace/mr_aen_sort/aens_mr.txt >> ./$fileName/script_workspace/mr_aen_sort/aens_mr_used_C$i.txt
							done < ./$fileName/script_workspace/mr_aen_sort/all_used_aens_C$i.txt

#						done

#						for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199							
							
							while IFS=' ' read j k l ; do
								mv -f ./$fileName/script_workspace/mr_aen_sort/"$k"_AEN_"C$i".txt ./$fileName/LSI_Products/MegaRAID/Event_Logs/"$k"_"$l"_"C$i".txt >> ./misc_output.txt 2>&1
							done < ./$fileName/script_workspace/mr_aen_sort/aens_mr_used_C$i.txt
							echo "ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/*_C$i.txt" >> ./misc_output.txt 2>&1											
							ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/*_C$i.txt >> ./misc_output.txt 2>&1
							if [ "$?" -eq "0" ] ; then
								mkdir ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i >> ./misc_output.txt 2>&1
								cp ./$fileName/LSI_Products/MegaRAID/Event_Logs/*_C$i.txt ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i >> ./misc_output.txt 2>&1
							fi			
						done				
														

						
						for i in $(cat ./$fileName/script_workspace/mr_aen_types.txt) ; do	
							echo "ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/*_${i}_*" >> ./misc_output.txt 2>&1
							ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/*_${i}_* >> ./misc_output.txt 2>&1
							if [ "$?" -eq "0" ] ; then
								mkdir ./$fileName/LSI_Products/MegaRAID/Event_Logs/$i >> ./misc_output.txt 2>&1
								echo "mkdir ./$fileName/LSI_Products/MegaRAID/Event_Logs/$i" >> ./misc_output.txt 2>&1
								mv -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/*_${i}_* ./$fileName/LSI_Products/MegaRAID/Event_Logs/$i >> ./misc_output.txt 2>&1
								echo "mv -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/*_${i}_* ./$fileName/LSI_Products/MegaRAID/Event_Logs/$i" >> ./misc_output.txt 2>&1
							fi
						done						
		
							
						
						for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199	
							for j in $(cat ./$fileName/script_workspace/mr_aen_types.txt) ; do
								echo "ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/*_${j}_*" >> ./misc_output.txt 2>&1
								ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/*_${j}_* >> ./misc_output.txt 2>&1
								if [ "$?" -eq "0" ] ; then
									mkdir ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/${j} >> ./misc_output.txt 2>&1
									echo "mkdir ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/${j}" >> ./misc_output.txt 2>&1
									mv -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/*_${j}_* ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/${j} >> ./misc_output.txt 2>&1
									echo "mv -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/*_${j}_* ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/${j}" >> ./misc_output.txt 2>&1
								fi
							done
						done							
		
						
			
						
						for i in $($MCLI_LOCATION$MCLI_NAME show | sed '1,/---/d' | sed '1,/---/d' | sed '/---/q' | sed '/---/d' | cut -b 1-3); do #Support for Controller IDs 0-199	
							echo "ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/*_C${i}.txt" >> ./misc_output.txt 2>&1
							ls ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C${i}/*_C${i}.txt >> ./misc_output.txt 2>&1
							if [ "$?" -eq "0" ] ; then
								if [ -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GE_C$i.txt ] ; then rm -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GE_C$i.txt ; fi >> ./misc_output.txt 2>&1
								if [ -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GE_C$i.txt ] ; then rm -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GE_C$i.txt ; fi >> ./misc_output.txt 2>&1
								if [ -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GSR_C$i.txt ] ; then rm -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GSR_C$i.txt ; fi >> ./misc_output.txt 2>&1
								if [ -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GSS_C$i.txt ] ; then rm -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_GSS_C$i.txt ; fi >> ./misc_output.txt 2>&1
								if [ -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_ID_C$i.txt ] ; then rm -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/evtlog_ID_C$i.txt ; fi >> ./misc_output.txt 2>&1
								if [ -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/Return_getlatest_* ] ; then rm -f ./$fileName/LSI_Products/MegaRAID/Event_Logs/Controller_C$i/Return_getlatest_* ; fi >> ./misc_output.txt 2>&1
							fi
							echo End on Controller $i... >> ./misc_output.txt 2>&1
						done
						
						echo "End of the MegaRAID Event Record Sort..." >> ./misc_output.txt 2>&1
						echo "End of the MegaRAID Event Record Sort..." 
						if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
							date '+%H:%M:%S.%N'
						fi
						if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
							date '+%H:%M:%S'
						fi
					fi
				fi
			fi

					
		# Returns from - Make sure at least 1 MegaRAID Adapter is identified
		fi


		###########################################################################################################################
		# Component version number collection
		###########################################################################################################################
		#Get the MegaCli version that came bundled with the script
		if [ "$mcli_Bundled_work" = "YES" ] ; then
			./$MCLI_NAME -v | $grep -i StorCli | awk '{ print$6 }' > ./$fileName/script_workspace/mcli_Bundled_version.txt
		fi

		# Get the MegaCli version that was pre-existing
		if [ "$tw_cli_Existing_work" = "YES" ] ; then
			$MCLI_NAME -v | $grep -i StorCli | awk '{ print$6 }' > ./$fileName/script_workspace/mcli_Existing_version.txt
		fi

	###########################################################################################################################
	# Done with MegaCli!
	###########################################################################################################################				
			
	
	# Return if MacOS for MegaRAID
	fi
# Return for TWGETSKIPMEGARAID
fi
###########################################################################################################################
# Script Version
###########################################################################################################################
###Update on Code Set Change
echo "$Capture_Script_Version" > ./$fileName/script_workspace/lsigetlunix_version.txt

###########################################################################################################################
# Data to help troubleshoot script issues.
###########################################################################################################################


#cho ".................................................||................................................."
echo "............................whoami - user executing lsigetlunix.sh script..........................." >> ./$fileName/script_workspace/script_diag.txt
whoami >> ./$fileName/script_workspace/script_diag.txt 2>&1
#cho ".................................................||................................................."
echo "..................groups - groups user executing lsigetlunix.sh script belongs to..................." >> ./$fileName/script_workspace/script_diag.txt
groups >> ./$fileName/script_workspace/script_diag.txt 2>&1
#cho ".................................................||................................................."
echo "..........................ls -latr - files in subdir script was executed from......................." >> ./$fileName/script_workspace/script_diag.txt
ls -latr >> ./$fileName/script_workspace/script_diag.txt
#cho ".................................................||................................................."
echo "....................................set - environment for script...................................." >> ./$fileName/script_workspace/script_diag.txt
set >> ./$fileName/script_workspace/script_diag.txt 2>&1
#cho ".................................................||................................................."
echo "....................................env - environment for script...................................." >> ./$fileName/script_workspace/script_diag.txt
env >> ./$fileName/script_workspace/script_diag.txt 2>&1
echo "......................................Command Line and Options......................................" >> ./$fileName/script_workspace/script_diag.txt
echo "$0 $@" > ./$fileName/script_workspace/cmd_line.txt
TWCMDLINE=`cat ./$fileName/script_workspace/cmd_line.txt`

###########################################################################################################################
export TWCMDLINE 
###########################################################################################################################

echo "$0 $@" >> ./$fileName/script_workspace/script_diag.txt

###########################################################################################################################
# System capture comment
###########################################################################################################################

if [ "$TWcomment" != "" ] ; then  
	echo "$TWcomment" > ./$fileName/Comment.txt 
fi


###########################################################################################################################
# Component version number collection
###########################################################################################################################
#Get the tw_cli version that came bundled with the script
if [ "$tw_cli_Bundled_work" = "YES" ] ; then
	./$CLI_NAME help 2>> ./misc_output.txt | $grep version | awk  '{ print $4 }' | sed -e 's/)//' > ./$fileName/script_workspace/tw_cli_Bundled_version.txt
fi

# Get the tw_cli version that was pre-existing
if [ "$tw_cli_Existing_work" = "YES" ] ; then
	$CLI_NAME help 2>> ./misc_output.txt | $grep version | awk  '{ print $4 }' | sed -e 's/)//' > ./$fileName/script_workspace/tw_cli_Existing_version.txt
fi


########################################################################################################################### 
###########################################################################################################################
# Common - Collect system information 
###########################################################################################################################
###########################################################################################################################


echo "Collecting System info..."

if [ -f re_execute_variable_shell.txt ] ; then
	mv  re_execute_variable_shell.txt ./$fileName/script_workspace
fi

uname -a > ./$fileName/uname-a.txt 2>> ./misc_output.txt



echo "Start of var_log section" >> ./misc_output.txt 2>&1
if [ -d /var/log ] ; then
	mkdir ./$fileName/var_log
	#ls /var/log > ./$fileName/script_workspace/var_log.txt
	#for i in $( cat ./$fileName/script_workspace/var_log.txt ); do
		#if [ -f /var/log/$i ] ; then 
			#if [ "$i" != "lastlog" ] ; then cp /var/log/$i ./$fileName/var_log 2>> ./misc_output.txt ; fi
		#fi
	#done
	tar cfz ./$fileName/var_log/varlog.tgz /var/log > /dev/null   2>&1
	
	
	ls ./$fileName/var_log >> ./misc_output.txt 2>&1
	rm -f ./$fileName/var_log/maillog* 2>> ./misc_output.txt
	rm -f ./$fileName/var_log/secure* 2>> ./misc_output.txt
	#Linux
	if [ -f ./$fileName/var_log/messages ] ; then ls -latr ./$fileName/var_log/messages* >> ./$fileName/script_workspace/all_copied_messages.txt 2>> ./misc_output.txt ; fi
	#MacOS
	if [ -f ./$fileName/var_log/system.log ] ; then ls -latr ./$fileName/var_log/system.log* >> ./$fileName/script_workspace/all_copied_messages.txt 2>> ./misc_output.txt ; fi
	#VMWare
	if [ -f /var/log/vmkernel ] ; then ls -latr ./$fileName/var_log/vmkernel* >> ./$fileName/script_workspace/all_copied_messages.txt 2>> ./misc_output.txt ; fi
	if [ -d /var/log/vmware ] ; then
		mkdir ./$fileName/var_log/vmware
		cp /var/log/vmware/* ./$fileName/var_log/vmware 2>> ./misc_output.txt
	fi
fi

dmesg >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	dmesg > ./$fileName/dmesg_${currentTime}.txt 2>> ./misc_output.txt
	if [ -d /var/log ] ; then mv -f ./$fileName/dmesg_${currentTime}.txt ./$fileName/var_log 2>> ./misc_output.txt ; fi
fi

echo "End of var_log section" >> ./misc_output.txt 2>&1







if [ -d /etc ] ; then
	mkdir ./$fileName/etc
	cp /etc/*release* ./$fileName/etc 2>> ./misc_output.txt






#for i in sysconfig/diskdump sysconfig/harddisks sysconfig/hwconf fstab raidtab ; do
	#if [ -f /etc/$i ] ; then cp -p /etc/$i ./$fileName/etc ; fi
#done


for i in $( ls /dev/sd* 2>> ./misc_output.txt ) ; do 
	dev=$(basename $i)
	for j in vendor model timeout;do
		if [ -e /sys/block/${dev}/device/$j ] ;then
			#cho ".................................................||................................................."
			echo "....................................cat /sys/block/${dev}/device/$j..................................." >> ./$fileName/sd_time_out_value.txt 2>&1
			cat /sys/block/${dev}/device/$j >> ./$fileName/sd_time_out_value.txt 2>&1
		fi
	done
done

uptime >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then 
	uptime > ./$fileName/uptime.txt 2>> ./misc_output.txt
fi

lsmod >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	lsmod > ./$fileName/lsmod.txt 2>> ./misc_output.txt
fi

lspci >> ./misc_output.txt 2>> ./misc_output.txt
if [ "$?" -eq "0" ] ; then
	if [ ! -d ./$fileName/lspci ] ; then mkdir ./$fileName/lspci ; fi

	lspci > ./$fileName/lspci/lspci.txt 2>> ./misc_output.txt
	
	lspci -e >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -e > ./$fileName/lspci/lspci-e.txt 2>> ./misc_output.txt
	fi
	
	lspci -p >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -p > ./$fileName/lspci/lspci-p.txt 2>> ./misc_output.txt
	fi
	
	lspci -t >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -t > ./$fileName/lspci/lspci-t.txt 2>> ./misc_output.txt
	fi
	
	lspci -x >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -x > ./$fileName/lspci/lspci-x.txt 2>> ./misc_output.txt
	fi
	
	lspci -xxx >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -xxx > ./$fileName/lspci/lspci-xxx.txt 2>> ./misc_output.txt
	fi
	
	lspci -xxxx >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -xxxx > ./$fileName/lspci/lspci-xxxx.txt 2>> ./misc_output.txt
	fi
	
	lspci -v >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -v > ./$fileName/lspci/lspci-v.txt 2>> ./misc_output.txt
	fi
	
	lspci -vv >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -vv > ./$fileName/lspci/lspci-vv.txt 2>> ./misc_output.txt
	fi
	
	lspci -vvv >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -vvv > ./$fileName/lspci/lspci-vvv.txt 2>> ./misc_output.txt
	fi
	
	lspci -tvvv >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -tvvv > ./$fileName/lspci/lspci-tvvv.txt 2>> ./misc_output.txt
	fi
	
	lspci -vvvxxxx >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		lspci -vvvxxxx > ./$fileName/lspci/lspci-vvvxxxx.txt 2>> ./misc_output.txt
	fi
fi


scanpci -v >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	scanpci -v > ./$fileName/scanpci-v.txt 2>> ./misc_output.txt
fi

rpm -q -a -i >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	rpm -q -a -i > ./$fileName/rpm-q-a-i.txt 2>> ./misc_output.txt
fi



who >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	who > ./$fileName/who.txt  2>> ./misc_output.txt
fi

who -b >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	who -b > ./$fileName/who-b.txt  2>> ./misc_output.txt
fi

who -m >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	who -m > ./$fileName/who-m.txt  2>> ./misc_output.txt
fi

top -b -n 1 >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
top -b -n 1 > ./$fileName/top-b-n1.txt 2>> ./misc_output.txt
fi

top -l1 >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	top -l1 > ./$fileName/top-l1.txt 2>> ./misc_output.txt
fi

if [ -d /boot ] ; then ls -latrR /boot > ./$fileName/boot-latrR.txt 2>&1 ./$fileName/script_workspace/lsiget_errorlog.txt; fi

#if [ -d /sys ] ; then ls -latrR /sys > ./$fileName/sys-latrR.txt 2>&1 ./$fileName/script_workspace/lsiget_errorlog.txt; fi
# BFS

if [ -d /dev ] ; then ls -latrR /dev > ./$fileName/dev-latrR.txt 2>&1 ./$fileName/script_workspace/lsiget_errorlog.txt; fi

if [ -f /boot/grub/menu.lst ] ; then cp -p /boot/grub/menu.lst ./$fileName/; fi

if [ -f /proc/interrupts ] ; then cp -p /proc/interrupts ./$fileName/; fi

ps >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	ps > ./$fileName/ps.txt 2>> ./misc_output.txt
fi

ps -e >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	ps -e > ./$fileName/ps-e.txt 2>> ./misc_output.txt
fi

ps -ef >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	ps -ef > ./$fileName/ps-ef.txt 2>> ./misc_output.txt
fi

ps -ea >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	ps -ea > ./$fileName/ps-ea.txt 2>> ./misc_output.txt
fi

ps -auxw >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	ps -auxw > ./$fileName/ps-auxw.txt 2>> ./misc_output.txt
fi

fdisk -l >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	fdisk -l > ./$fileName/fdisk-l.txt 2>> ./misc_output.txt
fi

fdisk -lu >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	fdisk -lu > ./$fileName/fdisk-lu.txt 2>> ./misc_output.txt
fi

vgs >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	if [ ! -d ./$fileName/lvm ] ; then mkdir ./$fileName/lvm; fi
	vgs > ./$fileName/lvm/vgs.txt 2>> ./misc_output.txt
fi

lvs >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	if [ ! -d ./$fileName/lvm ] ; then mkdir ./$fileName/lvm; fi
	lvs > ./$fileName/lvm/lvs.txt 2>> ./misc_output.txt
fi

pvs >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	if [ ! -d ./$fileName/lvm ] ; then mkdir ./$fileName/lvm; fi
	pvs > ./$fileName/lvm/pvs.txt 2>> ./misc_output.txt
fi

lvdisplay >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	if [ ! -d ./$fileName/lvm ] ; then mkdir ./$fileName/lvm; fi
	lvdisplay > ./$fileName/lvm/lvdisplay.txt 2>> ./misc_output.txt
fi

pvdisplay >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	if [ ! -d ./$fileName/lvm ] ; then mkdir ./$fileName/lvm; fi
	pvdisplay > ./$fileName/lvm/pvdisplay.txt 2>> ./misc_output.txt
fi

sysctl -a >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	sysctl -a > ./$fileName/sysctl-a.txt 2>> ./misc_output.txt
fi

sysctl -ad >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	sysctl -ad > ./$fileName/sysctl-ad.txt 2>> ./misc_output.txt
fi

sysctl -ah >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	sysctl -ah > ./$fileName/sysctl-ah.txt 2>> ./misc_output.txt
fi

sysctl -adh >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	sysctl -adh > ./$fileName/sysctl-adh.txt 2>> ./misc_output.txt
fi

vmstat >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	vmstat > ./$fileName/vmstat.txt 2>> ./misc_output.txt
fi

vmstat -i >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	vmstat -i > ./$fileName/vmstat-i.txt 2>> ./misc_output.txt
fi

dmidecode >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	dmidecode > ./$fileName/dmidecode.txt 2>> ./misc_output.txt
fi

biosdecode >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	biosdecode > ./$fileName/biosdecode.txt 2>> ./misc_output.txt
fi

vpddecode >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	vpddecode > ./$fileName/vpddecode.txt 2>> ./misc_output.txt
fi

if [ -f /etc/lvm/lvm.conf ] ; then 
	if [ ! -d ./$fileName/lvm ] ; then mkdir ./$fileName/lvm; fi
	cp /etc/lvm/lvm.conf ./$fileName/lvm 2>> ./misc_output.txt 
fi

lsscsi >> ./misc_output.txt 2>&1
if [ $? = 0 ] ; then

	#cho ".................................................||................................................."
	echo "...............................................lsscsi..............................................." >> ./$fileName/lsscsi-all.txt
	lsscsi  >> ./$fileName/lsscsi-all.txt 2>> ./misc_output.txt
	for i in c d g H k l v ; do
		echo "..............................................lsscsi -$i............................................" >> ./$fileName/lsscsi-all.txt
		lsscsi -$i >> ./$fileName/lsscsi-all.txt 2>> ./misc_output.txt
	done

	# Non standard out, leave separate
	echo "..............................................lsscsi -V............................................" >> ./$fileName/lsscsi-all.txt
	lsscsi -V >> ./$fileName/lsscsi-all.txt 2>&1 
	
	lsscsi -vg >> ./$fileName/lsscsi-vg.txt 2>> ./misc_output.txt
	
	#cho ".................................................||................................................."
	echo ".......................All lines lspci -vv with AVAGO, LSI OR 3ware in the line....................." >> ./$fileName/Controller_Disk_Association.txt 2>> ./misc_output.txt
	lspci -vv 2>> ./misc_output.txt | $grep -i -e LSI -e 3ware -e avago >> ./$fileName/Controller_Disk_Association.txt
	
	#cho ".................................................||................................................."
	echo ".............................................lsscsi -vg............................................." >> ./$fileName/Controller_Disk_Association.txt 2>> ./misc_output.txt
	lsscsi -vg >> ./$fileName/Controller_Disk_Association.txt 2>> ./misc_output.txt
	
	else

	#cho ".................................................||................................................."
	echo "...............lsscsi NOT installed! Recommend Installation if supported on this OS................." >> ./$fileName/Controller_Disk_Association.txt

fi

lsblk >> ./misc_output.txt 2>&1

if [ $? = 0 ] ; then

	#cho ".................................................||................................................."
	echo "...............................................lsblk................................................" >> ./$fileName/lsblk-all.txt
	lsblk  >> ./$fileName/lsblk-all.txt 2>> ./misc_output.txt
	for i in a b t V ; do
		#cho ".................................................||................................................."
		echo "..............................................lsblk -$i............................................." >> ./$fileName/lsblk-all.txt
		lsblk -$i >> ./$fileName/lsblk-all.txt 2>> ./misc_output.txt
	done
fi

showsel  >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	showsel  > ./$fileName/showsel.txt 2>> ./misc_output.txt
fi

lshw  >> ./misc_output.txt 2>&1
if [ "$?" = "0" ] ; then
	lshw > ./$fileName/lshw.txt 2>> ./misc_output.txt
fi

if [ "$TWSKIPNETWORK" = "NO" ] ; then

	ifconfig  >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		#cho ".................................................||................................................."
		echo "..............................................ifconfig.............................................." > ./$fileName/network_config.txt
		ifconfig > ./$fileName/network_config.txt 2>> ./misc_output.txt
	fi

	ipmitool lan print  >> ./misc_output.txt 2>&1
	if [ "$?" = "0" ] ; then
		#cho ".................................................||................................................."
		echo ".........................................ipmitool_lan_print........................................." >> ./$fileName/network_config.txt
		ipmitool lan print >> ./$fileName/network_config.txt 2>> ./misc_output.txt
	fi
fi

echo "File Size Check - 4" >> ./misc_output.txt 2>&1
ls -latr >> ./misc_output.txt 2>&1


	#
	#All Generic Performance Tuning parameters should be gathered here!
	#
	echo "Collecting Generic SD Device Performance Tuning Data..."
	echo "Collecting - parted -s /dev/sdX print..."
	echo "Note: An active mkfs will cause this script to pause..."



	for i in $( ls /dev/sd* 2>> ./misc_output.txt ) ; do 
		dev=$(basename $i)

		if [ ! -d ./$fileName/Generic_Perf_Tuning ] ; then mkdir ./$fileName/Generic_Perf_Tuning ; fi 

		if [ -e /sys/block/${dev} ] ; then
				
			#cho ".................................................||................................................."
			echo "...................................................................................................." >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			echo "Parameters that impact performance, see the various KB articles on Performance Tuning." >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			echo "...................................................................................................." >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt


			echo "cat /sys/block/${dev}/queue/max_sectors_kb" >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			cat /sys/block/${dev}/queue/max_sectors_kb >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
	
			echo "cat /sys/block/${dev}/queue/nr_requests" >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			cat /sys/block/${dev}/queue/nr_requests >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			
			echo "cat /sys/block/${dev}/queue/queue_depth" >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			cat /sys/block/${dev}/device/queue_depth >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
		 
			echo "cat /sys/block/${dev}/queue/scheduler" >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			cat /sys/block/${dev}/queue/scheduler >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
	
			echo "blockdev --getra /dev/${dev}" >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
			blockdev --getra /dev/${dev} >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt        	

			if [ -d /sys/block/${dev} ] ; then 				
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
				echo "The following dumps all info in the /sys/block/${dev}/queue/ directory" >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
				echo "...................................................................................................."  >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
				
				for j in /sys/block/${dev}/queue/*; do
					if [ -f ${j} ] ; then
						echo $j >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt 2>&1
						cat $j >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt 2>&1
					fi
				done
				
				if [ -d /sys/block/${dev}/queue/iosched ] ; then 				
					for j in /sys/block/${dev}/queue/iosched/*; do
						if [ -f ${j} ] ; then 
							echo $j >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
							cat $j >> ./$fileName/Generic_Perf_Tuning/Generic_Perf_Tuning_${dev}.txt
						fi
					done
				fi
				
				#cho ".................................................||................................................."
				echo ".....................................parted -s /dev/${dev} print......................................." >> ./$fileName/parted_print_sdX.txt
				parted -s /dev/${dev} print >> ./$fileName/parted_print_sdX.txt 2>> ./misc_output.txt
			fi	
		fi
	done



if [ "$TWGETSKIPEXPANDER" != "YES" ] ; then
	###########################################################################################################################
	# LSI Expander Check Start
	###########################################################################################################################
	

	
	
	###########################################################################################################################
	# Set Gen 1 & 2 EXPANDER_INFO=YES If Linux/Solaris get LSI Expander Info
	###########################################################################################################################
	
	if [ "$OS_LSI" = "linux" ] ; then
		EXPANDER_INFO=YES
	fi
	
	if [ "$OS_LSI" = "solaris" ] ; then
		EXPANDER_INFO=YES
	fi
	
	if [ "$TWSKIPXUTILS" = "NO" ] ; then
	
		if [ "$EXPANDER_INFO" = "YES" ] ; then
	
			#Gen 1 #'s
			./xu -i get avail > ./$fileName/script_workspace/xu_-i_get_avail.txt  2>&1
			./xu -i get avail | $grepA -i SASx | $grepA -E -o '[0-9,A-F]+:[0-9,A-F]+' | cut -b 1-8,10-17 > ./$fileName/script_workspace/Gen1_EXP_SAS_Address.txt  2>&1
	
			# Make sure at least 1 SAS Address is identified
			if [ -s ./$fileName/script_workspace/Gen1_EXP_SAS_Address.txt ] ; then
				NO_xu_GEN1_or_2_EXPs=NO
				echo "Collecting LSI Gen 1 Expander Information..."
				if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
				if [ ! -d ./$fileName/LSI_Products/Expander/3Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/3Gb; fi
				if [ ! -d ./$fileName/LSI_Products/Expander/3Gb/Details ] ; then mkdir ./$fileName/LSI_Products/Expander/3Gb/Details; fi
				./xu -i get avail > ./$fileName/LSI_Products/Expander/3Gb/get_avail.txt 2>&1
				for i in `cat ./$fileName/script_workspace/Gen1_EXP_SAS_Address.txt` ; do 
					for l in 0 1 2 3 ; do
						#cho ".................................................||................................................."
						echo ".............................................Region $l..............................................." >> ./$fileName/LSI_Products/Expander/3Gb/${i}_get_ver.txt
						./xu -i $i get ver $l >> ./$fileName/LSI_Products/Expander/3Gb/${i}_get_ver.txt  2>&1
					done
					for l in 0 1 2 ; do
						#cho ".................................................||................................................."
						./xu -i $i up fw ./$fileName/LSI_Products/Expander/3Gb/${i}_region-${l}_up_fw.bin $l -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
					done
					for l in 3 ; do
						#cho ".................................................||................................................."
						./xu -i $i up mfg ./$fileName/LSI_Products/Expander/3Gb/${i}_region-${l}_up_mfg.bin $l -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
					done
					if [ -f ./$fileName/script_workspace/${i}_coredump_region.txt ] ; then 
						for l in $( cat ./$fileName/script_workspace/${i}_coredump_region.txt ) ; do
							#cho ".................................................||................................................."
							./xu -i $i up cfg ./$fileName/LSI_Products/Expander/3Gb/${i}_region-${l}_COREDUMP.bin ${l} -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
						done
					fi
	
					
					./xu -i $i get exp > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_exp.txt  2>&1
					./xu -i $i get region > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_region.txt  2>&1
					./xu -i $i get attach > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_attach.txt  2>&1
					./xu -i $i get port > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_port.txt  2>&1
					./xu -i $i get phy > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_phy.txt  2>&1
					#Causes segfault on gen1
					#./xu -i $i get trace > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_trace.txt  2>&1				
					./xu -i $i get log > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_log.txt  2>&1
					./xu -i $i get zgrp > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_zgrp.txt  2>&1
					./xu -i $i get zperm > ./$fileName/LSI_Products/Expander/3Gb/${i}_get_zperm.txt  2>&1
	
	
					if [ ! -f ./$fileName/LSI_Products/Expander/3Gb/${i}_xu.txt ] ; then 
						echo $fileName > ./$fileName/LSI_Products/Expander/3Gb/${i}_xu.txt
						#cho ".................................................||................................................."
						echo ".............................................get avail.............................................." >> ./$fileName/LSI_Products/Expander/3Gb/${i}_xu.txt
						cat ./$fileName/LSI_Products/Expander/3Gb/get_avail.txt >> ./$fileName/LSI_Products/Expander/3Gb/${i}_xu.txt 
					fi
					
					for j in ${i}_get_exp ${i}_get_ver ${i}_get_region ${i}_get_attach ${i}_get_port ${i}_get_phy ${i}_get_trace ${i}_get_log ${i}_get_zgrp ${i}_get_zperm ; do
				
						if [ -e ./$fileName/LSI_Products/Expander/3Gb/$j.txt ] ; then
							#cho ".................................................||................................................."
							echo "...........................................$j............................................" >> ./$fileName/LSI_Products/Expander/3Gb/${i}_xu.txt
							cat ./$fileName/LSI_Products/Expander/3Gb/$j.txt >> ./$fileName/LSI_Products/Expander/3Gb/${i}_xu.txt 
	
							if [ -e ./$fileName/LSI_Products/Expander/3Gb/$j.txt ] ; then 
								mv ./$fileName/LSI_Products/Expander/3Gb/${j}.txt ./$fileName/LSI_Products/Expander/3Gb/Details/${j}.txt
							fi
						fi
					done
				done			
			fi	
	
			#Gen 2 #'s
			./xu -i get avail > ./$fileName/script_workspace/xu_-i_get_avail.txt  2>&1
			./xu -i get avail | $grepA -i SAS2x | $grepA -E -o '[0-9,A-F]+:[0-9,A-F]+' | cut -b 1-8,10-17 > ./$fileName/script_workspace/Gen2_EXP_SAS_Address.txt  2>&1
	
			# Make sure at least 1 SAS Address is identified
			if [ -s ./$fileName/script_workspace/Gen2_EXP_SAS_Address.txt ] ; then
				echo "Collecting LSI Gen 2 Expander Information..."
				NO_xu_GEN1_or_2_EXPs=NO
				if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
				if [ ! -d ./$fileName/LSI_Products/Expander/6Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/6Gb; fi
				if [ ! -d ./$fileName/LSI_Products/Expander/6Gb/Details ] ; then mkdir ./$fileName/LSI_Products/Expander/6Gb/Details; fi
				./xu -i get avail > ./$fileName/LSI_Products/Expander/6Gb/get_avail.txt 2>&1
				for i in `cat ./$fileName/script_workspace/Gen2_EXP_SAS_Address.txt` ; do 
					for l in 0 1 2 3 ; do
						#cho ".................................................||................................................."
						echo ".............................................Region $l..............................................." >> ./$fileName/LSI_Products/Expander/6Gb/${i}_get_ver.txt
						./xu -i $i get ver $l >> ./$fileName/LSI_Products/Expander/6Gb/${i}_get_ver.txt  2>&1
					done
					for l in 0 1 2 ; do
						#cho ".................................................||................................................."
						./xu -i $i up fw ./$fileName/LSI_Products/Expander/6Gb/${i}_region-${l}_up_fw.bin $l -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
					done
					for l in 3 ; do
						#cho ".................................................||................................................."
						./xu -i $i up mfg ./$fileName/LSI_Products/Expander/6Gb/${i}_region-${l}_up_mfg.bin $l -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
					done
					if [ -f ./$fileName/script_workspace/${i}_coredump_region.txt ] ; then 
						for l in $( cat ./$fileName/script_workspace/${i}_coredump_region.txt ) ; do
							#cho ".................................................||................................................."
							./xu -i $i up cfg ./$fileName/LSI_Products/Expander/6Gb/${i}_region-${l}_COREDUMP.bin ${l} -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
						done
					fi
	
					
					./xu -i $i get exp > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_exp.txt  2>&1
					./xu -i $i get region > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_region.txt  2>&1
					./xu -i $i get attach > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_attach.txt  2>&1
					./xu -i $i get port > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_port.txt  2>&1
					./xu -i $i get phy > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_phy.txt  2>&1
					./xu -i $i get trace > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_trace.txt  2>&1				
					./xu -i $i get log > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_log.txt  2>&1
					./xu -i $i get zgrp > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_zgrp.txt  2>&1
					./xu -i $i get zperm > ./$fileName/LSI_Products/Expander/6Gb/${i}_get_zperm.txt  2>&1
	
	
					if [ ! -f ./$fileName/LSI_Products/Expander/6Gb/${i}_xu.txt ] ; then 
						echo $fileName > ./$fileName/LSI_Products/Expander/6Gb/${i}_xu.txt
						#cho ".................................................||................................................."
						echo ".............................................get avail.............................................." >> ./$fileName/LSI_Products/Expander/6Gb/${i}_xu.txt
						cat ./$fileName/LSI_Products/Expander/6Gb/get_avail.txt >> ./$fileName/LSI_Products/Expander/6Gb/${i}_xu.txt 
					fi
					
					for j in ${i}_get_exp ${i}_get_ver ${i}_get_region ${i}_get_attach ${i}_get_port ${i}_get_phy ${i}_get_trace ${i}_get_log ${i}_get_zgrp ${i}_get_zperm ; do
				
						if [ -e ./$fileName/LSI_Products/Expander/6Gb/$j.txt ] ; then
							#cho ".................................................||................................................."
							echo "...........................................$j............................................" >> ./$fileName/LSI_Products/Expander/6Gb/${i}_xu.txt
							cat ./$fileName/LSI_Products/Expander/6Gb/$j.txt >> ./$fileName/LSI_Products/Expander/6Gb/${i}_xu.txt 
	
							if [ -e ./$fileName/LSI_Products/Expander/6Gb/$j.txt ] ; then 
								mv ./$fileName/LSI_Products/Expander/6Gb/${j}.txt ./$fileName/LSI_Products/Expander/6Gb/Details/${j}.txt
							fi
						fi
					done
				done			
			fi
		fi
	fi	
	
	###########################################################################################################################
	# Set Gen 3 EXPANDER_INFO=YES If Linux/Solaris/FreeBSD get LSI Expander Info
	###########################################################################################################################
		
	if [ "$OS_LSI" = "linux" ] ; then
		if [ "$Arch32or64" = "64" ] ; then
			EXPANDER_INFO=YES
		fi
	fi
	
	if [ "$OS_LSI" = "solaris" ] ; then
		EXPANDER_INFO=YES
	fi
	
	if [ "$OS_LSI" = "freebsd" ] ; then
		EXPANDER_INFO=YES
	fi
	
	if [ "$TWSKIPXUTILS" = "NO" ] ; then
	
		if [ "$EXPANDER_INFO" = "YES" ] ; then
	
				#Gen 3 #'s
			./g3xu -i get avail > ./$fileName/script_workspace/g3xu_-i_get_avail.txt  2>&1
			./g3xu -i get avail | $grepA -i -e SAS_3X -e SAS_35X | $grepA -E -o '[0-9,A-F]+:[0-9,A-F]+' | cut -b 1-8,10-17 > ./$fileName/script_workspace/Gen3_EXP_SAS_Address.txt  2>&1
	
			# Make sure at least 1 SAS Address is identified
			if [ -s ./$fileName/script_workspace/Gen3_EXP_SAS_Address.txt ] ; then
				echo "Collecting LSI Gen 3 Expander Information..."
				NO_g3xu_GEN3_EXPs=NO
				if [ ! -d ./$fileName/LSI_Products/Expander ] ; then mkdir ./$fileName/LSI_Products/Expander; fi
				if [ ! -d ./$fileName/LSI_Products/Expander/12Gb ] ; then mkdir ./$fileName/LSI_Products/Expander/12Gb; fi
				if [ ! -d ./$fileName/LSI_Products/Expander/12Gb/Details ] ; then mkdir ./$fileName/LSI_Products/Expander/12Gb/Details; fi
				./g3xu -i get avail > ./$fileName/LSI_Products/Expander/12Gb/get_avail.txt 2>&1
				for i in `cat ./$fileName/script_workspace/Gen3_EXP_SAS_Address.txt` ; do 
					for l in 0 1 2 3 ; do
						#cho ".................................................||................................................."
						echo ".............................................Region $l..............................................." >> ./$fileName/LSI_Products/Expander/12Gb/${i}_get_ver.txt
						./g3xu -i $i get ver $l >> ./$fileName/LSI_Products/Expander/12Gb/${i}_get_ver.txt  2>&1
					done
					for l in 0 1 2 ; do
						#cho ".................................................||................................................."
						./g3xu -i $i up fw ./$fileName/LSI_Products/Expander/12Gb/${i}_region-${l}_up_fw.bin $l -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
					done
					for l in 3 ; do
						#cho ".................................................||................................................."
						./g3xu -i $i up mfg ./$fileName/LSI_Products/Expander/12Gb/${i}_region-${l}_up_mfg.bin $l -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
					done
					if [ -f ./$fileName/script_workspace/${i}_coredump_region.txt ] ; then 
						for l in $( cat ./$fileName/script_workspace/${i}_coredump_region.txt ) ; do
							#cho ".................................................||................................................."
							./g3xu -i $i up cfg ./$fileName/LSI_Products/Expander/12Gb/${i}_region-${l}_COREDUMP.bin ${l} -y  >>./$fileName/script_workspace/lsiget_errorlog.txt 2>&1
						done
					fi
	
					
					./g3xu -i $i get exp > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_exp.txt  2>&1
					./g3xu -i $i get region > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_region.txt  2>&1
					./g3xu -i $i get attach > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_attach.txt  2>&1
					./g3xu -i $i get port > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_port.txt  2>&1
					./g3xu -i $i get phy > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_phy.txt  2>&1
					./g3xu -i $i get trace > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_trace.txt  2>&1				
					./g3xu -i $i get log > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_log.txt  2>&1
					./g3xu -i $i get zgrp > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_zgrp.txt  2>&1
					./g3xu -i $i get zperm > ./$fileName/LSI_Products/Expander/12Gb/${i}_get_zperm.txt  2>&1
	
	
					if [ ! -f ./$fileName/LSI_Products/Expander/12Gb/${i}_g3xu.txt ] ; then 
						echo $fileName > ./$fileName/LSI_Products/Expander/12Gb/${i}_g3xu.txt
						#cho ".................................................||................................................."
						echo ".............................................get avail.............................................." >> ./$fileName/LSI_Products/Expander/12Gb/${i}_g3xu.txt
						cat ./$fileName/LSI_Products/Expander/12Gb/get_avail.txt >> ./$fileName/LSI_Products/Expander/12Gb/${i}_g3xu.txt 
					fi
					
					for j in ${i}_get_exp ${i}_get_ver ${i}_get_region ${i}_get_attach ${i}_get_port ${i}_get_phy ${i}_get_trace ${i}_get_log ${i}_get_zgrp ${i}_get_zperm ; do
				
						if [ -e ./$fileName/LSI_Products/Expander/12Gb/$j.txt ] ; then
							#cho ".................................................||................................................."
							echo "...........................................$j............................................" >> ./$fileName/LSI_Products/Expander/12Gb/${i}_g3xu.txt
							cat ./$fileName/LSI_Products/Expander/12Gb/$j.txt >> ./$fileName/LSI_Products/Expander/12Gb/${i}_g3xu.txt 
	
							if [ -e ./$fileName/LSI_Products/Expander/12Gb/$j.txt ] ; then 
								mv ./$fileName/LSI_Products/Expander/12Gb/${j}.txt ./$fileName/LSI_Products/Expander/12Gb/Details/${j}.txt
							fi
						fi
					done
				done			
			fi
		fi
	fi 
fi


if [ "$TWGETSKIPMEGARAID" != "YES" ] ; then
	###########################################################################################################################
	# MegaRAID Storage Manager Log files - Other Unix distros?
	###########################################################################################################################

	if [ -d "$MSM_HOME"/MegaMonitor ] ; then
		mkdir ./$fileName/LSI_Products/MegaRAID/MSM
		echo "Collecting MSM logs..."
		cp "$MSM_HOME"/MegaMonitor/* ./$fileName/LSI_Products/MegaRAID/MSM 2>> ./misc_output.txt
		cp "$MSM_HOME"/*.log ./$fileName/LSI_Products/MegaRAID/MSM 2>> ./misc_output.txt
		cp "$MSM_HOME"/*.txt ./$fileName/LSI_Products/MegaRAID/MSM 2>> ./misc_output.txt
	fi

	if [ "$MSM_HOME" = "" ] ; then
		if [ -d /usr/local/"MegaRAID Storage Manager"/MegaMonitor ] ; then
			mkdir ./$fileName/LSI_Products/MegaRAID/MSM
			echo "Collecting MSM logs..."
			cp /usr/local/"MegaRAID Storage Manager"/MegaMonitor/* ./$fileName/LSI_Products/MegaRAID/MSM 2>> ./misc_output.txt
			cp /usr/local/"MegaRAID Storage Manager"/*.log ./$fileName/LSI_Products/MegaRAID/MSM 2>> ./misc_output.txt
			cp /usr/local/"MegaRAID Storage Manager"/*.txt ./$fileName/LSI_Products/MegaRAID/MSM 2>> ./misc_output.txt
		fi
	fi

	if [ -f ./$fileName/LSI_Products/MegaRAID/MSM ] ; then
		if [ -f /etc/init.d/vivaldiframeworkd  ] ; then
			/etc/init.d/vivaldiframeworkd status 2 > ./$fileName/LSI_Products/MegaRAID/MSM/Status.txt 2>> ./misc_output.txt
		fi
	fi

	if [ -f ./$fileName/LSI_Products/MegaRAID/MSM ] ; then
		if [ -f /etc/init.d/mrmonitor   ] ; then
			/etc/init.d/mrmonitor status 2 >> ./$fileName/LSI_Products/MegaRAID/MSM/Status.txt 2>> ./misc_output.txt
			/etc/init.d/mrmonitor -v 2 >> ./$fileName/LSI_Products/MegaRAID/MSM/Status.txt 2>> ./misc_output.txt
			#Keep separate, mrmonitord_version.txt used in other parts of the script
			/etc/init.d/mrmonitor -v | cut -d m -f 2 | cut -d r -f 2 > ./$fileName/LSI_Products/MegaRAID/MSM/mrmonitord_version.txt 2>> ./misc_output.txt
		fi
	fi
fi	

###########################################################################################################################
echo "Collecting and Processing system logs/messages files..."
###########################################################################################################################
#Linux, FreeBSD
###########################################################################################################################


journalctl -h > ./$fileName/script_workspace/journalctl-h.txt 2>> ./misc_output.txt
if [ "$?" = "0" ] ; then
	if [ "$TWPRINTFILENAMETRIGGER" != "YES" ] ; then
		journalctl -a > ./$fileName/journalctl-a.txt 2>> ./misc_output.txt
		#journalctl -o verbose > ./$fileName/journalctl-o_verbose.txt 2>> ./misc_output.txt
	fi
	if [ -f ./journalctl_time.txt ] ; then
		journalctl_time=`(cat journalctl_time.txt)`
		if [ "$TWPRINTFILENAMETRIGGER" = "YES" ] ; then
			journalctl -a --since=${journalctl_time} > ./$fileName/journalctl-a.txt 2>> ./misc_output.txt
			#journalctl -o verbose > ./$fileName/journalctl-o_verbose.txt 2>> ./misc_output.txt
		fi
	fi
fi


###########################################################################################################################
# Start additional info collection
###########################################################################################################################
if [ -f ./local.sh ] ; then
	echo "Collecting additional info via local.sh..."
	mkdir ./$fileName/addedInfo
	./local.sh ./$fileName/addedInfo
fi 

###########################################################################################################################
# Move unused utilities to Utils and document utility versions
###########################################################################################################################

###lsiutil
if [ -f lsiutil ] ; then 
	echo "##### lsiutil" > ./$fileName/script_workspace/versions.txt 2>&1 
	./lsiutil 0 | grep Version | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_lsut_LSI_HBAs" = "YES" ] ; then 
		mv -f lsiutil Utils >> ./misc_output.txt 2>&1 
	fi
fi

###scli
if [ -f scli ] ; then 
	echo "##### scli" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./scli --list | grep Scrutiny | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_scl_EXP-IOC" = "YES" ] ; then 
		mv -f scli Utils >> ./misc_output.txt 2>&1 
	fi
fi

###sas2flash
if [ -f sas2flash ] ; then 
	echo "##### sas2flash" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./sas2flash -ver | grep "Version is:" | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_2flash_HBAs" = "YES" ] ; then 
		mv -f sas2flash Utils >> ./misc_output.txt 2>&1 
	fi
fi

###sas3flash
if [ -f sas3flash ] ; then 
	echo "##### sas3flash" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./sas3flash -ver | grep "Version is:" | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_3flash_HBAs" = "YES" ] ; then 
		mv -f sas3flash Utils >> ./misc_output.txt 2>&1 
	fi
fi

###sas2ircu
if [ -f sas2ircu ] ; then 
	echo "##### sas2ircu" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./sas2ircu | grep Version | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_2ircu_HBAs" = "YES" ] ; then 
		mv -f sas2ircu Utils >> ./misc_output.txt 2>&1 
	fi
fi

###sas3ircu
if [ -f sas3ircu ] ; then 
	echo "##### sas3ircu" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./sas3ircu | grep Version | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_3ircu_HBAs" = "YES" ] ; then 
		mv -f sas3ircu Utils >> ./misc_output.txt 2>&1 
	fi
fi

###storcli
###libstorelibir-2.so.14.07-0
if [ -f ${MCLI_NAME} ] ; then 
	echo "##### ${MCLI_NAME}" >> ./$fileName/script_workspace/versions.txt 2>&1 
	echo "##### libstorelibir-2.so.14.07-0" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./$MCLI_NAME | grep Ver | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_MR_Adps" = "YES" ] ; then 
		mv -f $MCLI_NAME Utils >> ./misc_output.txt 2>&1 
		if [ -f libstorelibir-2.so.14.07-0 ] ; then mv -f libstorelibir-2.so.14.07-0 Utils >> ./misc_output.txt 2>&1 ; fi
	fi
fi
#if [ -f ./$fileName/script_workspace/versions.txt ] ; then cat ./$fileName/script_workspace/versions.txt ; fi

###tw_cli
if [ -f tw_cli ] ; then 
	echo "##### tw_cli" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./tw_cli help | grep -e Copyright -e version | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_3Ware_Ctrls" = "YES" ] ; then 
		mv -f tw_cli Utils >> ./misc_output.txt 2>&1 
	fi
fi

###xutil
if [ -f xutil ] ; then 
	echo "##### xutil" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./xutil -h | grep -e Version -e Copyright | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_xu_GEN1_or_2_EXPs" = "YES" ] ; then 
		mv -f xutil Utils >> ./misc_output.txt 2>&1 
	fi
fi

###g3xutil
if [ -f g3xutil ] ; then 
	echo "##### g3xutil" >> ./$fileName/script_workspace/versions.txt 2>&1 
	echo "##### bootstrapCobra.bin" >> ./$fileName/script_workspace/versions.txt 2>&1
	./g3xutil -h | grep -e Version -e Copyright | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_g3xu_GEN3_EXPs" = "YES" ] ; then 
		mv -f g3xutil Utils >> ./misc_output.txt 2>&1 
		if [ -f bootstrapCobra.bin ] ; then mv -f bootstrapCobra.bin Utils >> ./misc_output.txt 2>&1 ; fi
	fi
fi



###flashoem
if [ -f flashoem ] ; then 
	echo "##### flashoem" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./flashoem -ver | grep "Version is" | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	if [ "$NO_flashoem_GEN2_or_3_HBAs" = "YES" ] ; then 
		mv -f flashoem Utils >> ./misc_output.txt 2>&1 

	fi
fi


####################Just Moved - Did not determine if compatible HW was installed
###sas2parser - Move to Utils subdir regardless of installed HW
if [ -f sas2parser ] ; then
	echo "##### sas2parser - Moved to Utils subdir regardless of installed HW" >> ./$fileName/script_workspace/versions.txt 2>&1 
	./sas2parser | grep Version | sed -e 's/^[ \t]*//' >> ./$fileName/script_workspace/versions.txt 2>&1 
	./sas2parser >> ./misc_output.txt 2>&1
	mv -f sas2parser Utils >> ./misc_output.txt 2>&1
fi

###LSIRBD.msi - Move to Utils subdir regardless of installed HW
if [ -f LSIRBD.msi ] ; then
	echo "##### LSIRBD.msi - Moved to Utils subdir regardless of installed HW" >> ./$fileName/script_workspace/versions.txt 2>&1 
	echo "Version 1.12.0.0 - Copyright LSI 2006 - 2017" >> ./$fileName/script_workspace/versions.txt 2>&1 
	mv -f LSIRBD.msi Utils >> ./misc_output.txt 2>&1
fi

###LSIPage.exe - Move to Utils subdir regardless of installed HW
if [ -f LSIPage.exe ] ; then
	echo "##### LSIPage.exe - Moved to Utils subdir regardless of installed HW" >> ./$fileName/script_workspace/versions.txt 2>&1 
	echo "MPI1 Version: 1.5.14.0 / MPI2 Version: 2.0.e.0 / Compiled: Sep 29 2010 08:55:14" >> ./$fileName/script_workspace/versions.txt 2>&1 
	mv -f LSIPage.exe Utils >> ./misc_output.txt 2>&1
	if [ -d LSI_Products/HBA ] ; then cp Utils/LSIPage.exe LSI_Products/HBA/. ; fi
fi

###bootstrapCobra.bin - Move to Utils subdir regardless of installed HW
if [ -f bootstrapCobra.bin ] ; then
	echo "##### bootstrapCobra.bin - Moved to Utils subdir regardless of installed HW" >> ./$fileName/script_workspace/versions.txt 2>&1 
	echo "No Version Number Associated" >> ./$fileName/script_workspace/versions.txt 2>&1 
	mv -f bootstrapCobra.bin Utils >> ./misc_output.txt 2>&1
fi


####################Docs/Notes
###MegaRAID_Terminology.txt
if [ -d ./$fileName/LSI_Products/MegaRAID ] ; then
	if [ ! -d ./$fileName/LSI_Products/MegaRAID/Notes ] ; then mkdir ./$fileName/LSI_Products/MegaRAID/Notes ; fi
	if [ -f MegaRAID_Terminology.txt ] ; then mv -f MegaRAID_Terminology.txt ./$fileName/LSI_Products/MegaRAID/Notes >> ./misc_output.txt 2>&1 ; fi
fi




###########################################################################################################################
# Script Start/Stop times
###########################################################################################################################
TWGETLUNIXSTOPutc=`date -u`
TWGETLUNIXSTOP=`date`
echo "START Universal Time" > ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTARTutc >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo "START Local Time" >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTART >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo "STOP Universal Time" >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTOPutc >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo "STOP Local Time" >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt
echo $TWGETLUNIXSTOP >> ./$fileName/script_workspace/Script_Start_Stop_Time.txt

if [ "$TWGETSKIPMEGARAID" != "YES" ] ; then
	###########################################################################################################################
	# Capture created logs in the working directory
	###########################################################################################################################
	
	if [ -f ./CtDbg.log ] ; then
		mv ./CtDbg.log ./$fileName/LSI_Products/MegaRAID/
	fi
	if [ -f ./MegaSAS.log ] ; then
		mv ./MegaSAS.log ./$fileName/LSI_Products/MegaRAID/
	fi
	if [ -f ./CmdTool.log ] ; then
		mv ./CmdTool.log ./$fileName/LSI_Products/MegaRAID/
	fi
fi


echo "File Size Check - 7" >> ./misc_output.txt 2>&1
ls -latr >> ./misc_output.txt 2>&1


###########################################################################################################################
# Clean up
###########################################################################################################################

for i in $( cat cleanup.txt ); do

	if [ -f ./$i ] ; then
		rm -f ./$i
	fi
done


rm -f cleanup.txt
CLEANED_UP=YES

###########################################################################################################################
# Compressing the file output 
###########################################################################################################################

if [ "$TWGETSKIPMEGARAID" != "YES" ] ; then
	if [ -f ./$fileName/LSI_Products/MegaRAID/CmdTool.log ] ; then rm ./$fileName/LSI_Products/MegaRAID/CmdTool.log >> ./misc_output.txt 2>&1 ; fi 
	if [ -f ./$fileName/LSI_Products/MegaRAID/MegaSAS.log ] ; then rm ./$fileName/LSI_Products/MegaRAID/MegaSAS.log >> ./misc_output.txt 2>&1 ; fi 
fi
if [ -f ./misc_output.txt ] ; then mv ./misc_output.txt ./$fileName/script_workspace > /dev/null 2>&1 ; fi


if [ "$TWGETSKIPCOMPRESSION" != "YES" ] ; then
	tar cfz $fileName.tgz ./$fileName 
	#gzip -9 $fileName.tar
fi

#BFS - remove unneeded dirs

if [ -d Scripts ]; then
		rm -r Scripts
fi

if [ -f Utils ] ; then
	rm Utils
fi
 
 
#Keep subdir unless variable set
if [ "$TWGETDIRECTORYKEEP" != "YES" ] ; then rm -rf $fileName > /dev/null 2>&1 ; fi 


#cho ".................................................||................................................."
echo ""
echo "Script done. The file name is;"
echo ""
echo "$fileName.tgz"
echo ""
echo "Send just this file as is to your support rep."
echo ""
echo "\"$BASECMD -H\" provides a help screen."
echo ""

if [ "$TWGETDIRECTORYKEEP" != "YES" ] ; then
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N' 
	fi	
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S' 
	fi 
fi

if [ "$TWGETDIRECTORYKEEP" = "YES" ] ; then 
	echo "The following subdir was left for your use;"
	echo ""
	echo "$fileName"
	echo ""
	if [ "$VMWARE_SUPPORTED" != "YES" ] ; then
		date '+%H:%M:%S.%N' 
	fi	
	if [ "$VMWARE_SUPPORTED" = "YES" ] ; then
		date '+%H:%M:%S' 
	fi
fi


if [ "$TWGETBATCHMODE" != "BATCH" ] ; then 
	if [ "$TWGETBATCHMODE" != "QUIET" ] ; then 
	   WaitQuit
	fi
fi

fi

