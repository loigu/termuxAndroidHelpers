#!/bin/bash

[ -z "$1" ] && from=books.db || from="$1"
[ -z "$2" ] && to=books.txt || to="$2"

if [ "$1" = '-h' ] || [ ! -f "$from" ]; then
	echo "$0 books.db out.txt"
	exit 1
fi

echo "SELECT bookmark_text || char(10) || ' - ' || Authors_name || ', ' || title || char(10) || '%'
FROM (
  SELECT
    Books.title,
    Bookmarks.bookmark_text,
    (
      SELECT group_concat(Authors.name)
      FROM BookAuthor
      JOIN Authors on BookAuthor.author_id=Authors.author_id
      WHERE Books.book_id=BookAuthor.book_id
    ) as Authors_name
  FROM Bookmarks
  JOIN Books on Bookmarks.book_id=Books.book_id
  where Bookmarks.visible = 1
) as subq;" | sqlite3 "$from" > "$to"
