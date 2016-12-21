import os
import requests
import json
import sys
#from subprocess import call

def call_api(owner, repo, subpath, data=None, username=None, password=None):
    """ Takes a subpath under the repository (ex: /releases) and returns the json data from the api """
    api_url = 'https://api.github.com/repos/%s/%s%s' % (owner, repo, subpath)
    # Use Github Authentication if available for the repo
    kwargs = {}
    if username and password:
        kwargs['auth'] = (username, password)

    if data:
        resp = requests.post(api_url, data=json.dumps(data), **kwargs)
    else:
        resp = requests.get(api_url, **kwargs)

    try:
        data = json.loads(resp.content)
        return data
    except:
        return resp.status_code

def set_commit_status():
    ORG_NAME=os.environ.get('GITHUB_ORG_NAME')
    REPO_NAME=os.environ.get('GITHUB_REPO_NAME')
    USERNAME=os.environ.get('GITHUB_USERNAME')
    PASSWORD=os.environ.get('GITHUB_PASSWORD')
    STATE=os.environ.get('STATE')
    CONTEXT=os.environ.get('CONTEXT', 'default')
    DESCRIPTION=os.environ.get('DESCRIPTION',None)
    BUILD_COMMIT=os.environ.get('BUILD_COMMIT')
    BUILD_URL=os.environ.get('BUILD_URL', None)
    
    data = {
        "state": STATE,
        "context": CONTEXT,
    }
    if BUILD_URL:
        data["target_url"] = BUILD_URL

    if not DESCRIPTION:
        DESCRIPTION = 'Build state: %s' % STATE

    data['description'] = DESCRIPTION

    status = call_api(ORG_NAME, REPO_NAME, '/statuses/%s' % BUILD_COMMIT, data=data, username=USERNAME, password=PASSWORD)
    
    print 'Status created:'
    print status

if __name__ == '__main__':
    try:
        set_commit_status()
    except:
        import traceback
        exc_type, exc_value, exc_traceback = sys.exc_info()
        print '-'*60
        traceback.print_exception(exc_type, exc_value, exc_traceback, file=sys.stdout)
        print '-'*60
        sys.exit(1)
