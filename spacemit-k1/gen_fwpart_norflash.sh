#!/usr/bin/env sh
# shellcheck disable=SC2034

set -e
set -u

PART_PAYLOAD_bootinfo="bootinfo_spinor.bin"
PART_PAYLOAD_fsbl="FSBL.bin"
PART_PAYLOAD_env="u-boot-env-default.bin"
PART_PAYLOAD_opensbi="fw_dynamic.itb"
PART_PAYLOAD_uboot="u-boot.itb"

BUILD_CONFIG="$1"

eval "$(grep "CONFIG_MTDPARTS_DEFAULT" "${BUILD_CONFIG}")"
if [ -z "${CONFIG_MTDPARTS_DEFAULT}" ]; then
    echo "CONFIG_MTDPARTS_DEFAULT not defined"
    exit 1
fi
MTDPARTS="$(printf "%s" "${CONFIG_MTDPARTS_DEFAULT}" | cut -d ':' -f 2- | tr ',' '\t')"

cat << EOF
{
  "version": "1.0",
  "format": "mtd",
  "partitions": [
EOF

first_loop_marker=""

for part in ${MTDPARTS}; do
    partinfo="$(printf "%s" "${part}" | sed -nE 's/([0-9\-]+[KMG]?)@([0-9]+[KMG]?)\(([a-zA-Z]+)\)/\1 \2 \3/p')"
    if [ -z "${partinfo}" ]; then
        echo "Error: unrecognized mtdpart: ${part}" 1>&2
        exit 1
    fi
    partname="$(printf "%s" "${partinfo}" | cut -d ' ' -f 3)"
    partsize="$(printf "%s" "${partinfo}" | cut -d ' ' -f 1)"
    partoffset="$(printf "%s" "${partinfo}" | cut -d ' ' -f 2)"
    # Only keep partitions with defined content
    if eval "[ -z \"\${PART_PAYLOAD_${partname}+x}\" ]"; then
        echo "Notice: unassigned mtd part: ${partname}" 1>&2
        continue
    fi
    partpayload="$(eval echo "\${PART_PAYLOAD_${partname}}")"


    cat << EOF
    ${first_loop_marker}{
      "name": "${partname}",
      "offset": "${partoffset}",
      "size": "${partsize}",
      "image": "${partpayload}"
EOF
    first_loop_marker="},
    "
done

cat << EOF
    }
  ]
}
EOF
