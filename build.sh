set -x

ver="1.7.6"
img="starina/nginx_nginx-ui"
latesttag="test"
latesttag="latest"

docker build --network host -t ${img}:${ver} -t ${img}:${latesttag} . \
&& docker push ${img}:${ver} \
&& docker push ${img}:${latesttag}

