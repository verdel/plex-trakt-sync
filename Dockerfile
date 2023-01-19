FROM python:3-alpine as build
ARG TAG=0.25.11

RUN apk add git curl

WORKDIR /app

RUN git -c advice.detachedHead=false clone --quiet --depth 1 --branch $TAG https://github.com/Taxel/PlexTraktSync.git . \
    && find . -maxdepth 1 ! -name plextraktsync -type d -not -path '.' -exec rm -rf {} + \
    && find . -maxdepth 1 ! -name requirements.txt -type f -not -path '.' -exec rm -rf {} + \
    && echo "j2cli[yaml]" >> requirements.txt \
    && pip3 install --no-cache-dir --target=dependencies -r requirements.txt \
    && curl -L https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o /app/dependencies/bin/jq \
    && chmod +x /app/dependencies/bin/jq

FROM python:3-alpine

COPY --from=build --chown=nobody:nobody app app
COPY --chown=nobody:nobody conf/ /app/conf_templates
COPY --chown=nobody:nobody --chmod=0750 start.sh /

ENV PYTHONPATH="${PYTHONPATH}:/app/dependencies"
ENV PATH="${PATH}:/app/dependencies/bin"

USER nobody:nobody

ENTRYPOINT [ "/start.sh" ]