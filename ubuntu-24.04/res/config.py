from os import environ, system
from dotenv import load_dotenv
from pwd import getpwnam
from random import choice
from subprocess import check_call
from string import ascii_lowercase
from pathlib import Path

env_path = Path(__file__).parent / ".env"
load_dotenv(dotenv_path=env_path)

##################################################################################################
# These functions are used to provide advanced settings for JupyterHub
###############################

### Authenticate secret
def randomword(length):
    letters = ascii_lowercase
    return ''.join(choice(letters) for i in range(length))
###

### Spawn mode
def pre_spawn_hook(spawner):
    username = spawner.user.name
    try:
        getpwnam(username)
    except KeyError:
        check_call(['useradd', '-ms', '/bin/bash', username])
        check_call(['cp', '-TRv', '/etc/labs_portal/tutorials-notebooks/jupyter-cpp-kernel-doc', f'/home/{username}/jupyter-cpp-kernel-doc'])
        check_call(['chown','-R',username,f'/home/{username}/jupyter-cpp-kernel-doc'])
        check_call(['chmod','-R','u+rwX,go-rwx',f'/home/{username}/jupyter-cpp-kernel-doc'])
###

##################################################################################################
# This config is updated for JupyterHub 5.3.0 and enhanced security
c = get_config()

c.Authenticator.allowed_users = {'administrator'}
c.Authenticator.admin_users = {'administrator'}
c.Authenticator.enable_auth_state = False
c.Authenticator.auto_login_oauth2_authorize = False
c.Authenticator.manage_groups = False

c.Application.log_level = 'DEBUG'

c.ConfigurableHTTPProxy.auth_token = '/etc/labs_portal/proxy_auth_token'

c.PAMAuthenticator.admin_groups = {'administrators'}

c.JupyterHub.authenticator_class = 'nativeauthenticator.NativeAuthenticator'
c.JupyterHub.api_page_default_limit = 3
c.JupyterHub.cookie_secret_file = '/etc/labs_portal/cookie_secret'
# c.JupyterHub.default_url = '/hub/home'

# Connect to local MySQL using credentials from the .env file.
mysql_user = environ.get("JHUB_MYSQL_USER")
mysql_password = environ.get("JHUB_MYSQL_PASSWORD")
mysql_database = environ.get("JHUB_MYSQL_DATABASE")
c.JupyterHub.db_url = f'mysql://{mysql_user}:{mysql_password}@localhost/{mysql_database}?charset=utf8mb4'

c.JupyterHub.debug_db = False

c.JupyterHub.port = 443

# For secure deployment, set valid absolute paths for SSL certificates
c.JupyterHub.ssl_key = environ.get("JHUB_SSL_KEY")
c.JupyterHub.ssl_cert = environ.get("JHUB_SSL_CERT")

c.JupyterHub.reset_db = False
c.JupyterHub.init_spawners_timeout = 300
c.JupyterHub.terminals_enabled = False
# c.JupyterHub.template_paths = ['/etc/labs_portal/web/base']

c.NotebookApp.terminals_enabled = False

c.NativeAuthenticator.check_common_password = True
c.NativeAuthenticator.minimum_password_length = 5
c.NativeAuthenticator.allowed_failed_logins = 5
c.NativeAuthenticator.seconds_before_next_try = 300
c.NativeAuthenticator.enable_signup = True
c.NativeAuthenticator.open_signup = True
c.NativeAuthenticator.ask_email_on_signup = False
c.NativeAuthenticator.allow_self_approval_for = r'\b[A-Za-z0-9._%+-]+@(homelab\.local|)\b'
c.NativeAuthenticator.secret_key = randomword(44)
c.NativeAuthenticator.allow_2fa = True

c.Spawner.cpu_limit = 1
c.Spawner.mem_limit = '1024M'
c.Spawner.pre_spawn_hook = pre_spawn_hook
