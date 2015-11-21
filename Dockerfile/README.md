#base image
for img in centos:7.1.1503 nginx:1.9.4 mongo:2.6 redis:2.6
do
	docker pull $img
done
