# Utility makefile to prepare source directory

CHECKOUT = origin/master
REPOSITORY = https://github.com/just-containers/s6-overlay

OUT = ./overlay-rootfs
TMP = ./.tmp

.PHONY: ${TMP}/s6-overlay clean

sync: ${TMP}/s6-overlay/.git/config
	cd ${TMP}/s6-overlay && git fetch --all && git checkout --detach ${CHECKOUT}
	rm -rf ${OUT}
	cp -arv ${TMP}/s6-overlay/builder/overlay-rootfs ${OUT}
	cp -av scripts/prepare-files ${OUT}/

sync-commit: sync
	git add ${OUT}
	git commit ${OUT} -m "overlay-rootfs: updates build with $(shell git --git-dir=${TMP}/s6-overlay/.git describe --all --long)"

${TMP}/s6-overlay/.git/config:
	git clone ${REPOSITORY} ${TMP}/s6-overlay

