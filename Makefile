source := src
output := output
sources := $(wildcard $(source)/*.md)


all: $(output)/fds-book.pdf

$(output)/fds-book.pdf:	$(sources)
	cat $^ | pandoc \
		--pdf-engine=xelatex \
		--include-in-header=preamble.tex \
		--template=eisvogel.tex \
		-o $@

.PHONY : clean

clean:
	rm -f $(output)/*.pdf
