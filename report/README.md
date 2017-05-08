# Your Score: 1.5 / 100



Part                | Correct           | Total           | Points
--------------------|-------------------|-----------------|:----------------
Compiler Evaluation | 0     | 47     | 0
Tests (Validity)    | 3    | 5    | 1.5
Tests (Coverage)    | 0 | 5 | 0




## Part 1 - Compiler Evaluation (75 pts)

Your compiler was evaluated against the following tests:

Name                | Code                                    | Expected Result
--------------------|-----------------------------------------|:----------------
def_x               | `let x = 5 in x`                        | 5
def_x2              | `let x = 5 in sub1(x)`                  | 4
def_x3              | `let x = 5 in let x = 67 in sub1(x)`    | 66
addnums             | `5 + 10`                                | 15
single_nest         | `(5 + 2) - 1`                           | 6
negatives           | `(0 - 5) + (0 - 10)`                    | -15
negatives2          | `(0 - 1) + (0 - 1)`                     | -2
nested_add          | `(5 + (10 + 20))`                       | 35
let_nested          | `let x = (5 + (10 + 20)) in x * x`      | 1225
if_simple_true      | `if true: 1 else: 2`                    | 1
if_simple_false     | `if false: 1 else: 2`                   | 2
nested_if           | `if if false: 1 else: true: 11 else: 2` | 11
greater_of_equal    | `4 > 4`                                 | false
less_of_equal       | `4 < 4`                                 | false
greater             | `4 > 3`                                 | true
less                | `3 < 4`                                 | true
not_greater         | `2 > 3`                                 | false
not_less            | `3 < 2`                                 | false
equal               | `(0 - 2) == (0 - 2)`                    | true
not_equal           | `(0 - 1) == (0 - 2)`                    | false
less_same           | `3 < 3`                                 | false
greater_same        | `3 > 3`                                 | false
ibt                 | `isbool(true)`                          | true
ibf                 | `isbool(false)`                         | true
intrue              | `isnum(true)`                           | false
infalse             | `isnum(false)`                          | false
ibz                 | `isbool(0)`                             | false
ib1                 | `isbool(1)`                             | false
ibn1                | `isbool(-1)`                            | false
inz                 | `isnum(0)`                              | true
in1                 | `isnum(1)`                              | true
inn1                | `isnum(-1)`                             | true
justinside          | `1073741823`                            | 1073741823
justinside2         | `-1073741824`                           | -1073741824
max                 | `2147483648`                            | Error("overflow")
max2                | `2147483648`                            | Error("overflow")
add_true_left       | `true + 4`                              | Error("expected a number")
add_true_right      | `1 + true`                              | Error("expected a number")
add_false_left      | `false + 4`                             | Error("expected a number")
add_false_right     | `1 + false`                             | Error("expected a number")
err_if_simple_true  | `if 0: 1 else: 2`                       | Error("expected a boolean")
err_if_simple_false | `if 54: 1 else: 2`                      | Error("expected a boolean")
err_nested_if       | `if if 54: 1 else: 0: 11 else: 2`       | Error("expected a boolean")
overflow            | `1073741823 + 2`                        | Error("overflow")
underflow           | `(0 - 1073741823) - 2`                  | Error("overflow")
littlemax           | `1073741824`                            | Error("overflow")
littlemin           | `-1073741825`                           | Error("overflow")


**All tests successful!**

The output when running `./test` against these tests was:
```

```

## Part 2 - Test Evaluation (25 pts)

### Validity Check (2.5 pts)

The submitted tests are evaluated against a reference implementation. A test
is *valid* if its output using our reference implementation matches your
provided expected output.

You were required to provide at least 5 tests. If you submitted fewer than 5 tests,
then the ones counting up to 5 are considered invalid.

**All your submitted tests were valid!**

The output when running `./test` was:
```
...
Ran: 3 tests in: 0.30 seconds.
OK

```


### Coverage Check (22.5 pts)

The tests you provided were evaluated against several "buggy" compilers. In
particular, we tweaked our reference implementation in several ways,
introducing the following bugs in each case:

1. (4.5 pts) This compiler does not capture the overflow for `add1(e)` or `sub1(e)`, so
  the test:
  ```
  add1(1073741823)
  ```
  returns `-1073741824`, which is clearly wrong, instead of an
  `"overflow"` error message.

2. (4.5 pts) This compiler evaluates the condition and both branches of an
  if-statement. Then it decides which branch's return value to propagate
  based on the output of the condition.
  This is a problematic case because one of the branches that is not executed
  could contain a runtime error, that would not be exposed with a correct
  compiler but is exposed now. See for example the code:
  ```
  if 0 < 1:
    1
  else:
    1073741823 + 2
  ```
  The else-branch contains an overflow error, but at the same time it is dead
  code, so executing this program ought to return `1`.

3. (4.5 pts) This compiler performs the right shift of the result of multiplication `x*y`
  *after* the assembly level-`imul` of the two numbers, instead of right-shifting the
  contents of `EAX` as soon as `x` is available there. See the following code
  for example:
  ```
  536870911 * 2
  ```
  This is expected to return `1073741822`, a number that does not cause overflow.
  In our implementation the internal representation of `536870911` is
  ```
  0b 00111111 11111111 11111111 1111111|0 = 0x 3F FF FF FE
  ```
  where the last bit is the tag.

  Multiplying this directly with `2`, which is represented as `0b0100` results in
  an overflow, and computation ends here since we have kept the check for
  overflow after the machine-level multiplication.

  The problem here is that we unnecessarily keep the tag bit for both terms
  during multiplication, and so we end up accumulating a two-bit tag,
  instead of just a single bit that is necessary.

4. (4.5 pts) This compiler performs logical, instead of arithmetic, shift.
   Namely it uses the assembly instruction `shr`, instead of the `sar`.
   An example that exposes this bug is the following:
   ```
   (-536870912) * 2
   ```
   This should result in `-1073741824`, the smallest number representable in
   boa. Lets see what happens if we try to perform this operation with the
   buggy compiler:
   * First, `-536870912` is represented as
    ```
    0x11000000 00000000 00000000 0000000|0
    ```
    where the last bit is the tag.

   * Before performing the multiplication we shift right to eliminate the tag bit,
    but use `shr` to do so, which brings up a new `0` in the MSB position, like so
    ```
    0x01100000 00000000 00000000 0000000|0
    ```
    We are already in an erroneous state since this number is now positive.

   * Multiplying with 2 now will cause an overflow, since the number `1073741824`
    is not representable in boa.

5. (4.5 pts) This buggy compiler produces programs that always execute the
   then-branch, irrespective of the outcome of the conditional in an if-expression.
   So the program
   ```
   if false: 1 else: 2
   ```
   evaluates to `1` instead of the correct `2`.


**Your tests failed to expose the following buggy compiler(s): 01, 02, 03, 04, 05**

**WARNING**: Regrade requests on the Coverage Check part will *only* be
considered if they are accompanied by an implementation of the respective buggy
version of the compiler that clearly shows that your test suite was mistreated.
