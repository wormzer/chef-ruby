GEM_DIR="`gem env gemdir 2>/dev/null`"
if [ $? = 0 ]
then
  PATH="$PATH:$GEM_DIR/bin"
fi
