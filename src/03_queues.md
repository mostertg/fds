
# Queues

> "Transmit the message / To the receiver / Hope for an answer some day"
>Talking Heads, "Life During Wartime", Fear of Music, 1979


## Simple queues

The word "queue" comes to us from French (it means "tail"). A queue can be viewed as a modification of a sequence where we add only at the end, while still removing from the front. (If we can add and remove at both ends, it is often called a "double-ended queue" or "deque" for short, pronounced "deck".) Queues have immediate application in situations where first-come, first-served processing is appropriate, and for use as buffers between computations that produce/consume information at different rates. They are also a useful component in many algorithms, for example in doing a breadth-first search of an explicit or implicit tree.

The operations are usually called enqueue, dequeue, and front. Those names are a bit awkward, and better suited to a mutable implementation. We’ll form an immutable Queue ADT by taking the Sequence ADT and removing the `extend` and `index` operations (keeping `empty`, _first_, and _rest_) and including the _snoc_ operation for adding to the end of the queue. This operation consumes a queue $Q$ and an element $e$, and produces the queue $Q,e$.

```{ocaml}
module type Queue = sig
  type 'a queue

  val empty : 'a queue
  val isEmpty : 'a queue -> bool

  val _snoc_ : 'a -> 'a queue -> 'a queue
  val first : 'a queue -> 'a option
  val rest : 'a queue -> 'a queue option
end

```

A Deque ADT would add back `extend` and would also add a "remove from end" operation (which one is tempted to call `tser`).

We can adapt our list-based implementation of the Sequence ADT to get a persistent implementation of Queue. But in order to implement _snoc_, we need to append the added element to the end of a list. This takes as much time as appending a whole list to the end of another list, which can be done with the OCaml infix `@` operator, or code like this:

```{ocaml}
let rec append lst1 lst2 =
  match lst1 with
    | [] -> lst2
    | h :: t -> h :: append t lst2

```

It’s not hard to see that this takes time $O(n)$, where $n$ is the length of the first list, and the length of the second list plays no role. append can be used to implement _snoc_ in a list-based implemention of Queue by making the second argument a list containing only the element to be added at the end of the queue. But the time for this operation is unacceptably slow. We can do better.

**Exercise 13**: Write OCaml code to implement the Deque ADT with a pair consisting of a Braun tree and the number of nodes it has, and show that your code achieves $O(log\ n)$
time for all operations, where n is the number of elements in the deque. This result is due to Hoogerwoord, from 1992. $\blacksquare$

In contrast, adapting the array-based implementation of Sequence does even better, at least superficially. As we did with Sequence, we will only briefly describe the conventional approach using arrays. But we will be using mutation in our functional implementations, so it’s time for a brief introduction to the OCaml syntax.



### Mutation in OCaml

In OCaml, the type `’a ref` (for "reference") is mutable. A value of this type can be dereferenced with the prefix `!` operator. That is, if `r` is of type `’a ref`, then `!r` is of type `’a`. The value can be mutated with the infix assignment operator `:=` (the left side has to have type `’a ref`, and the right side of type `’a`). An expression `r := aval` has value `()`, which is the unique value of type `unit`, and is intended to convey no information. Sequencing of expressions is done with the infix operator single semicolon (`;`). In the expression `e1 ; e2`, `e1` must have type `unit`, and the value of the whole expression is the value of `e2`. The `;` operator is left-associative, so it is easy to sequence several operations, parenthesizing as necessary.

We will not be using arrays extensively until Chapter 5, but I’ll introduce the syntax here for quick reference. Array operations are provided by the module `Array`. The function `Array.make` consumes an integer size and an initial value, and produces an array of that size initialized to the value. Arrays are indexed from 0. The expression `Array.get a i` gets the value of array `a` at index `i`. This can also be written `a.(i)`. (You may be used to using square brackets, but OCaml reserves those for strings, as we’ll see in Chapter 5.) The expression `Array.set a i v` mutates the value of array `a` at index `i` to be `v`. This can also be written with the shorthand `a.(i) <- v`. Both of these expressions produce `()`. There are many other operations available, which you can learn about by consulting the documentation. The type constructor for arrays is postfix `array`. This is analogous to postfix `list`, in that a given array must store all elements of the same type, but we can write functions that are polymorphic in the element type.

The substitution model of computation needs to be made more complicated to deal with mutation. A name-value binding becomes a name-location binding plus a location-value mapping, and mutation changes the location-value mapping. This is essentially an abstraction of the way physical computer memory works.

Although I have introduced the syntax for mutation and arrays here, you should avoid using it in your code unless I specifically suggest its use. For maximum benefit from what follows, stick to purely functional implementations when you can.

OCaml has `for` and `while` loops, but these lack the `break` and `continue` features often found in imperative languages, and they do not produce useful values (they type as `unit`). As a result, they fit awkwardly with more functional code. The reason for these restrictions is that the OCaml interpreter and compiler do **tail-call optimization**. If the recursive applications in the body of a recursive function are in "tail position" (intuitively, no further computation needs to be done after they produce a value), then they are optimized to a loop, computationally. (There is an example in the next section.) Functions written in a tail-recursive fashion are an effective substitute for loops.



### Using arrays for queues

Recall that the array-based implementation of Sequence keeps the sequence in reverse order in an array, with a pointer (integer index) to the next insertion point. Since for a queue, we are adding at the end, we don’t need to use reverse order, and we can keep the queue in regular order in the array. If we are inserting at the end of the queue and removing from the front, we can keep pointers to both front and end, so that the queue consists of a contiguous sequence of elements in the array. This will, in the normal course of operation, creep down towards the end of the array, which we handle by wrapping around to the front again. That is, the queue is a contiguous sequence of elements on the edge of a circle, which is mapped onto the array, so that the last element of the array is followed by the first one.

The resulting code is the type of problem often seized upon as significant in whiteboard coding interviews (because it is slightly nontrivial) and the solution has all operations running in $O(1)$ time. It is often called a "circular buffer" or a "bounded buffer", which is a more honest name, because this implementation inherits all the problems of the previous array-based implementation of Sequence: it implements a mutable ADT by using mutation heavily, it is not persistent, and one has to deal with the case when the array fills up.

**Exercise 14**: Implement a bounded buffer datatype in your favourite imperative language, or try it using OCaml. There are some decisions to be made about exactly where the front and end pointers point to, which affect the maximum number of elements in the buffer, and the empty and full tests. $\blacksquare$

With mutable lists, we can get rid of the size restriction, at least. We maintain pointers to the head and tail elements of the list, and mutate the "rest" field of the tail element to add a new element. Once again, the code is slightly nontrivial. The implementation still implements the mutable ADT, and is not persistent.

