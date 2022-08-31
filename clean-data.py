#!/usr/bin/env python

import sys
import pandas as pd

file_path = sys.argv[1]

df = pd.read_csv(file_path, sep=";")

df = df.drop_duplicates("hash")
df = df.sort_values(by="date").reset_index(drop=True)

df.to_csv(file_path, sep=";", index=False)
