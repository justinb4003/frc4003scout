#!/usr/bin/env python3

import os
import json
from google.cloud import firestore
from functools import lru_cache


@lru_cache(maxsize=1)
def _get_student_dict():
    student_lookup = {}
    db = get_client()
    students_ref = db.collection('students')
    for doc in students_ref.stream():
        student_lookup[doc.id] = doc.to_dict()['name']
    return student_lookup


def get_client():
    # Unfortunately I'm not finding a way to specify credentials without the
    # environment variable.
    credential_file = '/home/jbuist/git/frc4003scout/goog-py.json'
    os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credential_file
    db = firestore.Client()
    return db


def get_student_name(key):
    return _get_student_dict().get(key, None)


def get_comp_data(target_year, target_compname):
    results_ref = get_client().collection('scoutresults')
    out_results = []
    for doc in results_ref.stream():
        (year, compname, team, student_key, matchnum) = doc.id.split(':')
        # Skip competitions we're not trying to get data for
        if int(target_year) != int(year) or target_compname != compname:
            continue
        student_name = get_student_name(student_key)
        match_data = doc.to_dict()
        res = {'team_number': team,
               'student_name': student_name,
               'match_number': matchnum,
               'auto_line': match_data.get('auto_line', 0),
               'auto_port_bottom': match_data.get('auto_port_bottom', 0),
               'auto_port_top': match_data.get('auto_port_top', 0),
               'auto_port_inner': match_data.get('auto_port_inner', 0),
               }
        out_results.append(res)
    return out_results


if __name__ == '__main__':
    import sys
    target_year = sys.argv.pop(1) if len(sys.argv) >= 2 else 2020
    target_compname = sys.argv.pop(1) if len(sys.argv) >= 2 else 'misjo'
    print(f'Processing {target_year} at {target_compname}')
    data = get_comp_data(target_year, target_compname)
    print(json.dumps(data, indent=4, sort_keys=True))