**Exercise 15**: Implement queues using mutable lists in your favourite imperative language, or try it using OCaml (adapt the `mylist` datatype from section 2.2.5 to allow mutation of `Cons` arguments). $\blacksquare$

Our goal in this section is to achieve an immutable, persistent implementation in which all operations take $O(1)$ time. Along the way, we will expand our notion of algorithm analysis, and see some new OCaml programming features. Queues are useful for glueing together components that may be processing data at different rates, and this also tends to happen in the big data situations that we previously identified as good candidates for immutable, persistent implementations.

The operations on Sequence took $O(1)$ time because adding an element at the front of the sequence uses `Cons`, and because removing an element uses pattern matching to, in effect, undo `Cons`. Lists are biased towards the front. If we kept the queue in a list in `reverse` order, then _snoc_ would take $O(1)$ time. But _first_ and _rest_ would take $O(n)$ time (where $n$ is the number of elements in the queue), since the front of the queue would be at the end of the list.

We can try to get the best of both worlds by keeping two lists.

```{ocaml}
type queue = ’a list * ’a list

```

The first list will be the front several items of the queue (where "several" varies with time). The second list will be the rest of the items (at the rear of the queue) in reverse order. _first_ and _rest_ operate primarily on the first list, and _snoc_ operates primarily on the second list (where "primarily" has to be carefully defined).

If we are lucky, these operations will take $O(1)$ time. Adding to the rear of the queue is adding to the front of the second list. The problem is when, for example, _first_ is applied to a nonempty queue whose first list is empty. The result is at the end of the second list. We are not going to be able to get to that in constant time.

If the first list is empty and the second list has $n$
elements, then first will take $O(n)$ time. In that amount of time (with a different but still modest hidden constant) we can reverse the entire old second list and make the result the new first list. The new second list will then be empty.

Reversing a list efficiently is not trivial. Pure structural recursion alone will not do it.

```{ocaml}
let rec rev1 lst = function
  | [] -> []
  | h :: t -> (rev1 t) @ [h]

```

The above code takes $O(n^2)$ time to reverse a list of length $n$. To do better, we can still process the list in a structurally-recursive fashion, but add an accumulator argument that accumulates the result in reverse order.

```{ocaml}
let rev2 lst =
  let rec revh acc = function
    | [] -> acc
    | h :: t -> revh (h :: acc) t
  in revh [] lst

```

When `rev2` is applied to a list of length $n$, there are $n+1$ applications of `revh`, each taking $O(1)$ time, so the total time is $O(n)$.

The function `revh` is an example of tail recursion that will be optimized into a loop, because the recursive application is the entire answer of a clause of the implicit `match`, which is the entire body of the function `revh`. For an example of recursive code that is not tail-recursive, look at the inefficient, structurally-recursive `rev1` function just above, which does more computation (the append, using `@`) after the recursive application.

**Exercise 16**: Analyze these two implementations of `rev` and confirm the claimed running times. $\blacksquare$

The example which prompted the use of `rev` was when `first` was applied to a queue with first list empty and second list nonempty. But we can’t make this solution the responsibility of _first_, since it doesn’t produce a new queue. Instead, we code _rest_ and _snoc_ so that they never produce a queue with an empty first list unless the second list is also empty. This will be an **invariant** of our data structure that needs to be preserved by every operation. (We will be using such invariants a lot in what follows.)

If the first list of the result would be empty while the second list is nonempty, we reverse the second list, make it the new first list, and make the new second list empty. As a result, _first_ will never encounter an empty first list, so it will always take $O(1)$ time.

That doesn’t improve the running time of _rest_ and _snoc_, each of which may have to do a reversal to maintain the invariant. They are still going to take $O(n)$ time when the second list (to be reversed) has n elements. But how did we get to this point? The second list is added to by _snoc_. If it contains $n$ elements, then there must have been $n$ applications of _snoc_ that each took $O(1)$ time. If we take the cost of reversing the list of $n$ elements, and distribute it among these $n$ applications, they each cost a little more (but still $O(1)$), and the reversal now also costs $O(1)$.

Another way of saying this is that any expensive operation has to be preceded by a number of cheap operations. While we cannot claim that the worst-case running time of every operation is $O(1)$
, we can show that any sequence of $n$ operations (starting from nothing) takes $O(n)$ time.

This kind of reasoning is known as **amortization**, or **amortized analysis**. The word means, roughly "to death" in French, but it is used to refer to the common practice in finance and commerce of spreading the cost of paying off a debt over the lifetime of that debt. We will formalize the notion and apply it to this implementation, among others. (The idea for this implementation dates back to at least 1980, perhaps earlier.)

There is one condition we must impose for the analysis to work on our example: each operation on a queue that produces a queue is applied to the most recent queue produced. Operations that do not produce queues (such as _isEmpty_ and _first_) can be applied to older versions. This is sometimes known as "weak persistence". We will see how to deal with full persistence later.



## Amortized analysis

Given a sequence of $n$ operations on a data structure (for arbitrary $n$), where operation $i$ has cost $t_i$, we can assign amortized costs $a_i$ if we can ensure that $$\sum^n_{i=1}t_i \leq \sum^n_{i=1}a_i \ \ .$$

Robert Tarjan, starting in 1985, championed the idea of amortized analysis for data structures, and described two metaphors for it. The first is called the **banker’s method**. In this method, credits are allocated to locations in a data structure that can be used to pay for operations. The amortized cost $a_i$
of operation $i$ is defined to be the actual cost $t_i$ minus the credits $c_i$ spent by the operation plus the credits $\bar{c}_i$ allocated by the operation. If the credits start at zero and we are not allowed to go into debt, the total amortized cannot be less than the total actual cost, as required.

We analyze the two-list queue implementation using the banker’s method as follows. We maintain the invariant that there is one credit associated with every element in the second list (the reversed rear of the queue). The _snoc_ operation will add one element to the front of the second list. So the actual cost is one, and one credit has to be allocated, for an amortized cost of two. But now if _rest_ is applied to a queue represented by an empty first list and a second list with $m$ elements, there are $m+1$ applications of `revh`, but we can spend the m credits associated with the $m$ elements to reduce the amortized cost to one.

There is some sloppiness here, as the cost of revh is not exactly $m+1$, but bounded by some constant times this. What we’d really have to do is give symbolic names to the hidden constants and then adjust the credits to make the math work out. This kind of sloppiness is common in algorithm analysis; as described in Chapter 2, we often count some easy-to-identify "significant" operations (here the number of recursive applications), and use that as a proxy for the actual running time which is at most some constant factor greater.

The following exercise is not required, but doing it now will pay off later in this section.

**Exercise 17**: An alternate strategy reverses the second list and appends the result onto the first when the length of the second list exceeds the length of the first. Write an implementation of Queue that uses this strategy. Show that this also results in amortized time $O(1)$ for all operations. $\blacksquare$

