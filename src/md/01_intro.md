---
title: "Functional Data Structures"
author: "Prabhakar Ragde"
date: "5/3/2020"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

# Introduction

> "This ain’t no party / This ain’t no disco / This ain’t no foolin’ around"
> Talking Heads, "Life During Wartime", Fear of Music, 1979

This flânerie is a stroll through intermediate data structures and their associated algorithms, from the point of view of functional programming. In brief: we wish to manipulate data in various ways, to extract information or to store information for later retrieval. We want these operations to be efficient in their use of resources (chiefly time and space). The data may be naturally structured, or we may impose structure on it for the sake of efficiency.

This treatment is not intended to be comprehensive; it originated as a set of lecture summaries for a particular course in a particular undergraduate program (as described below), and the selection of topics was influenced by the predecessor and successor courses. It is also not intended as a reference into which one can dip at random; it was designed as a continuous development in which later sections often depend on earlier ones. Sustained engagement, including doing many or most of the exercises, is important for gaining full benefit.


## 1.1 Required background

This material was used in enriched versions of a required second-year undergraduate course in the Cheriton School of Computer Science at the University of Waterloo (UW), in spring term 2017 and winter term 2018. Admission was voluntary, but required instructor consent.

Students would normally take this course in their fourth term or semester of study. They would have had a first course in computer science using the functional programming language Racket, including coverage of elementary data structures (lists and trees). This would be followed by a second course using the imperative programming language C, introducing basic ideas of algorithm design and analysis (for example, looking at sorting items stored in arrays). Helpful background was also provided by required courses in mathematical proof (using number theory as the vehicle), logic and computation, and probability and statistics.

You do not need all of this past experience to benefit from this stroll. You should have at least one course or equivalent experience in programming. It can be in an imperative language (such as Java, C++, or Python), though the approach here is different. Some exposure to functional programming (in languages such as Lisp, Scheme, Clojure, Racket, Scala, Haskell, or OCaml) would help, but is not essential, if you do additional practice as needed. When I show you code, it will use OCaml, but I will not provide software installation instructions or cover features in detail, expecting you to fill in gaps with documentation and tutorials available on the Web.


## 1.2 Design philosophy

Nearly all computer science programs will have a course on data structures. UW is unusual in also having a third-year required course on algorithms and a fourth-year optional course on advanced algorithms, thus providing coverage of the field in all four years of the program. Most of the subject matter was developed in the period 1965-1980, and the major textbooks were written shortly after that. The approach and content of UW’s conventional second-year data structures course has not changed significantly for decades, and there is considerable overlap with similar courses at other institutions.

But the practice and impact of computing has changed significantly in that time, as has my own personal view of how the subject should be taught. I believe that you will rarely, if ever, be called upon to implement the data structures traditionally studied in such courses, because modern programming languages offer generic versions in libraries or as built-in datatypes. The material is still valuable as a set of case studies in how one thinks about efficient computing. Some of the benefits of such study can be lost if solutions are seen as isolated clever ideas without commonality or generalizability. I have put some effort into finding unifying frameworks and sustained narrative arcs for greater pedagogical effect. The functional paradigm makes such development clearer and more rational, even if the final deployed code is more imperative than the initial approach.

Any alternative educational experience has to be aware of the world in which it is set. I will try to provide sketches of more conventional approaches at appropriate points, so that you are not left with a feeling of having visited a beautiful island unconnected to the mainland.

Details from conventional data structures and algorithms courses are sometimes used as a source of questions for technical interviews for internships and full-time jobs. This is a questionable practice, especially considering the nature of such work nowadays, but it does persist. A truly enlightened interviewer will appreciate a clear answer using an alternative approach, but you may not be so lucky. In preparing for such interviews, you may wish to consult online guides focussing on this aspect, and save the alternative approaches until after the job offer arrives.

To be blunt, working through this material will not help you get a job in the next few months. It may actually make it harder for you to get a job in the next few months! But I believe it will help develop the kinds of cognitive skills that will help you hold onto a job and thrive in it, or move to a better job in the future.

I recommend that you do the exercises; engaging fully with the material is an important part of the learning process. I chose OCaml for reasons I discuss in Chapter 2, but if you prefer, you can use any other language with good support for functional programming. (I originally programmed many of these data structures in Racket.) Although it was not a design goal, I believe this is a reasonable way of starting to learn OCaml, even if you already know about data structures.

Please don’t post solutions anywhere publicly accessible, like a GitHub account or blog. Also please don’t repost or copy any material. If you would like to adapt it for your own purposes, please contact me for permission. (A complete rewrite in your own words is fine; this work is itself a synthesis.)

A logistical note: These Web pages use MathJax to render mathematical expressions, which requires the intervention of a third-party server. If the MathJax server is unreachable, you will see the underlying LaTeX code for the expressions instead. This should be readable, though with difficulty that increases with the complexity of the expression.