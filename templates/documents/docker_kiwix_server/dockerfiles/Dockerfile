ARG PYTHON_BASE=${PYTHON_IMG_VER:-3.12-slim}
FROM python:${PYTHON_BASE} AS base

RUN python -m pip install --upgrade pip

FROM base AS mover

RUN mkdir -p /project
RUN mkdir /kiwix-zims
RUN mkdir /transmission-torrents

WORKDIR /project

COPY scripts/container_scripts/move_zims.py /project
COPY scripts/container_scripts/docker_scheduled_mover.py /project

RUN pip install schedule

# CMD ["python", "move_zims.py", "--help"]
CMD ["python", "docker_scheduled_mover.py", "--zim-dir", "/kiwix-zims", "--torrent-dir", "/transmission-completed", "--print-env", "--ignore", ".part"]

FROM base AS torrent_mgr

RUN mkdir -p /project

COPY scripts/container_scripts/torrents_mgr.py /project
COPY scripts/container_scripts/docker_scheduled_rm_finished_torrents.py /project

RUN pip install transmission-rpc schedule

CMD ["python", "docker_scheduled_rm_finished_torrents.py", "--help"]
