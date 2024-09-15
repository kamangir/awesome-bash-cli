import os

from blue_options.env import load_config, load_env
from blue_objects.env import ABCLI_AWS_S3_BUCKET_NAME, ABCLI_AWS_S3_PREFIX

load_env(__name__)
load_config(__name__)


abcli_is_github_workflow = os.getenv("GITHUB_ACTIONS", "")

abcli_aws_ec2_default_image_name = os.getenv("abcli_aws_ec2_default_image_name", "")
abcli_aws_ec2_default_instance_type = os.getenv(
    "abcli_aws_ec2_default_instance_type", ""
)
abcli_aws_ec2_default_template = os.getenv("abcli_aws_ec2_default_template", "")
abcli_aws_ec2_image_id_abcli = os.getenv("abcli_aws_ec2_image_id_abcli", "")
abcli_aws_ec2_image_id_abcli_g4dn = os.getenv("abcli_aws_ec2_image_id_abcli_g4dn", "")
abcli_aws_ec2_image_id_bolt = os.getenv("abcli_aws_ec2_image_id_bolt", "")
abcli_aws_ec2_key_name = os.getenv("abcli_aws_ec2_key_name", "")
abcli_aws_ec2_security_group_ids = os.getenv("abcli_aws_ec2_security_group_ids", "")
abcli_aws_ec2_subnet_id = os.getenv("abcli_aws_ec2_subnet_id", "")
abcli_aws_ec2_templates_bolt = os.getenv("abcli_aws_ec2_templates_bolt", "")
abcli_aws_ec2_templates_bolt_gpu = os.getenv("abcli_aws_ec2_templates_bolt_gpu", "")

abcli_aws_s3_public_bucket_name = os.getenv("abcli_aws_s3_public_bucket_name", "")

abcli_blue_sbc_application = os.getenv("abcli_blue_sbc_application", "")

abcli_camera_diff = os.getenv("abcli_camera_diff", "")
abcli_camera_hi_res = os.getenv("abcli_camera_hi_res", "")
abcli_camera_rotation = os.getenv("abcli_camera_rotation", "")

abcli_display_fullscreen = os.getenv("abcli_display_fullscreen", "")

abcli_git_ssh_key_name = os.getenv("abcli_git_ssh_key_name", "")

abcli_gpu = os.getenv("abcli_gpu", "")

abcli_hardware_kind = os.getenv("abcli_hardware_kind", "")

abcli_messenger_recipients = os.getenv("abcli_messenger_recipients", "")


abcli_path_abcli = os.getenv("abcli_path_abcli", "")

abcli_papertrail_dest_host = os.getenv("abcli_papertrail_dest_host", "")
abcli_papertrail_dest_port = os.getenv("abcli_papertrail_dest_port", "")

abcli_plugins_must_have = os.getenv("abcli_plugins_must_have", "")

abcli_session_auto_upload = os.getenv("abcli_session_auto_upload", "")
abcli_session_imager_diff = os.getenv("abcli_session_imager_diff", "")
abcli_session_imager_enabled = os.getenv("abcli_session_imager_enabled", "")
abcli_session_imager_period = os.getenv("abcli_session_imager_period", "")
abcli_session_imager = os.getenv("abcli_session_imager", "")
abcli_session_messenger_period = os.getenv("abcli_session_messenger_period", "")
abcli_session_monitor_enabled = os.getenv("abcli_session_monitor_enabled", "")
abcli_session_object_tags = os.getenv("abcli_session_object_tags", "")
abcli_session_outbound_queue = os.getenv("abcli_session_outbound_queue", "")
abcli_session_reboot_period = os.getenv("abcli_session_reboot_period", "")
abcli_session_screen_period = os.getenv("abcli_session_screen_period", "")
abcli_session_temperature_period = os.getenv("abcli_session_temperature_period", "")
abcli_session = os.getenv("abcli_session", "")

abcli_youtube_api_key = os.getenv("abcli_youtube_api_key", "")

STABILITY_KEY = os.getenv("STABILITY_KEY", "")

VANWATCH_TEST_OBJECT = os.getenv("VANWATCH_TEST_OBJECT", "vanwatch-test-object-v2")

NGROK_AUTHTOKEN = os.getenv("NGROK_AUTHTOKEN", "")

COMFYUI_PASSWORD = os.getenv("COMFYUI_PASSWORD", "")

ABCLI_TEST_OBJECT = os.getenv("ABCLI_TEST_OBJECT", "")
