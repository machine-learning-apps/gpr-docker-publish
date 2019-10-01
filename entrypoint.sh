#!/bin/sh

#Publish Docker Container To GitHub Package Registry
####################################################

# exit when any command fails
set -e

#check inputs
if [[ -z "$INPUT_USERNAME" ]]; then
	echo "Set the USERNAME input."
	exit 1
fi

if [[ -z "$INPUT_PASSWORD" ]]; then
	echo "Set the PASSWORD input."
	exit 1
fi

if [[ -z "$INPUT_IMAGE_NAME" ]]; then
	echo "Set the IMAGE_NAME input."
	exit 1
fi

if [[ -z "$INPUT_DOCKERFILE_PATH" ]]; then
	echo "Set the DOCKERFILE_PATH input."
	exit 1
fi

if [[ -z "$INPUT_BUILD_CONTEXT" ]]; then
	echo "Set the BUILD_CONTEXT input."
	exit 1
fi


# The following environment variables will be provided by the environment automatically: GITHUB_REPOSITORY, GITHUB_SHA

# send credentials through stdin (it is more secure)
echo ${INPUT_PASSWORD} | docker login -u ${INPUT_USERNAME} --password-stdin docker.pkg.github.com

# Set Local Variables
shortSHA=$(echo "${GITHUB_SHA}" | cut -c1-12)
BASE_NAME="docker.pkg.github.com/${GITHUB_REPOSITORY}/${INPUT_IMAGE_NAME}"
SHA_NAME="${BASE_NAME}:${shortSHA}"

# Add Arguments For Caching
BUILDPARAMS=""
if [ "${INPUT_CACHE}" == "true" ]; then
   # try to pull container if exists
   if docker pull ${BASE_NAME} 2>/dev/null; then
      echo "Attempting to use ${BASE_NAME} as build cache."
      BUILDPARAMS=" --cache-from ${BASE_NAME}"
   fi
fi

# Build The Container
docker build $BUILDPARAMS -t ${SHA_NAME} -t ${BASE_NAME} -f ${INPUT_DOCKERFILE_PATH} ${INPUT_BUILD_CONTEXT}

# Push two versions, with and without the SHA
docker push ${BASE_NAME}
docker push ${SHA_NAME}

echo "::set-output name=IMAGE_SHA_NAME::${SHA_NAME}"
echo "::set-output name=IMAGE_URL::https://github.com/${GITHUB_REPOSITORY}/packages"
