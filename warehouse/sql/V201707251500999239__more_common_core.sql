-- some more common core standards

USE ${schemaName};

INSERT INTO common_core_standard (subject_id, natural_id, description) VALUES
  (1,'1.NBT.2','Understand that the two digits of a two-digit number represent amounts of tens and ones.'),
  (1,'2.NBT.1','Understand that the three digits of a three-digit number represent amounts of hundreds, tens, and ones; e.g., 706 equals 7 hundreds, 0 tens, and 6 ones.'),
  (1,'3.NF.3','Explain equivalence of fractions in special cases, and compare fractions by reasoning about their size.'),
  (1,'3.MD.5','Recognize area as an attribute of plane figures and understand concepts of area measurement.'),
  (1,'3.MD.7','Relate area to the operations of multiplication and addition.'),
  (1,'5.NBT.3','Read, write, and compare decimals to thousandths.'),
  (1,'5.NF.7','Apply and extend previous understandings of division to divide unit fractions by whole numbers and whole numbers by unit fractions.'),
  (1,'6.NS.6','Understand a rational number as a point on the number line. Extend number line diagrams and coordinate axes familiar from previous grades to represent points on the line and in the plane with negative number coordinates.'),
  (1,'6.EE.2','Write, read, and evaluate expressions in which letters stand for numbers.'),
  (1,'6.SP.5','Summarize numerical data sets in relation to their context.'),
  (1,'7.RP.2','Recognize and represent proportional relationships between quantities.'),
  (1,'7.EE.4','Use variables to represent quantities in a real-world or mathematical problem, and construct simple equations and inequalities to solve problems by reasoning about the quantities.'),
  (1,'7.SP.8','Find probabilities of compound events using organized lists, tables, tree diagrams, and simulation.'),
  (1,'N-VM.4','Add and subtract vectors.'),
  (1,'N-VM.5','Multiply a vector by a scalar.'),
  (1,'A-SSE.1','Interpret expressions that represent a quantity in terms of its context.'),
  (1,'A-SSE.3','Choose and produce an equivalent form of an expression to reveal and explain properties of the quantity represented by the expression.'),
  (1,'A-REI.4','Solve quadratic equations in one variable.'),
  (1,'F-IF.7','Graph functions expressed symbolically and show key features of the graph, by hand in simple cases and using technology for more complicated cases.'),
  (1,'F-BF.4','Find inverse functions.'),
  (1,'F-LE.1','Distinguish between situations that can be modeled with linear functions and with exponential functions.'),
  (1,'G-SRT.1','Verify experimentally the properties of dilations given by a center and a scale factor.'),
  (1,'S-ID.6','Represent data on two quantitative variables on a scatter plot, and describe how the variables are related.'),
  (1,'S-MD.5','Weigh the possible outcomes of a decision by assigning probabilities to payoff values and finding expected values.');

-- trigger migration
INSERT INTO import (status, content, contentType, digest) VALUES
  (1, 3, 'updated common core standards', 'updated common core standards');
