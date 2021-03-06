# script for nuvoton M0517 OpenOCD linux

transport select hla_swd
source [find target/swj-dp.tcl]

if { [info exists CHIPNAME] } {
   set _CHIPNAME $CHIPNAME
} else {
   set _CHIPNAME M0517
}

if { [info exists ENDIAN] } {
   set _ENDIAN $ENDIAN
} else {
   set _ENDIAN little
}

# Work-area is a space in RAM used for flash programming
# By default use 4kB
if { [info exists WORKAREASIZE] } {
   set _WORKAREASIZE $WORKAREASIZE
} else {
   set _WORKAREASIZE 0x1000
}

if { [info exists CPUTAPID] } {
   set _CPUTAPID $CPUTAPID
} else {
  # See STM Document RM0091
  # Section 29.5.3
   set _CPUTAPID 0x0bb11477
}

swj_newdap $_CHIPNAME cpu -irlen 4 -ircapture 0x1 -irmask 0xf -expected-id $_CPUTAPID

set _TARGETNAME $_CHIPNAME.cpu
target create $_TARGETNAME cortex_m -endian $_ENDIAN -chain-position $_TARGETNAME

$_TARGETNAME configure -work-area-phys 0x20000000 -work-area-size $_WORKAREASIZE -work-area-backup 0

# # flash size will be probed
# set _FLASHNAME $_CHIPNAME.flash_aprom
# flash bank $_FLASHNAME nuc1x 0x00000000 0x4000 0 0 $_TARGETNAME
# set _FLASHNAME $_CHIPNAME.flash_data
# flash bank $_FLASHNAME nuc1x 0x0001F000 0x1000 0 0 $_TARGETNAME
# set _FLASHNAME $_CHIPNAME.flash_ldrom
# flash bank $_FLASHNAME nuc1x 0x00100000 0x1000 0 0 $_TARGETNAME
# set _FLASHNAME $_CHIPNAME.flash_conf
# flash bank $_FLASHNAME nuc1x 0x00300000 0x0100 0 0 $_TARGETNAME

# adapter speed should be <= F_CPU/6. F_CPU after reset is 8MHz, so use F_JTAG = 1MHz
# adapter_khz 1000
# adapter_nsrst_delay 100

if {![using_hla]} {
   # if srst is not fitted use SYSRESETREQ to
   # perform a soft reset
   cortex_m reset_config sysresetreq
}
