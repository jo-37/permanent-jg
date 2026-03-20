#!/usr/local/bin/jconsole

0 : 0
The not-so-well-known "Johnson-Gentleman tree minor" algorithm 

A fast approach for permanents, but very memory-consuming.

For not-too-large matrices (maybe N<=25 rows, depending on the available
RAM), this method is a few times faster than the Ryser method.
Both are by magnitudes faster than (+/ . *).
For N=25 this one needs some GB of RAM.

Building minor trees.
A k-minor is build from the first k rows and k distinct columns.
It is identified by a pair of a selector and a value.
The selector is the subset indicator of the columns, i.e.
bit m is 1 if column m is part of the minor.
The value is the corresponding permanent of the minor.
The list of all k-minors is transformed into the list of all k+1 minors.
Starting with the empty minor, after N steps the procedure ends with
the single minor that represents the whole matrix.

Taking the P x 2 array of minor selectors and values as input.

Remove minors having a zero value, but always keep at least one minor
)

permanent_jg =: 3 : 0
getrow =. {~ +/@,@#:@((<0 0)&{)   NB. count the bits in the first selector to identify the current row
selectors =. {.@|:@] NB. pick the selector list from the input array
values =. {:@|:      NB. pick the value list from the input array
complements =. [: I. [: -. [: |."1 ] #:~ 2 #~ #@[   NB. Find the complementary columns for each selector
nextvals =. values@>@{.@] * >@{:@] { [ f.    NB. for each complementary column pick the matrix element
                                             NB. and multiply by the minor value
nextsels =. selectors@>@{.@] + >@{:@] (34 b.) 1: f.    NB. for each complementary column calculate the
                                                       NB. corresponding selector
collectminors =. (([ , [: +/ ])/..)&,  NB. flatten the arrays of new values and new selectors,
                                       NB. collect by new minor selectors and sum over the new values
compress =. [: (1 2 $ 0)"_^:(0&=@#) 0&~:@values # ] f. NB. remove zero-valued minors,
                                                       NB. but keep at least one entity
addrow =: getrow ([ ([: compress nextsels collectminors nextvals) ] ; [ complements selectors) ] f. NB. add one row
permpow =. ]`(#@])`[    NB. in power of verb: put the right arg (the matrix) to the left,
                        NB. use the number of rows as the power and put the left arg to the right
perm =. ((<0 1) { (1 2 $ 0 1)"_ addrow^:permpow ]) f.    NB. run N steps and return the value
perm y                  NB. calculate the permanent
)

matrix =: (0&=@|~&>: +. 0&=@|&>:)"0/~@i.  NB. build a matrix
precond =. /:~@|:@(/:~)  NB. preconditioning: sort lexicagraphically, transpose and sort again

3 : 0 (2}. ARGV)
from =. ". > {. y
if.
   1 = # y
do.
   to =. from
elseif.
   2 = # y
do.
   to =. ". > {: y
else.
   echo 'call ''', (> 1&{ ARGV), ' FROM [TO]'' where TO defaults to FROM'
   exit''
end.

NB. For the matrices from A320843 it is crucial to re-arrange them in a form that resembles a lower
NB. triangle.
NB. This can be achieved by lexicographical sorting of columns and rows.

([: echo ] , permanent_jg@precond@matrix)"0 from ([ + [: i. >:@-~) to

)

exit''
