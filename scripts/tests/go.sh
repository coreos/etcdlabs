#!/usr/bin/env bash
set -e

if ! [[ "$0" =~ "./scripts/tests/go.sh" ]]; then
    echo "must be run from repository root"
    exit 255
fi

IGNORE_PKGS="(vendor)"
TESTS=`find . -name \*_test.go | while read a; do dirname $a; done | sort | uniq | egrep -v "$IGNORE_PKGS"`

echo "Checking gofmt..."
fmtRes=$(gofmt -l -s -d $TESTS)
if [ -n "${fmtRes}" ]; then
	echo -e "gofmt checking failed:\n${fmtRes}"
	exit 255
fi
echo "Checking govet..."
vetRes=$(go vet $TESTS 2>&1 >/dev/null)
if [ -n "${vetRes}" ]; then
	echo -e "govet checking failed:\n${vetRes}"
	exit 255
fi

# TODO: run with multi-CPU (not right now because of port conflict)
echo "Running tests..."
go test -v $TESTS  -logtostderr

echo "Success"
