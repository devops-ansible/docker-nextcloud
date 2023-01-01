# Docker image: NextCloud

## About this repository

This repository holds the definition of customized NextCloud Docker images.

The main improvement of this image is, that basic `./occ` actions that are needed after an update are executed unattended. For what actions are executed automatically, please have a look at `files/boot.d/nextcloud/01_occ.sh`.

There are two images built on a regular basis:

### The `latest` tagged image

Compared to the original image `nextcloud:apache` this image contains only the extension with bootup scripts.

### The `full` tagged image

NextCloud publishes some extended Dockerfile examples [with their Git repository](https://github.com/nextcloud/docker/tree/master/.examples/dockerfiles). From there, the variant `full` is built as the basis for this image and the bootup scripts are added afterwards.

## Environmental variables to be used

| ENV Variable | Default Value | Description |
| ------------ | ------------- | ----------- |
| `NC_APPS`    | `calendar contacts` | List of applications to be checked for installed and enabled status on bootup – space separated! |
| `DISABLE_CHOWN` | | set to `true`, if chown should be skipped at bootup |
| `CHOWN_DEBUG` | | set to `true`, if chown should be run with debugging activated |

There do exist more environmental variables – but those are not recommended to be changed at all.

## License

This project is published unter [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/) license.

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## last built

2023-01-01 23:35:04
