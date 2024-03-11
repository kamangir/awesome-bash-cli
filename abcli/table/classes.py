import os
import os.path
import pymysql
from abcli import env
from abcli import file
from abcli.table import NAME
from abcli.logger import logger, crash_report


class Table:
    def __init__(self, name):
        self.name = name

        self.db = env.ABCLI_AWS_RDS_DB
        self.host = env.ABCLI_AWS_RDS_HOST
        self.password = env.ABCLI_AWS_RDS_PASSWORD
        self.port = int(env.ABCLI_AWS_RDS_PORT)
        self.user = env.ABCLI_AWS_RDS_USER

        self.connection = None

    def connect(self, create_command=""):
        """connect to self.

        Args:
            create_command (str, optional): create command. Defaults to "".

        Returns:
            bool: success.
        """
        if self.connection is not None:
            self.disconnect()

        try:
            self.connection = pymysql.connect(
                self.host,
                user=self.user,
                port=self.port,
                passwd=self.password,
                db=self.db,
            )
        except:
            crash_report(f"-{NAME}: connect: failed.")
            return False

        return True if not create_command else self.create(create_command)

    @staticmethod
    def Create(table_name, create_command):
        """create table_name.

        Args:
            table_name (str): table name.
            create_command (List[str]): create command.

        Returns:
            bool: success
        """
        table = Table(name=table_name)

        return table.disconnect() if table.connect(create_command) else False

    def create(self, create_command):
        """create self.

        Args:
            create_command (List[str]): create command.

        Returns:
            bool: success.
        """
        return self.execute(
            "CREATE TABLE IF NOT EXISTS {} ({})".format(
                self.name,
                ",".join(
                    [
                        "id INT(24) NOT NULL AUTO_INCREMENT",
                        "timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP",
                    ]
                    + create_command
                    + ["PRIMARY KEY (`id`)", "INDEX `index_timestamp` (`timestamp`)"]
                ),
            ),
            commit=True,
        )

    def disconnect(self):
        """disconnect.

        Returns:
            bool: success.
        """
        if self.connection is None:
            return True

        success = True
        try:
            self.connection.close()
        except:
            crash_report(f"-{NAME}: disconnect: failed.")
            success = False

        self.connection = None
        return success

    def drop(self):
        """drop self.

        Returns:
            bool: success.
        """
        return self.execute(f"DROP table {self.name};")

    def execute(self, sql, commit=False, returns_output=True):
        """execute sql command.

        Args:
            sql (str): sql command.
            commit (bool, optional): commit changes. Defaults to False.
            returns_output (bool, optional): return output. Defaults to True.

        Returns:
            bool: success.
            Any: output, optional.
        """
        output = []
        success = False
        try:
            with self.connection.cursor() as cursor:
                if isinstance(sql, tuple):
                    cursor.execute(sql[0], sql[1])
                else:
                    cursor.execute(sql)

                if returns_output:
                    output = cursor.fetchall()

                if commit:
                    # connection is not autocommit by default. So you must commit to save
                    # your changes.
                    self.connection.commit()

            success = True
        except:
            crash_report(f"-{NAME}: execute({sql}): failed.")

        return (success, output) if returns_output else success

    def insert(self, columns, values):
        """insert data in self.

        Args:
            columns (List[str]): list of columns to insert.
            values (List[Any]): list of values to insert.

        Returns:
            bool: success
        """
        return self.execute(
            (
                f"INSERT INTO {self.name}"
                + " ("
                + ", ".join(columns)
                + ") VALUES ("
                + ", ".join(len(columns) * ["%s"])
                + ")",
                values,
            ),
            commit=True,
            returns_output=True,
        )
