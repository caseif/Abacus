# Abacus

*A*rgus *B*inary *A*sset *C*onversion *U*tility *S*cript.
Dead simple Ruby script for converting binary files to C source.

The script will generate a header containing a `extern` declarations for the data and length variables, and a C source
file containing the actual data.

## Usage

```shell
./abacus.rb <path/to/file.dat> [-h <path/to/resource.h>] [-c <path/to/resource.c>]
```

## Arguments

| Flag | Description |
| :-- | :-- |
| (none) | Path to the file to generate sources from |
| `-h` | Path at which header file will be generated |
| `-c` | Path at which source file will be generated |

If the `-h` or `-c` flags are not supplied, they will be inferred from the input file path by appending `.h` or `.c`,
respectively. If either flag is a directory, its respective output will be generated in the directory with the file name
being inferred from the input path.

## License

This project is released under the [MIT License](LICENSE).
