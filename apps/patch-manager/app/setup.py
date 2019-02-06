from setuptools import setup, find_packages

setup(
    name='ifi',
    version='0.1',
    packages=find_packages(),
    include_package_data=True,
    py_modules=['ifi'],
    install_requires=[
        'Click'
    ],
    entry_points='''
        [console_scripts]
        ifi=ifi:cli
    ''',
)
