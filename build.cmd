echo Remove old and rebuild docuwrite image

echo first delete the previous image
docker rmi docuwrite -f

echo then build it from scratch
docker build --no-cache -t docuwrite .

echo test after build
docker run --rm docuwrite