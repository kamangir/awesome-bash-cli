import os
from dotenv import load_dotenv

load_dotenv()

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

abcli_aws_rds_db = os.getenv("abcli_aws_rds_db", "")
abcli_aws_rds_host = os.getenv("abcli_aws_rds_host", "")
abcli_aws_rds_password = os.getenv("abcli_aws_rds_password", "")
abcli_aws_rds_port = os.getenv("abcli_aws_rds_port", "")
abcli_aws_rds_user = os.getenv("abcli_aws_rds_user", "")

abcli_aws_region = os.getenv("abcli_aws_region", "")
abcli_aws_s3_bucket_name = os.getenv("abcli_aws_s3_bucket_name", "")
abcli_aws_s3_prefix = os.getenv("abcli_aws_s3_prefix", "")
abcli_aws_s3_public_bucket_name = os.getenv("abcli_aws_s3_public_bucket_name", "")

abcli_blue_sbc_application = os.getenv("abcli_blue_sbc_application", "")

abcli_camera_diff = os.getenv("abcli_camera_diff", "")
abcli_camera_hi_res = os.getenv("abcli_camera_hi_res", "")
abcli_camera_rotation = os.getenv("abcli_camera_rotation", "")

abcli_display_fullscreen = os.getenv("abcli_display_fullscreen", "")

abcli_git_ssh_key_name = os.getenv("abcli_git_ssh_key_name", "")

abcli_gpu = os.getenv("abcli_gpu", "")

abcli_hardware_kind = os.getenv("abcli_hardware_kind", "")

abcli_hostname = os.getenv("abcli_hostname", "")

abcli_messenger_recipients = os.getenv("abcli_messenger_recipients", "")

HOME = os.getenv("HOME", "")
abcli_path_home = os.getenv("abcli_path_home", HOME)
abcli_path_storage = os.getenv(
    "abcli_path_storage",
    os.path.join(abcli_path_home, "storage"),
)
abcli_object_root = os.getenv(
    "abcli_object_root",
    os.path.join(abcli_path_storage, "abcli"),
)
abcli_object_name = os.getenv("abcli_object_name", "")
abcli_object_path = os.getenv("abcli_object_path", "")
abcli_path_git = os.getenv("abcli_path_git", "")
abcli_path_static = os.getenv("abcli_path_static", "")
abcli_path_abcli = os.getenv("abcli_path_abcli", "")
abcli_log_filename = os.getenv("abcli_log_filename", "")

abcli_publish_prefix = os.getenv("abcli_publish_prefix", "")

abcli_papertrail_dest_host = os.getenv("abcli_papertrail_dest_host", "")
abcli_papertrail_dest_port = os.getenv("abcli_papertrail_dest_port", "")

abcli_plugins = os.getenv("abcli_plugins", "")

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
abcli_ultralytics_api_key = os.getenv("abcli_ultralytics_api_key", "")
abcli_youtube_api_key = os.getenv("abcli_youtube_api_key", "")

abcli_wifi_ssid = os.getenv("abcli_wifi_ssid", "")

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")

STABILITY_KEY = os.getenv("STABILITY_KEY", "")
