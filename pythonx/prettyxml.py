#! /usr/bin/env python3

import sys
import xml.dom.minidom

def main(doc):
    pretty = xml.dom.minidom.parse(doc).toprettyxml()
    print(pretty)

if __name__ == "__main__":
    main(sys.stdin)
