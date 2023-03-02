## docker compose exec -it mc-server mc-send-to-console give r3djak chest 6
import subprocess

class DockerCmd:

    def __init__(self, container_name, cmd):
        self.container_name = container_name
        self.cmd = cmd

    @property
    def command(self):
        command = self.cmd

        return command
    
    def print_cmd(self):
        print(f"Command: {self.command}")
        
    def run_cmd(self):
        cmd = self.command.split(" ")
        print(f"Command: {cmd}")

# restart_server = subprocess.run(["docker", "compose", "up", "-d"], check=True, stdout=subprocess.PIPE, text=True)
# print(f"Restart server exit code: {restart_server.returncode}")

container_name:str = "mc-server"
print(f"Container name: {container_name}")

cmd_base = f"docker compose exec -it {container_name} mc-send-to-console"
print(f"[DEBUG] cmd_base: {cmd_base}")

_player:str = input(f"Player name, without @ symbol:\n> ")
_item:str = input(f"Item ID (check Minecraft wiki):\n> ")
_quant:int = input(f"Give quantity:\n> ")

print(f"[DEBUG] Giving {_player} {_quant} of {_item}")

test_cmd = DockerCmd(container_name=container_name, cmd=f"{cmd_base} give {_player} {_item} {_quant}")

print(f"[DEBUG] test_cmd class instance: {test_cmd}")

print(f"Command: {test_cmd.command}")

print(f"Run: {test_cmd.run_cmd()}")
