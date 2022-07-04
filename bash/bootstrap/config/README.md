# configuring `abcli`

config files are carried through the seed and are mainly [excluded from git](./.gitignore) - create new copies based on [the given templates](./template) and fill up the files using the following instructions. 

## [abcli.sh](./abcli.sh)

`abcli_name` is the name that the cli replies to.

## [aws.json](./template/aws.json)

to complete the `rds` section create a database as follows:

1. go to `AWS Management Console` -> `RDS` -> `Create database`.

1. use `Standard Create` -> `MySQL` -> `MySQL 8.0.20` -> `Dev/Test`.

1. set `DB instance identifier` to `abcli`.

1. set `Credentials Settings` -> `Master username` and `Master Password` and update `host`, `username`, and `password` in the `rds` section of `aws.json`.

1. set `DB instance size` to `Burstable Classes` and select `db.t3.small`.

1. set `Storage` to `20` and disable `Storage autoscaling`.

1. in `Connectivity` set `Public Access` to `Yes`.

1. in `Additional Configuration` set `initial database name` to `abcli`.

## [git.sh](./template/git.sh)

`abcli_git_ssh_key_name` is the name of the git ssh key.
## [papertrail.sh](./template/papertrail.sh)

follow these steps to acquire the values for `abcli_papertrail_dest_host` and `abcli_papertrail_dest_port`.

1. login to [papertrail](https://papertrailapp.com/dashboard).

1. visit [Setup Logging](https://papertrailapp.com/systems/setup?type=app&platform=unix) and copy the destination port (`-p nnnnn`) and destination host (`-d logsx.papertrailapp.com`).

## ec2 key pair

follow [these instructions](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) to create a `.pem` file and then drop it in this folder - add the name of the key file to `aws.json` under `ec2->key_name`.