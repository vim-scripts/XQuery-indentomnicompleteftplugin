#!/bin/bash

#   
#   Runs XQuery indent tests.  
#
#   If a test fails, it'll leave a .diff in the directory
#
#
#    test #  |  what is it  
#  ----------------------------
#      1      rhs FLOWR expression alignment
#      2      embedded tags  
#      3      FLOWR statement alignment
#      4      Basic nested FLOWR expression
#      5      FLOWR alignment,  let -> function call -> for
#      6      Typeswitch
#      7      function declaration argument alignment (from xqdoc.org pdf p.26)
#      8      searchpairpos() and function param alignment
#      9      nested FLOWR 'return keyword alignment
#     10      Wrapped HTML tag indentation
#     11      Line wrapping for an if statement (from xqdoc.org pdf p.9)
#     12      XML indentation when syntax check dosen't work
#     13      previous keyword alignment should not pass through tags
#     14      no-parens if-else if-else-return alignment
#     15      statement alignment in multi-line where clause
#     16      lines starting with 'import' or 'declare' should always have 0 indent
#     17      basic 'open function call'
#
#

MAX_TEST_COUNT=17

RESULTS_FILE=RESULTS
DIFFS_FILE=DIFFS

# do a little cleanup
rm *.diff
rm $RESULTS_FILE

echo "vi:ft=diff" >> $RESULTS_FILE
echo >>$RESULTS_FILE

for ((n=1; n <=$MAX_TEST_COUNT; ++n))
do
    vim -n -c 'set ft=xquery' -c 'set sw=4' -c 'normal =G' -c ':wq! '$n'.out' $n.in
    diff -u $n.out $n.solution > $n.diff 
    cat $n.diff >> $DIFFS_FILE

    if [ -s $n.diff ]   # 'help test'  -s ==> True if file exists and is not empty.
    then 
        echo "Test $n DID NOT PASS!" >> $RESULTS_FILE
    else 
        echo "Test $n passed!" >> $RESULTS_FILE
        rm $n.diff
    fi
done

# merge em' together
echo >>$RESULTS_FILE
cat $DIFFS_FILE >> $RESULTS_FILE
rm $DIFFS_FILE

echo ""
echo "========================================================================="
echo ""
echo "...XQuery indent tests done! Showing diffs! (if there's anything below,
something got messed up)"
echo ""
echo "   diffs:"
cat *.diff 
echo ""
echo "========================================================================="
echo ""
echo "    $MAX_TEST_COUNT tests performed! see RESULTS for all the test output"
echo ""
echo "========================================================================="
echo "> head -n" $(($MAX_TEST_COUNT + 3)) "RESULTS"
echo ""

head -n $(($MAX_TEST_COUNT+3)) RESULTS

echo ""



# cleanup 
#rm *.out
