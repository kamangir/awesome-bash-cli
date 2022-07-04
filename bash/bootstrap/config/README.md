# config

config files are carried through the seed and are mainly [excluded from git](./.gitignore).

## aws.json

`aws.json` is excluded from git - create it using [aws_template.json](./aws_template.json) - to complete the `rds` section create a database as follows:

1. go to `AWS Management Console` -> `RDS` -> `Create database`.

1. use `Standard Create` -> `MySQL` -> `MySQL 8.0.20` -> `Dev/Test`.

1. set `DB instance identifier` to `abcli`.

1. set `Credentials Settings` -> `Master username` and `Master Password` and update `host`, `username`, and `password` in the `rds` section of `aws.json`.

1. set `DB instance size` to `Burstable Classes` and select `db.t3.small`.

1. set `Storage` to `20` and disable `Storage autoscaling`.

1. in `Connectivity` set `Public Access` to `Yes`.

1. in `Additional Configuration` set `initial database name` to `abcli`.