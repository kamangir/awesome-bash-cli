# config

config files are carried through the seed and are mainly [excluded from git](./.gitignore).

## [aws.json](./template/aws.json)

`aws.json` is excluded from git - create it using [template/aws.json](./template/aws.json) - to complete the `rds` section create a database as follows:

1. go to `AWS Management Console` -> `RDS` -> `Create database`.

1. use `Standard Create` -> `MySQL` -> `MySQL 8.0.20` -> `Dev/Test`.

1. set `DB instance identifier` to `abcli`.

1. set `Credentials Settings` -> `Master username` and `Master Password` and update `host`, `username`, and `password` in the `rds` section of `aws.json`.

1. set `DB instance size` to `Burstable Classes` and select `db.t3.small`.

1. set `Storage` to `20` and disable `Storage autoscaling`.

1. in `Connectivity` set `Public Access` to `Yes`.

1. in `Additional Configuration` set `initial database name` to `abcli`.

## [papertrail.sh](./template/papertrail.sh)

`papertrail.sh` is excluded from git - create it using [template/papertrail.sh](./template/papertrail.sh) - follow these steps to acquire the values for `abcli_papertrail_dest_host` and `abcli_papertrail_dest_port`.

1. login to [papertrail](https://papertrailapp.com/dashboard).

1. visit [Setup Logging](https://papertrailapp.com/systems/setup?type=app&platform=unix) and copy the destination port (`-p nnnnn`) and destination host (`-d logsx.papertrailapp.com`) - 
