echo "Preparing compilation toolchain for: $GUIX_ENVIRONMENT"

triplet=$1

if [ -z $triplet ]; then
    echo "-> ERROR Expecting triplet as argument"
    exit 1
fi

binutils=$(guix build -e "(begin (use-modules (gnu packages cross-base)) (cross-binutils \"$triplet\"))")
echo " - binutils path is $binutils"
export PATH=$PATH:$binutils/$triplet/bin/
export LIBRARY_PATH=$LIBRARY_PATH:$GUIX_ENVIRONMENT/lib
export INCLUDE_PATH=$INCLUDE_PATH:$GUIX_ENVIRONMENT/include

echo "NOTE: LIBRARY_PATH is kind of broken. Remember to add -L$GUIX_ENVIRONMENT/lib the gcc call"
echo "NOTE: crt1.o searching is broken for reasons beyond our understanding, add it by hand to the current dir"

echo "NOTE: looks like it works with --sysroot=$GUIX_ENVIRONMENT, but that's only valid if you have an environment"
