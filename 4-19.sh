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
elif [ "${GCC_BRANCH}" == "elf-10" ]; then
git clone --depth=1 --quiet https://github.com/fiqri19102002/aarch64-gcc.git -b elf-gcc-10 gcc64
git clone --depth=1 --quiet https://github.com/fiqri19102002/arm-gcc.git -b elf-gcc-10 gcc32
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
    # wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/master/clang-r428724.tar.gz
    # wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/c3260b409f13d92f8c9f4795420238694c529352/clang-r416183c1.tar.gz
    # wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/ecd70fc88e56db2ebcaa0a4d893e7c416eee84a8.tar.gz
    # wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/9a12fa7b5a8a4b796ae34d04402151c64aeb6ad6/clang-r437112b.tar.gz
    wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/a0c964f6d8448a9611f11744c432819eaf33265c/clang-r445002.tar.gz
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
function modify() {
# Use for modifications of the kernel like kernel configs
echo "modify configs using sed"
# Devfreq_boost frequency
# sed -i 's/CONFIG_DEVFREQ_MSM_CPUBW_BOOST_FREQ=2597/CONFIG_DEVFREQ_MSM_CPUBW_BOOST_FREQ=1571/g' arch/arm64/configs/${CONFIG}
}
function compile() {
START=$(date +"%s")
# make -j$(nproc) O=out ARCH=arm64 ${CONFIG}
make -j$(nproc) O=out ARCH=arm64 SUBARCH=arm64 vendor/whyred_defconfig
if [ "${COMPILER}" == "aosp-clang" ]; then
PATH="$(pwd)/clang"/bin:${PATH} \
    make -j$(nproc) O=out ARCH=arm64 SUBARCH=arm64 CC="clang" CLANG_TRIPLE="aarch64-linux-gnu-"
elif [ "${COMPILER}" == "proton-clang" ]; then
    make -j$(nproc) O=out \
    		ARCH=arm64 \
                CC=clang \
                CROSS_COMPILE=aarch64-linux-gnu- \
                CROSS_COMPILE_ARM32=arm-linux-gnueabi-
else
	if [ "${LLD}" == "true" ] || [ "${GCC_BRANCH}" == "eva" ]; then
		make -j$(nproc) O=out ARCH=arm64 LD=ld.lld
	else
	make -j$(nproc) O=out ARCH=arm64
	fi
fi
cp ${WD}/out/arch/arm64/boot/Image.gz-dtb ${WD}/AnyKernel
}
function zipKernel() {
if [ "${HMP}" != "hmp" ] || [ "${HMP}" == "" ]; then
HMP="eas"
fi
DATE="`date +%d%m%H%M`"
if [ "${UCLAMP}" == "true" ]; then
UCLAMP_NAME="-uclamp"
else
UCLAMP_NAME=""
fi
cd "${WD}"/AnyKernel
if [ "${CONFIG}" == "whyred_defconfig" ]; then
if [ "${SLMK}" == "true" ]; then
zip -r9 personal-oldcam-rad${HMP}-slmk${UCLAMP_NAME}-${DATE}.zip *
else
zip -r9 personal-oldcam-rad{HMP}${UCLAMP_NAME}-${DATE}.zip *
fi
elif [ "${CONFIG}" == "whyred-newcam_defconfig" ]; then
zip -r9 personal-newcam-rad${HMP}${UCLAMP_NAME}-${DATE}.zip *
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
	TYPE="oldcam"
        shift
        ;;
    --newcam)
        CONFIG="whyred-newcam_defconfig"
	TYPE="newcam"
        shift
        ;;
    --fakerad)
        CONFIG="fakerad_defconfig"
	TYPE="fakerad"
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
    --elf-10)
    	GCC_BRANCH="elf-10"
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
    --hmp)
    	HMP="hmp"
	shift
	;;
    --lld)
    	LLD="true"
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
modify
sendInfo
compile
zipKernel
push
# ///////////////////// END //////////////////////
