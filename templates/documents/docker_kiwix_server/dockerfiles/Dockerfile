ARG PYTHON_BASE=${PYTHON_IMG_VER:-3.12-slim}
FROM python:${PYTHON_BASE}

RUN python -m pip install --upgrade pip

RUN mkdir -p /project
RUN mkdir /kiwix-zims
RUN mkdir /transmission-torrents

WORKDIR /project

COPY scripts/move_zims.py /project
COPY scripts/docker_scheduled_mover.py /project

RUN pip install schedule

# CMD ["python", "move_zims.py", "--help"]
CMD ["python", "docker_scheduled_mover.py", "--zim-dir", "/kiwix-zims", "--torrent-dir", "/transmission-completed", "--print-env", "--ignore", ".part"]
