import os
import json
import urllib.request
import urllib.error

github_token = os.environ.get('GIT_TOKEN') or os.environ.get('GITHUB_TOKEN')
codeberg_token = os.environ.get('CODEBERG_TOKEN')
version = 'v4.0.0'
try:
    with open('release_notes_4.0.0.md', 'r') as f:
        notes = f.read()
except Exception:
    notes = "ICHITO Release v4.0.0"
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
            try:
                with urllib.request.urlopen(req) as response:
                    res = json.loads(response.read().decode())
                    return res['upload_url'].split('{')[0]
            except Exception as ex:
                print(f"Error fetching existing GitHub release: {ex}")
        return None

def upload_github_asset(upload_url, release_id=None):
    if release_id:
        print("Checking for existing GitHub assets to delete...")
        req = urllib.request.Request(f'https://api.github.com/repos/funbinet/ichito/releases/{release_id}/assets', headers={
            'Authorization': f'token {github_token}',
            'Accept': 'application/vnd.github.v3+json'
        })
        try:
            with urllib.request.urlopen(req) as response:
                assets = json.loads(response.read().decode())
                for asset in assets:
                    if asset['name'] == f"ichito-android-arm64-{version}.apk":
                        print(f"Deleting existing GitHub asset: {asset['id']}")
                        del_req = urllib.request.Request(f"https://api.github.com/repos/funbinet/ichito/releases/assets/{asset['id']}", method='DELETE', headers={
                            'Authorization': f'token {github_token}',
                            'Accept': 'application/vnd.github.v3+json'
                        })
                        urllib.request.urlopen(del_req)
        except Exception as ex:
            print(f"Error checking/deleting existing GitHub assets: {ex}")

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
            try:
                with urllib.request.urlopen(req) as response:
                    res = json.loads(response.read().decode())
                    return res['id']
            except Exception as ex:
                print(f"Error fetching existing Codeberg release: {ex}")
        return None

def upload_codeberg_asset(release_id):
    # Check and delete existing assets first
    print("Checking for existing Codeberg assets to delete...")
    req = urllib.request.Request(f'https://codeberg.org/api/v1/repos/funbinet/ichito/releases/{release_id}/assets', headers={
        'Authorization': f'token {codeberg_token}',
        'Accept': 'application/json'
    })
    try:
        with urllib.request.urlopen(req) as response:
            assets = json.loads(response.read().decode())
            for asset in assets:
                if asset['name'] == f"ichito-android-arm64-{version}.apk":
                    print(f"Deleting existing Codeberg asset: {asset['id']}")
                    del_req = urllib.request.Request(f"https://codeberg.org/api/v1/repos/funbinet/ichito/releases/assets/{asset['id']}", method='DELETE', headers={
                        'Authorization': f'token {codeberg_token}',
                        'Accept': 'application/json'
                    })
                    urllib.request.urlopen(del_req)
    except Exception as ex:
        print(f"Error checking/deleting existing Codeberg assets: {ex}")

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
    gh_release_id = None
    gh_upload_url = None
    print("Fetching GitHub release...")
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
            gh_release_id = res['id']
            gh_upload_url = res['upload_url'].split('{')[0]
    except urllib.error.HTTPError as e:
        if e.code == 422:
            req = urllib.request.Request(f'https://api.github.com/repos/funbinet/ichito/releases/tags/{version}', headers={
                'Authorization': f'token {github_token}',
                'Accept': 'application/vnd.github.v3+json'
            })
            try:
                with urllib.request.urlopen(req) as response:
                    res = json.loads(response.read().decode())
                    gh_release_id = res['id']
                    gh_upload_url = res['upload_url'].split('{')[0]
            except Exception:
                pass
                
    if gh_upload_url:
        upload_github_asset(gh_upload_url, gh_release_id)
        
    cb_release_id = create_codeberg_release()
    if cb_release_id:
        upload_codeberg_asset(cb_release_id)
