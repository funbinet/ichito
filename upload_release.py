import os
import json
import urllib.request
import urllib.error

github_token = os.environ.get('GITHUB_TOKEN')
codeberg_token = os.environ.get('CODEBERG_TOKEN')
version = 'v1.7.0'
notes = "Phase 3 complete: Interactive Order Workflow & Management, Order Wizard, and Timeline"
apk_path = 'build/app/outputs/flutter-apk/app-release.apk'

def create_github_release():
    print("Creating GitHub release...")
    url = 'https://api.github.com/repos/funbinet/ichito/releases'
    data = json.dumps({
        'tag_name': version,
        'name': f'ICHITO Release {version}',
        'body': notes,
        'draft': False,
        'prerelease': False
    }).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    })
    try:
        with urllib.request.urlopen(req) as response:
            res = json.loads(response.read().decode())
            release_id = res['id']
            upload_url = res['upload_url'].split('{')[0]
            print(f"GitHub Release ID: {release_id}")
            return upload_url
    except urllib.error.HTTPError as e:
        print(f"GitHub API Error: {e.read().decode()}")
        # Check if release already exists
        if e.code == 422:
            print("Release might already exist. Fetching existing release...")
            req = urllib.request.Request(f'https://api.github.com/repos/funbinet/ichito/releases/tags/{version}', headers={
                'Authorization': f'token {github_token}',
                'Accept': 'application/vnd.github.v3+json'
            })
            with urllib.request.urlopen(req) as response:
                res = json.loads(response.read().decode())
                return res['upload_url'].split('{')[0]
        return None

def upload_github_asset(upload_url):
    print("Uploading GitHub asset...")
    with open(apk_path, 'rb') as f:
        data = f.read()
    
    url = f"{upload_url}?name=ichito-android-arm64-{version}.apk"
    req = urllib.request.Request(url, data=data, headers={
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/vnd.android.package-archive'
    })
    try:
        with urllib.request.urlopen(req) as response:
            print("GitHub asset uploaded.")
    except urllib.error.HTTPError as e:
        print(f"GitHub Asset Upload Error: {e.read().decode()}")

def create_codeberg_release():
    print("Creating Codeberg release...")
    url = 'https://codeberg.org/api/v1/repos/funbinet/ichito/releases'
    data = json.dumps({
        'tag_name': version,
        'name': f'ICHITO Release {version}',
        'body': notes,
        'draft': False,
        'prerelease': False
    }).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={
        'Authorization': f'token {codeberg_token}',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    })
    try:
        with urllib.request.urlopen(req) as response:
            res = json.loads(response.read().decode())
            release_id = res['id']
            print(f"Codeberg Release ID: {release_id}")
            return release_id
    except urllib.error.HTTPError as e:
        print(f"Codeberg API Error: {e.read().decode()}")
        if e.code == 409:
            print("Release might already exist. Fetching existing release...")
            req = urllib.request.Request(f'https://codeberg.org/api/v1/repos/funbinet/ichito/releases/tags/{version}', headers={
                'Authorization': f'token {codeberg_token}',
                'Accept': 'application/json'
            })
            with urllib.request.urlopen(req) as response:
                res = json.loads(response.read().decode())
                return res['id']
        return None

def upload_codeberg_asset(release_id):
    # Using curl for multipart file upload since urllib makes it hard
    import subprocess
    print("Uploading Codeberg asset...")
    cmd = [
        'curl', '-s', '-X', 'POST',
        f'https://codeberg.org/api/v1/repos/funbinet/ichito/releases/{release_id}/assets',
        '-H', 'accept: application/json',
        '-H', f'Authorization: token {codeberg_token}',
        '-F', f'attachment=@{apk_path};type=application/vnd.android.package-archive',
        '-F', f'name=ichito-android-arm64-{version}.apk'
    ]
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode == 0 and "id" in res.stdout:
        print("Codeberg asset uploaded.")
    else:
        print(f"Codeberg Asset Upload Error: {res.stdout}")

if __name__ == '__main__':
    gh_upload_url = create_github_release()
    if gh_upload_url:
        upload_github_asset(gh_upload_url)
        
    cb_release_id = create_codeberg_release()
    if cb_release_id:
        upload_codeberg_asset(cb_release_id)