**Exercise 18**: In Chapter 2, an exercise asked you to write increment and decrement functions for natural numbers represented as a list of binary digits in reverse order. Show that the worst-case cost of incrementing the number $n$ is $O(log\ n)$. Then show that the amortized cost of incrementing 0 repeatedly ($n$ times) to produce $n$ is $O(1)$. $\blacksquare$

**Exercise 19**: Show that if a list representation of a sequence is converted to the PBLT representation of the same sequence using structural recursion on the list combined with the `extend` operation, the amortized cost of each operation is $O(1)$, and so the conversion takes $O(n)$ time on a sequence of length $n$. $\blacksquare$

Amortized analysis of this sort can be used to deal with the fixed size of arrays by copying into a larger array as needed (or into a smaller array). While this copying is expensive, it can be amortized over the sequence of operations that filled up the array. Another use is for automatic garbage collection, whose periodic pauses for cleanup can be amortized over the allocations that caused the mess.

I’ll briefly explain Tarjan’s second metaphor (we won’t be using it in what follows). It’s called the **physicist’s method**, inspired by the idea of potential energy. We define a potential function $\phi$ that measures the potential of a data structure in some fashion (that is, it maps the state of the structure to a nonnegative number). The amortized cost of an operation is defined to be the actual cost plus the change in potential. The potential function that works here is the length of the second list.

Tarjan’s work was designed for mutable data structures. We have to take some care with immutable data structures. Here, since we know about sharing between lists, things work out. But, in general, we might have to describe how credits are shared between different values. This could get tricky when we are talking about persistence, because we have to ensure that a credit is not spent more than once.

Speaking of persistence, how are we doing on that front? The two-list implementation does not use mutation, so it is automatically persistent. However, it is not an _efficient_ persistent implementation, even in amortized terms. We know that a long series of _snoc_ operations will result in a long second list. If we keep doing _rest_ twice on that version of the queue, we repeat the expensive reversal over and over. (Weak persistence forbids this, but full persistence does not.)

This seems like a general problem with an amortized analysis of a persistent data structure. If we can identify an expensive operation (one where the individual actual cost is higher than the individual amortized cost) then we can just repeat it over and over. And if we can’t identify such an operation, then we don’t need the amortized analysis!

The way out of the dilemma is to observe that the operation has to return the same value each time, but it doesn’t have to cost the same. If we use mutation "behind the scenes", we might be able to reduce the cost of subsequent repeats of the same operation. One way to do this is by **memoization**, remembering the value produced by a computation. This uses mutation, but it is a benign use. It does not break equational reasoning; we cannot detect the mutation by noticing some change in value. It only affects the cost.

We’ll achieve this using a general mechanism called lazy evaluation, which allows one to defer computation. You have already experienced a form of **lazy evaluation**. A conditional expression (or statement, in an imperative language) only evaluates one of the `then` or `else` branches, and does not evaluate the other one. You may also have experienced AND/OR operators that stop as soon as an answer is determined, allowing expressions such as `(x = 0) || (y/x > 1)` (using OCaml’s OR operator).

In full generality, lazy evaluation allows one to specify a computation that may be evaluated zero or more times in the future. The simplest way of doing this is to just use a lambda, but when combined with memoization, we can create expressions that we can evaluate repeatedly, but only pay the full cost of evaluation the first time. This is the default in Haskell, but is optional in OCaml, which provides special syntax for it (as does Racket, and other modern languages).



## Lazy evaluation with memoization

The idea of using lazy evaluation with memoization to facilitate amortized analysis of persistent implementations of data structures is due to Chris Okasaki, in work connected to his 1996 PhD thesis. The components were available earlier. Lazy evaluation is inherent in the early work on the lambda calculus from the 1940’s and 50’s, but was first suggested for practical work about 1970. Memoization dates back even further, to the late ’50’s, when dynamic programming was first described, and was combined with streams (described below) around 1976.

We can use the OCaml keyword `lazy` before an expression to create a _suspension_ of that expression. If the expression has type `’a`, the suspension will have type `’a Lazy.t`. Given a suspension `s` of type `’a Lazy.t`, `Lazy.force s` will produce a value of type `’a` which is the result of evaluating the suspended expression. Any subsequent forcing of `s` will produce the same value, but without evaluating the expression again. OCaml also allows pattern matching of suspended expressions: the pattern `lazy p` will match `s` of type `’a Lazy.t` if the pattern `p` matches the value of type `’a`. (I suggest you avoid using the lazy pattern for a while. Explicit forcing makes it easier to properly account for all costs in algorithm analysis.)

This seems like internal magic, but all that the compiler provides is a bit of convenient syntax. We can demystify it by doing a similar implementation.

The body of a lambda is not evaluated until the lambda is applied, so we can suspend an expression by making it the body of a `fun`. We don’t care about the argument, so we can make the type of the argument be `unit`. The suspended expression will be `fun () -> expr`, and we’re going to have to write it this way to keep it from being evaluated. Here is the interface.

```{ocaml}
module type Lazy' = sig
  type 'a t
  val delay: (unit -> 'a) -> 'a t
  val force: 'a t -> 'a
end

```

We start the implementation by using an algebraic data type to express the fact that an expression is either delayed (suspended) or has been evaluated.

```{ocaml}
type 'a lazy_expr =
| Delayed of (unit -> 'a)
| Evaluated of 'a

```

The code below should be straightforward to understand.

```{ocaml}
module MyLazy : Lazy' = struct
  type 'a lazy_expr =
  | Delayed of (unit -> 'a)
  | Evaluated of 'a

  type 'a t = 'a lazy_expr ref

  let delay f = ref (Delayed f)

  let force f =
    match !f with
    | Evaluated x -> x
    | Delayed f' ->
        let a = f'() in
        f := Evaluated a;
        a
end

```

The built-in implementation is more sophisticated than this, as it has to handle exceptions, and it detects circularity in forcing. But this is the basic idea. It’s clear that the overhead in suspending and forcing is relatively low, so we can afford to do it speculatively.

The expensive case in our two-list implementation occurs when the first list is empty and the second list is long. But to add to the second list, the first list had to have been nonempty, and the eventual empty first list is a tail of that nonempty list. If we are going to move some of the cost of the expensive case, it is going to involve that tail. This suggests a data structure like a list, but where the tail is a suspended computation. This is commonly called a **stream**. (There is a related but definitely different notion of "stream" available in OCaml as an abstraction for iterative processing of a sequence. Please ignore that.)

Here is a common definition of a stream, as seen in several references, notably the famous "Structure and Interpretation of Computer Programs" textbook.

```{ocaml}
type 'a stream = Nil | Cons of 'a * 'a stream Lazy.t

```

Because the tail is suspended, we can use a stream to represent an infinite sequence, even though we will only force evaluation of some finite initial segment. Here is a definition of an infinite stream of ones.

