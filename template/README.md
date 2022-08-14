# abcli plugins

An `abcli` plugin is a mechanism to quickly build a bash cli around existing code to codify parameter selection and provide a scripting language for workflow automation. Here are examples of `abcli` plugins:

1. [blue-rvr](https://github.com/kamangir/blue-rvr): A low-cost rover that carries a camera, runs deep learning vision models through python and TensorFlow, and is cloud-connected.
1. [blue-bracket](https://github.com/kamangir/blue-bracket): Multiple machine vision & ai designs on raspberry pi and jetson nano on the edge.
1. [RAW Vancouver PORTAL 2022](https://github.com/kamangir/RAW-Vancouver-PORTAL-2022): A [digital art installation](https://rawartists.com/vancouver).

---

To build an `abcli` plugin you need existing code or code under development that is executed through the command line. This code must exist in a separate repo. Now, follow these steps:

1. Make sure that you have an up-to-date copy of [`abcli`](../README.md) running on a dev machine.
1. Checkout the `plugin-name`.
1. Run these lines to add the contents of this folder to the repo. Replace `eye` with `plugin-name`.
    ```
    abcli git cd
    cp -r * ../plugin-name/ ; \
    cp .gitignore ../plugin-name/
    ```
1. Run `abc init` and validate that `plugin-name` is loaded.

## Advanced

1. Update [`keywords.py`](../abcli/keywords/keywords.py).
1. Remove the file [`no-browser`](./no-browser) in the repo root and build out the [browser](https://github.com/kamangir/browser) pages.