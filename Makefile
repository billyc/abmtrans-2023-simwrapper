# --------------------------------------------------
# standard Makefile preamble see https://tech.davis-hansson.com/p/make/
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
ifeq ($(origin .RECIPEPREFIX), undefined)
  $(error Your Make does not support .RECIPEPREFIX. Use GNU Make 4.0 or later)
endif
.RECIPEPREFIX = >
# --------------------------------------------------

cur_dir = $(shell pwd)

SRC = src
TEX = Paper

PNG_IMAGES := $(shell find $(SRC)/images -name "*.jpg")
PDF_IMAGES := $(patsubst %.jpg, %.jpg.pdf, $(PNG_IMAGES))

build: build/$(TEX).pdf
.PHONY: build

build/$(TEX).pdf: Makefile $(shell find $(SRC)/*)
> rm -rf build
> mkdir -p build
> cd $(SRC)
> pdflatex --output-directory ../build $(TEX).tex
> cd ../build
> BIBINPUTS=../$(SRC):~/shared-svn/documents/inputs/bib bibtex $(TEX)
> cd ../$(SRC)
> pdflatex --output-directory ../build $(TEX).tex
> pdflatex --output-directory ../build $(TEX).tex

serve:
> fswatch -o src | xargs -n1 -I{} gmake
.PHONY: serve

#> inotifywait -qrm --event modify src/* | while read file; do make; done

images: $(PDF_IMAGES)
.PHONY: images

%.jpg.pdf: %.jpg
> convert -compress LZW $*.jpg pdf:$*.jpg.pdf


clean:
> rm -rf $(SRC)/*.aux
> rm -rf $(SRC)/*.pdf
> rm -rf $(SRC)/*.out
> rm -rf build/*
.PHONY: clean
