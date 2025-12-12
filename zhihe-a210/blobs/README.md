# Blobs for A210 Bootloader

## Filelist

- `a210-aon.bin`: Always-On firmware, powermanage purpose
- `bootzero2.bin`:  Proprietary firmware, performs platform initialization
- `bootzero-rvbl.bin`: Same as above but specially designed for fastboot loading
- `a210-opensbi.dtb`: DTB used by OpenSBI, built from kernel source

## Where to Get Them

### 闭源固件

根据官方 SDK 构建文档：

https://developer.zhcomputing.com/docs/SDK/Quick-start-guide/Basic_quick_start_guide

下载的 [`build.sh`](http://developer.zhcomputing.com/downloads/release/zhihesdk/develop/build.sh) 构建脚本可知，固件位于如下 URL：

http://8.149.140.24/downloads/release/zhihesdk/develop/zhihesdk-develop-a210_evb.tar.gz

目录为：

```
./rootfs/boot/
```

### OpenSBI 使用的 DTB

目前来看 OpenSBI 只能使用来自内核的 DTB，为了构建阶段不引入内核，并且将固件与内核解藕，因此将该 DTB 当作 blob 处理。

## Licensing

**TBD**

## Version

- 20251117 下载最新固件
- 20251114 下载最新固件
- 20251103 下载最新固件
- 20251212 下载的固件为 20251205 版本
