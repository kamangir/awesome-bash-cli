import boto3
from typing import Any, Tuple
from botocore.exceptions import ClientError

from blueness import module
from blue_objects.env import ABCLI_AWS_REGION

from abcli import NAME
from abcli import env
from abcli.logger import logger

NAME = module.name(__file__, NAME)


def get_secret(secret_name: str) -> Tuple[bool, str]:
    client = boto3.client(
        service_name="secretsmanager",
        region_name=ABCLI_AWS_REGION,
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name,
        )
    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceNotFoundException":
            # If the secret does not exist
            return True, ""
        return False, f"error:{e}"
    except Exception as e:
        return False, f"error:{e}"

    return True, get_secret_value_response.get(
        "SecretString",
        "unknown",
    )


def put_secret(
    secret_name: str,
    secret_value: str,
    description: str = "",
) -> Tuple[bool, Any]:
    if not description:
        description = f"secret managed by {NAME}.put_secret()"

    client = boto3.client(
        "secretsmanager",
        region_name=ABCLI_AWS_REGION,
    )

    try:
        # Check if the secret already exists
        _ = client.describe_secret(SecretId=secret_name)
        # If secret exists, update it
        response = client.update_secret(
            SecretId=secret_name,
            SecretString=secret_value,
            Description=description,
        )
        logger.info(f"{NAME}.put_secret: {secret_name} updated.")
    except ClientError as e:
        if e.response["Error"]["Code"] == "ResourceNotFoundException":
            # If the secret does not exist, create it
            response = client.create_secret(
                Name=secret_name,
                SecretString=secret_value,
                Description=description,
            )
            logger.info(f"{NAME}.put_secret: {secret_name} updated.")
        else:
            logger.error(f"{NAME}.put_secret({secret_name}): AWS Client Error: {e}")
            return False, {}
    except Exception as e:
        logger.error(f"{NAME}.put_secret({secret_name}): error: {e}.")
        return False, {}

    return True, response


def rm_secret(secret_name: str) -> Tuple[bool, Any]:
    client = boto3.client(
        "secretsmanager",
        region_name=ABCLI_AWS_REGION,
    )

    try:
        response = client.delete_secret(
            SecretId=secret_name,
            ForceDeleteWithoutRecovery=True,
        )
        logger.info(f"{NAME}.rm_secret: {secret_name} deleted.")
    except ClientError as e:
        logger.error(f"{NAME}.rm_secret({secret_name}): AWS Client Error: {e}")
        return False, {}
    except Exception as e:
        logger.error(f"{NAME}.rm_secret({secret_name}): error: {e}.")
        return False, {}

    return True, response
