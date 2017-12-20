find . -regextype sed -regex '\./[A-Za-z0-9]\{54\}' -exec rm -rf {} \;

