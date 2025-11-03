# U-Boot for Zhihe A210

## Supported Devices

- Zhihe A210 DEV

## Filelist

- `binman-emmc_boot-loader.img`: 刷写至 EMMC BOOT1 硬件分区的固件镜像
- `bootzero-rvbl.bin`: fastboot 使用的平台初始化固件
- `binman-spl-with-fit-rvbl.bin`: fastboot 使用的 U-Boot 与 OpenSBI 固件

## Usage

### Firmware Update

#### Prepare

Make sure Android ADB suite (aka. [Android SDK Platform Tools](https://developer.android.com/tools/releases/platform-tools)) is installed.

#### Entering Fastboot Mode

1. Connecting USB Type-C port (Marked as USB2) to PC.
2. Connecting DEBUG Uart to PC with serial adapter.
3. Power the board.
4. Press `K1` once.
5. Press `K2` button while holding `K1` button.
6. Release `K2` button.

#### Booting from RAM

Make sure current working directory contains the files extracted from our firmware release.

Executing on the host PC:

```shell
fastboot flash ram bootzero-rvbl.bin && \
fastboot reboot && \
fastboot flash ram binman-spl-with-fit-rvbl.bin && \
fastboot reboot
```

#### EMMC Programming

Executing on the host PC:

```shell
fastboot flash mmc0boot0 binman-emmc_boot-loader.img
# Optionally flash the OS image located in the EMMC User Area as well
# fastboot flash mmc0 openEuler-24.03-LTS-SP1-base-Zhihe-A210-extlinux.img.sparse
```

#### Post Configuration

Executing over DEBUG serial connection:

```shell
env erase
env set fdtfile zhihe/a210-dev.dtb
env save
```

### OS Deployment

An Android sparse disk image is expected.

`img2simg` is required to convert a normal disk dump into a sparse image, packaged as `android-sdk-libsparse-utils` on Debian-based distributions.

OS image can be writen to EMMC through fastboot mode in either condition, even within the procedure of firmware updating.
