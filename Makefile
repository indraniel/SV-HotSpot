.PHONY: clean svhotspot create-conda-channel update-conda-channel

SHELL := /bin/bash

BUILD_DIR := /build
SVHOTSPOT_ENV := $(BUILD_DIR)/svhotspot-env
MINICONDA_URL := https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
MINICONDA_INSTALLER := $(BUILD_DIR)/Miniconda3-latest-Linux-x86_64.sh
MINICONDA_INSTALL_PREFIX := /opt/mini
CONDA := $(MINICONDA_INSTALL_PREFIX)/bin/conda
CONDA_ACTIVATE := $(MINICONDA_INSTALL_PREFIX)/bin/activate
CONDA_PROFILE := $(MINICONDA_INSTALL_PREFIX)/etc/profile.d/conda.sh
CONDA_BUILD_PATH := $(MINICONDA_INSTALL_PREFIX)/conda-bld/linux-64

SV_HOTSPOT_URL := https://github.com/indraniel/SV-HotSpot
SV_HOTSPOT_LOCAL := $(BUILD_DIR)/SV-HotSpot-conda-builder

all: svhotspot

svhotspot: $(CONDA)
	$(CONDA) create --yes --prefix $(SVHOTSPOT_ENV)
	$(CONDA) install -v --yes --prefix $(SVHOTSPOT_ENV) 'perl>=5.10'
	$(CONDA) install -v --yes --prefix $(SVHOTSPOT_ENV) 'perl-list-moreutils'
	$(CONDA) install -v --yes --prefix $(SVHOTSPOT_ENV) bedtools
	$(CONDA) install -v --yes --prefix $(SVHOTSPOT_ENV) 'r-base>=3.1.0'
	$(CONDA) install -v --yes --prefix $(SVHOTSPOT_ENV) r-ggplot2
	$(CONDA) install -v --yes --prefix $(SVHOTSPOT_ENV) conda-build
	$(CONDA) install -v --yes --prefix $(SVHOTSPOT_ENV) conda-verify
	git clone $(SV_HOTSPOT_URL) $(SV_HOTSPOT_LOCAL)
	cd $(SV_HOTSPOT_LOCAL) && git checkout -b docker-conda origin/docker-conda
	cd $(SV_HOTSPOT_LOCAL) && $(CONDA) build sv-hotspot
	cd $(SV_HOTSPOT_LOCAL) && cp $(CONDA_BUILD_PATH)/sv-hotspot-*.tar.bz2 ..
#	source $(CONDA_PROFILE) && $(CONDA) activate $(SVHOTSPOT_ENV)

$(CONDA): $(MINICONDA_INSTALLER)
	/bin/bash $(MINICONDA_INSTALLER) -u -b -p $(MINICONDA_INSTALL_PREFIX)
	$(CONDA) init bash
	$(CONDA) update -y -n base -c defaults conda
	$(CONDA) config --set env_prompt '({name}) '
	$(CONDA) config --add channels defaults
	$(CONDA) config --add channels bioconda
	$(CONDA) config --add channels conda-forge
	$(CONDA) install -v --yes conda-build
	$(CONDA) install -v --yes conda-verify

$(MINICONDA_INSTALLER):
	curl -k -L -O $(MINICONDA_URL)

update-conda-channel::
define input-arg-error-msg
missing required inputpkg argument, please run:

    make update-conda-channel inputpkg=/path/to/yourpkg.version.tar.bz2


endef

define inputpkg-not-exist-error-msg
Did not find $(inputpkg) on file system!
endef

ifdef inputpkg
	@echo 'got a value for input-pkg ' $(inputpkg)
else
	$(error $(input-arg-error-msg))
endif

# https://stackoverflow.com/questions/5553352/how-do-i-check-if-file-exists-in-makefile-so-i-can-delete-it
ifeq ("$(wildcard $(inputpkg))", "")
	$(error $(inputpkg-not-exist-error-msg))
endif

update-conda-channel::
	echo "inputpkg is: " $(inputpkg)
	git checkout -B conda-channel origin/conda-channel
	cp -v sv-hotspot-*.tar.bz2 channel/linux-64
	cp -v sv-hotspot-*.tar.bz2 channel/linux-32
	cp -v sv-hotspot-*.tar.bz2 channel/osx-64
	cp -v sv-hotspot-*.tar.bz2 channel/win-64
	cp -v sv-hotspot-*.tar.bz2 channel/win-32
	$(CONDA) index channel/
	git add channel/linux-64/repodata.json
	git add channel/linux-32/repodata.json
	git add channel/osx-64/repodata.json
	git add channel/win-64/repodata.json
	git add channel/win-32/repodata.json
	git commit -m "updated conda package $$(date)"
	git push origin conda-channel

create-conda-channel:
	git checkout --orphan conda-channel
	git rm -rf .
	git commit -m 'initialize conda-channel'
	git push origin conda-channel:conda-channel
	git branch --set-upstream-to origin/conda-channel
	mkdir -p channel/{linux-64,linux-32,osx-64,win-64,win-32}
	cp -v sv-hotspot-*.tar.bz2 channel/linux-64
	cp -v sv-hotspot-*.tar.bz2 channel/linux-32
	cp -v sv-hotspot-*.tar.bz2 channel/osx-64
	cp -v sv-hotspot-*.tar.bz2 channel/win-64
	cp -v sv-hotspot-*.tar.bz2 channel/win-32
	git add channel
	git commit -m 'first edition conda build file'
	git push origin conda-channel

clean:
	rm -rfv $(SVHOTSPOT_ENV)
	rm -rfv $(MINICONDA_INSTALL_PREFIX)
	rm -rfv $(MINICONDA_INSTALLER)

# references
# https://github.com/conda/conda/issues/7980
# https://stackoverflow.com/questions/53382383/makefile-cant-use-conda-activate/55696820#55696820
# https://towardsdatascience.com/a-guide-to-conda-environments-bc6180fc533
# http://mlg.eng.cam.ac.uk/hoffmanm/blog/2016-02-25-conda-build/
# https://www.youtube.com/watch?v=HSK-6dCnYVQ
# https://towardsdatascience.com/a-guide-to-conda-environments-bc6180fc533
# https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/create-custom-channels.html
