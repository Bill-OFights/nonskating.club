build:
	zola build

render: build
	#!/usr/bin/env bash
	for guide in public/guides/*/index.html; do
		base="$(basename $(dirname $guide))"
		weasyprint "$guide" "$(dirname $guide)/$base.pdf" -s build-assets/print.css		
		pandoc -r commonmark+yaml_metadata_block \
			   -w epub --toc --css build-assets/print.css \
			   --metadata-file build-assets/epub-metadata.txt \
				-M "publisher=https://nonskating.club/guides/$base/" \
			   "content/guides/$base.md" -o "$(dirname $guide)/$base.epub"
	done

watch:
	#!/usr/bin/env bash
	inotifywait -m -r . \
		--exclude "(.*\\.pdf$)|public|justfile|\\.git" \
		-e close_write,move,create,delete \
	| while read -r directory events filename; do
		just render
	done
