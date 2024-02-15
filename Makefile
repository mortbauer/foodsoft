.PHONY: image-dev image-prod

IMAGE_NAME=foodsoft
IMAGE_TAG:=latest

image-dev:
	docker buildx build --tag ${IMAGE_NAME}:${IMAGE_TAG} --progress=plain --target=builder .

image-prod:
	docker buildx build --tag ${IMAGE_NAME}:${IMAGE_TAG} --no-cache --progress=plain --target=app .
