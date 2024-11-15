from pathlib import Path
import shutil

def copy_dotenv():
    if not Path("{{ cookiecutter.template_shortname }}/.env").exists():
        if Path("{{ cookiecutter.template_shortname }}/.env.example").exists():
            shutil.copy2(src="{{ cookiecutter.template_shortname }}/.env.example", dst="{{ cookiecutter.template_shortname }}/.env")

if __name__ == "__main__":
    copy_dotenv()
