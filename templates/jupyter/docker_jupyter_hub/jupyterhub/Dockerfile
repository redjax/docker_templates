FROM jupyterhub/jupyterhub:5.2.1

COPY jupyterhub_config.py .

RUN wget https://raw.githubusercontent.com/jupyterhub/jupyterhub/5.2.1/examples/cull-idle/cull_idle_servers.py

RUN pip install \
    dockerspawner \
    jhub_cas_authenticator
