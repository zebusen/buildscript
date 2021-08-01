function cloneDEP() {
if [ "${COMPILER}" == "gcc10" ]; then
git clone --depth=1 --quiet https://github.com/fiqri19102002/aarch64-gcc.git -b gnu-gcc-10 gcc64
git clone --depth=1 --quiet https://github.com/fiqri19102002/arm-gcc.git -b gnu-gcc-10 gcc32
cd ${WD}
COMPILER_STRING="$(${WD}"/gcc64/bin/aarch64-linux-gnu-gcc" --version | head -n 1)"
export KBUILD_COMPILER_STRING="${COMPILER_STRING}"
export CROSS_COMPILE=$WD"/gcc64/bin/aarch64-linux-gnu-"
export CROSS_COMPILE_ARM32=$WD"/gcc32/bin/arm-linux-gnueabi-"
# /////////////////////////////
elif [ "${COMPILER}" == "gcc-eva" ]; then
git clone --depth=1 --quiet https://github.com/mvaisakh/gcc-arm.git -b gcc-master gcc32
git clone --depth=1 --quiet https://github.com/mvaisakh/gcc-arm64.git -b gcc-master gcc64
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
    wget -q https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/master/clang-r416183b.tar.gz
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
function cloneAK(){
git clone --depth=1 https://github.com/Reinazhard/AnyKernel3 AnyKernel
}
function initialize(){
TGtoken=$TELEGRAM_TOKEN
WD=$(pwd)
IMG=${WD}"/out/arch/arm64/boot/Image.gz-dtb"
DATE="`date +%d%m%Y-%H%M%S`"
cd ${WD}
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_HOST=hololive
export KBUILD_BUILD_USER="SuiseiKawaii"
}
function compile(){
START=$(date +"%s")
make -j$(nproc) O=out ARCH=arm64 ${CONFIG}
if [ "${COMPILER}" == "aosp-clang" ]; then
    make -j$(nproc) O=out CC="clang" CLANG_TRIPLE="aarch64-linux-gnu-"
elif [ "${COMPILER}" == "proton-clang" ]; then
    make -j$(nproc) O=out \
                CC=clang
               CROSS_COMPILE=aarch64-linux-gnu- \
               CROSS_COMPILE_ARM32=arm-linux-gnueabi-
else
    make -j$(nproc) O=out
fi
cp ${WD}/out/arch/arm64/boot/Image.gz-dtb ${WD}/AnyKernel
}
function zipKerne(){
DATE="`date +%d%m%H%M`"
cd "${WD}"/AnyKernel
if [ "${CONFIG}" == "whyred_defconfig" ]; then
zip -r9 personal-oldcam-radeas-${DATE}.zip *
elif [ "${CONFIG}" == "whyred-newcam_defconfig" ]; then
zip -r9 personal-newcam-radeas-${DATE}.zip *
elif [ "${CONFIG}" == "fakerad_defconfig" ]; then
zip -r9 personal-fakerad-${DATE}.zip *
fi
cd ..
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
curl -s -X POST "https://api.telegram.org/bot1628360095:AAF947lAXmKVaw9jRpx-CURb_wK2FZKl9z8/sendMessage" \
        -d chat_id="-1001214166550" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Started build ${DATE} using ${COMPILER}"
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
    --gcc10)
        COMPILER="gcc10"
        shift
        ;;
    --gcc-eva)
        GCC_BRANCH="gcc-eva"
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
    *)
        # unknown option
        echo "Unknown option(s)"
        exit
        ;;
    esac
done
