.PHONY: image-dev image-prod image-prod-dev

IMAGE_NAME=foodsoft
IMAGE_TAG:=latest

image-dev:
	docker buildx build --tag ${IMAGE_NAME}-rubocop:${IMAGE_TAG} --progress=plain --target=dev .

image-prod:
	docker buildx build --tag ${IMAGE_NAME}:${IMAGE_TAG} --no-cache --progress=plain --target=app .

image-prod-dev:
	docker buildx build --tag ${IMAGE_NAME}:${IMAGE_TAG} --progress=plain --target=app .

rubocop:
	docker run --rm -it -v ${PWD}:/work:ro --workdir /work foodsoft-rubocop bash
