#! /usr/bin/env python

import json
import sys


WRITE_FILE = 'variables.json'
VARIABLES = ['Country', 'Perceived Descritpive Norms about Childcare', 'Perceived Descriptive Norms: HEED, STEM and Work', 'Perceived injunctive Norms', 'Own Support for Equality', 'Personal Evaluations', 'Family Expectations', 'Expected Experiences', 'Personal Beliefs', 'Own Parental Background', 'Demographics']


def add_new_variable(line):
    """Add new variable."""
    global var_list
    new_var = {'name': line, "labels": []}
    var_list.append(new_var)


def add_new_label(line):
    """Add new label to a existing variable."""
    global var_list
    new_label = line
    var_list[-1]['labels'].append(new_label)


def dump_variables2json(var_list, write_file):
    """Dump the variable list object to JSON."""
    with open(write_file, 'w') as file:
        json.dump(var_list, file, indent=2)


def main():
    """Execute main function."""
    with open('variables.txt') as file:
        global var_list
        var_list = []
        while True:
            line = file.readline()

            # when reach EOF, stop
            if not line:
                break

            line = line.strip()
            if line in VARIABLES:
                add_new_variable(line)
            elif len(line) > 1:
                add_new_label(line)
            else:
                continue
    dump_variables2json(var_list, WRITE_FILE)


if __name__ == "__main__":
    sys.exit(main())
