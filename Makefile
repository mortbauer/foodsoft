.PHONY: image-dev image-prod image-prod-dev

IMAGE_NAME=foodsoft
IMAGE_TAG:=latest
BUILD_ARGS:= --build-arg REVISION="$(shell git rev-parse HEAD)" --build-arg BUILDTIME="$(shell date --rfc-3339=seconds)"

image-dev:
	docker buildx build --tag ${IMAGE_NAME}-rubocop:${IMAGE_TAG} --progress=plain --target=dev .

image-prod:
	docker buildx build --tag ${IMAGE_NAME}:${IMAGE_TAG} --no-cache --progress=plain --target=app ${BUILD_ARGS} .

image-prod-dev:
	docker buildx build --tag ${IMAGE_NAME}:${IMAGE_TAG} --progress=plain --target=app ${BUILD_ARGS} .

rubocop:
	docker run --rm -it -v ${PWD}:/work:ro --workdir /work foodsoft-rubocop bash
