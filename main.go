package main

// A command line tool to generate QR codes from a variety of inputs, i.e.: text, URL, etc.

import (
	"flag"
	"fmt"
	"github.com/skip2/go-qrcode"
	_ "image"
	"image/color"
	"os"
	"strconv"
	"strings"
)

var QrCodeMaxLength = 4296

func main() {
	outFile := flag.String("o", "", "out PNG file prefix, empty for stdout")
	size := flag.Int("s", 256, "image size (pixel)")
	textArt := flag.Bool("t", false, "print as text-art on stdout")
	negative := flag.Bool("i", false, "invert black and white")
	disableBorder := flag.Bool("d", false, "disable QR Code border")
	inpFile := flag.String("f", "", "input file, empty for stdin")
	help := flag.Bool("h", false, "show help")
	foreGroundColor := flag.String("fg", "000000", "foreground color, defaults to black (#000000)")
	backGroundColor := flag.String("bg", "ffffff", "background color, defaults to white (#ffffff)")
	//squaresColor := flag.String("sq", "000000", "squares color")

	flag.Usage = func() {
		showUsage()
	}
	flag.Parse()

	if *help {
		flag.Usage()
		os.Exit(0)
	}

	if len(flag.Args()) == 0 && *inpFile == "" {
		flag.Usage()
		checkError(fmt.Errorf("error: no content given"))
	}

	content := strings.Join(flag.Args(), " ")

	if *inpFile != "" {
		f, err := os.Open(*inpFile)
		checkError(err)
		defer func(f *os.File) {
			err := f.Close()
			if err != nil {
				checkError(err)
			}
		}(f)
		fileInfo, err := f.Stat()
		checkError(err)
		if fileInfo.IsDir() {
			checkError(fmt.Errorf("error: %s is a directory", *inpFile))
		}
		buf := make([]byte, fileInfo.Size())
		_, err = f.Read(buf)
		checkError(err)
		content = string(buf)
	} else if isInputFromPipe() {
		buf := make([]byte, QrCodeMaxLength)
		n, err := os.Stdin.Read(buf)
		checkError(err)
		content = string(buf[:n])
	}

	// Check that overall content length does not exceed QR code capacity.
	if len(content) > QrCodeMaxLength {
		checkError(fmt.Errorf("error: content length %d exceeds QR code capacity", len(content)))
	}

	var err error
	var q *qrcode.QRCode
	q, err = qrcode.New(content, qrcode.Highest)
	checkError(err)

	if *disableBorder {
		q.DisableBorder = true
	}

	if *textArt {
		art := q.ToString(*negative)
		fmt.Println(art)
		return
	}

	if *foreGroundColor != "000000" {
		q.ForegroundColor = convertColorStringToStruct(*foreGroundColor)
	}
	if *backGroundColor != "ffffff" {
		q.BackgroundColor = convertColorStringToStruct(*backGroundColor)
	}

	if *negative {
		q.ForegroundColor, q.BackgroundColor = q.BackgroundColor, q.ForegroundColor
	}

	var png []byte
	png, err = q.PNG(*size)
	checkError(err)

	if *outFile == "" {
		_, err := os.Stdout.Write(png)
		if err != nil {
			checkError(err)
		}
	} else {
		var fh *os.File
		fh, err = os.Create(*outFile + ".png")
		checkError(err)
		defer func(fh *os.File) {
			err := fh.Close()
			if err != nil {
				checkError(err)
			}
		}(fh)
		_, err := fh.Write(png)
		if err != nil {
			checkError(err)
		}
	}
}

func checkError(err error) {
	if err != nil {
		_, err := fmt.Fprintf(os.Stderr, "%s\n", err)
		if err != nil {
			checkError(err)
		}
		os.Exit(1)
	}
}

func showUsage() {
	var err error
	_, err = fmt.Fprintf(os.Stderr, `qr-gen -- QR Code encoder in Go using the https://github.com/skip2/go-qrcode library

Flags:
`)
	if err != nil {
		return
	}
	flag.PrintDefaults()
	_, err = fmt.Fprintf(os.Stderr, `
Usage:
  1. Arguments except for flags are joined by " " and used to generate QR code.
     Default output is STDOUT, pipe to imagemagick command "display" to display
     on any X server.

       qr-gen hello word | display

  2. Save to file if "display" not available:

       qr-gen "homepage: https://github.com/skip2/go-qrcode" > out.png

`)
	if err != nil {
		return
	}
}

func convertColorStringToStruct(colorStr string) color.RGBA {
	r, _ := strconv.ParseUint(colorStr[0:2], 16, 8)
	g, _ := strconv.ParseUint(colorStr[2:4], 16, 8)
	b, _ := strconv.ParseUint(colorStr[4:6], 16, 8)
	rgba := color.RGBA{R: uint8(r), G: uint8(g), B: uint8(b), A: 255}
	return rgba
}

func isInputFromPipe() bool {
	fileInfo, _ := os.Stdin.Stat()
	return fileInfo.Mode()&os.ModeCharDevice == 0
}

//SHA256:uNiVztksCsDhcc0u9e8BujQXVUpKZIDTMczCvj3tD2s.
