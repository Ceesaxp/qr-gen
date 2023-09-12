A command line tool in Golang to generate QR codes from a variety of inputs, i.e.: text, URL, etc.

## Sample use

```bash
$ qr "Hello World" # Generates a QR code with the text "Hello World", 
                   # save it to a file named "qr.png" in the current directory
```

```bash
$ qr "Hello World" -o ~/Desktop/qr.png # Generates a QR code with the text "Hello World", 
                                       # save it to a file named "qr.png" in the Desktop directory
```

```bash
$ qr -f file.txt -o ~/Desktop/qr.png -s 512 # Generates a QR code with the contents of the file "file.txt", save it 
                                            # to a file named "qr.png" in the Desktop directory, with a size 
                                            # of 512x512 pixels
```

```bash
$ cat file.txt | qr -o ~/Desktop/qr.png # Generates a QR code with the contents of the file "file.txt", save it to a 
                                        # file named "qr.png" in the Desktop directory
```

```bash
$ qr -u https://github.com -o ~/Desktop/qr.png # Generates a QR code with the URL "https://github.com", 
                                               # save it to a file named "qr.png" in the Desktop directory
```

## Installation

### From a binary 

Download and copy a binary anywhere in your path.

### From source
