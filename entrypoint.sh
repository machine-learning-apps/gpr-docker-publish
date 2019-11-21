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

if [[ -z "$INPUT_IMAGE_NAME" && -z "$INPUT_DOCKERHUB_REPOSITORY" ]]; then
	echo "Set either the IMAGE_NAME or a valid DOCKERHUB_REPOSITORY."
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

if [[ -z "$INPUT_IMAGE_TAG" ]]; then
	IMAGE_TAG=$(echo "${GITHUB_SHA}" | cut -c1-12)
else
	IMAGE_TAG=$INPUT_IMAGE_TAG
fi

# The following environment variables will be provided by the environment automatically: GITHUB_REPOSITORY, GITHUB_SHA

if [[ -z "$INPUT_DOCKERHUB_REPOSITORY" ]]; then
  DOCKER_REGISTRY=docker.pkg.github.com
  BASE_NAME="${DOCKER_REGISTRY}/${GITHUB_REPOSITORY}/${INPUT_IMAGE_NAME}"
else
  BASE_NAME="${INPUT_DOCKERHUB_REPOSITORY}"
fi

# send credentials through stdin (it is more secure)
echo ${INPUT_PASSWORD} | docker login -u ${INPUT_USERNAME} --password-stdin ${DOCKER_REGISTRY}

# Set Local Variables
SHA_NAME="${BASE_NAME}:${IMAGE_TAG}"

# Build additional tags based on the GIT Tags pointing to the current commit
ADDITIONAL_TAGS=
for git_tag in $(git tag -l --points-at HEAD)
do
  echo "Processing ${git_tag}"
  ADDITIONAL_TAGS="${ADDITIONAL_TAGS} -t ${BASE_NAME}:${git_tag}"
done
echo "following additional tags will be created: ${ADDITIONAL_TAGS}"

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
docker build $BUILDPARAMS -t ${SHA_NAME} -t ${BASE_NAME}${ADDITIONAL_TAGS} -f ${INPUT_DOCKERFILE_PATH} ${INPUT_BUILD_CONTEXT}

# Push two versions, with and without the SHA
docker push ${BASE_NAME}
docker push ${SHA_NAME}

echo "::set-output name=IMAGE_SHA_NAME::${SHA_NAME}"
if [[ -z "$INPUT_DOCKERHUB_REPOSITORY" ]]; then
  echo "::set-output name=IMAGE_URL::https://github.com/${GITHUB_REPOSITORY}/packages"
else
  echo "::set-output name=IMAGE_URL::https://hub.docker.com/r/${INPUT_DOCKERHUB_REPOSITORY}"
fi
