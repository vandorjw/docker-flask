# docker-flask

To test locally
```
docker build .
```

```
docker run -it -e GUNICORN_CMD_ARGS="--bind=0.0.0.0" <image-id>
```
