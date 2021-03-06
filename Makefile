info:
	@echo "pypi 		-- uplod to python package index"
	@echo "builddeb		-- build debian (ubuntu 14.04) package"
	@echo "ppa-dev          -- upload to ppa development repo"
	@echo "ppa		-- upload to ppa release repo"
	@echo "man		-- make the manpage"
	@echo "test		-- run tests"

#VERSION=2.1~dev4
VERSION=2.22.1

pypi:
	make man
	python setup.py sdist upload

clean:
	find . -name \*.pyc -exec rm {} \;
	rm -fr build/
	rm -fr dist/
	rm -fr DEBUILD
	(cd doc; make clean)

man:
	(cd doc; make man)

debianize:
	make clean
	make man
	mkdir -p DEBUILD/privacyideaadm.org
	cp -r * DEBUILD/privacyideaadm.org || true
	cp LICENSE DEBUILD/privacyideaadm.org/debian/copyright
	(cd DEBUILD; tar -zcf privacyideaadm_${VERSION}.orig.tar.gz --exclude=privacyideaadm.org/debian  privacyideaadm.org)

builddeb:
	make debianize
	(cd DEBUILD/privacyideaadm.org; debuild)

ppa-dev:
	make debianize
	# build trusty
	(cd DEBUILD/privacyideaadm.org; debuild -sa -S)
	# build xenial
	sed -e s/"trusty) trusty; urgency"/"xenial) xenial; urgency"/g debian/changelog > DEBUILD/privacyideaadm.org/debian/changelog
	(cd DEBUILD/privacyideaadm.org; debuild -sa -S)
	# Upload to launchpad:
	dput ppa:privacyidea/privacyidea-dev DEBUILD/privacyideaadm_${VERSION}*_source.changes

ppa:
	make debianize
	# build trusty
	(cd DEBUILD/privacyideaadm.org; debuild -sa -S)
	# build xenial
	sed -e s/"trusty) trusty; urgency"/"xenial) xenial; urgency"/g debian/changelog > DEBUILD/privacyideaadm.org/debian/changelog
	(cd DEBUILD/privacyideaadm.org; debuild -sa -S)

	dput ppa:privacyidea/privacyidea DEBUILD/privacyideaadm_${VERSION}-*_source.changes

test:
	rm .coverage
	nosetests -v --with-coverage --cover-package=privacyideautils --cover-html tests/test_clientutils.py

