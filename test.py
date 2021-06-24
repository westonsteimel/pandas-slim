import importlib
import pandas as pd

module = importlib.import_module('pandas')
print(module.__version__)


