ARG PYTHON_BASE=${PYTHON_IMG_VER:-3.12-slim}
FROM python:${PYTHON_BASE}

RUN mkdir -p /project
RUN mkdir /kiwix-zims
RUN mkdir /transmission-completed

WORKDIR /project

COPY scripts/move_zims.py /project

CMD ["python", "move_zims.py", "--help"]
