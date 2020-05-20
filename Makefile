source := src
output := output
sources := $(wildcard $(source)/*.md)


all: $(output)/fds-book.pdf

$(output)/fds-book.pdf:	$(sources)
	cat $^ | pandoc \
		-f markdown+implicit_figures \
		--pdf-engine=xelatex \
		--include-in-header=preamble.tex \
		--template=eisvogel.tex \
		--top-level-division=chapter \
		--number-sections \
		-o $@

.PHONY : clean

clean:
	rm -f $(output)/*.pdf
