#!/usr/bin/python
# -*- coding: utf-8 -*-

### copyright, Opscode Inc.
# Apache License
# Version 2.0, January 2004
# http://www.apache.org/licenses/
##################################

import sys
from functools import wraps
from hashlib import sha1
from pprint import pprint
from flask import Flask, request, flash, Response, session, g, jsonify, redirect, url_for, abort, render_template
import MySQLdb
from AAR_config import SECRET_KEY, CONNECTION_ARGS
########### local and temporary debugging crap: ###########
# import logging
# logger = logging.getLogger('aarapp')
# hdlr = logging.FileHandler('/Users/jjc/Desktop/aarapp.log')
# formatter = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
# hdlr.setFormatter(formatter)
# logger.addHandler(hdlr) 
# logger.setLevel(logging.INFO)
##########################################################

login_error = '''I'm sorry. I can't find that combination of credentials in my database. Perhaps you mis-typed your password?'''

app = Flask(__name__)
app.config['DEBUG'] = True #TODO: put this in __main__?
app.config['SECRET_KEY'] = SECRET_KEY

def logged_in(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session.get('logged_in') is not None:
            return f(*args, **kwargs)
        else:
            flash('Please log in first...', 'error')
#             next_url = request.url
#             login_url = '%s?next=%s' % (url_for('login'), next_url)
            return redirect(url_for('login'))
            
    return decorated_function

@app.route('/logout')
def logout():
    session.pop('username', None)
    session.pop('role', None)
    session.pop('logged_in', None)
    return redirect(url_for('login'))

@app.route('/', methods=['GET', 'POST'])
def login():
    error = None
    next = request.args.get('next')
    
    if request.method == 'POST':
        uname = request.form['username']
        upswd = request.form['password']
        upw = sha1(upswd).hexdigest()
        
        db = MySQLdb.connect(**CONNECTION_ARGS)
        cur = db.cursor()
        rows = cur.execute("select uname, pw, role from users where uname = %s",(uname,))
        
        if rows > 0:
            users_name, pw_hash, role = cur.fetchone()
        if rows == 0 or uname != users_name or upw != pw_hash:
            error = login_error
        else:
            session['logged_in'] = True
            session['username'] = uname
            session['role'] = role
            
            if session['role'] == 'admin':
                return redirect(url_for('dispatcher'))
            elif session['role'] == 'customer':
                return redirect(url_for('repairRequest'))
        cur.close()
    return render_template('login.html', error=error, session=session, reqenviron = request.environ,)

@app.route('/resetdb')
def resetdb():
    ## data for original sample jobs, j_id 100 through 127
    resetdata = [(None, 'pending', 100), ('2013-11-01', 'completed', 101), (None, 'pending', 102), ('2013-11-02', 'completed', 103), ('2013-11-03', 'pending', 104), ('2013-11-04', 'pending', 105), (None, 'pending', 106), ('2013-11-05', 'pending', 107), (None, 'pending', 108), ('2013-11-06', 'completed', 109), (None, 'pending', 110), ('2013-11-07', 'completed', 111), (None, 'pending', 112), ('2013-11-08', 'completed', 113), (None, 'pending', 114), ('2013-11-09', 'completed', 115), (None, 'pending', 116), ('2013-11-10', 'pending', 117), (None, 'pending', 118), ('2013-11-11', 'pending', 119), (None, 'pending', 120), ('2013-11-12', 'pending', 121), (None, 'pending', 122), ('2013-11-13', 'pending', 123), (None, 'pending', 124), ('2013-11-14', 'pending', 125), (None, 'pending', 126), ('2013-11-15', 'pending', 127)]

    IPadd = request.environ['REMOTE_ADDR']
    db = MySQLdb.connect(**CONNECTION_ARGS)
    cur = db.cursor()
    
    for x in resetdata:
        cur.execute("update jobs set appointment = %s, job_status = %s where j_id=%s", (x[0],x[1],x[2]))
    
    rows = cur.execute("delete from jobs where j_ip = %s", (IPadd))
    db.commit()
    cur.close()
    return jsonify({'IP': IPadd,'rows_deleted': rows})
    
@app.route('/dispatcher', methods=['GET', 'POST'])
@logged_in
def dispatcher():
    error = None
    db = MySQLdb.connect(**CONNECTION_ARGS)
    cur = db.cursor()
    if not session.get('logged_in'):
        abort(401)
    if session.get('role') != 'admin':
        flash( 'please log in first' )
        return logout()
    
    ##POST
    if request.method == 'POST':
        jid = request.form['job_id']
        field = request.form['field_value']
        new_value = request.form['new_value']
        set_job_status = "update jobs set job_status = %s where j_id=%s"
        set_appointment = "update jobs set appointment = %s where j_id=%s"
        
        if field == 'job_status':
            query = set_job_status
        else:
            query = set_appointment
            if new_value.upper() == 'NULL' or new_value.upper() == 'NONE': new_value = None
        
        query = set_job_status if field == 'job_status' else set_appointment
        
        try:
            affected_count = cur.execute(query, (new_value, jid))
            db.commit()
            if affected_count > 0: flash( 'your update was successful' )
        except MySQLdb.IntegrityError:
            error = "failed to update job ID: %s" % (jid,)
        finally:
            cur.close()
                    
        return redirect(url_for('dispatcher'))
    
    ##GET
    else:
        cur.execute("select j.j_id, c.cid, c.lname, j.make, j.appliance, j.job_status, j.appointment, j.description from jobs j, customer c where j.cid = c.cid")
        result = cur.fetchall()

        return render_template("dispatcher.html",
            error = error,
            title = "Dispatcher Interface",
            user = session['username'],
            reqenviron = request.environ,
            ses = session,
            result = result)

@app.route('/repairRequest', methods=['GET', 'POST'])
@logged_in
def repairRequest():
    if session.get('role') != 'customer':
        flash( 'please log in first' )
        return logout()
    
    session.permanent = False
    error = None
    user = session.get('username')
    host = request.environ['REMOTE_ADDR']
    db = MySQLdb.connect(**CONNECTION_ARGS)
    cur = db.cursor()
    rows = cur.execute("select c.fname, c.lname, u.cid from customer c, users u where u.uname = %s and u.cid = c.cid",(user,))
    if rows > 0:
        fname, lname, cid = cur.fetchone()
    else:
        return logout()

    #POST
    if request.method == 'POST':
        make = request.form['make']
        type = request.form['type']
        description = request.form['description']
        appointment = None
        job_status = 'pending'
        
        rows = cur.execute("insert into jobs (j_ip,cid, make, appliance, appointment, job_status, description) values\
            (%s, %s, %s, %s, %s, %s, %s)", (host, cid, make, type, appointment, job_status, description))
        db.commit()
        if rows == 0:
            error = "Your repair request failed."
        
        rows = cur.execute("select j_id, make, appliance, job_status, appointment from jobs where cid = %s and j_ip = %s", (cid, host))
        result = cur.fetchall()
        cur.close()
        error = "Your request has been added to the database."    
        
        return render_template("repairRequest.html",
            title = "Repair Request",
            user = user,
            fname = fname,
            lname = lname,
            result = result,
            error = error,
            reqenviron = request.environ,
            ses = session)
    
    #GET
    else:
        cur.execute("select j_id, make, appliance, job_status, appointment from jobs where j_ip = %s and cid = %s", (host, cid))
        result = cur.fetchall()
        
        return render_template("repairRequest.html",
            title = "Repair Request",
            user = user,
            fname = fname,
            lname = lname,
            error = error,
            result = result,
            reqenviron = request.environ,
            ses = session)
        cur.close()

##### Shut down the simple server from the browser address bar #####
def shutdown_server():
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()

@app.route('/shutdown', methods=['GET'])
def shutdown():
    shutdown_server()
    return 'Server shutting down...'

if __name__ == "__main__":
    app.run(port=9229)
