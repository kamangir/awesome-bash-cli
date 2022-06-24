import copy

from .. import *

name = f"{shortname}.options"


class Options(dict):
    def __add__(self, options):
        """
        Add options to self.
        :param options: options
        :return: Options()
        """
        output = copy.deepcopy(self)
        output.update(Options(options))
        return output

    def __init__(self, *args):
        super(Options, self).__init__()

        if not args:
            return

        first_item_index = 0
        if len(args) % 2 == 1:
            first_item_index = 1
            if isinstance(args[0], dict):
                self.update(args[0])
            elif isinstance(args[0], str):
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
                raise NameError(
                    "Cannot convert {} to {}.".format(
                        args[0].__class__.__name__, self.__class__.__name__
                    )
                )

        for index in range(first_item_index, len(args), 2):
            self[args[index]] = args[index + 1]

    def as_string(self):
        """
        Describe self as a string.
        :return: string
        """
        return "{}".format(self).replace("'", '"')

    def default(self, option, default):
        """
        Set default.
        :param option: option
        :param default: default
        :return: Options()
        """
        output = copy.deepcopy(self)
        output[option] = output.get(option, default)
        return output

    def delete(self, item):
        """
        Delete item from self.
        :param item: Item to be deleted.
        :return: Options()
        """
        output = copy.deepcopy(self)
        if item in output:
            del output[item]
        return output

    def get(self, keyword, default):
        """
        Get the value corresponding to keyword.
        :param keyword: keyword
        :param default: default
        :return: value
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

    def set(self, *args):
        """
        Set options.
        :param args:
            1. option_1, value_1, option_2, value_2,...
            2. {option_1:value_1, option_2:value_2, ...}
        :return: Options()
        """
        output = copy.deepcopy(self)

        if len(args) == 1:
            if isinstance(args[0], dict):
                output.update(args[0])
                return output
            else:
                raise NameError(
                    "Options.set({}) failed, dict expected, {} .".format(
                        args[0].__class__.__name
                    )
                )

        if len(args) % 2:
            raise NameError(
                "Options.set({}) failed, even inputs expected.".format(
                    ",".join(len(args) * "X")
                )
            )

        for index in range(0, len(args), 2):
            output[args[index]] = args[index + 1]

        return output

    def to_str(self):
        """convert self to str.

        Returns:
            str: self as str.
        """

        return ",".join(
            [
                "+{}".format(keyword)
                if value == True
                else "-{}".format(keyword)
                if value == False
                else "{}={}".format(keyword, value)
                for keyword, value in self.items()
            ]
        )
