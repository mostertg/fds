
# Hashing

> _"My chest is aching / Burns like a furnace / The burning keeps me alive"_
>
> Talking Heads, "Life During Wartime", Fear of Music, 1979

Arrays are the sharks of data structures: a more primitive form from an earlier stage of evolution. But, like sharks, they have their place in the ecosystem. Their great advantage is constant-time access (with a small constant) to any element. Using them usually means using mutation, and giving up persistence. We avoided some issues in the last chapter by using mutation on arrays only in preprocessing, and usually in a write-before-read fashion. We will not be so fortunate this time. The algorithms make heavy use of mutation, and worst-case analysis is mostly not relevant. Consequently, this chapter is more descriptive, and there are no exercises (though you can easily write code if you wish to experiment). I will focus on ideas, and on some of the more accessible associated mathematics.

A hash table is an implementation of the mutable Map ADT that uses arrays as its primary data structure. Hash tables are quite commonly used, and all modern languages provide them in some fashion. Following common terminology, we will call the domain of keys $U$ (for "universe"). The number of keys we are storing will be $n$.

The main idea is to do computations on the keys, in particular using them to compute indices into an array. If $U={0,1, \ldots, k−1}$ (for which I will use the more concise notation $[k]$), we can use the key as an index directly, with an array of size $|U|=k$. But typically $|U|$ is much larger than $n$, making this impractical. A **hash function** maps keys to indices in a **hash table** which is an array of size $m$.

The resulting implementations are usually simple and fast, even though analysis yields poor worst-case running times for operations (typically $\mathcal{O}(n)$ ). The discrepancy is partly explained by analysis done using probabilistic assumptions, but mostly evaluation is empirical and based heavily on experience. The subject is huge and we will only touch briefly on a few of the ideas.

The ratio $\sfrac{n}{m}$ of the number of occupied indices to the total size of the array is often designated as $\alpha$ or the **load factor**. If this gets too large (which tends to result in degraded performance), a new array of larger size can be allocated, and all keys relocated into it, a process known as **rehashing**. Similar considerations apply as for the cases of resizing arrays we have discussed earlier. The rehashing process takes time proportional to the number of keys, and if the new array is a constant factor larger, we can view the additional cost as $\mathcal{O}(1)$ amortized over earlier operations (since the last resizing).

If the keys come from a large range of integers, modular arithmetic can be used to produce an array index. The simplest approach for a key $x$ is to use $x \mod m$, defined as the unique integer $r \in [m]$ such that $x=r+km$ for some integer $k$. This is often too simple, since sometimes information is encoded in digits of keys. A slightly better idea is to use $(ax+b) \mod m$ for some $a,b$. We’ll see variations on these ideas shortly. It’s not hard to extend this basic notion to sequences of integers through various iterative computations. Characters can be considered as integers from a moderate range, and strings as sequences of characters. Similarly, we can deal with tuples and algebraic data types. In what follows, we will assume that the keys are integers.

Modular arithmetic tends to involve division, which is an expensive operation from a hardware point of view. For applications where the speed of computing a hash function is a significant factor in performance, there are alternatives involving bitwise logical and shift operations, which are much faster.

Beyond the choice of hash function (or functions, as we will see), the different methods differ mainly in the strategy used when two different keys hash to the same index, which is bound to happen when $m<|U|$. This is known as a **collision**. The hope is that the set of colliding keys is small and can be dealt with by a simple Map implementation instead of the more complicated implementations of Chapter 4. Okasaki characterized hashing as _"the composition of an imperfect map [the hash function] and a perfect map [collision resolution]"_.



## Chaining

The method known as **chaining** puts all keys that hash to the same index into a list, which is managed in the obvious fashion. In other words, the hash table is an array of lists of keys. Not much more needs to be said about the implementation or the worst-case analysis.

