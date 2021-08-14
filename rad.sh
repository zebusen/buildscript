#!/usr/bin/env bash
cd $(pwd)
token=$TELEGRAM_TOKEN
WD=$(pwd)
IMG=${WD}"/out/arch/arm64/boot/Image.gz-dtb"
DATE="`date +%d%m%Y-%H%M%S`"
cd ${WD}
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_HOST=hololive
export KBUILD_BUILD_USER="SuiseiKawaii"
function cloneDEP() {
if [ "${COMPILER}" == "gcc-gnu" ]; then
if [ "${GCC_BRANCH}" == "gnu-12" ]; then
git clone --depth=1 --quiet https://github.com/fiqri19102002/aarch64-gcc.git -b master gcc64
git clone --depth=1 --quiet https://github.com/fiqri19102002/arm-gcc.git -b master gcc32
elif [ "${GCC_BRANCH}" == "gnu-10" ]; then
git clone --depth=1 --quiet https://github.com/fiqri19102002/aarch64-gcc.git -b gnu-gcc-10 gcc64
git clone --depth=1 --quiet https://github.com/fiqri19102002/arm-gcc.git -b gnu-gcc-10 gcc32
else
git clone --depth=1 --quiet https://github.com/fiqri19102002/aarch64-gcc.git -b gnu-gcc-10 gcc64
git clone --depth=1 --quiet https://github.com/fiqri19102002/arm-gcc.git -b gnu-gcc-10 gcc32
fi
cd ${WD}
COMPILER_STRING="$(${WD}"/gcc64/bin/aarch64-linux-gnu-gcc" --version | head -n 1)"
export KBUILD_COMPILER_STRING="${COMPILER_STRING}"
export CROSS_COMPILE=$WD"/gcc64/bin/aarch64-linux-gnu-"
export CROSS_COMPILE_ARM32=$WD"/gcc32/bin/arm-linux-gnueabi-"
# /////////////////////////////
elif [ "${COMPILER}" == "gcc-elf" ]; then
if [ "${GCC_BRANCH}" == "eva" ]; then
git clone --depth=1 --quiet https://github.com/mvaisakh/gcc-arm.git -b gcc-master gcc32
git clone --depth=1 --quiet https://github.com/mvaisakh/gcc-arm64.git -b gcc-master gcc64
elif [ "${GCC_BRANCH}" == "silont-10" ]; then
git clone --depth=1 --quiet https://github.com/silont-project/aarch64-elf-gcc.git -b arm64/10 gcc64
git clone --depth=1 --quiet https://github.com/silont-project/arm-eabi-gcc.git -b arm/10 gcc32
elif [ "${GCC_BRANCH}" == "silont-11" ]; then
git clone --depth=1 --quiet https://github.com/silont-project/aarch64-elf-gcc.git -b arm64/11 gcc64
git clone --depth=1 --quiet https://github.com/silont-project/arm-eabi-gcc.git -b arm/11 gcc32
else
git clone --depth=1 --quiet https://github.com/silont-project/aarch64-elf-gcc.git -b arm64/10 gcc64
git clone --depth=1 --quiet https://github.com/silont-project/arm-eabi-gcc.git -b arm/10 gcc32
fi
cd ${WD}
COMPILER_STRING="$(${WD}"/gcc64/bin/aarch64-elf-gcc" --version | head -n 1)"
export KBUILD_COMPILER_STRING="${COMPILER_STRING}"
export CROSS_COMPILE=$WD"/gcc64/bin/aarch64-elf-"
export CROSS_COMPILE_ARM32=$WD"/gcc32/bin/arm-eabi-"
# ////////////////////////////
elif [ "${COMPILER}" == "aosp-clang" ]; then
git clone --depth=1 --quiet https://github.com/fiqri19102002/aarch64-gcc.git -b gnu-gcc-10 gcc64
git clone --depth=1 --quiet https://github.com/fiqri19102002/arm-gcc.git -b gnu-gcc-10 gcc32
mkdir clang
    cd clang || exit
    # wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r416183b.tar.gz
    wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/master/clang-r428724.tar.gz
    tar -xzf clang*
    cd .. || exit
cd ${WD}
COMPILER_STRING="$(${CC} --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export KBUILD_COMPILER_STRING="${COMPILER_STRING}"
export CROSS_COMPILE=$WD"/gcc64/bin/aarch64-linux-gnu-"
export CROSS_COMPILE_ARM32=$WD"/gcc32/bin/arm-linux-gnueabi-"
# ///////////////////////////
elif [ "${COMPILER}" == "proton-clang" ]; then
git clone --depth=1 --quiet https://github.com/kdrag0n/proton-clang clang
cd ${WD}
COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1)"
export KBUILD_COMPILER_STRING="${COMPILER_STRING}"
fi
# END ///////////////////////
}
function cloneAK() {
git clone --depth=1 https://github.com/Reinazhard/AnyKernel3 AnyKernel
}
function compile() {
START=$(date +"%s")
make -j$(nproc) O=out ARCH=arm64 ${CONFIG}
if [ "${COMPILER}" == "aosp-clang" ]; then
PATH="$(pwd)/clang"/bin:${PATH} \
    make -j$(nproc) O=out ARCH=arm64 CC="clang" CLANG_TRIPLE="aarch64-linux-gnu-"
elif [ "${COMPILER}" == "proton-clang" ]; then
    make -j$(nproc) O=out \
    		ARCH=arm64 \
                CC=clang \
                CROSS_COMPILE=aarch64-linux-gnu- \
                CROSS_COMPILE_ARM32=arm-linux-gnueabi-
else
    make -j$(nproc) O=out ARCH=arm64
fi
cp ${WD}/out/arch/arm64/boot/Image.gz-dtb ${WD}/AnyKernel
}
function zipKernel() {
DATE="`date +%d%m%H%M`"
if [ "${UCLAMP}" == "true" ]; then
UCLAMP_NAME="-uclamp"
else
UCLAMP_NAME=""
fi
cd "${WD}"/AnyKernel
if [ "${CONFIG}" == "whyred_defconfig" ]; then
if [ "${SLMK}" == "true" ]; then
zip -r9 personal-oldcam-radeas-slmk${UCLAMP_NAME}-${DATE}.zip *
else
zip -r9 personal-oldcam-radeas-${DATE}.zip *
fi
elif [ "${CONFIG}" == "whyred-newcam_defconfig" ]; then
zip -r9 personal-newcam-radeas${UCLAMP_NAME}-${DATE}.zip *
elif [ "${CONFIG}" == "fakerad_defconfig" ]; then
zip -r9 personal-fakerad${UCLAMP_NAME}-${DATE}.zip *
fi
cd ..
END=$(date +"%s")
DIFF=$(($END - $START))
}
function push() {
cd AnyKernel
ZIP=$(echo *.zip)
 curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="-1001214166550" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) second(s). | For <b>WHYRED</b> | using ${COMPILER_STRING} | ${DATE}"
	cd ..
}
function sendInfo() {
suffix="_defconfig"
TYPE="${CONFIG} | sed -e 's/^$suffix$//'"
curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="-1001214166550" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Started ${TYPE} build ${DATE} using ${COMPILER} ${GCC_BRANCH}"
}
# theradcolor/lazyscripts
for i in "$@"; do
    case $i in
    --oldcam)
        CONFIG="whyred_defconfig"
        shift
        ;;
    --newcam)
        CONFIG="whyred-newcam_defconfig"
        shift
        ;;
    --fakerad)
        CONFIG="fakerad_defconfig"
        shift
        ;;
    --gcc-gnu)
        COMPILER="gcc-gnu"
        shift
        ;;
    --gcc-elf)
        COMPILER="gcc-elf"
        shift
        ;;
    --aosp-clang)
        COMPILER="aosp-clang"
        shift
        ;;
    --proton-clang)
        COMPILER="proton-clang"
        shift
        ;;
    --gnu-10)
    	GCC_BRANCH="gnu-10"
    	shift
	;;
    --gnu-12)
    	GCC_BRANCH="gnu-12"
	shift
	;;
    --eva)
    	GCC_BRANCH="eva"
	shift
	;;
    --silont-10)
    	GCC_BRANCH="silont-10"
	shift
	;;
    --silont-11)
    	GCC_BRANCH="silont-11"
	shift
	;;
    --slmk)
    	SLMK="true"
	shift
	;;
    --uclamp)
    	UCLAMP="true"
	shift
	;;
    *)
        # unknown option
        echo "Unknown option(s)"
        exit
        ;;
    esac
done
# initialize
cloneDEP
cloneAK
sendInfo
compile
zipKernel
push
# ///////////////////// END //////////////////////
