# Abacus

**A**rgus **B**inary **A**sset **C**onversion **U**tility **S**cript.
Dead simple Ruby script for converting binary files to C source.

The script will generate a header containing a `extern` declarations for the data and length variables, and a C source
file containing the actual data.

## Basic Usage

```shell
./abacus.rb <path/to/file.dat> [-h <path/to/resource.h>] [-s <path/to/resource.c>]
```

## Arguments

| Flag | Description |
| :-- | :-- |
| `-h` | Path at which header file will be generated |
| `-s` | Path at which source file will be generated |
| `-i` | Input file path. This may instead be supplied as a sole positional argument if desired. |
| `-n` | Name of the file. This can be used to customize the output file name inference if a directory is provided for either output path. |

If either the `-h` or `-c` flags are not supplied, the respective file will not be generated. This is useful for
integration into a build script, where the header file needs to be available immediately after configuration but the
source file can be generated just-in-time when building.

If the value passed to either flag is a directory, its respective output will be generated in the directory with the
file name being inferred from the supplied name or the name of the supplied input file by appending a `.h` or `.c`.

## License

This project is released under the [MIT License](LICENSE).
