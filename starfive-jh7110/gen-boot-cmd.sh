#!/usr/bin/env sh

U_BOOT_CONFIG="$1"
OUTPUT_BOOT_CMD="$2"

# SPL(256KB): 0x0 ~ 0x40000(CONFIG_SPL_MAX_SIZE)
# ENV(64K): 0xf0000(CONFIG_ENV_OFFSET) ~ 0x100000(CONFIG_ENV_OFFSET+CONFIG_ENV_SIZE)
# Proper(3M): 0x100000(CONFIG_ENV_OFFSET+CONFIG_ENV_SIZE) ~ 0x400000

CONFIG_SPL_MAX_SIZE="$(grep 'CONFIG_SPL_MAX_SIZE=' "${U_BOOT_CONFIG}" | cut -d '=' -f 2)"
if [ -z "${CONFIG_SPL_MAX_SIZE}" ]; then
    echo "CONFIG_SPL_MAX_SIZE not set"
    exit 1
fi
CONFIG_ENV_OFFSET="$(grep 'CONFIG_ENV_OFFSET=' "${U_BOOT_CONFIG}" | cut -d '=' -f 2)"
if [ -z "${CONFIG_ENV_OFFSET}" ]; then
    echo "CONFIG_ENV_OFFSET not set"
    exit 1
fi
CONFIG_ENV_SIZE="$(grep 'CONFIG_ENV_SIZE=' "${U_BOOT_CONFIG}" | cut -d '=' -f 2)"
if [ -z "${CONFIG_ENV_SIZE}" ]; then
    echo "CONFIG_ENV_SIZE not set"
    exit 1
fi
CONFIG_SYS_SPI_U_BOOT_OFFS="$(grep 'CONFIG_SYS_SPI_U_BOOT_OFFS=' "${U_BOOT_CONFIG}" | cut -d '=' -f 2)"
if [ -z "${CONFIG_SYS_SPI_U_BOOT_OFFS}" ]; then
    echo "CONFIG_SYS_SPI_U_BOOT_OFFS not set"
    exit 1
fi
CONFIG_SYS_LOAD_ADDR="$(grep 'CONFIG_SYS_LOAD_ADDR=' "${U_BOOT_CONFIG}" | cut -d '=' -f 2)"
if [ -z "${CONFIG_SYS_LOAD_ADDR}" ]; then
    echo "CONFIG_SYS_LOAD_ADDR not set"
    exit 1
fi

cat << EOF > "${OUTPUT_BOOT_CMD}"
# Avoid disruption from existing ENV on NOR flash
env default -a

# Blink 3 times before starting the update
led act on
sleep 1
led act off
sleep 1
led act on
sleep 1
led act off
sleep 1
led act on
sleep 1
led act off

# Device in use
sf probe
mmc dev 1

# Padding unused space with 0xff
mw ${CONFIG_SYS_LOAD_ADDR} 0xff 0x400000

# Load from files
fatload mmc 1:3 ${CONFIG_SYS_LOAD_ADDR} u-boot-spl.bin.normal.out 0
fatload mmc 1:3 $(printf '0x%x\n' $((CONFIG_SYS_LOAD_ADDR+CONFIG_ENV_OFFSET))) u-boot-env-default.bin 0
fatload mmc 1:3 $(printf '0x%x\n' $((CONFIG_SYS_LOAD_ADDR+CONFIG_SYS_SPI_U_BOOT_OFFS))) u-boot.itb 0

# write to flash
sf write ${CONFIG_SYS_LOAD_ADDR} 0x0 0x400000

# Notify user
led act on
EOF
