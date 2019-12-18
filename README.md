# SV-HotSpot

## How to build the conda package

```bash
git clone https://github.com/indraniel/SV-HotSpot
cd SV-HotSpot
git checkout -b docker-conda origin/docker-conda
docker build -t svhotspot:v1 .
docker run -i -t -v $PWD:/build --rm svhotspot:v1 /bin/bash
make

# Test conda package
/opt/mini/bin/conda init bash
source ~/.bashrc
conda activate /build/svhotspot-env/
conda install --yes \
    --channel bioconda \
    --channel conda-forge \
    --channel local \
    --channel default \
    sv-hotspot

which sv-hotspot.pl  # should be /build/svhotspot-env/bin/sv-hotspot.pl
sv-hotspot.pl --help
conda deactivate

# setup github access in docker container
git config --global user.name "indraniel"
git config --global user.email "indraniel@gmail.com"

# do this only once if the conda-channel branch doesn't exist in the github repo
make create-conda-channel

# upload the tar.bz2 to the custom github conda channel
make update-conda-channel inputpkg=./sv-hotspot-1.0.2-pl526r36_0.tar.bz2

# try installing from the custom conda channel
cd /build

conda create --yes --prefix /build/test-github-install
conda activate /build/test-github-install

conda install --yes \
    --channel bioconda \
    --channel conda-forge \
    --channel https://raw.githubusercontent.com/indraniel/SV-HotSpot/conda-channel/channel/  \
    --channel default \
    sv-hotspot

which sv-hotspot.pl  # should be /build/svhotspot-env/bin/sv-hotspot.pl
sv-hotspot.pl --help

conda deactivate

# clean up
rm -rf /build/test-github-install
make clean
```

