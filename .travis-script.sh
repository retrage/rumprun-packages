#!/bin/bash


# upload built binaries to bintray
upload_binary_to_bintray() {
    local PUB_SUFFIX=$1

    # fixup arch name
    if [ $TRAVIS_ARCH == "amd64" ] ; then
	ARCH=amd64
    elif [ $TRAVIS_ARCH == "aarch64" ] ; then
	ARCH=arm
    fi

    if [ "${PACKAGE}" == "nginx" ]; then
	if [ -n "$PUB_SUFFIX" ] ; then
	    strip bin/nginx -o bin/nginx$PUB_SUFFIX
	fi
	curl -T bin/nginx$PUB_SUFFIX -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/nginx$PUB_SUFFIX;override=1&publish=1"
	curl -T images/data.iso -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/data.iso;override=1&publish=1"
    fi

    if [ "${PACKAGE}" == "python3" ]; then
	if [ "$TRAVIS_OS_NAME" == "osx" ]; then
	    EXESUFFIX=.exe
	fi

	if [ -n "$PUB_SUFFIX" ] ; then
	    strip build/python$EXESUFFIX -o build/python$EXESUFFIX$PUB_SUFFIX
	fi

	curl -T build/python$EXESUFFIX$PUB_SUFFIX -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/python$PUB_SUFFIX;override=1&publish=1"
	if [ "$TRAVIS_OS_NAME" == "linux" ] && [ "$TRAVIS_ARCH" == "amd64" ]; then
	    curl -T images/python.img -u$BINTRAY_USER:$BINTRAY_APIKEY \
		 "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/python.img;override=1&publish=1"
	fi

	curl -T images/python.iso -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/python.iso;override=1&publish=1"
    fi

    if [ "${PACKAGE}" == "netperf" ]; then
	if [ -n "$PUB_SUFFIX" ] ; then
	    strip build/src/netperf -o build/src/netperf$PUB_SUFFIX
	    strip build/src/netserver -o build/src/netserver$PUB_SUFFIX
	fi

	curl -T build/src/netperf -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/netperf$PUB_SUFFIX;override=1&publish=1"
	curl -T build/src/netserver -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/netserver$PUB_SUFFIX;override=1&publish=1"
    fi

    if [ "${PACKAGE}" == "sqlite-bench" ]; then
	if [ -n "$PUB_SUFFIX" ] ; then
	    strip bin/sqlite-bench -o bin/sqlite-bench$PUB_SUFFIX
	fi

	curl -T bin/sqlite-bench -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/sqlite-bench$PUB_SUFFIX;override=1&publish=1"
    fi

    if [ "${PACKAGE}" == "nodejs" ]; then
	if [ -n "$PUB_SUFFIX" ] ; then
	    strip bin/node -o bin/node$PUB_SUFFIX
	fi

	curl -T bin/node -u$BINTRAY_USER:$BINTRAY_APIKEY \
	     "https://api.bintray.com/content/ukontainer/ukontainer/rumprun-packages/dev/$TRAVIS_OS_NAME/$ARCH/node$PUB_SUFFIX;override=1&publish=1"
    fi
}


# Builds one specific package, specified by $PACKAGE
if [ -z "${PACKAGE}" ]; then
	echo "PACKAGE is not set"
	exit 1
fi

cd ${PACKAGE}
# Openjdk make should not be used with option -j
if [ "${PACKAGE}" == "openjdk8" ]; then
	make
else
	make -j2
	upload_binary_to_bintray
#	# create slim image
	make clean || true
	PATH=/opt/rump-tiny/bin:$PATH make -j2
	upload_binary_to_bintray "-slim"
fi
