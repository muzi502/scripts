#!/bin/bash
REGISTRY_DIR=$1
REGISTRY_DIR=${REGISTRY_DIR:="/var/lib/registry"}
BLOB_DIR="docker/registry/v2/blobs/sha256"
REPO_DIR="docker/registry/v2/repositories"
OUTPUT_LOG="/tmp/registry_blobs.log"

:> ${OUTPUT_LOG}
cd ${REGISTRY_DIR}

for image in $(find ${REPO_DIR} -type d -name '_manifests'); do
    image_blobs=""
    for tag in $(find ${image} -type d -name 'current'); do
        manifest_sha256=$(sed 's/sha256://' ${tag}/link)
        echo ${manifest_sha256} >> ${OUTPUT_LOG}
        manifest="${BLOB_DIR}/${manifest_sha256:0:2}/${manifest_sha256}/data"
        image_blobs=$(sed '/v1Compatibility/d' ${manifest} | grep -Eo '\b[a-f0-9]{64}\b' | sort -u)
        echo ${image_blobs} | tr ' ' '\n' >> ${OUTPUT_LOG}
    done
    for link in $(find ${image/_manifests/_layers} -type f -name 'link'); do
        link_sha256=$(grep -Eo '\b[a-f0-9]{64}\b' ${link})
        if [[ ! "${image_blobs}" =~ "${link_sha256}" ]]; then
            rm -rf ${link/link/}
        fi
    done
done

# use shell to gc instead /bin/registry garbage-collect command
for blob in $(find ${BLOB_DIR} -name "data" | grep -Eo '\b[a-f0-9]{64}\b'); do
    if ! grep ${all_blobs} ${OUTPUT_LOG}; then
        rm -rf ${BLOB_DIR}/${blob:0:2}/${blob}
    fi
done
