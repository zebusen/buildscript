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
export KBUILD_COMPILER_STRING="${COMPILER_STRING}
# END ///////////////////////////////
}
function cloneAK(){
git clone --depth=1 https://github.com/Reinazhard/AnyKernel3 AnyKernel
}
function initialize(){
TGtoken=$TELEGRAM_TOKEN
WD=$(pwd)
DATE="`date +%d%m%Y-%H%M%S`"
START=$(date +"%s")
cd ${WD}
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_HOST=hololive
export KBUILD_BUILD_USER="SuiseiKawaii"
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