If we choose the hash function at random from some class, this becomes a randomized algorithm, and we can talk about the expected running time, or compute a bound on the running time that holds with high probability. What if we choose the hash function uniformly from the set of all functions from $U$
to $[m]$? There are some terrible hash functions in this set (the function that maps every element of $U$ to $0$, for example) but intuitively most choices should be pretty good. We can think of this choice as, for each element $x \in U$, choosing a random element of $[m]$ to which $x$ is mapped.

The method of indicator variables we used for treaps can help analyze this situation. Let $I_{x,y}$ be 1 if $x$ and $y$ are mapped to the same index. Since the probability of this is $\sfrac{1}{m}$, $\mathbb{E}[I_{x,y}]=\sfrac{1}{m}$ for $y \neq x$. Now suppose we are trying to insert $x$ into the hash table. The expected length of the list that $x$ is mapped to by the hash function is $\mathbb{E}[\sum_{y}I_{x,y}]$ where the sum is over all $y$ in the table. Since the expectation of a sum is the sum of the expectations, and there are at most $n$ such elements $y$, this is bounded by $\sfrac{n}{m}$ or $\alpha$. Thus (taking into account the empty list case as well), the expected cost of operations is $\mathcal{O}(1+ \alpha)$.

That’s an encouraging result, especially when the load factor $\alpha$ is less than 1, but how do we choose a random function from this class in such a way that we can later apply it? There are $m^{|U|}$ such functions, so it will take $|U| \log m$

bits to write down any unique "name" for one function. But that’s about how much space it would take to write down a complete table of function values. In other words, our conceptual idea of the choice is about as good an implementation as we can hope for. Clearly this is impractical when the universe is large.



### Universal hash functions

The important property of the class of all hash functions was that the probability that a random choice of function made two different elements collide was at most $\sfrac{1}{m}$. Carter and Wegman (1979) called a class that achieved this **universal**, and showed that if $p$ is a prime greater than $|U|$ (there is one between $|U|$ and $2|U|$), then ${((ax+b) \mod p) \mod m | a,b \in [p],a \neq 0}$ is a universal class. Since we only have to choose $a,b$ at random, this is much more practical.

We can prove this using only ideas from elementary number theory. This subject is taught in the very first algebra course at the University of Waterloo, because the ideas and proofs are a good introduction to how mathematics is done. If you don’t know the subject, you will have to take some things I say on faith, but this might be good incentive to learn it.

Let’s consider two keys $x,y$ that collide, and see how this might happen. To directly show that the chance of this happening is at most $\sfrac{1}{m}$, we could show that a fraction $\sfrac{1}{m}$ of all choices of $a,b$ will make them collide. We’ll go about that in an indirect way.

For fixed $x>y$ and given $a, b$, let $r=(ax+b) \mod p$ and $s=(ay+b) \mod p$. Then, because the two keys collide, $r \equiv s(\mod m). Furthermore, $r \neq s$, because if $r=s$, then $a(x−y) \equiv 0(\mod p). This means $p$ divides $a(x−y)$, so it must divide either $a$ or $x−y$, but both of these are less than $p$, a contradiction.

The elements of $[p]$ together with addition and multiplication with results reduced $\mod p$ form a **field**. In particular, for any nonzero $c \in [p]$, there is a unique nonzero $d \in [p]$ such that $cd \equiv 1 \mod p$. Given $c$, its inverse $d$ can be computed efficiently using the extended Euclidean algorithm (a greatest common divisor computation with added bookkeeping) but for this proof, we only need its existence.

There is a unique $z \in [p]$ such that $z(x−y) \equiv 1(\mod p)$, which lets us solve uniquely for $a$ and $b$ given $r$ and $s$: $a=(r−s)z \mod p$ and $b=r−ax \mod p$.

