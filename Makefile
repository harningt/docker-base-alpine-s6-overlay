# Utility makefile to prepare source directory

CHECKOUT = master
REPOSITORY = https://github.com/just-containers/s6-overlay

OUT = ./overlay-rootfs
TMP = ./.tmp

.PHONY: ${TMP}/s6-overlay clean

sync: ${TMP}/s6-overlay/.git/config
	cd ${TMP}/s6-overlay && git fetch --all && git checkout ${CHECKOUT} && git pull
	rm -rf ${OUT}
	cp -arv ${TMP}/s6-overlay/builder/overlay-rootfs ${OUT}
	cp -av scripts/prepare-files ${OUT}/

${TMP}/s6-overlay/.git/config:
	git clone ${REPOSITORY} ${TMP}/s6-overlay

