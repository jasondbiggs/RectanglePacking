
To build:

```
git clone --recurse-submodules git@github.com:jasondbiggs/RectanglePacking.git
cd rectanglepacking/
mkdir build
cd build
cmake -DWolframLanguage_INSTALL_DIR=/Applications/Mathematica.app/Contents  -DJLLU=4 ..
make -j4 install
```

Then run `PacletDirectoryLoad` in WL on the appropriate directory.