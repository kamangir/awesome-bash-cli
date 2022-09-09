# abcli plugins

An [`abcli`](https://github.com/kamangir/awesome-bash-cli) plugin is a mechanism to quickly build a bash cli around existing code. Here are examples of `abcli` plugins:

1. [blue-rvr](https://github.com/kamangir/blue-rvr): A low-cost rover that carries a camera, runs deep learning vision models through python and TensorFlow, and is cloud-connected.
1. [blue-bracket](https://github.com/kamangir/blue-bracket): Multiple machine vision & ai designs on raspberry pi and jetson nano on the edge.
1. [RAW Vancouver PORTAL 2022](https://github.com/kamangir/RAW-Vancouver-PORTAL-2022): A [digital art installation](https://rawartists.com/vancouver).

---

To build an [`abcli`](https://github.com/kamangir/awesome-bash-cli) plugin you need code that is executed through the command line. This code should exist in a repo, i.e. `<plugin-name>`. Now, follow these steps:

1. Make sure that you have an up-to-date copy of [`abcli`](https://github.com/kamangir/awesome-bash-cli) running on a dev machine.
1. Checkout the repo `<plugin-name>`.
1. Run `abcli plugin add_to <plugin-name>`.
1. Run `abcli init` and validate that `<plugin-name>` is loaded.
1. Commit and push the changes to the repo `<plugin-name>` and start developing... 🚀 

## Advanced

1. Update [`keywords.py`](../abcli/keywords/keywords.py).
1. Remove the file [`no-browser`](./no-browser) in the plugin repo and develop the [browser views](https://github.com/kamangir/browser).