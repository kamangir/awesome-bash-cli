from abcli.help.generic import help_functions as generic_help_functions
from abcli.help.actions import help_perform_action
from abcli.help.assets import help_functions as help_assets
from abcli.help.aws_batch import help_functions as help_aws_batch
from abcli.help.blueness import help_blueness
from abcli.help.browse import help_browse
from abcli.help.conda import help_functions as help_conda
from abcli.help.clone import help_clone
from abcli.help.docker import help_functions as help_docker
from abcli.help.download import help_download
from abcli.help.env import help_functions as help_env
from abcli.help.eval import help_eval
from abcli.help.gif import help_gif
from abcli.help.git import help_functions as help_git
from abcli.help.gpu import help_functions as help_gpu
from abcli.help.host import help_functions as help_host
from abcli.help.init import help_init
from abcli.help.instance import help_functions as help_instance
from abcli.help.latex import help_functions as help_latex
from abcli.help.logging import help_cat
from abcli.help.logging import help_functions as help_log
from abcli.help.list import help_functions as help_list
from abcli.help.ls import help_ls
from abcli.help.metadata import help_functions as help_metadata
from abcli.help.mlflow import help_functions as help_mlflow
from abcli.help.notebooks import help_functions as help_notebooks
from abcli.help.object import help_functions as help_object
from abcli.help.open import help_open
from abcli.help.papertrail import help_functions as help_papertrail
from abcli.help.pause import help_pause
from abcli.help.plugins import help_functions as help_plugins
from abcli.help.publish import help_functions as help_publish
from abcli.help.repeat import help_repeat
from abcli.help.sagemaker import help_functions as help_sagemaker
from abcli.help.seed import help_functions as help_seed
from abcli.help.select import help_select
from abcli.help.session import help_functions as help_session
from abcli.help.storage import help_functions as help_storage
from abcli.help.sleep import help_sleep
from abcli.help.source import (
    help_source_caller_suffix_path,
    help_source_path,
)
from abcli.help.ssm import help_functions as help_ssm
from abcli.help.terminal import help_badge
from abcli.help.terraform import help_functions as help_terraform
from abcli.help.upload import help_upload
from abcli.help.watch import help_watch

help_functions = generic_help_functions(plugin_name="abcli")


help_functions.update(
    {
        "assets": help_assets,
        "aws_batch": help_aws_batch,
        "badge": help_badge,
        "blueness": help_blueness,
        "browse": help_browse,
        "cat": help_cat,
        "clone": help_clone,
        "conda": help_conda,
        "docker": help_docker,
        "download": help_download,
        "env": help_env,
        "eval": help_eval,
        "gif": help_gif,
        "git": help_git,
        "gpu": help_gpu,
        "host": help_host,
        "init": help_init,
        "instance": help_instance,
        "latex": help_latex,
        "log": help_log,
        "list": help_list,
        "ls": help_ls,
        "metadata": help_metadata,
        "mlflow": help_mlflow,
        "notebooks": help_notebooks,
        "object": help_object,
        "open": help_open,
        "pause": help_pause,
        "perform_action": help_perform_action,
        "plugins": help_plugins,
        "publish": help_publish,
        "repeat": help_repeat,
        "sagemaker": help_sagemaker,
        "seed": help_seed,
        "select": help_select,
        "sleep": help_sleep,
        "session": help_session,
        "storage": help_storage,
        "source_caller_suffix_path": help_source_caller_suffix_path,
        "source_path": help_source_path,
        "ssm": help_ssm,
        "terraform": help_terraform,
        "trail": help_papertrail,
        "upload": help_upload,
        "watch": help_watch,
    }
)
