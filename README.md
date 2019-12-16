# SV-HotSpot

## How to build the conda package

```bash
git clone https://github.com/indraniel/SV-HotSpot
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
```
