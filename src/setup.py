from setuptools import setup
setup(
    name='stata_linter',
    version='1.0',
    entry_points={
        'console_scripts': [
            'stata_linter_detect=stata_linter_detect:run'
        ]
    },
    install_requires=[
          'pandas',
          'openpyxl'
      ]
)