What we have shown is that counting the $(a,b)$ pairs which cause $x,y$ to collide is the same as counting the $(r,s)$ pairs with $r \neq s$ and $r \equiv s(\mod m)$. If we fix $r$, we have at most $2(\lfloor \frac{p}{m} \rfloor −1$) choices for $s$, because $r−s$ could take on values of the form $jm$ where $0<jm<p$, but also values of the form $p−jm$ in the same range. Working with this quantity, $2(\lfloor \frac{p}{m} \rfloor −1) \leq 2(\lfloor \frac{p-1}{m} \rfloor −1 \leq \frac{2(p−1)}{m}$. Adding this up over all $r$ counts every pair exactly twice.

So the total number of $(a,b)$ pairs which cause $x,y$ to collide is $\frac{p(p−1)}{m}$. There are $p(p−1)$ such pairs in total, and we choose one at random, so the probability of $x,y$ colliding is at most $\sfrac{1}{m}$, proving universality of this class of hash functions.

We might want good running times to hold not just in expectation, but with higher probability. This requires stronger conditions on the class (governing how more than two keys interact), and there is much research on achieving those conditions, as well as on making the computation of universal hash functions even faster in practice (as previously observed, modular arithmetic is relatively slow).



### Balls in boxes

Our result above shows that the expected length of a list of colliding elements is $\mathcal{O}(1)$. But what is the maximum length over all lists (assuming a random construction)? This is an example of a result in an area known as "occupancy problems", or more colloquially, "balls in boxes". The idea is our random hashing resembles throwing n balls into $m$ boxes, and we wish in this case to bound the expected maximum occupancy of a box.

As an example of an easier problem, consider the expected number of empty boxes when $n=m$. Intuitively, we believe independent random choices will "spread out" the balls, making the number of empty boxes small. For a given box, the probability of it being empty is the probability that $n$ independently thrown balls each land in one of the other $n−1$ boxes. This is $(1−\frac{1}{n})^{n}$, which approaches $\sfrac{1}{e}$. Using the method of indicator variables, we can conclude that the expected number of empty boxes is roughly $\sfrac{n}{e}$, which may surprise you.

Estimating the expected maximum size of a box (length of a collision list) is a bit more complicated. We start by computing the probability that a given box contains $i$ balls. How can this happen? We can choose $i$ balls to go into the box and the remaining to go somewhere else. For each ball chosen to go into the box, the probability that it actually does is $\frac{1}{n}$; similarly, for each of the remaining balls, the probability that they miss the box is $\frac{n−1}{n}$. Thus the probability we want is $\binom{n}{i} (\frac{1}{n})^{i} (\frac{n−1}{n})^{n−i}$. So the probability that a given box contains at least $k$ balls is $\sum^{n}_{i=k} \binom{n}{i} (\frac{1}{n})^{i} (\frac{n−1}{n})^{n−i}$.

This might seem a little daunting, but we’re only after an upper bound. We can just throw away the third term inside the sum, as it’s between $\sfrac{1}{e}$
and 1. For the binomial coefficient, we need to approximate a factorial, and we do this by taking the definition of the exponential function $e^{x}=\sum_{j \geq 0} \frac{x^{j}}{j!}$, throwing away all but term $j=i$, and substituting $x=i$, giving $(\frac{e}{i})^{i} \geq \frac{1}{i!}$. Then $\binom{n}{i} \leq \frac{n^{i}}{i!} \leq (\frac{ne}{i})^{i}$. This bounds the probability that the given box contains at least $k$ balls by $\sum^{n}_{i=k} (\frac{e}{i})^{i} ≤ (\frac{e}{k})^{k} (\frac{1}{1−e/k})$. Our goal is to find a value of $k$ to get this down to below $\sfrac{1}{n^{2}}$. Why? If we do this, then because there was nothing special about that box, we can bound the probability that some box has at least $k$ balls by $\sfrac{1}{n}$ (even if the bad events are completely disjoint, which they are not).

The expected value $\mathbb{E}[V]$ of a random variable $V$ that ranges over the natural numbers is $\sum_{j \geq 0}j \dot \Pr[V=j]$. Since $\Pr[V \geq i]= \sum_{j \geq i} \Pr[V=j]$, with a bit of manipulation of sigma-notation, we can show that $\mathbb{E}[V]=\sum_{j \geq 0} \Pr[V>j]$. This form is often easier to work with, because the multiplicative factor $j$ is gone, and because the probability of the event with the inequality is often easier to bound. In our case, $V$ is the maximum number of balls in a box. For our given choice of $k$, we will replace the probability terms up to $k$ with 1, and those above $k$ with $\sfrac{1}{n}$, and the resulting sum is bounded by $k+2$.

At this point, I will start waving my hands a bit more. The essence of what we have to do is to find $k$ such that $k^{k} \geq n^{2}$. This is the quantity that dominates the probability expression above; once we find such a $k$, a modest increase (at most a constant factor) will take care of the other parts of the expression. By trying various values, we can convince ourselves that something like $k=c \frac{\ln n}{\ln \ln n}$ will do. This is a sketch of how to show that the expected maximum occupancy is $\mathcal{O}(\frac{\log n}{\log \log n})$, and so this is the expected worst-case running time of chaining. This bound in fact holds with high probability.

A simple idea (which is not simple to analyze) can reduce this quantity. Azar, Broder, Karlin, and Upfal showed in 1994 that choosing two boxes at random and putting the ball into the less-occupied box reduces the maximum occupancy to $\mathcal{O}(\log \log n)$ with high probability. They suggested, among several applications for this idea, using this in what they called "2-way chaining". We’ll revisit this idea later in this chapter.



## Open addressing

The general class of methods known as **open addressing** (for reasons that remain obscure to me) do away with lists or other data structures and store colliding elements elsewhere in the array. This idea, as well as chaining, dates back to at least 1953.

In all of these methods, we try to store $x$ at location $h(x)$, but if it is occupied, we try locations $h_{i}(x)$, for $i=1,2,\ldots,m−1$, stopping when we find an empty location. Since we cannot create an array without initializing it, we need at least one value storable in the array that is not in the domain of the map being represented, and this value will represent "no value stored". Lookup follows the same search strategy.

This presents problems for deletion. One way to cope is to store yet another value outside the domain at the index of a deleted element. Since, unlike with chaining, an open-addressing hash table can fill up, at some point these "deleted" values need to be removed by rehashing all legitimate values into a fresh table. The load factor $\alpha$ has to definitely be less than 1, and sometimes less than that.

In the realm of conceptual ideas we have uniform probing, which extends the idea we discussed above of using a completely random hash function. A probe is just an attempt to use a hash function on a given key. Above we considered the situation where the hash function $h$ was chosen independently at random, uniformly over all functions from $U$ to $[m]$. Here we try to be a little less foolish (but not any more practical) by assuming that for each $k, (h1(k),h2(k),\ldots,hm(k))$ is an independent random permutation of $[m]$, so we don’t ever probe an index we already tried. Under this fanciful assumption, we’d like to bound the expected time of unsuccessful search and successful search.

If $V$ is the number of probes (number of hash functions tried) in an unsuccessful search, then $\Pr[V>1]=\frac{n}{m}=\alpha$. Similarly, $\Pr[V>2]=\frac{n(n−1)}{m(m−1)} \leq \alpha^{2}$, and in general, $\Pr[V>j] \leq \alpha^{j}$, from which we can conclude that $\mathbb{E}[V]=\sum_{j \geq 0} \Pr[V>j] \leq \sum_{j \geq 0} \alpha^{j}=\frac{1}{1−\alpha}$. (If you’re comfortable with manipulating sums of fractions, you can compute this expectation exactly; it turns out to be $\frac{m+1}{m−n+1}$.)

What about a successful search? The cost of a successful search for a key is the same as the length of the probe sequence when it was first inserted, and this is the same sequence as for an unsuccessful search at that point (with a different load factor). We manage the changing load factor by averaging over all keys in the table, so we are bounding the expected time to search for a random key in the table. This is $\frac{1}{n} \sum^{n−1}_{i=0} \frac{1}{1−(i/m)}=\frac{m}{n}(H_{m}−H_{m−n}). We can bound the difference in harmonic numbers (recall these came up in our analysis of treaps in Chapter 4) by a definite integral, and conclude that the expected time of successful search for a random key is bounded above by $\frac{1}{\alpha} \ln \frac{1}{1− \alpha}$.

These results suggest that it’s a good idea not to let the hash table get too full. Less than half full is usually safe.

The simplest practical method is **linear probing**, which chooses one hash function $h(x)$ and then uses $h_{i}(x)=h(x)+i \mod m$. That is, we just try consecutive locations in the table, wrapping around if necessary. This seems too simple, but it works reasonably well in practice. The main drawback is that two keys that initially hash to nearby locations will have their probe sequences merge. This results in worse performance. The main advantage is that accessing consecutive elements of an array exhibits good **locality of reference**, which works nicely with caches and virtual memory.

Knuth (1962) analyzed linear probing under the assumption that a random hash function is chosen as we did at the beginning, so that the choice uniformly distributes any key, and the random variables denoting probe locations for keys are independent. The analysis, while accessible for anyone who has taken an undergraduate course in combinatorics, is too complicated to give here. But the result is that for unsuccessful search, the expected length of the probe sequence is bounded above by $\frac{1}{2}(1+(\frac{1}{1− \alpha})^{2}), and for successful search, the expected length of the probe sequence for a random key is $\frac{1}{2}(1+(\frac{1}{\alpha})$. Knuth later cited this work as the genesis of his multi-volume work The Art of Computer Programming.

Knuth’s analysis, like our discussion of uniform probing above, relies on reasoning about more than two random variables at a time, so we cannot use the Carter-Wegman uniform hashing idea in linear probing and get the same result. Subsequent work involves finding families of hash functions with stronger "universality" properties, as well as more sophisticated analysis of the algorithm to weaken the independence requirements.

**Quadratic probing** avoids the creation of runs by using $h_{i}(x)=h(x)+i^{2} \mod m$. This means that keys that initially hash to different but nearby values will not have much, if any, overlap in their probe sequences. However, keys that initially hash to the same value will have identical probe sequences, as they will in linear probing, and locality of reference is weakened. Care must also be taken in the choice of m. **Double hashing** avoids these issues by choosing two hash functions $h,f$ and using $h_{i}(x)=h(x)+i \dot f(x) \mod m$. The analysis is even more complicated, but a relatively recent result shows that unsuccessful search has expected running time $\mathcal{O}(\frac{1}{1− \alpha})$, matching the result for completely impractical uniform probing.

We have been assuming that elements, once in the table, remain undisturbed (except during total rehashing), but this need not be the case. **Robin Hood hashing** is a policy that can be added to the above probing methods that tags each element in the table with the length of the probe sequence. When there is a collision, the element that continues on its probe sequence is the one with the shortest probe sequence, on the basis that it was lucky early on and now needs to do its fair share. The name comes from an English folk hero reputed to "steal from the rich and give to the poor"; the work was done in a PhD thesis by Celis at the University of Waterloo in 1986. Intuitively, this clusters the distribution of the length of probe sequences more tightly around its mean.



## Cuckoo hashing

Cuckoo hashing is an open addressing method that combines two ideas from above, Robin Hood hashing and 2-way hashing. The work is due to Pagh and Rodler (2001); the name refers to the nesting habits of the European cuckoo, which pushes one egg out of the nest of a bird of another species and lays one of its own. There are several variations; I will discuss a simple one with a simplified analysis. I will need to talk about graphs formed by nodes and edges and some simple structures within them (paths and cycles), but I won’t need any serious graph theory.

We use two hash functions, $h_{1}$ and $h_{2}$ (assume for now that they are random). A key $x$ is guaranteed to be either at index $h_{1}(x)$ or $h_{2}(x)$. This means that the worst-case lookup time is bounded by a constant.

To insert a key, we try to insert it at index $h_{1}(x)$. If this is occupied, we put it there and try to insert the displaced element $y$ at its other possible location, using a similar policy. This may loop, so we attempt it only $t$ times for some threshold $t$, after which we choose a new pair of random hash functions and rehash everything. This is $\mathcal{O}(t)$ in the worst case if there is no rehashing, but it could take less time. That’s about it for the algorithm.

In the analysis, $n$ will be an absolute upper bound on the number of keys in the table (it could be less than this). We define an undirected graph whose nodes are the indices of the table (the elements of $[m]$) with an edge between $h_{1}(x)$ and $h_{2}(x)$, where $x$ is a key in the table. So this graph has at most $n$ edges.

We’re going to reuse part of our analysis for chaining, where we showed that the expected cost of insertion when $n<m$ was $\mathcal{O}(1)$. The fact we needed (that allowed us to use universal hashing instead) was that the probability of two keys $x$ and $y$ colliding was at most $\sfrac{1}{m}$. If we had $\mathcal{O}(\sfrac{1}{m})$ instead, we’d still get the desired result.

The equivalent of a collision here is $x$ and $y$ being connected in the graph, or more precisely, one of $h_{1}(x),h_{2}(x)$ connected to one of $h_{1}(y),h_{2}(y)$. If this does not happen, then the insertion of one of them cannot displace the other. Since the cost of an insertion of a key is bounded by the number of displacements it causes, to show that this cost is bounded in expectation by a constant, it suffices to show that the probability of $x$ and $y$ being connected in the graph is $\mathcal{O}(\sfrac{1}{m})$.

Here is the main lemma that will let us show this: 

> Main Lemma
> 
> for indices $i,j$, if $m \geq 4n$ then the probability that there is a shortest path between $i$ and $j$ of length $\ell \geq 1$ is at most $\frac{1}{m2^{\ell}}$.

Why does the main lemma give us the fact about $x$ and $y$? We bound the probability of their being connected by summing the key lemma probability over all path lengths, and multiplying by four (two choices for each endpoint in the graph). The sum is $\sum_{\ell \geq 1} \frac{1}{m2^{\ell}} \leq \frac{2}{m}$.

The main lemma is proved by induction on $\ell$. For $\ell=1$, for a given item $x$, the probability that ${h_{1}(x),h_{2}(x)}={i,j}$ is $\frac{2}{m^{2}}$. Summing over all items, this is at most $\frac{2n}{m^{2}} \leq \frac{1}{2m}$. Here we are using the fact that the probability of one of two events occurring is at most the sum of the probabilities that each one occurs, even if the events are not independent.

For $\ell>1$, a shortest path between $i$ and $j$ of length $\ell$ must be a path from $i$ and some $k$ of length $\ell−1$ that does not contain $j$, and then an edge between $k$ and $j$. These two events are independent, meaning the probability that both occur is the product of the individual probabilities. We bound the first, for fixed $k$, by $\frac{1}{m2^{\ell−1}}$ by the inductive hypothesis, and the second by $\frac{1}{2m}$ by the same argument as in the $\ell=1$ case. The product is $\frac{1}{m^{2}2^{\ell}}$, and summing over all $k$ gives the bound we want.

That concludes the analysis of insertion provided there is no rehashing. To deal with rehashing, consider the situation where we have a sequence of insertions that take the table from size $\sfrac{n}{2}$ to $n$. We draw the graph with the items present at the end of this sequence. A rehashing cannot occur if there is no cycle in the graph, or if there is no shortest path between two vertices of length more than $t$.

To deal with cycles, we use the main lemma again (the shortest cycle, if it contains vertex $i$, is a shortest path from a vertex $i$ to itself) and get that the probability that there is a shortest cycle of length $\ell$ is at most $\sfrac{1}{2}$. That is not small, but if that happens, we rehash, and the probability of a second rehash is $\sfrac{1}{4}$, and so on, meaning the expected number of rehashes in the sequence due to cycles is bounded by a constant.

For long shortest paths, we choose $t \geq 2 \log n$, and use the main lemma again to show that the probability of a shortest path between $i$ and $j$ of length greater than $t$ is at most $\frac{1}{m^{3}}$, so (summing over all choices of $i,j$) the probability of any shortest path of length greater than $t$ is at most $\frac{1}{m}$, and the expected number of rehashes in the sequence due to long paths is bounded by a constant.

Pagh and Rodler show that the amortized cost of rehashing is $\mathcal{O}(\sfrac{1}{m})$ (we’ve only seen $\mathcal{O}(1)$ here) and describe a practical universal hash function family with stronger properties than Carter-Wegman for which the analysis holds.

We required $m \leq 4n$, meaning the load factor $\alpha$ must be bounded by $\sfrac{1}{4}$. Without breaking the analysis, we can weaken the restriction to $m \leq 2(1+ \epsilon)n$, with the effect that a factor $\mathcal{O}(\sfrac{1}{\epsilon})$ shows up in the time bounds. What this means is that the table cannot get more than half full, and empirical results seem to bear this out (some of the other methods we have discussed can tolerate higher load factors).



## Perfect hashing

A hash function is perfect if for a given set of keys there are no collisions. We also want our hash functions to be quick to compute, and with not too much overhead in storing the information needed to do the computations. Surprisingly, we can achieve a version of this goal. We’ll focus first on the static problem, where the set $S$ of $n$ keys is known in advance and fixed. We want to preprocess them (as quickly as possible) so that the total size of keys and additional information is $\mathcal{O}(n)$, and we can locate each key in worst-case $\mathcal{O}(1)$ time. Fredman, Komlos, and Szemeredi (1982) described a hashing method achieving this.

We’re going to look for a perfect hash function of the form $h_{a}(x)=(ax \mod p) \mod m$, where $a$ is in $[p]$ and not zero. This is like the Carter-Wegman universal hash function family, but simpler because it uses $ax$ instead of $ax+b$ (which makes the family much smaller). Carter and Wegman actually discussed this family in their original paper, and showed it has a weaker universality property. Let’s look at the collisions caused by one of these functions.

We define, for $i \in [m]$, the set $B_{i,a}$ to be all keys that hash to index $i$ when $h_{a}$ is used. More precisely, $B_{i,a}={x \in S | h_{a}(x)=i}$, and its size will be $b_{i,a}$. We want to find a such that all the $b_{i,a}$ are at most one.

We’re going to count the number of colliding pairs of keys over all hash functions in two different ways. This will give us an inequality involving the $b_{i,a}$ for all $i,a$, which will then allow us to find the desired $a$. More precisely, we will count the number of $(a,(x,y))$ with $x>y$ such that $h_{a}(x)=h_{a}(y)$.

The first way is to count over all choices of hash functions and then over all indices. For each choice of $a$ and $i$ we know that $b_{i,a}$ keys hash to $i$ using $h_{a}$, so this contributes $\binom{b_{i,a}}{2}$ pairs $(x,y)$. Summing over all choices of $a$ and $i$ yields $\sum^{p−1}_{a=1} \sum^{m−1}_{i=0} \binom{b_{i,a}}{2}$.

The second way is to count over all pairs $(x,y)$ with $x>y$. For this, we reuse some of the analysis of the Carter-Wegman functions we did above. For fixed $x>y$ and a given $a$, let $r=ax \mod p$ and $s=ay \mod p$. Then $r \equiv s(\mod m), r \neq s$ and $a=(r−s)z \mod p$ where $z \in [p]$ is the unique inverse of $x−y$. If we fix $r$, there are at most $2 \frac{p−1}{m}$ choices for $s$, because $r−s$ could take on values $im$ in the range $0<im<p$, but also values $p−im$ in the same range. There are $\binom{n}{2}$ pairs $x,y$, and this is less than $\sfrac{n^{2}}{2}$, so our sum is less than $\frac{n^{2}(p−1)}{m}$.

Putting the two facts together, we have shown that $\sum^{p−1}_{a=1} \sum^{m−1}_{i=0} \binom{b_{i,a}}{2} < \frac{n^{2}(p−1)}{m}$. This means there is some value of a for which $\sum^{m−1}_{i=0} \binom{b_{i,a}}{2} < \frac{n^{2}}{m}$. If we choose $m=n^{2}$, then the sum is less than one, meaning it must be zero, and all the $b_{i,a}$ are at most one. That is, this value of a gives a perfect hash function into a table of size $n^{2}$. This is bigger than we want, but it’s a start.

This is an existence proof, though. To actually find a good value of $a$, we have to try all possible values, and for each one, hash all the keys to test perfection. We can avoid trying all values by choosing $m=2n^{2}$, which means at least half of all possible choices of a will work. More precisely, $\sum^{p−1}_{a=1} \sum^{m−1}_{i=0} \binom{b_{i,a}}{2} < \frac{n^{2}(p−1)}{2n^{2}} = \frac{p−1}{2}$, so at least half the values of a must make $\sum^{m−1}_{i=0} \binom{b_{i,a}}{2}$ zero. Choosing $a$ to test at random gives an expected search time of $\mathcal{O}(n)$.

To get the size bound down to the desired $\mathcal{O}(n)$, we use this idea in a two-level scheme. The first level hashes into a table of size $2n$. At most half the values of a have $\sum^{m−1}_{i=0} \binom{b_{i,a}}{2} < n$, by the same argument as above, and we find one by trying random choices. For each $i$ such that $b_{i,a}>1$, we use the above idea to hash $B_{i,a}$ perfectly into space $2b^{2}_{i,a}$. Since $\binom{k}{2} = \frac{k(k−1)}{2} = \frac{k^{2}}{2} − \frac{k}{2}$, and $\sum^{m−1}_{i=0}b_{i,a}=n$, we conclude that $\sum^{m−1}_{i=0}2b^{2}_{i,a} < 6n$. The total amount of space taken by all the tables and the information needed to locate each secondary table and compute the corresponding hash function is $\mathcal{O}(n)$, as required. The expected preprocessing time is also $\mathcal{O}(n)$ (because expectations add), and the time taken for a query will be $\mathcal{O}(1)$.

The original paper showed how to reduce the space to $n(1+ \epsilon_{n})$ where $\lim_{n \to \infty} \epsilon_{n}=0$. It also discussed making the preprocessing deterministic, with a worst-case time of $\mathcal{O}(n^{3} \log n)$. Dietzfelbinger _et al._ (1990) showed how to make the scheme dynamic by using the doubling/halving idea for resizing, which results in $\mathcal{O}(1)$ amortized time for insertions and deletions.

I will conclude with a brief mention of a recent Map data structure that combines ideas we’ve seen in different chapters. The hash array-mapped trie (HAMT) data structure of Bagwell (2000) uses an initial word-sized hash of the key which is then used to insert the key and avalue into a trie with branching factor 32 or 64 (so chunks of 5 or 6 hash-value bits are used to navigate). The use of a trie means the data structure can easily be made persistent, unlike the rest of the techniques in this chapter. A bitmap indicating non-empty subtrees is used to compress the array of children of a node to save space without increasing access time; the bitmap is handled using advanced bit-counting instructions available on more recent processors. Other careful engineering decisions have made this the persistent Map implementation of choice for several programming languages (Clojure, Scala, Racket).
