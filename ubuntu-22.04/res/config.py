import os, pwd, subprocess, random, string

##################################################################################################
# These functions are used to provide advanced settings for JupyterHub
###############################

### Authenticate secret
def randomword(length):
   letters = string.ascii_lowercase
   return ''.join(random.choice(letters) for i in range(length))
###

### Spawn mode
def pre_spawn_hook(spawner):
    username = spawner.user.name
    try:
        pwd.getpwnam(username)
    except KeyError:
        subprocess.check_call(['useradd', '-ms', '/bin/bash', username])
        subprocess.check_call(['cp', '-TRv', '/etc/labs_portal/tutorials-notebooks/jupyter-cpp-kernel-doc', f'/home/{username}/jupyter-cpp-kernel-doc'])
        os.system(f'chown -R {username} /home/{username}/jupyter-cpp-kernel-doc')
###

##################################################################################################

c = get_config()

c.Authenticator.admin_users = {'administrator'}
c.Authenticator.enable_auth_state = False
c.Authenticator.auto_login_oauth2_authorize = False
c.Authenticator.manage_groups = True

c.Application.log_level = 'DEBUG'

c.ConfigurableHTTPProxy.auth_token = '/etc/labs_portal/proxy_auth_token'

c.PAMAuthenticator.admin_groups = {'administrators'}

c.JupyterHub.authenticator_class = 'nativeauthenticator.NativeAuthenticator'
c.JupyterHub.api_page_default_limit = 3
c.JupyterHub.cookie_secret_file = '/etc/labs_portal/cookie_secret'
c.JupyterHub.default_url = '/hub/home'
c.JupyterHub.db_url = 'sqlite:////etc//labs_portal//labs_portal.sqlite'
c.JupyterHub.debug_db = True
c.JupyterHub.port = 80
#c.JupyterHub.ssl_key = ########
#c.JupyterHub.ssl_cert = #########
c.JupyterHub.reset_db = False
c.JupyterHub.init_spawners_timeout = 300
c.JupyterHub.terminals_enabled = True
c.JupyterHub.template_paths = ['/etc/labs_portal/web/base']

c.NotebookApp.terminals_enabled = True

#----------------------------
# Native Authentication behaviour
c.NativeAuthenticator.check_common_password = True
c.NativeAuthenticator.minimum_password_length = 5
c.NativeAuthenticator.allowed_failed_logins = 5
c.NativeAuthenticator.seconds_before_next_try = 300
c.NativeAuthenticator.enable_signup = True
c.NativeAuthenticator.open_signup = True
c.NativeAuthenticator.ask_email_on_signup = True
#c.NativeAuthenticator.recaptcha_key = "your key"
#c.NativeAuthenticator.recaptcha_secret = "your secret"
c.NativeAuthenticator.allow_self_approval_for = '\b[A-Za-z0-9._%+-]+@(theflightsims\.tfs|theflightsims\.onmicrosoft\.com|google\.com|gmail\.com|outlook\.com|hotmail\.com|harvard\.edu)\b'
c.NativeAuthenticator.secret_key = randomword(44)
#c.NativeAuthenticator.self_approval_email = ("labs-portal-system@theflightsims.tfs", "[Labs Portal System] Activate your account", "Welcome to Labs Portal <3\n\nYour Labs Portal is just created, but not activated\nYou may need to activate by enter this activation URL into your domain where you registered: {approval_url}\n\nPlease ignore this email in case you have not registered: some one is trying to steal your credential to get an unauthorized account!\n\nHave a nice day,\nLabs Portal Team - by TheFlightSims.")
#c.NativeAuthenticator.self_approval_server = {'url': 'smtp.gmail.com', 'usr': 'myself', 'pwd': 'mypassword'}
c.NativeAuthenticator.tos = 'I agree to <a href="https://github.com/TheFlightSims/labs-portal/blob/master/LICENSE" target="_blank"><b>Labs Portal licensing terms (by TheFlightSims, and all related parties)</b></a>.'
#c.NativeAuthenticator.allow_2fa = True
#----------------------------

c.Spawner.cpu_limit = 1
c.Spawner.mem_limit = '1024M'
c.Spawner.pre_spawn_hook = pre_spawn_hook