```{ocaml}
let rec makeones () = Cons (1, lazy (makeones()))

let ones = makeones ()

```

When these lines are evaluated in OCaml, we see:

```{ocaml}
val ones : int stream = Cons (1, <lazy>)

```

We can easily write a function to take a finite initial segment of a stream as a regular list. The function take is a simple adaptation of the similar function that consumes a regular list.

```{ocaml}
let rec take n = function
  | _ when n = 0 -> []
  | Nil -> []
  | Cons (hd, tl) -> hd :: take (n - 1) (Lazy.force tl)

```

We can also write stream functions that correspond to list functions, for doing things like append, reverse, map, filter, and so on. But before we get too far into that, I want to point out a potential issue with this definition of streams. It is prone to embarrassing or fatal "off-by-one" errors. Consider the following definitions.

```{ocaml}
let rec sixty_div n =
  Cons (60/n, lazy (sixty_div (n - 1)))

let sample = take 4 (sixty_div 4)

```

You would expect, when these are evaluated in OCaml, to see:

```{ocaml}
val sample : int list = [15; 20; 30; 60]

```

But instead, we get:

```{ocaml}
Exception: Division_by_zero.

```

What happened? There is a recursive call of the form `take 0 (Lazy.force tl)`. In the recursive application, that second argument is not used, but it is forced first, and that is the fifth element of the sequence, which is `60/0`. We could try to patch the code of take to avoid this, but there are other problems of this kind with odd streams, and the best thing to do is to fix the definition.

Unfortunately, the new definition is a little more complicated, and so is the code that uses it. The new definition is called "even streams", and the old one "odd streams" (the terms "odd" and "even" refer to the number of constructors used in finite streams). It ensures that a stream object is suspended (as opposed to having an unsuspended head) by using two mutually-recursive types (note the keyword and to indicate the mutual recursion; this is also used for mutually-recursive functions).

```{ocaml}
type 'a stream_cell =
    Nil
  | Cons of 'a * 'a stream
and  'a stream = 'a stream_cell Lazy.t

let rec take n s =
      if n = 0 then []
      else match Lazy.force s with
           | Nil -> []
           | Cons (hd, tl) -> hd :: take (n - 1) tl

let rec sixty_div n =
  lazy (Cons (60/n, sixty_div (n - 1)))

let sample = take 4 (sixtyDiv 4)

```

This works as expected, but the code for `take` is a bit more complicated. At least one textbook author tried writing about even streams, but went back to odd streams, despite their drawbacks, because of the coding and comprehension overhead of even streams. (For further details on the awkwardnesses of working with even streams, see the original paper by Wadler, Taha, and McQueen that pointed out the issue and offered this solution, or the discussion around the Scheme library implementations SRFI-40 and SRFI-41.)

Our queue implementations are not going to involve potentially infinite streams, only finite ones, and they won’t involve code that might throw unexpected exceptions, so we might be able to get away with using odd streams without affecting correctness. However, an "off-by-one" error could result in overevaluation, and invalidate our running time analysis. To be sure, we will use even streams. This is not overcaution: efforts to formally verify these implementations (that is, to verify the resource bounds as well as the correctness) have found this to be necessary.

The following exercise is important in what follows, so it will be beneficial to stop and work through it. OCaml’s type system will help in writing correct code.

**Exercise 20**: Create versions of `append` and `rev` that consume and produce even streams, using the efficient list-based versions above as a starting point. $\blacksquare$



### Incremental vs monolithic computation

Some stream computations are "smoother" than others, and those are the ones we should prefer. To understand the issue, let’s look at a version of the take function above that produces a stream, instead of a list.

```{ocaml}

let rec take' n s =
  lazy (
      if n = 0 then Nil
      else match Lazy.force s with
           | Nil -> Nil
           | Cons (hd, tl) ->
                  Cons (hd, take' (n - 1) tl))

let sample' = take' 4 (sixtyDiv 4)

```

It takes $O(1)$
time to produce sample’, and $O(1)$ time to force each element of sample’. But contrast this behaviour with the drop function which removes n

elements from a stream.


```{ocaml}
let rec drop' n s =

  lazy (
      match Lazy.force s with
      | x when n = 0 -> x
      | Nil -> Nil
      | Cons (hd, tl) ->
            Lazy.force (drop' (n - 1) tl))

```

The issue with `drop’` is that forcing the first element of the result of `drop’ n s` takes $O(n)$
time, after which forcing subsequent elements takes $O(1)$ time. (This analysis depends on the fact that it takes $O(1)$ time to force each element of the stream that sixtyDiv produces, but we can generalize the statement.)

The stream version of `rev` that I asked you to write in the previous section does even worse. If we reverse a stream of length $n$, we get the result in $O(1)$ time (because it is a suspended computation), but forcing the first element of the result requires forcing all of the original stream because the first element of the result is the last element of the original stream, and this takes $O(n)$ time to reach. After that, it takes $O(1)$ time to get each of the rest of the elements of the reversed stream, because the cached versions are used. (Obviously, one cannot reverse a stream representing an infinite sequence.)

The stream version of `rev` is called **monolithic**, because all its work has to be done at once. (The term means "made from a single stone", a metaphor for something that can’t be broken up.) In contrast, the stream version of `append` (which we will denote by infix `++`, after the Haskell notation) has the property that forcing each element of the result takes $O(1)$ additional time (beyond the cost of the suspended computation of that element) and does not force any subsequent elements. This kind of function is called **incremental**, and it is this sort of behaviour that we can exploit to improve our queue implementation.



### Flattening using streams

Streams, properly coded, can be used for elegant solutions to many problems. As an example, consider the task of writing a function `to_list` that consumes a leaf-labelled binary tree (not necessarily perfect or near-perfect) and produces a list of the leaves in left-to-right order. It’s easy to write a function that does this, but not so easy to write an efficient one.


```{ocaml}
let rec to_list t = function
  | Leaf v -> [v]
  | Node (l, r) -> (to_list l) @ (to_list r)

```

Why is this inefficient? If the result has length $n$, then the tree has $n$ leaves and $n−1$ nodes. The cost of list append is $O(s)$, where $s$ is the length of the first (left) argument. We get a recurrence that looks like this:

\begin{align*}
T_{to\_list}(1) &= O(1) \\
T_{to\_list}(n) &= \max_{0<s<n}\{\ T_{to\_list}(s)+T_{to\_list}(n−s)+O(s)\ \}
\end{align*}

If we choose $s$ to be $n−1$, we get a recurrence whose solution is $\O(n^2)$, and in fact if we apply `to_list` to a tree with $n$ leaves where every left child is a leaf, it will take $\Omega(n^2)$ time, so this analysis cannot be improved.

