.PHONY: clean svhotspot

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

clean:
	rm -rfv $(SVHOTSPOT_ENV)
	rm -rfv $(MINICONDA_INSTALL_PREFIX)
	rm -rfv $(MINICONDA_INSTALLER)

# references
# https://github.com/conda/conda/issues/7980
# https://stackoverflow.com/questions/53382383/makefile-cant-use-conda-activate/55696820#55696820
# https://towardsdatascience.com/a-guide-to-conda-environments-bc6180fc533
# http://mlg.eng.cam.ac.uk/hoffmanm/blog/2016-02-25-conda-build/
