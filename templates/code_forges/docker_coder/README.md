# Coder

## Troubleshooting

### Fix tcp timeouts with Docker-in-Docker

If you get errors like this:

```log
coder  | 2025-10-12 21:05:28.689 [info]  provisionerd-11d65d8b4af3-0: unpacking template source archive  session_id=558519f1-5b8b-4802-87e2-1da5bea8a1f1  size_bytes=10240
coder  | 2025-10-12 21:05:31.721 [info]  provisionerd-11d65d8b4af3-0: clean stale Terraform plugins  cache_path=/home/coder/.cache/coder/provisioner-0/tf
coder  | 2025-10-12 21:05:42.288 [erro]  coderd.update_checker: init failed ...
coder  |     error= update check failed:
coder  |                github.com/coder/coder/v2/coderd/updatecheck.(*Checker).init
coder  |                    /home/runner/work/coder/coder/coderd/updatecheck/updatecheck.go:123
coder  |              - client do:
coder  |                github.com/coder/coder/v2/coderd/updatecheck.(*Checker).update
coder  |                    /home/runner/work/coder/coder/coderd/updatecheck/updatecheck.go:186
coder  |              - Get "https://api.github.com/repos/coder/coder/releases/latest": dial tcp: lookup api.github.com on 127.0.0.11:53: read udp 127.0.0.1:59501->127.0.0.11:53: i/o timeout
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="Error: Error accessing remote module registry"
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="  on main.tf line 125:"
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output=" 125: module \"code-server\" {"
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="Failed to retrieve available versions for module \"code-server\" (main.tf:125)"
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="from registry.coder.com: failed to request discovery document: Get"
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="\"https://registry.coder.com/.well-known/terraform.json\": net/http: request"
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="canceled while waiting for connection (Client.Timeout exceeded while awaiting"
coder  | 2025-10-12 21:05:51.752 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output=headers).
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="Error: Error accessing remote module registry"
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="  on main.tf line 137:"
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output=" 137: module \"jetbrains\" {"
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="Failed to retrieve available versions for module \"jetbrains\" (main.tf:137)"
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="from registry.coder.com: failed to request discovery document: Get"
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="\"https://registry.coder.com/.well-known/terraform.json\": dial tcp: lookup"
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="registry.coder.com on 127.0.0.11:53: read udp 127.0.0.1:48380->127.0.0.11:53:"
coder  | 2025-10-12 21:05:51.753 [erro]  provisionerd-11d65d8b4af3-0.runner: template import provision job logged  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  level=ERROR  output="i/o timeout."
coder  | 2025-10-12 21:05:51.754 [info]  provisionerd-11d65d8b4af3-0.runner: dry-run provision failure  job_id=c280e0d3-792b-43f6-a110-4fc77f166e47  error="initialize terraform: exit status 1"
coder  | 2025-10-12 21:05:51.758 [info]  provisionerd-11d65d8b4af3-0: recv done on Session  session_id=558519f1-5b8b-4802-87e2-1da5bea8a1f1
coder  | 2025-10-12 21:05:53.159 [warn]  coderd: GET  host=coder.mydomain.com  path=/api/v2/debug/health  proto=HTTP/1.1  remote_addr=172.20.0.1  start="2025-10-12T21:05:23.155975226Z"  response_body="{\"message\":\"Healthcheck is in progress and did not complete in time. Try again in a few seconds.\"}\n"  requestor_id=22259539-8408-4053-823f-3505071d2550  requestor_name=jackenyon  requestor_email=jackenyon@gmail.com  took=30.003968557s  status_code=503  latency_ms=30003  request_id=bebe173a-0fef-4a2c-b0d4-eb056f56f9db
```

Or see messages like this in the Coder webUI when trying to deploy a template:

```log
Initializing the backend...
Initializing modules...
Error: Error accessing remote module registry
  on main.tf line 125:
 125: module "code-server" {
Failed to retrieve available versions for module "code-server" (main.tf:125)
from registry.coder.com: failed to request discovery document: Get
"https://registry.coder.com/.well-known/terraform.json": net/http: request
canceled while waiting for connection (Client.Timeout exceeded while awaiting
headers).
Error: Error accessing remote module registry
  on main.tf line 137:
 137: module "jetbrains" {
Failed to retrieve available versions for module "jetbrains" (main.tf:137)
from registry.coder.com: failed to request discovery document: Get
"https://registry.coder.com/.well-known/terraform.json": dial tcp: lookup
registry.coder.com on 127.0.0.11:53: read udp 127.0.0.1:48380->127.0.0.11:53:
i/o timeout.
```

If you are on Fedora, try running the following commands:

```shell
sudo iptables -t nat -L POSTROUTING -n -v | grep docker0
sudo iptables -L FORWARD -n -v | grep docker0
sudo iptables -t nat -A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
sudo iptables -A FORWARD -i docker0 -o eth0 -j ACCEPT
sudo iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo systemctl restart docker
```