To get a solution that runs in $O(n)$ time, we can convert `to_list` to produce a stream in $O(n)$ time. The stream will have a total of $O(n)$ suspensions, so it can be completely forced to a list in $O(n)$ time.

**Exercise 21**: It is possible, though more difficult, to write `to_list` without using streams. The efficient version of `rev` used a helper function with an accumulator, and we can do the same here. Write the function `to_list_h` which consumes a tree `t` and a list `lst`, and produces the same result as `to_list t @ lst`, but takes $O(n)$ time, where $n$ is the number of constructors of $t$. $\blacksquare$



### Queues using streams

We will modify the two-list implementation of queues by using two streams instead. That alone will not improve the situation.

What we did before, in list terms, was to replace (`[], r`) by (`rev r, []`). To take advantage of the incremental nature of `++`, we will, at selected points, replace (`f, r`) by (`f ++ rev r, []`) (we’ll call this a rotation). When should we do this, and how do we analyze it?

I will answer the second question first, because that has implications for the first question. Okasaki’s brilliant insight was to recast the banker’s method in terms of debits rather than credits. The intuition Okasaki offers is that credit cannot be spent more than once, but it is okay to pay off a debt more than once.

Thinking in terms of credits, it’s okay to let things build up to the point where an expensive computation is required, if one is earning credits to pay for that computation. Thinking in terms of debits, one schedules an expensive computation in the future, calculates its cost as a debt, and then pays off that debt by the time the computation needs to be carried out. The difference may seem minor, but the latter approach works well with full persistence.

For full details of how to carry out amortized analysis using the debit method, I refer you to Okasaki’s thesis or the subsequent book based on it. Here I will just sketch the ideas.

Debits will be associated with locations where there are suspensions. One debit represents a constant amount of work done in forcing a suspension. For an incremental function like `++`, we will distribute the debits among the first list. For a monolithic function like `rev`, we will pile all the debits on the first location. When an operation is performed, we might also discharge (pay off) some debts in other places. The amortized cost of an operation is the running time assuming any forcing of a suspension existing at the start of the operation takes $O(1)$ time plus the number of debits discharged. We have to ensure that no suspension is forced before its debt is paid off. This is like a "layaway plan" in finance, where one doesn’t take possession of the item until the debt is fully paid. In effect, we have used other operations to pay for the cost of forcing the suspension. If we can ensure this, and we start with total debt zero, then the sum of the amortized costs is an upper bound on the sum of the actual costs.

If we replace (`f, r`) by (`f ++ rev r, []`), then the reverse is not executed right away. It is a suspension which is going to cost, in real terms, $O(\lvert r \rvert)$ time (using the vertical bars to denote length). But we have to do $\lvert f \rvert$ operations before the suspended reverse is forced. If we maintain the invariant that $\lvert f\rvert \geq \lvert r \rvert$, and do the rotation as soon as the invariant is violated (that is, when $\lvert r \rvert = \lvert f\rvert+1$), then we’ll have enough time to pay off the debt of the reverse. (This is the same invariant used in the list-based exercise in the section that introduced amortized analysis.) Both _snoc_ and rest have to do this check (they can share the code to do it). But to give them the information, we have to maintain the lengths of each stream.


```{ocaml}
type queue = int * 'a stream * int * 'a stream

```

**Exercise 22**: Complete the implementation of Queue using this idea. $\blacksquare$

The analysis from the earlier list-based exercise can be adapted to show that this implementation achieves $O(1)$ amortized time for all operations under the conditions of weak persistence. But it also works for full persistence. Let’s take a look at an example.

Suppose we have $Q_0$ with $m$ elements on both first and second streams, and $Q_i+1$ is the result of applying `rest` to $Q_i$. The rotation is set up in the formation of $Q_1$, but it is not forced until the computation of $Q_{m+1}$. If we repeat the computation of $Q_{m+1}$, the memoized version of the result of the reverse is used, and the cost is $O(1)$. This is also true if we repeat from $Q_m$. The only way to get an expensive reverse is to go all the way back to $Q_0$, at which point we have to repeat the cheap operations creating Q1 through $Q_m$ before we trigger the expensive reverse, so we have amortization.

That is not a proof. Okasaki’s proof describes a **debt invariant** and precisely specifies how many debits each operation creates and discharges and why, in order to both maintain the invariant and ensure that all costs are accounted for.



### Achieving constant time with full persistence

We can work a little more on this implementation and create one that, surprisingly, has $O(1)$ worst-case cost for all operations, even when persistence is important. Since the code is about as simple (if not simpler), that is going to make the implementation we just analyzed of academic interest only. But we are building on what have just learned, so it is not a waste, and it is good to see the progressive development of ideas. Too many data structures textbooks and references present only the final, optimized versions.

The first purely-functional (and hence persistent) implementation of queues with constant worst-case running time for all operations was done by Hood and Melville in 1981. They did not use suspension or streams; they used regular lists. I will not describe this implementation in detail, but I’ll sketch the basic ideas. The central concept is to avoid the expensive reverse by doing it incrementally. We have argued that rev, translated to streams, is not incremental, but the helper function (which repeatedly removes from the front of a list and conses onto an accumulator) can be viewed as incremental (in the sense that we can partition its work). So, given `(f,r)`, we can incrementally and "in parallel" reverse `f` giving `f’` and `r` giving `r’`, and then incrementally reverse `f’` onto `r’` using the helper function, doing all this "in parallel" with the other work of the operations.

The problem is that while we are incrementally doing this work, operations can be removing from f, so we might have to stop early. The original HM implementation, using Lisp (in a style that will be familiar from Racket in CS 135, so you can read the original paper, if you want) had one function with six list arguments, and a complicated invariant relating these arguments that was used to prove correctness. Using algebraic data types, we can use different constructors in different situations, so that at most four lists are needed at a time. But the code is fairly intricate.

Okasaki realized that we can do better starting from the two-stream (plus two natural numbers) implementation. The key is to use the idea of the incremental helper function from `rev` to make rotation incremental. In effect, we fuse the code from the helper function with the code from `++`. The `rot` function will consume three streams (think of the first two as the two streams in the two-stream implementation, and the third as the accumulator in the helper function for `rev`). The computation will ensure that `rot s s’ a` has the same value as `s ++ (rev s’) ++ a`. If we ensure this, then the computation `f ++ (rev r)` we needed to do in the two-stream implementation is just `rot f r (lazy Nil)`.

The code for rot is simplified because we only need to apply it in the case where $\lvert r \rvert = \lvert f \rvert +1$
(with an empty accumulator). We will preserve this invariant in its recursive applications. That is, for any application rot s s’ a, $\lvert s^{\prime}\rvert =\lvert s \rvert+1$. So if the first argument is empty, the second argument is a singleton, and we just stream-cons that onto the accumulator. But if the first argument is not empty, we take one element from the first argument and stream-cons it onto a recursive application of `rot`, where to preserve the invariant, we move one element from the second argument to the accumulator.

