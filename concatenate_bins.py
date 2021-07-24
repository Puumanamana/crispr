import argparse
import re
from pathlib import Path

from Bio.SeqIO.FastaIO import SimpleFastaParser

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('indir', type=str)
    parser.add_argument('output', type=str)    
    args = parser.parse_args()

    return args

def main():
    args = parse_args()

    with open(args.output, "w") as writer:
        for f in Path(args.indir).glob("*"):
            with open(f) as reader:
                for (title, seq) in SimpleFastaParser(reader):
                    writer.write(f">{f.stem}_{title}\n{seq}\n")

if __name__ == '__main__':
    main()
