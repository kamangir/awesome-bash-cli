from setuptools import setup

from awesome_bolt_plugin import name, version

setup(
    name=name,
    author="kamangir",
    version=str(version),
    description=name,
    packages=[name],
)