In order to account for the cost of a rotation, we need to make progress on it when it is not being used, for example when _snoc_ is adding to the second stream. This progress consists of forcing elements of the first stream. We keep track of where we are in this process by adding a third argument, the **schedule**, to the representation. The schedule will be a suffix of the first stream, but because of sharing, we can think of it as a pointer into the first stream. So the representation becomes `(f,r,s)`. When r grows (that is, _snoc_ has added to the second stream), then s can shrink. So we can maintain the invariant that $\lvert s |=\lvert f\rvert−\lvert r\rvert$. Since the only reason to maintain the lengths of the streams `f` and `r` was to know when to rotate, we can get rid of the integers maintaining length! Furthermore, we don’t really need `r` to be a stream (this was true in the two-stream representation also) so we make it into a list (making the appropriate adjustments to the code of `rot`).


```{ocaml}
type 'a queue3 = 'a stream * 'a list * 'a stream

```

As before, _snoc_ and rest share a helper function that maintains the invariant. If s is empty, the helper function uses rot to start a rotation of the former second list onto the former first stream (this same value is the new value of `s`). If `s` is nonempty, the mere act of pattern matching to determine this has forced the first element of `s`, so it just has to be removed.

**Exercise 23**: Write code for this implementation. Verify that each suspension created takes $O(1)$
time to force, and each operation does $O(1)$ suspensions plus $O(1)$ additional work. Conclude that the worst-case cost of any operation is $O(1)$. $\blacksquare$

**Exercise 24**: In the two-stream implementation of the previous section, the second stream r doesn’t have to be a stream; it can be a list. Edit your previous code to create a one-stream, one-list implementation. $\blacksquare$

If persistence is important, the implementation described in this section is competitive with the two-stream (or one-stream one-list) implementation that had constant amortized cost; if persistence is not important, and amortized constant time is okay, the two-list implementation is best.

There is much more work in this area, extending operations (for example) to deques, or adding the ability to append one queue or deque onto another efficiently.



## Priority queues

There are many applications where one wants something like queues, but time of insertion is not the ordering criterion. Rather, there is some other factor that gives certain items priority over other items. We model this with a priority queue, where each item comes with a priority. We can think of the priority as a number, but we can generalize this to any ordered domain with a total comparison operation. This generalization lets us forget about the items and focus on the priority values (since we can just pair priority values and items and define the appropriate comparison operation for the pairs). So we view a priority queue as a multiset of elements from an ordered domain.

Confusingly, the convention is to focus on the minimum element, even though, in English, we speak of "higher priority". That is, the item of highest priority has the lowest priority value! We could focus on the maximum element just by flipping all priority comparisons, but we won’t. Some references speak of max-queues and min-queues (both can be useful, sometimes at the same time). We will only deal with min-queues here.

The operations that the Priority Queue ADT supports are `empty`, `is_empty`, `insert`, `find_min` and `delete_min`. (Later, we will consider another operation, `merge`.)

It’s usually a good idea to try first to use lists for a new ADT. Sometimes they’re good enough (especially for small data), and even if they’re not, we might gain insight into what the issues are. If we use unordered lists, then when the list contains $n$ elements, insert takes $O(1)$ time but `find_min` and `delete_min` take $O(n)$ time. We can reduce `find_min` to $O(1)$ time by maintaining the minimum separately (this is possible for any implementation) but there is nothing to be done to improve `delete_min`. If we keep the lists ordered by nondecreasing priority, the costs of `find_min` and `delete_min` drop to $O(1)$, but `insert` increases to $O(n)$ time.

Our goal is to get these operations down to $O(log\ n)$
time, with some of them $O(1)$ time. We can’t expect to get all of them down to $O(1)$ time, even amortized. Given any priority queue implementation, we can sort $n$ elements by inserting them into an initially empty priority queue, then interleaving $n$ `find_min` and $n$ `delete_min` operations. But any comparison-based sorting algorithm that sorts $n$ distinct elements must make $\Omega(n\ log\ n)$ comparisons. We can see this by viewing such an algorithm as a binary tree with comparisons at the internal nodes and leaves labelled with permutations of the elements. There are $n!$ permutations, and thus the tree must have at least this many leaves. But a binary tree of height $h$ has at most $2^h$ leaves (this is an easy proof by induction on $h$). This means that a binary tree with at least $n!$ leaves must have height at least $log(n!)$. Since $n! \geq (\lfloor n/2 \rfloor)_{\lfloor n/2 \rfloor}$, some permutation forces at least $cn\ log\ n$ comparisons for some constant $c$.

This bound does not hold if we do computation on the elements (for example, if we assume they are integers, and compute their digits or bits). But it does suggest a limit to the efficiency of a truly generic priority queue implementation. If all operations take $O(log\ n)$ time, then we contradict the sorting lower bound.

Before we work on more efficient priority queues, we should discuss implementation in OCaml. Since the priority can be drawn from any ordered domain, we can create a module type that works for any such situation. For the sorting examples in Chapter 2, we just used the overloaded OCaml operator `>`, which provides the expected results on types such as `int` and `string`. For full generality, though, we should include the ability to specify the comparison function.


```{ocaml}
module type OrderedType = sig
  type t
  val compare : t -> t -> int
end

```

Here the type `t` is abstract, and the operation `compare` will consume two elements of type `t` and produce an integer. The integer will be negative if the first argument is smaller, positive if the first argument is greater, and 0 if the two arguments are equal. This is a somewhat awkward convention. It would be better to use a sum type; Haskell provides the equivalent of the following.


```{ocaml}
type Ordering = LT | EQ | GT

```

But the integer convention is now standard in OCaml (it comes from a similar convention in C, used for example by the `strcmp` function) and is used in some OCaml library modules, so we will adopt it. Here’s an example of a module of this type.


```{ocaml}
module OrderedInt : OrderedType =
  struct
    type t = int
    let compare x y =
      if (x < y) then -1
      else if (x = y) then 0 else 1
  end

```

In this example, two elements (integers) can be compared in $O(1)$ time. We will assume this in our analyses. If in some particular instance this assumption is not true, the running times we derive have to be multiplied by the cost of a comparison.



### Functors (parameterized modules)

We’d like to write our implementation of priority queues (say, using unordered lists) so that it can use an arbitrary implementation of `OrderedType`. We can do this by using a **functor**, which can be thought of as a parameterized module, or as a sort of function from a structure to a structure. Here’s the way we might describe the type of such a functor.


```{ocaml}
module type PQFunctor =
  functor (Elem : OrderedType) ->
    sig
      type elt = Elem.t
      type pq

      val empty : pq
      val is_empty : pq -> bool
      val insert : elt -> pq -> pq
      val find_min : pq -> elt option
      val delete_min : pq -> pq option
    end

```

