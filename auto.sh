#!/bin/bash

# --------------------------------------------
#    KernelBuilder V1.1
# --------------------------------------------
# by eraselk20

TIMESTAMP=$(date +"%Y%m%d")
DATES=$(date +"%Y-%m-%d")
FW=RUI2
CHATID=-4038162495
curl -X POST --silent --output /dev/null https://api.telegram.org/bot6958149447:AAF-GLC5WcpN3Zb9G9XWRL2uiiMX9exbKWc/sendMessage -d chat_id=${CHATID} -d text="|| Starting cooking ||"
sleep 10s
# Package
sudo apt update && sudo apt install nano bc bison ca-certificates curl flex gcc git libc6-dev libssl-dev openssl python-is-python3 ssh wget zip zstd make clang gcc-arm-linux-gnueabi software-properties-common build-essential libarchive-tools gcc-aarch64-linux-gnu -y && sudo apt install build-essential -y && sudo apt install libssl-dev libffi-dev libncurses5-dev zlib1g zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev make gcc -y && sudo apt install pigz -y && sudo apt install python2 -y && sudo apt install python3 -y
# Clone
git clone --depth=1 https://github.com/kdrag0n/proton-clang clang
git clone --depth=1 https://github.com/EternalX-project/aarch64-linux-gnu gcc64
git clone --depth=1 https://github.com/EternalX-project/arm-linux-gnueabi gcc32
git clone --depth=1 https://github.com/picasso09/AnyKernel3 anykernel
# KSU (KernelSU). 0= No. 1= Yes.
KSU=1

# Function
if [[ $KSU == "1" ]]; then
curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -
fi

#endfunc
#permission
find . -type f -exec chmod 777 {} +
#
sleep 10s
curl -X POST --silent --output /dev/null https://api.telegram.org/bot6958149447:AAF-GLC5WcpN3Zb9G9XWRL2uiiMX9exbKWc/sendMessage -d chat_id=${CHATID} -d text="|| Build Started ||"
# compile
export KBUILD_BUILD_USER="picasso"
export KBUILD_BUILD_HOST="picasso09"

make O=out ARCH=arm64 oppo6765_defconfig
PATH="${PWD}/clang/bin:${PATH}:${PWD}/gcc32/bin:${PATH}:${PWD}/gcc64/bin:${PATH}" \
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC="clang" \
                      CLANG_TRIPLE=aarch64-linux-gnu- \
                      CROSS_COMPILE="${PWD}/gcc64/bin/aarch64-elf-" \
                      CROSS_COMPILE_ARM32="${PWD}/gcc32/bin/arm-eabi-" \
V=0 2>&1 | tee log.txt

if [[ -f "out/arch/arm64/boot/Image.gz" ]]; then
curl -X POST --silent --output /dev/null https://api.telegram.org/bot6958149447:AAF-GLC5WcpN3Zb9G9XWRL2uiiMX9exbKWc/sendMessage -d chat_id=${CHATID} -d text="|| Kernel Build Success!, Zipping Kernel... ||"
cp ${PWD}/out/arch/arm64/boot/Image.gz ${PWD}/anykernel
    # Zip the kernel
    cd ${PWD}/anykernel
    zip -r9 "DiscussionVerse-picasso09-${TIMESTAMP}-${FW}".zip * -x .git README.md *placeholder
    cd ..
    # make zip directory
    mkdir -p zipd
    mv ${PWD}/anykernel/DiscussionVerse-picasso09-${TIMESTAMP}-${FW}.zip ${PWD}/zipd
curl -F chat_id=${CHATID} -F document=@${PWD}/zipd/DiscussionVerse-picasso09-${TIMESTAMP}-${FW}.zip -F caption="Zipping Kernel Done || Build Date: ${DATES}" "https://api.telegram.org/bot6958149447:AAF-GLC5WcpN3Zb9G9XWRL2uiiMX9exbKWc/sendDocument"
curl -F chat_id=${CHATID} -F document=@${PWD}/log.txt -F caption="Build Log" "https://api.telegram.org/bot6958149447:AAF-GLC5WcpN3Zb9G9XWRL2uiiMX9exbKWc/sendDocument"
exit 1
else
echo "Kernel doesn't Compiled 100%"
curl -X POST --silent --output /dev/null https://api.telegram.org/bot6958149447:AAF-GLC5WcpN3Zb9G9XWRL2uiiMX9exbKWc/sendMessage -d chat_id=${CHATID} -d text="|| KERNEL BUILD FAILED!"
sleep 4s
curl -F chat_id=${CHATID} -F document=@${PWD}/log.txt -F caption="Build Log" "https://api.telegram.org/bot6958149447:AAF-GLC5WcpN3Zb9G9XWRL2uiiMX9exbKWc/sendDocument"
exit 1
fi
