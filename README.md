![Actions Status](https://github.com/machine-learning-apps/gpr-docker-publish/workflows/Tests/badge.svg) [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/machine-learning-apps/gpr-docker-publish/blob/master/LICENSE)


## This Action Publishes Docker Images to the [GitHub Package Registry](https://github.com/features/package-registry).  

### Background On The GitHub Package Registry (GPR):

From [the docs](https://help.github.com/en/articles/configuring-docker-for-use-with-github-package-registry):

The GitHub Package Registry allows you to develop your code and host your packages in one place.  GitHub uses the README in your repository to generate the package's description, and you can edit it to reflect details about the package or installation process. GitHub adds metadata for each package version that includes links to the author, repository, commit SHA, version tags, and date.

[The docs](https://help.github.com/en/articles/configuring-docker-for-use-with-github-package-registry) also contain relevant such as how to authenticate and naming conventions.  Some noteable items about publishing Docker Images on GPR:

- Docker Images are tied to a repository.  
- All images are named with the following nomenclature:

    docker.pkg.github.com/{OWNER}/{REPOSITORY}/{IMAGE_NAME}:{TAG}
    
`OWNER` and `REPOSITORY` refer to a unique repository on GitHub, such as `tensorflow/tensorflow`.


## Automatic Tagging

This Action will automatically tag each image as follows:

    {Image_Name}:{IMAGE_TAG}

Where:
- `Image_Name` is provided by the user as an input.
- `IMAGE_TAG` is either the first 12 characters of the GitHub commit SHA or the value of INPUT_IMAGE_TAG env variable

Additionally it will use Git Tags pointing to the HEAD commit to create docker tags accordingly. 
E.g. Git Tag v1.1 will result in an additional docker tag v1.1.

## Usage




### Example Workflow That Uses This Action:
```yaml
name: Publish Docker image to GitHub Package Registry
on: push
jobs:
  build:
    runs-on: ubuntu-latest 
    steps:

    - name: Copy Repo Files
      uses: actions/checkout@master

     #This Action Emits 2 Variables, IMAGE_SHA_NAME and IMAGE_URL 
     #which you can reference in subsequent steps
    - name: Publish Docker Image to GPR
      uses: machine-learning-apps/gpr-docker-publish@master
      id: docker
      with:
        IMAGE_NAME: 'test-docker-action'
        TAG: 'my-optional-tag-name'
        DOCKERFILE_PATH: 'argo/gpu.Dockerfile'
        BUILD_CONTEXT: 'argo/'
      env:
        REGISTRY_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    #To access another docker registry like dockerhub you'll have to add `DOCKERHUB_UERNAME` and `DOCKERHUB_PAT` in github secrets.
    - name: Build and Publish Docker image to Dockerhub instead of GPR
      uses: saubermacherag/gpr-docker-publish@master
      with:
        IMAGE_TAG: 'v0.0'
        DOCKERFILE_PATH: '.github/docker/Dockerfile'
        BUILD_CONTEXT: './'
        DOCKERHUB_REPOSITORY: 'pinkrobin/gpr-docker-publish-example'
        DOCKERHUB_USERNAME: ${{ secrets.DOCKERHUB_USERNAME }}
      env:
        REGISTRY_TOKEN: ${{ secrets.DOCKERHUB_PAT }}

    # This second step is illustrative and shows how to reference the 
    # output variables.  This is completely optional.
    - name: Show outputs of previous step
      run: |
        echo "The name:tag of the Docker Image is: $VAR1"
        echo "The docker image is hosted at $VAR2"
      env:
        VAR1: ${{ steps.docker.outputs.IMAGE_SHA_NAME }}
        VAR2: ${{ steps.docker.outputs.IMAGE_URL }}
```

### Mandatory Inputs

1. `IMAGE_NAME` is the name of the image you would like to push  
2. `DOCKERFILE_PATH`: The full path (including the filename) relative to the root of the repository that contains the Dockerfile that specifies your build.
3. `BUILD_CONTEXT`: The directory for the build context.  See these [docs](https://docs.docker.com/engine/reference/commandline/build/) for more information on the definition of build context.

## Optional Inputs

1. `cache`: if value is `true`, attempts to use the last pushed image as a cache.  Default value is `false`.
2. `tag`: a custom tag you wish to assign to the image.
3. `DOCKERHUB_REPOSITORY`: if value is set, you don't need to set `IMAGE_NAME`. It will push the image to the given dockerhub repository instead of using GPR.
Why? Because Github Actions don't support downloading images without authentication at the moment. See: https://github.community/t5/GitHub-Actions/docker-pull-from-public-GitHub-Package-Registry-fail-with-quot/m-p/32782
4. `DOCKERHUB_USERNAME`: required when `DOCKERHUB_REPOSITORY` set to true.

## Outputs

You can reference the outputs of an action using [expression syntax](https://help.github.com/en/articles/contexts-and-expression-syntax-for-github-actions), as illustrated in the Example Pipeline above.

1. `IMAGE_SHA_NAME`: This is the `{Image_Name}:{IMAGE_TAG}` as described above.
2. `IMAGE_URL`: This is the URL on GitHub where you can view your hosted Docker images.  This will always be located at `https://github.com/{OWNER}/{REPOSITORY}/packages` in reference to the repository where the action was called.

These outputs are merely provided as convenience incase you want to use these values in subsequent steps.