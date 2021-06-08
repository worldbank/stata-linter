from setuptools import setup
setup(
    name='stata_linter',
    version='0.01',
    entry_points={
        'console_scripts': [
            'stata_linter_detect=stata_linter_detect:run',
            'stata_linter_correct=stata_linter_correct:run'
        ]
    },
    install_requires=[
          'pandas',
          'openpyxl'
      ]
)
