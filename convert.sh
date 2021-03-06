#!/bin/bash

DIRECTORY=test
mkdir -p $DIRECTORY.as3tidy
mkdir -p $DIRECTORY.hx

# First run as3tidy sed conversion...
(
  cd $DIRECTORY
  find . -name '*.as' | \
  while read f
  do
    mkdir -p ../$DIRECTORY.as3tidy/$( dirname $f )
    sed -Ef ../as3tidy.sed $f > ../$DIRECTORY.as3tidy/$f
  done
)

# Now run as3tohx...
~/dev/as3tohx_project/as3hx/as3tohx -convert-flexunit --debug-inferred-type $DIRECTORY.as3tidy $DIRECTORY.hx

# Now do post-processing with sed...
(
  cd $DIRECTORY.hx
  find . -type f -name '*.hx' | \
  while read f; do
    sed -Ef ../as3posttidy.sed $f > $f.tmp
    mv $f.tmp $f
  done
)

echo 'Comparing results...'
if ! cmp test/conversionTest_golden.hx test.hx/com/as3tohx/test/ConversionTest.hx
then
  echo 'Found some differences...'
   #diff test/conversionTest_golden.hx test.hx/as3tohx/ConversionTest.hx
else
  echo 'Files match golden!'
fi

