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

    {Image_Name}:{timestamp}{shortSHA}

Where:
- `Image_Name` is provided by the user as an input.
- `timestamp` is system generated and is YYYYMMDD
- `shortSHA` is the first 6 characters of the GitHub SHA that triggered the action.

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
        USERNAME: ${{ secrets.DOCKER_USERNAME }}
        PASSWORD: ${{ secrets.DOCKER_PASSWORD }}
        IMAGE_NAME: 'test-docker-action'
        DOCKERFILE_PATH: 'argo/gpu.Dockerfile'
        BUILD_CONTEXT: 'argo/'

    # This second step is illustrative and shows how to reference the 
    # output variables.  This is completely optional.
    - name: Show outputs of pervious step
      run: |
        echo "The name:tag of the Docker Image is: $VAR1"
        echo "The docker image is hosted at $VAR2"
      env:
        VAR1: ${{ steps.docker.outputs.IMAGE_SHA_NAME }}
        VAR2: ${{ steps.docker.outputs.IMAGE_URL }}
```

### Mandatory Arguments

1. `USERNAME` the login username, most likely your github handle.  This username must have write access to the repo where the action is called.
2. `PASSWORD` Your GitHub password that has write access to the repo where this action is called.
3. `IMAGE_NAME` is the name of the image you would like to push  
4. `DOCKERFILE_PATH`: The full path (including the filename) relative to the root of the repository that contains the Dockerfile that specifies your build.
5. `BUILD_CONTEXT`: The directory for the build context.  See these [docs](https://docs.docker.com/engine/reference/commandline/build/) for more information on the definition of build context.



## Outputs

You can reference the outputs of an action using [expression syntax](https://help.github.com/en/articles/contexts-and-expression-syntax-for-github-actions), as illustrated in the Example Pipeline above.

1. `IMAGE_SHA_NAME`: This is the `{Image_Name}:{timestamp}${shortSHA}` as described above.
2. `IMAGE_URL`: This is the URL on GitHub where you can view your hosted Docker images.  This will always be located at `https://github.com/{OWNER}/{REPOSITORY}/packages` in reference to the repository where the action was called.

These outputs are merely provided as convenience incase you want to use these values in subsequent steps.
