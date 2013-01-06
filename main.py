#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
import webapp2
import jinja2
import os
from google.appengine.api import channel
import datetime
import logging
from google.appengine.ext import db
import json
from uuid import uuid4 as uuid

# jinja = jinja2.Environment(
#     loader=jinja2.FileSystemLoader(os.path.dirname(__file__)))

class User(db.Model):
    name = db.StringProperty()
    token = db.StringProperty()
    connected = db.BooleanProperty(default=False)

class GameState:
    BEFORE, PLAYING, FINISHED = range(3)

class Game(db.Model):
    name = db.StringProperty()
    host = db.StringProperty()
    users = db.StringListProperty()
    state = db.IntegerProperty()
    results = db.TextProperty()
    data = db.TextProperty()

    def toJson(self):
        return {
            'gid': self.key().name(),
            'name': self.name,
            'host': self.host,
            'users': self.users,
            'state': self.state,
            'results': json.loads(self.results or "{}"),
            'data': json.loads(self.data or "{}")
        }

def jsonResponse(fn):
    def wrapped(self, *args, **kwargs):
        self.response.headers["Content-Type"] = "application/json"
        self.response.write(json.dumps(fn(self, *args, **kwargs)))
    return wrapped

def error(msg):
    return {
        'success': False,
        'msg': msg
    }

def success(o = {}):
    o['success'] = True
    return o

def broadcast(msg, users=None, sender=None):
    msg = json.dumps(msg)

    if users is None:
        users = [u.key().name() for u in User.all().filter("connected = ", True).run()]

    [channel.send_message(u, msg) for u in users if u != sender]

class MsgHandler(webapp2.RequestHandler):
    def post(self):
        m = self.request.get("msg")

        logging.info(m)
        logging.info(globTk)

        logging.info(inner)

        channel.send_message(inner, m)

class ConnectHandler(webapp2.RequestHandler):
    @jsonResponse
    def post(self):
        name = self.request.get("name")
        uid = name + ":" + str(uuid())

        logging.info("Connecting user " + uid)

        tk = channel.create_channel(uid)

        user = User(key_name=uid,
            name=name,
            token=tk)
        user.put()

        return success({
            'token': tk,
            'uid': uid,
            'name': name
        })

class GamesHandler(webapp2.RequestHandler):
    @jsonResponse
    def post(self):
        name = self.request.get("name")
        host = self.request.get("host")

        hostUser = User.get_by_key_name(host)

        if (hostUser is None):
            return error("Invalid User: " + host)

        gid = name + ":" + str(uuid())

        logging.info("Creating game " + gid)

        data = self.request.get("data")

        game = Game(key_name=gid,
            name=name,
            host=host,
            users=[host],
            state=GameState.BEFORE,
            data=data)

        game.put()

        broadcast({
            'type': 'gameCreate',
            'gid': gid,
            'name': name
            })

        return success(game.toJson())

    @jsonResponse
    def get(self):
        q = Game.all().filter("state = ", GameState.BEFORE)

        return [{
            'gid': g.key().name(),
            'name': g.name
        } for g in q.run()]

class GameHandler(webapp2.RequestHandler):
    @jsonResponse
    def get(self, gid):
        game = Game.get_by_key_name(gid)

        if game:
            return success(game.toJson())

        return error("No such game: " + gid)

class JoinGameHandler(webapp2.RequestHandler):
    @jsonResponse
    def post(self, gid):
        game = Game.get_by_key_name(gid)

        uid = self.request.get('uid')
        user = User.get_by_key_name(uid)

        if not game:
            return error("No such game: " + gid)
        if not user:
            return error("No such user: " + uid)

        if uid in game.users:
            return error("Already part of the game")

        if game.state != GameState.BEFORE:
            return error("Game has already started")
        
        game.users.append(uid)
        game.put()

        msg = {
            'gid': gid,
            'uid': uid,
            'name': user.name,
            'type': 'join'
        }

        broadcast(msg, game.users, uid)

        return success(game.toJson())

