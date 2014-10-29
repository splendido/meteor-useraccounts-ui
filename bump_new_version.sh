#!/bin/bash

curr_version=`cat core/package.js | grep version:`
curr_version=${curr_version//[ ]/}
curr_version=${curr_version//version:/}
curr_version=${curr_version//[\"\,]/}

version=(${curr_version//./ })
major=${version[0]}
minor=${version[1]}
patch=${version[2]}

next_major=major
next_minor=minor
next_patch=patch

case "$1" in
        -M)
            ((next_major=major+1))
            next_minor=0
            next_patch=0
            release_type="Major release"
            echo "$release_type!!!"
            ;;
        -m)
            next_major=$major
            ((next_minor=minor+1))
            next_patch=0
            release_type="minor release"
            echo "$release_type!!"
            ;;
        -p)
            next_major=$major
            next_minor=$minor
            ((next_patch=patch+1))
            release_type="patch release"
            echo "$release_type!"
            ;;
        *)
            echo "Usage: $0 {-M|-m|-p}"
            echo "  -M: major relase"
            echo "  -m: minor relase"
            echo "  -p: patch relase"
            exit 1
esac
next_version="$next_major.$next_minor.$next_patch"

echo
echo
echo "Current version: $curr_version"
echo "Major: $major"
echo "Minor: $minor"
echo "Patch: $patch"
echo
echo "Next version: $next_version"
echo "Major: $next_major"
echo "Minor: $next_minor"
echo "Patch: $next_patch"
echo
echo "Publishing version $next_version..."

cd core
echo
echo
pwd
echo "Bumping to version $next_version..."
sed -i "s/version: \"$curr_version\"/version: \"$next_version\"/g" package.js
sed -i "s/useraccounts:core@$curr_version/useraccounts:core@$next_version/g" package.js
git add . --all
git commit -am "$release_type - Bump to version $next_version"
git push
echo "Done!"
#echo "Creating tag..."
#git tag -a "$next_version" -m "$release_type - Bump to version $next_version"
#git push
#git push --tags
#echo "Done!"
echo "Pushing release..."
API_JSON=$(printf '{"tag_name": "v%s", "target_commitish": "master", "name": "v%s", "body": "%s - Bump to version %s", "draft": false, "prerelease": false}' $next_version $next_version "$release_type" $next_version)
curl --data "$API_JSON" "https://api.github.com/repos/meteor-useraccounts/core/releases?access_token=$GITHUB_ACCESS_TOKEN"
echo "Done!"
echo "Now Publishing..."
meteor publish
echo "Done!"
cd ..

for folder in */
do
  if [ "$folder" != "core/" -a "$folder" != "ionic/" -a "$folder" != "ratchet/" ]
  then
    cd $folder
    echo
    echo
    pwd
    echo "Bumping to version $next_version..."
    sed -i "s/version: \"$curr_version\"/version: \"$next_version\"/g" package.js
    sed -i "s/useraccounts:core@$curr_version/useraccounts:core@$next_version/g" package.js
    sed -i "s/useraccounts:unstyled@$curr_version/useraccounts:unstyled@$next_version/g" package.js
    sed -i "s/useraccounts:bootstrap@$curr_version/useraccounts:bootstrap@$next_version/g" package.js
    sed -i "s/useraccounts:foundation@$curr_version/useraccounts:foundation@$next_version/g" package.js
    sed -i "s/useraccounts:semantic-ui@$curr_version/useraccounts:semantic-ui@$next_version/g" package.js
    git add . --all
    git commit -am "$release_type - Bump to version $next_version"
    git push
    echo "Done!"
    #echo "Creating tag..."
    #git tag -a "$next_version" -m "$release_type - Bump to version $next_version"
    #git push
    #git push --tags
    #echo "Done!"
    echo "Pushing release..."
    API_JSON=$(printf '{"tag_name": "v%s", "target_commitish": "master", "name": "v%s", "body": "%s - Bump to version %s", "draft": false, "prerelease": false}' $next_version $next_version "$release_type" $next_version)
    curl --data "$API_JSON" "https://api.github.com/repos/meteor-useraccounts/"$folder"releases?access_token=$GITHUB_ACCESS_TOKEN"
    echo
    echo "Done!"
    echo "Now Publishing..."
    meteor publish
    echo "Done!"
    cd ..
  fi
done

echo "All Done!"