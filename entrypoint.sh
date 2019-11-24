#!/bin/sh

#Publish Docker Container To GitHub Package Registry
####################################################

# exit when any command fails
set -e

#check inputs
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
user=$(curl -s -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user | jq -r .login)
echo ${GITHUB_TOKEN} | docker login docker.pkg.github.com -u "${user}" --password-stdin 

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
if [ "${INPUT_TAG}" ]; then
   CUSTOM_TAG="${BASE_NAME}:${INPUT_TAG}"
   docker build $BUILDPARAMS -t ${SHA_NAME} -t ${BASE_NAME} -t ${CUSTOM_TAG} -f ${INPUT_DOCKERFILE_PATH} ${INPUT_BUILD_CONTEXT}
   docker push ${CUSTOM_TAG}
else
   docker build $BUILDPARAMS -t ${SHA_NAME} -t ${BASE_NAME} -f ${INPUT_DOCKERFILE_PATH} ${INPUT_BUILD_CONTEXT}
fi


# Push two versions, with and without the SHA
docker push ${BASE_NAME}
docker push ${SHA_NAME}

echo "::set-output name=IMAGE_SHA_NAME::${SHA_NAME}"
echo "::set-output name=IMAGE_URL::https://github.com/${GITHUB_REPOSITORY}/packages"
