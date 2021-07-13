FROM python:3-alpine as build
ARG TAG

RUN apk add git

WORKDIR /app

RUN git -c advice.detachedHead=false clone --quiet --depth 1 --branch $TAG https://github.com/Taxel/PlexTraktSync.git . \
    && echo "j2cli[yaml]" >> requirements.txt \
    && pip3 install --no-cache-dir --target=dependencies -r requirements.txt

FROM python:3-alpine

COPY --from=build --chown=nobody:nobody app app
COPY --chown=nobody:nobody conf/ /app/conf_templates
COPY --chown=nobody:nobody --chmod=0750 start.sh /

ENV PYTHONPATH="${PYTHONPATH}:/app/dependencies"
ENV PATH="${PATH}:/app/dependencies/bin"

USER nobody:nobody

ENTRYPOINT [ "/start.sh" ]