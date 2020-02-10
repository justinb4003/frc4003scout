#!/usr/bin/env python3

import os
import sys
import json
from google.cloud import firestore
from functools import lru_cache
from flask import Flask, jsonify

# Monkey punch that thing because i sprinkled print everywhere
sys.stdout = sys.stderr

app = application = Flask(__name__)
# Unfortunately I'm not finding a way to specify credentials without the
# environment variable.
credential_file = '/var/www/scoutdata/goog-py.json'
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credential_file


@lru_cache(maxsize=32)
def _get_student_dict():
    print('Building student name cache.')
    student_lookup = {}
    db = get_client()
    students_ref = db.collection('students')
    for doc in students_ref.stream():
        student_lookup[doc.id] = doc.to_dict()['name']
    print('Student cache built.')
    return student_lookup


def get_client():
    print('Getting connection to Firecloud...')
    db = firestore.Client()
    print('... CONNECTION ESTABLISHED!')
    return db


def get_student_name(key):
    return _get_student_dict().get(key, None)


@app.route('/')
def test():
    return 'It lives!'


@app.route('/results/<target_year>/<target_compname>')
def get_comp_scoutresults_url(target_year, target_compname):
    print(f'Begin getting results for {target_year} and {target_compname}')
    data = get_comp_scoutresults(target_year, target_compname)
    print('got the data...')
    # response.content_type = 'application/json'
    return jsonify(data)


def get_comp_scoutresults(target_year, target_compname):
    out_results = []
    try:
        print("Getting scout results collection")
        results_ref = get_client().collection('scoutresults')
        print("got it, begin record processing.")
        # Hangs right here when run in WSGI mode, not on console
        for dr in results_ref.list_documents():
            print("Processing record: {}".format(dr))
            (year, compname, team, student_key, matchnum) = dr.id.split(':')
            # Skip competitions we're not trying to get data for
            if int(target_year) != int(year) or target_compname != compname:
                continue
            student_name = get_student_name(student_key)
            print('Grabbing actual document now')
            doc = dr.get()
            match_data = doc.to_dict()
            res = {'team_number': team,
                   'student_name': student_name,
                   'match_number': matchnum}
            res.update(match_data)
            out_results.append(res)
        print("Returning data")
    except:  # noqa
        print('Something really bad happened.')
    return out_results


if __name__ == '__main__':
    import sys
    target_year = sys.argv.pop(1) if len(sys.argv) >= 2 else 2020
    target_compname = sys.argv.pop(1) if len(sys.argv) >= 2 else 'misjo'
    print(f'Processing {target_year} at {target_compname}')
    data = get_comp_scoutresults(target_year, target_compname)
    print(json.dumps(data, indent=4, sort_keys=True))
