#!/usr/bin/env python3

import json
from google.cloud import firestore

student_lookup = {}
db = firestore.Client()
students_ref = db.collection('students')
for doc in students_ref.stream():
    student_lookup[doc.id] = doc.to_dict()['name']

results_ref = db.collection('scoutresults')
out_results = []
for doc in results_ref.stream():
    (year, compname, team, student_key, match_id) = doc.id.split(':')
    student_name = student_lookup[student_key]
    match_data = doc.to_dict()
    res = {'team_number': team,
           'student_name': student_name,
           'auto_line': match_data['auto_line'],
           'auto_port_bottom': match_data['auto_port_bottom'],
           }
    out_results.append(res)
print(json.dumps(out_results, indent=4, sort_keys=True))
