# there are bashisms used in this Makefile
SHELL=/bin/bash

DIST_VERSION ?= 8
PKGNAME ?= "inmodule"
VERSION=`grep -m1 "^Version:" $(PKGNAME).spec | grep -om1 "[0-9].[0-9.]**"`
RPMS_DIR ?= "packaging/RPMS"

# private variable; points to the number of the pkgname filed separated by dash
# we should refer as subdir. For the defult valur, e.g.:
#   inmoduleA-inmoduleB-....
# refers to "inmoduleA"
_SUBDIR_FIELD ?= 1

# by default use values you can see below, but in case the COPR_* var is defined
# use it instead of the default
_COPR_REPO=$${COPR_REPO:-leapp-tests-modularity}
_COPR_CONFIG=$${COPR_CONFIG:-~/.config/copr_rh_oamg.conf}



all: help

help:
	@echo "Use of one of targets.."

install-deps:
	@rpm -q make modulemd-tools >/dev/null \
		|| dnf install -y make modulemd-tools rpm-build

clean:
	@echo "--- Clean repo ---"
	@rm -rf packaging

clean_all: clean
	@rm -rf repos

prepare: clean
	@echo "--- Prepare build directories ---"
	@mkdir -p packaging/{sources,SRPMS,BUILD,BUILDROOT}/ repos

srpm: prepare
	@echo "--- Build SRPM: $(PKGNAME)-$(VERSION)---"
	@rpmbuild -bs $(PKGNAME).spec \
		--define "_sourcedir `pwd`/packaging/sources"  \
		--define "_srcrpmdir `pwd`/packaging/SRPMS" \
		--define "rhel $(DIST_VERSION)" \
		--define 'dist .el$(DIST_VERSION)' \
		--define 'el$(DIST_VERSION) 1' || FAILED=1

local_build: clean
	@echo "--- Build RPMs: $(PKGNAME)-$(VERSION) ---"
	@rpmbuild -ba $(PKGNAME).spec \
		--target noarch \
		--define "_sourcedir `pwd`/packaging/sources"  \
		--define "_srcrpmdir `pwd`/packaging/SRPMS" \
		--define "_builddir `pwd`/packaging/BUILD" \
		--define "_buildrootdir `pwd`/packaging/BUILDROOT" \
		--define "_rpmdir `pwd`/$(RPMS_DIR)" \
		--define "rhel $(DIST_VERSION)" \
		--define 'dist .el$(DIST_VERSION)' \
		--define 'el$(DIST_VERSION) 1'
	@mkdir -p "$(RPMS_DIR)/`echo $(PKGNAME) | cut -d '-' -f $(_SUBDIR_FIELD)`"
	@mv $(RPMS_DIR)/noarch/* "$(RPMS_DIR)/`echo $(PKGNAME) | cut -d '-' -f $(_SUBDIR_FIELD)`"
	@rm -rf $(RPMS_DIR)/noarch/


_local_build_all:
	@echo "--- Build all RPMs: For RHEL $(DIST_VERSION) ---"
	@mkdir -p repos/$(DIST_VERSION)
	@for PKG in `ls *.spec | sed 's/\.spec$$//'`; do \
		echo "BALIIIIIK::::: $${PKG}" ; \
		PKGNAME="$${PKG}" \
		DIST_VERSION="$(DIST_VERSION)" \
		RPMS_DIR="repos/$(DIST_VERSION)" \
		$(MAKE) local_build ; \
	done


local_build_all: clean_all
	@echo "--- Build all RPMs ---"
	DIST_VERSION=$(DIST_VERSION) $(MAKE) _local_build_all
	DIST_VERSION=$$(($(DIST_VERSION) + 1)) _SUBDIR_FIELD=2 $(MAKE) _local_build_all

_create_repo:
	@echo "--- Prepare RPM modules for RHEL $(DIST_VERSION)"
	@pushd "repos/$(DIST_VERSION)" ; for i in `ls -d inmodule*`; \
		do \
			dir2module -m "$$i" --dir "$$i" "$$i:devel:1:el$(DIST_VERSION):noarch" ; \
		done ; \
		popd
	@echo "--- Create modular DNF repository for RHEL $(DIST_VERSION)"
	@pushd "repos/$(DIST_VERSION)" ; createrepo_mod . ; popd

create_repos: local_build_all
	@echo "--- Create all repositories ---"
	$(MAKE) _create_repo
	DIST_VERSION=$$(($(DIST_VERSION) + 1)) $(MAKE) _create_repo

.PHONY: clean clean_all prepare local_build _local_build_all local_build_all srpm create_repos
