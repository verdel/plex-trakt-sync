FROM python:3-alpine as build
ARG TAG

RUN apk add git

WORKDIR /app

RUN git clone --depth 1 --branch $TAG https://github.com/Taxel/PlexTraktSync.git .
RUN echo "j2cli[yaml]" >> /app/requirements.txt
RUN pip3 install --no-cache-dir --target=/app/dependencies -r requirements.txt

FROM python:3-alpine
WORKDIR /app

COPY --from=build --chown=65534:65534 /app /app
COPY --chown=65534:65534 conf/ /app/conf_templates
COPY --chown=65534:65534 --chmod=0750 start.sh /
ENV PYTHONPATH="${PYTHONPATH}:/app/dependencies"
ENV PATH="${PATH}:/app/dependencies/bin"

ENTRYPOINT [ "/start.sh" ]