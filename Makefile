source := src
output := output
sources := $(wildcard $(source)/*.md)

		# --include-in-header=preamble.tex \

all: $(output)/fds-book.pdf

$(output)/fds-book.pdf:	$(sources)
	cat $^ | pandoc \
		--verbose \
		--pdf-engine=xelatex \
		--toc \
		--template=template/acmlarge.tex \
		--highlight-style=tango \
		-o $@ \

.PHONY : clean

clean:
	rm -f $(output)/*.pdf
