# Using Flask to generate static website

![Banner image](images/banner.png)

This is a post about me using Flask Jinja templating to "standardize" [my static website](karlcch.com)

[↩️ go back](../)

## Introductions

Why flask? There are indeed many tools that can be used to create static websites, however, all of them have some kind of limitations.

I personally don't have much experience with those tools myself. Plus, I like to be in control and create the entire thing from scratch.

Flask in this project is only used to create routes while Jinja2 does all the work of putting everything together "standardly".

I am still working on migrating my [GitHub pages](https://pages.github.com/) page for posts like this to my site. Flask is the middle ground for me between throwing everything on a WordPress host and hosting on a bucket(free).

Also, check out:

- [Using S3 with CloudFront to host Static Websites for FREE](https://github.karlcch.com/articles/1.Using-S3-to-host-static-website)
- [Project github link](https://github.com/ltekme/karlcch/tree/e91ddd54899ae19c0bcfc01fab15f3bb11df52b4)
- [karlcch.com](karlcch.com)

## Table of Contents

- [Using Flask to generate static website](#using-flask-to-generate-static-website)
  - [Introductions](#introductions)
  - [Table of Contents](#table-of-contents)
  - [credits](#credits)
  - [Reason to use templating](#reason-to-use-templating)
    - [Ranting about WordPress, hosting, services](#ranting-about-wordpress-hosting-services)
    - [Linkedin is a good platform](#linkedin-is-a-good-platform)
    - [Flask](#flask)
  - [Project Layout](#project-layout)
  - [Encounters](#encounters)
    - [Frozen-Flask page build](#frozen-flask-page-build)
    - [sitemap](#sitemap)
    - [robots](#robots)
    - [Static content](#static-content)
    - [Favicon](#favicon)
    - [Full URL path on build](#full-url-path-on-build)
    - [Build dir](#build-dir)
    - [S3 error page](#s3-error-page)
  - [File overview](#file-overview)
    - [app/\_\_init\_\_.py](#app__init__py)
    - [app/routes.py](#approutespy)
    - [app/pages.py](#apppagespy)
    - [build.py](#buildpy)
    - [additional reads](#additional-reads)
  - [Happy building](#happy-building)

## credits

- Flask: [https://github.com/pallets/flask](https://github.com/pallets/flask)
- Flask Sitemapper: [https://github.com/h-janes/flask-sitemapper](https://github.com/h-janes/flask-sitemapper)
- Frozen-Flask: [https://github.com/Frozen-Flask/Frozen-Flask](https://github.com/Frozen-Flask/Frozen-Flask)
- python-dotenv: [https://github.com/theskumar/python-dotenv](https://github.com/theskumar/python-dotenv)

## Reason to use templating

There are many pages that have the same content over and over such as the head of the html and the banner itself.

In the future when I expand the site, things will only get more complicated. I have a few options:

- Migrate to [WordPress](https://wordpress.com/)
- Migrate all my posts to LinkedIn
- Flask

---

### Ranting about WordPress, hosting, services

I personally don't like WordPress. The biggest reason is that the control panel is directly accessible by URL to anyone. You can secure it, however, just is idea of it feels off. Trust me, it's not a good idea to expose your control panel to a publically accessible URL.

Just look for sites hosted using WordPress and type in `/wp-admin`. You would be surprised by how many site owners didn't do anything to protect the page.

I not saying WordPress is bad, it has its nesh, and every implementation of every system has its flaws. But this wp-admin thing has been bothering me since I once used it until I moved to a different option.

Besides, having a host with a service exposed to the internet is not really my cup of tea. Back when I was hosting my site on a VM, viewing the logs of apach2 was one of my favorite free time activities, I constantly found random hosts hitting `/wp-admin`, `/wp/config`, `.config`, `.c9` to try to get something out of the host. It's a fun activity and a great time killer.

`Looking at Apache Log to see what bots are targeting and searching up IP addresses that hit on some random URL path that tries to do SQL injection on an HTML hosted dir with no logic on the server whatsoever`

come on, I don't even have a database back then. it is fun to see this popping up once in a while.

| Time                 | Type | Path                | HTTP ver | Response |
| -------------------- | ---- | ------------------- | -------- | -------- |
| 13/Apr/2023:11:29:03 | GET  | /.aws/credentials   | HTTP/1.1 | 404      |
| 13/Apr/2023:11:29:03 | GET  | /.wp-config.php.swp | HTTP/1.1 | 404      |
| 13/Apr/2023:11:29:03 | GET  | /admin/phpinfo.php  | HTTP/1.1 | 404      |

Fun times.

---

### Linkedin is a good platform

LinkedIn is a very good place to share things like this it's just too simple for me.

---

### Flask

At the time of writing, I am using CloudFront and an s3 bucket to host my site, all I need is a way to standardize my HTMLs.

So flask it is. And for those who wanted to say [node.js](https://nodejs.org/en), I tried, it was way too complicated for my use case. I just finished an assignment project that requires Flask. I just want to get on with my life. Semester 3 is hell enough already.

## Project Layout

```sh
.
├── app
│   ├── __init__.py
│   ├── pages.py
│   ├── resources
│   │   └── favicon.ico
│   ├── routes.py
│   ├── static
│   │   ├── images
│   │   │   ├── icon.webp
│   │   └── styles
│   │       ├── main.css
│   │       └── normalize.css
│   └── templates
│       ├── errors.html.j2
│       ├── index.html.j2
│       ├── layout.html.j2
│       └── robots.txt
├── build.py
├── requirements.txt
└── run.py
```

checkout the [GitHub repo](https://github.com/ltekme/karlcch) for more details about it

## Encounters

### Frozen-Flask page build

when I decided on using [`Frozen-Flask`](https://frozen-flask.readthedocs.io/en/latest/) I didn't realize it would copy all the contents of the static folder to the build destination. Thus causing some files to be duplicated such as:

- favicon.ico
- robots.txt
- sitemap.xml

---

### sitemap

After looking at some of the options out there I landed on flask-sitemapper as it was one of the simplest of them all. At first, I decided to use [flask-sitemap](https://flask-sitemap.readthedocs.io/en/latest/) however after reading the documentation, this is too complicated for my use case, after stumbling around when I almost decided to create my own I found [h-janes/flask-sitemapper](https://github.com/h-janes/flask-sitemapper) a simple yet elegant solution to my problem.

```python
# app/__init__.py
sitemapper = Sitemapper(https=bool(app.config.get("URL_SCHEME") == "https"))
sitemapper.init_app(app)
```

```python
# app/routes.py
@sitemapper.include(lastmod="2024-05-09")
@app.route('/')
def index():
    return render_template('index.html.j2', title='KarlCCH | Home', metadata_description='Home of karlcch', config=app.config)
```

along with

```python
# app/routes.py
@app.route("/sitemap.xml")
def sitemap():
    return sitemapper.generate()
```

only one line is needed to include the route to the sitemap `@sitemapper.include(lastmod="2024-05-09")`.

---

### robots

This file is a bit complicated as I cannot just send a text string to the client for some reason.

```python
# app/routes.py
@app.route('/robots.txt')
def robots():
    return '''# https://www.robotstxt.org/robotstxt.html
User-agent: *
Disallow:
sitemap: karlcch.com/sitemap.xml'''
```

But this has a few problems in itself. First I would be hardcoding the hostname of the site.

[lighthouse](https://developer.chrome.com/docs/lighthouse/overview/) keeps complaining about an improper robots.txt so I had to send a file instead of a string.

```python
# app/routes.py
return send_from_directory('resources', 'robots.txt')
```

I can use [`flask.send_from_directory`](https://tedboy.github.io/flask/generated/flask.send_from_directory.html) to send the file however I need to figure out how to change the file based on the hostname.

I can use Python's [`open`](https://docs.python.org/3/library/functions.html) to modify the file on the fly, but this would create another problem down the road.

Consulting the documentation I found [`flask.send_file`](https://flask.palletsprojects.com/en/3.0.x/api/#flask.send_file) this allows me to send [`open`](https://docs.python.org/3/library/functions.html) object as a file to the client.

All I need to do now is to encode the robots string to a [`BytesIO`](https://docs.python.org/3/library/io.html#binary-i-o) object and use [`flask.send_file`](https://flask.palletsprojects.com/en/3.0.x/api/#flask.send_file) to send the string as a file.

```python
# app/routes.py
mem = BytesIO()
mem.write(robot_file.encode('utf8'))
mem.seek(0)

return send_file(mem, mimetype='text/plain', as_attachment=False, download_name='robots.txt')
```

done. I can now use [`flask.render_template`](https://flask.palletsprojects.com/en/2.3.x/templating/) to render the file with hostname

```python
# app/routes.py
robot_file = render_template('robots.txt', hostname=hostname)
```

to get the hostname I need to have 2 things, `HTTPS` and `SERVER_NAME` should be easy

```python
# app/routes.py
hostname = app.config.get('SERVER_NAME') or request.host
if app.config.get('URL_SCHEME') == 'https':
    hostname = 'https://' + hostname
else:
    hostname = 'http://' + hostname
```

piecing everything together

```python
# app/routes.py
@app.route('/robots.txt')
def robots():
    # get hostname
    hostname = app.config.get('SERVER_NAME') or request.host
    if app.config.get('URL_SCHEME') == 'https':
        hostname = 'https://' + hostname
    else:
        hostname = 'http://' + hostname
    # render file
    robot_file = render_template('robots.txt', hostname=hostname)
    # store to memory as a virtaul file
    mem = BytesIO()
    mem.write(robot_file.encode('utf8'))
    mem.seek(0)

    return send_file(mem, mimetype='text/plain', as_attachment=False, download_name='robots.txt')
```

That's a complete robots.txt Lighthouse is now happy.

---

### Static content

Flask [`url_for`](https://flask.palletsprojects.com/en/2.3.x/api/#flask.url_for) has a built-in static content route which allows you to point to every file in the `static` folder.
This creates a problem.

Everything in that folder is now in the root of the site. To prevent anything from breaking and making it `CDN friendly`

I decided to put all static content in the `/static` folder of the HTML. Thus this route was born.

```python
# app/routes.py
@app.route('/static/<path:path>')
def static_content(path):
    return send_from_directory('static', path)
```

Instead of using the built-in static route, using this special route allows all static content present in the built static site folder.

---

### Favicon

This file is a bit complicated as I would like. To show the favicon I can just put it in the static folder and be done with it.

However as mentioned before, duplicated files.

```python
# app/routes.py
@app.route('/favicon.ico')
def favicon_ico():
    return send_from_directory('resources', 'favicon.ico')
```

create a new folder called `resources`. Move the file there with a route pointing to the file.

Problem solved

---

### Full URL path on build

When writing the Flask app, the path to static files does not contain the `domain name/host` in the URL path. This creates a problem. I need all [`url_for`](https://flask.palletsprojects.com/en/2.3.x/api/#flask.url_for) to have an external path which would need 2 things.

- _external
- _scheme

which created 2 more [`flask.config`](https://flask.palletsprojects.com/en/2.3.x/api/#flask.Flask.config") which created

```text
# build.py
build_config = dict(dotenv_values('.buildenv'))

if __name__ == '__main__':
    app.config.from_mapping(build_config)
```

with these 2 in .build

```text
# .buildenv
SERVER_NAME=localhost
URL_SCHEME=http
```

and addition args on every [`url_for`](https://flask.palletsprojects.com/en/2.3.x/api/#flask.url_for)

```jinja2
# *.html.j2 templates
{{ url_for('static_content', path='images/icon.webp', _scheme=config.get('URL_SCHEME')) }}
```

When a `_scheme` arg is present [`url_for`](https://flask.palletsprojects.com/en/2.3.x/api/#flask.url_for) automatically looks for a `SERVER_NAME` so that value doesn't need to be set.

---

### Build dir

this should be simple

```text
.buildenv
BUILD_DESTINATION=../.build
```

```python
# build.py
app.config["FREEZER_DESTINATION"] = build_config.get('BUILD_DESTINATION') or os.path.join(basedir, '.build')
freezer = Freezer(app)
freezer.freeze()
```

done. Try to get the build dir from env, when not present use the default `.build` dir next to `build.py`

---

### S3 error page

to host on s3 I need Flask to also generate the error document

```python
# app/route.py
@app.route('/errors.html')
def error_file():
    return render_template('errors.html.j2', title='karlcch', config=app.config)

@app.errorhandler(404)
def error_not_found(err):
    return error_file(), 404
```

done

## File overview

### app/\_\_init\_\_.py

```python
from flask import Flask
from flask_sitemapper import Sitemapper

app = Flask(__name__)

sitemapper = Sitemapper(https=bool(app.config.get("URL_SCHEME") == "https"))
sitemapper.init_app(app)

# routes must be placed at the bottom
from . import routes
```

### app/routes.py

```python
from io import StringIO, BytesIO
from flask import render_template, send_from_directory, send_file, request
from . import app, sitemapper, pages

@app.route('/static/<path:path>')
def static_content(path):
    return send_from_directory('static', path)

@app.route('/favicon.ico')
def favicon_ico():
    return send_from_directory('resources', 'favicon.ico')

@app.route('/robots.txt')
def robots():
    # get hostname
    hostname = app.config.get('SERVER_NAME') or request.host
    if app.config.get('URL_SCHEME') == 'https':
        hostname = 'https://' + hostname
    else:
        hostname = 'http://' + hostname
    # render file
    robot_file = render_template('robots.txt', hostname=hostname)
    # store to memory as a virtaul file
    mem = BytesIO()
    mem.write(robot_file.encode('utf8'))
    mem.seek(0)

    return send_file(mem, mimetype='text/plain', as_attachment=False, download_name='robots.txt')

@app.route('/errors.html')
def error_file():
    return render_template('errors.html.j2', title='karlcch', config=app.config)

@app.errorhandler(404)
def error_not_found(err):
    return error_file(), 404

@app.route("/sitemap.xml")
def sitemap():
    return sitemapper.generate()
```

### app/pages.py

```python
from flask import render_template
from . import sitemapper, app

@sitemapper.include(lastmod="2024-05-09")
@app.route('/')
def index():
    return render_template('index.html.j2', title='KarlCCH | Home', metadata_description='Home of karlcch', config=app.config)
```

### build.py

```python
from dotenv import dotenv_values
import os
from flask_frozen import Freezer
from app import app

basedir = os.path.dirname(__file__)

build_config = dict(dotenv_values('.buildenv'))

if __name__ == '__main__':
    app.config.from_mapping(build_config)
    app.config["FREEZER_DESTINATION"] = build_config.get('BUILD_DESTINATION') or os.path.join(basedir, '.build')
    freezer = Freezer(app)
    freezer.freeze()
```

Check out the project repo for more additional fun stuff

[ltekme/karlcch](https://github.com/ltekme/karlcch)

and the rest was left for me to continue.

### additional reads

- [廣東話 Build Python Flask 2 Apps with CodeSpace - Cyrus Wong](https://www.youtube.com/watch?v=a2D4bY0jEI0&list=PLtgJR0xD2TPeVeq6azvnKXYSeYHFzGaMi)
- [The Flask Mega-Tutorial - miguelgrinberg.com](https://blog.miguelgrinberg.com/post/the-flask-mega-tutorial-part-i-hello-world)

## Happy building
