# Multilingual Data Science: Example Project

This project is a simple example of multilingual data science:

- Get the data with curl: fast and simple.
- Wrangle the data with Python: nice interface to duckdb.
- Render a simple report with R: very easy to generate good-looking plots.

Then the targets for the analysis are defined in the Makefile, to make everything nice and reproducible.

I've borrowed heavily from two sources for this example:

1. [Cookiecutter Data Science](http://drivendata.github.io/cookiecutter-data-science/), which I used as the starting point for my own [Python Data Science Cookiecutter](https://github.com/hamedbh/cookiecutter-py-datasci).
2. [Data Science at the Command Line](https://jeroenjanssens.com/dsatcl/), which offers loads of ideas around using command line tools as the glue between languages.

## Getting started

Having checked out this repo you'll need to set up the environments for R and Python. These steps are all contained in the `project_setup` script, which will:

- Create a Python virtual environment and activate it. The Python executable and location of the virtual environment are set in the Makefile. If you want/need to change these they are `PYTHON_VERSION` and `VIRTUALENV_LOCATION` respectively.
- Install the required packages from `requirements.txt`, which includes your local code under `src`.
- Create an IPython kernel to use with notebooks, called test-copilot.
- Install the Git pre-commit hooks defined in `.pre-commit-config.yaml`.
- Install nbstripout, which prevents notebook outputs being committed in version control.
- Activate an [{renv}](https://rstudio.github.io/renv/articles/renv.html) and install the required R packages.

To run the setup script:

```bash
. project_setup
```

Running that script should just be a one-off step. In future when you return you just need to activate the virtual environment with:

```bash
source ./.venv/bin/activate
```

Running the entire analysis _should_ then be as simple as `make all`. Note that this will download five years' data, which is over 4GB. If you want to narrow the scope change the `YEARS` variable in the Makefile.

## Environment variables

This project assumes that you have a file called `.env` at the top level of your project, which is where you can store env vars e.g. API keys. **This must never be checked into version control**.

Then you can refer to those variables in your Python scripts easily:

```python
import os
from dotenv import load_dotenv, find_dotenv

# find .env automagically by walking up directories until it's found
dotenv_path = find_dotenv()
# load up the entries as environment variables
load_dotenv(dotenv_path)
api_key = os.getenv["CONNECT_API_KEY"]
```

You can use dotenv in IPython. By default, it will use find_dotenv to search for a .env file:

```python
%load_ext dotenv
%dotenv
```

Please do not use environment variables for project paths. Instead, use `src/locations.py`.