The `functor` syntax is intended to be analogous to the fun syntax for creating an anonymous function. In this case, because we are defining the type of a functor, a signature appears to the right of the arrow. When we actually write the implementation, a structure will appear to the right of the arrow, like this:


```{ocaml}
module UListPQ : PQFunctor =
  functor (Elem : OrderedType) ->
    struct
       type elt = Elem.t
       type pq = elt list
       let empty = []
       let is_empty x = (x = empty)
       let insert = List.cons
       let find_min x = if (is_empty x) then None else
         let min x y =
            if (Elem.compare x y <= 0) then x else y
         in Some (List.fold_left min (List.hd x) (List.tl x))

       let delete_min x =
         let rec delete_this e = function
           | [] -> [] (* will never happen *)
           | (x :: xs) -> if (x=e) then xs else x :: delete_this e xs
         in match (findMin x) with
            | None -> None
            | (Some m) -> Some (delete_this m x)
    end

```

Just as `let id x = x` is syntactic sugar for `let id = fun x -> x`, OCaml provides syntactic sugar for writing functors so that they look more like parameterized modules. We could replace the header above with:


```{ocaml}
module UListPQ (Elem : OrderedType) =
  struct ... end

```

We can’t put the annotation `: PQFunctor` before the `=` because the functor produces a structure, and we would need to use a named type which matches that. If we’re worried that we haven’t created something of type `PQFunctor`, we can do a coercion:


```{ocaml}
Module UListPQC = (UListPQ : PQFunctor)

```

This is a bit awkward, and we’ll deal with it better in a moment. But first, let’s instantiate an integer priority queue, and use it.


```{ocaml}
module IntPQ = UListPQ(OrderedInt)

let test1 = IntPQ.find_min (IntPQ.insert 1 (IntPQ.empty))

```

To specify the generic type produced by `PQFunctor`, we can write a description like this.


```{ocaml}
module type PQ = sig
  module Elem : OrderedType

  type pq

  val empty : pq
  val is_empty : pq -> bool
  val insert : Elem.t -> pq -> pq
  val find_min : pq -> Elem.t option
  val delete_min : pq -> pq option
end

module type PQFunctor = functor (E : OrderedType) -> PQ

module UListPQ : PQFunctor =
  functor (E : OrderedType) ->
    struct
       module Elem = E
       type elt = E.t
       type pq = elt list
       ...
    end

```

OCaml is fine with this, but when we try to instantiate and use an integer priority queue as we did before, the expression 1 is flagged with the following compilation error:


```{ocaml}
Error: This expression has type int but an expression
        was expected of type IntPQ.Elem.t

```

The type `Elem.t` in the definition of `PQ` has remained abstract. We want to instantiate it with `int` in this case. The connection should be made in the definition of module type `PQFunctor`. We need a way of saying that the `E` that parameterizes the result of the functor (for which we later supply the argument `OrderedInt` when creating `IntPQ`) should be the same as the abstract `Elem` mentioned in the definition of `PQ`. The syntax provided by OCaml for this is called a **sharing constraint**, and we can write it like this:


```{ocaml}
module type PQFunctor =
  functor (E : OrderedType) -> (PQ with module Elem = E)

```

This does not entirely fix the error; it becomes:

```{ocaml}
Error: This expression has type int but an expression
        was expected of type IntPQ.Elem.t = OrderedInt.t

```

So we have a similar problem with `OrderedInt`. If we change its type in a similar fashion:

```{ocaml}
module OrderedInt : (OrderedType with type t = int) = ...

```

the example compiles and runs properly. (We can also remove the type annotation on `OrderedInt`.)

Using the syntactic sugar for parameterized modules, we can write the header for `UListPQ` like this:

```{ocaml}
module UListPQ (E : OrderedType) : (PQ with module Elem = E) =
  struct
    module Elem = E
    ...
  end

```

**Exercise 25**: Write the functor `module GoodMin (M : PQ) : (PQ with module Elem = M.Elem)`. The result module uses the representation of `M` but also maintains the minimum element. The goal is to reduce the cost of `find_min` to $O(1)$ regardless of how `M` is implemented, while increasing the running time of the other operations as little as possible. Analyze the running time of the other operations in terms of the running time of the implementations in `M`. $\blacksquare$




### Priority queues using Braun heaps

Now that we know how to code our priority queue ideas in OCaml, we return to the question of efficiency.

Most priority queue implementations use some variant of a **heap**, which is a tree with an element at each node. A heap has the property that the priority of an element is no greater than the priority of its children (and, by transitivity, its descendants). Thus the minimum element is at the root of the tree. The heap property says nothing about the relative ordering of siblings, and this gives us flexibility in rearranging elements. In particular, rearranging sibling subtrees preserves the heap property. Different implementations use different tree shapes and rearrangement policies.

(Confusingly, the word "heap" is also used for managing a large storage pool of memory from which arbitrary-sized chunks can be requested. This involves another important data structure that is completely different, but usually discussed in a systems or compilers context.)

Insertion into a heap, if we don’t care about the shape of a tree, is straightforward. We compare the element being inserted to the element at the root. The smaller is the root of the new heap and the larger is recursively inserted into one of the children subtrees. But this will take worst-case time proportional to the height of the tree, so we need to care about the shape.

We’ve already seen a tree that does well under these circumstances: the Braun tree. A **Braun heap** has the Braun-tree property (for every node, either the two subtrees have the same size, or the left one has one more node than the right one) and the heap property. To maintain the Braun-tree property under insertion, we adapt the above insertion idea with the same thing we did for our sequence implementation. The new right tree is the old left tree, and the new left tree is the old right tree with the larger (of the root and the inserted element) recursively inserted. Since we know that a Braun tree with $n$ nodes has height $O(log\ n)$, we have an efficient implementation for insert.

`delete_min` is not quite as straightforward. We can’t just remove the root element, swap the subtrees, and promote the root of the new right subtree (recursively deleting its minimum element). That might violate the heap property, since we don’t know the relationship between the child elements of the root. We could promote the smaller of the two child elements of the root, but if it’s the root of the right subtree, we risk violating the Braun-tree property.

The swap and recursively delete on the left idea does work to remove some leaf element, so we can at least get a heap with the same shape as the answer, even if the wrong element has been removed. The helper function `delete_one` will, using this idea, delete one leaf element from a Braun heap and produce a pair of the removed element and the new Braun heap, which still has the same root (unless there was only one node being deleted, in which case `delete_min` is straightforward). This takes $O(log\ n)$ time if the Braun heap has $n$ nodes.

That root is the minimum element to be deleted. We will be left with the two subtrees (which are Braun heaps, either of the same size or with the right one being one smaller) and the removed element. We write another helper function `meld` that consumes these three arguments and produces a Braun heap. This can be done with a single recursive application and constant time (there are a few cases). Thus the task is completed in $O(log\ n)$ time.

