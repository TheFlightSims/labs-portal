from pwd import getpwnam
from subprocess import check_call

class DefaultSpawner:
    def_shell = "/bin/bash"
    
    def __init__(self):
        def_shell = self.def_shell
    
    def pre_spawn_hook(self, spawner):
        username = spawner.user.name
        try:
            getpwnam(username)
        except KeyError:
            check_call(["useradd", "-ms", self.def_shell, username])
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
