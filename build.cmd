echo Remove old and rebuild docuwrite-base image

echo first delete the previous image
docker rmi docuwrite-base -f

echo then build it from scratch
docker build --no-cache -t docuwrite-base .

echo test after build
docker run --rm docuwrite-base