**Exercise 26**: Complete the OCaml implementation of priority queues using Braun trees. $\blacksquare$

With care, one can use `meld` to create a Braun heap from a list of $n$ elements in $O(n)$ time (as opposed to doing $n$ individual insertions, which will take $O(n\ log\ n)$ time). For simplicity, consider $n=2^k−1$. It’s easy to create a Braun heap of size one, so create $2^{k−1}$ of them. Then meld them in pairs with one of the leftover elements, and repeat until there is only one heap. On repeat $i$, each of the $2^{k−i}$ trees are of height $i$, so one meld takes $O(i)$ time, and there are $2^{k−i−1}$ of them. The melding work done is thus proportional to $\sum^{k−2}_{i=1}i2^{k−i−1}$, which is $O(n)$. The sum can be solved exactly with a bit of algebra, but intuitively, the sum is dominated by the first two terms, after which the increase in the $i$ term is more than compensated for by the decrease in the $2^{k−i−1}$ term.

I’ve described this bottom-up to make the work expression clearer, but it’s best implemented top-down, and it’s not hard to do it for arbitrary $n$. The recurrence we get is:

\begin{align*}
T_{ heapify }(1) &= O(1) \\
T_{ heapify }(n) &= T_{ meld }(\lfloor n/2 \rfloor)+T_{meld}(\lceil n/2 \rceil)+O(log\ n)
\end{align*}

and the discussion in the previous paragraph (plus Akra-Bazzi) shows this has solution $T_{ heapify }(n)=O(n)$. (This recurrence seems a bit specialized, but it will come up again.)

**Exercise 27**: Write the OCaml function `heapify_h` that consumes a list of elements `lst` and a natural number `n` and produces a pair consisting of `lst` with the first `n` elements removed, and a Braun heap containing those elements. Then use `heapify_h` as a helper function in a top-down implementation of `heapify`. $\blacksquare$



### LJNP trees revisited

Our original use of Braun trees to improve the index operation for sequences was reminiscent of arrays. We can reverse the thinking and try to use an array to store a binary tree. If we use the Braun tree numbering, it’s a bit awkward to navigate. To compute the children of the element at index $i$, we have to add the digits 1 and 2 to the left of the bijective binary representation of $i$. But the numbering we first used (with contiguous numbers as we move across a level, using a left-justified near-perfect or LJNP binary tree) adds the digits at the right, which is easier to compute. The children of the element at index $i$ are at indices $2i+1$ and $2i+2$, and the parent is at index $\lfloor (n−1)/2 \rfloor$ . We also maintain the size of the heap in a separate mutable variable.

Of course, we cannot easily swap subtrees in the array representation, so the algorithms look different (and tend to be expressed in terms of loops, rather than recursion). Insertion into an array-based heap is done by storing the new element in the first unused position in the array and then restoring the heap property by repeatedly comparing with its parent and swapping them if necessary. Deletion of the minimum is done by swapping the element of index 0 with the element of size $n−1$ (where $n$ is the size before deletion) and then restoring the heap property by repeatedly comparing it with its children and swapping with the smaller one. If the minimum is repeatedly deleted in this fashion (decrementing the maintained size of the heap each time), then the removed elements accumulate in nonincreasing order in the portion of the array unused by the heap. When the heap reaches size zero, the array is sorted. This is known as `heapsort` (Williams 1964). It is an in-place $O(n\ log\ n)$ array-based sort that requires only constant additional storage, and no recursion (despite this, `mergesort` is often preferable).

The "swapping down" process described in the last paragraph can also be used to `heapify` $n$ elements by putting them in an arbitrary order in the array and then applying the process on each element from index $n−1$ down to 0. This idea is due to Robert Floyd, from 1964. For the same reason as with Braun heaps, the cost is $O(n)$.

**Exercise 28**: Write code for array-based heap operations, `heapsort`, and `heapify` in your favourite imperative language, or try it in OCaml. $\blacksquare$

Array-based heaps have the same drawbacks that we’ve seen for other uses of arrays: they use mutation heavily, they aren’t persistent, and they have a fixed maximum size. Braun heaps were (I believe) first published in a textbook by Larry Paulson in 1996, using code supplied by Okasaki.



### Merging heaps

Both of the efficient heap implementations we have seen (Braun-tree-based and array-based) seem ill-suited to the `merge` operation. It is somewhat more difficult to see the utility of this operation, but it proves useful in some algorithms, notably shortest-path computation (Dijkstra’s algorithm). From a set point of view, this is the union operation for multisets, though we will not consider the intersection operation. Okasaki points out that other operations can be expressed in terms of `merge`. `insert` is the merge of a singleton heap with a possibly larger one. `deleteMin` is the merge of the two subtrees of the root.

It would be nice if we could add merge to the types and modules we’ve written in OCaml as easily as we just added it conceptually. Fortunately, it is almost as easy.

```{ocaml}
module type MPQ =
  sig
    include PQ
    val merge: pq -> pq -> pq
  end

module UListMPQ (E : OrderedType) : (PQ with module Elem = E) =
  struct
    include UListPQ(E)
    let merge = (@)
  end

```

The merge operation in `UListMPQ` takes $O(m)$ time when merging priority queues of size $m$ and $n$ . It’s not easy to adapt the implementations we have to do much better. We need some new ideas.

Okasaki created **maxiphobic heaps** for pedagogical purposes. They do not perform quite as well as related data structures. But the invariant in a well-performing data structure often seems impossibly clever. We can understand it when it is explained, but how did someone come up with it in the first place? The invariant for maxiphobic heaps is not so mysterious.

Consider merging two binary heaps of arbitrary shape. To choose the root of the result, we can choose the smaller of the two roots. That leaves three trees (one original, and two subtrees of the smaller root). We can put two trees as children of the chosen root. So we have to do one recursive merge. How do we choose so that the recursion has $O(log\ n)$ depth?

After a bit of thought, we might conclude that we should leave alone the larger of the three trees (for some measure of "large") and merge the two smaller ones. Does this work?

If the measure of "large" is the number of nodes, then the tree left alone has at least one-third of the total number of nodes. So if $T(n)$ is the time taken to merge two binary heaps of total size $n$, then $T(n)=T(2n/3)+O(1)$, and $T(n)$ is $O(log\ n)$. We should maintain the number of nodes in every subtree to avoid computing it from scratch. The base of the logarithm is 3/2 instead of 2, so the resulting trees can be taller.

There are many other heap implementations, some of which achieve $O(1)$ amortized time for all operations except `delete_min` in a persistent setting. One implementation, pairing heaps (which uses non-binary trees), works best in many benchmarks, and has been conjectured to meet this bound, but so far only $O(log\ n)$ amortized time has been proved.