class StartGameHandler(webapp2.RequestHandler):
    @jsonResponse
    def post(self, gid):
        game = Game.get_by_key_name(gid)

        uid = self.request.get('uid')

        if not game:
            return error("No such game: " + gid)

        if uid not in game.users:
            return error("You are not in this game")

        if game.state != GameState.BEFORE:
            return error("Game has already been started")

        game.state = GameState.PLAYING
        game.put()

        broadcast({
            'type': 'gameStart',
            'gid': gid
            })

        msg = {
            'gid': gid,
            'type': 'start'
        }

        broadcast(msg, game.users)

        return success()

class FlyerHandler(webapp2.RequestHandler):
    @jsonResponse
    def post(self, gid, uid):
        game = Game.get_by_key_name(gid)

        if not game:
            return error("No such game: " + gid)

        if uid not in game.users:
            return error("User not in this game")

        if game.state != GameState.PLAYING:
            return error("Game not in progress")

        msg = {
            'gid': gid,
            'uid': uid,
            'type': 'fly',
            'msg': json.loads(self.request.get('msg'))
        }

        broadcast(msg, game.users, uid)

        return success()

class FlyerFinishHandler(webapp2.RequestHandler):
    @jsonResponse
    def post(self, gid, uid):
        game = Game.get_by_key_name(gid)

        if not game:
            return error("No such game: " + gid)

        if uid not in game.users:
            return error("User not in this game")

        results = json.loads(game.results or "{}")

        if uid in results:
            return error("User already finished")

        time = float(self.request.get('time'))

        results[uid] = time

        if len(results) >= len(game.users):
            # Everybody finished
            game.state = GameState.FINISHED

            msg = {
                'gid': gid,
                'type': 'done',
                'results': results
            }

            broadcast(msg, game.users)
        else:
            msg = {
                'gid': gid,
                'uid': uid,
                'type': 'finish',
                'time': time
            }

            broadcast(msg, game.users, uid)

        game.results = json.dumps(results)
        game.put()

        return success()

class ChannelConnectHandler(webapp2.RequestHandler):
    def post(self):
        uid = self.request.get("from")
        user = User.get_by_key_name(uid)

        if not user:
            return error("User does not exist")

        user.connected = True

        user.put()

class ChannelDisconnectHandler(webapp2.RequestHandler):
    def post(self):
        uid = self.request.get("from")
        user = User.get_by_key_name(uid)

        if not user:
            return error("User does not exist")

        user.connected = False

        user.put()

class UsersHandler(webapp2.RequestHandler):
    @jsonResponse
    def get(self):
        return [u.key().name() for u in User.all().filter("connected = ", True).run()]

class SendHandler(webapp2.RequestHandler):
    def post(self):
        rec = self.request.get("receiver")
        signal = self.request.get("signal")

        data = json.dumps({
                'signal': signal
                })

        channel.send_message(rec, data)

        # receiver = User.get_by_key_name(rec)

        # if (receiver != None):
        #     logging.info("Receiver: " + receiver.name + ", " + receiver.token)
        #     data = json.dumps({
        #             'signal': signal
        #             })
        #     self.response.write("Sending message: " + receiver.name + ", " + receiver.token + ", " + data)
        #     channel.send_message(receiver.name, data)
        # else:
        #     logging.info("Couldn't find user " + rec)
        #     self.response.write("Couldn't find user " + rec)

app = webapp2.WSGIApplication([
    ('/connect', ConnectHandler),
    ('/games/(.*)/join', JoinGameHandler),
    ('/games/(.*)/start', StartGameHandler),
    ('/games/(.*)/(.*)/finish', FlyerFinishHandler),
    ('/games/(.*)/(.*)', FlyerHandler),
    ('/games/(.*)', GameHandler),
    ('/games', GamesHandler),
    ('/users', UsersHandler),
    ('/_ah/channel/connected/', ChannelConnectHandler),
    ('/_ah/channel/disconnected/', ChannelDisconnectHandler)
], debug=True)
