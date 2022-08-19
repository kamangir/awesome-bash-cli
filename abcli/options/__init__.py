import copy
from .. import *

name = f"{shortname}.options"


class Options(dict):
    def __add__(self, options):
        """return Options(self += options).

        Args:
            options (Options): options.

        Returns:
            Options: options
        """
        output = copy.deepcopy(self)
        output.update(Options(options))
        return output

    def __init__(self, *args):
        """constructor.

        Args:
            - option_1, value_1, option_2, value_2,...
            - {option_1:value_1, option_2:value_2, ...}

        Raises:
            NameError: bad input.

        Returns:
            Options: options.
        """
        super(Options, self).__init__()

        if not args:
            return

        if len(args) == 1:
            if isinstance(args[0], dict):
                self.update(args[0])
                return

            if isinstance(args[0], str):
                for input in args[0].split(","):
                    if input.startswith("+"):
                        self[input[1:]] = True
                    elif (
                        input.startswith("-")
                        or input.startswith("~")
                        or input.startswith("!")
                    ):
                        self[input[1:]] = False
                    elif "=" in input:
                        option_name = input.split("=")[0]
                        option_value = "=".join(input.split("=")[1:])
                        self[option_name] = option_value
                    else:
                        if input:
                            self[input] = True
            else:
                raise NameError(f"-{NAME}: cannot read {args[0].__class__.__name__}.")
        else:
            for index in range(0, len(args), 2):
                self[args[index]] = args[index + 1]

    def default(self, keyword, default):
        """create a copy of self and set default for keyword.

        Args:
            keyword (str): keyword.
            default (str): default.

        Returns:
            Options: options.
        """
        output = copy.deepcopy(self)
        output[keyword] = output.get(keyword, default)
        return output

    def delete(self, keyword):
        """create a copy of self and delete keyword.

        Args:
            keyword (str): keyword.

        Returns:
            Options: options.
        """
        output = copy.deepcopy(self)
        if keyword in output:
            del output[keyword]
        return output

    def get(self, keyword, default):
        """return self.get(keyword, default).

        Args:
            keyword (str): keyword.
            default (str): default.

        Returns:
            Any: value.
        """
        output = super(Options, self).get(keyword, default)

        if isinstance(default, bool):
            try:
                return bool(output)
            except:
                return default

        if isinstance(default, int):
            try:
                return int(output)
            except:
                return default

        if isinstance(default, float):
            try:
                return float(output)
            except:
                return default

        return output

    def to_str(self):
        """convert self to str.

        Returns:
            str: self as str.
        """
        return ",".join(
            [
                f"+{keyword}"
                if value == True
                else f"-{keyword}"
                if value == False
                else f"{keyword}={value}"
                for keyword, value in self.items()
            ]
        )
