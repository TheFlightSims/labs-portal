from os import environ
from dotenv import load_dotenv
from pwd import getpwnam
from random import choice
from subprocess import check_call
from string import ascii_lowercase
from pathlib import Path
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

#################################################################################################
# Initial loading
env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=env_path)
##################################################################################################

##################################################################################################
# These are the global variables for configuration
###############################

connection_url = URL.create(
    "mssql+pyodbc",
    username=environ.get("JHUB_MSSQL_USER"),
    password=environ.get("JHUB_MSSQL_PASSWORD"),
    host=environ.get("JHUB_MSSQL_HOST"),
    port=1433,
    database=environ.get("JHUB_MSSQL_DATABASE"),
    query={
        "driver": "ODBC Driver 18 for SQL Server",
        "Encrypt": "yes",
        "TrustServerCertificate": "yes",
    },
)

pub_key = environ.get("JHUB_PUB_KEY", "/etc/labs_portal/ssl/labs_portal.key")
pri_key = environ.get("JHUB_PRI_CERT", "/etc/labs_portal/ssl/labs_portal.crt")

proxy_auth_token = environ.get(
    "JHUB_PROXY_AUTH_TOKEN", "/etc/labs_portal/proxy_auth_token"
)

cookie_secret = environ.get("JHUB_COOKIE_SECRET", "/etc/labs_portal/cookie_secret")

def_shell = environ.get("JHUB_DEFAULT_SHELL", "/bin/bash")

def_allowed_users = environ.get("JHUB_ALLOWED_USERS")
def_admin_users = environ.get("JHUB_ADMIN_USERS")
def_admin_group = environ.get("JHUB_ADMIN_GROUP")

cpu_limit = int(environ.get("JHUB_CPU_LIMIT", "1"))
mem_limit = environ.get("JHUB_MEM_LIMIT", "1024M")

#################################################################################################

##################################################################################################
# These functions are used to provide advanced settings for JupyterHub
###############################

# Authenticate secret
def randomword(length):
    str = ""

    letters = ascii_lowercase
    for i in range(length):
        str += choice(letters)

    return str

# Spawn mode
def pre_spawn_hook(spawner):
    username = spawner.user.name
    try:
        getpwnam(username)
    except KeyError:
        check_call(["useradd", "-ms", def_shell, username])
        check_call(
            [
                "cp",
                "-TRv",
                "/etc/labs_portal/tutorials-notebooks/jupyter-cpp-kernel-doc",
                f"/home/{username}/jupyter-cpp-kernel-doc",
            ]
        )
        check_call(
            ["chown", "-R", username, f"/home/{username}/jupyter-cpp-kernel-doc"]
        )
        check_call(
            ["chmod", "-R", "u+rwX,go-rwx", f"/home/{username}/jupyter-cpp-kernel-doc"]
        )

##################################################################################################
# This config is updated for JupyterHub 5.3.0 and enhanced security
c = get_config()

c.Authenticator.allowed_users = {def_allowed_users}
c.Authenticator.admin_users = {def_admin_users}
c.Authenticator.enable_auth_state = False
c.Authenticator.auto_login_oauth2_authorize = False
c.Authenticator.manage_groups = False

c.Application.log_level = "DEBUG"

c.ConfigurableHTTPProxy.auth_token = proxy_auth_token

c.PAMAuthenticator.admin_groups = {def_admin_group}

c.JupyterHub.authenticator_class = "nativeauthenticator.NativeAuthenticator"
c.JupyterHub.api_page_default_limit = 3
c.JupyterHub.cookie_secret_file = cookie_secret
# c.JupyterHub.default_url = '/hub/home'

c.JupyterHub.db_url = f"mysql://{mysql_user}:{mysql_password}@{mysql_server}/{mysql_database}?charset=utf8mb4"

c.JupyterHub.debug_db = False

c.JupyterHub.port = 443

# For secure deployment, set valid absolute paths for SSL certificates
c.JupyterHub.ssl_key = pri_key
c.JupyterHub.ssl_cert = pub_key

c.JupyterHub.reset_db = False
c.JupyterHub.init_spawners_timeout = 300
c.JupyterHub.terminals_enabled = False
c.JupyterHub.template_paths = ["/etc/labs_portal/web/base"]

c.NotebookApp.terminals_enabled = False

c.NativeAuthenticator.check_common_password = True
c.NativeAuthenticator.minimum_password_length = 5
c.NativeAuthenticator.allowed_failed_logins = 5
c.NativeAuthenticator.seconds_before_next_try = 300
c.NativeAuthenticator.enable_signup = True
c.NativeAuthenticator.open_signup = True
c.NativeAuthenticator.ask_email_on_signup = False
# c.NativeAuthenticator.allow_self_approval_for = r'\b[A-Za-z0-9._%+-]+@(homelab\.local|)\b'
c.NativeAuthenticator.secret_key = randomword(44)
c.NativeAuthenticator.allow_2fa = True

c.Spawner.cpu_limit = cpu_limit
c.Spawner.mem_limit = mem_limit
c.Spawner.pre_spawn_hook = pre_spawn_hook
