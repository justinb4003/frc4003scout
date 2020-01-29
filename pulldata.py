#!/usr/bin/env python3


from google.cloud import firestore

student_lookup = {}
db = firestore.Client()
students_ref = db.collection('students')
for doc in students_ref.stream():
    student_lookup[doc.id] = doc.to_dict()['name']

results_ref = db.collection('scoutresults')
for doc in results_ref.stream():
    (year, match_id, team, student_key) = doc.id.split(':')
    student_name = student_lookup[student_key]
    match_data = doc.to_dict()
    print(f"Year {year} match {match_id} with {team} taken by {student_name}")
    print("... crossed auto line: {}".format(match_data['auto_line']))
    print("... auto bottom port: {}".format(match_data['auto_port_bottom']))
