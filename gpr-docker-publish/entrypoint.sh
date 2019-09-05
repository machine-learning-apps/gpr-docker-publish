#!/bin/sh

#Publish Docker Container To GitHub Package Registry
####################################################

# The following environment variables will be provided by the environment automatically: GITHUB_REPOSITORY, GITHUB_SHA

# send credentials through stdin (it is more secure)
echo ${INPUT_PASSWORD} | docker login -u ${INPUT_USERNAME} --password-stdin docker.pkg.github.com


# Set Local Variables
shortSha=$(echo "${GITHUB_SHA}" | cut -c1-6)
timestamp=`date +%Y%m%d%H%M%S`
BASE_NAME="docker.pkg.github.com/${GITHUB_REPOSITORY}/${INPUT_IMAGE_NAME}"
SHA_NAME="${BASE_NAME}:${timestamp}${shortSha}"

# Build The Container
docker build -t ${SHA_NAME} -t ${BASE_NAME} -f ${INPUT_DOCKERFILE_PATH} ${INPUT_BUILD_CONTEXT}

# Push two versions, with and without the SHA
docker push ${BASE_NAME}
docker push ${SHA_NAME}

echo "::set-output name=IMAGE_SHA_NAME::${BASE_NAME}"
echo "::set-output name=IMAGE_URL::https://github.com/${GITHUB_REPOSITORY}/packages"
