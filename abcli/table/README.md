# creating an rds instance

1. go to `AWS Management Console` -> `RDS` -> `Create database`.

1. use `Standard Create` -> `MySQL` -> `MySQL 8.0.20` -> `Dev/Test`

1. set `DB instance identifier` to `abcli`.

1. set `Credentials Settings` -> `Master username` and `Master Password` and update [info.json](../../assets/aws/info.json).

1. set `DB instance size` to `Burstable Classes` and select `db.t3.small`.

1. set `Storage` to `20` and disable `Storage autoscaling`.

1. in `Connectivity` set `Public Access` to `Yes`.

1. in `Additional Configuration` set `initial database name` to `abcli`.
