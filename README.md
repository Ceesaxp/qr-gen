A command line tool in Golang to generate QR codes from a variety of inputs, i.e.: text, URL, etc.

Based on the sample app in https://github.com/skip2/go-qrcode by [Tom Harwood](https://github.com/skip2).

What was changed:

1. Read file an/or STDIN as input (not only text provided)
2. Assign foreground/backgreound colors for the QR generated
3. Check for the content length not to exceed QR limit of 4296 chars

## Sample use

```bash
# Generates a QR code with the text "Hello World", save it to a file named "qr.png" 
# in the current directory
$ qr "Hello World"
```

```bash
# Generates a QR code with the text "Hello World", save it to a file named "qr.png" 
# in the Desktop directory
$ qr "Hello World" -o ~/Desktop/qr.png
```

```bash
# Generates a QR code with the contents of the file "file.txt", save it to a file 
# named "qr.png" in the Desktop directory, with a size of 512x512 pixels
$ qr -f file.txt -o ~/Desktop/qr.png -s 512 
```

```bash
# Generates a QR code with the contents of the file "file.txt", save it to a 
# file named "qr.png" in the Desktop directory
$ cat file.txt | qr -o ~/Desktop/qr.png
```

```bash
# Generates a QR code with the URL "https://github.com", save it to a file
# named "qr.png" in the Desktop directory
$ qr -u https://github.com -o ~/Desktop/qr.png 
```

## Installation

### From a binary 

Download and copy an appropriate for your platform binary anywhere in your path.

### From source

Checkout the repo and run

```bash
$ make build && make package
```

This will place all the binaries in the `./bin` directory.

Run `make` without any arguments to see all the available options.

Alternatively – just run `go build .` in the root of the repo.
